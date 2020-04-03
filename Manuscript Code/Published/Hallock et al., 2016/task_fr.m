function [fr_DA, fr_CD] = task_fr(spk, Int1, Int2, plot)
%%

%   This function calculates firing rates across three maze locations
%   (start-box, stem, and choice-point) between tasks for dual-task
%   sessions. This function is useful for discerning whether a single unit
%   fires differentially between tasks

%   Inputs:
%       spk:            n spikes x 1 array of spike timestamp values
%       Int1:           n trials x 8 matrix of maze timestamp values for DA
%       Int2:           n trials x 8 matrix of maze timestamp values for CD
%       plot:           0 if plot, 1 if no plot

%   Outputs:
%       fr_DA:          n trials x 3 (maze position) matrix of firing rate
%                       values for DA epoch
%       fr_CD:          n trials x 3 (maze position) matrix of firing rate
%                       values for CD epoch

%%

numtrials1 = size(Int1,1);
numtrials2 = size(Int2,1);

% Find firing rates for DA start-box occupancy (this function assumes that
% Int1 = DA)
for i = 2:numtrials1
    spk_temp = find(spk>Int1(i-1,8) & spk<Int1(i,1));
    numspikes = length(spk_temp);
    time = Int1(i,1) - Int1(i-1,8);
    time = time/1e6;
    fr_DA(i-1,1) = numspikes/time;
end

% Find firing rates for DA stem traversals
for i = 2:numtrials1
    spk_temp = find(spk>Int1(i,1) & spk<Int1(i,5));
    numspikes = length(spk_temp);
    time = Int1(i,5) - Int1(i,1);
    time = time/1e6;
    fr_DA(i-1,2) = numspikes/time;
end

% Find firing rates for DA choice-point traversals
for i = 2:numtrials1
    spk_temp = find(spk>Int1(i,5) & spk<Int1(i,6));
    numspikes = length(spk_temp);
    time = Int1(i,6) - Int1(i,5);
    time = time/1e6;
    fr_DA(i-1,3) = numspikes/time;
end

% Find firing rates for CD start-box occupancy (this function assumes that
% Int2 = CD)
for i = 2:numtrials2
    spk_temp = find(spk>Int2(i-1,8) & spk<Int2(i,1));
    numspikes = length(spk_temp);
    time = Int2(i,1) - Int2(i-1,8);
    time = time/1e6;
    fr_CD(i-1,1) = numspikes/time;
end

% Find firing rates for CD stem traversals
for i = 2:numtrials2
    spk_temp = find(spk>Int2(i,1) & spk<Int2(i,5));
    numspikes = length(spk_temp);
    time = Int2(i,5) - Int2(i,1);
    time = time/1e6;
    fr_CD(i-1,2) = numspikes/time;
end

% Find firing rates for CD choice-point traversals
for i = 2:numtrials2
    spk_temp = find(spk>Int2(i,5) & spk<Int2(i,6));
    numspikes = length(spk_temp);
    time = Int2(i,6) - Int2(i,5);
    time = time/1e6;
    fr_CD(i-1,3) = numspikes/time;
end

% Calculate mean firing rates and standard errors
mean_DA = mean(fr_DA,1);
mean_CD = mean(fr_CD,1);
std_DA = std(fr_DA,0,1);
std_CD = std(fr_CD,0,1);
sem_DA = std_DA/sqrt(numtrials1-1);
sem_CD = std_CD/sqrt(numtrials2-1);

if plot == 0
errorbar(mean_DA,sem_DA)
ax.XTickLabel = {[],'Start-Box',[],'Stem',[],'Choice-Point',[]};
set(gca,'XTickLabel',ax.XTickLabel);
hold on
errorbar(mean_CD,sem_CD,'r')
legend('DA', 'CD')
ylabel('Firing Rate (Hz)')
xlabel('Maze Position')
box off
set(gca,'TickDir','out')
end




end

