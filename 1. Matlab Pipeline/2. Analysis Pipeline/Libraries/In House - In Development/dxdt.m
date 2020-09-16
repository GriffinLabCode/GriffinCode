function dx = dxdt(x,varargin)

% dx = dxdt(x,varargin)
%
% WARNING converts tsd to ctsd while removing NaNs before running, 
% be sure that this is OK for your data.
% 
% window = 1; % seconds
% postSmoothing = 0.5; % seconds --- 0 means don't
%
% Based on Janabi-Sharifi/Hayward/Chen, Discrete-time adaptive windowing
% for velocity estimation, IEEE Transactions on Control Systems Technology,
% (2000) 8(6):1003-1009.
% But modified extensively.  Basic algorithm is to allow windows from 3
% steps to nW = window/DT steps.  For each window, let dx = x(i+nW) - x(i).
% Select the window with the smallest MSE = sum_k=1..nW (x(i+k) - linear-fit(x(i+k) given slope from dx)).^2.
%
% postSmoothing does a convolution of normalized ones(nPS/DT)
%
% ADR 2003
% CORRECTED ADR 6 August 2012 - it was returning the negative direction
% ADR 2020
% Now checks that tsd is sorted.
window = 1; % seconds
postSmoothing = 0.5; % seconds --- 0 means don't
display = 0;
process_varargin(varargin);

assert(x.isSorted, 'Input tsd is not sorted, applying to ctsd is inappropriate.');

x = ctsd(removeNaNs(x));
xD = x.data();
dT = x.dt();

nW = min(ceil(window/x.dt()),length(xD));
nX = length(xD);

MSE = zeros(nX, nW);
b = zeros(nX,nW);

MSE(:,1:2) = Inf;
nanvector = nan(nW,1);

for iN = 3:nW
	if display, fprintf(2,'.'); end
	b(:,iN) = ([nanvector(1:iN); xD(1:(end-iN))] - xD)/iN;
	for iK = 1:iN
		q = ([nanvector(1:iK); xD(1:(end-iK))] - xD + b(:,iN) * iK);
		MSE(:,iN) = MSE(:,iN) + q.*q;		
	end
	MSE(:,iN) = MSE(:,iN)/iN;	
end
if display, fprintf(2, '!'); end

[~, nSelect] = min(MSE,[],2);
dx = nan .* ones(size(xD));
for iX = 1:nX
	dx(iX) = -b(iX,nSelect(iX)) / dT;  % CORRECTED ADR 6 August 2012 - it was returning the negative direction
end

if postSmoothing
	nS = ceil(postSmoothing/x.dt());
	dx = conv2(dx,ones(nS)/nS,'same');
end
	
dx = tsd(x.range(),dx);
