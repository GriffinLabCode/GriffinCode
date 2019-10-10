function [fx2y,fy2x,freqs,ssmo] = StateSpaceGranger(data,ssmo)
% MVGC state-space

%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Test data generation

ntrials   = data.num_trials;       % number of trials
nobs      = data.num_observations; % number of observations per trial
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

% Estimate SS model order and model paramaters

[A,C,K,V] = tsdata_to_ss(X,data.pf,ssmo);

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

% only plot freqs between 0 and 100
idx_frex = find(freqs>0 & freqs<50);

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
