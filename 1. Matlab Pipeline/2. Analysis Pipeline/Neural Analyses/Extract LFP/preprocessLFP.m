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

function [lfp_clean,lfp_det,lfp_data] = preprocessLFP(lfp_data,params)

% ensure correct formatting
lfp_data  = change_row_to_column(lfp_data); % chronux

% detrend your data
lfp_det   = polyDetrend(lfp_data); % henry function

% clean your data
lfp_clean = rmlinesc(lfp_det,params); % chronux

end