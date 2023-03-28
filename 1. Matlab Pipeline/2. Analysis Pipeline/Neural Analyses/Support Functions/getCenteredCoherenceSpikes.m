%% getCenteredCoherenceSpikes
% this code computes coherence over a moving window and aligns spikes to
% transition points defined by the user. Includes all coherence data.
% Includes all spiking data
%
% -- INPUTS -- %
% data1: LFP data to sample over. Vector format
% data2: LFP data to sample over
% boolSpikes: spike data of the same shape as LFP with rows as units and
%               columns as samples. 0 = no spike. 1 = spike
% highThresh: high coherence threshold
% lowThresh: low coherence threshold
% srate: sampling rate (e.g. 2000)
% f: frequencies to compute coherence over. For example:
%               -> f = [1:.5:20]; computes coherence bw 1 hz to 20hz over a
%               range of 0.5 increments
% 
% --- OUTPUTS --- %
% spkHigh: variable of type "cell". Each array is organized by unit
%           (spkHigh{1} = unit #1 from boolSpikes [ boolSpikes(1,:) ].
%           spkHigh{1}(1,:) = spike data -0.25s and +0.25s surrounding the
%           onset of the coherence epoch
% spkLow: same as spike high but for low coherence vents
%
% written by John Stout
    
function [spkHigh,spkLow] = getCenteredCoherenceSpikes(data1,data2,boolSpikes,highThresh,lowThresh,srate,f)
clear starter ender coh

% preset
movingwin = [1.25 0.25];
disp('Preset moving window and time-around for spikes information');

% reorient data
data1 = change_row_to_column(data1);
data2 = change_row_to_column(data2);

% preparatory steps
%f = [1:.5:20];
Fs = srate;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
[N,Ch]=check_consistency(data1,data2);
winstart=1:Nstep:N-Nwin+1;

% remove the first epoch for this analysis (cant get spikes from something
% you dont have)
winstart(1)=[];
nw=length(winstart);

C = [];
clear spkHigh spkLow
for n=1:nw % have to skip first event
    
    % get data
    indx     = winstart(n):winstart(n)+Nwin-1;
    datawin1 = data1(indx,:);
    datawin2 = data2(indx,:);
    %spkwin = boolSpikes(:,indx);
    
    % detrend
    datawin1 = detrend(datawin1,3);
    datawin2 = detrend(datawin2,3);
    
    % compute coherence
    c = mean(mscohere(datawin1,datawin2,[],[],f,srate));  
    for clusti = 1:size(boolSpikes,1)
        % get spikes surrounding high and low coherence events
        if c > highThresh
            % find spikes surrounding onset and erase those spikes so that they
            % aren't used twice
            spkHigh{clusti}(n,:) = boolSpikes(clusti,indx(1)-(srate*0.25):indx(1)+(srate*0.25));
            % replace spikes used by NaN
            %boolSpikes(clusti,indx(1)-(srate*0.25):indx(1)+(srate*0.25))=NaN;
        else
            spkHigh{clusti}(n,:) = NaN([size(boolSpikes(clusti,indx(1)-(srate*0.25):indx(1)+(srate*0.25)))]);                        
        end

        if c < lowThresh
            % find spikes surrounding onset and erase those spikes so that they
            % aren't used twice
            spkLow{clusti}(n,:) = boolSpikes(clusti,indx(1)-(srate*0.25):indx(1)+(srate*0.25));
            % replace spikes used by NaN
            %boolSpikes(clusti,indx(1)-(srate*0.25):indx(1)+(srate*0.25))=NaN;
        else
            spkLow{clusti}(n,:) = NaN([size(boolSpikes(clusti,indx(1)-(srate*0.25):indx(1)+(srate*0.25)))]);            
        end
    end
end

%{
figure('color','w')
pcolor(t,f,C);
shading interp
%}