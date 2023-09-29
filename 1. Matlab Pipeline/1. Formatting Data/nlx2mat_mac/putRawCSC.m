% putRawCSC.m
% demo on how to use Mat2NlxCSC
%
%
% example:
% putRawCSC( filenameOut, timestamps, dataSamples, ['Test header info'] );
% where timestamps and dataSamples are as returned by:
% [timestamps,dataSamples] = getRawCSCData( filename, fromInd, toInd, mode );
%
%urut/MPI/dec11
%urut/feb13 added exporting Fs/validSamples/channelNr to make compatible
%with windows version
%
function putRawCSC( filenameOut, timestamps, dataSamples,ChannelNumbers, SampleFrequencies, NumberOfValidSamples, headerLines )
blocksize = 512;

AppendFile = 0;
ExtractMode = 1;
ModeArray = 1;

NumRecs=length(timestamps);

FieldSelection(1) = 1; %timestamps
FieldSelection(2) = 1; %channel nr
FieldSelection(3) = 1; %sample freq
FieldSelection(4) = 1; % valid samples
FieldSelection(5) = 1; %samples
FieldSelection(6) = 1;%header

HeaderOut{1} = ['######## Neuralynx'];     %this is REQUIRED as header prefix
HeaderOut{2} = ['FileExport Mat2NlxCSC-urut unix-vers'];    
if iscell(headerLines)
    for k=1:length(headerLines)
        HeaderOut{2+k} = headerLines{k};
    end
else
    HeaderOut{3} = [' ' headerLines];    
end

% if one row/column, reformat into blocks
if size(dataSamples,1)==1 || size(dataSamples,2)==1
	SamplesOut = reshape(dataSamples, blocksize, length(dataSamples)/blocksize);
else
	SamplesOut = dataSamples;
end

if AppendFile==0 & exist(filenameOut)
   warning(['Append is disabled and file exists already -- need to delete manually, will be corrupt: ' filenameOut]); 
end

Mat2NlxCSC( filenameOut, AppendFile, ExtractMode, ModeArray, NumRecs,...
            FieldSelection, timestamps, ChannelNumbers, SampleFrequencies,...
            NumberOfValidSamples, SamplesOut, HeaderOut' );       
