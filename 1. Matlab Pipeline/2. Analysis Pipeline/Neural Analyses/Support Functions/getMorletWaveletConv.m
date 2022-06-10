%% Morlet wavelet convolution
%
% -- INPUTS -- %
% LFP: vector of type SINGLE. Double prob works though
% frex: frequency of wavelet
% Cycle: number of wavelet cycles. Should be between 4-12. Higher numbers
%           create wider wavelets in the time domain and narrower wavelets
%           in the frequency domain. Higher values = increased frequency
%           precision. Lower values = increase time precision.
% 
% -- OUTPUTS -- %
% as: analytical signal
%
% taken from MxC brain and cog sci by JS

function [as] = getMorletWaveletConv(lfp,frex,nCycle,srate)

% create wavelet
wavetime = -1:1/srate:1;
halfwave = floor(length(wavetime)/2)+1;
nData    = length(lfp);
nWave    = length(wavetime);
nConv    = nData + nWave - 1;
gausS    = nCycle / (2*pi*frex);
wavelet  = exp(2*1i*pi*frex*wavetime + (-wavetime.^2)/(2*gausS^2) );
waveletX = fft(wavelet,nConv);
waveletX = waveletX./max(waveletX);

% as = the analytic signal; the result of convolution between LFP and a
% complex morlet wavelet
dataX = fft(lfp,nConv);
as = ifft( dataX .* waveletX );
% cut off edges
as = as(halfwave-1:end-halfwave);
