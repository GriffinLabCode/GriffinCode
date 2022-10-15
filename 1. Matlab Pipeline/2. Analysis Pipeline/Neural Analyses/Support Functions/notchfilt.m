%% notch filter
% these methods were updated to allow easy replication. They were taken
% from the recent James Hyman lab paper
% https://www.nature.com/articles/s42003-021-02558-4.pdf
%

function [filtLFP] = notchfilt(lfp_data,Fs,fpass)

if exist('fpass')==0
    % default fpass
    fpass = [55 65];
    disp('Defaulting fpass to 55-65Hz - change if necessary')
end

% redefine bandpass filtering variables
lowPass = fpass(1);
highPass = fpass(2);
diffPass = fpass(2)-fpass(1);

% use a notch filter to remove 60hz
d = designfilt('bandstopiir','FilterOrder',diffPass, ...
               'HalfPowerFrequency1',lowPass,'HalfPowerFrequency2',highPass, ...
               'DesignMethod','butter','SampleRate',Fs);                     
filtLFP = filtfilt(d,lfp_data);           
           
           