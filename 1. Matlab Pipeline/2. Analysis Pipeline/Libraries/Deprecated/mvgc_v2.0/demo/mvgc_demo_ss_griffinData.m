%% MVGC state-space demo

%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0')
startup_fun;
cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0\demo')
load('data_hc_re.mat');

% Test data generation

ntrials   = data.num_trials;       % number of trials
nobs      = data.num_observations; % number of observations per trial
fs        = data.srate;            % sample rate (Hz)

% Actual VAR model generation parameters

nvars     = 2;      % number of variables
ssmoact   = 100;      % SS model order
%rhoa      = 0.95;   % AR spectral radius
%wvar      = 0.5;    % var coefficients decay weighting factor
%rmi       = 0.5;    % residuals log-generalised correlation (multi-information)
                    % g = -log|R|. g = 0 yields zero correlation,g = [] is uniform random
                    % on space of correlation matrices

% VAR model order estimation

varmosel  = 'AIC';  % VAR model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
varmomax  = nvars*ssmoact; % maximum model order for VAR model order selection

% SS model order estimation

ssmosel   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
% MVGC (frequency domain)

fres      = [];     % spectral MVGC frequency resolution (empty for automatic calculation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if ~exist('seed',   'var'), seed     = 0;    end % random seed (0 for unseeded)
%if ~exist('svconly','var'), svconly  = true; end % only compute SVC for SS model order selection (faster)
if ~exist('plotm',  'var'), plotm    = 0;    end % plot mode (figure number offset, or Gnuplot terminal string)

%% Generate random SS test data

% Generate random SS parameters in innovations form

%[AA,CC,KK] = iss_rand(nvars,ssmoact,rhoa);

% Generate random residuals covariance (in fact correlation) matrix.

%VV = corr_rand(nvars,rmi);

% Report information on the generated VAR model and check for errors.

%infoo = ss_info(AA,CC,KK,VV);
%assert(~infoo.error,'SS error(s) found - bailing out');

% Remove temporal mean and normalise by temporal variance.
% Not strictly necessary, but may help numerical stability
% if data has very large or very small values.

X = demean(data.signals,true);

%% VAR model order estimation

% Calculate and plot VAR model order estimation criteria up to specified maximum model order.

ptic('\n*** tsdata_to_varmo... ');
if isnumeric(plotm), plotm = plotm+1; end
[varmoaic,varmobic,varmohqc,varmolrt] = tsdata_to_varmo(X,varmomax,'LWR',[],[],plotm);
ptoc;

% Select and report VAR model order.

varmo = moselect(sprintf('VAR model order selection (max = %d)',varmomax),varmosel,'AIC',varmoaic,'BIC',varmobic,'HQC',varmohqc,'LRT',varmolrt);
assert(varmo > 0,'selected zero model order! GCs will all be zero!');
if varmo >= varmomax, fprintf(2,'*** WARNING: selected VAR maximum model order (may have been set too low)\n'); end

%% SS model order estimation

pf = 2*varmo; % Bauer recommends 2 x VAR AIC model order

ptic('\n*** tsdata_to_sssvc... ');
if isnumeric(plotm), plotm = plotm+1; end
[ssmosvc,ssmomax] = tsdata_to_sssvc(X,pf,[],plotm);
ptoc;

% Select and report SS model order.
ssmo = moselect(sprintf('SS model order selection (max = %d)',ssmomax),ssmosel,'ACT',ssmoact,'SVC',ssmosvc);

assert(ssmo > 0,'selected zero model order! GCs will all be zero!');
if ssmo >= ssmomax, fprintf(2,'*** WARNING: selected SS maximum model order (may have been set too low)\n'); end

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

% NOTE: we don't have an analytic (asymptotic) distribution for the statistic, so no significance testing here!

% For comparison, we also calculate the actual pairwise-conditional causalities
%{
ptic('*** ss_to_pwcgc... ');
FF = ss_to_pwcgc(AA,CC,KK,VV);
ptoc;
assert(~isbad(FF,false),'GC calculation failed');

% Plot time-domain causal graph

maxF = 1.1*max(nanmax(F(:),nanmax(FF(:))));
if isnumeric(plotm), plotm = plotm+1; end
plot_gc({FF,F},{'PWCGC (actual)','PWCGC (estimated)'},[],[maxF maxF],plotm);
%}

%% Granger causality estimation: frequency domain

if isempty(fres)
    fres = 2^nextpow2(max(info.acdec,infoo.acdec)); % alternatively, fres = 2^nextpow2(nobs);
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

% For comparison, we also calculate the actual pairwise-conditional spectral causalities

ptic(sprintf('*** ss_to_spwcgc (at frequency resolution = %d)... ',fres));
ff = ss_to_spwcgc(AA,CC,KK,VV,fres);
ptoc;
assert(~isbad(ff,false),'spectral GC calculation failed');

% Get frequency vector according to the sampling rate.

freqs = sfreqs(fres,fs);

% Plot spectral causal graphs.

if isnumeric(plotm), plotm = plotm+1; end
plot_sgc({ff,f},freqs,'Spectral Granger causalities (blue = actual, red = estimated)',plotm);

% f bottom value in table is row 1->2, f top right is row 2->1
f_new = reshape(f,[2 length(f)*2]);
% bottom is x2y, top is y2x. this is because top row is X or 1 and the top
% row of the f_new variable is 2->1
fy2x = f_new(1,:);
fy2x(isnan(fy2x))=[];
fx2y = f_new(2,:);
fx2y(isnan(fx2y))=[];

% only plot freqs between 0 and 100
idx_frex = find(freqs>0 & freqs<50);

figure('color',[1 1 1]);
    plot(freqs(idx_frex),fy2x(idx_frex),'b')
    hold on;
    plot(freqs(idx_frex),fx2y(idx_frex),'k')
    legend('Re->HPC', 'HPC->Re');
    ylabel('State space GC estimates')
    xlabel('Frequency')
    box off

%% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)

%{
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
%}
%%
% <mvgc_demo.html back to top>
