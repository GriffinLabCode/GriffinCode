%% event triggered LFP
% this code gets LFP data around event times of interest. This would be
% useful if you identify certain events, like maybe choice point entry, the
% moment of a VTE, or the turning on of a laser, then getting data around
% that point.
%
% You could 1) run getLFPdata, then identify your timestamps of interest,
% then run this code. Could be fed into pspectrum or mscohere after or
% something.
%
% -- INPUTS -- %
% edgeTimes = [6.25 6.25]; % how much time surrounding the event
% eventTimes: Vector of timestamps that you want to get LFP around
% lfpData: Vector of LFP (converted) from your session
% lfpTimes: Vector of timestamps for each LFP data point
% srate: sampling rate of LFP
% 
% -- OUTPUTS -- %
% eventLFP: matrix of LFP data where rows reflect events and columns
%               reflect LFP data
% t: time variable
%
% written by John Stout

function [eventLFP,t] = getEventTriggeredLFP(lfpData,lfpTimes,eventTimes,edgeTimes,srate)

% correct the inputs incase you write -1 to +1 or something
edgeTimes = abs(edgeTimes);

% convert your time variable into samples
edgeSamples = edgeTimes*srate;

% get index of times
lfpIdx = dsearchn(lfpTimes',eventTimes);

% loop across events and get LFP
for i = 1:numel(eventTimes)
    eventLFP(i,:) = lfpData(lfpIdx(i)-edgeSamples(1):lfpIdx(i)+edgeSamples(2));
end

% get your time variable out
t = linspace(-edgeTimes(1),edgeTimes(2),size(eventLFP,2));

%{
% could avg it like spk triggered avg
eventLFPavg = nanmean(eventLFP,1);

figure('color','w')
plot(t,eventLFPavg)
axis tight;
xlim([-1 1])

%}
