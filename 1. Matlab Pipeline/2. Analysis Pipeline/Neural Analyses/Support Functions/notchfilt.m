%% notch filter
% these methods were updated to allow easy replication. They were taken
% from the recent James Hyman lab paper
% https://www.nature.com/articles/s42003-021-02558-4.pdf
%

function [filtLFP] = notchfilt(lfp_data,Fs)
% use a notch filter to remove 60hz
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',Fs);                     
filtLFP = filtfilt(d,lfp_data);           
           
           