function [filteredeeg] = skaggs_filter_var(eegval, lowpass, highpass, srate)

%   Third-degree Butterworth filter for bandpass filtering

% Input:
%   eegval:     1 x n data points array of continuously sampled data
%   lowpass:    Lowpass filter value (Hz)
%   highpass:   Highpass filter value (Hz)
%   srate:      Sampling rate (Hz)

%%

nfq = srate/2; %Niquist frequency (nfq)=sampling rate/2
par1 = lowpass/nfq;
par2 = highpass/nfq;
[b,a] = butter(3,[par1 par2]);
filteredeeg = filtfilt(b,a,eegval);
%end