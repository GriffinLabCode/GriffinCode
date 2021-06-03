%% new int method

% inputs
load('Int_information')
datafolder = pwd;
missing_data = 'exclude';
vt_name = 'VT1.mat';

%% pull in video tracking data
% meat
[x,y,t] = getVTdata(datafolder,missing_data,vt_name);

% number of position samples
numSamples = length(t);

%% define rectangles for all coordinates

% stem
xv_stem = [STM_fld(1)+STM_fld(3) STM_fld(1) STM_fld(1) STM_fld(1)+STM_fld(3) STM_fld(1)+STM_fld(3)];
yv_stem = [STM_fld(2) STM_fld(2) STM_fld(2)+STM_fld(4) STM_fld(2)+STM_fld(4) STM_fld(2)];

% choice point
xv_cp = [CP_fld(1)+CP_fld(3) CP_fld(1) CP_fld(1) CP_fld(1)+CP_fld(3) CP_fld(1)+CP_fld(3)];
yv_cp = [CP_fld(2) CP_fld(2) CP_fld(2)+CP_fld(4) CP_fld(2)+CP_fld(4) CP_fld(2)];

% left reward field
xv_lr = [lRW_fld(1)+lRW_fld(3) lRW_fld(1) lRW_fld(1) lRW_fld(1)+lRW_fld(3) lRW_fld(1)+lRW_fld(3)];
yv_lr = [lRW_fld(2) lRW_fld(2) lRW_fld(2)+lRW_fld(4) lRW_fld(2)+lRW_fld(4) lRW_fld(2)];

% right reward field
xv_rr = [rRW_fld(1)+rRW_fld(3) rRW_fld(1) rRW_fld(1) rRW_fld(1)+rRW_fld(3) rRW_fld(1)+rRW_fld(3)];
yv_rr = [rRW_fld(2) rRW_fld(2) rRW_fld(2)+rRW_fld(4) rRW_fld(2)+rRW_fld(4) lRW_fld(2)];

% startbox
xv_sb = [PED_fld(1)+PED_fld(3) PED_fld(1) PED_fld(1) PED_fld(1)+PED_fld(3) PED_fld(1)+PED_fld(3)];
yv_sb = [PED_fld(2) PED_fld(2) PED_fld(2)+PED_fld(4) PED_fld(2)+PED_fld(4) lRW_fld(2)];

%% identify where each sample in the position data belongs to

% stem 
[in_stem,on_stem] = inpolygon(x,y,xv_stem,yv_stem);

% choice point
[in_cp,on_cp] = inpolygon(x,y,xv_cp,yv_cp);

% left reward field 
[in_lr,on_lr] = inpolygon(x,y,xv_lr,yv_lr);

% right reward field 
[in_rr,on_rr] = inpolygon(x,y,xv_rr,yv_rr);

% startbox 
[in_sb,on_sb] = inpolygon(x,y,xv_sb,yv_sb);

%% loop across data, identify entry and exit points and get timestamps

% intialize some variables
stem_entry     = [];
cp_entry       = []; % is stem exit
goalArm_entry  = []; % is choice point exit
goalZone_entry = []; % is goal arm exit
retArm_entry   = []; % is goal field exit
startBox_entry = []; % is return arm exit
trajectory     = [];

for i = 2:numSamples-1
 
    
    % if the rat is not in the stem
    if (in_sb(i) == 1 || on_sb(i) == 1) && in_sb(i-1) == 0 && in_sb(i+1) == 1
        startBox_entry = [startBox_entry t(i)];
    end       

    % if the rat is not in the cp, is not in the stem, is not in the goal
    % fields, is not in the startbox, but his last position was in either
    % the left or the right goal fields, and his next coordinate is in no
    % location previously covered, then hes in the return arms
    if in_stem(i) == 0 && in_cp(i) == 0 && in_lr(i) == 0 && in_rr(i) == 0 && ...
            in_sb(i) == 0 && ((in_lr(i-1) == 1 || on_lr(i-1) == 1) || (in_rr(i-1) == 1 || on_rr(i-1) == 1)) ...
            && in_stem(i+1) == 0 && in_cp(i+1) == 0 && in_lr(i+1) == 0 && in_rr(i+1) == 0 ...
            && in_sb(i+1) == 0
        retArm_entry = [retArm_entry t(i)];
    end   
    
    % if the rat is in the left reward field or on it, but didn't used to
    % be in the field nor on it, but his next coordinate is in it
    if (in_lr(i) == 1 || on_lr(i) == 1) && (in_lr(i-1) == 0 && on_lr(i-1) == 0) && (in_lr(i+1) == 1 || on_lr(i+1) == 1)
        goalZone_entry = [goalZone_entry t(i)];
        trajectory = [trajectory 'L'];
    elseif (in_rr(i) == 1 || on_rr(i) == 1) && (in_rr(i-1) == 0 && on_rr(i-1) == 0) && (in_rr(i+1) == 1 || on_rr(i+1) == 1)
        goalZone_entry = [goalZone_entry t(i)];
        trajectory = [trajectory 'R'];
    end       

    % if the rat is not in the cp, is not in the stem, is not in the goal
    % fields, is not in the startbox, but his last position was in the
    % choice point
    if in_stem(i) == 0 && in_cp(i) == 0 && in_lr(i) == 0 && in_rr(i) == 0 && ...
            in_sb(i) == 0 && (in_cp(i-1) == 1 || on_cp(i-1) == 1)
        goalArm_entry = [goalArm_entry t(i)];
    end
        
    % same for choice point
    if in_stem(i-1) == 1 && in_stem(i) == 0 && in_stem(i+1) == 0 && in_cp(i) == 1 && in_cp(i+1) == 1
        cp_entry = [cp_entry t(i)];
    end
    
    % only proceed if you're not working with the very first sample

    % if the rat was in the sb, but is not in the startbox, and his next
    % traversal is not in the startbox, but his current traversal, and the
    % next traversal is in the stem, and he wasn't coming from the goal
    % fields
    if in_sb(i-1) == 1 && in_sb(i) == 0 && in_sb(i+1) == 0 && in_stem(i) == 1 && in_stem(i+1) == 1
        stem_entry = [stem_entry t(i)];
    end
end

% correct any instances where the variables do not follow the logical flow
% of things
next = 0;
while next == 0
    if stem_entry(end) > cp_entry(end) 
        
    end
    if cp_entry(end) > 
    end
end

i = 1;
if stem_entry(i) > cp_entry(i) && cp_entry(i) < goalArm_entry(i)
    stem_entry(i) = [];
end


&& cp_entry(i) < goalArm_entry(i) && goalArm_entry(i) < goalZone_entry(i) ...
    && goalZone_entry(i) < retArm_entry(i) && retArm_entry(i) < startBox_entry(i)


% troubleshooting
figure; hold on;
plot(x,y); 
plot(x(dsearchn(t',stem_entry')),y(dsearchn(t',stem_entry')),'.k','Marker','o')


%{
if in_sb(i-1) == 1 && in_sb(i) == 0 && in_sb(i+1) == 0 && in_stem(i) == 1 && in_stem(i+1) == 1
            
        if isempty(stem_entry) 
            stem_entry = [stem_entry t(i)];
        else
            try
                if stem_entry(end) < cp_entry(end)
                    stem_entry = [stem_entry t(i)];
                end 
            catch
                continue
            end
        end
    end
%}


