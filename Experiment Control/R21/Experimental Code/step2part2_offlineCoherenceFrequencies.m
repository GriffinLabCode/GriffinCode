%% defining coherence range
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
        cd(['C:\Users\jstout\Desktop\Data 2 Move\',rats{i},'\step2-definingCoherenceFrequency']);
        dataIN{i,:} = load('step2_definingCoherenceFrequencies');
    end
end

for i = 1:length(dataIN)
    cohData{i} = dataIN{i}.avgCoh;
end
cohMat = vertcat(cohData{:});

% plot data
cohAvg = nanmean(cohMat);
cohSer = stderr(cohMat,1);
fcoh   = dataIN{1}.fcoh;

figure('color','w')
shadedErrorBar(fcoh,cohAvg,cohSer,'k',1)
box off
ylabel('Averaged coherence (N = 7 rats)')
xlabel('Frequency')
title('6-12hz = theta')

% what if data is normalized before averaging
cohNorm = normalize(cohMat','range')';

% plot data
cohAvg = nanmean(cohNorm);
cohSer = stderr(cohNorm,1);
fcoh   = dataIN{1}.fcoh;

figure('color','w')
shadedErrorBar(fcoh,cohAvg,cohSer,'k',1)
box off
ylabel('Averaged normalized coherence (N = 7 rats)')
xlabel('Frequency')
title('6-12hz = theta')

%% save here
cd('C:\Users\jstout\Desktop\Data 2 Move\Data driven definitions')


