%% tells you where the timing of interest tends to correspond on the maze
%
% INPUTS:
% datafolder
% Int
%
% OUTPUTS:
% pos_X: cell array containing trial dependent locations
% pos_Y: cell array containing trial dependent locations
%
% written by John Stout

function [pos_X,pos_Y,ExtractedX,ExtractedY] = rat_location(datafolder,Int)

        %% load VT data
        load(strcat(datafolder,'\VT1.mat'));
        load(strcat(datafolder,'\Events.mat'));

        %% interpolate missing data
        [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
        
        % convert to cm
        ExtractedX = round(ExtractedX./2.09);
        ExtractedY = round(ExtractedY./2.04);
        
        %%  Extract location data
        for triali=1:size(Int,1) % trial

            % on Int being defined as sample or choice Int 
            time = [];
            %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5)+(1*1e6))];
            %time = [(Int(triali,6)-(2*1e6)) (Int(triali,6))];
            %time = [(Int(triali,1)) (Int(triali,1)+(2*1e6))];   
     % time = [(Int(triali,1)) (Int(triali,1)+(2*1e6))]; 
      %time = [(Int(triali,6)-(1*1e6)) (Int(triali,6))];  
    time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];  
            %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5))];
            %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];            
            %time = [(Int(triali,1)) (Int(triali,1)+(1*1e6))];
            %time = [(Int(triali,1)) (Int(triali,6))];
            %time = [(Int(triali,1)+0.5*1e6) (Int(triali,6)-(0.5*1e6))];            
            %time = [(Int(triali,1)+(0.5*1e6)) (Int(triali,1)+(1.5*1e6))];

            pos_X{triali} = ExtractedX(TimeStamps_VT > time(1,1) & TimeStamps_VT < time(1,2));
            pos_Y{triali} = ExtractedY(TimeStamps_VT > time(1,1) & TimeStamps_VT < time(1,2));

        end
      

end

