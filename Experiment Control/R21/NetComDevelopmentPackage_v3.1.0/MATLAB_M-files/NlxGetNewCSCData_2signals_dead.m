%NLXGETNEWCSCDATA   Gets new CSC records that have been streamed over NetCom
%
%   [succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData(objectName)
%
%   Example:   [succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData('CSC1')
%		Returns the data for all the records received for CSC1 since the last call to this function.	
%
%	Returns:
%	succeeded:	1 means the operation completed successfully
%			0 means the operation failed
%	dataArray:  Continuous (e.g. not separated into records) array of samples returned from a get data function call for all received records since the last call to this function.  
%		          Each MAX_CSC_SAMPLES chunk of data will be associated with a single entry in the timestamp array.
%	timeStampArray:  Continuous array of timestamps for all received records since the last call to this function. 
%	channelNumberArray:  Continuous array of channel numbers  for all received records since the last call to this function.
%	samplingFreqArray:  Continuous array of sampling rates for all received records since the last call to this function.
%	numRecordsReturned:  The number of records that were received since the last call to this function
%	numRecordsDropped:  The number of records that were dropped since the last call to this function.
%
%


function [succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur] = NlxGetNewCSCData_2signals(objectName1, objectName2)  

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
	
    % get data
	[succeeded_signal1, objectName_signal1, timeStampArray_signal1, channelNumberArray_signal1, samplingFreqArray_signal1, numValidSamplesArray_signal1, dataArray_signal1, numRecordsReturned_signal1, numRecordsDropped_signal1 ] = calllib('MatlabNetComClient', 'GetNewCSCData', objectName1, timeStampArrayPtr, channelNumberArrayPtr, samplingFreqArrayPtr, numValidSamplesArrayPtr, dataArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );
	[succeeded_signal2, objectName_signal2, timeStampArray_signal2, channelNumberArray_signal2, samplingFreqArray_signal2, numValidSamplesArray_signal2, dataArray_signal2, numRecordsReturned_signal2, numRecordsDropped_signal2 ] = calllib('MatlabNetComClient', 'GetNewCSCData', objectName2, timeStampArrayPtr, channelNumberArrayPtr, samplingFreqArrayPtr, numValidSamplesArrayPtr, dataArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );


    % resample signal1 if its not the same size as signal2
    size1 = numel(timeStampArray_signal1);
    size2 = numel(timeStampArray_signal2);
    if size2 > size1
        numNewSamples = size2-size1;
        for i = 1:numNewSamples
            [succeeded_signal1, objectName_signal1, timeStampArray_signal1, channelNumberArray_signal1, samplingFreqArray_signal1, numValidSamplesArray_signal1, dataArray_signal1, numRecordsReturned_signal1, numRecordsDropped_signal1 ] = calllib('MatlabNetComClient', 'GetNewCSCData', objectName1, timeStampArrayPtr, channelNumberArrayPtr, samplingFreqArrayPtr, numValidSamplesArrayPtr, dataArrayPtr, numRecordsReturnedPtr,numRecordsDroppedPtr );
        end
    end
    
	%format the return arrays
	if numRecordsReturned_signal1 > 0
		%truncate arrays to the number of returned records
		dataArray_signal1 = dataArray_signal1(1:(numRecordsReturned_signal1 * maxCSCSamples) );
		timeStampArray_signal1 = timeStampArray_signal1(1:numRecordsReturned_signal1);
		channelNumberArray_signal1 = channelNumberArray_signal1(1:numRecordsReturned_signal1);
		samplingFreqArray_signal1 = samplingFreqArray_signal1(1:numRecordsReturned_signal1);
		numValidSamplesArray_signal1 = numValidSamplesArray_signal1(1:numRecordsReturned_signal1);
	elseif numRecordsReturned_signal1 == 0
		%return empty arrays if no data was retrieved
		dataArray_signal1 = [];
		timeStampArray_signal1 = [];
		channelNumberArray_signal1 = [];
		samplingFreqArray_signal1 = [];
		numValidSamplesArray_signal1 = [];
    end
    
	if numRecordsReturned_signal2 > 0
		%truncate arrays to the number of returned records
		dataArray_signal2 = dataArray_signal2(1:(numRecordsReturned_signal2 * maxCSCSamples) );
		timeStampArray_signal2 = timeStampArray_signal2(1:numRecordsReturned_signal2);
		channelNumberArray_signal2 = channelNumberArray_signal2(1:numRecordsReturned_signal2);
		samplingFreqArray_signal2 = samplingFreqArray_signal2(1:numRecordsReturned_signal2);
		numValidSamplesArray_signal2 = numValidSamplesArray_signal2(1:numRecordsReturned_signal2);
	elseif numRecordsReturned_signal2 == 0
		%return empty arrays if no data was retrieved
		dataArray_signal2 = [];
		timeStampArray_signal2 = [];
		channelNumberArray_signal2 = [];
		samplingFreqArray_signal2 = [];
		numValidSamplesArray_signal2 = [];
    end  
 %{   
    % sometimes, the sample sizes will differ, we must account for this.   
    if timeStampArray_signal1 ~= timeStampArray_signal2
        
        % create an index that reflects the mismatch (idx will have a 1)
        idx = timeStampArray_signal1 ~= timeStampArray_signal2;
        
        % find instances where idx equals 1
        idxRem = find(idx == 1);
        
        if numel(timeStampArray_signal1) < numel(timeStampArray_signal2)
            
            % remove the timestamps
            timeStampArray_signal2(idxRem)=[];
            
            % remove the necessary signal
            dataArray_signal2(numValidSamplesArray_signal2(1)+1:numel(dataArray_signal2))=[];
        
    end
    
    if numel(timeStampArray_signal1) <  numel(timeStampArray_signal2)
         
        % find the timestamp match
        idx = dsearchn(timeStampArray_signal2',timeStampArray_signal1);
        
        timeStampArray_signal2(idx)=[]
        
    elseif numel(timeStampArray_signal1) >  numel(timeStampArray_signal2)
        
    end
%}
    
    % set up final return arrays - keep these as matrices
    dataArray            = [];
    timeStampArray       = [];
    channelNumberArray   = [];
    samplingFreqArray    = [];
    numValidSamplesArray = [];
    numRecordsReturned   = [];
    numRecordsDropped    = [];
    
    % signal 2 is always the bottom array
    succeeded(1,:) = succeeded_signal1;
    succeeded(2,:) = succeeded_signal2;
    
    dataArray(1,:) = dataArray_signal1;
    dataArray(2,:) = dataArray_signal2;
    
    timeStampArray(1,:) = timeStampArray_signal1;
    timeStampArray(2,:) = timeStampArray_signal2;
    
    channelNumberArray(1,:) = channelNumberArray_signal1;
    channelNumberArray(2,:) = channelNumberArray_signal2;
    
    samplingFreqArray(1,:) = samplingFreqArray_signal1;
    samplingFreqArray(2,:) = samplingFreqArray_signal2;
    
    numValidSamplesArray(1,:) = numValidSamplesArray_signal1;
    numValidSamplesArray(2,:) = numValidSamplesArray_signal2;
    
    numRecordsReturned(1,:) = numRecordsReturned_signal1;
    numRecordsReturned(2,:) = numRecordsReturned_signal2;
    
    numRecordsDropped(1,:) = numRecordsDropped_signal1;
    numRecordsDropped(2,:) = numRecordsDropped_signal2;
    
    % track time
    funDur = toc;
    
end