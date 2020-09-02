%% simple_pulse

%   This script emits TTL pulses in 30 second intervals, and records
%   timestamp data for TTL "on" and "off" periods

%   Output:
%       event_counter = 10 x 3 matrix, with rows corresponding to trials
%                       and columns corresponding to "off", "on", "off".
%                       TTL was "off" between timestamp values in columns 1
%                       and 2, TTL was "on" between timestamp values in
%                       columns 2 and 3, and TTL was "off" again between
%                       timestamp values in columns 3 and 1 of the next row

%%

% Connect to NetCom server
serverName = '128.175.182.250';
if NlxAreWeConnected() ~= 1
    succeeded = NlxConnectToServer(serverName);
    if succeeded ~= 1
        error('FAILED to connect');
        return;
    else
        display('Connected to NetCom Server');
    end
end

% Get VT timestamps
% It may make more sense to grab CSC timestamps instead
NlxOpenStream('VT1');

% Grab current VT timestamp and wait 30 seconds
% Grab current VT timestamp, turn the laser on, and wait another 30 seconds
% Grab current VT timestamp, turn the laser off, and wait another 30
% seconds
for i = 1:10
    [~, timeStampArray, ~, ~, ~, ~] = NlxGetNewVTData('VT1');
    event_counter(i,1) = timeStampArray(1,end);
    pause(30);
    NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2');
    [~, timeStampArray, ~, ~, ~, ~] = NlxGetNewVTData('VT1');
    event_counter(i,2) = timeStampArray(1,end);
    display('Laser On');
    pause(30);
    NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0');
    [~, timeStampArray, ~, ~, ~, ~] = NlxGetNewVTData('VT1');
    event_counter(i,3) = timeStampArray(1,end);
    display('Laser Off');
    pause(30);
end

clear timeStampArray succeeded serverName 