%
%reads the raw data from a neuralynx CSC file.
%
%urut/april04
function [timestamps,dataSamples] = getRawCSCData(filename, ExtractMode, ModeArray)
if nargin==3
    mode=2;
end

FieldSelection(1) = 1;%timestamps
FieldSelection(2) = 0;
FieldSelection(3) = 0;%sample freq
FieldSelection(4) = 0;
FieldSelection(5) = 1;%samples
ExtractHeader = 0;

ExtractMode = mode; % 2 = extract record index range; 4 = extract timestamps range.
%ModeArray(1)=fromInd;
%ModeArray(2)=toInd;

[timestamps, dataSamples] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode, ModeArray);

%flatten
dataSamples=dataSamples(:);

