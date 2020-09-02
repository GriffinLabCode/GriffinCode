function [fr_sb, fr_stem, fr_cp, fr_reward, fr_return] = firing_rate_maze(spk, Int, plot)

%   This function calculates trial-averaged firing rates across key maze
%   locations (start-box, stem, choice-point, reward-arm, and return-arm)

% Inputs:
%   spk:    n x 1 array of spike timestamps
%   Int:    n trials x 8 matrix of maze timestamp values
%   plot:   0 if plot, 1 if no plot

% Outputs:  Trial-averaged firing rate values (Hz) at each maze section

%%

ntrials = size(Int,1);

% Convert timestamp values into seconds
spksec = spk/1e6;
intsec = Int/1e6;

% Trial-averaged firing rate for start-box occupancy
for i = 2:ntrials
    spk_new = find(spksec>intsec(i-1,8) & spksec<intsec(i,1));
    time_spent = (intsec(i,1)) - (intsec(i-1,8));
    nspikes = length(spk_new);
    fr_sb(i-1) = nspikes/time_spent;
end

std_sb = std(fr_sb,0,2);
sem_sb = std_sb/sqrt(ntrials-1);
fr_sb = mean(fr_sb);

% Trial-averaged firing rate for stem traversals
for i = 1:ntrials
    spk_new = find(spksec>intsec(i,1) & spksec<intsec(i,5));
    time_spent = (intsec(i,5)) - (intsec(i,1));
    nspikes = length(spk_new);
    fr_stem(i) = nspikes/time_spent;
end

std_stem = std(fr_stem,0,2);
sem_stem = std_stem/sqrt(ntrials);
fr_stem = mean(fr_stem);

% Trial-averaged firing rate for choice-point traversals
for i = 1:ntrials
    spk_new = find(spksec>intsec(i,5) & spksec<intsec(i,6));
    time_spent = (intsec(i,6)) - (intsec(i,5));
    nspikes = length(spk_new);
    fr_cp(i) = nspikes/time_spent;
end

std_cp = std(fr_cp,0,2);
sem_cp = std_cp/sqrt(ntrials);
fr_cp = mean(fr_cp);

% Trial-averaged firing rate for reward arm traversals
for i = 1:ntrials
    spk_new = find(spksec>intsec(i,6) & spksec<intsec(i,2));
    time_spent = (intsec(i,2)) - (intsec(i,6));
    nspikes = length(spk_new);
    fr_reward(i) = nspikes/time_spent;
end

std_reward = std(fr_reward,0,2);
sem_reward = std_reward/sqrt(ntrials);
fr_reward = mean(fr_reward);

% Trial-averaged firing rate for return arm traversals
for i = 1:ntrials
    spk_new = find(spksec>intsec(i,7) & spksec<intsec(i,8));
    time_spent = (intsec(i,8)) - (intsec(i,7));
    nspikes = length(spk_new);
    fr_return(i) = nspikes/time_spent;
end

std_return = std(fr_return,0,2);
sem_return = std_return/sqrt(ntrials);
fr_return = mean(fr_return);

fr_all(:,1) = fr_sb;
fr_all(:,2) = fr_stem;
fr_all(:,3) = fr_cp;
fr_all(:,4) = fr_reward;
fr_all(:,5) = fr_return;

sem_all(:,1) = sem_sb;
sem_all(:,2) = sem_stem;
sem_all(:,3) = sem_cp;
sem_all(:,4) = sem_reward;
sem_all(:,5) = sem_return;

if plot == 0
figure()
errorbar(fr_all,sem_all)
ax.XTickLabel = {[],'Start-Box',[],'Stem',[],'Choice-Point',[],'Reward-Arm',[],'Return-Arm',[]};
set(gca,'XTickLabel',ax.XTickLabel);
xlabel('Maze Position')
ylabel('Firing Rate (Hz)')
box off
set(gca,'TickDir','out')
end


end

