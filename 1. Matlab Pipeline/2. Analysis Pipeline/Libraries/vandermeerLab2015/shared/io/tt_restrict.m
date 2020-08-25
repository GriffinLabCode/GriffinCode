function tt_restrict(cfg_in)
%
% function tt_restrict(cfg_in)
%
% restrict tetrode file(s) to specified interval
%
% defaults:
%
% cfg_def.fc = []; % cell array with filenames, if empty all *.ntt
% cfg_def.t = []; % 2-element array with start and end times (in s) 
%  of interval, prompt user using vt data if empty
%
% MvdM 2015-07-30 initial version
%  --could add option to set output filename(s)

cfg_def.fc = []; % cell array with filenames, if empty all *.ntt
cfg_def.t = [];

cfg = ProcessConfig2(cfg_in,cfg_def);

if isempty(cfg.t) % prompt user
    
    pos = LoadPos([]); % assumes VT1.nvt present
    
    f = figure;
    plot(pos.tvec,getd(pos,'x'),'.');
    title('Select interval to keep (start and end times):');
    
    cfg.t = ginput(2);
    cfg.t = cfg.t(:,1); % get points on horizontal axis (time)
    
    close(f);
    
end
cfg.t = cfg.t * 10^6; % convert to microseconds

% construct file list
if isempty(cfg.fc)

    cfg.fc = FindFiles('*.ntt');
    if isempty(cfg.fc)
        error('No tetrode files found.');
    end
    
end

% load and restrict
for iTT = 1:length(cfg.fc)
    
    fname_in = cfg.fc{iTT};
            
    fprintf('Processing tt %s...\n',fname_in);
    
    % load tt
    [ttin.Timestamps, ttin.ScNumbers, ttin.CellNumbers, ttin.Features, ttin.Samples, ...
        ttin.Header] = Nlx2MatSpike(fname_in, [1 1 1 1 1], 1, 1, []);
    
    keep_idx = ttin.Timestamps > cfg.t(1) & ttin.Timestamps < cfg.t(2);
    
    % save tt
    
    [fp fn fe] = fileparts(fname_in);
    fname_out = cat(2,fn,'r',fe);
    
    Mat2NlxSpike(fname_out, 0, 1, [], [1 1 1 1 1], ttin.Timestamps(keep_idx), ttin.ScNumbers(keep_idx), ttin.CellNumbers(keep_idx), ttin.Features(:,keep_idx), ttin.Samples(:,:,keep_idx), ttin.Header);
    
end