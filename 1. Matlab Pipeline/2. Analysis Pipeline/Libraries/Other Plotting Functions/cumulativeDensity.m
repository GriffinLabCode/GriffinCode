%% cumulative density figure
% data: cell array containing data
% color: cell array containing color
% x_label: string label
% title_label: string
% paired: 1, y, or Y, for paired kstest. Nothing or anything else for
% two-sample


function [p,kstat] = cumulativeDensity(data,color,x_label,title_label,saveName,paired)

    figure('color','w'); hold on;
    h1 = cdfplot(data{1});
    h1.Color = color{1}; %[.3 .3 .3];
    h2 = cdfplot(data{2});
    h2.Color = color{2}; %[0 .6 0];
    grid off
    ylabel('Cumulative Frequency')
    xlabel(x_label)
    title(title_label)
    set(gcf,'Position',[300 250 350 300])
    
    if exist('paired') & ( paired == 1 | contains(paired,[{'y'},{'Y'}]) )
        [h,p,kstat]=kstest(data{1},data{2});        
    else
        [h,p,kstat]=kstest2(data{1},data{2},'Tail','unequal');
    end
    
    if exist('saveName') 
        print('-painters',[saveName,'.eps'],'-depsc','-r0')
    end

    
    
    