% define number of trials
numTrials  = 100;

%% randomize delay durations
delayDur = 5:1:30; % 5-45 seconds
rng('shuffle')
delayLenTrial = randsample(delayDur,numTrials,'true');
delayLenTrial_og = delayLenTrial;
% update iwth what you have in new code in lab

% designate what 20% looks like
indicatorOUT = [];
for i = 1:10:100
    delays2pull = delayLenTrial(i:i+9);
    numExp = length(delays2pull)*.20;
    numCon = length(delays2pull)*.20;
    totalN = numExp+numCon;
    
    % randomly select which delay will be high and low
    %N1=1; N2=10;   % range desired
    %p=randperm(N1:N2);
        
    % high and low must happen before yoked
    next = 0;
    while next == 0
        idx = randperm(10,totalN);
        if idx(1) < idx(3) && idx(1) < idx(4) && idx(2) < idx(3) && idx(2) < idx(4)
            next = 1;
        end
    end
    
    % first is always high, second low, third, con h, 4 con L
    indicator = cellstr(repmat('Norm',[10 1]));
    
    % now replace
    indicator{idx(1)} = 'high';
    indicator{idx(2)} = 'low';
    indicator{idx(3)} = 'yokeH';
    indicator{idx(4)} = 'yokeL';
    
    % store indicator variable
    indicatorOUT = [indicatorOUT;indicator];

end    
    
% now replace old delays with NaN
find(contains(indicatorOUT,'yokeL')==1);

% open these for storing
yokH = []; yokL = [];
for triali = 1:numTrials
    if contains(indicatorOUT{triali},'Norm')
        disp(['Normal delay of ',num2str(delayLenTrial(triali))])
        pause(delayLenTrial(triali));
    elseif contains(indicatorOUT{triali},'high')
        cohStart = tic;  
        % coherence detection goes here
        
        cohEnd = toc(cohStart); 
        disp(['Coh detect high end at ', num2str(cohEnd)])
        
        % now replace the delayLenTrial with coherence delay
        delayLenTrial(triali) = cohEnd;
        
        % now identify yoked high, and replace with control delay
        yokH = [yokH delayLenTrial(triali)];
        %yokH_store = yokH;
        
    elseif contains(indicatorOUT{triali},'low')
        cohStart = tic;    
        % coherence detection goes here
        
        cohEnd = toc(cohStart);        
        disp(['Coh detect low end at ', num2str(cohEnd)])

        % now replace the delayLenTrial with coherence delay
        delayLenTrial(triali) = cohEnd;
        
        % now identify low yoked duration of delay
        yokL = [yokL delayLenTrial(triali)];
        %yokL_store = yokL;
        
    elseif contains(indicatorOUT{triali},'yokeL')
        % pause for yoked control
        disp(['Pausing for low yoked control of ',num2str(yokL(1))])
        pause(yokL(1));
        % delete so that next time, 1 is the updated delay
        yokL(1)=[];
        
    elseif contains(indicatorOUT{triali},'yokeH')
        disp(['Pausing for high yoked control of ',num2str(yokH(1))])
        
        pause(yokH(1));
        yokH(1)=[];
    end
end      
    
    