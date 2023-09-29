%
%putRawEV_verify
%
%reads an event file, and write its back out to verify content is written
%correctly.
%
%urut/Dec15

%% read an event file
filenameIn='/home/urut/data/p27CS_011713/Events.nev';
%                           FieldSelectionFlags(1): Timestamps
%                           FieldSelectionFlags(2): Event IDs
%                           FieldSelectionFlags(3): TTLs
%                           FieldSelectionFlags(4): Extras
%                           FieldSelectionFlags(5): Event Strings
FieldSelection=[1 1 1 1 1];
ExtractHeader = 1;
ExtractMode = 1;

[timestamps,  eventIDs, ttls,extras, eventStrings, header] = Nlx2MatEV_v3(filenameIn, FieldSelection, ExtractHeader, ExtractMode);

%% write it back out
filenameOut = '/tmp/EventsOut_test.nev';
filenameOut2 = '/tmp/EventsOut_test2.nev';

exportMode=2;   % only export timestamps and TTLs
putRawEV( exportMode, filenameOut,timestamps, ttls, 'testHeader' );

exportMode=1;   % only export timestamps and TTLs
putRawEV( exportMode, filenameOut2,timestamps, ttls, 'testHeader', eventIDs, extras, eventStrings  );

%% read it back in to compare
[timestamps2,  eventIDs2, ttls2,extras2, eventStrings2, header2] = Nlx2MatEV_v3(filenameOut, FieldSelection, ExtractHeader, ExtractMode);

%should all be zero
sum( timestamps2-timestamps)
sum( ttls2-ttls)

[timestamps3,  eventIDs3, ttls3,extras3, eventStrings3, header3] = Nlx2MatEV_v3(filenameOut2, FieldSelection, ExtractHeader, ExtractMode);
