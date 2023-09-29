%
% demo file on how to use Nlx2MatSpike_v3. for further details,see the original help in Nlx2MatSpike_v3.m
%
%

%Filename = '/Users/ueli/data/turtleD29_sept6/TT1.ntt';
%Filename = '/home/urut/MPI/data/testData/SE1_CSC34.nse';
Filename='/tmp/TT_test4.ntt';

%     1. Timestamps   
%     2. Sc Numbers
%     3. Cell Numbers
%     4. Params
%     5. Data Points
FieldSelection(1) = 1;
FieldSelection(2) = 1;
FieldSelection(3) = 1;
FieldSelection(4) = 1;
FieldSelection(5) = 1;

ExtractHeader = 1;
ExtractMode = 1;

ModeArray=[]; %all.

%this file can read SE and TT
[TimeStamps, ScNumbers, CellNumbers, Params, DataPoints,header] = Nlx2MatSpike_v3( Filename, FieldSelection, ExtractHeader, ExtractMode, ModeArray );
which Nlx2MatSpike_v3

spikes=squeeze(DataPoints(:,1,1:1000));  %take so many spikes to display

figure;
plot(spikes);

%%
%write it back out for testing
filenameOut = '/tmp/TT_test4.ntt';
modeOut=2;
putRawTT( modeOut, filenameOut, TimeStamps, DataPoints, 'test info' );

