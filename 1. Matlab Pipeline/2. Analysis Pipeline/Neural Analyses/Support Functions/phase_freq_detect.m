function [Phase, InstCycleFrequency, PerCycleFreq, signal_filtered] = phase_freq_detect(signal_filtered, signal_ts, lowpass, highpass, srate)

%   This function interpolates phase from peaks, troughs, and zero
%   crossings of a filtered signal. 
%   Signal_filtered should be bandpass filtered (filtfilt).  It's most
%   important to get high frequency oscillations out - so 1-60 is okay, 1-30
%   or even 4-12Hz might be better, depending on your need. 

%   Ensure that you have 'signal' processing toolbox added to your path.
%   Otherwise matlab will use the wrong version of the function 'findpeaks'

%   Set parameters for allowed peak and trough detection.  These can be
%   changed to whatever you want.  6-10 is about standard.  This will not
%   filter your signal - it will only constrain this code to find cycles
%   within this range. 

% Input:
%   signal_filtered:    Bandpass filtered signal
%   signal_ts:          Signal timestamps
%   lowpass:            Minimum frequency for cycle identification
%   highpass:           Maximum frequency for cycle identification
%   srate:              Sampling rate (Hz)

MinFreq = lowpass;
MaxFreq = highpass;


%%
fs = srate;
MPD = 1/MaxFreq*fs;

[~, peaks] = findpeaks(signal_filtered, 'MINPEAKDISTANCE', round(MPD));
[~, troughs] = findpeaks(signal_filtered.*-1, 'MINPEAKDISTANCE', round(MPD));

Test = 0;
PerCycleFreq = [];

Phase = NaN(length(signal_filtered),1);
InstCycleFrequency = NaN(length(signal_filtered),1);

for i = 1:length(peaks)-1
    valley = troughs(find(troughs > peaks(i) & troughs < peaks(i+1)));
    if length(valley) ~= 1, continue, end % Makes sure there is one valley between the peaks
    % find zero crossings for descending zero and ascending zero
    [~, ZeroCross270] = min(abs(signal_filtered(peaks(i):valley) - [(signal_filtered(peaks(i)) + signal_filtered(valley)) / 2]));
    ZeroCross270 = ZeroCross270+peaks(i)-1;
    [~, ZeroCross90] = min(abs(signal_filtered(valley:peaks(i+1)) - [(signal_filtered(peaks(i+1)) + signal_filtered(valley)) / 2]));
    ZeroCross90 = ZeroCross90+valley-1 ;    
    
    ThetaCyclePhase = [];
    % peak to ZeroCross 270
    x = [peaks(i) ZeroCross270];
    if length(unique(x)) == 1,Test = Test+1; continue, end
    y = [180 270];
    xi = peaks(i):1:ZeroCross270; 
    yi = interp1(x,y,xi);
    
    ThetaCyclePhase(peaks(i)-peaks(i)+1:1:ZeroCross270-peaks(i)+1) = yi;
    
    % ZeroCross270 to trough
    x = [ZeroCross270 valley];
    if length(unique(x)) == 1,Test = Test+1; continue, end
    y = [270 360];
    xi = ZeroCross270:1:valley; 
    yi = interp1(x,y,xi);
    
    ThetaCyclePhase(ZeroCross270-peaks(i)+1:1:valley-peaks(i)+1) = yi;
    
    % trough to ZeroCross90 - not huge problem
    x = [valley ZeroCross90];
    if length(unique(x)) == 1,Test = Test+1; continue, end
    y = [0 90];
    xi = valley:1:ZeroCross90; 
    yi = interp1(x,y,xi);
    
    ThetaCyclePhase(valley-peaks(i)+1:1:ZeroCross90-peaks(i)+1) = yi;
    
    % ZeroCross90 to peak
    x = [ZeroCross90 peaks(i+1)];
    if length(unique(x)) == 1, Test = Test+1;continue, end
    y = [90 180];
    xi = ZeroCross90:1:peaks(i+1); 
    yi = interp1(x,y,xi);
    
    ThetaCyclePhase(ZeroCross90-peaks(i)+1:1:peaks(i+1)-peaks(i)+1) = yi;    
    
    Phase(peaks(i):peaks(i+1)) = ThetaCyclePhase;
    InstCycleFrequency(peaks(i):peaks(i+1)) = 1/((peaks(i+1)-peaks(i))/fs);
    PerCycleFreq(i) = 1/((peaks(i+1)-peaks(i))/fs);
end    
PerCycleFreq(PerCycleFreq == 0) = NaN;
end
