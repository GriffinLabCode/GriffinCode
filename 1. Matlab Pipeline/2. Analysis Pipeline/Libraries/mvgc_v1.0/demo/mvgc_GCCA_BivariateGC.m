%% Granger causality estimation
% X: is the input data in the same format as 'data'. it should be noted
%       that the first row of X is 'x' and the second row of X is 'y'.
%       thus, if first row is PFC and second row is HPC, then x2y would be
%       PFC->HPC
% morder: model order

function [fx2y,fy2x,freqs] = mvgc_GCCA_BivariateGC(X,modelOrder,srate)
%% VAR model estimation (<mvgc_schema.html#3 |A2|>)
    
% Estimate VAR model of selected order from data.
data = X;
get_mvgc_parameters

ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(X,modelOrder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(A),'VAR estimation failed');

% NOTE: at this point we have a model and are finished with the data! - all
% subsequent calculations work from the estimated VAR parameters A and SIG.

%% Autocovariance calculation (<mvgc_schema.html#3 |A5|>)

% The autocovariance sequence drives many Granger causality calculations (see
% next section). Now we calculate the autocovariance sequence G according to the
% VAR model, to as many lags as it takes to decay to below the numerical
% tolerance level, or to acmaxlags lags if specified (i.e. non-empty).

ptic('*** var_to_autocov... ');
[G,info] = var_to_autocov(A,SIG,acmaxlags);
ptoc;

% The above routine does a LOT of error checking and issues useful diagnostics.
% If there are problems with your data (e.g. non-stationarity, colinearity,
% etc.) there's a good chance it'll show up at this point - and the diagnostics
% may supply useful information as to what went wrong. It is thus essential to
% report and check for errors here.

%var_info(info,true); % report results (and bail out on error)

%% Granger causality calculation: frequency domain  (<mvgc_schema.html#3 |A14|>)

% Calculate spectral pairwise-conditional causalities at given frequency
% resolution - again, this only requires the autocovariance sequence.

ptic('\n*** autocov_to_spwcgc... ');
f = autocov_to_spwcgc(G,fres);
ptoc;

% Check for failed spectral GC calculation

assert(~isbad(f,false),'spectral GC calculation failed');

% Plot spectral causal graph.

figure(3); clf;
plot_spw(f,fs);

% get granger causal estimates and frequencies
fy2x   = squeeze(f(1,2,:));
fx2y   = squeeze(f(2,1,:));

% frequency resolution
if exist(fres) == 0 | isempty(fres) == 1
    fres  = size(f,3) - 1;
end
freqs = sfreqs(fres,fs);


%%
% <mvgc_demo_GCCA.html back to top>