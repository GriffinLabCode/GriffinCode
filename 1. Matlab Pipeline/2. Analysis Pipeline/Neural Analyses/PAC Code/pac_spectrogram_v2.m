%% PAC_spectogram
%
% Tort et al., 2010; measuring phase-amplitude coupling between neuronal
% oscillations of different frequencies
%
% -- INPUTS -- %
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
%   phase_bandwidth:        width of frequencies included (if
%                           phase_bandpass = [1 20] and bandiwdth set to 2,
%                           then you will get MI values between 1:2:20. so
%                           first, [1 3], then [3 5] and so on... default
%                           is 2
%   amplitude_bandwidth:    Width of frequencies included for amplitude
%                           signal. defualt is 10
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
%
% -- OUTPUTS -- %
% mod_matrix: a matrix that is NxM (row are amplitude frequencies and
%               columns and phase frequencies) with each element indicating
%               PAC modulation index estimates
%
% written by John Stout using Henry Hallock formatting 

function [mod_matrix] = pac_spectrogram(signal_data)

% for phase frequency, 2Hz steps with 4Hz bandwidths. For amplitude
% frequency, 5Hz steps with 10hz bandwidtsh (Tort et al., )
freq_phase = signal_data.phase_bandpass; %[1 20];
freq_amp   = signal_data.amplitude_bandpass; % [20 100];

% frequency steps
phaseStepper = 5; ampStepper = 5;
step_phase = freq_phase(1):phaseStepper:freq_phase(2);
step_amp   = freq_amp(1):ampStepper:freq_amp(2);

% bandwidth
%bw_phase = signal_data.phase_bandwidth; % 4;  % 4Hz
%bw_amp   = signal_data.amplitude_bandwidth; %10; % 10 hz

% loop across phase steps
mod_matrix = [];
for i = 1:length(step_phase)-1
    
    % define phase bandpass (2Hz step with 4Hz window)
    signal_data.phase_bandpass = [];
    signal_data.phase_bandpass = [step_phase(i) step_phase(i+1)];
    
    % loop across amplitude steps
    for ii = 1:length(step_amp)-1
        
        signal_data.amplitude_bandpass = [];
        signal_data.amplitude_bandpass = [step_amp(ii) step_amp(ii+1)];
    
        % make datafile
        signal_data.phase_extraction = 2;
        datafile = [];
        datafile = makedatafile_morlet(signal_data);
        datafile.srate = datafile.FS;
        
        % get pac
        M_out = [];
        M_out = modindex(datafile,'n','n',18); % 18 is the default
        
        % store data so that rows are amplitude frequencies and colums are
        % phase frequencies
        mod_matrix(ii,i) = M_out.MI;
        
    end
end

figure('color','w')
x = step_phase(1)+1:phaseStepper:step_phase(end);
y = step_amp(1)+1:ampStepper:step_amp(end);
pcolor(x,y,mod_matrix); % rows are amplitude freqs, col are phase freqs
%pcolor(x,y,mod_log)
colormap(jet)
shading 'interp'
ylabel('Frequency for Amplitude (Hz)')
xlabel('Phase')
colorbar
%caxis([0 .001])
