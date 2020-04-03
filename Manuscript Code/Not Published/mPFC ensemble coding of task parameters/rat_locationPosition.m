%% tells you where the timing of interest tends to correspond on the maze
% this code is useful if you are in the time domain and want to visualize
% the animals position in your epoch. 
%
% INPUTS:
% datafolder
% Int
%
% OUTPUTS:
% pos_X: cell array containing trial dependent locations
% pos_Y: cell array containing trial dependent locations
%
% written by John Stout last edit 3/4/2020

function [pos_X,pos_Y,ExtractedX,ExtractedY] = rat_locationPosition(datafolder,Int)

        %% load VT data
        % if you cd to datafolder, you don't have to worry about issues
        % loading the converted .mat folders if they were converted using a
        % different directory.
        cd(datafolder);
        load('VT1.mat');
        load('Events.mat');

        %% interpolate missing data
        addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
        addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')

        [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
        
        % convert to cm
        ExtractedX = round(ExtractedX);
        ExtractedY = round(ExtractedY);
        
        %% bins
        numbins = 8; % was 8
        ymin = 135; % do not underestimate - you'll end up in start-box
        ymax = 400; % over estimate - this doesn't hurt anything
        bins = round(linspace(ymin,ymax,numbins));
        
        %%  Extract location data       
        for triali=1:size(Int,1) % trial

            time = [];
            
            time = [(Int(triali,1)) (Int(triali,6))];

            % get position data and store in temporary variable
            pos_XTemp = ExtractedX(TimeStamps_VT > time(1,1) & TimeStamps_VT < time(1,2));
            pos_YTemp = ExtractedY(TimeStamps_VT > time(1,1) & TimeStamps_VT < time(1,2));
            
            for j = 1:length(bins)-1
                % get an index of position data binned by y axis
                pos_idx = find(pos_YTemp >= bins(j) & pos_YTemp <= bins(j+1));

                % get data from index and store the data trial by trial,
                % bin by bin.
                pos_X{triali}{j} = pos_XTemp(pos_idx);
                pos_Y{triali}{j} = pos_YTemp(pos_idx);
            end
        end
      

end

