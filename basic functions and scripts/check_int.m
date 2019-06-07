% checking over the int file
%
% written by John Stout

% ~~~~~~~~~ need the datafolder variable ~~~~~~~~~~
% datafolder = '';

% define some boundaries for the trajectory info on maze
    % maze running
    mazei(1,:)  = [1 5];
    mazei(2,:)  = [5 6];
    mazei(3,:)  = [6 2];
    mazei(4,:)  = [2 7];
    mazei(5,:)  = [7 8];
    % startbox occupancy
    mazesb(1,:) = [8,1];

% define maze parameters
% right reward zone (up/down room, L)
    rRW_fld = [478 310 77 100]; 
    
    % left reward zone (up/down room, L)
    lRW_fld = [150 310 81 100];
    
    % central stem (up/down room, L)
    STM_fld = [335 132 37 228];
    
    % delay pedestal (up/down room, L)
    PED_fld = [280 35 150 97];
    
    % choice point/T-junction (up/down room, L)
    CP_fld = [336 360 35 65];
    
    % Left Goal Arm 
    GAL_fld = [231 360 105 65];
    
    % Right Goal Arm 
    GAR_fld = [371 360 107 65];
    
    % Return Arm Left
    RAL_fld = [180 135 160 175];
    
    % Return Arm Right
    LAL_fld = [367 135 167 175];
    
% load vt data
load(strcat(datafolder,'\VT1.mat'));

% addpath for easy call of function
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')

% interpolate missing vt data
ExtractedX = []; ExtractedY = [];
[ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);

% load Int file
load(strcat(datafolder,'\Int_file.mat'))

% is maze locations defined?
if exist('mazei') == 1
    % get data from maze running
    for i = 1:size(Int,1);
        for ii = 1:size(mazei,1);
            % index location times
            data.loc_idx{ii,i} = find(TimeStamps_VT>=Int(i,mazei(ii,1)) ...
                & TimeStamps_VT<=Int(i,mazei(ii,2)));
            % find timing values based on index
            data.times{ii,i} = (TimeStamps_VT(data.loc_idx{ii,i}))/1e6;
            % find x and y positional coordinates based on location index
            data.X{ii,i} = ExtractedX(data.loc_idx{ii,i});
            data.Y{ii,i} = ExtractedY(data.loc_idx{ii,i});
        end
    end
end

% is startbox defined?
if exist('mazesb')==1 
    % get data from startbox occupancy
    for i = 1:size(Int,1)-1
        data.loc_idx{size(mazei,1)+1,i} = find(TimeStamps_VT>=...
            Int(i,mazesb(1)) & TimeStamps_VT<=Int(i+1,mazesb(2)));
        data.times{size(mazei,1)+1,i} = (TimeStamps_VT(data.loc_idx...
            {size(mazei,1)+1,i}))/1e6;
        data.X{size(mazei,1)+1,i} = ExtractedX(data.loc_idx{size(mazei,1)+1,i});
        data.Y{size(mazei,1)+1,i} = ExtractedY(data.loc_idx{size(mazei,1)+1,i});
    end
else
end

% plot startbox
close all
if exist('mazesb') == 1
    for i = 1:size(data.loc_idx,2)
        for ii = 1:(size(mazei,1))+1 % plus one for startbox
            figure(); plot(data.X{ii,i},data.Y{ii,i})

            rectangle ('position', rRW_fld);  %rRW
            rectangle ('position', lRW_fld);  %lRW
            rectangle ('position', STM_fld);  %Stem
            rectangle ('position', PED_fld);  %Box
            rectangle ('position', CP_fld);   %CP
            rectangle ('position', GAL_fld);  %GAL
            rectangle ('position', GAR_fld);  %GAR
            rectangle ('position', RAL_fld);  %RAL
            rectangle ('position', LAL_fld);  %LAL

            pause
        end
    end
end

% plot maze
if exist('mazei') == 1
    for i = 1:size(data.loc_idx,2)
        for ii = 1:size(mazei,1) % plus one for startbox
            figure(); plot(data.X{ii,i},data.Y{ii,i})

            rectangle ('position', rRW_fld);  %rRW
            rectangle ('position', lRW_fld);  %lRW
            rectangle ('position', STM_fld);  %Stem
            rectangle ('position', PED_fld);  %Box
            rectangle ('position', CP_fld);   %CP
            rectangle ('position', GAL_fld);  %GAL
            rectangle ('position', GAR_fld);  %GAR
            rectangle ('position', RAL_fld);  %RAL
            rectangle ('position', LAL_fld);  %LAL

            pause
        end
    end 
end
