function [fx2y,fy2x,freqs,ssmo,fx2z,fz2x,fy2z,fz2y] = StateSpaceGranger(data,ssmo,pf)
% MVGC state-space demo

%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load('data_hc_re.mat');

% Test data generation

ntrials   = size(data.signals,3);  % number of trials
nobs      = size(data.signals,2);  % number of observations per trial
fs        = data.srate;            % sample rate (Hz) is actually 

% Actual VAR model generation parameters
nvars     = size(data.signals,1);  % number of variables

% SS model order estimation
ssmosel   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)

% MVGC (frequency domain)
fres      = [];     % spectral MVGC frequency resolution (empty for automatic calculation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if ~exist('seed',   'var'), seed     = 0;    end % random seed (0 for unseeded)
%if ~exist('svconly','var'), svconly  = true; end % only compute SVC for SS model order selection (faster)
if ~exist('plotm',  'var'), plotm    = 0;    end % plot mode (figure number offset, or Gnuplot terminal string)

% Remove temporal mean and normalise by temporal variance.
% Not strictly necessary, but may help numerical stability
% if data has very large or very small values.

X = demean(data.signals,true);

%% VAR model order estimation
%{
% Calculate and plot VAR model order estimation criteria up to specified maximum model order.
ssmoact   = 10; % start with a small model order

% VAR model order estimation - LRT seems consistent
% AIC should be used in cases where a false negative is misleading while
% BIC should be used in cases where a false positive is misleading
% AIC has a high chance of over estimating order, which can be seen with
% baby groot 9-13-18 since it is so high while bic is so low. the field
% uses BIC https://www.methodology.psu.edu/resources/AIC-vs-BIC/

varmosel  = 'BIC';  % VAR model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
varmomax  = nvars*ssmoact; % maximum model order for VAR model order selection

next = 0;
while next == 0
    ptic('\n*** tsdata_to_varmo... ');
    %if isnumeric(plotm), plotm = plotm+1; end
    plotm=0;
    [varmoaic,varmobic,varmohqc,varmolrt] = tsdata_to_varmo(X,varmomax,'LWR',[],[],plotm);
    ptoc;

    % Select and report VAR model order.
    varmo = moselect(sprintf('VAR model order selection (max = %d)',varmomax),varmosel,'AIC',varmoaic,'BIC',varmobic,'HQC',varmohqc,'LRT',varmolrt);
    assert(varmo > 0,'selected zero model order! GCs will all be zero!');
    if varmo >= varmomax
        fprintf(2,'*** WARNING: selected VAR maximum model order (may have been set too low)\n'); 
        % Calculate and plot VAR model order estimation criteria up to specified maximum model order.
        ssmoact   = ssmoact+1; % multiply this by 2 to get more orders to choose from
        varmomax  = nvars*ssmoact; % maximum model order for VAR model order selection
    else
        next = 1; % move on
    end
end

%% SS model order estimation

pf = 2*varmo; % Bauer recommends 2 x VAR AIC model order

next = 0;
while next == 0
    try
        ptic('\n*** tsdata_to_sssvc... ');
        %if isnumeric(plotm), plotm = plotm+1; end
        [ssmosvc,ssmomax] = tsdata_to_sssvc(X,pf,[],plotm);
        ptoc;

        % Select and report SS model order.
        ssmo = moselect(sprintf('SS model order selection (max = %d)',ssmomax),ssmosel,'ACT',ssmoact,'SVC',ssmosvc);

        % Interface
        assert(ssmo > 0,'selected zero model order! GCs will all be zero!');
        if ssmo >= ssmomax
            fprintf(2,'*** WARNING: selected SS maximum model order (may have been set too low)\n'); 
            pf = pf+1; % double the pf variable to get more model order possibilities
        else
            next = 1; % move on
        end
    catch
        next = 0; % re-loop
        pf = pf-1; % may be maxing out to what can  be tested
    end
end

%}
%% SS model estimation

% Estimate SS model order and model paramaters

[A,C,K,V] = tsdata_to_ss(X,pf,ssmo);

% Report information on the estimated SS, and check for errors.

info = ss_info(A,C,K,V);
assert(~info.error,'SS error(s) found - bailing out');
%% Granger causality calculation: time domain

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** ss_to_pwcgc... ');
F = ss_to_pwcgc(A,C,K,V);
ptoc;
assert(~isbad(F,false),'GC estimation failed');

%% Granger causality estimation: frequency domain

if isempty(fres)
    %fres = 2^nextpow2(max(info.acdec,infoo.acdec)); % alternatively, fres = 2^nextpow2(nobs);
	fres = 2^nextpow2(nobs);
    fprintf('\nUsing frequency resolution %d\n',fres);
end
if fres > 10000 % adjust to taste
	fprintf(2,'\nWARNING: large frequency resolution = %d - may cause computation time/memory usage problems\nAre you sure you wish to continue [y/n]? ',fres);
	istr = input(' ','s'); if isempty(istr) || ~strcmpi(istr,'y'); fprintf(2,'Aborting...\n'); return; end
end

ptic(sprintf('\n*** ss_to_spwcgc (at frequency resolution = %d)... ',fres));
f = ss_to_spwcgc(A,C,K,V,fres);
ptoc;
assert(~isbad(f,false),'spectral GC estimation failed');

% Get frequency vector according to the sampling rate.

freqs = sfreqs(fres,fs);

if nvars == 2
    % f bottom value in table is row 1->2 (x2y), f top right is row 2->1 (y2x)
    f_new = reshape(f,[2 length(f)*2]);
    % bottom is x2y, top is y2x. this is because top row is X or 1 and the top
    % row of the f_new variable is 2->1 - figured this out by running their
    % demo and looking at the plot/ finding which values corresponded to which.
    % Also Re leading HPC was a good sign that I'm correct since all methods
    % have shown this.
    fy2x = f_new(1,:);
    fy2x(isnan(fy2x))=[];
    fx2y = f_new(2,:);
    fx2y(isnan(fx2y))=[];
    
    fz2x = NaN;
    fz2y = NaN;
    fx2z = NaN;
    fy2z = NaN;
end

% x is 1, y is 2, z is 3. If you want to confirm for yourself ->
% cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\Triple site');
% load('proof_data_GC_triplesite.mat');
% load('fig_proof_data_GC_triplesite.fig'); and follow each plot

if nvars == 3
    for i = 1:size(f,3)
        fx2y(i) = f(2,1,i);
        fx2z(i) = f(3,1,i);
        
        fy2x(i) = f(1,2,i);
        fy2z(i) = f(3,2,i);
        
        fz2x(i) = f(1,3,i);
        fz2y(i) = f(2,3,i);      
    end
end

%{
figure('color',[1 1 1]);
    plot(freqs(idx_frex),fy2x(idx_frex),'b')
    hold on;
    plot(freqs(idx_frex),fx2y(idx_frex),'k')
    legend('Re->HPC', 'HPC->Re');
    ylabel('State space GC estimates')
    xlabel('Frequency')
    box off
%}

%% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)

% Check that spectral causalities average (integrate) to time-domain
% causalities. Note that this may occasionally fail if a certain condition
% on the VAR parameters is not satisfied (see refs. [4,5]).

Fint = bandlimit(f,3); % integrate spectral MVGCs (frequency is dimension 3 of CPSD array

fprintf('\n*** GC spectral integral check... ');
rr = abs(F-Fint)./(1+abs(F)+abs(Fint)); % relative residuals
mrr = max(rr(:));                       % maximum relative residual
if mrr < 1e-5
    fprintf('PASS: max relative residual = %.2e\n',mrr);
else
    fprintf(2,'FAIL: max relative residual = %.2e (too big!)\n',mrr);
end

