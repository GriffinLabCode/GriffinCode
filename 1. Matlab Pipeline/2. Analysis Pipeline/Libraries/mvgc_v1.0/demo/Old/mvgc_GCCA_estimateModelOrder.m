%% MVGC "GCCA compatibility mode" demo
%
% Demonstrates usage of the MVGC toolbox in "GCCA compatibility mode"; see
% <mvgchelp.html#6 Miscellaneous issues> in the Help documentation. This is
% partly for the benefit of former users of the Granger Causal Connectivity
% Analysis (<http://www.sussex.ac.uk/Users/anils/aks_code.htm GCCA>) Toolbox
% [2], and partly as an implementation of a more "traditional" approach to
% Granger causality computation. The chief difference is that here two separate
% VAR regressions - the _full_ and _reduced_ regressions (see [1]) - are
% explicitly performed (see <GCCA_tsdata_to_pwcgc.html
% |GCCA_tsdata_to_pwcgc|>), in contrast to the MVGC Toolbox preferred
% approach (see <mvgc_demo.html |mvgc_demo|>), which only requires a full
% regression and is consequently more flexible and numerically accurate.
%
% Granger-causal pairwise-conditional analysis is demonstrated on generated
% VAR data for a 5-node network with known causal structure (see
% <var5_test.html |var5_test|>), as in the main MVGC Toolbox demonstration
% script, <mvgc_demo.html |mvgc_demo|>. A drawback of the traditional dual
% regression approach is that in the frequency domain, _conditional_
% spectral causalities cannot be estimated to an acceptable standard; see
% [1] and <GCCA_tsdata_to_smvgc.html |GCCA_tsdata_to_smvgc|> for more
% detail.
%
%% References
%
% [1] L. Barnett and A. K. Seth,
% <http://www.sciencedirect.com/science/article/pii/S0165027013003701 The MVGC
%     Multivariate Granger Causality Toolbox: A New Approach to Granger-causal
% Inference>, _J. Neurosci. Methods_ 223, 2014
% [ <matlab:open('mvgc_preprint.pdf') preprint> ].
%
% [2] A. K. Seth, "A MATLAB toolbox for Granger causal connectivity analysis",
% _J. Neurosci. Methods_ 186, 2010.
%
% (C) Lionel Barnett and Anil K. Seth, 2012. See file license.txt in
% installation directory for licensing terms.
%

% -- INPUTS -- %
% data: a 2D or 3D array with highly SPECIFIC formatting. 1D (rows) is
% number of signals. 2D (columns) is number of lfp data points. 3D is
% trials. You can only acheive a 3D matrix if the data is the same size,
% probably using a time-resolved method. single trial estimations will only
% have 2 dimensions and simply be a small matrix.
%       -> example: data_ex = rand([2 2000 5]); 
%                       this array contains 2 signals, 2000 data points,
%                       and 5 trials.
%
% -- OUTPUTS -- %
% morder: model order based on your selection criteria

function [morder] = mvgc_GCCA_estimateModelOrder(data,srate)

%% Parameters
get_mvgc_parameters

%% Generate VAR test data
%
% _*Note:*_ This is where you would read in your own time series data; it should
% be assigned to the variable |X| (see below and <mvgchelp.html#4 Common
% variable names and data structures>).

X = data;

%% Model order estimation

% Calculate information criteria up to max model order

ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC] = tsdata_to_infocrit(X,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

[~,bmo_AIC] = min(AIC);
[~,bmo_BIC] = min(BIC);

% Plot information criteria.

%{
figure(1); clf;
plot((1:momax)',[AIC BIC]);
legend('AIC','BIC');
%}

amo = size(X,3); % actual model order

fprintf('\nbest model order (AIC) = %d\n',bmo_AIC);
fprintf('best model order (BIC) = %d\n',bmo_BIC);
fprintf('actual model order     = %d\n',amo);

% Select model order

if     strcmpi(morder,'actual')
    morder = amo;
    fprintf('\nusing actual model order = %d\n',morder);
elseif strcmpi(morder,'AIC')
    morder = bmo_AIC;
    fprintf('\nusing AIC best model order = %d\n',morder);
elseif strcmpi(morder,'BIC')
    morder = bmo_BIC;
    fprintf('\nusing BIC best model order = %d\n',morder);
else
    fprintf('\nusing specified model order = %d\n',morder);
end

end

%{
%% Granger causality estimation

% Calculate time-domain pairwise-conditional causalities. Return VAR parameters
% so we can check VAR.

ptic('\n*** GCCA_tsdata_to_pwcgc... ');
[F,A,SIG] = GCCA_tsdata_to_pwcgc(X,morder,regmode); % use same model order for reduced as for full regressions
ptoc;

% Check for failed (full) regression

assert(~isbad(A),'VAR estimation failed');

% Check for failed GC calculation

assert(~isbad(F,false),'GC calculation failed');

% Check VAR parameters (but don't bail out on error - GCCA mode is quite forgiving!)

rho = var_specrad(A);
fprintf('\nspectral radius = %f\n',rho);
if rho >= 1,       fprintf(2,'WARNING: unstable VAR (unit root)\n'); end
if ~isposdef(SIG), fprintf(2,'WARNING: residuals covariance matrix not positive-definite\n'); end

% Significance test using theoretical null distribution, adjusting for multiple
% hypotheses.

pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat);
sig  = significance(pval,alpha,mhtc);

% Plot time-domain causal graph, p-values and significance.

figure(2); clf;
subplot(1,3,1);
plot_pw(F);
title('Pairwise-conditional GC');
subplot(1,3,2);
plot_pw(pval);
title('p-values');
subplot(1,3,3);
plot_pw(sig);
title(['Significant at p = ' num2str(alpha)])

fprintf(2,'\nNOTE: no frequency-domain pairwise-conditional causality calculation in GCCA compatibility mode!\n');

%%
% <mvgc_demo_GCCA.html back to top>
%}