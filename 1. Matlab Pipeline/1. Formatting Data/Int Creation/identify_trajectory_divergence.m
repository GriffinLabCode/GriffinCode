function [X,Y] = identify_trajectory_divergence(x,y)

breakOut = 0;
while breakOut == 0
    
    figure('color','w'); hold on;
    title(['Define the T-intersection - Hit Enter when finished...'])
    plot(x,y,'Color',[.8 .8 .8])
    [X,Y] = ginput;
    close;

    % abs value to make positive
    X = abs(X)';
    Y = abs(Y)';

    figure('color','w'); hold on;
    plot(x,y,'Color',[.8 .8 .8])
    plot(X,Y,'Marker','*','MarkerSize',14)
        prompt = 'Confirm this is correct by pressing Y or y ';
        answer = input(prompt,'s');
        if contains(answer,[{'y'} {'Y'}])
            breakOut = 1;
        else
            breakOut = 0;
        end
    close;
end


