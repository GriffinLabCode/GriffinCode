%NLXGETNEWEVENTDATA   Gets new event records that have been streamed over NetCom
%
%   [succeeded,  timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData(objectName)
%
%   Example:   [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData('Events')
%		Returns the data for all the records received for Events since the last call to this function.	
%
%	Returns:
%	succeeded:	1 means the operation completed successfully
%			0 means the operation failed
%	timeStampArray:  Continuous array of timestamps for all received records since the last call to this function. 
%	eventIDArray:  Continuous array of event IDs returned for all received records since the last call to this function.
%	ttlValueArray:  Continuous array of TLL values (in decimal form) returned for all received records since the last call to this function.
%	eventStringArray:   Continuous array of event string values returned for all received records since the last call to this function.
%	numRecordsReturned:  The number of records that were received since the last call to this function
%	numRecordsDropped:  The number of records that were dropped since the last call to this function.
%
%


function [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData(objectName)

	
	succeeded = 0;
	
	succeeded = libisloaded('MatlabNetComClient');
	if succeeded == 0
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
		return;
	end
	
	%get buffer sizes from NetCom DLL
	bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
	maxEventStringLength = calllib('MatlabNetComClient', 'GetMaxEventStringLength');
	STRING_PLACEHOLDER = blanks(maxEventStringLength);  %ensures enough space is allocated for each event string name
	
	%Clear out all of the return values and preallocate space for the variables
	timeStampArray = zeros(1,bufferSize);
	eventIDArray = zeros(1,bufferSize);
	ttlValueArray = zeros(1,bufferSize);
	eventStringArray = cell(1,bufferSize);
	for index = 1:bufferSize
		eventStringArray{1,index} = STRING_PLACEHOLDER;
	end
	numRecordsReturned = 0;
	numRecordsDropped = 0;
	
	
	%setup the ref pointers for the function call
	timeStampArrayPtr = libpointer('int64PtrPtr', timeStampArray);
	eventIDArrayPtr = libpointer('int32PtrPtr', eventIDArray);
	ttlValueArrayPtr = libpointer('int32PtrPtr', ttlValueArray);
	eventStringArrayPtr = libpointer('stringPtrPtr', eventStringArray);
	numRecordsReturnedPtr = libpointer('int32Ptr', numRecordsReturned);
	numRecordsDroppedPtr = libpointer('int32Ptr', numRecordsDropped);
	
	[succeeded, objectName, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = calllib('MatlabNetComClient', 'GetNewEventData', objectName, timeStampArrayPtr, eventIDArrayPtr, ttlValueArrayPtr, eventStringArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );

	%format the return arrays
	if numRecordsReturned > 0
		%truncate arrays to the number of returned records
		timeStampArray = timeStampArray(1:numRecordsReturned);
		eventIDArray = eventIDArray(1:numRecordsReturned);
		ttlValueArray = ttlValueArray(1:numRecordsReturned);
		eventStringArray = eventStringArray(1:numRecordsReturned);
	elseif numRecordsReturned == 0
		%return empty arrays if no data was retrieved
		timeStampArray = [];
		eventIDArray = [];
		ttlValueArray = [];
		eventStringArray = [];
	end		
end