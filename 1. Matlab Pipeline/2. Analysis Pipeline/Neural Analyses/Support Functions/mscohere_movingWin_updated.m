%% Coherence in moving window
% this code computes coherence over a moving window. This code uses
% mscohere, and detrends the data by removing 3rd degree polynomials using
% the moving window as the segment to detrend over. 
%
% this code also accounts for artifacts in the data, removing them
%
% -- INPUTS -- %
% data1: LFP data to sample over. Vector format
% data2: LFP data to sample over
% movingwin: moving window parameters. For example:
%               -> movingwin = [1.25 .25]; 
%               -> 1.25 sec window, moving with .25sec steps
% srate: sampling rate (e.g. 2000)
% f: frequencies to compute coherence over. For example:
%               -> f = [1:.5:20]; computes coherence bw 1 hz to 20hz over a
%               range of 0.5 increments
% 
% --- OUTPUTS --- %
% coh: Coherence outputs per frequency
% t: windowed time for coherence estimations
% f: frequency (same as input really)
%
% written by John Stout
    
function [C,t,f] = mscohere_movingWin_updated(data1,data2,movingwin,srate,f)
clear starter ender coh

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
    c = mscohere(datawin1,datawin2,[],[],f,srate);  
    
    % store coherence
    C(n,:)=c;
end
% reorient coherence matrix
C = C';

% generate time
winmid=winstart+round(Nwin/2);
t=winmid/Fs;

% get time around
totalTime = length(data1)/srate;
% t might not be correct bc the moving window may not complete the entire
% signal
t = linspace(-totalTime/2,totalTime/2,size(C,2));

%{
figure('color','w')
pcolor(t,f,C);
shading interp
%}