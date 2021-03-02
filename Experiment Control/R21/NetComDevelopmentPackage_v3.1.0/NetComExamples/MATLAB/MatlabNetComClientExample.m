%MatlabNetComClient example script.
%Connects to a server, streams some data into plots, then exits.
%
%Note: If you have any questions about any of the functions in the
%MatlabNetComClient package, you can type help <function_name> at the
%MATLAB command prompt.
%
%Load NetCom into MATLAB, and connect to the NetCom server
%If you are running MATLAB on a PC other than the one with the NetCom
%server, you will need to change the server name to the name of the server
%PC.
serverName = 'localhost';
fprintf('Connecting to %s...', serverName);
succeeded = NlxConnectToServer(serverName);
if succeeded ~= 1
    fprintf('FAILED to connect. Exiting script.\n');
    return;
else
    fprintf('Connect successful.\n');
end

serverIP = NlxGetServerIPAddress();
fprintf('Connected to IP address: %s\n', serverIP);

serverPCName = NlxGetServerPCName();
fprintf('Connected to PC named: %s\n', serverPCName);

serverApplicationName = NlxGetServerApplicationName();
fprintf('Connected to the NetCom server application: %s\n', serverApplicationName);

%Identify this program to the server we're connected to.
succeeded = NlxSetApplicationName('My Matlab Script');
if succeeded ~= 1
    fprintf('FAILED to set the application name\n');
end

%get a list of all objects in the DAS, along with their types.
[succeeded, dasObjects, dasTypes] = NlxGetDASObjectsAndTypes;
if succeeded == 0
    fprintf('FAILED get DAS objects and types\n');
else
    fprintf('Retrieved %d objects from the DAS\n', length(dasObjects));
end

%open up a stream for all objects that can stream date
for index = 1:length(dasObjects)
    %beginning in Cheetah 5.7.0 and Pegasus 2.0.0, the AcqSource data type
    %was included in the DAS object list. AcqSource objects cannot stream
    %data, but can be used to control the DAS
    if strcmp(char(dasTypes(index)), 'AcqSource') ~= 1 
        succeeded = NlxOpenStream(dasObjects(index));
        if succeeded == 0
            fprintf('FAILED to open stream for %s\n', char(dasObjects(index)));
            break;
        end
    end
end;
if succeeded == 1
    fprintf('Streams opened for all streaming DAS objects\n');
end

%example of how to use command replies, -GetDASState requires 
%Cheetah v5.7.0 or Pegasus v2.0.0 or newer. You can use NlxSendCommand
%to send any command to the DAS.
[succeeded, reply] = NlxSendCommand('-GetDASState');
if succeeded == 0
    fprintf('Failed to get DAS state\n');
else
    if strcmp(reply, 'Idle') == 1
        [succeeded, ~] = NlxSendCommand('-StartAcquisition');
        if succeeded == 0
            fprintf('Failed to start acquisition\n');
        end
    end
end

%This loop is run to get new data from NetCom.  All open streams must be
%serviced regularly, or there will be dropped records.
numberOfPasses = 4;
for pass = 1:numberOfPasses
    
    %You can optionally check to see if you are still connected to the
    %server and attempt a reconnection.
    if NlxAreWeConnected == 0
        fprintf('Connection to %s was lost. Attempting reconnection...', serverName);
        succeeded = NlxConnectToServer(serverName);
        if succeeded ~= 1
            fprintf('FAILED to reconnect. Exiting script.\n');
            return;
        else
            fprintf('Reconnect successful.\n');
        end
    end
    
    %send out an event so that there is something in the event buffer when
    %this script queries the event buffer
    [succeeded, ~] = NlxSendCommand('-PostEvent "Test Event" 10 11');
    if succeeded == 0
        fprintf('FAILED to send -PostEvent command.\n');
    end
    
    for objectIndex = 1:length(dasObjects)
        objectToRetrieve = char(dasObjects(objectIndex));
        %determine the type of acquisition entity we are currently indexed
        %to and call the appropriate function for that type
        if strcmp('CscAcqEnt', char(dasTypes(objectIndex))) == 1
            [succeeded,dataArray, timeStampArray, channelNumberArray, samplingFreqArray, numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData(objectToRetrieve);
            if succeeded == 0
                fprintf('FAILED to get new data for CSC stream %s on pass %d\n', objectToRetrieve, pass);
                break;
            else
                fprintf('Retrieved %d CSC records for %s with %d dropped.\n', numRecordsReturned, objectToRetrieve, numRecordsDropped);
                
                %Here is where you can perform some calculation on any of 
                %the returned values. Make sure any calculations done here
                %don not take too much time, otherwise NetCom will back up 
                %and you will have dropped records
                plot(dataArray);
            end
        %The test and actions are repeated for each acquisition entity type
        elseif strcmp('SEScAcqEnt', char(dasTypes(objectIndex))) == 1
            [succeeded, dataArray, timeStampArray, spikeChannelNumberArray, cellNumberArray, featureArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewSEData(objectToRetrieve);
            if succeeded == 0
                 fprintf('FAILED to get new data for SE stream %s on pass %d\n', objectToRetrieve, pass);
                break;
            else
                fprintf('Retrieved %d SE records for %s with %d dropped.\n', numRecordsReturned, objectToRetrieve, numRecordsDropped);
                plot(dataArray);
            end
        elseif strcmp('STScAcqEnt', char(dasTypes(objectIndex))) == 1
            [succeeded, dataArray, timeStampArray, spikeChannelNumberArray, cellNumberArray, featureArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewSTData(objectToRetrieve);
            if succeeded == 0
                 fprintf('FAILED to get new data for ST stream %s on pass %d\n', objectToRetrieve, pass);
                break;
            else
                fprintf('Retrieved %d ST records for %s with %d dropped.\n', numRecordsReturned, objectToRetrieve, numRecordsDropped);
                plot(dataArray);
            end
         elseif strcmp('TTScAcqEnt', char(dasTypes(objectIndex))) == 1
            [succeeded, dataArray, timeStampArray, spikeChannelNumberArray, cellNumberArray, featureArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewTTData(objectToRetrieve);
            if succeeded == 0
                 fprintf('FAILED to get new data for TT stream %s on pass %d\n', objectToRetrieve, pass);
                break;
            else
                fprintf('Retrieved %d TT records for %s with %d dropped.\n', numRecordsReturned, objectToRetrieve, numRecordsDropped);
                plot(dataArray);
            end
         elseif strcmp('EventAcqEnt', char(dasTypes(objectIndex))) == 1
            [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData(objectToRetrieve);
            if succeeded == 0
                 fprintf('FAILED to get new data for event stream %s on pass %d\n', objectToRetrieve, pass);
                break;
            else
                fprintf('Retrieved %d event records for %s with %d dropped.\n', numRecordsReturned, objectToRetrieve, numRecordsDropped);
                for recordIndex=1:numRecordsReturned                
                    fprintf('Event String: %s Event ID: %d TTL Value: %d\n',char(eventStringArray(recordIndex)), eventIDArray(recordIndex), ttlValueArray(recordIndex));
                end
            end
         elseif strcmp('VTAcqEnt', char(dasTypes(objectIndex))) == 1
            %NOTE: Pegasus does not stream data for VTAcqEnt objects since
            %no video tracking is performed
            [succeeded,  timeStampArray, extractedLocationArray, extractedAngleArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewVTData(objectToRetrieve);
            if succeeded == 0
                 fprintf('FAILED to get new data for VT stream %s on pass %d\n', objectToRetrieve, pass);
                break;
            else
                fprintf('Retrieved %d VT records for %s with %d dropped.\n', numRecordsReturned, objectToRetrieve, numRecordsDropped);
               plot(extractedLocationArray);
            end   
        end
    end
   
    if succeeded == 0
        break;
    end
end
if succeeded == 0
    fprintf('FAILED to get data consistently for all open streams\n');
end

[succeeded, ~] = NlxSendCommand('-StopAcquisition');
if succeeded == 0
    fprintf('Failed to stop acquisition\n');
end

%close all open streams before disconnecting
for index = 1:length(dasObjects)
     if strcmp(char(dasTypes(index)), 'AcqSource') ~= 1 
        succeeded = NlxCloseStream(dasObjects(index));
        if succeeded == 0
            fprintf('FAILED to close stream for %s\n', char(dasObjects(index)));
        end
     end
end;

%Disconnects from the server and shuts down NetCom
succeeded = NlxDisconnectFromServer();
if succeeded ~= 1
    fprintf('FAILED disconnect from server\n');
else
    fprintf('Disconnected from %s\n', serverName);
end

%remove all vars created in this test script
clear
    