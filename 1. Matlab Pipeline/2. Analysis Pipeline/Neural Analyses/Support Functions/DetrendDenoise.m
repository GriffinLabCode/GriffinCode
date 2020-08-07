%% denoise/detrend
% This function provides an alternative approach to chronux detrend/denoise
% functions. It utilizes built in matlab functions and should therefore be
% faster. I've noticed that this approach works better to scrub the data of
% the 60Hz noise. I could have used the chronux functions wrong, but this
% approach is simple and easy. Additionally, this approach removes
% significant outliers in your dataset using Hampel Outlier Identification.
%
% ~~~ INPUTS ~~~
% Fs: the sampling frequency of your dataset
% y: your data in a 1-D format (ie 1xN vector)
%
% ~~~ OUTPUTS ~~~
% y_filt: detrended and denoised LFP data
%
% written by John Stout - last edit on 3/8/2020

function [y_filt] = DetrendDenoise(y,Fs)

    % first use the matlab detrend function to correct for trends in the data
    % (like the lfp drifting upwards or something)
    y_det = detrend(y);

    % design a filter - this was taken off of the matlab website
    d = designfilt('bandstopiir','FilterOrder',2, ...
                   'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
                   'DesignMethod','butter','SampleRate',Fs);
               
    % design a filter to filter out 300Hz noise - looked suspicious
    d2 = designfilt('bandstopiir','FilterOrder',2, ...
                   'HalfPowerFrequency1',299,'HalfPowerFrequency2',301, ...
                   'DesignMethod','butter','SampleRate',Fs); 
               
    % filter out the noise
    y_filtTemp = filtfilt(d,y);
    
    % filter out 300hz noise
    y_filt = filtfilt(d2,y_filtTemp);
    
    % remove significant outliers in your dataset
    y_filt = hampel(y_filt);

end
