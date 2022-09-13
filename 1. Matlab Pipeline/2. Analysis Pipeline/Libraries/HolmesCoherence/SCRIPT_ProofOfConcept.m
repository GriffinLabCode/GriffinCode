% load in data 2 play with
load('data4PhaseCoherenceDemonstration')

% reformat data
timeSeries = dataPlay;
timeSeries2(1,:) = dataPlay(1,:);
timeSeries2(2,:) = dataPlay(1,:); % erase -1* to demonstrate the validity of this code

% phase coherence
FS = 2000;
freq = 8;
PC = PhaseCoherence(freq, timeSeries2, FS);

% figure demonstration
figure('color','w'); hold on;
plot(timeSeries2(1,:),'k','LineWidth',2);
plot(timeSeries2(2,:),'r');
title(['Phase Coherence = ',num2str(PC)])
legend('Signal 1','Signal 1')

% -- invert data to make 180degrees out of sync -- %
timeSeries2(2,:) = -1*dataPlay(1,:); % erase -1* to demonstrate the validity of this code

% phase coherence
FS = 2000;
freq = 8;
PC = PhaseCoherence(freq, timeSeries2, FS);

% figure demonstration
figure('color','w'); hold on;
plot(timeSeries2(1,:),'k');
plot(timeSeries2(2,:),'r');
title(['Phase Coherence = ',num2str(round(PC))])
legend('Signal 1','Signal 1 inverted 180deg')
