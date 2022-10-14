%% cleaning up 60hz
% this code is meant to demonstrate the utility of a notchfilter for
% cleaning 60hz

% load in example dataset
load('data2clean')

% get some parameters for chronux
params = getCustomParams;
params.Fs = 2000; % sampling rate - i knew this about the data

figure('color','w');
subplot 321
    plot(tempLfpPlt_hpc)
    title('60Hz dominates!')
    ylabel('voltage - hpc')
subplot 323
    plot(tempLfpPlt_pfc)
    ylabel('voltage - pfc')
subplot 325; hold on;
    [p_pfc,f] = mtspectrumc(tempLfpPlt_pfc,params);
    [p_hpc,f] = mtspectrumc(tempLfpPlt_hpc,params);
    plot(f,log10(p_pfc),'k')
    plot(f,log10(p_hpc),'b')  
    legend('PFC','HPC','Location','SouthWest')
    ylabel('log10 pow.')
    xlabel('freq.')

% clean up with notchfilt
cleanHpc = notchfilt(tempLfpPlt_hpc,params.Fs);
cleanPfc = notchfilt(tempLfpPlt_pfc,params.Fs);
   
subplot 322
    plot(cleanHpc)
    title('no more 60hz')
subplot 324
    plot(cleanPfc)
subplot 326; hold on;
    [p_pfc,f] = mtspectrumc(cleanPfc,params);
    [p_hpc,f] = mtspectrumc(cleanHpc,params);
    plot(f,log10(p_pfc),'k')
    plot(f,log10(p_hpc),'b')  
    legend('PFC','HPC','Location','SouthWest')
    ylabel('log10 pow.')
    xlabel('freq.')    
    box off
