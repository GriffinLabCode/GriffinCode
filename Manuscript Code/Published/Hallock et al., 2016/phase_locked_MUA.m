%% phase_locked_MUA

% This script plots multi-unit activity with an ongoing oscillation as a
% way of visualizing network phase-locking

%%

clear all, clc, close all

netDrive = 'X:\';
expFolder = '01.Experiments\RERh Inactivation Recording\14-22\Baseline\';
session = 'Baseline 1\';

trial = 5;  %   Manually select trial to look at
bin = 0.2;  %   Manually select bin size for raster plot (seconds)
total_time = 6;  %   Manually select how much time to include in plot (seconds)
where = 10;      %   Manually select how much time prior to the end of the delay period to search for spikes (seconds)  
phase_bandpass = [5 11];    %   Manually select frequencies for phase
srate = 2034;    %   Manually define sampling rate (Hz)

datafolder = strcat(netDrive,expFolder,session);
load(strcat(datafolder, 'Int.mat'));
load(strcat(datafolder, 'CSC8.mat'));   %   Manually select CSC for plotting
cd(datafolder)
clusters = dir('TT*.txt');

clear rat session expFolder

cd(strcat(netDrive, '03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\'));

% Define parameters for temporal window
intsec = Int/1e6;
TrialStart = (intsec(trial,1)-(where+total_time));
TrialEnd = (intsec(trial,1)-where);
DelayCenter = (intsec(trial,1)-((where+(total_time/2))));

edges = (-(total_time/2):bin:total_time/2);

Samples = Samples(:)';

Timestamps = linspace(Timestamps(1,1),Timestamps(1,end),length(Samples));
Timestamps_sec = Timestamps/1e6;

% Bandpass filter the CSC samples
samples_raw = Samples(Timestamps_sec>TrialStart & Timestamps_sec<TrialEnd);
[filtered_signal] = skaggs_filter_var(samples_raw, phase_bandpass(:,1), phase_bandpass(:,2), srate);

subplot(311)
plot(samples_raw)
axis tight
set(gca,'XTick',[])
ylabel('Raw Amplitude')

subplot(312)
plot(filtered_signal)
axis tight
set(gca,'XTick',[])
ylabel('Filtered Amplitude')

subplot(313)
for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    cluster = clusters(ci).name(1:end-4);
    spksec=spikeTimes/1e6;
    s=spksec(find(spksec>TrialStart & spksec<TrialEnd));
    ev=DelayCenter;
    s0=s-ev;
    n(:,ci) = histc(s0,edges);
    if isempty(s)==0,subplot(313),plot(s0,ci,'ks','MarkerFace','black','MarkerSize',2), end
    axis([-(total_time/2) total_time/2 0 length(clusters)+1])
    hold on
end
ylabel('Single Unit')
xlabel('Time (Seconds)')



