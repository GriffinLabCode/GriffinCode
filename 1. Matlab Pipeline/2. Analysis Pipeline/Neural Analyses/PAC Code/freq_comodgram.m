function [phase_map_var,M,amplitude_highpass] = phase_comodgram(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plot)

%   This function creates a co-modulogram of normalized amplitude values
%   across phase bins. 

% Input: 
%   signal_data:            Structure with fields timestamps, phase_EEG, amplitude_EEG,
%                           phase_bandpass, amplitude_bandpass, srate, and
%                           phase_extraction
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
%   phase_extraction:       0 = Hilbert transform, 1 = Phase interpolation,
%                           2 = Morlet wavelet

%   phase_bins:             Number of phase bins
%   amplitude_freq_bins:    Number of co-modulogram bins for amplitude
%                           values
%   phase_freq_bins:        Number of co-modulogram bins for phase values
%   plot:                   0 if plot, 1 if no plot

%Output:
%   phase_map:          Co-modulogram of normalized amplitude values across phase bins

%%

% Define bandpass filter parameters based on phase frequency and amplitude
% frequency bins
phase_lowpass = (signal_data.phase_bandpass(:,1):phase_freq_bins:(signal_data.phase_bandpass(:,2))-phase_freq_bins);
phase_highpass = ((signal_data.phase_bandpass(:,1))+phase_freq_bins:phase_freq_bins:signal_data.phase_bandpass(:,2));
amplitude_lowpass = (signal_data.amplitude_bandpass(:,1):amplitude_freq_bins:(signal_data.amplitude_bandpass(:,2))-amplitude_freq_bins);
amplitude_highpass = ((signal_data.amplitude_bandpass(:,1))+amplitude_freq_bins:amplitude_freq_bins:signal_data.amplitude_bandpass(:,2));

% Grab normalized amplitude values for each amplitude frequency for each
% filtered signal
% Combine phase-amplitude co-modulograms for each signal into 3-d matrix
for freqPhasei = 1:length(phase_lowpass)
    for freqPoweri = 1:length(amplitude_lowpass)
        signal_data.phase_bandpass = [phase_lowpass(freqPhasei) phase_highpass(freqPhasei)];
        signal_data.amplitude_bandpass = [amplitude_lowpass(freqPoweri) amplitude_highpass(freqPoweri)];
        
        if signal_data.phase_extraction == 0 || signal_data.phase_extraction == 1
            [data] = makedatafile(signal_data);
        elseif signal_data.phase_extraction == 2
            [data] = makedatafile_morlet(signal_data);
        end
        data.srate = data.FS;
        
        plotMod = 'n';
        shuffle = 'n';
        [M] = modindex(data,plotMod,phase_bins,shuffle);
        
        phase_map_temp(freqPoweri,1:phase_bins) = M.NormAmp;
        
    end
    
    % average across theta frequencies for a phase comodulogram
    phase_map_var(:,:,freqPhasei) = phase_map_temp;
    
end

% Average co-modulogram values across all frequencies for phase
phase_map_var = mean(phase_map_var,3);

if plot == 0
figure()
pcolor(M.PhaseAxis,amplitude_highpass,phase_map_var)
colormap(jet)
shading 'interp'
ylabel('Frequency for Amplitude (Hz)')
xlabel('Phase')

end



end

