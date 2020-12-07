%% cycle_by_cycle
%
% this code is designed to provide outputs that can be used to assess cycle
% by cycle phenomenon in the theta range
%
% -- INPUTS -- %
% datafolder: string datafolder
% lfp: vector of lfp 
% lfp_srate: sampling rate of lfp
%
% -- OUTPUTS -- %
% asymmetry_logIdx: Redish style theta asymmetry log(ascending) -log(descending)
% asymmetry_idx: simpler theta asymmetry method (descending./(ascending+descending)
%                   where values less than .5 have longer descending
% cycle_period: in ms, the timing between two peaks of the theta cycle
% cycle_amp: in voltage (not sure if uv), is the average amplitude between
%               two cycles
% 

function [asymmetry_logIdx,asymmetry_idx,cycle_period,cycle_amp] = cycle_by_cycle(lfp,timesLFP,lfp_srate)

% filter 1-80Hz like Amemiya et al 2018
[signal_filtered] = skaggs_filter_var(lfp,1,80,lfp_srate);

%{
figure('color','w')
subplot 211
plot(timesLFP,lfp,'b');
legend('raw lfp')
subplot 212
plot(timesLFP,signal_filtered,'k');
legend('1-80hz filt lfp')
%}

% phase freq detect - get phase bw 6-12 Amemiya et al., 2018
Phase = phase_freq_detect(signal_filtered, timesLFP, 6, 12, lfp_srate);

%{
figure('color','w');
subplot 211;
    plot(timesLFP,signal_filtered,'k');
    legend('1-80hz filt lfp')
    box off
subplot 212;
    plot(timesLFP,Phase,'k');
    legend('6-12Hz phase')
    box off
%}

% using phase, use find function to find closest values to 0, to 180 (peak), and
% to 360 (trough)
trough = find(Phase == 0); %should i add a line including 360?
peak   = find(Phase == 180);

%{
figure('color','w');
subplot 211; hold on;
    plot(timesLFP,signal_filtered,'k');
    legend('1-80hz filt lfp')
    box off
    plot(timesLFP(peak),signal_filtered(peak),'.r','Marker','o');
    plot(timesLFP(trough),signal_filtered(trough),'.b','Marker','o');
%}

% within each theta cycle (time betweek peaks - Amemiya et al., 2018), get
% ascending and descending
ascending = []; descending = [];
for i = 1:length(peak)-1
    
    % get trough between peaks (within a theta cycle)
    trough_idx = find(trough > peak(i) & trough < peak(i+1));
    
    % if no trough exists between peaks, or if there are multiple troughs
    % between a peak, skip the theta cycle (its not really a theta cycle at
    % this point, its multiple. Data got lost somewhere and so it shouldn't
    % be analyzed).
    if isempty(trough_idx) == 1 | length(trough_idx) > 1
        % nan arrays if no trough exists between peak
        ascending(i)  = NaN;
        descending(i) = NaN;
        continue 
    else    
        % -- theta asymmetry stuff -- %
        
        % get temporary trough variable
        trough_temp = trough(trough_idx);

        % ascending is peak - trough
        ascending(i) = peak(i+1) - trough_temp;

        % descending is trough - peak
        descending(i) = trough_temp - peak(i);
            
        % -- cycle amplitude -- %
        
        % like cole and voytek 2020
        cycle_amp(i) = (lfp(peak(i)) + lfp(peak(i+1)))/2;
        
    end
end

% sanity checks - there should be no negative values
if find(descending < 0) | find(ascending < 0)
    error('descending not correctly determined')
end

%% calculate asymmetry index log((ascending)) - log((descending))

% sanity check - check that ascend and descend variables are the same size.
% If they're not, create an error.
if length(ascending) ~= length(descending)
    error('Error in sizing')
end

% redish method
asymmetry_logIdx = log((ascending)) - log((descending));

% Cole and voytek 2018 https://www.biorxiv.org/content/10.1101/452987v1.full.pdf
asymmetry_idx = ascending./(ascending+descending);

% get theta cyle period (in ms)
% https://www.biorxiv.org/content/10.1101/452987v1.full.pdf
cycle_period = ascending+descending./lfp_srate;

%{
figure(); plot(timesLFP,signal_filtered,'k'); hold on;
timing = linspace(1,length(timesLFP),length(timesLFP));
plot(timesLFP(peak_temp),signal_filtered(peak_temp),'.r','Marker','o');
plot(timesLFP(trough_temp),signal_filtered(trough_temp),'.b','Marker','o');
axis tight
% get doublets
idxplot = peaks_troughs(sort_idx(15:16,1),1);
plot(timesLFP(idxplot),signal_filtered(idxplot),'.m','Marker','o')
%}

end
