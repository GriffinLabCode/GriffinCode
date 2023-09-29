%putRawEV.m
%Demo file on how to write EV files
%
%exportMode: 1 all fields, 2 only timestamps and TTLs (usually only this is
%needed)
%
%urut/Dec15
function putRawEV( exportMode, filenameOut, Timestamps, TTLs, headerLine, EventIDs, Extras, EventStrings )

if exportMode==1
    FieldSelection(1) = 1; %timestamps
    FieldSelection(2) = 1; %Event IDs
    FieldSelection(3) = 1; %TTLs
    FieldSelection(4) = 1; %Extras
    FieldSelection(5) = 1; %Event Strings
    FieldSelection(6) = 1;%header
else
    FieldSelection(1) = 1; %timestamps
    FieldSelection(2) = 0; %Event IDs
    FieldSelection(3) = 1; %TTLs
    FieldSelection(4) = 0; %Extras
    FieldSelection(5) = 0; %Event Strings
    FieldSelection(6) = 1;%header
end

HeaderOut{1} = ['######## Neuralynx'];     %this is REQUIRED as header prefix
HeaderOut{2} = ['FileExport Mat2NlxEV-urut unix-vers'];    
HeaderOut{3} = [' ' headerLine];    

AppendFile=0;
ExtractMode=1;
ModeArray=1;
NumRecs=length(Timestamps);

if exist(filenameOut)
    error(['File already exists. Cannot overwrite, need to remove manually first:' filenameOut]);
end

if exportMode==1
    Mat2NlxEV( filenameOut, AppendFile, ExtractMode, ModeArray, NumRecs, FieldSelection, Timestamps,EventIDs, TTLs, Extras, EventStrings, HeaderOut' );     
else
    Mat2NlxEV( filenameOut, AppendFile, ExtractMode, ModeArray, NumRecs, FieldSelection, Timestamps, TTLs, HeaderOut' );     
end

%Mat2NlxEV(filenameOut, AppendFile, ExtractMode, FieldSelection, 1, 1, [],Timestamps, EventIDs, TTLs, Extras, EventStrings, HeaderOut);