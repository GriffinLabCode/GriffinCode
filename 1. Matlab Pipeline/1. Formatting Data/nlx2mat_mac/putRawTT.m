%putRawTT.m
%Demo file on how to write SE and TT files
%This function can write either.
%
%modeOut: 1 is SE, 2 is TT
%
%
%urut/MPI/Dec11
function putRawTT( modeOut, filenameOut, timestamps, dataPointsOut, headerLine )
AppendFile=0;
ExtractMode=1;
ModeArray=1;

NumRecs=length(timestamps);

%all
% Field List
%     1. Timestamps   
%     2. Sc Numbers
%     3. Cell Numbers
%     4. Params
%     5. Data Points
%     6. Header

FieldSelection(1) = 1; %timestamps
FieldSelection(2) = 0; 
FieldSelection(3) = 0; 
FieldSelection(4) = 0; 
FieldSelection(5) = 1; %samples
FieldSelection(6) = 1;%header

HeaderOut{1} = ['######## Neuralynx'];     %this is REQUIRED as header prefix
HeaderOut{2} = ['FileExport Mat2NlxTT_SE-urut unix-vers'];    
HeaderOut{3} = [' ' headerLine];    

if modeOut == 1
    Mat2NlxSE( filenameOut, AppendFile, ExtractMode, ModeArray, NumRecs, FieldSelection, timestamps, dataPointsOut, HeaderOut' );
else
    Mat2NlxTT( filenameOut, AppendFile, ExtractMode, ModeArray, NumRecs, FieldSelection, timestamps, dataPointsOut, HeaderOut' );    
end