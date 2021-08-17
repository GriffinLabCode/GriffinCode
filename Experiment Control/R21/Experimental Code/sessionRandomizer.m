%% session randomizer
% this code was created to keep the users blind from the type of session
% being performed
clear; clc

% interface with user for accurate storage
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');
prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

% define the number of sessions you desire
numSessions = 8;

% this code randomizes sessions such that there will never be more than 3
% days in a row of one session type
blindedSessions = [];
for n = 1:3
    redo = 1;
    while redo == 1
        high  = repmat('H',[(numSessions/2) 1]);
        low   = repmat('L',[(numSessions/2) 1]);
        both  = [high; low];
        both_shuffled = both;
        for i = 1:1000
            % notice how it rewrites the both_shuffled variable
            both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
        end
        sessType_exp = cellstr(both_shuffled);

        % no more than 3 turns in one direction
        idxH = double(contains(sessType_exp,'H'));
        idxL = double(contains(sessType_exp,'L'));

        
        for i = 1:length(sessType_exp)-3
            if idxH(i) == 1 && idxH(i+1) == 1 && idxH(i+2) == 1 && idxH(i+3)==1
                redo = 1;
                break        
            elseif idxL(i) == 1 && idxL(i+1) == 1 && idxL(i+2) == 1 && idxL(i+3)==1
                redo = 1;
                break        
            else
                redo = 0;
            end
        end
    end

end
blindedSessions = vertcat(sessType_exp{:});

% save data
dataStored = 'C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\Rat Specific Inputs';
cd(dataStored)

% save with rat as first name and blindedSessionTypes as second
save(['blindedSessionTypes_' targetRat],'blindedSessions')

clear;
