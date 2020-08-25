function [csc,vid,maxpwr] = prelim_data_check(dir,channels)
% Runs a preliminary check on all the data. Takes data directory (dir) as input
% and the channels you want to use and spits out a figure showing raw LFPs, 
% PSDs and tracking info.
% 
% --------
% 
% Example inputs:
%
% prelim_data_check('C:\Data\M06-2015-07-25_LinearTrack',[17:32])
% This would load channels 17-32 from the data in the
% M06-2015-07-25_LinearTrack folder
% 
% Or if you wanted to exclude channel 18, 22, and 30..:
% prelim_data_check('C:\Data\M06-2015-07-25_LinearTrack',[17 19:21 23:29 31 32])
% and so on
% 
%
% ----------------
% Please unzip video before running and load the nsb/fieldtrip/mclust
% toolboxes
%
% --------------
% 
% CW July 2015

%% Load LFP
cd(dir);
cfg=[];
csc = cell(32,1);

no_chs=numel(channels); % Get number of channels


for ch=1:no_chs
    cfg.fc = {['CSC' num2str(channels(ch)) '.ncs']};
    csc{ch} = LoadCSC(cfg);
end

%% Load video - I just changed this to load into a structure (CW)
if ~exist('VT1.nvt','file')
    fprintf('No video file found, try unzipping...');
else
    [vid.Timestamps, vid.X, vid.Y, vid.Angles, vid.Targets, vid.Points, vid.Header] = Nlx2MatVT('VT1.nvt', [1 1 1 1 1 1], 1, 1, [] );

%Plot video
    vidlfpfig=figure('units','normalized','outerposition',[0 0 1 1]);
    
    keep_idx=(vid.X~=0&vid.Y~=0); %keep only points where position not (0,0)
    %set(fh,'Color',[0 0 0]);
    subplot(1,2,1)
    plot(vid.X(keep_idx),vid.Y(keep_idx),'.','Color','k','MarkerSize',1); axis off;
    title('Video tracking')

end

%% Plot LFP and show only a 2s window from the middle of the recording 

% Goes into same fig as video

subplot(1,2,2)
start_idx=length(csc{1}.tvec)/2-2000; % get 1s before halfway through recording...
end_idx=length(csc{1}.tvec)/2+2000; % get 1s after...
hold on;
legendtext=cell(no_chs,1);

% Plot raw LFPs for all channels
for ch=1:no_chs
    plot(csc{ch}.tvec(start_idx-2000:end_idx+2000),csc{ch}.data(start_idx-2000:end_idx+2000)+ch*0.001);
    legendtext{ch}=['Ch ' num2str(channels(ch))];
end
legend(legendtext);
xlim([csc{1}.tvec(start_idx) csc{1}.tvec(end_idx)]) % set the xlim to the cut out bit
set(gca,'Ytick',[])
title('Raw LFP')

suptitle(strrep(csc{1}.cfg.SessionID,'_','-'))

%% Create PSDs as separate subplots
psdfig=figure('units','normalized','outerposition',[0 0 1 1]);
Fs=csc{1}.cfg.hdr{1,1}.SamplingFrequency; % this should be the same for everything
wSize = 8092/2; % define window size
sp_size=ceil(sqrt(no_chs)); % set the subplot size to be just big enough to hold all the chs
hold on;
for ch=1:no_chs
    subplot(sp_size,sp_size,ch);
    [Pxx,F] = pwelch(csc{ch}.data,hamming(wSize),0,wSize,Fs); % use welch method to get power spectrum thing
    plot(F,10*log10(Pxx));
    ax(ch)=gca;
    title(['Ch ' num2str(channels(ch))])
    xlim([0 150]);
    
    maxpwr.channel{ch}=['Ch ' num2str(channels(ch))];
    [maxpwr.power(ch),idx]=max(Pxx(F>7&F<10));
    F=F(F>7&F<10);
    maxpwr.freq(ch)=F(idx);
end

linkaxes(ax,'x');
suptitle([strrep(csc{1}.cfg.SessionID,'_','-') ' PSD'])
xlabel('Frequency (Hz)'); ylabel('Power (dB)');

%% Suggest a channel...
[maxpwr_ch,idx]=max(maxpwr.power);
disp(['the max theta power is ' num2str(maxpwr_ch) ' on ' maxpwr.channel{idx}])
end

