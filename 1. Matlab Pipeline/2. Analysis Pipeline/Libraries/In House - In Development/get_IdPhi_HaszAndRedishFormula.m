%% IdPhi
%
clear; clc;

datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Saline\Baseline';

% load vt data
missing_data = 'exclude';
vt_name      = 'VT1.mat';
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% smooth position data?
smooth_data = 0; % 1 for yes

% load int
load('Int.mat')

% numtrials
numTrials = length(Int);

% get data
for i = 1:numTrials
    x_data{i}  = ExtractedX(TimeStamps >= (Int(i,5)-(1*1e6)) & TimeStamps <= Int(i,6));
    y_data{i}  = ExtractedY(TimeStamps >= (Int(i,5)-(1*1e6)) & TimeStamps <= Int(i,6));
    ts_data{i} = TimeStamps(TimeStamps >= (Int(i,5)-(1*1e6)) & TimeStamps <= Int(i,6));
end

% define temporary variable for function
x_pos  = x_data{1};
y_pos  = y_data{1};
ts_pos = ts_data{1}/1e6;

% try smoothing - moving seems to be smoothest
if smooth_data == 1
    x_pos = smooth(x_pos,'moving');
    y_pos = smooth(y_pos,'moving');
end

% get the derivative of x, y, and t
dx = diff(x_pos);
dy = diff(y_pos);
dt = diff(ts_pos);

% get arctangent of the derivatives (Phi)
phi = atan2(dx./dt,dy./dt);

% unwrap orientation to prevent circular transitions
phi_unwrap = unwrap(phi);

% derivative of phi
dPhi = diff(phi_unwrap);

% divide by dt
%dPhiXdt = dPhi./dt;

% absolute value
absPhi = abs(dPhi);

% integrated absolute phi - not sure what they actually meant by
% integrated, but Jesse summed it. Summation seems to be no different than 
% trapz integration.
%IdPhi = sum(absPhi);
IdPhi = trapz(absPhi); 

end


