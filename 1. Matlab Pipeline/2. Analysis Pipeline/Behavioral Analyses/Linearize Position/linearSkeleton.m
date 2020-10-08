% Int_traj_indicator tells you which boolean value is left and right.
%                       for example: Int_indicator = 0, tells us that using
%                       the int file, and focusing on column 3, we will do
%                       the trajectory assigned to values "0"
%
% written by John Stout with considerable insight from Van Der Meer code

function linear_skel = linearSkeleton(x, y, ts, stemX, stemY, Int, measurements, Int_indicator)

% inputs need to be the int file
int_bool = Int_indicator;

% inputs will be stem entry, T-junction location, and end points for
% trajectory 
for i = 1:size(Int,1)
    xPos(1,i) = x(ts == Int(i,1));
    xPos(2,i) = x(ts == Int(i,6));
    xPos(3,i) = x(ts == Int(i,2)); 
    xPos(4,i) = x(ts == Int(i,7)); 
    xPos(5,i) = x(ts == Int(i,8)); 
    
    yPos(1,i) = y(ts == Int(i,1));
    yPos(2,i) = y(ts == Int(i,6));    
    yPos(3,i) = y(ts == Int(i,2)); 
    yPos(4,i) = y(ts == Int(i,7));     
    yPos(5,i) = y(ts == Int(i,8));     
end

% -- select turn -- %
figure('color','w'); hold on;
title(['Define your trajectory skeleton to be within the Int locations '  newline  ...
    ' Make sure its defined after your last stem point ' newline ...
    ' The overlayed trajectory is an example of the traj. that you are following '])
plot(x,y,'Color',[.8 .8 .8])
for i = 1:size(yPos,1)
    plot(xPos(i,:),yPos(i,:),'o','Color','b')
    ylim([min(yPos(4,:))-200 max(yPos(4,:))+200]);
    xlim([min(xPos(5,:))-200 max(xPos(2,:))+200]); 
end
% get an example left trajectory
idx_turns = find(Int(:,3)==int_bool);
turn_idx_ex = find(ts == Int(idx_turns(1),1)):find(ts == Int(idx_turns(1),8));
xData = x(turn_idx_ex);
yData = y(turn_idx_ex);
plot(xData,yData,'r')
[newX,newY] = ginput;
close;

% add in the stem
newX2 = horzcat(stemX,newX');
newY2 = horzcat(stemY,newY');
clear newX newY
newX = newX2; newY = newY2;

% combine coordinates
Coord = [newX; newY];

% extract hand measurements
measurements_out = cell2mat(struct2cell(measurements));

% for each of the measurements, except 1, you have to add 1 data point. You
% do this because during the next for loop, you need to remove the very
% first point of each linspaced data (except the first) to remove identical
% overlap in the data
for i = 1:length(measurements_out)
    if i > 1
        measurements_out(i) = measurements_out(i)+1;
    end
end

% using the measurements variable to guide the number of data points (in
% cm), linspace data points.
lin_temp = cell([1 numel(measurements_out)]);
for i = 1:length(measurements_out)
    % x data
    lin_temp{i}(1,:) = linspace(Coord(1,i),Coord(1,i+1),measurements_out(i));
    % y data
    lin_temp{i}(2,:) = linspace(Coord(2,i),Coord(2,i+1),measurements_out(i));
end

% before concatenating, remove the first point in each cell array except
% the first one
for i = 1:length(measurements_out)
    if i > 1
       lin_temp{i}(:,1) = [];
    end
end

% concatenate linear skeletons
linear_skel = horzcat(lin_temp{:});

%{
figure('color','w');
plot(x,y,'Color',[.8 .8 .8]); hold on;
plot(linear_skel(1,:),linear_skel(2,:),'r')
%}
close 