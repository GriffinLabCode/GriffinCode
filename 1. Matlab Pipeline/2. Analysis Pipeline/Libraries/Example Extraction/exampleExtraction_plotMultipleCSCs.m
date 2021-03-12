%% example utility
clear; clc; close all;
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-13-18';

% get vt data - interpolate missing data - plot result
[x,y,ts] = getVTdata(datafolder,'interp','VT1.mat');
figure('color','w')
plot(x,y,'Color',[.6 .6 .6])

% load int
load('Int_file');

% load and convert csc - only need to load timestamps and srate from one
% variable as they're the same across csc channels
[re_csc,ts_lfp,srate] = getLFPdata(datafolder,'Re');
pf_csc = getLFPdata(datafolder,'mPFC');
hp_csc = getLFPdata(datafolder,'HPC');

% only look at correct trials
%Int = Int(Int(:,4)==0,:);

% plot data from an example trial
triali = 1;
ex_ts = ts_lfp(ts_lfp > Int(triali,1) & ts_lfp < Int(triali,8));
ex_re = re_csc(ts_lfp > Int(triali,1) & ts_lfp < Int(triali,8));
ex_pf = pf_csc(ts_lfp > Int(triali,1) & ts_lfp < Int(triali,8));
ex_hp = hp_csc(ts_lfp > Int(triali,1) & ts_lfp < Int(triali,8));

% clean data
params = getCustomParams();
params.Fs = srate;
[~,ex_re] = cleanLFP(ex_re,srate,params,params.movingwin,params.cleanFreq);
[~,ex_pf] = cleanLFP(ex_pf,srate,params,params.movingwin,params.cleanFreq);
[~,ex_hp] = cleanLFP(ex_hp,srate,params,params.movingwin,params.cleanFreq);

% get maze markers
tjun  = dsearchn(ex_ts',Int(triali,5));
gz_en = dsearchn(ex_ts',Int(triali,2));
gz_ex = dsearchn(ex_ts',Int(triali,7));

% create a time variable to make sense of lfp data
timeVar = linspace(0,length(ex_re)/srate,length(ex_re));

% make figure
figure('color','w')
subplot 311; hold on;
    plot(timeVar,ex_hp,'b');
    axis tight;
    ylimits = ylim;
    line([timeVar(tjun) timeVar(tjun)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    line([timeVar(gz_en) timeVar(gz_en)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    line([timeVar(gz_ex) timeVar(gz_ex)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    xlim([0 15])
subplot 312; hold on;
    plot(timeVar,ex_pf,'r');
    axis tight;
    ylimits = ylim;
    line([timeVar(tjun) timeVar(tjun)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    line([timeVar(gz_en) timeVar(gz_en)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    line([timeVar(gz_ex) timeVar(gz_ex)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    xlim([0 15])
subplot 313; hold on;
    plot(timeVar,ex_re,'m');
    axis tight;
    ylimits = ylim;
    line([timeVar(tjun) timeVar(tjun)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    line([timeVar(gz_en) timeVar(gz_en)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    line([timeVar(gz_ex) timeVar(gz_ex)],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    xlim([0 15])    











