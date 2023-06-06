%% check int for timestamp - position accuracy
% this function was designed to check the users int file for accuracy
%
% -- INPUTS -- %
% Int: Int file in old formatting
% pos_x: x position data
% pos_y: y position data
% pos_t: timestamps from video camera
%
% -- OUTPUTS -- %
% remData: according to the user, remove these trials
%
% written by John Stout

function [remData] = checkInt(Int,pos_x,pos_y,pos_t)

% number of trials
numTrials = size(Int,1);

figure('color','w'); hold on;    
p1 = []; p2 = [];
for i = 1:numTrials
        subplot(5,8,i); hold on;
        plot(pos_x,pos_y,'Color',[.8 .8 .8]); 
        for ii = 1:size(Int,2)
            Int_x = pos_x(pos_t == Int(i,ii));
            Int_y = pos_y(pos_t == Int(i,ii));
            % plot
            if ii == size(Int,2)
            elseif ii == 1
                x_trial = pos_x(pos_t >= Int(i,1) & pos_t <= Int(i,6));
                y_trial = pos_y(pos_t >= Int(i,1) & pos_t <= Int(i,6));
                plot(x_trial,y_trial,'Color','r','LineWidth',1.5);
            elseif ii == 6
                x_trial = pos_x(pos_t >= Int(i,6) & pos_t <= Int(i,8));
                y_trial = pos_y(pos_t >= Int(i,6) & pos_t <= Int(i,8));
                plot(x_trial,y_trial,'Color','k','LineWidth',1.5);            
            else
            end
        end
        title(['Trial #',num2str(i)])
        axis off
 
end 
set(gcf, 'Position', get(0, 'Screensize'));
remData = str2num(input('Enter which trials to exclude: ','s'));
    
%remData = logical(remData);

% update int file accuracy
