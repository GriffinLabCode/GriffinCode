%% granger prediction (Gewekes)
% this function will provide a BIC model order output
%
% -- INTPUTS --%
% data: matrix of data (rows = brain region, col = signal)
% mcgc_params: run "get_mvgc_parameters.m"
% modelOrder: model order for prediction
%
% -- OUTPUTS -- %
% gp_cell: a cell array containing frequency domain (gewekes) granger
%           prediction estimations. This array is powerful in that it is
%           insensitive to the number of inputs. You could input 100 brain
%           regions and you will get granger prediction outputs between all
%           100 combinations
% freqs: frequencies
%
% JS 11/8/22 from mvgc

function [gp_cell,freqs] = get_mvgc_freqGranger(data,mvgc_params,modelOrder)

% -- now lets work towards granger -- %
disp('Converting to double...')
data = double(data);

data = demean(data,'true');
disp('Data demeaned to shrink residuals...')

% Estimate VAR model of selected order from data.
ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(data,modelOrder,mvgc_params.regmode);
ptoc;

% Check for failed regression
assert(~isbad(A),'VAR estimation failed');

% The autocovariance sequence drives many Granger causality calculations (see
% next section). Now we calculate the autocovariance sequence G according to the
% VAR model, to as many lags as it takes to decay to below the numerical
% tolerance level, or to acmaxlags lags if specified (i.e. non-empty).
ptic('*** var_to_autocov... ');
[G,info] = var_to_autocov(A,SIG,mvgc_params.acmaxlags);
ptoc;

% The above routine does a LOT of error checking and issues useful diagnostics.
% If there are problems with your data (e.g. non-stationarity, colinearity,
% etc.) there's a good chance it'll show up at this point - and the diagnostics
% may supply useful information as to what went wrong. It is thus essential to
% report and check for errors here.
info = var_info(A,SIG);
assert(~info.error,'VAR error(s) found - bailing out');

% -- frequency domain -- %

% If not specified, we set the frequency resolution to something sensible. Warn if
% resolution is very large, as this may lead to excessively long computation times,
% and/or out-of-memory issues.
if isempty(mvgc_params.fres)
    fres = 2^nextpow2(info.acdec); % based on autocorrelation decay; alternatively, you could try fres = 2^nextpow2(nobs);
	fprintf('\nfrequency resolution auto-calculated as %d (increments ~ %.2gHz)\n',fres,mvgc_params.fs/2/fres);
end
if mvgc_params.fres > 20000 % adjust to taste
	fprintf(2,'\nWARNING: large frequency resolution = %d - may cause computation time/memory usage problems\nAre you sure you wish to continue [y/n]? ',fres);
	istr = input(' ','s'); if isempty(istr) || ~strcmpi(istr,'y'); fprintf(2,'Aborting...\n'); return; end
end

% Calculate spectral pairwise-conditional causalities at given frequency
% resolution - again, this only requires the autocovariance sequence.
ptic('\n*** var_to_spwcgc... ');
f = var_to_spwcgc(A,SIG,mvgc_params.fres);
assert(~isbad(f,false),'spectral GC calculation failed - bailing out');
ptoc;

% Check for failed spectral GC calculation
assert(~isbad(f,false),'spectral GC calculation failed');

% get data out in an automated way
for rowi = 1:size(f,1)
    for coli = 1:size(f,2)
        gp_cell{rowi,coli} = squeeze(f(rowi,coli,:));
    end
end
disp('In gp_cell, COLUMN IS ALWAYS YOUR PREDICTOR, row is always receiving. (col1,row1)=1->1 = NAN. (col1,row2)=1->2. (col2,row1)=2->1');
%{
    % this code demonstrates that the output is in a covariance type
    matrix. Column is predictor, row is receiver.
    figure(); clf;
    plot_spw(f,fs);
%}

% frequency resolution
if isempty(mvgc_params.fres) == 1
    fres  = size(f,3) - 1;
else
    fres = mvgc_params.fres;
end
freqs = sfreqs(fres,mvgc_params.fs);
disp('Please reference SCRIPT_mvgc_granger in the Libraries>Example Pipline Usage>LFP_code folder');

