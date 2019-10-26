function [data] = makedatafile(signal_data)

%   This function creates a structural array that contains phase and
%   amplitude values for two filtered signals. Phase values are extracted 
%   via either Hilbert transformation or by phase interpolation between 
%   peaks, troughs, and zero crossings. Amplitude envelopes are extracted 
%   via Hilbert transformation. This function is useful when high temporal 
%   resolution is not necessary (i.e., calculating an average modulation 
%   index value for a specific trial).

% Input:   
%   signal_data:            Structure with fields timestamps, phase_EEG, amplitude_EEG,
%                           phase_bandpass, amplitude_bandpass, srate, and phase_extraction
%
%   timestamps:             1 x n data points array of timestamp values
%                           (microseconds)
%   phase_EEG:              1 x n data points array of continuously sampled data
%                           from signal containing phase information
%   amplitude_EEG:          1 x n data points array of continuously sampled
%                           data from signal containing amplitude information
%   phase_bandpass:         Frequency band for filtering the phase signal
%                           ([fmin fmax])
%   amplitude_bandpass:     Frequency band for filtering the amplitude
%                           signal ([fmin fmax])
%   srate:                  Sampling rate (Hz)
%   phase_extraction:       Phase extraction method - binary, takes values of 0 or 1
%                           If phase_extraction = 0, Hilbert transformation
%                           is used
%                           If phase_extraction = 1, phase interpolation is
%                           used
%                           Phase interpolation accounts for asymmetries
%                           within an oscillatory cycle, but should only be used
%                           when the phase highpass is < 60 Hz

% Output:
%   data:                   Structural array containing phase and amplitude
%                           information for two filtered signals (used as
%                           input in "modindex.m")

%%
if signal_data.phase_extraction ~= 1 & signal_data.phase_extraction ~= 0
    error ('Phase_extraction value must be either a 0 or 1');
end

data.FS = signal_data.srate;
data.ADChannel = 64;

data.T = signal_data.timestamps;
data.X = signal_data.phase_EEG;

% Filter phase and amplitude signals
data.Xt = skaggs_filter_var(signal_data.phase_EEG,signal_data.phase_bandpass(:,1),signal_data.phase_bandpass(:,2),signal_data.srate);
data.Xg = skaggs_filter_var(signal_data.amplitude_EEG,signal_data.amplitude_bandpass(:,1),signal_data.amplitude_bandpass(:,2),signal_data.srate);

% Extract phase using either the Hilbert transform or phase extrapolation
if signal_data.phase_extraction == 0
    data.Xt_hil = hilbert(data.Xt);
    data.Xt_phase = angle(data.Xt_hil)*(180/pi)+180;
elseif signal_data.phase_extraction == 1
    [Phase, InstCycleFrequency, PerCycleFreq, signal_filtered] = phase_freq_detect(data.Xt,data.T,signal_data.phase_bandpass(:,1),signal_data.phase_bandpass(:,2),signal_data.srate);
    data.Xt_phase = Phase';
end

% Extract amplitude information with Hilbert transform
data.Xg_hil = hilbert(data.Xg);
data.Xg_env = abs(data.Xg_hil);
hilbert_phase = hilbert(data.Xt);
data.Xt_env = abs(hilbert_phase);

data.Xt_freq = diff(data.Xt_phase)./diff(data.T);


end