function [all_sess]=run_ifrq_pipe(dir,channels)
close all
% run the theta instantaneous frequency extraction for diff sessions

%% run the prelim data check to choose analysis channel

prelim_data_check(dir,channels);
%% set channel

channel=input('which channel?: ');

%% Load LFP
cd(dir);
cfg=[];
cfg.fc = {['CSC' num2str(channel) '.ncs']};
csc = LoadCSC(cfg);
%% run stuffs
[~,all_ivs] = restrict_to_theta(dir,channel);

[smooth_ifrq] = get_ifrq(csc);

%% Restrict the frequency infos and create a special var
% This could be used if I am interested in only looking @ high theta bits
disp('Restricting for session info..')
% Select the theta bits
ifrq_restrict_tmp=restrict(smooth_ifrq,all_ivs.theta);
% Now select the running bits in the new theta restricted data
ifrq_restrict_tmp=restrict(ifrq_restrict_tmp,all_ivs.running);

%% Now restrict by session IVs
ifrq_restrict.rest1=restrict(ifrq_restrict_tmp,all_ivs.rest1);
ifrq_restrict.rest1.name='rest1';
ifrq_restrict.trackA_nov=restrict(ifrq_restrict_tmp,all_ivs.trackA_nov);
ifrq_restrict.trackA_nov.name='trackA_nov';
ifrq_restrict.rest2=restrict(ifrq_restrict_tmp,all_ivs.rest2);
ifrq_restrict.rest2.name='rest2';
ifrq_restrict.trackB_nov=restrict(ifrq_restrict_tmp,all_ivs.trackB_nov);
ifrq_restrict.trackB_nov.name='trackB_nov';
ifrq_restrict.rest3=restrict(ifrq_restrict_tmp,all_ivs.rest3);
ifrq_restrict.rest3.name='rest3';
ifrq_restrict.trackA_fam=restrict(ifrq_restrict_tmp,all_ivs.trackA_fam);
ifrq_restrict.trackA_fam.name='trackA_fam';
ifrq_restrict.rest4=restrict(ifrq_restrict_tmp,all_ivs.rest4);
ifrq_restrict.rest4.name='rest4';

%% Get means and stds
[all_sess.sessions] = mean_ifrq('all',ifrq_restrict);
all_sess.cfg.SessionID=csc.cfg.SessionID;
all_sess.cfg.channel=channel;

%% Get running speeds

disp('restricting for speed info');
%sorry this is ugly no time to fix
ifrq_bins.bin1=restrict(smooth_ifrq,all_ivs.run_bins{1});
ifrq_bins.bin1.name=all_ivs.run_bins{1}.name;
ifrq_bins.bin2=restrict(smooth_ifrq,all_ivs.run_bins{2});
ifrq_bins.bin2.name=all_ivs.run_bins{2}.name;
ifrq_bins.bin3=restrict(smooth_ifrq,all_ivs.run_bins{3});
ifrq_bins.bin3.name=all_ivs.run_bins{3}.name;

[all_sess.bins] = mean_ifrq('all',ifrq_bins);

%% output ivs

all_sess.ivs=all_ivs;
end