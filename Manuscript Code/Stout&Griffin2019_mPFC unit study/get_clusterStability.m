%% combine folders for cluster_stability
% this script combines Datafolders to plot more than just one folders worth
%
% make sure the nlx2spk functions are saved to the folders
%
% written by John Stout
clear; clc

% add directory with cluster_stability function to path
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Cluster Stability')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat');

% define two folders to combine
Datafolders1 = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';

% define window of time for stability assessment
time_window = 10; % minutes

% run function
[neuron1, pre_peak_data1, post_peak_data1] = cluster_stability(Datafolders1,time_window);

% concatenate neuron variable
post_peaks = post_peak_data1;
pre_peaks = pre_peak_data1;


figure('color',[1 1 1]);
scatter(pre_peaks,post_peaks,'k')
%Y = ['Mean peak voltage (uv) first ',num2str(time_window),' minutes'];
%ylabel(Y);
%X = ['Mean peak voltage (uv) last ',num2str(time_window),' minutes'];
%xlabel(X);
box off
hold on;
coeffs = polyfit(pre_peaks, post_peaks, 1);
% Get fitted values
fittedX = linspace(min(pre_peaks), max(pre_peaks), 188);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, 'r', 'LineWidth', 2); 
axis tight

[h,p]=corrcoef(pre_peaks,post_peaks)