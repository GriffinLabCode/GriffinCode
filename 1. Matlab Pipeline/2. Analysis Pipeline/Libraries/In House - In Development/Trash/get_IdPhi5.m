%% IdPhi
%
% stem_dir = 'y' or 'x' - orientation of stem

function [IdPhi] = get_IdPhi5(x_pos,y_pos,stem_dir,smooth_data)

% using gaussian to pick out the major trend in the data. This seems to
% help for derivatives not jumping around
if smooth_data == 1
    x_pos = smoothdata(x_pos,'gauss',30); % 30 bc 30 samples/sec
    y_pos = smoothdata(y_pos,'gauss',30);        
end

% get the derivative of x, y, and t
dx = gradient(x_pos);
dy = gradient(y_pos);

% get arctangent of the derivatives (Phi) - note that if stem direction is
% oriented along the y axis, we want to get x axis because rat would turn
% left/right at choice point along the x axis
if contains(stem_dir,'Y') | contains(stem_dir,'y')
    phi = atan(dx);
elseif contains(stem_dir,'X') | contains(stem_dir,'x')
    phi = atan(dy);
end

% absolute value - this needs to stay
absPhi = abs(phi);    

% IdPhi
IdPhi = trapz(absPhi);

end


