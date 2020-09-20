%% number of VTEs before/after muscimol
clear; clc;
addpath('X:\01.Experiments\John n Andrew\Data and Exploratory\VTEs and Re suppression')

% main Datafolder
Datafolders   = 'X:\01.Experiments\RERh Inactivation Recording';

% int name and vt name
int_name     = 'Int_VTE_JS';
vt_name      = 'VT1.mat';
missing_data = 'interp'; % interpolate missing data

% preSmooth smooths the position data by 1 second
preSmooth = 1; % 1 for yes, 0 for no

% define middle of stem
middleStemPosition = 500;

% what orientation is the stem?
stemOrientation = 'X'; % going forward in the x direction or y direction

% rat names
rat{1} = 'Usher';
rat{2} = 'Rick';
rat{3} = 'Ratticus';
rat{4} = 'Ratdle';
rat{5} = 'Eric2';
rat{6} = '14-22';

% condition
Day_cond{1} = 'Saline';
Day_cond{2} = 'Muscimol';
Day_cond{3} = 'Baseline';

% infusion treatment
infusion{1} = '\Baseline';
infusion{2} = '\Saline';
infusion{3} = '\Muscimol'; % within day infusion

% loop across rats
for rat_i = 1:length(rat)
    
    % datafolder for the rat
    datafolder = [];
    datafolder_rat = [Datafolders,'\',rat{rat_i}];
    
    for day_cond_i = 1:length(Day_cond)
        
        % datafolder that includes condition
        datafolder_cond = [datafolder_rat,'\',Day_cond{day_cond_i}];
        
        % get content in directory
        dir_content = dir(datafolder_cond);
        dir_content = extractfield(dir_content,'name');
 
        % find non folders
        remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
        
        % remove .mat files
        dir_content(remIdx)=[];
        
        % loop across infusion conditions
        for inf_i = 1:length(dir_content)
        
            % define datafolder
            datafolder = [datafolder_cond,'\',dir_content{inf_i}];

            % the struct array below that organizes the data cannot create
            % fields with space characters, therefore rename them if they
            % exist.
            if contains(dir_content{inf_i},'Baseline 1')
                dir_content{inf_i} = 'Baseline1';
            elseif contains(dir_content{inf_i},'Baseline 2')
                dir_content{inf_i} = 'Baseline2';
            end
            
            % if rat has a '-' character in it, remove
            if contains(rat{rat_i},'14-22')
                rat{rat_i} = 'rat1422';
            end
            
            % get VTE data in a structure array that is organized based on
            % rat, day condition, and infusion type
            [IdPhi.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             xPos.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             yPos.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             tsPos.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             xPosOG.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             yPosOG.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             tsPosOG.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i}),...
             timeSpent.(rat{rat_i}).(Day_cond{day_cond_i}).(dir_content{inf_i})] ...
             = get_session_IdPhi(datafolder,int_name,vt_name,missing_data,middleStemPosition,stemOrientation,preSmooth);
                
            % restore appropriate naming for 14-22
            if contains(rat{rat_i},'rat1422')
                rat{rat_i} = '14-22';
            end
                    
        end       
    end
end
   
% -- z score data across sessions, but within each rat -- %

% rat names
rat{1} = 'Usher';
rat{2} = 'Rick';
rat{3} = 'Ratticus';
rat{4} = 'Ratdle';
rat{5} = 'Eric2';
rat{6} = 'rat1422';

for rati = 1:length(rat)
    
    % col 1 is baseline, col 2 is infusion
    IdPhi_bl_saline{rati} = IdPhi.(rat{rati}).Saline.Baseline;
    IdPhi_sa_saline{rati} = IdPhi.(rat{rati}).Saline.Saline;
    
    % baseline
    IdPhi_bl_baseline1{rati} = IdPhi.(rat{rati}).Baseline.Baseline1;
    IdPhi_bl_baseline2{rati} = IdPhi.(rat{rati}).Baseline.Baseline2;
  
    % muscimol
    IdPhi_mu_baseline{rati} = IdPhi.(rat{rati}).Muscimol.Baseline;
    IdPhi_mu_muscimol{rati} = IdPhi.(rat{rati}).Muscimol.Muscimol;
    
    % concatenate data
    IdPhi_data{rati} = horzcat(IdPhi_bl_saline{rati},IdPhi_sa_saline{rati},IdPhi_bl_baseline1{rati},...
        IdPhi_bl_baseline2{rati},IdPhi_mu_baseline{rati},IdPhi_mu_muscimol{rati});
    
    % array required to return 
    return_sizes{rati} = horzcat(numel(IdPhi_bl_saline{rati}),numel(IdPhi_sa_saline{rati}),...
        numel(IdPhi_bl_baseline1{rati}),numel(IdPhi_bl_baseline2{rati}),...
        numel(IdPhi_mu_baseline{rati}),numel(IdPhi_mu_muscimol{rati}));
    
end

% zscore across sessions, then return data
return_sizes2 = cellfun(@numel,IdPhi_data,'UniformOutput',false);
IdPhi_cat  = horzcat(IdPhi_data{:});
%zIdPhi_cat = zscore(IdPhi_cat);
zIdPhi_cat = zscore(log(IdPhi_cat));
zIdPhi_dist = zIdPhi_cat; % save the distribution
for rati = 1:length(rat)
    zIdPhi_all{rati} = zIdPhi_cat(1:return_sizes2{rati}(1));
    zIdPhi_cat(1:return_sizes2{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes2{rati}(1) = [];
end

for rati = 1:length(rat)
    
    % reorganize data, delete zIdPhi_all data and return sizes after
    % finishing with it
    zIdPhi.(rat{rati}).Saline.Baseline = zIdPhi_all{rati}(1:return_sizes{rati}(1)); % extract
    zIdPhi_all{rati}(1:return_sizes{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes{rati}(1) = [];
    
    % now do saline condition within saline
    zIdPhi.(rat{rati}).Saline.Saline = zIdPhi_all{rati}(1:return_sizes{rati}(1));
    zIdPhi_all{rati}(1:return_sizes{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes{rati}(1) = [];
    
    % baseline - 
    zIdPhi.(rat{rati}).Baseline.Baseline1 = zIdPhi_all{rati}(1:return_sizes{rati}(1)); % extract
    zIdPhi_all{rati}(1:return_sizes{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes{rati}(1) = [];
    
    % now do saline condition within saline
    zIdPhi.(rat{rati}).Baseline.Baseline2 = zIdPhi_all{rati}(1:return_sizes{rati}(1));
    zIdPhi_all{rati}(1:return_sizes{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes{rati}(1) = [];    
  
    % muscimol
    zIdPhi.(rat{rati}).Muscimol.Baseline = zIdPhi_all{rati}(1:return_sizes{rati}(1)); % extract
    zIdPhi_all{rati}(1:return_sizes{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes{rati}(1) = [];
    
    % now do saline condition within saline
    zIdPhi.(rat{rati}).Muscimol.Muscimol = zIdPhi_all{rati}(1:return_sizes{rati}(1));
    zIdPhi_all{rati}(1:return_sizes{rati}(1))=[]; % erase this data so that we can continue extracting
    return_sizes{rati}(1) = [];      
end

% house keeping
%clearvars -except zIdPhi zIdPhi_dist IdPhi xPos xPosOG yPos yPosOG tsPos tsPosOG zIdPhi_dist rat Day_cond zThresh

%% determine a threshold using redish method with gaussian
%{
% what z-score is in the 75th percentile, per rat?
figure('color','w')
h1 = histogram(zIdPhi_dist); hold on;
h1.FaceColor = 'r';
ylimits = ylim;
title('Distribution of zIdPhi estimates across sessions')
box off
ylabel('Number of Trials')
xlabel('zIdPhi')
h1.BinWidth = 0.1;
bins = h1.BinEdges;
%}

% try fitting a complex 
fig = figure('color','w');
h1 = histogram(zIdPhi_dist); hold on;
h1.FaceColor = 'r';
ylimits = ylim;
title('Distribution of zIdPhi estimates across sessions')
box off
ylabel('Number of Trials')
xlabel('zIdPhi')
h1.BinWidth = 0.1;
zIdPhi_bins = h1.BinEdges;
axis tight;
% fit kernel distirbution 
%pd = fitdist(zIdPhi_dist','Kernel','Kernel','epanechnikov');
pd = fitdist(zIdPhi_dist','Kernel','Kernel','normal');
stepVal = 1/length(zIdPhi_dist);
x_curve = h1.BinEdges(1):stepVal:h1.BinEdges(end);
y_curve = pdf(pd,x_curve);
yyaxis right; hold on;
plot(x_curve,y_curve,'k','LineWidth',2); 

% -- identify the first largely positive deflection, this will be our
% threshold -- %
% find first point of deflection after second half of peak in curve
y_axis = h1.BinCounts;
x_axis = h1.BinEdges;
[maxVal,maxIdx] = max(y_axis); % use the index for the max val to extract x-axis
maxBins = x_axis(maxIdx:maxIdx+1); % +1 because we're working with bins
% now using maxBins(2) to identify the distribution after the most common
% value
y_curve_remainder = y_curve(x_curve > maxBins(2));
x_curve_remainder = x_curve(x_curve > maxBins(2));
% take derivative to find first point of positive deflection
dy_curve_remainder = gradient(y_curve_remainder);
positiveDeflections = find(dy_curve_remainder > 0);
firstPosDeflection = positiveDeflections(1);
binFirstPosDef = round(x_curve_remainder(firstPosDeflection),1); % round to the first decimal to the right

% ---- UPDATE ---- %
% 9-17-2020, after visual inspection of behavior, time spent, and head
% velocity, a threshold of 1 seems better and corresponds to the second
% bump in the distribution. This should ensure minimal false positive VTE
% classifications
% ----  END   ---- %

% find the second maximima in the VTE distribution to ensure minimal false
% positives (this is overly conservative). Get the bin of first maximima
% after the bin of first positive deflection
%peaks()
x_after1posDef = x_curve_remainder(x_curve_remainder > binFirstPosDef);
y_after1posDef = y_curve_remainder(x_curve_remainder > binFirstPosDef);

% we'll consider the VTE distribution the data after the first positive
% deflection point, indicating some change in the normal distribution to
% the left
yyaxis right;
p2_right = plot(x_after1posDef,y_after1posDef,'b','LineWidth',2);
p2_right.LineStyle = '-';

% use peaks to find local maxima
idxOfy_maxima = findpeaks(y_after1posDef');
xOFy_maxima   = x_after1posDef(idxOfy_maxima.loc);

% extract the second local maxima to be well within the distribution of
% VTEs to avoid false positives - false positives are worse than false
% negatives. The second local maxima defines our VTE threshold.
threshold = xOFy_maxima(2); % this corresponds to the z-score

% threshold will be the bin that corresponds to the first positive
% deflection in the data. this was chosen because it should signify some
% change in the distribution. I used the normal curve to elucidate this
% deflection to detect the general trend.
% plot a line
yyaxis left;
ylimits = ylim;
l1 = line([threshold threshold],[ylimits(1) ylimits(2)]);
l1.Color = 'b';
l1.LineStyle = '--';
l1.LineWidth = 1;
text([threshold+0.1],[ylimits(2)/2],['VTE threshold, the 2nd local maxima' ...
     newline 'in the VTE distribution (blue), is ',num2str(threshold)])
% set color of axes
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'b';
% remove right axis - not necessary
ax.YAxis(2).Visible = 'off';

%% second definition
% define based on timespent distribution and vte behavior
for rati = 1:length(rat)
    
    % col 1 is baseline, col 2 is infusion
    tsPos_bl_saline{rati} = tsPos.(rat{rati}).Saline.Baseline;
    tsPos_sa_saline{rati} = tsPos.(rat{rati}).Saline.Saline;
    
    % baseline
    tsPos_bl_baseline1{rati} = tsPos.(rat{rati}).Baseline.Baseline1;
    tsPos_bl_baseline2{rati} = tsPos.(rat{rati}).Baseline.Baseline2;
  
    % muscimol
    tsPos_mu_baseline{rati} = tsPos.(rat{rati}).Muscimol.Baseline;
    tsPos_mu_muscimol{rati} = tsPos.(rat{rati}).Muscimol.Muscimol;
    
    % concatenate data
    tsPos_data{rati} = horzcat(tsPos_bl_saline{rati},tsPos_sa_saline{rati},tsPos_bl_baseline1{rati},...
        tsPos_bl_baseline2{rati},tsPos_mu_baseline{rati},tsPos_mu_muscimol{rati});
    
end
 
% cat across all observations and create a distribution of timespents
tsPos_data = horzcat(tsPos_data{:});
for i = 1:length(tsPos_data)
    timeSpent_array(i) = (tsPos_data{i}(end)-tsPos_data{i}(1))/1e6;
end

% consider the time if its 1 std above the mean
percentile = 75; % qualitatively seems to match up for the most part
%std_aboveTS = 1;
fig_timeSpent = figure('color','w');
h1 = histogram(timeSpent_array); hold on;
h1.FaceColor = [0 0.5 0.5];
ylimits = ylim;
box off
ylabel('Number of Trials')
xlabel('Timespent at CP (seconds)')
h1.BinWidth = 1.5;
ts_percentile = prctile(timeSpent_array,percentile);
%ts_std = zscore(timeSpent_array);
%ts_1std = timeSpent_array(dsearchn(ts_std',1));
axis tight
ylimits = ylim;
l_ts = line([ts_percentile ts_percentile],[ylimits(1) ylimits(2)]);
l_ts.LineStyle = '--';
l_ts.Color = 'k';
l_ts.LineWidth = 1.5;
text([ts_percentile+1],[ylimits(2)/2],['Time-spent at ',num2str(percentile),'th',' percentile = ',num2str(ts_percentile)])

% second threshold
threshold2 = ts_percentile;

%% plot examples
% after looking through rat1422 with timespent and angular velocity, I feel 
% like a score of 1 safely gets VTE events. Is there a way to draw this
% from the distribution? I need to look at more rats. Remember when
% interpreting velocity colors, if you see a solid color, it just means
% there was no change in velocity, not that they were going slow/fast. What
% would this metrics units be? rad/sec?

%threshold = 0.5;
% next, lets plot some examples
rat_get = 'Rick';    % rat
day_get = 'Baseline'; % day (baseline, saline, muscimol day)
con_get = 'Baseline1'; % condition (saline, baseline, or muscimol infusion)

% get session position information
session_x = xPosOG.(rat_get).(day_get).(con_get);
session_y = yPosOG.(rat_get).(day_get).(con_get);
session_ts = tsPosOG.(rat_get).(day_get).(con_get);

% plot location specific data
loc_x = xPos.(rat_get).(day_get).(con_get);
loc_y = yPos.(rat_get).(day_get).(con_get);
loc_ts = tsPos.(rat_get).(day_get).(con_get);
%angVel = dphi.(rat_get).(day_get).(con_get); % not sure if this is actually angular velocity

% plot based off distribution - 0 seems a good spot
for i = 1:length(zIdPhi_bins)-1
    idx2plot = find(session_zIdPhi >= zIdPhi_bins(i) & session_zIdPhi <= zIdPhi_bins(i+1));
    if isempty(idx2plot) == 1
        disp(['No events between zIdPhi of ',num2str(zIdPhi_bins(i)),' and ',num2str(zIdPhi_bins(i+1))]);
       continue
    else
        for ii = 1:numel(idx2plot)
            figure('color','w')
            p1 = plot(session_x,session_y,'Color',[.8 .8 .8]); box off;
            ylim([-100 500]);
            hold on;             
            %plot(loc_x{idx2plot(ii)},loc_y{idx2plot(ii)},'b','LineWidth',1.4)
            
            % plot position with color heat indicating angular velocity
            z = zeros(size(loc_x{idx2plot(ii)}));
            %col = angVel{idx2plot(ii)}';
            [~,head_velocity] = instant_speed2(loc_x{idx2plot(ii)},loc_y{idx2plot(ii)},loc_ts{idx2plot(ii)},'y'); % 'y' to convert to seconds
            head_velocity = normalize(head_velocity,'range');
            surface([loc_x{idx2plot(ii)};loc_x{idx2plot(ii)}],[loc_y{idx2plot(ii)};loc_y{idx2plot(ii)}],[z;z],[head_velocity;head_velocity],...
                        'facecol','no',...
                        'edgecol','interp',...
                        'linew',2);               
            title(['Bins: ',num2str(zIdPhi_bins(i)),':',num2str(zIdPhi_bins(i+1)),' | ','zIdPhi = ',num2str(session_zIdPhi(idx2plot(ii)))])
            
            % orient axis
            xlim([400 700]);
            ylim([120 330]);
            
            % plot time spent
            timeSpent_run = (loc_ts{idx2plot(ii)}(end)-loc_ts{idx2plot(ii)}(1))/1e6;
            xlimits = xlim;
            ylimits = ylim;
            text([xlimits(2)/1.5],[ylimits(2)/1.2],['TimeSpent at CP = ',num2str(timeSpent_run),' sec.'])
                        
            pause; 
            close;
        end
    end
end

%% get data into matrix

% define a threshold
%threshold = 1; % zscore
VTE=[]; Non=[];
for rati = 1:length(rat)
    
    VTE(rati,1) = numel(find(zIdPhi.(rat{rati}).Baseline.Baseline1 > threshold & timeSpent.(rat{rati}).Baseline.Baseline1 > threshold2));
    VTE(rati,2) = numel(find(zIdPhi.(rat{rati}).Baseline.Baseline2 > threshold & timeSpent.(rat{rati}).Baseline.Baseline2 > threshold2));    
    VTE(rati,3) = numel(find(zIdPhi.(rat{rati}).Saline.Baseline > threshold & timeSpent.(rat{rati}).Saline.Baseline > threshold2));
    VTE(rati,4) = numel(find(zIdPhi.(rat{rati}).Saline.Saline > threshold & timeSpent.(rat{rati}).Saline.Saline > threshold2));
    VTE(rati,5) = numel(find(zIdPhi.(rat{rati}).Muscimol.Baseline > threshold & timeSpent.(rat{rati}).Muscimol.Baseline > threshold2));
    VTE(rati,6) = numel(find(zIdPhi.(rat{rati}).Muscimol.Muscimol > threshold & timeSpent.(rat{rati}).Muscimol.Muscimol > threshold2));

    Non(rati,1) = numel(find(zIdPhi.(rat{rati}).Baseline.Baseline1 < threshold & timeSpent.(rat{rati}).Baseline.Baseline1 < threshold2));
    Non(rati,2) = numel(find(zIdPhi.(rat{rati}).Baseline.Baseline2 < threshold & timeSpent.(rat{rati}).Baseline.Baseline2 < threshold2));    
    Non(rati,3) = numel(find(zIdPhi.(rat{rati}).Saline.Baseline < threshold & timeSpent.(rat{rati}).Saline.Baseline < threshold2));
    Non(rati,4) = numel(find(zIdPhi.(rat{rati}).Saline.Saline < threshold & timeSpent.(rat{rati}).Saline.Saline < threshold2));
    Non(rati,5) = numel(find(zIdPhi.(rat{rati}).Muscimol.Baseline < threshold & timeSpent.(rat{rati}).Muscimol.Baseline < threshold2));
    Non(rati,6) = numel(find(zIdPhi.(rat{rati}).Muscimol.Muscimol < threshold & timeSpent.(rat{rati}).Muscimol.Muscimol < threshold2));   
    
    % get a percentage
    numTrials = numel(zIdPhi.(rat{rati}).Baseline.Baseline1);
    propVTE(rati,1) = (numel(find(zIdPhi.(rat{rati}).Baseline.Baseline1 > threshold & timeSpent.(rat{rati}).Baseline.Baseline1 > threshold2)))/numTrials;
    propVTE(rati,2) = (numel(find(zIdPhi.(rat{rati}).Baseline.Baseline2 > threshold & timeSpent.(rat{rati}).Baseline.Baseline2 > threshold2)))/numTrials;    
    propVTE(rati,3) = (numel(find(zIdPhi.(rat{rati}).Saline.Baseline > threshold & timeSpent.(rat{rati}).Saline.Baseline > threshold2)))/numTrials;
    propVTE(rati,4) = (numel(find(zIdPhi.(rat{rati}).Saline.Saline > threshold & timeSpent.(rat{rati}).Saline.Saline > threshold2)))/numTrials;
    propVTE(rati,5) = (numel(find(zIdPhi.(rat{rati}).Muscimol.Baseline > threshold & timeSpent.(rat{rati}).Muscimol.Baseline > threshold2)))/numTrials;
    propVTE(rati,6) = (numel(find(zIdPhi.(rat{rati}).Muscimol.Muscimol > threshold & timeSpent.(rat{rati}).Muscimol.Muscimol > threshold2)))/numTrials;    
end

% notice that we're not seeing an effect on the single rat scale - probably
% because there are so few trials and so few rats, therefore lets look
% across sessions
figure()
colorLine.color1 = 'r'; colorLine.color2 = 'k';
jitterIdx = 1:6;
colorIdx{1} = 'r'; colorIdx{2} = 'b'; colorIdx{3} = 'm'; colorIdx{4} = 'y'; colorIdx{5} = 'k'; colorIdx{6} = 'g';
BarPlotsJitteredData(propVTE,1,0,1,1,[],colorLine,jitterIdx,colorIdx)
set(gca,'FontSize',12)
ylabel('Proportion of Deliberative-like events');
ax = gca;
ax.XTick = [1:6];
ax.XTickLabel = [{'Baseline 1'},{'Baseline 2'},{'Baseline'},{'Saline'},{'Baseline'},{'Muscimol'}];
ax.XTickLabelRotation = 45;

% like henry, do a change score
prop_baselineDay = (propVTE(:,2)-propVTE(:,1));%./(propVTE(:,2)+propVTE(:,1));
prop_salineDay   = (propVTE(:,4)-propVTE(:,3));%./(propVTE(:,4)+propVTE(:,3));
prop_muscimolDay = (propVTE(:,6)-propVTE(:,5));%./(propVTE(:,6)+propVTE(:,5));
diffScores = horzcat(prop_baselineDay,prop_salineDay,prop_muscimolDay);

figure()
jitterIdx = 1:6;
colorIdx{1} = 'r'; colorIdx{2} = 'b'; colorIdx{3} = 'm'; colorIdx{4} = 'y'; colorIdx{5} = 'k'; colorIdx{6} = 'g';
fig = BarPlotsJitteredData(diffScores,1,0,1,0,[],[],jitterIdx,colorIdx)
set(gca,'FontSize',12)
ylabel('Deliberative Difference (testing - baseline)');
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = [{'Baseline'},{'Saline'},{'Muscimol'}];
ax.XTickLabelRotation = 45;
[h,p]=ttest(diffScores,0)

% below isnt correct yet
%f=get(gca,'Children');
%legend([f(1),f(2),f(3),f(4),f(5),f(6),f(7)],rat)

