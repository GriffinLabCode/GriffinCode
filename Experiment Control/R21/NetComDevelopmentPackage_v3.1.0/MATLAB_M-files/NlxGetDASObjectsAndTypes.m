%NLXGETDASOBJECTSANDTYPES   Retrieves all objects defined in the data acquisition
%							software (DAS) object list, along with their
%							corresponding types.  The NetCom client must be
%							connected, or this function will fail.
%
%   [SUCCEEDED, OBJECTNAMES, TYPENAMES] = NLXGETDASOBJECTSANDTYPES() 
%
%   Example:  [succeeded, objectNames, typeNames] NlxGetDASObjectsAndTypes();
%	
%
%	succeeded:	1 means the operation completed successfully
%				0 means the operation failed
%
%	objectNames:   This cell string array will be filled with strings for each object 
%				   in the DAS's object list.
%
%	typeNames:     This cell string array will be filled with String objects for each 
%				   object's type in the DAS's object list.  The type specified will 
%				   have a one-to-one mapping with objectNames.
%				   (i.e. objectNames(1) will be of type typeNames(1) ).
%                  Type names are as follows:
%                   'SEScAcqEnt' is the Single Electrode object identification in NetCom
%                   'STScAcqEnt' is the Stereotrode object identification in NetCom
%                   'TTScAcqEnt' is the Tetrode object identification in NetCom
%                   'CscAcqEnt' is the Continuously Sampled Channel object identification
%                               in NetCom. This also identifies individual channels of a
%                               Continuous Signal Group (CSG) object in Pegasus.
%                   'EventAcqEnt' is the Event object identification in NetCom
%                   'VTAcqEnt' is the Video Tracker object identification in NetCom
%                   'AcqSource' is the Acquisition Source object identification in NetCom
% 


function [succeeded, objectNames, typeNames] = NlxGetDASObjectsAndTypes()  

  MAX_OBJECTS = 5000; %limit on number of objects returned
  MAX_STRING_LENGTH = 100; %limit on length of strings for each returned object
  STRING_PLACEHOLDER = blanks(MAX_STRING_LENGTH);  %ensures enough space is allocated for each AE name
  
  objectNames = 0;
  typeNames = 0;
  succeeded = libisloaded('MatlabNetComClient');
  if succeeded == 0
    disp 'Not Connected - call NlxConnectToServer before calling this function.'
    return;
  end
  
  str = cell(1,MAX_OBJECTS);
  for index = 1:MAX_OBJECTS
    str{1,index} = STRING_PLACEHOLDER;
  end
  
  dasObjectsPointer = libpointer('stringPtrPtr', str);
  dasTypesPointer = libpointer('stringPtrPtr', str);
  if succeeded == 1
    [succeeded, objectNames, typeNames, stringLength, numObjects] = calllib('MatlabNetComClient', 'GetDASObjectsAndTypes', dasObjectsPointer, dasTypesPointer, MAX_STRING_LENGTH, MAX_OBJECTS);
    end;
    
    if succeeded == 1
      objectNames = objectNames(1:numObjects);
      typeNames = typeNames(1:numObjects);
    end;
    
end