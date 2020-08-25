function SWRfreqs = SWRfreak(cfg_in,SWRtimes,csc)
%SWRFREAK get frequency spectrum for manually identified sharp wave-ripples
%
%   SWRfreqs = SWRfreak(SWRtimes,csc,)
%
%   SWRfreqs = SWRfreak(SWRtimes,csc,NOISEtimes) % not implemented yet
%
%   cfg.weightby = 'power'; or 'amplitude'
%                  'power' re-weight the spectrum to "unbias" the voltage
%                  over each frequency 
%                  'amplitude' raw spectrum
%   cfg.hiPassCutoff = 100; in Hz, disregard all frequencies below
%   cfg.fs = 2000; in Hz, the sampling frequency
%   cfg.win1 = 0.06; in ms, the window size
%   cfg.win2 = []; specify if you want two windows to be used
%   Suggested settings for two windows:
%         cfg.win1 = 0.08; in ms, the "noise reduction" window
%         cfg.win2 = 0.04; in ms, the "precision" window
%
%   cfg.showfig = 0; 0 do not display the figures; 1 display the figures
%          There is a hidden fig config if you open the function and read
%          the section called "Parse cfg parameters"
%
%   OUTPUT
%   
%   SWRfreqs - noise-corrected frequency spectrum: Fourier coefficients for 
%              SWRs minus the Fourier coefficients for HC background noise
%         .freqs1      - frequency spectrum based on win1
%         .freqs2      - (if win2 specified)frequency spectrum based on win2
%         .label       - csc used
%         .cfg         - record of cfg history
%         .parameters  - all parameters used to generate the output
% 
%   For additional information, open SWRfreak and read the ABOUT section
%
% Elyot Grant, Jan 2015 (math and original code)
% ACarey, Jan 2015 (responsible for poor function design >_<)
% - edit Mar 2015 -- additional config options, plotting

%% ABOUT SWRFREAK

% Why are there two windows, and why are 40 ms and 80 ms the defaults?

% The noise reduction and precision windows were chosen based on how well
% the plotted scores (from amSWR) characterized the data in the csc and the 
% spiketrains.
% 120, 100, 80, 60, and 40 ms windows were used for FFTing the data. 120
% and 100 merged nearby events and were rejected, despite lower rates
% of false positives. 80 ms still merged nearby events, but to
% a lesser degree than 100 and 120. It also had decently low scores for false
% positives. 40 ms had the best separation for nearby events, but was the
% worst for peaking at false positives. The geometric mean of the two of
% them did a good job, so it was decided that two sets of SWRfreqs
% were better than one. 

%% Parse cfg parameters

cfg_def.weightby = 'power'; 
cfg_def.win1 = 0.06;
cfg_def.win2 = [];
cfg_def.hiPassCutoff = 100; %We want to delete all frequencies below 100 Hz
cfg_def.fs = 2000; 
cfg_def.showfig = 0;
    % this makes it easier to delete the fig config from history:
    cfg_def.fig.SWRcolor = 'k'; % line colour for raw SWR freqs
    cfg_def.fig.NOISEcolor = [0.67 0.67 0.67]; % line colour for noise freqs 
    cfg_def.fig.FREQScolor = 'r'; % line colour for noise-corrected SWR freqs
    cfg_def.fig.LineWidth = 2; 
    cfg_def.fig.xlim = [0 600]; % xvals go all the way up to 1000 Hz (nyquist), but the freqs are basically flat after 600 Hz
    
cfg = ProcessConfig2(cfg_def,cfg_in);

%% check if csc is the same as the one used in ducktrap

if ~strcmp(SWRtimes.label{1}(1:15),csc.label{1}(1:15))
    error('CSC must be from the same day as the one used for manual identification')
end

if ~strcmp(SWRtimes.label,csc.label)
    warning('CSC is different from the one used for manual SWR identification')
end

%% internal function to do the thing

    function freqs = freakHelper(SWRtimes,csc,timewin)
        sampwin = timewin*cfg.fs; % the window size in nSamples = timewindow * sampling frequency 
        %tstart = SWRtimes.tcent - timewin/2;
        %tend = SWRtimes.tcent + timewin/2;
        midIndices = nearest_idx3(SWRtimes.tcent,csc.tvec);
        SWRsum = 0;
        for iSWR = 1:length(SWRtimes.tcent) 
            nextFFT = windowedFFT(cfg,csc.data,sampwin,midIndices(iSWR));
            SWRsum = SWRsum + nextFFT;
        end

        midIndices = nearest_idx3(SWRtimes.tcent+2,csc.tvec); % Add 2 seconds to each clicked time -> random time (this could error if a clicked time was closer than 2 s away from the end of recording?)
        SWRsumNoise = 0;
        for iSWR = 1:length(SWRtimes.tcent)
            nextFFT = windowedFFT(cfg,csc.data,sampwin,midIndices(iSWR));
            SWRsumNoise = SWRsumNoise + nextFFT;
        end

        SWRsum = conv(SWRsum,[0.1,0.2,0.4,0.2,0.1]); % narrow smoothing kernel
        SWRsum = SWRsum(3:length(SWRsum)-2);
        SWRsum = SWRsum./sum(SWRsum); %Normalize
        %plot(SWRsum);

        SWRnoise = conv(SWRsumNoise,[0.1,0.2,0.4,0.2,0.1]);
        SWRnoise = SWRnoise(3:length(SWRnoise)-2);
        SWRnoise = SWRnoise./sum(SWRnoise);
        %figure;plot(SWRnoise);

        freqs = (SWRsum - SWRnoise);
        freqs = conv(freqs,[0.1,0.2,0.4,0.2,0.1]);
        freqs = freqs(3:length(freqs)-2);
        %freqs = max(freqs,zeros(size(freqs))); %%%%%%%%%%%%%%%%%%%%%%
        %figure;plot(freqs);
        
        if cfg.showfig == 1 
            % plot some stuff
            
            frequency = (1:timewin*1000)./timewin;
            
            maxSWR = max(SWRsum);
            minSWR = min(SWRsum);
            maxNOISE = max(SWRnoise);
            minNOISE = min(SWRnoise);
            maxDIFF = max(freqs);
            minDIFF = min(freqs);
            
            ymax = max([maxSWR maxNOISE maxDIFF]);
            ymin = min([minSWR minNOISE minDIFF]);
            
            figure; hold on;
            plot(frequency,SWRsum,'Color',cfg.fig.SWRcolor,'LineWidth',cfg.fig.LineWidth);
            plot(frequency,SWRnoise,'Color',cfg.fig.NOISEcolor,'LineWidth',cfg.fig.LineWidth);
            plot(frequency,freqs,'Color',cfg.fig.FREQScolor,'LineWidth',cfg.fig.LineWidth);
            
            xlabel('Frequency (Hz)','Fontsize',11); 
            if strcmp(cfg.weightby,'power')
                type = 'Power weighted, ';
            elseif strcmp(cfg.weightby,'amplitude')
                type = 'Amplitude weighted, ';
            end
            xlim(cfg.fig.xlim); ylim([ymin-0.01 ymax+0.01])
            title([type,sprintf('%d SWRs, %d ms window',length(SWRtimes.tcent),timewin*1000)],'FontSize',14);
            legend('SWR','background noise','SWR - noise')
        end
    end

%% generate the output

if ~isempty(cfg.win2)
    freqs1 = freakHelper(SWRtimes,csc,cfg.win1);
    freqs2 = freakHelper(SWRtimes,csc,cfg.win2);
else 
    freqs1 = freakHelper(SWRtimes,csc,cfg.win1);
    freqs2 = [];
end

%% return the output
parameters = struct('weightby',cfg.weightby,'win1',cfg.win1,'win2',cfg.win2','hiPassCutoff',cfg.hiPassCutoff,'fs',cfg.fs,'csc',csc.label);

SWRfreqs = struct('freqs1',freqs1,'freqs2',freqs2,'parameters',parameters);
SWRfreqs.label = csc.label;

% keep a record
cfg = rmfield(cfg,'fig'); % because who cares what the figure settings were?
SWRfreqs.cfg.history.mfun = mfilename;
SWRfreqs.cfg.history.cfg = {cfg};

end

