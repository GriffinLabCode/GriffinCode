%% detect doublets
% code was designed to detect doublets in peak_datas and troughs of filtered
% data for calculating theta asymmetry
%
% -- inputs -- %
% peak_data: index of peaks (x-axis if you plotted phase values out)
% trough_data: index of troughs
% input_arg: can be 'ascending' or 'descending'
%
% -- outputs -- %
% IMPORTANT: peaks/troughs are filtered depending on if you plan to
% calculate descending or ascending lengths
%
% peak_out: peaks filtered for doublets
% trough_out: troughs filtered for doublets

function [peak_out,trough_out] = correct_doublets(peak_data,trough_data,input_arg)

% peak_datas are 2s, troughs are 1s
peak_data(:,2)   = 2;
trough_data(:,2) = 1;

% concatenate data into one vector
peak_data_troughs = vertcat(trough_data,peak_data);

% sort the data
[~,sort_idx] = sort(peak_data_troughs,1);
doubleDetect = peak_data_troughs(sort_idx(:,1),2);

if contains(input_arg,'descending')
    
    % use doubledetect to get sort_idx, then use sort_idx to get peak_datas_troughs
    for i = 1:length(doubleDetect)-1

        % if there is double peak_data, and we're doing descending, remove the first
        % peak_data in the doublet pair

        % detect doublets in peak_data
        if doubleDetect(i) == doubleDetect(i+1) & (doubleDetect(i) == 2 & doubleDetect(i+1) == 2)
            % get the index of sorted values to go back to peak_datas_troughs
            idxRem = sort_idx(i,1); % get the very first value
            % get peak_datas_troughs value that lets us go back to peak_data
            idxRem2 = peak_data_troughs(idxRem);
            % get peak_data
            idxNan  = find(peak_data == idxRem2);
            % set peak_data to nan
            peak_data(idxNan) = NaN;

        % detect doublets in troughs    
        elseif doubleDetect(i) == doubleDetect(i+1) & (doubleDetect(i) == 1 & doubleDetect(i+1) == 1)

            % get the index of sorted values to go back to peak_datas_troughs
            idxRem = sort_idx(i+1,1); % delete the second trough
            % get peak_datas_troughs value that lets us go back to peak_data
            idxRem2 = peak_data_troughs(idxRem);
            % get trough
            idxNan  = find(trough == idxRem2);
            % set trough to nan
            trough_data(idxNan) = NaN;            
        end
    end

elseif contains(input_arg,'ascending')
    
    % use doubledetect to get sort_idx, then use sort_idx to get peak_datas_troughs
    for i = 1:length(doubleDetect)-1

        % if there is double peak_data, and we're doing descending, remove the first
        % peak_data in the doublet pair

        % detect doublets in peak_data
        if doubleDetect(i) == doubleDetect(i+1) & (doubleDetect(i) == 2 & doubleDetect(i+1) == 2)
            
            % get the index of sorted values to go back to peak_datas_troughs
            idxRem = sort_idx(i+1,1); % get the second value
            % get peak_datas_troughs value that lets us go back to peak_data
            idxRem2 = peak_data_troughs(idxRem);
            % get peak_data
            idxNan  = find(peak_data == idxRem2);
            % set peak_data to nan
            peak_data(idxNan) = NaN;

        % detect doublets in troughs    
        elseif doubleDetect(i) == doubleDetect(i+1) & (doubleDetect(i) == 1 & doubleDetect(i+1) == 1)

            % get the index of sorted values to go back to peak_datas_troughs
            idxRem = sort_idx(i,1); % delete the first trough
            % get peak_datas_troughs value that lets us go back to peak_data
            idxRem2 = peak_data_troughs(idxRem);
            % get trough
            idxNan  = find(trough == idxRem2);
            % set trough to nan
            trough_data(idxNan) = NaN;      
        end
    end 
    
end

% remove second columns
trough_data(:,2) = [];
peak_data(:,2)   = [];

% remove nans
peak_data(isnan(peak_data))=[];
trough_data(isnan(trough_data))=[];

% set up outputs
peak_out   = peak_data;
trough_out = trough_data;


