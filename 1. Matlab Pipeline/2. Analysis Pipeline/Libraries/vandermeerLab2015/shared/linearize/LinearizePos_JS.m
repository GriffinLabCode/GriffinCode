function linpos_tsd = LinearizePos(cfg_in,pos_tsd)
% function linpos_tsd = LinearizePos(cfg,pos_tsd)
%
% linearizes (x,y) position data
%
% INPUTS:
%
% pos_tsd: input position tsd (must have x,y fields)
%
% OUTPUTS:
%
% linpos_tsd: tsd with linearized position (z field) and distance (z_dist)
%
% cfg.Coord: Coord file geneated by makeCoord, if not defined tries to load

cfg_def.Coord = [];
cfg = ProcessConfig2(cfg_def,cfg_in); % remember this will overwrite Coord if defined in cfg

mfun = mfilename;

disp('LinearizePos.m: linearizing data...');


% implementing
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18';
load('Int_file.mat')
load('VT1.mat')
[ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);   
IntL = Int(find(Int(:,3)==1),:);
IntR = Int(find(Int(:,3)==0),:);

% try to load Coord file if not specified
if isempty(cfg.Coord)
   
    fn = FindFiles('*Coord.mat','CheckSubdirs',0);
    
    if length(fn) > 1
       error('More than one Coord file found. Specifiy file to use in cfg.'); 
    else
        fn = fn{1};
    end
    
    load(fn);
    cfg.Coord = Coord;
    
end

% init output variable
linpos_tsd = tsd; linpos_tsd.cfg = pos_tsd.cfg;

% set up vars for linearize
x = getd(pos_tsd,'x'); y = getd(pos_tsd,'y');

NN = repmat(NaN,size(x));
f_use = find(~isnan(x) & ~isnan(y));

if cfg.Coord(1,1) == cfg.Coord(1,end) & cfg.Coord(2,1) == cfg.Coord(2,end)
    cfg.Coord = cfg.Coord(:,1:end-1);
end

% get Coord points nearest to each x,y pair
NN(f_use) = griddata(cfg.Coord(1,:),cfg.Coord(2,:),1:length(cfg.Coord),x(f_use),y(f_use),'nearest');

clear NN d
for i = 1:length(IntL)
    xLeft{i} = ExtractedX(TimeStamps_VT >= IntL(i,1) & TimeStamps_VT <= IntL(i,8));
    yLeft{i} = ExtractedY(TimeStamps_VT >= IntL(i,1) & TimeStamps_VT <= IntL(i,8));
    
    % get coordinate points between idealize trajectory and real data
    NN{i} = griddata(coord.coordL(1,:),coord.coordL(2,:),1:length(coord.coordL),xLeft{i},yLeft{i},'nearest');

    % get distance
    d{i} = sqrt((coord.coordL(1,ceil(NN{i}))-xLeft{i}).^2 + (coord.coordL(2,ceil(NN{i}))-yLeft{i}).^2);
end

figure(); plot(NN{i},d{i})

figure(); plot(NN{1})
figure(); plot(d{1},NN{1})
% also get distance
d = sqrt((cfg.Coord(1,ceil(NN(f_use))) - x(f_use)).^2 + (cfg.Coord(2,ceil(NN(f_use))) - y(f_use)).^2);

% assemble output tsd
linpos_tsd.tvec = pos_tsd.tvec;

linpos_tsd.data(1,:) = NN;
linpos_tsd.label{1} = 'z';

linpos_tsd.data(2,:) = d;
linpos_tsd.label{2} = 'z_dist';


% housekeeping
linpos_tsd.cfg.history.mfun = cat(1,linpos_tsd.cfg.history.mfun,mfun);
linpos_tsd.cfg.history.cfg = cat(1,linpos_tsd.cfg.history.cfg,{cfg});

