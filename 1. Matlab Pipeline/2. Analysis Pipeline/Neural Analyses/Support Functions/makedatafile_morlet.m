function [data] = makedatafile_morlet(signal_data)

%   This function creates a structural array that contains phase and
%   amplitude values for two filtered signals. Phase and amplitude values 
%   are extracted via Morlet wavelet. This function is useful when high 
%   frequency and temporal precision are necessary (i.e., when plotting 
%   amplitude in phase space).

% Input:   
%   signal_data:            Structure with fields timestamps, phase_EEG, amplitude_EEG,
%                           phase_bandpass, amplitude_bandpass, and srate
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

% Output:
%   data:                   Structural array containing phase and amplitude
%                           information for two filtered signals (used as
%                           input in "modindex.m")

%%

data.FS = signal_data.srate;
data.ADChannel = 64;

data.T = signal_data.timestamps;
data.X = signal_data.phase_EEG;

% Create phase and power bandpass filter parameters for wavelet
phase = [signal_data.phase_bandpass(:,1) signal_data.phase_bandpass(:,2)];
power = [signal_data.amplitude_bandpass(:,1) signal_data.amplitude_bandpass(:,2)];

phase_frequency = mean(phase);
power_frequency = mean(power);

% Extract phase and power from wavelet convolution
time = -1:1/signal_data.srate:1;
s_phase = 4/(2*pi*phase_frequency)^2;
s_power = 4/(2*pi*power_frequency)^2;
wavelet_phase = exp(2*1i*pi*phase_frequency.*time) .* exp(-time.^2./(2*s_phase)/phase_frequency);
wavelet_power = exp(2*1i*pi*power_frequency.*time) .* exp(-time.^2./(2*s_power)/power_frequency);

n_wavelet            = length(wavelet_phase);
n_data               = length(signal_data.phase_EEG);
n_convolution        = n_wavelet+n_data-1;
half_of_wavelet_size = (length(wavelet_phase)-1)/2;

fft_wavelet_phase = fft(wavelet_phase,n_convolution);
fft_wavelet_power = fft(wavelet_power,n_convolution);
fft_phase         = fft(signal_data.phase_EEG,n_convolution);
fft_amplitude     = fft(signal_data.amplitude_EEG,n_convolution);

convolution_result_fft_phase = ifft(fft_wavelet_phase.*fft_phase,n_convolution) * sqrt(s_phase);
convolution_result_fft_power = ifft(fft_wavelet_power.*fft_amplitude,n_convolution) * sqrt(s_power);

convolution_result_fft_phase = convolution_result_fft_phase(half_of_wavelet_size+1:end-half_of_wavelet_size);
convolution_result_fft_power = convolution_result_fft_power(half_of_wavelet_size+1:end-half_of_wavelet_size);

data.Xt = real(convolution_result_fft_phase);
data.Xg = real(convolution_result_fft_power);

data.Xt_hil = hilbert(data.Xt);
data.Xg_hil = hilbert(data.Xg);

data.Xt_env = abs(convolution_result_fft_phase);
data.Xg_env = abs(convolution_result_fft_power);

data.Xt_phase = angle(convolution_result_fft_phase)*(180/pi)+180;

data.Xt_freq = diff(data.Xt_phase)./diff(data.T);


end

