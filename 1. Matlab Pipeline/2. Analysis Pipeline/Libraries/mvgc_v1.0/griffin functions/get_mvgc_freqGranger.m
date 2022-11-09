%% granger prediction (Gewekes)
% this function will provide a BIC model order output
%
% -- INTPUTS --%
% data: matrix of data (rows = brain region, col = signal)
% mcgc_params: run "get_mvgc_parameters.m"
% modelOrder: model order for prediction
% integrate: set to 1 if you want to calculate temporal granger, then
%               test for frequency domain stability by going back to the
%               temporal domain. This is a great option, but extremely time
%               consuming
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

function [gp_cell,freqs] = get_mvgc_freqGranger(data,mvgc_params,modelOrder,integrate)


% -- now lets work towards granger -- %
data = double(data);

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
acerr = var_info(info,true); % report results (and bail out on error)
if acerr == 1
    return;
    disp('Model is not fitted properly, skipping data');
end

if exist('integrate')
    if integrate == 1
        % Calculate time-domain pairwise-conditional causalities - this just requires
        % the autocovariance sequence.
        ptic('*** autocov_to_pwcgc... ');
        F = autocov_to_pwcgc(G);
        ptoc;

        % Check for failed GC calculation
        assert(~isbad(F,false),'GC calculation failed');
    end
end

% -- frequency domain -- %

% Calculate spectral pairwise-conditional causalities at given frequency
% resolution - again, this only requires the autocovariance sequence.
disp('Be warned, gewekes estimation is extremely time consuming...')
ptic('\n*** autocov_to_spwcgc... ');
f = autocov_to_spwcgc(G,mvgc_params.fres);
ptoc;

% Check for failed spectral GC calculation
assert(~isbad(f,false),'spectral GC calculation failed');

if exist('integrate')
    if integrate == 1
        fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
        Fint = smvgc_to_mvgc(f); % integrate spectral MVGCs
        mad = maxabs(F-Fint);
        madthreshold = 1e-5;
        if mad < madthreshold
            fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
        else
            fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
        end
    end
end

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
if exist(mvgc_params.fres) == 0 | isempty(mvgc_paramsfres) == 1
    fres  = size(f,3) - 1;
end
freqs = sfreqs(fres,mvgc_params.fs);
disp('Please reference SCRIPT_mvgc_granger in the Libraries>Example Pipline Usage>LFP_code folder');

