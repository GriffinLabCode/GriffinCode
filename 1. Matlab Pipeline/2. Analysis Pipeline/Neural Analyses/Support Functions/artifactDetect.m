%% artifact detection
% this method was tested and seems to successfully detect artifacts. The
% method is simple, using some online detected 'data', you transform it
% into standard deviations by comparing it against a baseline mean and
% baseline standard deviation
%
% see the video here: https://www.loom.com/share/d2c5f29cb3b241aca3b7821fcf1ad657
% and here: https://www.loom.com/share/f60fa34dbd0e4deea4c831602a288260
%
% this method is on the conservative side, but it seems to successfully
% extract and detect noise events for the purpose of ignoring them in
% on-line coherence detection
%
% IF YOU ARE USING THIS ON YOUR DATA:
% --> FIRST, RUN get_artifactBaseline for all sessions <--
%
% -- INPUTS -- %
% data: a 2(row) by N (col) array of data. Each row of data is LFP that
%       should be treated the SAME as it was for baseline detection. If
%       using 'baselineDetection', then the data was detrended (not
%       cleaned) using locdetrend.
%
% baselineMean: the output from baselineDetection, average LFP
% baselineSTD: another output from baselineDetection, standard deviation
%               LFP
% noiseThreshold: Optional. In standard deviations. Preset to 4 standard
%                   deviations, such that signals who's LFP exceeds 4
%                   standard deviations from the mean are considered noise.
%                   This was visually confirmed. You should try this
%                   separately on your dataset before using the preset.
%
% -- OUTPUTS -- %
% idxNoise: an index that tells you if you have any noise events. If empty,
%           you are good.
% zArtifact: the zscore transformed LFP data
%
% written by John Stout

function [percentSat,idxNoise,zArtifact] = artifactDetect(data,baselineMean,baselineSTD,noiseThreshold)

% zscore data against your defined mean and std
zArtifact = [];
zArtifact(1,:) = ((data-baselineMean)./baselineSTD);

% using a std threshold of 4, detect instances of clipping or large
% movement artifacts or other sources of noise like scratching
if exist('noiseThreshold')==0 || isempty(noiseThreshold)==1
    noiseThreshold = 4;
end

% this is telling us that if there is a detected artifact in the positive
% going voltage direction, or the negative going voltage direction, then
% identify it   
idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold);

% saturation
percentSat = (numel(idxNoise)/numel(zArtifact))*100;


