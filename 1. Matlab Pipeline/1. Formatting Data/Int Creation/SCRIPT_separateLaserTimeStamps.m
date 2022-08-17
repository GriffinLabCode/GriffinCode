%% SCRIPT - identifying blue/red laser and on/off timestamps
clear; clc;
disp('Make sure you run startup')
disp('Make sure you change directory to the datafolder of interest')
datafolder = pwd;
load('Events','EventStrings','TimeStamps')

% get ttl index
idxTTL = find(contains(EventStrings,'TTL')==1);

% clean up data - extract timestamps and events with ttls
eventTTLs      = EventStrings(idxTTL);
eventTimesTTLs = TimeStamps(idxTTL);

% string split to get red/blue on/off
clear splitEventTTLs
for i = 1:length(eventTTLs)
    splitEventTTLs(i,:) = strsplit(eventTTLs{i},'_');
end

% get red/blue
splitEventTTLs(:,1)=[];
 
% change me for accuracy - is 0 value red or blue?
laserRedIdx  = find(contains(splitEventTTLs,'0 value')==1);
laserBlueIdx = find(contains(splitEventTTLs,'2 value')==1);

% separate red/blue data
eventTTLred        = splitEventTTLs(laserRedIdx);
eventTTLblue       = splitEventTTLs(laserBlueIdx);
eventTTLred_times  = eventTimesTTLs(laserRedIdx);
eventTTLblue_times = eventTimesTTLs(laserBlueIdx);

% split data more to get on/off
laserRedONidx   = find(contains(eventTTLred,'0x0002')==1);
laserRedOFFidx  = find(contains(eventTTLred,'0x0000')==1);
laserBlueONidx  = find(contains(eventTTLblue,'0x0002')==1);
laserBlueOFFidx = find(contains(eventTTLblue,'0x0000')==1);

% use these index's to get timestamps
timesLaserRedON   = eventTTLred_times(laserRedONidx);
timesLaserRedOFF  = eventTTLred_times(laserRedOFFidx);
timesLaserBlueON  = eventTTLblue_times(laserBlueONidx);
timesLaserBlueOFF = eventTTLblue_times(laserBlueOFFidx);

% put into structure array for each session
dataLaserTimes.timesRedON   = timesLaserRedON;
dataLaserTimes.timesRedOFF  = timesLaserRedOFF;
dataLaserTimes.timesBlueON  = timesLaserBlueON;
dataLaserTimes.timesBlueOFF = timesLaserBlueOFF;

% make sure in datafolder and save
cd(datafolder);
save('dataLaserTimes','dataLaserTimes');


