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

function [remStem2Choice, remReturn, remDelay] = checkInt(Int,pos_x,pos_y,pos_t)

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
                plot(x_trial,y_trial,'Color',[1, 0, 0, 1],'LineWidth',2);
                missingStem = numel(find(x_trial==0));
                numStem = numel(x_trial);
                rateStem = missingStem/numStem;
            elseif ii == 6
                x_trial = pos_x(pos_t >= Int(i,6) & pos_t <= Int(i,8));
                y_trial = pos_y(pos_t >= Int(i,6) & pos_t <= Int(i,8));
                plot(x_trial,y_trial,'Color',[0, 0, 0, 0.5],'LineWidth',1);
                missingRet = numel(find(x_trial==0)); 
                numRet = numel(x_trial);
                rateRet = missingRet/numRet;
            else
            end
        end
        title(['Trial #',num2str(i)])
        text(min(pos_x)+20,min(pos_y)+150,['stemLost=',num2str(round(rateStem,2))],'Color','r');
        text(min(pos_x)+20,min(pos_y)+50,['retLost=',num2str(round(rateRet,2))],'Color','b');
        axis off
 
end 
set(gcf, 'Position', get(0, 'Screensize'));
remStem2Choice = str2num(input('Enter trials with >10% tracking error in stem/choice, failed stem entry or choice exit: ','s'));
remReturn = str2num(input('Enter trials with >10% tracking error in return: ','s'));
remDelay = str2num(input('Enter trials with failed startbox entry: ','s'));

%remData = logical(remData);

% update int file accuracy
