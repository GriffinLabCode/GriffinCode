% example code demonstrating that this does not work yet. This session has
% clear VTE events that have z scores at around 0.3. We need to try the
% Redish approach for estimating dx and dy.

clear; clc

% inputs will be x and y position data
%datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Ratdle\Muscimol\Baseline';
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Muscimol\Muscimol';

% load vt data
missing_data = 'exclude';
vt_name      = 'VT1.mat';
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% load int
load('Int.mat')

% numtrials
numTrials = length(Int);

% get data
for i = 1:numTrials
    x_data{i}  = ExtractedX(TimeStamps >= (Int(i,5)-(1*1e6)) & TimeStamps <= (Int(i,6)));
    y_data{i}  = ExtractedY(TimeStamps >= (Int(i,5)-(1*1e6)) & TimeStamps <= (Int(i,6)));
    ts_data{i} = TimeStamps(TimeStamps >= (Int(i,5)-(1*1e6)) & TimeStamps <= (Int(i,6)));
end

% get IdPhi
for i = 1:numTrials
    IdPhi(i) = get_IdPhi(x_data{i},y_data{i});
end

zIdPhi = zscore(IdPhi);

% distribution
figure(); histogram(zIdPhi)

% plot position data
i = 4;
figure('color','w')
p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
hold on;
scat1 = scatter(x_data{i},y_data{i},[],y_data{i},'filled');
scat1.MarkerEdgeColor = 'k';
y_min = min(horzcat(y_data{:}));
y_max = max(horzcat(y_data{:}));
ylim([200 300])
xlim([500 700])
box off
xlimits = xlim;
ylimits = ylim;
text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(i))])


%% example plot showing zIdPhi works
% plot position data
[~,HighVTE] = max(zIdPhi);
[~,LowVTE]  = min(zIdPhi);
MidVTE      = dsearchn(zIdPhi',median(zIdPhi)');

figure('color','w')
subplot 311
    p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    hold on;
    scat1 = scatter(x_data{HighVTE},y_data{HighVTE},18,y_data{HighVTE},'filled');
    scat1.MarkerEdgeColor = 'k';
    y_min = min(horzcat(y_data{:}));
    y_max = max(horzcat(y_data{:}));
    ylim([200 300])
    xlim([500 700])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(HighVTE))])
subplot 312
    p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    hold on;
    scat1 = scatter(x_data{MidVTE},y_data{MidVTE},18,y_data{MidVTE},'filled');
    scat1.MarkerEdgeColor = 'k';
    y_min = min(horzcat(y_data{:}));
    y_max = max(horzcat(y_data{:}));
    ylim([200 300])
    xlim([500 700])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(MidVTE))])   
    ylabel('Y position (pixels)')
subplot 313
    p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    hold on;
    scat1 = scatter(x_data{LowVTE},y_data{LowVTE},18,y_data{LowVTE},'filled');
    scat1.MarkerEdgeColor = 'k';
    y_min = min(horzcat(y_data{:}));
    y_max = max(horzcat(y_data{:}));
    ylim([200 300])
    xlim([500 700])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(LowVTE))])
    xlabel('X position (pixels)')

% -- red line plot -- %
%{
figure('color','w')
subplot 311
    p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    hold on;
    
    % vary color based on time in trajectory (reflects evolution of
    % trajectory)
    c = parula(length(x_data{HighVTE}));
    for i = 1:length(x_data{HighVTE})
        plot(x_data{HighVTE}(i),y_data{HighVTE}(i),'LineStyle','none','Marker','o','MarkerSize',4,'MarkerFaceColor',c(i,:),'MarkerEdgeColor','k');
    end
    
    % change axes
    y_min = min(horzcat(y_data{:}));
    y_max = max(horzcat(y_data{:}));
    ylim([200 300])
    xlim([500 700])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(HighVTE))])
subplot 312
    p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    hold on;
    
    % vary color based on time in trajectory (reflects evolution of
    % trajectory)
    c = parula(length(x_data{MidVTE}));
    for i = 1:length(x_data{MidVTE})
        plot(x_data{MidVTE}(i),y_data{MidVTE}(i),'LineStyle','none','Marker','o','MarkerSize',4,'MarkerFaceColor',c(i,:),'MarkerEdgeColor','k');
    end
    
    % change axes
    y_min = min(horzcat(y_data{:}));
    y_max = max(horzcat(y_data{:}));
    ylim([200 300])
    xlim([500 700])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(MidVTE))])   
    ylabel('Y position (pixels)')
subplot 313
    p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    hold on;
    
    % vary color based on time in trajectory (reflects evolution of
    % trajectory)
    c = parula(length(x_data{LowVTE}));
    for i = 1:length(x_data{LowVTE})
        plot(x_data{LowVTE}(i),y_data{LowVTE}(i),'LineStyle','none','Marker','o','MarkerSize',4,'MarkerFaceColor',c(i,:),'MarkerEdgeColor','k');
    end
    
    % change axes
    y_min = min(horzcat(y_data{:}));
    y_max = max(horzcat(y_data{:}));
    ylim([200 300])
    xlim([500 700])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(LowVTE))])
    xlabel('X position (pixels)')
%}

%% plot VTEs greater than 1
VTEs    = find(zIdPhi > 0 & zIdPhi < 2);
%VTEs    = find(zIdPhi > 1);
numVTEs = length(VTEs);

figure('color','w')
for i = 1:numVTEs
    
    subplot(['1',num2str(numVTEs),num2str(i)])
    
        % plot underlying position
        p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
        hold on;
    
        % vary color based on time in trajectory (reflects evolution of
        % trajectory)
        c = parula(length(x_data{VTEs(i)}));
        for ii = 1:length(x_data{VTEs(i)})
            plot(x_data{VTEs(i)}(ii),y_data{VTEs(i)}(ii),'LineStyle','none','Marker','o','MarkerSize',4,'MarkerFaceColor',c(ii,:),'MarkerEdgeColor','k');
        end
    
        % change axes
        y_min = min(horzcat(y_data{:}));
        y_max = max(horzcat(y_data{:}));
        ylim([200 300])
        xlim([500 700])
        box off
        xlimits = xlim;
        ylimits = ylim;
        text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(VTEs(i)))])
end


%% number of VTEs before/after muscimol
%{
clear; clc; close all
Datafolders   = 'X:\01.Experiments\RERh Inactivation Recording\Ratdle';
Day_condition = '\Muscimol'; % day specific treatment condition
infusion      = '\Baseline'; % within day infusion
datafolder    = [Datafolders,Day_condition,infusion];
cd(datafolder);

% load vt data
missing_data = 'exclude';
vt_name      = 'VT1.mat';
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% load int
load('Int.mat')

% numtrials
numTrials = length(Int);

% get data
for i = 1:numTrials
    x_data{i}  = ExtractedX(TimeStamps >= Int(i,5) & TimeStamps <= Int(i,6));
    y_data{i}  = ExtractedY(TimeStamps >= Int(i,5) & TimeStamps <= Int(i,6));
    ts_data{i} = TimeStamps(TimeStamps >= Int(i,5) & TimeStamps <= Int(i,6));
end

% get IdPhi
for i = 1:numTrials
    IdPhi(i) = get_IdPhi(x_data{i},y_data{i});
end

% zscore it
zIdPhi = zscore(IdPhi);

% distribution
figure(); histogram(zIdPhi)

% define thrshold
VTE_threshold = 1; % std - this may need to be adjusted

% number of events
num_VTEs = numel(zIdPhi > VTE_threshold);
%}






