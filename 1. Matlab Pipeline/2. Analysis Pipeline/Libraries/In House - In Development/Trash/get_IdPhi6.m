%% IdPhi
%
% stem_dir = 'y' or 'x' - orientation of stem

function [IdPhi,vel] = get_IdPhi6(x_pos,y_pos,ts_pos,smooth_data)

% using gaussian to pick out the major trend in the data. This seems to
% help for derivatives not jumping around
if smooth_data == 1
    x_pos = smoothdata(x_pos,'gauss',30); % 30 bc 30 samples/sec
    y_pos = smoothdata(y_pos,'gauss',30);        
end

% get the derivative of x, y, and t
dx = gradient(x_pos);
dy = gradient(y_pos);
dt = gradient(ts_pos);

% get angular velocity
vel = atan2(dy./dt,dx./dt);

% hasz and redish paper equation
IdPhi = trapz(abs(gradient(unwrap(atan2(dy./dt,dx./dt)))./dt).*dt);

end


