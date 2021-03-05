%NLXOPENSTREAM   Opens a data stream to a specified DAS object
%
%   	Function takes a string containing the name of the object whose
%	data you wish to stream.
%
%	NLXOPENSTREAM(OBJECTNAME,)
%
%	Once a data stream is opened, the DAS will begin streaming data
%	for that stream.  You will then need to call the appropriate
%	NLXGETNEW<type>DATA function for the type of object whose stream was
%	opened to retrieve streaming data. Objects of type 'AcqSource' cannot
%   stream data, so opening a stream for those objects will fail.
%   Data may be lost if the opened stream is not serviced regularly
%   by calling one of the following commands:
%
%	NLXGETNEWCSCDATA(AENAME)
%	NLXGETNEWSEDATA(AENAME)
%	NLXGETNEWSTDATA(AENAME)
%	NLXGETNEWTTDATA(AENAME)
%	NLXGETNEWEVENTDATA(AENAME)
%	NLXGETNEWVTDATA(AENAME)
%
%
%   Example:  NlxOpenStream('SE1');
%	Opens a data stream for the single electrode named SE1.
%
%	Returns: 1 means the stream was successfully opened.
%			 0 means the stream was not opened.
%
%

function succeeded = NlxOpenStream(objectName)  

	succeeded = libisloaded('MatlabNetComClient');
	
	if succeeded == 1
		succeeded = calllib('MatlabNetComClient', 'OpenStream', char(objectName));
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
    end;
	
end