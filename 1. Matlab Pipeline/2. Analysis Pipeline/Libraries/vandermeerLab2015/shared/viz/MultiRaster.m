function out = MultiRaster(cfg_in,S)
% function MultiRaster(cfg,S) plots the spiketrain S with optional inputs for lfps and
% iv or ts event objects. 
% User can move viewing window via keyboard input (type "help navigate" in command window).
%
%   INPUTS:
%       cfg_in: input cfg
%       S: input ts NOTE: S.t can be a MxN cell array where M is the number of repeated trials
%       and N is the number of labeled signals
%
%   CFG OPTIONS:
%       cfg.SpikeHeight - default 0.4
%           Size of marker for each spike
%
%       cfg.lfp - default NONE
%           LFP data in ts format. Multiple sources of lfp data can be input as a single
%           cfg.lfp object by using a 1xM struct array where M is the number of lfp signals.
%           (i.e., cfg.lfp(1) = lfpA; cfg.lfp(2) = lfpB)
%
%       cfg.evt - default NONE
%           Event data in ts or iv format. Multiple sources of event data in a single 
%           cfg.evt object by using a 1xM cell array where M is the number of event files.
%           (i.e., cfg.evt = {evt1,evt2}, where evt1=ts evt2=iv)
%
%       cfg.axisflag - default 'tight'
%           Converts axis scaling. TIGHT restricts the plot to the data range. ALL sets
%           the x-axis to cover the whole experiment.
%
%       cfg.spkColor - default 'k' (black)
%           Color specifier for spikes in a single trial. Can be 1x3 vector of RGB values 
%           [1 0 0], or a string specifying the short name of a color ('r'), or a string 
%           specifying a colormap ('linspecer'). 
%           NOTE: multiple trials will call upon a function to create a good
%           colormap to distinguish cells.
%
%       cfg.ivColor - default 'r' (red)
%           Color specifier for iv. Can be 1x3 vector of RGB values [1 0 0], or a string 
%           specifying the short name of a color ('r').
%
%       cfg.lfpColor - default 'k' (black)
%           Color specifier for lfp signal. Can be 1x3 vector of RGB values [1 0 0], or a string 
%           specifying the short name of a color ('r').
%
%       cfg.lfpHeight - default 5 
%           The height of the lfp from maximum to minium in y-axis units. Vertically 
%           stretches the lfp to improve visibility of oscillations. lfp + iv mode only. 
%
%       cfg.lfpMax - default 15
%           Values greater than lfpMax times above mean(abs(lfp.data)) will be plotted 
%           as NaNs. Improves visibilty by cutting off high-amplitude [noise] blips 
%           in raw lfp. lfp + iv mode only.
%
%       cfg.axislabel - default 'on'
%           Automatically creates labels for the axes. Can be turned off.
%
%
% youkitan 2014-11-06 
% edit 2015-01-20
% ACarey edit, 2015-01-20 (lfpHeight and lfpMax)

%% Set cfg parameters and check inputs
cfg_def.SpikeHeight = 0.4;
cfg_def.axisflag = 'tight';
cfg_def.spkColor = 'k';
cfg_def.ivColor = 'r';
cfg_def.lfpColor = 'k'; 
cfg_def.lfpHeight = 15;
cfg_def.lfpMax = 15;
cfg_def.axislabel = 'on';
cfg_def.windowSize = 1;
cfg_def.openInAxes = 0; % replace with axes handle to open in axes instead of figure
cfg = ProcessConfig2(cfg_def,cfg_in);

%% Setup navigate

global evtTimes windowSize time usrfield
windowSize = cfg.windowSize;

% Initialize time vector for navigating
if ~isfield(cfg,'time')
    %create internal tvec
    spktimes = [];
    for iC = 1:length(S.t)
       spktimes = cat(1,spktimes,S.t{iC}); 
    end
    spktimes = sort(spktimes);

    tstart = spktimes(1);
    tend = spktimes(end);

    binSize = 0.01;
    time = tstart:binSize:tend;
end

% Initialize events
if isfield(cfg,'evt')
    evtTimes = cfg.evt;
    % Initialize usr input text
    if isfield(cfg.evt,'usr')
        usrfield = cfg.evt.usr;
    else
        usrfield = [];
    end
else
    %set time vector as evtTimes
    evtTimes = time;
    usrfield = [];
end
    
% open in appropriate fig or axes
if ~cfg.openInAxes
    figure('KeyPressFcn',@navigate)
    hold on;
else
    axes(cfg.openInAxes);
    hold on;
end

%% Error checking and plot type setup
% Check to see what datatypes we need to plot besides spikes and do error checking. 

ts_only = @(x) isfield(x,'t') && ~isfield(x,'tstart');
iv_only = @(x) isfield(x,'tstart') && ~isfield(x,'t');

if isfield(cfg,'lfp') %lfp
    ylims = PlotSpikeRaster2(cfg,S);

    spikelims = get(gca,'Xlim');
    for iLFP = 1:length(cfg.lfp)
      cfg.lfp(iLFP) = lfp_check(cfg,cfg.lfp(iLFP),spikelims);
    end

    if ~isfield(cfg,'evt')
        plotMode = 5;

    elseif ts_only(cfg.evt) %lfp + ts
        plotMode = 6;

    elseif iv_only(cfg.evt) %lfp + iv
        plotMode = 7;

    else %lfp + ts + iv
        plotMode = 8;
    end

elseif isfield(cfg,'evt')
    if ts_only(cfg.evt) %ts
        plotMode = 2;

    elseif iv_only(cfg.evt) %iv
        plotMode = 3;

    else %ts + iv
        plotMode = 4;

    end

else %default (spikes only)
    plotMode = 1;

end

%% Choose Plotting mode
switch plotMode        
    case 1 % just spikes
        ylims = PlotSpikeRaster2(cfg,S);
        
    case 2 % ts data only
        ylims = PlotSpikeRaster2(cfg,S);
        PlotTSEvt(cfg,cfg.evt)
        
    case 3 % iv data only
        evtTimes = (cfg.evt.tstart + cfg.evt.tend)./2;
        S_iv = restrict(S,cfg.evt.tstart,cfg.evt.tend);
        ylims = PlotSpikeRaster2(cfg,S);
        cfg.spkColor = 'r';
        ylims = PlotSpikeRaster2(cfg,S_iv);
        
    case 4 % ts + iv data NOT WORKING YET
        error('ts + iv event data NOT WORKING YET')
        
    case 5 % lfp data only
        numLFP = length(cfg.lfp);        
        cmap = linspecer(numLFP);

        for iLFP = 1:numLFP
            lfp = cfg.lfp(iLFP);
            
            abslfp = abs(lfp.data);
            nans_here = abslfp > cfg.lfpMax*mean(abslfp);
            lfp.data(nans_here) = NaN;
            
            lower_val = -iLFP*cfg.lfpHeight;
            upper_val = lower_val+cfg.lfpHeight;

            lfp.data = rescale(lfp.data,lower_val,upper_val);
            plot(lfp.tvec,lfp.data,'Color',cmap(iLFP,:))
        end
        ylims(1) = lower_val;

    case 6 % lfp + ts data
        abslfp = abs(cfg.lfp.data);
        nans_here = abslfp > cfg.lfpMax*mean(abslfp);
        cfg.lfp.data(nans_here) = NaN;
        
        cfg.lfp.data = rescale(cfg.lfp.data,-cfg.lfpHeight,0);
        plot(cfg.lfp.tvec,cfg.lfp.data,'Color',cfg.lfpColor);
        ylims(1) = -cfg.lfpHeight;
        PlotTSEvt([],cfg.evt)

    case 7 % lfp + iv data
        evtTimes = (cfg.evt.tstart + cfg.evt.tend)./2;
        abslfp = abs(cfg.lfp.data);
        nans_here = abslfp > cfg.lfpMax*mean(abslfp);
        cfg.lfp.data(nans_here) = NaN;
        cfg.lfp.data = rescale(cfg.lfp.data,-cfg.lfpHeight,0);
        cfg_temp.display = 'tsd';
        cfg_temp.bgcol = cfg.lfpColor;
        cfg_temp.fgcol = cfg.ivColor;
        
        PlotTSDfromIV(cfg_temp,cfg.evt,cfg.lfp);
        ylims(1) = -cfg.lfpHeight - 1;
    
    case 8 % lfp + iv + ts data
        error('ts + iv event data NOT WORKING YET')
end 

%% Helper Functions

    function lfp = lfp_check(cfg_in,lfp_in,limits)
    % Checks lfp size and restricts it to the spiking data time interval
        if (min(lfp_in.tvec) < limits(1) || max(lfp_in.tvec) > limits(2))...
                && strcmp(cfg_in.axisflag,'tight')
            fprintf('minlfp = %d maxlfp = %d minspikes = %d maxspikes = %d\n',...
                min(lfp_in.tvec),max(lfp_in.tvec),limits(1),limits(2))
            fprintf('Range of lfp data exceeds spiketrain data!... Restricting lfp data...');
            lfp = restrict(lfp_in,limits(1),limits(2));   
        else 
            lfp = lfp_in;
        end
    end


%% Adjust figure

% Set Axis limits
xlims = get(gca,'XLim');

switch cfg.axisflag
    case 'tight'
        xlim([xlims(1) xlims(2)]);
        ylim([ylims(1)-1 ylims(2)+1]);
    case 'all'
        xlim([S.cfg.ExpKeys.TimeOnTrack S.cfg.ExpKeys.TimeOffTrack]);
        ylim([ylims(1)-1 ylims(2)+1])
end

hold off;



%% output for debugging
plotmodes = {'spikes only','ts events','iv events','ts + iv events','lfp','lfp + ts events'...
    'lfp + iv events','all'};
% out.yvals = yvals;
out.plotMode = plotmodes{plotMode};
% out.plot = h;
end