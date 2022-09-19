% position_playBack
% plays back position of rat on maze
%
% --- INPUTS -- %
% Int file
% Extracted X
% Extracted Y
% timestamps for position data
% IntZone: [1 6] means stem entry to choice point exit
% lag = time lag in between playback samples. Can leave empty

function [remData] = position_playBack(Int,pos_x,pos_y,pos_t,IntZones,lag)

if exist('lag')==0
    lag = 0.025;
    disp('Default lag to 0.025s')
end

if exist('IntZone')==0
    IntZone = [1 6];
    disp('Defaulted IntZone to stem entry to choice point exit')
end
       
% loop over trials 
disp('Hit space bar in between trial plottings')
numTrials = size(Int,1);
for triali = 1:numTrials
    
    figure('color','w')
    plot(pos_x,pos_y,'Color',[.6 .6 .6]); 
    hold on;

    % trial specific data
    x_data = []; y_data = []; t_data = [];
    x_data = pos_x(pos_t >= Int(triali,IntZone(1)) & pos_t <= Int(triali,IntZone(2)));
    y_data = pos_y(pos_t >= Int(triali,IntZone(1)) & pos_t <= Int(triali,IntZone(2)));
    t_data = pos_t(pos_t >= Int(triali,IntZone(1)) & pos_t <= Int(triali,IntZone(2)));
  
    % velocity
    head_velocity = [];
    [~,head_velocity] = kinematics2D(x_data,y_data,t_data,'y'); % 'y' to convert to seconds    

    % scatter plot pixel/sec
    s = scatter(x_data(2:end),y_data(2:end),[],head_velocity);
    colorbar
    s.Marker = '.';
    s.SizeData = 75; 
    box off
    
    % video playback
    looper = 1:5:numel(x_data);
    for i = 1:numel(looper)-1
        %tic
        plot(x_data(looper(i):looper(i+1)),y_data(looper(i):looper(i+1)),'*k','MarkerSize',4)
        %toc
        pause(lag); % - matlab lag
    end 
    
    % correct any issues
    %pause()
    question = 'Tag trial for removal? [Y/N] / [y/n] ';
    answer   = input(question,'s');    

    if contains(answer,[{'y'} {'Y'}])
        remData(i) = 1;
    else
        remData(i) = 0;
    end

    %pause;
    close;
end