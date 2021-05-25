%% check int for timestamp - position accuracy

% number of trials
numTrials = size(Int,1);

p1 = []; p2 = [];
for i = 1:numTrials
    figure('color','w'); hold on;    
    p1 = plot(pos_x,pos_y,'Color',[.8 .8 .8]); 
    p1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    % get position data on a trial-by-trial basis
    x_trial = pos_x(pos_t >= Int(i,1) & pos_t <= Int(i,8));
    y_trial = pos_y(pos_t >= Int(i,1) & pos_t <= Int(i,8));
    p2 = plot(x_trial,y_trial,'Color','b');
    %p2.Annotation.LegendInformation.IconDisplayStyle = 'off';    
    title(['Trial ',num2str(i), ': check that stars are adequate Int locations'])
    box off
    % now plot all Int locations
    for ii = 1:size(Int,2)
        Int_x = pos_x(pos_t == Int(i,ii));
        Int_y = pos_y(pos_t == Int(i,ii));
        % plot
        if ii == size(Int,2)
            plot(Int_x,Int_y,'k','Marker','*','MarkerSize',12);
        else
            plot(Int_x,Int_y,'r','Marker','*','MarkerSize',12)
        end
    end
    disp('Keep? ')

    % correct any issues
    question = 'Keep trial? [Y/N] / [y/n] ';
    answer   = input(question,'s');
    
    if contains(answer,[{'N'} {'n'}])
        remData(i) = 1;
    else
        remData(i) = 0;
    end

    %pause;
    close;
end 

remData = logical(remData);

% update int file accuracy

% Populate column 4 of the Int variable 
% 0 = Correct, 1 = Incorrect
Int(:,4) = 0;
numtrials = size(Int,1);
for i = 1:numtrials-1
    if Int(i,3) == 1 && Int(i+1,3) == 0 || Int(i,3) == 0 && Int(i+1,3) == 1
        Int(i+1,4) = 0;
    else
        Int(i+1,4) = 1;
    end
end
percentCorrect = (((numtrials/2)-(sum(Int(:,4))/2))/(numtrials/2))*100;
