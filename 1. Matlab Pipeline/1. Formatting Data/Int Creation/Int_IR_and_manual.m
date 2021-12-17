%% 
% on earlier versions of automaze approaches, the code didn't spit out
% timestamps for every IR point (for example upon returns). The code always
% returned choice point entrance and exit though. Here, you will define
% goal zone exits, startbox entry, and stem entry. Importantly, these
% coordinates are only needed once unless the maze moves.

% place data into one datafolder to share locations
place2store = 'X:\01.Experiments\R21\Int Location Parameters';

breakOut = 0;
while breakOut == 0
    
    figure('color','w'); hold on;
    title(['Define stem entry and hit enter when finished'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_stem = abs(X)';
    Y_stem = abs(Y)';
    
    figure('color','w'); hold on;
    title(['Define goal zone exit left'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_gz(1) = abs(X)';
    Y_gz(1) = abs(Y)';  
    
    figure('color','w'); hold on;
    title(['Define goal zone exit right'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_gz(2) = abs(X)';
    Y_gz(2) = abs(Y)';
    
    figure('color','w'); hold on;
    title(['Define startbox entry point - this should be high up in sb'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_sb = abs(X)';
    Y_sb = abs(Y)'; 
    
    figure('color','w'); hold on;
    title(['Define choice point entry - this should be prior to divergence'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_cp = abs(X)';
    Y_cp = abs(Y)';
    
    figure('color','w'); hold on;
    title(['Define choice point exit L - this should be after divergence, before reward'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_cpEx(1) = abs(X)';
    Y_cpEx(1) = abs(Y)'; 
    
    figure('color','w'); hold on;
    title(['Define choice point exit R - this should be after divergence, before reward'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;
    % abs value to make positive
    X_cpEx(2) = abs(X)';
    Y_cpEx(2) = abs(Y)';
    
    % plot results
    figure('color','w'); hold on;
    plot(x,y,'Color',[.8 .8 .8])
    plot(X_stem,Y_stem,'Marker','*','MarkerSize',14)
    plot(X_gz(1),Y_gz(1),'Marker','*','MarkerSize',14)
    plot(X_gz(2),Y_gz(2),'Marker','*','MarkerSize',14)
    plot(X_sb,Y_sb,'Marker','*','MarkerSize',14) 
    plot(X_cp,Y_cp,'Marker','*','MarkerSize',14) 
    plot(X_cpEx(1),Y_cpEx(1),'Marker','*','MarkerSize',14) 
    plot(X_cpEx(2),Y_cpEx(2),'Marker','*','MarkerSize',14)     
        prompt = 'Confirm this is correct by pressing Y or y ';
        answer = input(prompt,'s');
        if contains(answer,[{'y'} {'Y'}])
            breakOut = 1;
        else
            breakOut = 0;
        end
    close;

end
cd(place2store);
save('Int_parameters.mat','X_cp','X_cpEx','X_gz','X_sb','X_stem','Y_cp','Y_cpEx','Y_gz','Y_sb','Y_stem')
