%% get_session_IdPhi
% this function uses a function gifted to me (JS) from David Redish to
% estimate IdPhi. I modified the function to work with our lab, but he
% should be acknowledged for his contribution.
%
% this function takes one days worth of data and computes IdPhi across
% trials. There are many outputs
%
% int_input: can either be the name of the Int file, or the int file itself

function [IdPhi,x_data,y_data,ts_data,ExtractedX,ExtractedY,TimeStamps,timeSpent,x_data_raw,y_data_raw,ts_data_raw,remEmpty] = get_session_IdPhi_automaze(datafolder,int_input,vt_name,missing_data,middleStemPosition,stemOrientation,preSmooth,mazeLoc,runDirection)

% get IdPhi
window_sec    = 1;   % redish inputs
postSmoothing = 0.5; % redish inputs
vt_srate      = ceil(1/mean(diff(TimeStamps/1e6))); % rounded to a integer for ease of computation and stuff
display       = 0;

for i = 1:numTrials
    [IdPhi(i),dphi{i}] = IdPhi_RedishFun(x_data{i},y_data{i},window_sec,postSmoothing,vt_srate,display);
end

end