%% example multivariate granger causality with mvgc
clear; clc;
cd(getCurrentPath);
load('data4granger');
startup_mvgc1;

%% parameters
ntrials   = size(testingData,3); % number of trials
nobs      = size(testingData,2); % number of observations per trial

% model order - you would want to do this across all of your datasets, then
% take the rounded average to use across all data for granger prediction
% (Cohen 2014)
momax     = 100;    % number of orders to test for
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
regmode   = 'LWR';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)

acmaxlags = 1000;   % 1324; % maximum autocovariance lags (empty for automatic calculation)
fs        = 2000;   % sample rate (Hz)
fres      = [];    % Resolution

%% working with a 2D array - statespace

%testingDemean = demean(testingData);

% convert data into double
disp('converting to double-type')
testingData = double(testingData);

% this is time consuming, you have to run a model on every single epoch or
% trial of interest. However, you'll notice that the model fits the data
% better with smaller model orders compared to when we used a lot of
% observations.
%{
% AIC reflects information lost by the model. Lower values indicate less
% information lost. BIC is like AIC, but generally preferred in our field.
ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(testingData,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

figure('color','w'); clf;
plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
title('Model order estimation');
%}
% -- now lets work towards granger -- %

% Estimate VAR model of selected order from data.
tstart=tic;
ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(testingData,moBIC,regmode);
ptoc;

% Check for failed regression
assert(~isbad(A),'VAR estimation failed');

% The autocovariance sequence drives many Granger causality calculations (see
% next section). Now we calculate the autocovariance sequence G according to the
% VAR model, to as many lags as it takes to decay to below the numerical
% tolerance level, or to acmaxlags lags if specified (i.e. non-empty).
ptic('*** var_to_autocov... ');
[G,info] = var_to_autocov(A,SIG,acmaxlags);
ptoc;

info = var_info(A,SIG);
assert(~info.error,'VAR error(s) found - bailing out');

% Granger causality calculation: frequency domain  (<mvgc_schema.html#3 |A14|>)

% If not specified, we set the frequency resolution to something sensible. Warn if
% resolution is very large, as this may lead to excessively long computation times,
% and/or out-of-memory issues.
if isempty(fres)
    fres = 2^nextpow2(info.acdec); % based on autocorrelation decay; alternatively, you could try fres = 2^nextpow2(nobs);
	fprintf('\nfrequency resolution auto-calculated as %d (increments ~ %.2gHz)\n',fres,fs/2/fres);
end
if fres > 20000 % adjust to taste
	fprintf(2,'\nWARNING: large frequency resolution = %d - may cause computation time/memory usage problems\nAre you sure you wish to continue [y/n]? ',fres);
	istr = input(' ','s'); if isempty(istr) || ~strcmpi(istr,'y'); fprintf(2,'Aborting...\n'); return; end
end
ptic('\n*** var_to_spwcgc... ');
f = var_to_spwcgc(A,SIG,fres);
assert(~isbad(f,false),'spectral GC calculation failed - bailing out');
ptoc;

% Check for failed spectral GC calculation
assert(~isbad(f,false),'spectral GC calculation failed');

%{
fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
Fint = smvgc_to_mvgc(f); % integrate spectral MVGCs
mad = maxabs(F-Fint);
madthreshold = 1e-5;
if mad < madthreshold
    fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
else
    fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
end
%}

% get data out in an automated way
for rowi = 1:size(f,1)
    for coli = 1:size(f,2)
        gp_cell{rowi,coli} = squeeze(f(rowi,coli,:));
    end
end
disp('In gp_cell, COLUMN IS ALWAYS YOUR PREDICTOR, row is always receiving. (col1,row1)=1->1 = NAN. (col1,row2)=1->2. (col2,row1)=2->1');

% frequency resolution
fres=[];
if exist(fres) == 0 | isempty(fres) == 1
    fres  = size(f,3) - 1;
end
freqs = sfreqs(fres,fs);
toc(tstart)

%figure; plot(freqs,f_3_to_1);

% Plot spectral causal graph and compare against your extracted data
figure(); clf;
plot_spw(f,fs);
% row 1 column 3 = effect of signal 3 on signal 1
figure; plot(freqs,gp_cell{1,3});
% row 3 column 1 = effect of signal 1 on signal 3
figure; plot(freqs,gp_cell{3,1});

%% 3D array
% you can do the same work with a 3D array, however, with 3Dimensions, the
% BIC/AIC model fit doesn't work so well

clear;
cd(getCurrentPath);
load('data4granger_3Darray')
testingData3D = double(testingData3D);

% parameters
ntrials   = size(testingData3D,3); % number of trials
nobs      = size(testingData3D,2); % number of observations per trial

% model order - you would want to do this across all of your datasets, then
% take the rounded average to use across all data for granger prediction
% (Cohen 2014)
momax     = 30;    % number of orders to test for
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)

acmaxlags = [];% 1324; % maximum autocovariance lags (empty for automatic calculation)
fs        = 2000;   % sample rate (Hz)
fres      = [];     % max frequency to calculate to. You should leave this empty for automatic calculation.

% AIC reflects information lost by the model. Lower values indicate less
% information lost. BIC is like AIC, but generally preferred in our field.
ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(testingData3D,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

figure('color','w'); clf;
plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
title('Model order estimation');

% -- now lets work towards granger -- %

% Estimate VAR model of selected order from data.
ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(testingData,moBIC,regmode);
ptoc;

% Check for failed regression
assert(~isbad(A),'VAR estimation failed');

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
acerr = var_info(info,true); % report results (and bail out on error)
disp('consider skipping if acerr == 1');

% -- now lets work towards granger -- %
disp('we dont need to worry about time domain granger, but here it is for completion')

% Calculate time-domain pairwise-conditional causalities - this just requires
% the autocovariance sequence.
ptic('*** autocov_to_pwcgc... ');
F = autocov_to_pwcgc(G);
ptoc;

% Check for failed GC calculation
assert(~isbad(F,false),'GC calculation failed');

% -- frequency domain -- %
disp('Freq domain is more relevant to our work');
% Calculate spectral pairwise-conditional causalities at given frequency
% resolution - again, this only requires the autocovariance sequence.
disp('Be warned, gewekes estimation is extremely time consuming...')
ptic('\n*** autocov_to_spwcgc... ');
f = autocov_to_spwcgc(G,fres);
ptoc;

% Check for failed spectral GC calculation
assert(~isbad(f,false),'spectral GC calculation failed');

fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
Fint = smvgc_to_mvgc(f); % integrate spectral MVGCs
mad = maxabs(F-Fint);
madthreshold = 1e-5;
if mad < madthreshold
    fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
else
    fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
end

% get data out in an automated way
for rowi = 1:size(f,1)
    for coli = 1:size(f,2)
        gp_cell{rowi,coli} = squeeze(f(rowi,coli,:));
    end
end
disp('In gp_cell, COLUMN IS ALWAYS YOUR PREDICTOR, row is always receiving. (col1,row1)=1->1 = NAN. (col1,row2)=1->2. (col2,row1)=2->1');

% frequency resolution
if exist(fres) == 0 | isempty(fres) == 1
    fres  = size(f,3) - 1;
end
freqs = sfreqs(fres,fs);

figure; plot(freqs,f_3_to_1);

% Plot spectral causal graph and compare against your extracted data
figure(); clf;
plot_spw(f,fs);
% row 1 column 3 = effect of signal 3 on signal 1
figure; plot(freqs,gp_cell{1,3});
% row 3 column 1 = effect of signal 1 on signal 3
figure; plot(freqs,gp_cell{3,1});


%% alternatively, you could make one long array
clear;
cd(getCurrentPath);
load('data4granger_3Darray')
testingData3D = double(testingData3D);
testingDataLong = reshape(testingData3D,[size(testingData3D,1), size(testingData3D,2)*size(testingData3D,3)]);

% parameters
ntrials   = size(testingDataLong,3); % number of trials
nobs      = size(testingDataLong,2); % number of observations per trial

% model order - you would want to do this across all of your datasets, then
% take the rounded average to use across all data for granger prediction
% (Cohen 2014)
momax     = 30;    % number of orders to test for
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)

acmaxlags = [];% 1324; % maximum autocovariance lags (empty for automatic calculation)
fs        = 2000;   % sample rate (Hz)
fres      = [];     % max frequency to calculate to. You should leave this empty for automatic calculation.

% AIC reflects information lost by the model. Lower values indicate less
% information lost. BIC is like AIC, but generally preferred in our field.
ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(testingDataLong,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

figure('color','w'); clf;
plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
title('Model order estimation');

% -- now lets work towards granger -- %

% Estimate VAR model of selected order from data.
ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(testingDataLong,moBIC,regmode);
ptoc;

% Check for failed regression
assert(~isbad(A),'VAR estimation failed');

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
acerr = var_info(info,true); % report results (and bail out on error)
disp('consider skipping if acerr == 1');

% -- now lets work towards granger -- %
disp('we dont need to worry about time domain granger, but here it is for completion')

% Calculate time-domain pairwise-conditional causalities - this just requires
% the autocovariance sequence.
ptic('*** autocov_to_pwcgc... ');
F = autocov_to_pwcgc(G);
ptoc;

% Check for failed GC calculation
assert(~isbad(F,false),'GC calculation failed');

% -- frequency domain -- %
disp('Freq domain is more relevant to our work');
% Calculate spectral pairwise-conditional causalities at given frequency
% resolution - again, this only requires the autocovariance sequence.
disp('Be warned, gewekes estimation is extremely time consuming...')
ptic('\n*** autocov_to_spwcgc... ');
f = autocov_to_spwcgc(G,fres);
ptoc;

% Check for failed spectral GC calculation
assert(~isbad(f,false),'spectral GC calculation failed');

fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
Fint = smvgc_to_mvgc(f); % integrate spectral MVGCs
mad = maxabs(F-Fint);
madthreshold = 1e-5;
if mad < madthreshold
    fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
else
    fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
end

% get data out in an automated way
for rowi = 1:size(f,1)
    for coli = 1:size(f,2)
        gp_cell{rowi,coli} = squeeze(f(rowi,coli,:));
    end
end
disp('In gp_cell, COLUMN IS ALWAYS YOUR PREDICTOR, row is always receiving. (col1,row1)=1->1 = NAN. (col1,row2)=1->2. (col2,row1)=2->1');

% frequency resolution
if exist(fres) == 0 | isempty(fres) == 1
    fres  = size(f,3) - 1;
end
freqs = sfreqs(fres,fs);

figure; plot(freqs,f_3_to_1);

% Plot spectral causal graph and compare against your extracted data
figure(); clf;
plot_spw(f,fs);
% row 1 column 3 = effect of signal 3 on signal 1
figure; plot(freqs,gp_cell{1,3});
% row 3 column 1 = effect of signal 1 on signal 3
figure; plot(freqs,gp_cell{3,1});