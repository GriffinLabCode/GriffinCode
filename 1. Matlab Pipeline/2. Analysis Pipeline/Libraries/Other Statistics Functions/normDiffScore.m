%% calculate normalized difference score
%
% -- INPUTS -- %
% mat: data in matrix format where the rows are observations of the
%       variables, and the columns are the variables. For example, in
%       Hallock et al., 2016 (Journal of neuroscience - ventral midline
%       thalamus...), Fig. 8B, you would have a matrix of 6 columns, with
%       rows indicating percent accuracy for each animal. The 6 columns
%       would be broken down to (baseline 1, baseline 2, baseline, saline,
%       baseline, muscimol) where there were 3 days for each condition
%       (baseline only, saline, muscimol). Thus, your grouping_idx would be
%       [1 3 5] where 1 tells you the start of day 1, 3 tells you the start
%       of day 2, and 5 tells you the start of day 3. 
%
%           To further demonstrate: 
%               mat = abs(rand([6 6])); % 6 subjects (rows), 6 conditions (columns)
%               grouping_idx = 1:2:size(mat,2); % if this were empty, diff score for each column
%
% grouping_idx: (optional, but highly suggested) vector that indicates 
%                   which variables to compare. This is optional, but if
%                   you do not define it, it will automatically assume that
%                   your data is organized in a manner consistent with
%                   above (ie columns 2 and 3 will never be compared, but
%                   columns 1 and 2, 3 and 4, 5 and 6, 7 and 8, etc...
%                   willl be).
%
% -- OUTPUTS -- %
% normDiff.data: normalized difference score (difference / sum)
% normDiff.info: information about the score

function [normDiff] = normDiffScore(mat,grouping_idx)

% data must be organized as a matrix, where columns are the variables of
% interest, and rows are observations of that variable. If you do not
% specify grouping_idx, this function will calculate a normalized
% difference score between each row
if exist('grouping_idx') == 0
    grouping_idx = 1:2:size(mat,2);
end

% normalized difference is the difference / sum
for i = 1:length(grouping_idx)
    normDiff(:,i) = (mat(:,grouping_idx(i)+1)-(mat(:,grouping_idx(i))))./...
        (mat(:,grouping_idx(i)+1)+(mat(:,grouping_idx(i))));
end

    


