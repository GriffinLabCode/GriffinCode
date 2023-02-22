%% Smoothed histogram plot
%
% -- INPUTS -- %
% data: vector of data
% -- OPTIONAL -- %
% colors: color of figure. Accepts str inputs ('r'/'k',etc...) or matrix
%           inputs ([0 0 1])
% genFig: 'y' or 'Y' to generate a figure. Otherwise, you gen the fig.
%
% -- OUTPUTS -- %
% figure
%
% Written by Rachel Clein from Neunuebel lab and wrapped into a function by
% JS on 2/2023

function CleinPlot(data,colors,plotFig) 
    disp('Code by Rachel Clein from Neunuebel lab sent on 2/2023')

    % specify input variables
    if exist('colors')==0
        disp('Default to black');
        colors = 'k';
    end
    if exist('plotFig')
        if contains(plotFig,[{'y'} {'Y'}])
            figure('color','w');
        end
    end
    
    % do plotting stuff
    hold on;
    [heights,centers]=hist(data);
    n = length(centers);
    w = centers(2)-centers(1);
    t = linspace(centers(1)-w/2,centers(end)+w/2,n+1);
    dt = diff(t);
    Fvals = cumsum([0,heights.*dt]);
    F = spline(t,[0,Fvals,0]);
    DF = fnder(F);
    X = linspace(centers(1)-w/2,centers(end)+w/2,1000);
    Y = fnval(DF,X);
    area(X,Y,'FaceColor',colors);
    set(gca,'ylim',[0 350])
    set(gca,'xlim',[0.05 0.6])
end