%% clearStream
%
% this function was created to clear the working stream when connected to
% cheetah via netcom. This is important because we want to control for the
% amount of time in consideration.
%
% last edit 8/4/20 by JS. Code written by neuralynx, idea developed by JS

function [funDur] = clearStream(objectName1, objectName2)  
	tic;
	%get buffer sizes from NetCom DLL
	bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
	maxCSCSamples = calllib('MatlabNetComClient', 'GetMaxCSCSamples');
	
	%Clear out all of the return values and preallocate space for the variables
	dataArray = zeros(1,(maxCSCSamples * bufferSize) );
	timeStampArray = zeros(1,bufferSize);
	channelNumberArray = zeros(1,bufferSize);
	samplingFreqArray = zeros(1,bufferSize);
	numValidSamplesArray = zeros(1,bufferSize);
	numRecordsReturned = 0;
	numRecordsDropped = 0;
	
	%setup the ref pointers for the function call
	dataArrayPtr = libpointer('int16PtrPtr', dataArray);
	timeStampArrayPtr = libpointer('int64PtrPtr', timeStampArray);
	channelNumberArrayPtr = libpointer('int32PtrPtr', channelNumberArray);
	samplingFreqArrayPtr = libpointer('int32PtrPtr', samplingFreqArray);
	numValidSamplesArrayPtr = libpointer('int32PtrPtr', numValidSamplesArray);
	numRecordsReturnedPtr = libpointer('int32Ptr', numRecordsReturned);
	numRecordsDroppedPtr = libpointer('int32Ptr', numRecordsDropped);
	
    % run function to clear the working stream
	calllib('MatlabNetComClient', 'GetNewCSCData', objectName1, timeStampArrayPtr, channelNumberArrayPtr, samplingFreqArrayPtr, numValidSamplesArrayPtr, dataArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );
	calllib('MatlabNetComClient', 'GetNewCSCData', objectName2, timeStampArrayPtr, channelNumberArrayPtr, samplingFreqArrayPtr, numValidSamplesArrayPtr, dataArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );
    
    % track the amount of time spent in this function
    funDur = toc;
end