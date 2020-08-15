clear; clc

% inputs will be x and y position data
datafolder = 'C:\Users\uggriffin\Documents\GitHub\CodingClub\Data';

% load vt data
missing_data = 'exclude';
vt_name      = 'VT1.mat';
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% load int
load('Int_file.mat')

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

zIdPhi = zscore(IdPhi);

% distribution
figure(); histogram(zIdPhi)

% plot position data
i = 5;
figure('color','w')
p1 = plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
hold on;
scat1 = scatter(x_data{i},y_data{i},[],y_data{i},'filled');
scat1.MarkerEdgeColor = 'k';
y_min = min(horzcat(y_data{:}));
y_max = max(horzcat(y_data{:}));
ylim([300 400])
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
    ylim([300 400])
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
    ylim([300 400])
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
    ylim([300 400])
    box off
    xlimits = xlim;
    ylimits = ylim;
    text(xlimits(2)/1.2,ylimits(2),['zIdPhi = ',num2str(zIdPhi(LowVTE))])
    xlabel('X position (pixels)')




