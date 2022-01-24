%% 
% a second filter for VTE

% this code identifies trials where the rats enter both goal arms before
% making a choice

% only works for automaze right now

function [oopsTrial] = oopsTrials(x,y)

% These are the dimensions selected after checking multiple sessions across
% multiple rats
%yLeft  = 230;
%yRight = 180;

%xmin = 390; 
%xmax = 450;

% identify parameters for left choice point
minY = 223; addY = abs(minY-300);
minX = 390; addX = abs(minX-450);
lCP_fld = [minX minY addX addY]; %[180 215 395 50]; % x,y (first corner) , x,y (second right top corner)

xv_lCP = [lCP_fld(1)+lCP_fld(3) lCP_fld(1) lCP_fld(1) lCP_fld(1)+lCP_fld(3) lCP_fld(1)+lCP_fld(3)];
yv_lCP = [lCP_fld(2) lCP_fld(2) lCP_fld(2)+lCP_fld(4) lCP_fld(2)+lCP_fld(4) lCP_fld(2)];

% same for right choice point
minY = 105; addY = abs(minY-193);
minX = 390; addX = abs(minX-450);
rCP_fld = [minX minY addX addY]; %[180 215 395 50]; % x,y (first corner) , x,y (second right top corner)

xv_rCP = [rCP_fld(1)+rCP_fld(3) rCP_fld(1) rCP_fld(1) rCP_fld(1)+rCP_fld(3) rCP_fld(1)+rCP_fld(3)];
yv_rCP = [rCP_fld(2) rCP_fld(2) rCP_fld(2)+rCP_fld(4) rCP_fld(2)+rCP_fld(4) rCP_fld(2)];

% now for each trial identify if the rat was in one bin before entering the
% other
for triali = 1:length(x)
    
    % check if the rat is in both areas for this trial
    [in_left]  = inpolygon(x{triali},y{triali},xv_lCP,yv_lCP);
    [in_right] = inpolygon(x{triali},y{triali},xv_rCP,yv_rCP);
    
    % find instances where the rat is in both
    idxInLeft  = find(in_left==1);
    idxInRight = find(in_right==1);
    
    % 
    if isempty(idxInLeft) == 0 && isempty(idxInRight)==0
        oopsTrial(triali) = 1;
    else
        oopsTrial(triali) = 0;
    end
    
end

%{
hold on;
rectangle ('position', rCP_fld);  % right reward field
rectangle ('position', lCP_fld);  % left reward field
%}


