function [tfZ, tf_smooth] = morlet_spectrogram(sample, srate, lowpass, highpass, plot)

%   This function creates a spectrogram from morlet wavelet convolution

%   Input:
%       sample:     1 x n samples array of continuously sampled data
%       srate:      Sampling rate (Hz)
%       lowpass:    fmin
%       highpass:   fmax
%       plot:       0 if plot, 1 if no plot

%   Output:
%       tfZ:        n frex x n samples matrix of z-scored wavelet amplitude
%                   values
%       tf_smooth:  Smoothed spectrogram

%%

min_freq = lowpass;
max_freq = highpass;
num_frex = (highpass-lowpass)+1;

Ldata  = length(sample);
Ltapr  = length(sample);
Lconv1 = Ldata+Ltapr-1;
Lconv  = pow2(nextpow2(Lconv1));
frex=lowpass:highpass;

tf=zeros(num_frex,length(sample));
datspctra = fft(sample,Lconv);
s=4./(2*pi.*frex);
t=-((length(sample)-1)/2)/srate:1/srate:((length(sample)-2)/2)/srate+1/srate;

for fi=1:length(frex);
wavelet=exp(2*1i*pi*frex(fi).*t).*exp(-t.^2./(2*s(fi)^2));
m = ifft(datspctra.*fft(wavelet,Lconv),Lconv);
m = m(1:Lconv1);
m = m(floor((Ltapr-1)/2):end-1-ceil((Ltapr-1)/2));
tf(fi,:) = abs(m).^2;
end

tfZ = zscore(tf);
times = linspace(0,(length(sample))/srate,length(sample));

[X,Y] = meshgrid(round(-size(tfZ,1)/2):round(size(tfZ,1)/2), round(-size(tfZ,2)/2):round(size(tfZ,2)/2));
f = exp(-X.^2/(2*1.5^2)-Y.^2/(2*1.5^2));
f = f./sum(f(:));

tf_smooth = conv2(tfZ,f,'same');

if plot == 0
figure()
PowerPlot = flipud(tf_smooth);
imagesc(times,flipud(frex),PowerPlot)
box off
set(gca,'TickDir','out')
colormap(jet)
ylabel('Frequency (Hz)')
xlabel('Time (Seconds)')
end




end

