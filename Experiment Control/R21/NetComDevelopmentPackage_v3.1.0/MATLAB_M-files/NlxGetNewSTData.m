%NLXGETNEWSTDATA   Gets new ST records that have been streamed over NetCom
%
%   [succeeded, dataArray, timeStampArray, spikeChannelNumberArray, cellNumberArray, featureArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewSTData(objectName)
%
%   Example:   [succeeded, dataArray, timeStampArray, spikeChannelNumberArray, cellNumberArray, featureArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewSTData('ST1')
%		Returns the data for all the records received for ST1 since the last call to this function.	
%
%	Returns:
%	succeeded:	1 means the operation completed successfully
%			0 means the operation failed
%	dataArray:  Continuous array of points with the sub channels interleaved (i.e. [ch0,ch1,ch0,ch1]) returned for all received records since the last call to this function.
%	timeStampArray:  Continuous array of timestamps for all received records since the last call to this function. 
%	spikeChannelNumberArray:  Continuous array of sc numbers for all received records since the last call to this function.
%	cellNumberArray:  Continuous array of cell numbers returned  for all received records since the last call to this function.
%	featureArray:   Continuous array of feature values with the feature values interleaved (i.e. [ft0,ft1,..ft7,ft0,ft1]) returned for all received records since the last call to this function.
%	numRecordsReturned:  The number of records that were received since the last call to this function
%	numRecordsDropped:  The number of records that were dropped since the last call to this function.
%
%


function [succeeded, dataArray, timeStampArray, spikeChannelNumberArray, cellNumberArray, featureArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewSTData(objectName) 

	
	succeeded = 0;
	
	succeeded = libisloaded('MatlabNetComClient');
	if succeeded == 0
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
		return;
	end
	
	%get buffer sizes from NetCom DLL
	bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
	spikeSampleWindowSize = calllib('MatlabNetComClient', 'GetSpikeSampleWindowSize');
	maxSpikeFeatures = calllib('MatlabNetComClient', 'GetMaxSpikeFeatures');
	numSubChannels = 2; %number of stereotrode channels
	
	%Clear out all of the return values and preallocate space for the variables
	dataArray = zeros(1,(numSubChannels * spikeSampleWindowSize * bufferSize) );
	timeStampArray = zeros(1,bufferSize);
	spikeChannelNumberArray = zeros(1,bufferSize);
	cellNumberArray = zeros(1,bufferSize);
	featureArray = zeros(1,maxSpikeFeatures * bufferSize);
	numRecordsReturned = 0;
	numRecordsDropped = 0;
	
	
	%setup the ref pointers for the function call
	dataArrayPtr = libpointer('int16PtrPtr', dataArray);
	timeStampArrayPtr = libpointer('int64PtrPtr', timeStampArray);
	spikeChannelNumberArrayPtr = libpointer('int32PtrPtr', spikeChannelNumberArray);
	cellNumberArrayPtr = libpointer('int32PtrPtr', cellNumberArray);
	featureArrayPtr = libpointer('int32PtrPtr', featureArray);
	numRecordsReturnedPtr = libpointer('int32Ptr', numRecordsReturned);
	numRecordsDroppedPtr = libpointer('int32Ptr', numRecordsDropped);
	
	[succeeded, objectName, timeStampArray, spikeChannelNumberArray, cellNumberArray,featureArray, dataArray, numRecordsReturned, numRecordsDropped ] = calllib('MatlabNetComClient', 'GetNewSTData', objectName, timeStampArrayPtr, spikeChannelNumberArrayPtr, cellNumberArrayPtr, featureArrayPtr, dataArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );

	%format the return arrays
	if numRecordsReturned > 0
		%truncate arrays to the number of returned records
		dataArray = dataArray(1:(numRecordsReturned * spikeSampleWindowSize * numSubChannels) );
		timeStampArray = timeStampArray(1:numRecordsReturned);
		spikeChannelNumberArray = spikeChannelNumberArray(1:numRecordsReturned);
		cellNumberArray = cellNumberArray(1:numRecordsReturned);
		featureArray = featureArray(1:numRecordsReturned * maxSpikeFeatures);
	elseif numRecordsReturned == 0
		%return empty arrays if no data was retrieved
		dataArray = [];
		timeStampArray = [];
		spikeChannelNumberArray = [];
		cellNumberArray = [];
		featureArray = [];
	end		
end