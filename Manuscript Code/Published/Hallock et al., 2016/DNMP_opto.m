%% DNMP_opto

% This code is used to send TTL pulses when the animal is at specific
% points on the T-maze during specific phases of the DNMP task.

% Indicate which type of session to run (which task phase to turn on the
% LED)
% 1 = sample, 2 = choice, 3 = whole trial; 4 = delay

sessiontype = 2;

%% Make sure that everything is set up correctly

prompt = 'Is Cheetah running? Y/N: ';
str = input(prompt,'s');
if str == 'N'
    error('Turn on the DigitalLynx power switch, and then open Cheetah');
end

prompt = 'Is the video tracker running? Y/N: ';
str = input(prompt,'s');
if str == 'N'
    error('Check the "intensity" box in the video tracker settings, and set the "intensity" value to "75"');
end

prompt = 'Is the acquisition computer''s IP address correct? Y/N: ';
str = input(prompt,'s');
if str == 'N'
    error('Open the "command prompt" from the start menu of the acquisition computer, type "ipconfig/all", and check the IPv4 [preferred] address beginning with 128.175. Enter this IP address into the "serverName" variable on line 83');
end

prompt = 'Is the Doric hardware running? Y/N: ';
str = input(prompt,'s');
if str == 'N'
    error('Turn the power switch of the Doric laser diode housing to the "on" position, that Doric software is running, and the "Set Mode" option is set to "External TTL"');
end

prompt = 'Is Cheetah output set to Port 00? Y/N; ';
str = input(prompt,'s');
if str == 'N'
    error('Open the "view" pull down menu in Cheetah, select "digital IO setup" and set Port 00 to "Output"');
end


%% Adjustable parameters

% Manually select which bins to shine laser
%SelectBINS = [37:95];

%Manually define regions of the maze

%Start box
XV_sb = [60 60 145 145 60];
YV_sb = [400 200 250 350 400];

%Stem
XV_stem = [160 160 370 370 160];
YV_stem = [330 310 320 350 330];

%Choice point
XV_cp = [370 410 410 370 370];
YV_cp = [300 300 380 380 300];

%Goal arms (Right and left)
XV_goal_r = [];
YV_goal_l = [];

%Stem and choice point
XV_t = [200 200 430 430 220];
YV_t = [315 290 230 400 315];

%Reward zones (Right and Left)
XY_rew_r = [];
XY_rew_l = [];

%Return arms (Right and left)
XV_ret_r = [];
YV_ret_l = [];


%% Establish connection to Cheetah

serverName = '128.175.182.96';
if NlxAreWeConnected() ~= 1
    succeeded = NlxConnectToServer(serverName);
    if succeeded ~= 1
        error('FAILED to connect');
        return;
    else
        display('Connected to NetCom Server');
    end
end



%% Identification of photobeams (for later development)

% 1 - Delay   0000000000000100
% 2 - Stem    0000000000000010
% 3 - Choice  0000000000100000
% 4 - LFood   0000000001000000
% 5 - RFood   0000000000010000
% 6 - LReturn 0000000010000000
% 7 - RReturn 0000000000001000

%% Stimulate based on position

NlxOpenStream('VT1'); %Open data stream of VT1(Video data)

InSelectedZone = 0; % Start by assuming animal is not within selected bins
InStemZone = 0;
InSBZone = 0;

phasei = 1; % Session starts with sample phase
pulse_counter = 0;


%%Test
% tic
% for jj = 1:1000000
%     [~, timeStampArray, locationArray, ~, VTRecsReturned, numRecordsDropped] = NlxGetNewVTData('VT1'); %Request all new VT data that has been acquired since the last pass.
%     %[succeeded,  timeStampArray, extractedLocationArray, extractedAngleArray, numRecordsReturned, numRecordsDropped ]= NlxGetNewVTData('VT1');
%     X = locationArray(2:2:length(locationArray));
%     Y = locationArray(1:2:length(locationArray)-1);
%     X_all(jj,:) = mean(X);
%     Y_all(jj,:) = mean(Y);
%     plot(X,Y,'.'), hold on
%     if mean(X) > XV_t(1,1)-10 && mean(X) < XV_t(1,1)+20 && mean(Y) < YV_t(1,1) && mean(Y) > YV_t(1,7) %If the rat's position is at the entrance of the maze stem
%         if exist ('TS_Stem','var') == 0 %If first trial, timestamp of stem entry is recorded
%             TS_Stem = mean(timeStampArray);
%         elseif exist ('TS_Stem','var') == 1 %If not first trial, check current timestamp to see if it has been ten seconds since the last recorded stem entry timestamp
%             if ((mean(timeStampArray) - TS_Stem)/1e6) > 10
%                 TS_Stem = mean(timeStampArray); %If it has been ten seconds since last stem entry, record new stem entry timestamp
%                 phasei = phasei+1; %Increase phase counter
%             end
%         end
%     end
%     if mod(phasei,2) == 0
%         NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2');
%     else
%         NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0');
%     end
%     timeGrabbed(jj) = length(locationArray)/30;
%     timeArray(jj,:) = mean(timeStampArray);
%     pause(0.02);
% end
% toc

%%Real
for jj = 1:1000000 %Make this into a while loop (to run as long as the session is running)
    
    LastCheck = InSelectedZone; % Get position data.
    
    [~, timeStampArray, locationArray, ~, VTRecsReturned, numRecordsDropped] = NlxGetNewVTData('VT1'); %Request all new VT data that has been acquired since the last pass.
    timeStampArray_counter(jj,:) = mean(timeStampArray); %Cache timestamp records
    X = locationArray(2:2:length(locationArray));
    Y = locationArray(1:2:length(locationArray)-1);
    
   
    if exist ('X_all','var') == 1 && exist ('Y_all','var') == 1
       if isempty(X) == 1 
          X = X_all(jj-1,:);
       end
       if isempty(Y) == 1 
          Y = Y_all(jj-1,:);
       end
    end
    
    for zeroi = 2:length(X) %Semi-control for tracking errors. If a zero coordinate is found, just replace it with the coordinate immediately preceding it.
        if X(zeroi) == 0
            X(zeroi) = X(zeroi-1);
        end
        if Y(zeroi) == 0
            Y(zeroi) = Y(zeroi-1);
        end
    end
    X_all(jj,:) = mean(X); %Cache position data
    Y_all(jj,:) = mean(Y);
    
    % Record entrance into stem polygon
    if mean(X) > XV_t(1,1) && mean(X) < XV_t(1,1)+100 && mean(Y) < YV_t(1,1) && mean(Y) > YV_t(1,2) %If the rat's position is at the entrance of the maze stem
        if exist ('TS_Stem','var') == 0 %If first trial, timestamp of stem entry is recorded
            TS_Stem = mean(timeStampArray);
        elseif exist ('TS_Stem','var') == 1 %If not first trial, check current timestamp to see if it has been twenty seconds since the last recorded stem entry timestamp
            if ((mean(timeStampArray) - TS_Stem)/1e6) > 20
                TS_Stem = mean(timeStampArray); %If it has been twenty seconds since last stem entry, record new stem entry timestamp
                phasei = phasei+1; %Increase phase counter
            end
        end
    end
    
    if exist ('TS_Stem','var') == 1
    TS_Stem_Tracker(phasei,:) = TS_Stem;
    end
    
    % check if animal is in selected zone
    if sessiontype == 1 || sessiontype == 2; %If the light should come on during maze traversals
        [IN_t,ON_t] = inpolygon(mean(X),mean(Y),XV_t,YV_t);
        [IN2_t,ON2_t] = inpolygon(double(median(X)),double(median(Y)), XV_t,YV_t);
        if IN_t == 1 || ON_t == 1 || IN2_t == 1 || ON2_t == 1 
            InSelectedZone = 1;
            InOtherZone = 0;
        elseif IN_t == 0 || ON_t == 0 && IN2_t == 0 || ON2_t == 0 
            InOtherZone = 1;
            InSelectedZone = 0;
        end
    elseif sessiontype == 4; %If the light should come on during start box occupancy
        [IN_sb,ON_sb] = inpolygon(mean(X),mean(Y),XV_sb,YV_sb);
        [IN2_sb,ON2_sb] = inpolygon(double(median(X)),double(median(Y)), XV_sb,YV_sb);
        if IN_sb == 1 || ON_sb == 1 || IN2_sb == 1 || ON2_sb == 1 
            InSelectedZone = 1;
            InOtherZone = 0;
        elseif IN_sb == 0 || ON_sb == 0 && IN2_sb == 0 || ON2_sb == 0
            InOtherZone = 1; 
            InSelectedZone = 0;
        end
    elseif sessiontype == 3;
        [IN_t,ON_t] = inpolygon(mean(X),mean(Y),XV_t,YV_t);
        [IN2_t,ON2_t] = inpolygon(double(median(X)),double(median(Y)), XV_t,YV_t);
        [IN_sb,ON_sb] = inpolygon(mean(X),mean(Y),XV_sb,YV_sb);
        [IN2_sb,ON2_sb] = inpolygon(double(median(X)),double(median(Y)), XV_sb,YV_sb);
        if IN_t == 1 || ON_t == 1 || IN2_t == 1 || ON2_t == 1 
           InStemZone = 1;
           InOtherZone = 0;
           InSBZone = 0;
        elseif IN_sb == 1 || ON_sb == 1 || IN2_sb == 1 || ON2_sb == 1
           InSBZone = 1;
           InOtherZone = 0;
           InStemZone = 0;
        elseif IN_t == 0 || ON_t == 0 && IN2_t == 0 || ON2_t == 0 && IN_sb == 0 || ON_sb == 0 && IN2_sb == 0 || ON2_sb == 0
            InOtherZone = 1;
            InStemZone = 0;
            InSBZone = 0;
        end
    end
      
%% Check to see that animal is in selected bins

    % If animal is in bins, turn LED on
    if sessiontype == 1 || sessiontype == 4
        if InSelectedZone == 1 && InOtherZone == 0 && mod(phasei,2) == 1 && exist ('TS_Stem','var') == 1; % animal has entered Selected Bins & phase = Sample
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2');
        pulse_counter = pulse_counter + 1;
        LED_Counter(pulse_counter,1) = mean(timeStampArray);
        LED_Counter(pulse_counter,2) = X_all(jj,:);
        LED_Counter(pulse_counter,3) = Y_all(jj,:);
        elseif InSelectedZone == 1 && InOtherZone == 0 && mod(phasei,2) == 0;% Turn off
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0');
        end
    end
    
    if sessiontype == 2
        if InSelectedZone == 1 && InOtherZone == 0 && mod(phasei,2) == 0; % animal has entered Selected Bins & phase = Choice
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2'); % Turn on
        pulse_counter = pulse_counter + 1;
        LED_Counter(pulse_counter,1) = mean(timeStampArray);
        LED_Counter(pulse_counter,2) = X_all(jj,:);
        LED_Counter(pulse_counter,3) = Y_all(jj,:);
        elseif InSelectedZone == 1 && InOtherZone == 0 && mod(phasei,2) == 1;
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0');
        end
    end
    
    if sessiontype == 3
        if InStemZone == 1 && InOtherZone == 0 && InSBZone == 0; % animal has entered Selected Bins
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2'); % Turn on
        pulse_counter = pulse_counter + 1;
        LED_Counter(pulse_counter,1) = mean(timeStampArray);
        LED_Counter(pulse_counter,2) = X_all(jj,:);
        LED_Counter(pulse_counter,3) = Y_all(jj,:);
        elseif InSBZone == 1 && InOtherZone == 0 && InStemZone == 0 && mod(phasei,2) == 1 && exist ('TS_Stem','var') == 1;
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2');
        pulse_counter = pulse_counter + 1;
        LED_Counter(pulse_counter,1) = mean(timeStampArray);
        LED_Counter(pulse_counter,2) = X_all(jj,:);
        LED_Counter(pulse_counter,3) = Y_all(jj,:);
        elseif InSBZone == 1 && InOtherZone == 0 && InStemZone == 0 && mod(phasei,2) == 0;
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0');   
        end
    end
    
    % If animal is outside of selected bins, turn LED off
    if InSelectedZone == 0 && InStemZone == 0 && InSBZone == 0 && InOtherZone == 1;
       NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0'); % Turn Off
    end
   
    
end




