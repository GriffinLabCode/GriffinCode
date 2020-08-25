function [csc_restricted,all_ivs] = restrict_to_theta(dir,channel)
% Restrict the LFP for analysis to periods where there is both high theta
% and high running speed
%
% Remember to  select channel for analysis using PSDs
%
% Takes the data directory (dir) and the channel you want to analyse
% (channel) as input
%
% Outputs csc_restricted and the ivs used for restricting (all_ivs.theta,
% all_ivs.running) plus the start and end times of sessions in iv format
% (all_ivs.session) - you can use this session info to cut out your
% sessions of interest later on
% 
%
% Theta threshold (theta_thresh) is set manually by the user as the theta 
% z-score (which you threshold to choose the high theta times) is determined 
% by the mean theta in a recording, which might be higher or lower depending on
% your mouse (and then you need to lower or raise your threshold
% accordingly)
%
% Movement threshold (spd_thresh) is set within the fn to 12 but if this 
% doesn't seem sensible feel free to change.
% 
% Other important parameters for theta and speed thresholding are the minlen 
% and merge_thr which are set in seconds, I've tried to set this up to get
% relatively big chunks out (at least half a second) but again feel free to
% change if the output doesn't look sensible
%
% You could also change the smoothing on theta_power by changing stdev_size
%% Load LFP
cd(dir);
cfg=[];
cfg.fc = {['CSC' num2str(channel) '.ncs']};
csc = LoadCSC(cfg);

%% Load video
pos=LoadPos([]);

%% Find chunks with only good theta

close all

% filter to theta freqs
cfg=[];
cfg.type = 'cheby1';
cfg.order = 3; % filter order;
cfg.display_filter = 0; % show output of fvtool on filter
cfg.bandtype = 'bandpass'; % 'highpass', 'lowpass'
cfg.R = 0.25; % passband ripple (in dB) for Chebyshev filters only
cfg.f = [7 10]; %filter range to use (in Hz)

csc_filt = FilterLFP(cfg,csc);

% apply hilbert transform and square to get theta power
theta_pwr=LFPpower([],csc_filt);

% Convolve with gaussian
stdev_size=1; % size of sd in seconds
Fs = csc.cfg.hdr{1}.SamplingFrequency;
gauss_window=gausskernel(stdev_size.*5.*Fs,stdev_size.*Fs); % Create Gaussian

% set up conv_theta_pwr to have the same fields as theta_pwr
conv_theta_pwr=theta_pwr;

% change the data bit of conv_theta_pwr
conv_theta_pwr.data=conv(theta_pwr.data,gauss_window,'same');
theta_pwr_z = zscore_tsd(conv_theta_pwr);

% Plot raw LFP and z-scored theta, get threshold as user input
hold on;plot(csc.tvec,rescale(csc.data,3,4)); plot(theta_pwr_z.tvec,theta_pwr_z.data);
legend('raw LFP','z-scored theta power');
msgbox('Look at the LFP and theta power and press any button to continue when you are satisfied')
pause;
close gcf
theta_thresh=input('Where should the threshold be?: ');

if or(~isnumeric(theta_thresh),length(theta_thresh)>1)
    error('Input must be a single number')
end

% Threshold (this automatically z scores too
cfg=[];
cfg.method = 'zscore';
cfg.threshold = theta_thresh;
cfg.dcn =  '>'; % '<', '>'
cfg.merge_thr = 2; % merge events closer than this
cfg.minlen = 1; % minimum interval length

theta_iv=TSDtoIV(cfg,conv_theta_pwr);

%% Find chunks with running

% Get distance travelled between each sample
spd = getLinSpd([],pos);

% Remove weirdly high values
cfg=[];
cfg.method = 'raw';
cfg.threshold = 150;
cfg.dcn =  '<'; % '<', '>'
cfg.merge_thr = 0.01; % merge events closer than this
cfg.minlen = 0.01; % minimum interval length

spd_iv=TSDtoIV(cfg,spd);
spd=restrict(spd,spd_iv);

spd_thresh=12;

% Select only true running (please change the thresholds if you want to..)
cfg=[];
cfg.method = 'raw';
cfg.threshold = spd_thresh;
cfg.dcn =  '>'; % '<', '>'
cfg.merge_thr = 0.3; % merge events closer than this
cfg.minlen = 0.5; % minimum interval length
run_spd_iv=TSDtoIV(cfg,spd);
run_spd=restrict(spd,run_spd_iv);

% plot(spd.tvec,spd.data);hold on;plot(run_spd.tvec,run_spd.data,'.');

% 
% figure;
% PlotTSDfromIV([],run_spd_iv,spd);
% title('Detected running times in speed')

%% Getting different run speed bins

% Baseline bin

spd_tmp=spd;

for i=1:3
    cfg=[];
    cfg.method = 'raw';
    cfg.threshold = [5+(i-1)*10 5+i*10];
    cfg.dcn =  'range'; % '<', '>'
    cfg.merge_thr = 0.3; % merge events closer than this
    cfg.minlen = 0.5; % minimum interval length
    run_bin_iv{i}=TSDtoIV(cfg,spd_tmp);
    run_bin{i}=restrict(spd_tmp,run_bin_iv{i});
    run_bin_iv{i}.name=num2str(cfg.threshold);
end

%sanity plot
figure;
plot(spd.tvec,spd.data);

hold on;
for i=1:3
    plot(run_bin{i}.tvec,run_bin{i}.data,'.');
end

% plot time in each bin

for i=1:3
    run_time(i)=sum(run_bin_iv{i}.tend-run_bin_iv{i}.tstart);
end
figure;
bar(5:10:25,run_time,'histc')

%% TODO Find chunks w gamma (maybe?)


%% get session start and end ivs

cfg = [];
cfg.eventList = {'Starting Recording','Stopping Recording'};


evt = LoadEvents(cfg);

%% Restrict using running and theta ivs and plot outcome

% Select the theta bits
csc_restricted=restrict(csc,theta_iv);
% Now select the running bits
csc_restricted=restrict(csc_restricted,run_spd_iv);

csc_for_plot=csc;
csc_for_plot.data=rescale(csc.data,3,5);

figure;
subplot(3,1,1)
PlotTSDfromIV([],theta_iv,csc_for_plot);
title('Detected theta in raw LFP and z-scored theta power')
hold on;
plot(theta_pwr_z.tvec,theta_pwr_z.data,'Color',[ 0.4940    0.1840    0.5560]);
plot([theta_pwr_z.tvec(1) theta_pwr_z.tvec(end)],[theta_thresh theta_thresh],'LineWidth',2,'Color',[0.8500    0.3250    0.0980])
ax(1)=gca;
subplot(3,1,2)
PlotTSDfromIV([],run_spd_iv,spd);
title('Detected running times in speed')
ax(2)=gca;
subplot(3,1,3)
plot(csc_restricted.tvec,csc_restricted.data);
hold on;
% put little arrows to mark session start and end
plot(evt.t{1},0,'>g');
plot(evt.t{2},0,'<g');
ax(3)=gca;
title('restricted lfp and session markers')

linkaxes(ax,'x')

%% Create all_ivs output

if length(evt.t{1})>1
    all_ivs.session=iv(evt.t{1}',evt.t{2}');
else
    disp('manual input of recording start and end')
    disp(['start recording: ' num2str(evt.t{1})])
    disp(['stop recording: ' num2str(evt.t{2})])
    tstarts=input('Please input tstarts: ')';
    tends=input('Please input tends: ')';
    
    if or(~isnumeric(tstarts),~isnumeric(tends))
        error('input not numeric')
    else
        if length(tstarts)~=length(tends)
            error('tstarts and tends are not same length')
        end
        all_ivs.session=iv(tstarts,tends);
    end
end
all_ivs.theta=theta_iv;
all_ivs.running=run_spd_iv;
all_ivs.run_bins=run_bin_iv;

%% Create separate iv fields for each session (just in case)

all_ivs.rest1=SelectIV_idx(all_ivs.session,1);
all_ivs.trackA_nov=SelectIV_idx(all_ivs.session,2);
all_ivs.rest2=SelectIV_idx(all_ivs.session,3);
all_ivs.trackB_nov=SelectIV_idx(all_ivs.session,4);
all_ivs.rest3=SelectIV_idx(all_ivs.session,5);
all_ivs.trackA_fam=SelectIV_idx(all_ivs.session,6);
all_ivs.rest4=SelectIV_idx(all_ivs.session,7);

end

