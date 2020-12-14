%% get_thetaPhase
%
% This function extracts theta phase by first filtered the data to remove
% super high frequency components (1-80Hz), then using phase interpolation
% between 6-12Hz. This concept was taken from Amemiya et al., 2018 Cell,
% Redish paper.
%
% -- INPUTS -- %
% lfp: vector of lfp
% lfp_times: vector of lfp time stamps
% lfp_srate: sampling rate of lfp
% method; determine which way to extract phase
%
% -- OUTPUTS -- %
% Phase: lfp theta phases vector
% signal_filtered: filtered signal between 1-80Hz
% peak: peaks (180) of theta (6-12Hz)
% trough: troughs (0) of theta (6-12Hz)
%
% written by John Stout

function [Phase, signal_filtered, peak, trough] = get_thetaPhase(lfp,lfp_times,lfp_srate,method)

% filter
signal_filtered = skaggs_filter_var(lfp,4,12,lfp_srate);

% phase freq detect - get phase bw 6-12 Amemiya et al., 2018
if exist('method') == 0
    Phase = phase_freq_detect(signal_filtered, lfp_times, 5, 9, lfp_srate);
elseif method == 1 | contains(method,'interp')
    Phase = phase_freq_detect(signal_filtered, lfp_times, 5, 9, lfp_srate);
elseif method == 0 | contains(method,'hilbert')
    signal_filtered = [];
    signal_filtered = skaggs_filter_var(lfp,5,9,lfp_srate);
    % angle of hilbert transform in degrees
    Phase = rad2deg(angle(hilbert(signal_filtered)));
end

% using phase, use find function to find closest values to 0, to 180 (peak), and
% to 360 (trough)
trough = find(Phase == 0); %should i add a line including 360?
peak   = find(Phase == 180);

%% Proof of concept figures
%{
figure('color','w')
subplot 211
plot(timesLFP,lfp,'b');
legend('raw lfp')
subplot 212
plot(timesLFP,signal_filtered,'k');
legend('1-80hz filt lfp')
%}

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

%{
figure('color','w');
subplot 211; hold on;
    plot(timesLFP,signal_filtered,'k');
    legend('1-80hz filt lfp')
    box off
    plot(timesLFP(peak),signal_filtered(peak),'.r','Marker','o');
    plot(timesLFP(trough),signal_filtered(trough),'.b','Marker','o');
%}