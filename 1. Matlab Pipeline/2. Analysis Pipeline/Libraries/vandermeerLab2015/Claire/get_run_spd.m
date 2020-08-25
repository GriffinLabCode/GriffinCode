function [mouse] = get_run_spd(mouse)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

dir=['C:\Data\Backup\' mouse.cfg.SessionID]

%% Load video
cd(dir);
pos=LoadPos([]);

%% get session start and end ivs

cfg = [];
cfg.eventList = {'Starting Recording','Stopping Recording'};

evt = LoadEvents(cfg);

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

% all_ivs.rest1=SelectIV_idx(all_ivs.session,1);
all_track_iv=SelectIV_idx(all_ivs.session,[2 4 6]);
% all_ivs.rest2=SelectIV_idx(all_ivs.session,3);
% trackB_nov=SelectIV_idx(all_ivs.session,4);
% all_ivs.rest3=SelectIV_idx(all_ivs.session,5);
% trackA_fam=SelectIV_idx(all_ivs.session,6);
% all_ivs.rest4=SelectIV_idx(all_ivs.session,7);


%% Find chunks with running

% Get distance travelled between each sample
spd = getLinSpd([],pos);

% % Restrict to track times only
% spd=restrict(spd,all_track_iv);

% Remove high values
max_thresh=50;
cfg=[];
cfg.method = 'raw';
cfg.threshold = max_thresh;
cfg.dcn =  '<'; % '<', '>'
cfg.merge_thr = 0.01; % merge events closer than this
cfg.minlen = 0.01; % minimum interval length

spd_iv=TSDtoIV(cfg,spd);
spd=restrict(spd,spd_iv);

spd_thresh=12;

% Select run
cfg=[];
cfg.method = 'raw';
cfg.threshold = spd_thresh;
cfg.dcn =  '>'; % '<', '>'
cfg.merge_thr = 0.1; % merge events closer than this
cfg.minlen = 0.1; % minimum interval length
run_spd_iv=TSDtoIV(cfg,spd);
run_spd=restrict(spd,run_spd_iv);

% Select stationary
cfg=[];
cfg.method = 'raw';
cfg.threshold = spd_thresh;
cfg.dcn =  '<'; % '<', '>'
cfg.merge_thr = 0.1; % merge events closer than this
cfg.minlen = 0.1; % minimum interval length
stationary_iv=TSDtoIV(cfg,spd);
stationary=restrict(spd,stationary_iv);
%% Set everything

run_track_spd=restrict(run_spd,all_track_iv);
stationary_track=restrict(stationary,all_track_iv);

stationary_iv=IntersectIV([],stationary_iv,all_track_iv);
run_spd_iv=IntersectIV([],run_spd_iv,all_track_iv);

mouse.track_ivs=all_track_iv;
mouse.stationary=stationary_track;
mouse.stationary.iv=stationary_iv;
mouse.stationary.threshold=spd_thresh;
mouse.stationary_time=sum(stationary_iv.tend-stationary_iv.tstart);
mouse.strackspd_time=sum(run_spd_iv.tend-run_spd_iv.tstart);
mouse.totaltime=sum(all_track_iv.tend-all_track_iv.tstart);
mouse.prop_stationary=mouse.stationary_time/mouse.totaltime;
mouse.prop_track=mouse.strackspd_time/mouse.totaltime;
% mouse.trackspd=track_spd;
% mouse.trackspd.threshold=spd_thresh;
% mouse.trackspd.median=median(track_spd.data);

end

