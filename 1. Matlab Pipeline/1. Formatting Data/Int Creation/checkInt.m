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
    disp('Press any key to continue...')
    pause;
    close;
end 



