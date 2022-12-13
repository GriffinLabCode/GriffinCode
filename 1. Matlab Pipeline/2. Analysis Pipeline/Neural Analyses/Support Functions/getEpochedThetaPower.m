%% get epoched power
% this code generates a distribution of theta 6-11hz values over some time
% interval (as dictated by the signal you provide)

% -- INPUTS -- %
% data1: LFP data to sample over. Vector format
% movingwin: moving window parameters. For example:
%               -> movingwin = [1.25 .25]; 
%               -> 1.25 sec window, moving with .25sec steps
% srate: sampling rate (e.g. 2000)
% 
% --- OUTPUTS --- %
% S: Power per epoch
% t: windowed time for power estimations
% f: frequency (same as input really)
%
% written by John Stout
    
function [S,t,f] = getEpochedThetaPower(data,movingwin,srate)
clear starter ender coh

% reorient data
data = change_row_to_column(data);

% preparatory steps
f = [6:.5:11];
Fs = srate;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
[row,col] = size(data);
if row < col
    data = data';
    disp('Signal detected on columns. Inverted so signal is on rows')
end
[N,~] = size(data);
winstart=1:Nstep:N-Nwin+1;
nw=length(winstart);

S = [];
for n=1:nw
    
    % get data
    indx     = winstart(n):winstart(n)+Nwin-1;
    datawin1 = data(indx,:);
    
    % detrend
    datawin1 = detrend(datawin1,3);
    
    % compute coherence
    s = mean(pwelch(datawin1,[],[],f,srate));  
    
    % store coherence
    S(n,:)=s;
end
% reorient coherence matrix
S = S';

% generate time
winmid=winstart+round(Nwin/2);
t=winmid/Fs;

%{
figure('color','w')
pcolor(t,f,C);
shading interp
%}