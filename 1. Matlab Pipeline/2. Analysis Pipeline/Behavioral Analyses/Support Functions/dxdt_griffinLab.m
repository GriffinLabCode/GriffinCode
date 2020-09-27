%% dxdt - janabi-sharifi method
% this code was provided to me (JS) from David Redish on 9-15-2020. It was
% modified, including some wording here
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
%
% JS 2020 modified to work with Griffin lab
% 
% window = 1; % seconds
% postSmoothing = 0.5; % seconds --- 0 means don't
% display = 0;
% below is information from redish lab

% -- INPUTS -- %
% xD: x position data as a vector
% window: window of time to consider for adaptive estimation - 1 sec works
% postSmoothing: smoothing window time (0.5 sec was from Redish)
% vt_srate: video tracking sampling rate (30 samples/sec is typical for
%           griffin lab
% display: set to 0 for no display
%
% -- OUTPUTS -- %
% dx: 

function dx = dxdt_griffinLab(xD,window,postSmoothing,vt_srate,display)

% check size - 
checkSize = size(xD);
if checkSize(1) == 1 && checkSize(2) == numel(xD)
    xD = xD';
else
    xD = xD;
end

% dT = timestep (1/sampling rate should do fine)
dT = 1/vt_srate; 

nW = min(ceil(window/dT),length(xD));
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
	nS = ceil(postSmoothing/dT);
	dx = conv2(dx,ones(nS)/nS,'same');
end
