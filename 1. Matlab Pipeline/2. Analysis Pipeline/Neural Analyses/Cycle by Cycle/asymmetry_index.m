%% get_asymmetryIndex
%
% -- INPUTS -- %
% datafolder: string datafolder
% lfp: vector of lfp 
% lfp_srate: sampling rate of lfp
% phase_bandpass: 

function [asymmetryIDX] = asymmetry_index(lfp,timesLFP,lfp_srate,phase_bandpass)

% filter 4-12 hz
[signal_filtered] = skaggs_filter_var(lfp,phase_bandpass(:,1),phase_bandpass(:,2),lfp_srate);

% phase freq detect - get phase
Phase = phase_freq_detect(signal_filtered, timesLFP, 4, 12, lfp_srate);

% using phase, use find function to find closest values to 0, to 180 (peak), and
% to 360 (trough)
trough = find(Phase == 0); %should i add a line including 360?
peak   = find(Phase == 180);

%% FOR DESCENDING [TROUGH - PEAK]

% if peak comes first, and peak comes last
peak_temp = []; trough_temp = [];
if peak(1) < trough(1) && peak(end) > trough(end)
    
    % delete the last peak because peak was the last observed
    peak_temp = peak;  % define
    peak_temp(end)=[]; % delete
    
    % define trough-temp
    trough_temp = trough;
    
% if peak comes first, and peak comes second-last
elseif peak(1) < trough(1) && peak(end) < trough(end)
    
    % no deletions required
 
    % define peak_temp
    peak_temp   = peak;
    trough_temp = trough;

% if peak comes second, and peak comes last
elseif peak(1) > trough(1) && peak(end) > trough(end)
    
    % delete the first trough 
    trough_temp = trough;
    trough_temp(1) = [];
    % delete the last peak
    peak_temp = peak;
    peak_temp(end) = []; 
    
% if peak comes second, and peak comes second-last
elseif peak(1) > trough(1) && peak(end) < trough(end)
    
    % delete the first trough
    trough_temp = trough;  % define
    trough_temp(1)=[]; % delete
    
end 

% correct doublets, triplets, quadruplets
peak_out1 = []; trough_out1 = []; peak_out2 = []; trough_out2 = []; 
peak_final = []; trough_final = [];
[peak_out1,trough_out1] = correct_doublets(peak_temp,trough_temp,'descending');
[peak_out2,trough_out2] = correct_doublets(peak_out1,trough_out1,'descending');
[peak_final,trough_final] = correct_doublets(peak_out2,trough_out2,'descending');

% calculate descending - no need for deletions
descending = trough_final-peak_final;   

%% FOR ASCENDING [PEAK - TROUGH]

peak_temp = []; trough_temp = [];
% if peak comes first, and peak comes last
if peak(1) < trough(1) && peak(end) > trough(end) 
    
    % delete first peak 
    peak_temp = peak;
    peak_temp(1) = [];
    
    % define trough
    trough_temp = trough;

% if peak comes first, and peak comes second-last
elseif peak(1) < trough(1) && peak(end) < trough(end)
    
    % delete first peak
        peak_temp = peak;
        peak_temp(1) = [];
    % delete last trough
        trough_temp = trough;
        trough_temp(end) = [];
        
% if peak comes second, and peak comes last
elseif peak(1) > trough(1) && peak(end) > trough(end)
    
    % define peak and trough variables
    peak_temp = peak;
    trough_temp = trough;
    
% if peak comes second, and peak comes second-last
elseif peak(1) > trough(1) && peak(end) < trough(end) 
    
    % delete last trough
    trough_temp = trough;
    trough_temp(end) = [];

end

% correct doublets, triplets, quadruplets
peak_out1 = []; trough_out1 = []; peak_out2 = []; trough_out2 = []; 
peak_final = []; trough_final = [];
[peak_out1,trough_out1] = correct_doublets(peak_temp,trough_temp,'ascending');
[peak_out2,trough_out2] = correct_doublets(peak_out1,trough_out1,'ascending');
[peak_final,trough_final] = correct_doublets(peak_out2,trough_out2,'ascending');

% calculate descending - no need for deletions
ascending = peak_final-trough_final;   

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

asymmetryIDX = log((ascending)) - log((descending));

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
