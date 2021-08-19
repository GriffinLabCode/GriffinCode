function [nAvg_Smooth, b] = PETH_delay_multiPlot(spk, Int, delay_length, bin)
%%

%This function creates a peri-event time histogram, raster plot, and
%average firing rate plot over time for a single unit recorded during delay
%pedestal occupancy. 

%The function also detects changes in firing rate over time ("ramping"
%activity/"decay" activity) by performing a Poisson regression

%Inputs
%   spk = 1 x nSamples array of spike timestamps
%   Int = nTrials x 8 matrix of timestamps values for maze occupancy
%   delay_length = Length of delay period (seconds)
%   bin = Temporal bin size (seconds)
%   plot = 0 if plot, 1 if no plot

%Outputs
%   p = P value for regression coefficient
%   b = Regression coefficient (R)

% edit to create multicolored plots for different DNMP trajectories

%%

% define ogInt
ogInt = Int;

% sample/choice indices
sampleTrials = 1:2:length(Int); % these are the sample trials
choiceTrials = 2:2:length(Int);

% define total traversals
numTraversals = [];
numTraversals = size(Int,1);

% get sample left/right choice left/right
% for sample left, first, find all lefts, then find all sample,
% then find the intersection between sample and lefts. Same for
% everything else  

% clean out
sampleLeft = []; sampleRight = []; choiceLeft = []; choiceRight = []; 
% sample
sampleLeft  = intersect(find(ogInt(:,3)==1), find(mod(1:numTraversals,2)==1));
sampleRight = intersect(find(ogInt(:,3)==0), find(mod(1:numTraversals,2)==1));
% choice
choiceLeft  = intersect(find(ogInt(:,3)==1), find(mod(1:numTraversals,2)==0)); % 0s are even for the second input to intersect and therefore choice
choiceRight = intersect(find(ogInt(:,3)==0), find(mod(1:numTraversals,2)==0));

% remember, the first sample trial had no ITI epoch. Identify this
% trial and remove the timestamp windows
if isempty(find(sampleLeft == 1)) == 0
    idxRem = [];
    idxRem = find(sampleLeft == 1);
    sampleLeft(idxRem) = [];
elseif isempty(find(sampleRight == 1)) == 0
    idxRem = [];
    idxRem = find(sampleRight == 1);
    sampleRight(idxRem,:) = [];
end

% define colors for each condition
caseColor = [];
caseColor{1} = 'k.'; % delay R
caseColor{2} = 'r.'; % delay L
caseColor{3} = 'b.'; % iti R
caseColor{4} = 'm.'; % iti L

% define the caseInt
caseInt = [];
caseInt{1} = Int(choiceRight,:);
caseInt{2} = Int(choiceLeft,:);
caseInt{3} = Int(sampleRight,:);
caseInt{4} = Int(sampleLeft,:);

% convert spikes to seconds
spksec  = [];
spksec  = spk/1e6;
   
%
figure('color','w');

% create a variable to track which Int section belongs to which trajectory
IntLens    = cellfun(@length,caseInt);
multVar    = [1 2 3 4];
trackerVar = zeros([1 4]);

% probably an elogant for loop way to do this, but whatev
trackerVar = [];
trackerVar(1) = IntLens(1); 
trackerVar(2) = IntLens(1)+IntLens(2);
trackerVar(3) = IntLens(1)+IntLens(2)+IntLens(3);
trackerVar(4) = IntLens(1)+IntLens(2)+IntLens(3)+IntLens(4);

% create one int variable containing all directions
Int = [];
Int = vertcat(caseInt{:});

nTrials     = length(Int(:,1));
TrialStart  = (Int(1:nTrials,1)-delay_length*1e6)/1e6;
TrialEnd    = Int(1:nTrials,1)/1e6;
DelayCenter = (Int(1:nTrials,1)-(delay_length/2)*1e6)/1e6;
intsec      = Int/1e6;
ntrials     = size(Int,1);

edges = (-(delay_length/2):bin:delay_length/2);

for i = 1:nTrials
    s=spksec(find(spksec>TrialStart(i) & spksec<TrialEnd(i)));
    ev=DelayCenter(i);
    s0=s-ev; 
    n(:,i) = histc(s0,edges);

    if i < trackerVar(1)
        color = caseColor{1};
    elseif i > trackerVar(1) && i < trackerVar(2)
        color = caseColor{2};
    elseif i > trackerVar(2) && i < trackerVar(3)
        color = caseColor{3};
    elseif i > trackerVar(3) && i < trackerVar(4) 
        color = caseColor{4};
    end
    
    if isempty(s)==0,subplot(211),plot(s0,i,color), end
    axis([-(delay_length/2) delay_length/2 0 nTrials])
    hold on
end
set(gca,'XTick',[]);
ylabel('Trial')

%{
n_allTrials = sum(n,2)*bin; 
max_n_allTrials = max(n_allTrials);
subplot(312), bar(edges,n_allTrials), axis([-(delay_length/2) delay_length/2 0 max_n_allTrials+1])

set(gca,'XTick',[]);
ylabel('Spike Count')
%}

% separate trials from n - again prob a for loop for elegance
n_data = [];
n_data{1} = n(:,1:trackerVar(1));
n_data{2} = n(:,trackerVar(1)+1:trackerVar(2));
n_data{3} = n(:,trackerVar(2)+1:trackerVar(3));
n_data{4} = n(:,trackerVar(3)+1:trackerVar(4));

% new colors
caseColor = [];
caseColor{1} = 'k'; % delay R
caseColor{2} = 'r'; % delay L
caseColor{3} = 'b'; % iti R
caseColor{4} = 'm'; % iti L

% Get firing rate by dividing number of spikes in each bin by bin size
subplot(212); hold on;
for i = 1:length(n_data)
    
    FR = n_data{i}./bin;
    nAvg{i} = mean(FR,2);
    Std = std(FR,0,2); 
    nTrialsCustom = size(n_data{i},2);
    SEM = Std/sqrt(nTrialsCustom-1); 

    % Create Gaussian filter for rate plot smoothing
    windowWidth = int16(5);
    halfWidth = windowWidth/2;
    gaussFilter = gausswin(5);
    gaussFilter = gaussFilter/sum(gaussFilter);

    nAvg_Smooth{i} = conv(nAvg{i},gaussFilter);
    SEM_Smooth = conv(SEM,gaussFilter);

    % Define size of smoothed firing rates to be plotted in accordance with
    % Gaussian blurring
    smooth_length = size(nAvg_Smooth{i}(halfWidth:end-halfWidth),1);
    raw_length = size(nAvg{i},1);
    difference = raw_length-smooth_length;
    max_data = max(nAvg_Smooth{i}) + max(SEM_Smooth);
    max_graph = max_data + 0.05;

    varargout(i)=shadedErrorBar(linspace(-(delay_length),0,size(edges,2)),nAvg_Smooth{i}(halfWidth:end-halfWidth+difference)',SEM_Smooth(halfWidth:end-halfWidth+difference),caseColor{i},1);
    axis tight
    ylabel('Firing Rate (Hz)')
    xlabel('Time from stem entry (Seconds)')
    ylim ([0 max_graph]);
    
end

legend([varargout(1).mainLine varargout(2).mainLine varargout(3).mainLine varargout(4).mainLine],...
    'delayR', 'delayL', 'itiR', 'itiL')

%{
% Perform Poisson regression between time and firing rate
for i = 1:length(nAvg)
    %nAvg{i}(end,:) = [];
    x = linspace(1,delay_length,delay_length/bin);
    x = x';
    [b, dev, stats] = glmfit(x,nAvg{i},'poisson');
    p{i} = stats.p(2,1);
    b{i} = stats.beta(2,1);
end
%}
end

