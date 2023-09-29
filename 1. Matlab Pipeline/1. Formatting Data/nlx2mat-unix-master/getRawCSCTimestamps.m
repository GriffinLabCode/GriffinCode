%
%reads the raw timestamps from a neuralynx CSC file.
%
%urut/april04
function [timestamps,nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawCSCTimestamps( filename )
disp(['reading ' filename]);

isContinous=false;

FieldSelection(1) = 1;%timestamps
FieldSelection(2) = 0;
FieldSelection(3) = 1;%sample freq
FieldSelection(4) = 0;
FieldSelection(5) = 0;

ExtractHeader = 1;
ExtractMode = 1;

[timestamps, sampleFreqs, headerInfo] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode);

nrBlocks=size(timestamps,2);
nrSamples=nrBlocks*512;
sampleFreq=sampleFreqs(1);


if length(unique(diff(timestamps)))==1
    %is a continous recording sessions (no interruptions)
    isContinous=true;
end