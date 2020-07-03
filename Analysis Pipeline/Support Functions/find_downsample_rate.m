%% find_downsample_rate
%
% this function estimates a value that can be used to downsample and reach
% your target of interest, based on your input. This only works under
% specific conditions where rounding isn't necessary.
%
% INPUTS
% current_rate: the current sampling rate of your data
% target_rate: the new wanted sampling rate
%
% OUTPUTS
% divisor: a value that can be used to downsample your data. For example,
%          if your sampling rate is 2000 and you want it to be 250, this
%          function will return a divisor output of 8. If your signal
%          variable is signalx, you can do the following:
%          signalx(1:divisor:end) and it should down-sample your data to
%          what you wanted
%
% written by John Stout


function [divisor] = find_downsample_rate(current_rate,target_rate)

% loop across your sampling rate and stop when you've reach the new target
ds_rates = [];
for n = 1:current_rate
    ds_rates(n) = current_rate/n;
    if ds_rates(n) == target_rate
        divisor = n;
        continue
    end
end

end