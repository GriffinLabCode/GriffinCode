%% tells you where the timing of interest tends to correspond on the maze
% this code is useful if you are in the time domain and want to visualize
% the animals position in your epoch. 
%
% INPUTS:
% datafolder
% Int
% vt_name = vt file name
% missing_data = how to handle missing vt data: 'exclude', 'interp',
% 'ignore'
%
% OUTPUTS:
% pos_X: cell array containing trial dependent locations
% pos_Y: cell array containing trial dependent locations
%
% written by John Stout

function [pos_X,pos_Y,ExtractedX,ExtractedY] = rat_location_time2pos(datafolder,Int,vt_name,missing_data)

        %% load VT data
        % if you cd to datafolder, you don't have to worry about issues
        % loading the converted .mat folders if they were converted using a
        % different directory.
        cd(datafolder);
        [ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);
        %load('Events.mat');
        
        %%  Extract location data
    for lagi = 1:5        
        for triali=1:size(Int,1) % trial

            time = [];

            if lagi == 1 
                time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)-(1.5*1e6))];
            elseif lagi == 2
                time = [(Int(triali,5)-(1.5*1e6)) (Int(triali,5)-(1*1e6))];                                        
            elseif lagi == 3 
                time = [(Int(triali,5)-(1*1e6)) (Int(triali,5)-(0.5*1e6))]; 
            elseif lagi == 4
                time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))]; 
            elseif lagi == 5
                time = [(Int(triali,5)) (Int(triali,5)+(0.5*1e6))]; 
            elseif lagi == 6
                time = [(Int(triali,5)+(0.5*1e6)) (Int(triali,5)+(1*1e6))];                 
            end
                
            
            pos_X{lagi}{triali} = ExtractedX(TimeStamps_VT > time(1,1) & TimeStamps_VT < time(1,2));
            pos_Y{lagi}{triali} = ExtractedY(TimeStamps_VT > time(1,1) & TimeStamps_VT < time(1,2));

        end
    end
      

end

