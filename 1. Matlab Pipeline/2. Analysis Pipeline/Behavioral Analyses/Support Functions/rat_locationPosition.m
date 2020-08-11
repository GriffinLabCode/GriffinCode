%% tells you where the timing of interest tends to correspond on the maze
% this code is useful if you are in the time domain and want to visualize
% the animals position in your epoch. 
%
% INPUTS:
% datafolder
% Int
% vt_name: video track file name
% missing_data: 'interp','exclude',or 'ignore'
% stemDir: the orientation of stem (can be X, oriented in the X dimension, 
%           or Y, oriented in the Y dimension)
% stemMin: minimum stem coordinate
% stemMax: maximum stem (or T-exit) coordinate
% numbins: number of bins to consider
%
% OUTPUTS:
% pos_X: cell array containing trial dependent locations
% pos_Y: cell array containing trial dependent locations
%
% written by John Stout last edit 3/4/2020

function [pos_X,pos_Y,times,ExtractedX,ExtractedY] = rat_locationPosition(datafolder,Int,vt_name,missing_data,stemDir,stemMin,stemMax,numbins)

        %% load VT data
        % if you cd to datafolder, you don't have to worry about issues
        % loading the converted .mat folders if they were converted using a
        % different directory.
        cd(datafolder);
        
        % make this flexible?
        load('Events','-regexp', ['^(?!' [datafolder] ')\w']);

        %% interpolate missing data
        [ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);
        
        %% bins
        %numbins = 8; % was 8
        %ymin = 135; % do not underestimate - you'll end up in start-box
        %ymax = 400; % over estimate - this doesn't hurt anything
        bins = round(linspace(stemMin,stemMax,numbins));
        
        %%  Extract location data       
        for triali=1:size(Int,1) % trial

            time = [];
            
            time = [(Int(triali,1)) (Int(triali,6))];

            % get position data and store in temporary variable
            pos_XTemp = ExtractedX(TimeStamps > time(1,1) & TimeStamps < time(1,2));
            pos_YTemp = ExtractedY(TimeStamps > time(1,1) & TimeStamps < time(1,2));
            ts_Temp   = TimeStamps(TimeStamps > time(1,1) & TimeStamps < time(1,2));
            
            % account for maze orientation
            if contains(stemDir,'Y') || contains(stemDir,'y')
                pos_temp = pos_YTemp;
            elseif contains(stemDir,'X') || contains(stemDir,'x')
                pos_temp = pos_XTemp;
            end
            
            for j = 1:length(bins)-1
                % get an index of position data binned by y axis
                pos_idx = find(pos_temp >= bins(j) & pos_temp <= bins(j+1));
                
                % get data from index and store the data trial by trial,
                % bin by bin.
                pos_X{triali}{j} = pos_XTemp(pos_idx);
                pos_Y{triali}{j} = pos_YTemp(pos_idx);
                times{triali}{j} = ts_Temp(pos_idx);
            end
        end
      

end

