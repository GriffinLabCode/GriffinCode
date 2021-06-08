function [pksOut,locsOut] = findpeaks_MATLAB(Xin,varargin)
%FINDPEAKS Find local peaks in data
%   PKS = FINDPEAKS(X) finds local peaks in the data vector X. A local peak
%   is defined as a data sample which is either larger than the two
%   neighboring samples or is equal to Inf.
%
%   [PKS,LOCS]= FINDPEAKS(X) also returns the indices LOCS at which the
%   peaks occur.
%
%   [...] = FINDPEAKS(X,'MinPeakHeight',MPH) finds only those peaks that
%   are greater than the minimum peak height, MPH. Specifying a minimum
%   peak height may help in reducing the processing time. MPH is a real
%   valued scalar. The default value of MPH is -Inf.
%
%   [...] = FINDPEAKS(X,'MinPeakDistance',MPD) finds peaks that are at
%   least separated by the minimum peak distance, MPD. MPD is a positive
%   integer valued scalar. This parameter may be specified to ignore
%   smaller peaks that may occur in close proximity to a large local peak.
%   For example, if a large local peak occurs at index N, then all smaller
%   peaks in the range (N-MPD, N+MPD) are ignored. If not specified, MPD is
%   assigned a value of one.
%
%   [...] = FINDPEAKS(X,'Threshold',TH)finds peaks that are at least
%   greater than their neighbors by the threshold, TH. TH is real valued
%   scalar greater than or equal to zero. The default value of TH is zero.
%
%   [...] = FINDPEAKS(X,'NPeaks',NP) specifies the maximum number of
%   peaks to be found. NP is an integer greater than zero. If not
%   specified, all peaks are returned.
%
%   [...] = FINDPEAKS(X,'SortStr',STR) specifies the direction of sorting
%   of peaks. STR can take values of 'ascend','descend' or 'none'. If not
%   specified, STR takes the value of 'none' and the peaks are returned in
%   the order of their occurrence.
%
%   % Example 1:
%   %   Find peaks in a vector and plot the result.
%
%   data = [2 12 4 6 9 4 3 1 19 7];     % Define data with peaks
%   [pks,locs] = findpeaks(data)        % Find peaks and their indices
%   plot(data,'Color','blue'); hold on;
%   plot(locs,data(locs),'k^','markerfacecolor',[1 0 0]);
%
%   % Example 2:
%   %   Find peaks separated by more than three elements and return  
%   %   their locations.
%
%   data = [2 12 4 6 9 4 3 1 19 7];                 % Define data
%   [pks,locs]=findpeaks(data,'minpeakdistance',3); % Find peaks 
%   plot(data,'Color','blue'); hold on;
%   plot(locs,data(locs),'k^','markerfacecolor',[1 0 0]);
%
%   See also DSPDATA/FINDPEAKS

%   Copyright 2007-2013 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

cond = nargin >= 1;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:notEnoughInputs');
end

cond = nargin <= 11;
if ~cond
    coder.internal.assert(cond,'MATLAB:narginchk:tooManyInputs');
end

[X,Ph,Pd,Th,Np,Str,infIdx] = parse_inputs(Xin,varargin{:});
[pks,locs] = getPeaksAboveMinPeakHeight(X,Ph);
[pks,locs] = removePeaksBelowThreshold(X,pks,locs,Th,infIdx);
[pks,locs] = removePeaksSeparatedByLessThanMinPeakDistance(pks,locs,Pd);
[pks,locs] = orderPeaks(pks,locs,Str);
[pks,locs] = keepAtMostNpPeaks(pks,locs,Np);

if iscolumn(Xin)
    pksOut = pks(:);
    locsOut = locs(:);
else
    pksOut = pks(:).';
    locsOut = locs(:).';
end

%--------------------------------------------------------------------------
function [X,Ph,Pd,Th,NpOut,Str,infIdx] = parse_inputs(Xin,varargin)

% Validate input signal
validateattributes(Xin,{'numeric'},{'nonempty','real','vector'},...
    'findpeaks','X');
isXRow = isrow(Xin);
if isXRow
    X = Xin(:);
else
    X = Xin;
end

if coder.target('MATLAB')
    try %#ok<EMTC>
        % Check the input data type. Single precision is not supported.
        chkinputdatatype(X);
    catch ME
        throwAsCaller(ME);
    end
else
    chkinputdatatype(X);
end

M = numel(X);
cond = (M < 3);
if cond
    coder.internal.errorIf(cond,'signal:findpeaks:emptyDataSet');
end

%#function dspopts.findpeaks
defaultMinPeakHeight = -inf;
defaultMinPeakDistance = 1;
defaultThreshold = 0;
defaultNPeaks = [];
defaultSortStr = 'none';

if coder.target('MATLAB')
    p = inputParser;
    addParameter(p,'MinPeakHeight',defaultMinPeakHeight);
    addParameter(p,'MinPeakDistance',defaultMinPeakDistance);
    addParameter(p,'Threshold',defaultThreshold);
    addParameter(p,'NPeaks',defaultNPeaks);
    addParameter(p,'SortStr',defaultSortStr);
    
    parse(p,varargin{:});
    Ph = p.Results.MinPeakHeight;
    Pd = p.Results.MinPeakDistance;
    Th = p.Results.Threshold;
    Np = p.Results.NPeaks;
    Str = p.Results.SortStr;
     
else
    parms = struct('MinPeakHeight',uint32(0), ...
                'MinPeakDistance',uint32(0), ...
                'Threshold',uint32(0), ...
                'NPeaks',uint32(0), ...
                'SortStr',uint32(0));
            
    pstruct = eml_parse_parameter_inputs(parms,[],varargin{:});
    Ph = eml_get_parameter_value(pstruct.MinPeakHeight,defaultMinPeakHeight,varargin{:});
    Pd = eml_get_parameter_value(pstruct.MinPeakDistance,defaultMinPeakDistance,varargin{:});
    Th = eml_get_parameter_value(pstruct.Threshold,defaultThreshold,varargin{:});
    Np = eml_get_parameter_value(pstruct.NPeaks,defaultNPeaks,varargin{:});
    Str = eml_get_parameter_value(pstruct.SortStr,defaultSortStr,varargin{:});
    
end

if isempty(Np)
    NpOut = M;
else
    NpOut = Np;
end

validateattributes(Ph,{'numeric'},{'real','scalar','nonempty'},'findpeaks','MinPeakHeight');
validateattributes(Pd,{'numeric'},{'real','scalar','nonempty','integer','positive','<',M},'findpeaks','MinPeakDistance');
validateattributes(Th,{'numeric'},{'real','scalar','nonempty','nonnegative'},'findpeaks','Threshold');
validateattributes(NpOut,{'numeric'},{'real','scalar','nonempty','integer','positive'},'findpeaks','NPeaks');
Str = validatestring(Str,{'ascend','none','descend'},'findpeaks','SortStr');

% Replace Inf by realmax because the diff of two Infs is not a number
infIdx = isinf(X);
if any(infIdx),
    X(infIdx) = sign(X(infIdx))*realmax;
end
infIdx = infIdx & X>0; % Keep only track of +Inf

%--------------------------------------------------------------------------
function [pks,locs] = getPeaksAboveMinPeakHeight(X,Ph)

pks = zeros(0,1);
locs = zeros(0,1);

if all(isnan(X)),
    return,
end

Indx = find(X > Ph);
if(isempty(Indx))
    if coder.target('MATLAB')
        warning(message('signal:findpeaks:largeMinPeakHeight', 'MinPeakHeight', 'MinPeakHeight'));
    end
    return
end
    
% Peaks cannot be easily solved by comparing the sample values. Instead, we
% use first order difference information to identify the peak. A peak
% happens when the trend change from upward to downward, i.e., a peak is
% where the difference changed from a streak of positives and zeros to
% negative. This means that for flat peak we'll keep only the rising
% edge.
trend = sign(diff(X));
idx = find(trend==0); % Find flats
N = length(trend);
for i=length(idx):-1:1,
    % Back-propagate trend for flats
    if trend(min(idx(i)+1,N))>=0,
        trend(idx(i)) = 1; 
    else
        trend(idx(i)) = -1; % Flat peak
    end
end

idxp = find(diff(trend)==-2)+1;  % Get all the peaks
if ~isempty(idxp)
    locs = intersect(Indx,idxp(:));      % Keep peaks above MinPeakHeight
    pks  = X(locs);
end


%--------------------------------------------------------------------------
function [pks_out,locs_out] = removePeaksBelowThreshold(X,pks,locs,Th,infIdx)

validpeakidx = false(numel(pks),1);

for i = 1:length(pks),
    delta = min(pks(i)-X(locs(i)-1),pks(i)-X(locs(i)+1));
    if delta>=Th,
        validpeakidx(i) = true; 
    end
end
if ~isempty(validpeakidx),
    templocs = locs(validpeakidx);
else
    templocs = zeros(0,1);
end

X(infIdx) = Inf;                 % Restore +Inf
locs_out = union(templocs(:),find(infIdx(:))); % Make sure we find peaks like [realmax Inf realmax]
pks_out  = X(locs_out);

%--------------------------------------------------------------------------
function [pks_out,locs_out] = removePeaksSeparatedByLessThanMinPeakDistance(pks,locs,Pd)
% Start with the larger peaks to make sure we don't accidentally keep a
% small peak and remove a large peak in its neighborhood. 

if isempty(pks) || Pd==1,
    pks_out = pks;
    locs_out = locs;
    return
end

% Order peaks from large to small
[pks_temp, idx] = sort(pks,'descend');
locs_temp = locs(idx);

idelete = ones(size(locs_temp))<0;
for i = 1:length(locs_temp),
    if ~idelete(i),
        % If the peak is not in the neighborhood of a larger peak, find
        % secondary peaks to eliminate.
        idelete = idelete | (locs_temp>=locs_temp(i)-Pd)&(locs_temp<=locs_temp(i)+Pd); 
        idelete(i) = 0; % Keep current peak
    end
end
pks_out = pks_temp(~idelete);
locs_out = locs_temp(~idelete);

%--------------------------------------------------------------------------
function [pks_out,locs_out] = orderPeaks(pks,locs,Str)

if isempty(pks), 
    pks_out = pks;
    locs_out = locs;
    return; 
end

if strcmp(Str,'none')
    [locs_out,idx] = sort(locs);
    pks_out = pks(idx);
elseif strcmp(Str,'ascend')
    [pks_out,s]  = sort(pks,'ascend');
    locs_out = locs(s);
else
    [pks_out,s]  = sort(pks,'descend');
    locs_out = locs(s);    
end

%--------------------------------------------------------------------------
function [pks_out,locs_out] = keepAtMostNpPeaks(pks,locs,Np)

if length(pks)>Np,
    locs_out = locs(1:Np);
    pks_out  = pks(1:Np);
else
    locs_out = locs;
    pks_out = pks;
end

% [EOF]
