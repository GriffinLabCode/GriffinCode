%% preprocessing lfp
%
% As of 8-23-2021, I (JS) followed powerpoints and examples from Chronux
% toolbox examples. Some modifications were made. 
%
% After working through example datasets, I found that rmlinesc can change
% the data a bit. Moreover, locdetrend doesn't do as good of a job as polynomial method
% at getting the LFP average near 0. Therefore, first we polynomial detrend, then we 
% clean without setting a threshold for significance (bonferroni correction automatically used)
% and finally, we detrend the signal again with locdetrend to account for rmlinesc changing the data.
%
% This code is probably redundant as its calling 'cleaningscript'

<<<<<<< Updated upstream
function [lfp_ready] = preprocessLFP(lfp_data,params)
=======
function [lfp_det,lfp_data] = preprocessLFP(lfp_data,params)
>>>>>>> Stashed changes

%{

% detrend your data
%lfp_det   = polyDetrend(lfp_data); % henry function

% clean your data
lfp_clean = cleaningscript(lfp_data,params); %There was mention of using both
%lfp_clean = rmlinesc(lfp_det,params); % chronux
%}

if exist('params') == 0
	disp('Pulling default parameters')
	params = getCustomParams;
end

if isempty(params.Fs)==1
    error('Must define params.Fs (i.e. sampling rate)');
end

% ensure correct formatting
if size(lfp_data,1) == 1 || size(lfp_data,2) == 1
    lfp_data = change_row_to_column(lfp_data); % chronux
end

% clean data - do not define a significance threshold - let the method
% correct for it

%lfp_clean = rmlinesmovingwinc(lfp_data,[0.25 0.1],10,params,[],'n');

% polynomial detrending - works better than loess at getting the mean near
% 0
lfp_poly = detrend_LFP(lfp_data);

% clean 
lfp_clean = rmlinesc(lfp_poly,params,[],'n');

% henry just detrended LFP and removed artifacts later. I think this is
% important bc dependending on the parameters, the rmlinesc functions can
% really change the LFP.
lfp_det = detrend_LFP(lfp_data);

% loess detrend
<<<<<<< Updated upstream
lfp_ready = locdetrend(lfp_clean,params.Fs);
=======
%lfp_det = locdetrend(lfp_data,params.Fs,[1 0.5]);
>>>>>>> Stashed changes

%{
for i = 1:size(lfp_data,2)
figure; 
plot(lfp_data(:,i),'b'); hold on;
plot(lfp_det(:,i),'r');
pause;
close;
end
%}

%[lfp_clean, datafit] = rmlinesmovingwinc(lfp_det,[1 0.5],10,params,[],'n');
%lfp_clean = lfp_clean';


end