%NLXSENDCOMMAND   Sends a command to the DAS
%
%   [SUCCEEDED, REPLY] = NLXSENDCOMMAND(COMMANDSTRING) 
%
%   Example:  [succeeded, reply] = NlxSendCommand('-StartAcquisition');
%	
%
%	succeeded:	1 means the operation completed successfully
%				0 means the operation failed
%
%	reply:      This cell string will be filled with the reply from the DAS.
%				You will need to convert this reply to the appropriate numeric
%				type for the data you requested before using the reply value in
%				MATLAB.
%


function [succeeded, reply] = NlxSendCommand(commandString)  

	MAX_REPLY_LENGTH = 1000; %number of chars to allocate for a reply
	STRING_PLACEHOLDER = blanks(MAX_REPLY_LENGTH);  % ensures enough space is allocated for the return value
	
	reply = 0;
	succeeded = libisloaded('MatlabNetComClient');
	if succeeded == 0
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
		return;
	end
	
	replyPointer = libpointer('stringPtrPtr', {STRING_PLACEHOLDER});
	if succeeded == 1
		[succeeded, commandString, reply, replyLength] = calllib('MatlabNetComClient', 'SendCommand', commandString, replyPointer, MAX_REPLY_LENGTH);
    end;
        
end