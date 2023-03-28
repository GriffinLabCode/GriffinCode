%% raster plot
% -- INPUTS -- %
% spkBool: boolean spike variable, rows = observations (trials, swrs,
%               events, etc...) columns = samples (time). Each element is
%               either 0 (no spike) or 1 (spike)
% srate: sampling rate of your signal. If fit to LFP, its your lfp sampling
%           rate. If fit to camera, your camera sampling rate
%
% -- OPTIONAL INPUTS -- 
% xTime: time variable. If you have LFP of size nx1001 (samples) and your
%           srate is 1000 (you have 1s of data with some centered point),
%           then you would do something like this: 
%               xTime = linspace(-0.5,0.5,size(spkBool,2));
% tickSize: value between 0 and 1. leave empty for automatic estimation
% genFig: set to 'y' if you want the function to create a figure (default).
%           Set to 'n' if you want to create your own fig. 'n' is very
%           useful for subplotting
%
% -- OUTPUT -- %
% figure

function [sumSpks] = rasterPlot(spkBool,srate,xTime,tickSize,color,genFig,plotFig)

    % if genFig isn't specified
    if exist('genFig')==0
        genFig = 'y';
    end
    
    % handle tick size variable
    if exist('tickSize')==0
        tickSize = 0.4;
    else
        if isempty(tickSize)
            tickSize = 0.4;
        end
    end
    
    % specify x variable
    if exist('xTime')==0
        xTime = 1:size(spkBool,2);
    end
    
    % assign color
    if exist('color')==0
        color = 'k';
    end
    
    % create figure
    if contains(genFig,'y')
        figure('color','w'); 
    end
    hold on;
    
    if contains(plotFig,'y')
        %xTime = linspace(-0.25,0.25,size(temp,2));
        for rowi = 1:size(spkBool,1)
            temp  = spkBool(rowi,:);
            idxSpk = find(temp);
            % convert to time if specified
            spkTime = xTime(idxSpk);
            for i = spkTime
                line([i i],[rowi-tickSize rowi+tickSize],'Color',color,'LineWidth',2);
            end
        end
        ylabel('Obs');
        xlabel('Time/samples');
    end
    
    % calculate firing rate
    sumSpks   = sum(spkBool);
    timing    = diff(xTime);
    %fr = sumSpks./(timing(1));
    %frSmooth = zscore(smoothdata(fr,'gaussian',round(srate*0.05)));
    %frSmooth = normalize(smoothdata(fr,'gaussian',round(srate*0.05)),'range');
    % firing rate is defined as number of spikes / 
    %frSmooth = spkSmooth./(round(srate*0.1));
    %figure('color','w');
    %plot(xTime,frSmooth)
