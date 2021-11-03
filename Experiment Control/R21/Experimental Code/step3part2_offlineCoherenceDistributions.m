clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-15';
rats{5} = '21-16';
rats{6} = '21-21';
rats{7} = '21-22';

for i = 1:length(rats)
    try
        cd(['C:\Users\jstout\Desktop\Data 2 Move\',rats{i},'\step3-definingCoherenceThresholds']);
        dataIN{i,:} = load(['CoherenceDistribution',rats{i}],'coh');
    end
end

for i = 1:length(dataIN)
    cohData{i} = dataIN{i}.coh;
end

data       = cohData;
xRange     = [0:.05:1];
colors{1}  = [1 0 1]; colors{2} = [1 0.3 1]; colors{3} = [1 .5 1];
colors{4}  = [0 0 1]; colors{5} = [0 .3 1]; colors{6} = [0 .5 1]; colors{7} = [0 .8 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);

rat = 1;
figure;
subplot 211;
histogram(data{rat});
xlim([0 1])
subplot 212;
plot(xRange,y{rat},'r');

%% what if I do like Fernandez ruiz et al 2019, and test whether coherence events are changed
% when memory is at play?

% so I need to get rats performing the CA task and eating on all trials











