%% IdPhi
%

function [IdPhi] = get_IdPhi3(x_pos,y_pos,ts_pos,smooth_data)

% try smoothing - moving seems to be smoothest
if smooth_data == 1
    x_pos = smooth(x_pos,'moving');
    y_pos = smooth(y_pos,'moving');
end

% get the derivative of x, y, and t
dx = gradient(x_pos);
dy = gradient(y_pos);
dt = gradient(ts_pos');

% get arctangent of the derivatives (Phi)
phi = atan2(dy./dt,dx./dt);

% unwrap orientation to prevent circular transitions
phi_unwrap = unwrap(phi);

% derivative of phi
dPhi = gradient(phi_unwrap);

% divide by dt
dPhiXdt = dPhi./dt;

% absolute value
absPhi = abs(dPhiXdt);

% multiply time
Phi_final = absPhi.*dt;

% integral
IdPhi = trapz(Phi_final); 

end


