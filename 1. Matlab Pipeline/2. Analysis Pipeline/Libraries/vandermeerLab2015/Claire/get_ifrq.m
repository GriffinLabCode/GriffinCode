function [smooth_ifrq] = get_ifrq(csc)
% Get (smoothed) instantaneous frequency in theta band 
% Use the raw LFPs and then restrict afterwards (using all_ivs)

%% Filter to get theta frequencies

cfg=[];
cfg.type = 'cheby1';
cfg.order = 3; % filter order;
cfg.display_filter = 0; % show output of fvtool on filter
cfg.bandtype = 'bandpass'; % 'highpass', 'lowpass'
cfg.R = 0.25; % passband ripple (in dB) for Chebyshev filters only
cfg.f = [7 10]; %filter range to use (in Hz)

csc_filt = FilterLFP(cfg,csc);

%% Apply hilbert and get instantaneous frequency

Fs = csc.cfg.hdr{1}.SamplingFrequency;
z = hilbert(csc_filt.data);

ifrq.data = Fs/(2*pi)*diff(unwrap(angle(z)));
ifrq.tvec = csc.tvec(2:end);

% Remove non theta values

ifrq.data=ifrq.data(ifrq.data>2&ifrq.data<15);
ifrq.tvec=ifrq.tvec(ifrq.data>2&ifrq.data<15);

% Smooth
smooth_win=0.125; %in s

smooth_ifrq=ifrq;
smooth_ifrq.data=smooth(ifrq.data,smooth_win*2000); 

% figure;
% plot(csc.tvec,rescale(csc.data,-5,0))
% hold on;
% plot(ifrq.tvec,ifrq.data)
% plot(smooth_ifrq.tvec,smooth_ifrq.data)

smooth_ifrq=tsd(smooth_ifrq.tvec,smooth_ifrq.data');

end

