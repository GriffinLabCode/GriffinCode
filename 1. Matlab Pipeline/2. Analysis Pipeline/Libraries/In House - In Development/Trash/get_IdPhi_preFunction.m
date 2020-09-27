%% IdPhi

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

for event_i = 1:length(x_data)
    
    % get 1 trial of data
    x_pos = x_data{event_i};
    y_pos = y_data{event_i};

    % get the derivative of x and y
    deriv_x = diff(x_pos);
    deriv_y = diff(y_pos);

    % get arctangent of the derivatives (Phi)
    phi = atan2(deriv_x,deriv_y);

    % unwrap orientation to prevent circular transitions
    phi_unwrap = unwrap(phi);

    % derivative of phi
    dPhi = diff(phi_unwrap);

    % absolute value
    absPhi = abs(dPhi);

    % integrated absolute phi - not sure what they actually meant by
    % integrated, but Jesse added it.
    IdPhi(event_i) = sum(absPhi);
    
end

% zscore
zIdPhi = zscore(IdPhi);

i = 13;
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



