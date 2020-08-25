function [bin_centers,counts] = spikePETH(cfg_in,S,evt)
% function [bin_centers,counts] = spikePETH(cfg,S,evt)
%
% S and evt should be ts with only one cell
%
% ISSUE: output does not bin centers correctly

cfg_def.window = [-2 5]; % in seconds
cfg_def.dt = 0.01; % in seconds
cfg_def.excessBounds = 1;
cfg_def.outputGrid = 0;

cfg = ProcessConfig2(cfg_def,cfg_in);


nT = length(evt.t{1}); % currently assumes only one set of events given

outputS = [];
outputT = [];
bin_centers = linspace(cfg.window(1), cfg.window(2), diff(cfg.window)/cfg.dt+1);

for iT = 1:nT
	
    % restrict spikes to window around current event
	S0 = restrict(S,evt.t{1}(iT)+cfg.window(1)-cfg.excessBounds,evt.t{1}(iT)+cfg.window(2)+cfg.excessBounds);
	if length(S0.t) > 0

		S0 = restrict(S0,evt.t{1}(iT)+cfg.window(1),evt.t{1}(iT)+cfg.window(2));
		
		outputT = [outputT; repmat(iT,length(S0.t{1}),1)];
		outputS = [outputS; S0.t{1}-evt.t{1}(iT)];
        
	end
end

counts = histc(outputS, bin_centers);
if nargout == 0
	% display
	clf
	
	subplot(2,1,1);
	plot(outputS, outputT+0.5, 'k.', 'MarkerSize', 5);
	xlabel('peri-event (sec)');
	ylabel('Event #');
	
	%
	subplot(2,1,2);
	bar(bin_centers,counts/cfg.dt/length(evt.t{1})); % not actually bin centers - need to convert

	set(gca, 'XLim', cfg.window);
	ylabel('FR (Hz)')
	xlabel('peri-event (sec)');
end

