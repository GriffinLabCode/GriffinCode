%% control sample and choice counts
% this function controls for the number of sample and choice trials
%
% Int must have a 9th column that contains 1s where the trial
% needs eliminating


function [Int] = correct_taskphase_counts_nonsubsample(Int)
    %% remove any cases where sample and choice trials arent every other row
    
    % isolate the task-phase index
    taskphase_var = Int(:,10);
    
    % find times where there are two consecutive integers
    loc_multiples=(diff(taskphase_var == 1));
    idx_multiples=find(loc_multiples==0);
    taskphase_var2 = taskphase_var(idx_multiples);

    while isempty(idx_multiples)==0    
        for i = 1
            % if the multiple is a sample-trial, remove the run
            if taskphase_var2(i) == 0
                taskphase_var(idx_multiples(i),:)=[];
                Int(idx_multiples(i),:)=[];
                % remake
                loc_multiples=(diff(taskphase_var == 1));
                idx_multiples=find(loc_multiples==0);
                taskphase_var2 = taskphase_var(idx_multiples);
            % if the multiples is a choice-trial, remove the following run
            elseif taskphase_var2(i) == 1
                taskphase_var(idx_multiples(i)+1,:)=[];
                Int(idx_multiples(i)+1,:)=[];
                % remake
                loc_multiples=(diff(taskphase_var == 1));
                idx_multiples=find(loc_multiples==0);
                taskphase_var2 = taskphase_var(idx_multiples);           
            end
        end
    end 
    
    % if the first row is a choice run, remove it
    if Int(1,10)==1
        Int(1,:)=[];
    end
    
    % report to command window
    if Int(1,10)==1
        disp('error - Int format incorrect')
    elseif Int(end,10)==0
        disp('error - Int format incorrect')
    end
    
end