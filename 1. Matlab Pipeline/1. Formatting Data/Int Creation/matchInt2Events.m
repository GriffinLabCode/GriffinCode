%% matchInt2Events
% this code was designed to organize the Int file data based on the event
% strings. Sometimes, we start recording only to find that we need to stop
% recording and restart. If you don't shut down cheetah, then re-open, but
% instead hit 'Stop recording' then 'Start Recording', your Int file will
% not reflect this. In other words, your Int file is blind to this process,
% so if the rat ran 5 trials on recording #1, then you stop/start and 10
% minutes passes, the Int file will see trial 6 as coming directly after
% trial 5. This is problematic if you want to see how behaviors on one
% trial affected behaviors on another trial.
%
% >>> This code corrects for that problem <<<
%
% -- INPUTS -- %
% datafolder: name of datafolder
% int_name: name of Int file
% events_name: name of events
%
% -- OUTPUTS -- %
% IntEvents: A cell array containing Int file organized by event strings.
%
%
% ***** IF you want an example *****
% datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Ratdle\Baseline\Baseline 2';
% int_name = 'Int_2022;
% events_name = 'Events2';
%
% written by John Stout

function [IntEvents] = matchInt2Events(datafolder,int_name,events_name)

    % change directory to datafolder
    cd(datafolder)

    % load Int file of interest
    load(int_name);
    
    % load events and separate LFP based on the event markers
    load(events_name,'EventStrings','TimeStamps');
    evStarts = find(contains(EventStrings,'Starting Recording')==1);
    evEnds   = find(contains(EventStrings,'Stopping Recording')==1);
    evEdges  = [TimeStamps(evStarts);TimeStamps(evEnds)]';

    % loop across evnt markers
    IntEvents = [];
    for i = 1:size(evEdges,1)

         % identify timestamps to keep
         idxKeep = [];
         idxKeep = find(Int(:,1) >= evEdges(i,1) & Int(:,8) <= evEdges(i,2));

         % linspacing this works great as long as you do not have multiple
         % starting recording epochs
         IntEvents{i} = Int(idxKeep,:);
    end
    
    % now make sure something weird didn't happen
    tempCheck = cellfun(@size,IntEvents,'UniformOutput',false);
    sumCheck = sum(vertcat(tempCheck{:}));
    sanityCheck = sumCheck(1) == size(Int,1);
    
    if sanityCheck == 0
        disp('POTENTIAL ERROR! The sum of Int files does not match the actual Int file')
        disp('PLEASE INSPECT THIS DATA MANUALLY to pick out which Int to include')
    end
    
    
    