%% filtLFPartifact
% this function zscore transforms your lfp signal and plots the data out
% for the user to select a z-score criterion to detect artifacts. It then
% removes 1 theta cycle worth of data surrounding the event.

function [lfpNaN,lfp] = filtLFPartifact(lfp,srate)

% zscore transform signal
lfp_og = lfp;

% plot data
next = 0;
while next == 0
    % reset this variable
    lfp = lfp_og;
    zlfp = zscore(lfp);
    
    % show the user data
    figure('color','w');
    plot(zlfp);
    ylabel('standard deviation')
    stdThresh = str2num(input('Defined a std threshold ','s'));
    close;
    
    % plot updated figure, test if the user is happy
    figure('color','w');
    subplot 211;
        % data shown with threshold
        plot(zlfp);
        ylimits = ylim; xlimits = xlim;
        line([xlimits(1) xlimits(2)],[stdThresh stdThresh],'color','r','LineWidth',2);
        line([xlimits(1) xlimits(2)],[-stdThresh -stdThresh],'color','r','LineWidth',2);
        ylabel('standard deviation');
    subplot 212;
        art = find(zlfp>stdThresh | zlfp <-stdThresh);
        % remove 1 theta cycle worth of LFP around artifact
        for i = 1:length(art)
            try
                idx = (art(i)-(round(srate*(0.125/2))):art(i)+(round(srate*(0.125/2))));
                lfp(idx)=NaN;
                zlfp(idx)=NaN;
            end
        end
        plot(zlfp);        
        userHappy = input('Is this threshold sufficient? y/n - enter "stop" to break ','s');
        
        % identify nans, which are the removed signal clips
        lfpNaN = find(isnan(lfp));
    if contains(userHappy,[{'y'} {'Y'}])
        next = 1;
    elseif contains(userHappy,'stop')
        break
    end
end
