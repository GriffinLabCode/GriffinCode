%% preprocessing lfp
%
% Henry used polynomial subtraction methods for detrending LFP. This seems
% to work nicely
%
% I (JS) performed an analysis on increasing sizes of data to determine if
% you should detrend the entire dataset, or just the epoch of interest. I
% found with increasing datasizes, you seem to get a little closer to a
% detrended average of 0. this is what you want because you dont want your
% average to be much greater than 0. moreover, by detrending the entire
% dataset, you control for any influence of detrending on your effects.
%
% I found no evidence that using the polynomial method or the loess method
% made much of a difference. That doesn't mean it doesn't. However, a paper
% that discussed all the toolboxes (find URL) suggested the same. I've messed
% with different approaches, but have decided to stick with the chronux way for
% purposes of reproducibility.
%
% As of 8-23-2021, I (JS) followed powerpoints and examples from Chronux
% toolbox examples. Some modifications were made. 
%
% This code is probably redundant as its calling 'cleaningscript'

function [lfp_clean,lfp_det,lfp_data] = preprocessLFP(lfp_data,params)

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
lfp_data  = change_row_to_column(lfp_data); % chronux

% loess detrend
lfp_det = locdetrend(lfp_data,params.Fs,[1 0.5]);

% scrub of 60hz
%[lfp_clean] = rmlinesc(lfp_det,params,0.05,'n',60);

[lfp_clean, datafit] = rmlinesmovingwinc(lfp_det,[1 0.5],10,params,[],'n');
%lfp_clean = lfp_clean';


end