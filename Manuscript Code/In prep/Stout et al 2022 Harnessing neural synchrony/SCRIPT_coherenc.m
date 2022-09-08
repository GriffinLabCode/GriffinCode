%% Is mean squared coherence phase coherence??
load('data4coherenceDemonstration');

% get data
data1 = dataPlay(1,:);
data2 = dataPlay(2,:);

% invert data2
data1i = -1*data1;

% demonstrate that both signals are out of phase
data1filt  = skaggs_filter_var(data1,[6],[11],2000);
data1ifilt = skaggs_filter_var(data1i,[6],[11],2000);

% plot data
figure('color','w'); 
subplot 211; hold on;
    plot(data1,'k')
    plot(data1i,'r')
title('Identical signal - inverted')
subplot 212; hold on;
    plot(data1filt,'k')
    plot(data1ifilt,'r')
    
% mscohere
[c,f] = mscohere(data1,data1i,[],[],[1:.5:20],2000);
figure; plot(f,c)





