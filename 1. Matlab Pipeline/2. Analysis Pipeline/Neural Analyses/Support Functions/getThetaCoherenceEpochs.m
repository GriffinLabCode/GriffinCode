%% Theta coherence epochs
% this code generates singular values for theta coherence during some time
% window of interest specified by your LFP inputs
%
% -- INPUTS -- %
% data1: LFP data to sample over. Vector format
% data2: LFP data to sample over
% movingwin: moving window parameters. For example:
%               -> movingwin = [1.25 .25]; 
%               -> 1.25 sec window, moving with .25sec steps
% srate: sampling rate (e.g. 2000)
% 
% --- OUTPUTS --- %
% c: Coherence outputs per frequency
% t: windowed time for coherence estimations
% f: frequency (same as input really)
%
% written by John Stout
    
function [C,t,f] = getThetaCoherenceEpochs(data1,data2,srate)

% reorient data
data1 = change_row_to_column(data1);
data2 = change_row_to_column(data2);

% preparatory steps
f = [6:.5:11];
movingwin = [1.25 .25];
Fs = srate;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
[N,Ch]=check_consistency(data1,data2);
winstart=1:Nstep:N-Nwin+1;
nw=length(winstart);

C = [];
for n=1:nw
    
    % get data
    indx     = winstart(n):winstart(n)+Nwin-1;
    datawin1 = data1(indx,:);
    datawin2 = data2(indx,:);
    
    % detrend
    datawin1 = detrend(datawin1,3);
    datawin2 = detrend(datawin2,3);
    
    % compute coherence
    c = mean(mscohere(datawin1,datawin2,[],[],f,srate));  
    
    % store coherence
    C(n,:)=c;
end
% reorient coherence matrix
C = C';

% generate time
winmid=winstart+round(Nwin/2);
t=winmid/Fs;

%{
figure('color','w')
pcolor(t,f,C);
shading interp
%}