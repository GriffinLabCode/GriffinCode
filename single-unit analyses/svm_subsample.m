%% svm subsample
%
% INPUT: svm_data - look at svm_taskphase for an example of how its made
%
% OUTPUT: subsamplde_svmData - subsampled svm_data to match svm_data size
%         sub_idx - an index of subsampled values
%
% written by John Stout

function [subsampled_svmData,sub_idx] = svm_subsample(svm_data,input)
    for row = 1:size(svm_data,1)
        for col = 1:size(svm_data,2)
                % create an index to subsample
                sub_idx{row,col} = randsample(1:length(svm_data...
                    {row,col}),input.n_samples);

                % subsample based on random index
                subsampled_svmData{row,col} = svm_data{row,col}...
                    (:,sub_idx{row,col}); 
        end    
    end  
end