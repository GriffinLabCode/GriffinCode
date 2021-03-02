%NLXGETNEWVTDATA   Gets new video tracker records that have been streamed over netcom
%
%   [succeeded,  timeStampArray, extractedLocationArray, extractedAngleArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewVTData(objectName)
%
%   Example:   [succeeded,  timeStampArray, extractedLocationArray, extractedAngleArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewVTData('VT1')
%		Returns the data for all the records received for VT1 since the last call to this function.	
%
%	Returns:
%	succeeded:	1 means the operation completed successfully
%			0 means the operation failed
%	timeStampArray:  Continuous array of timestamps for all received records since the last call to this function. 
%	extractedLocationArray:  Continuous array of x, y coordinate pairs (i.e. [x0,y0, x1, y1, ...])  for all received records since the last call to this function.
%	extractedAngleArray:  Continuous array of angles returned from a get data function call for all received records since the last call to this function.
%	numRecordsReturned:  The number of records that were received since the last call to this function
%	numRecordsDropped:  The number of records that were dropped since the last call to this function.
%
%


function [succeeded,  timeStampArray, extractedLocationArray, extractedAngleArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewVTData(objectName)

	
	succeeded = 0;
	
	succeeded = libisloaded('MatlabNetComClient');
	if succeeded == 0
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
		return;
	end
	
	%get buffer sizes from NetCom DLL
	bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
	
	%Clear out all of the return values and preallocate space for the variables
	timeStampArray = zeros(1,bufferSize);
	extractedLocationArray = zeros(1,bufferSize * 2);
	extractedAngleArray = zeros(1,bufferSize);
	numRecordsReturned = 0;
	numRecordsDropped = 0;
	
	
	%setup the ref pointers for the function call
	timeStampArrayPtr = libpointer('int64PtrPtr', timeStampArray);
	extractedLocationArrayPtr = libpointer('int32PtrPtr', extractedLocationArray);
	extractedAngleArrayPtr = libpointer('int32PtrPtr', extractedAngleArray);
	numRecordsReturnedPtr = libpointer('int32Ptr', numRecordsReturned);
	numRecordsDroppedPtr = libpointer('int32Ptr', numRecordsDropped);
	
	[succeeded, objectName, timeStampArray, extractedLocationArray, extractedAngleArray, numRecordsReturned, numRecordsDropped ] = calllib('MatlabNetComClient', 'GetNewVTData', objectName, timeStampArrayPtr, extractedLocationArrayPtr, extractedAngleArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );

	%format the return arrays
	if numRecordsReturned > 0
		%truncate arrays to the number of returned records
		timeStampArray = timeStampArray(1:numRecordsReturned);
		extractedLocationArray = extractedLocationArray(1:numRecordsReturned*2);
		extractedAngleArray = extractedAngleArray(1:numRecordsReturned);
	elseif numRecordsReturned == 0
		%return empty arrays if no data was retrieved
		timeStampArray = [];
		extractedLocationArray = [];
		extractedAngleArray = [];
	end		
end