%% MVGC fun
%
% Demonstrates typical usage of the MVGC toolbox on generated VAR data for a
% 5-node network with known causal structure (see <var5_test.html |var5_test|>).
% Estimates a VAR model and calculates time- and frequency-domain
% pairwise-conditional Granger causalities (also known as the "causal graph").
% Also calculates Seth's causal density measure [2].
%
% This script is a good starting point for learning the MVGC approach to
% Granger-causal estimation and statistical inference. It may serve as a useful
% template for your own code. The computational approach demonstrated here will
% make a lot more sense alongside the reference document> [1], which we
% _strongly recommend_ you consult, particularly Section 3 on design principles
% of the toolbox. You might also like to refer to the <mvgc_schema.html schema>
% of MVGC computational pathways - <mvgc_schema.html#3 algorithms> |A<n>| in
% this demo refer to the algorithm labels listed there - and the
% <mvgchelp.html#4 Common variable names and data structures> section of the
% Help documentation.
%
% *_FAQ:_* _Why do the spectral causalities look so smooth?_ 
%
% This is because spectral quantities are calculated from the estimated VAR,
% rather than sampled directly. This is in accordance with the MVGC design
% principle that all causal estimates be based on the <mvgc_demo.html#6
% estimated VAR model> for your data, and guarantees that spectral causalities
% <mvgc_demo.html#10 integrate correctly> to time-domain causality as theory
% requires. See [1] for details.
% 
% *_Note_*: Do _not_ pre-filter your data prior to GC estimation, _except_
% possibly to improve stationarity (e.g notch-filtering to eliminate line noise
% or high-pass filtering to suppress low-frequency transients). Pre-filtering
% (of stationary data) may seriously degrade Granger-causal inference! If you
% want (time-domain) GC over a limited frequency range, rather calculate
% "band-limited" GC; to do this, calculate frequency-domain GCs over the full
% frequency range, then integrate over the desired frequency band [3]; see
% <smvgc_to_mvgc.html |smvgc_to_mvgc|>.
%
%% References
%
% [1] L. Barnett and A. K. Seth,
% <http://www.sciencedirect.com/science/article/pii/S0165027013003701 The MVGC
%     Multivariate Granger Causality Toolbox: A New Approach to Granger-causal
% Inference>, _J. Neurosci. Methods_ 223, 2014
% [ <matlab:open('mvgc_preprint.pdf') preprint> ].
%
% [2] A. B. Barrett, L. Barnett and A. K. Seth, "Multivariate Granger causality
% and generalized variance", _Phys. Rev. E_ 81(4), 2010.
%
% [3] L. Barnett and A. K. Seth, "Behaviour of Granger causality under
% filtering: Theoretical invariance and practical application", _J. Neurosci.
% Methods_ 201(2), 2011.
%
% (C) Lionel Barnett and Anil K. Seth, 2012. See file license.txt in
% installation directory for licensing terms.
%
function []=mvgc_fun(data,freq)
%% Parameters

ntrials   = size(data.signals,3);  % number of trials
nobs      = size(data.signals,2);  % number of observations per trial

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 100;    % maximum model order for model order estimation

acmaxlags = [];   % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = data.srate;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)

seed      = 0;      % random seed (0 for unseeded)

X         = data.signals;

%% VAR model estimation (<mvgc_schema.html#3 |A2|>)

% Estimate VAR model of selected order from data.

ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(X,morder,regmode);
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

var_info(info,true); % report results (and bail out on error)

%% Granger causality calculation: time domain  (<mvgc_schema.html#3 |A13|>)

% Calculate time-domain pairwise-conditional causalities - this just requires
% the autocovariance sequence.

ptic('*** autocov_to_pwcgc... ');
F = autocov_to_pwcgc(G);
ptoc;

% Check for failed GC calculation

assert(~isbad(F,false),'GC calculation failed');

%{
% Significance test using theoretical null distribution, adjusting for multiple
% hypotheses.
pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
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
%}

% For good measure we calculate Seth's causal density (cd) measure - the mean
% pairwise-conditional causality. We don't have a theoretical sampling
% distribution for this.

cd = mean(F(~isnan(F)));

fprintf('\ncausal density = %f\n',cd);

%% Granger causality calculation: frequency domain  (<mvgc_schema.html#3 |A14|>)

% Calculate spectral pairwise-conditional causalities at given frequency
% resolution - again, this only requires the autocovariance sequence.

ptic('\n*** autocov_to_spwcgc... ');
f = autocov_to_spwcgc(G,fres);
ptoc;

% Check for failed spectral GC calculation

assert(~isbad(f,false),'spectral GC calculation failed');

% Plot spectral causal graph.
%freqs = sfreqs(fres,fs);

% what you need to do is run through data that is the type you will run
% your granger prediction analysis on, then figure this out. The f matrix
% is in the format of a covariance matrix (1->2 is col1/row2, 2->1 is
% col2/row1
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

%figure(3); clf;
%plot_spw(f,fs);

%% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)

% Check that spectral causalities average (integrate) to time-domain
% causalities, as they should according to theory.

fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
Fint = smvgc_to_mvgc(f); % integrate spectral MVGCs
mad = maxabs(F-Fint);
madthreshold = 1e-5;
if mad < madthreshold
    fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
else
    fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
end

%%
% <mvgc_demo.html back to top>
