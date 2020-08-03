%% get L-ratio 
%
% This function utilizes David Redish MClust L_ratio to estimate L_ratio. 
% It should be used over SpikeSort3D, since the neuralynx program fails to
% estimate L-ratios using less than 4 wires. This method was published by
% Schmitzer Torbert et al., 2005 from the Redish lab
%
% Note: this function will provide L-ratios that are not consistent with
%       spikesort3D. Not really sure why, but this function would be an
%       iteration of the one used in the original Schmitzer et al., 2005
%       paper from the Redish lab suggesting the usage of L-ratio.
%
% INPUTS
%
% Samples: a 32x4xN 3D array containing spike data. 32 samples per ms, 4
%           channels (tetrode), N spikes
% Features: an 4xN array containing peak and troughs for each spike. Use
%           the first 4 features (Schmitzer-Torbert et al., 2005). If only
%           3 avaialble, use the first 3, etc...
%            recordings from 4 wires) x N number of spikes
% CellNumbers: a vector whereby the number denotes a spike belonging to a
%               specific cluster. For example, if CellNumbers(1)=1, that
%               spike came from cluster 1. If CellNumbers(1)=0, that spike
%               was from the noise distribution
% OUTPUTS
%
% Lratio: Schmitzer-Torbert et al., 2005 from Redish labs statistical 
%          estimation of a cluster. The function used is directly from the
%          MClust toolbox from the Redish lab - free online.
%
% written by John Stout

function [Lratio] = get_Lratio(Samples,Features,CellNumbers)    
    %% Check that all channels recorded data
    % create an index for channels that have and do not have zeros
    chan_zeros   = find(Samples(1,:,1)==0);
    chan_notzero = find(Samples(1,:,1)~=0);
    
    if isempty(chan_zeros) == 0
    
        % report the number of missing channels
        num_missing_wires = length(chan_zeros);

        % remove missing data from Features and Samples
            % first save old data
            Features_og = Features;
            Samples_og = Samples;
            % remove missing channels
            Features(find(Features(:,1)==0),:)=[];
            Samples(:,chan_zeros,:)=[];
            % set a warning if there are still missing channels
            if isempty(find(Samples(1,:,1)==0))==0
                disp('Still missing channels - error in function')
                return
            end
    else
        disp('all wires recorded data')
    end
        
    %% utilize MClust L_Ratio function
        % define FD (Nspikes x Ddimentional feature space)
        FD = Features';
    
        % ClusterSpikes: Index into FD which lists spikes from the cell whose quality is to be evaluated.
        num_cells = unique(CellNumbers);
    
        % remove 0 - it's noise
        num_cells(num_cells==0)=[];
    
        for i = 1:length(num_cells)
            clust_idx{i} = find(CellNumbers == num_cells(i));
        end
        
        % tested this - it checks out
        for i = 1:length(clust_idx)
            ClusterSpikes = [];
            ClusterSpikes = clust_idx{i};
            % had to save this to a sep folder
            [output, m] = L_Ratio(FD, ClusterSpikes);
            Lratio(i) = output.Lratio;
        end
end
        
