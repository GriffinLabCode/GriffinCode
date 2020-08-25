function proceed = checkTmazeReqs(cfg_in)
%CHECKTMAZEREQS Verify that requisites exist before continuing analysis
% ExpKeys, metadata, VT file, candidates, times (R042 only), files (for
% stuff generated during analysis)
% Does not check deeper than the first level of fields in a struct.
% Displays missing items in the command window. problem = 1 if anything is
% missing (can be used as a flag to hault further analysis or w/e)
%
% cfg_def.checkall = 0; or 1 check everything; function knows all Tmaze ExpKeys 
% and metadata fields (unless additional ones were added after this was
% written)
%
%cfg_def.requireExpKeys = 0;
%cfg_def.ExpKeysFields = {}; list of strings specifying field names
%           ex: {'nTrials','badTrials'}
%cfg_def.requireMetadata = 0;
%cfg_def.MetadataFields = {}; list of strings specifying field names
%cfg_def.requireVT = 0;
%cfg_def.requireCandidates = 0;
%cfg_def.requireTimes = 0; for R042 only
%cfg_def.requireHSdetach = 0; for R044 only
%cfg_def.requireFiles = 0; files folder for images generated during
%analysis
%
% ACarey May 2015, for Tmaze project 

%% 
if isempty(cfg_in)
    disp('checkTmazeReqs: cfg is empty, not checking requisites')
    proceed = 1;
    return
end

cfg_def.checkall = 0;

cfg_def.requireExpKeys = 0;
cfg_def.ExpKeysFields = {};
cfg_def.requireMetadata = 0;
cfg_def.MetadataFields = {};
cfg_def.requireVT = 0;
cfg_def.requireCandidates = 0;
cfg_def.requireTimes = 0;
cfg_def.requireHSdetach = 0;
cfg_def.requireFiles = 0;

cfg = ProcessConfig2(cfg_def,cfg_in);
cfg.verbose = 1; % i want checkfields to tell me which ones are missing

if cfg.checkall
    cfg.requireExpKeys = 1;
    cfg.ExpKeysFields = {'Behavior','RestrictionType','Session','Layout','Pedestal','pathlength','patharms','realTrackDims','convFact','nPellets','waterVolume','nTrials','forcedTrials','nonConsumptionTrials','badTrials','TimeOnTrack','TimeOffTrack','prerecord','task','postrecord','goodSWR','goodTheta'};
    cfg.requireMetadata = 1;
    cfg.MetadataFields = {'coord','taskvars','SWRtimes','SWRfreqs'};
    cfg.requireVT = 1;
    cfg.requireCandidates = 1;
    cfg.requireTimes = 1; % R042 only
    def.requireHSdetach = 1; % R044 only
    cfg.requireFiles = 1;
end
%% 

if ispc
    machinename = getenv('COMPUTERNAME');
else
    machinename = getenv('HOSTNAME');
end

switch machinename
    
    case 'ISIDRO'
        base_fp = 'C:\data\';
    case 'EQUINOX'
        base_fp = 'D:\data\';
    case 'MVDMLAB-ATHENA'
        base_fp = 'D:\vandermeerlab\';
    case 'MVDMLAB-EUROPA'
        base_fp = 'D:\data\promoted\';
    case 'DIONYSUS'
        base_fp = 'D:\data\promoted\';
end

%%

proceed = 1;

% Remember where you started
original_folder = pwd; % pwd is your current directory ("print working directory")

% cd to the main directory
cd(base_fp);

% Work though each rat's folder
rat_list = dir(pwd); % dir() lists folder contents

% It seems that MATLAB pulls up some crap "folders" that are called "." or ".." ... ignore them  
rat_list = rat_list(arrayfun(@(x) x.name(1), rat_list) ~= '.');

for iRat = 1:length(rat_list)
    
    % go to the rat's folder
    ratfolder = [base_fp,rat_list(iRat).name]; % when strcat is applied to this array, it will create the folder path
    cd(strcat(ratfolder));
    
    % Get all the sessions
    session_list = dir(pwd);
    session_list = session_list(arrayfun(@(x) x.name(1), session_list) ~= '.');
   
    for iSession = 1:length(session_list)
        session = [ratfolder,'\',session_list(iSession).name]; 
        cd(strcat(session));
        [~,sessionID,~] = fileparts(session);

        % now we're in the folder for a specific session; verify that we have
        %requisites...if not, say so:
        
        if cfg.requireExpKeys
            fn = FindFiles('*keys.m');
            if isempty(fn)
                disp(['ExpKeys file not found in ',sessionID])
                proceed = 0;
            end
            if ~isempty(fn) && ~isempty(cfg.ExpKeysFields)
                [ismissing,~] = checkfields(cfg,'*keys.m',cfg.ExpKeysFields);
                if ismissing
                    proceed = 0;
                end
            end
        end
        
        if cfg.requireMetadata
            fn = FindFiles('*metadata.mat');
            if isempty(fn)
                disp(['metadata file not found in ',sessionID])
                proceed = 0;
            end
            if ~isempty(fn) && ~isempty(cfg.MetadataFields)
                [ismissing,~] = checkfields(cfg,'*metadata.mat',cfg.MetadataFields);
                if ismissing
                    proceed = 0;
                end
            end
        end
        
        if cfg.requireVT
            fn = FindFiles('*.nvt');
            if isempty(fn)
                disp(['Video tracking file not found in ',sessionID])
                proceed = 0;
            end
        end
        
        if cfg.requireCandidates
            fn = FindFiles('*candidates.mat');
            if isempty(fn)
                disp(['Candidates file not found in ',sessionID])
                proceed = 0;
            end
        end
        
        if cfg.requireTimes && strcmp(rat_list(iRat).name,'R042') % for R042 only
            fn = FindFiles('*-times.mat');
            if isempty(fn)
                disp(['Times file not found in ',sessionID])
                proceed = 0;
            end
        end   
        if cfg.requireTimes && sum(strcmp(sessionID,{'R044-2013-12-21','R044-2013-12-22'})) >= 1 % for these sessions only
            fn = FindFiles('*HS_detach_times.mat');
            if isempty(fn)
                disp(['HS_detach_times file not found in ',sessionID])
                proceed = 0;
            end
        end
        
        if cfg.requireFiles 
            if ~exist('files','dir')
                disp(['Files folder not found in ',sessionID])
                proceed = 0;
            end
        end 
        
    end
    if ~proceed 
        disp(' ') % for formatting, kind of
    end
end
if proceed
    disp('checkTmazeReqs: all requisites exist')
end
% return to the original folder
cd(original_folder)
end

