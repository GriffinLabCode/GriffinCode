function [optimalorder, order_time, order_val] = armorf_modelOrder(datax, datay, nPoints, orderRuns, sfreq)

% datax is the signal x which is in 1xN row, N is the length of data x and y;
% datay is the signal y which is in 1xN row, N is the length of data y and x;
% sfreq is the sampling frequency
% nPoints is the number of data points in the trial of consideration
% the unit of order is in temporal point (but not in second or milisecond)


% output: GCy2x is the granger causality value of data y to data x, it has
%         sfreq/2 + 1 points, meaning from 0 hz to sfreq/2 hz

% default is 10 runs
if orderRuns < 10
    orderRuns = 10;
    disp('Do not do less than 10 orderRuns - corrected')
end

% orient data appropriately
sizeOut = size(datax);
if sizeOut(2) ~= nPoints
    datax = datax';
end

% orient data appropriately
sizeOut = size(datay);
if sizeOut(2) ~= nPoints
    datay = datay';
end

% number of trials is the first dimension
nTrials = size(datax,1);

% concatenate data
tempdata = [];
tempdata = vertcat(datax,datay);

bic = [];
for orderi = 1:orderRuns
    
    % run model
    [Axy,E] = armorf(tempdata,nTrials,nPoints,orderi);

    % compute Bayes Information Criteria
    bic(orderi) = log(det(E)) + (log(length(tempdata))*orderi*2^2)/length(tempdata);
    
    % disp
    disp(['Attempted model order ',num2str(orderi)])

    % get optimal order
    [order_val,optimalorder] = min(mean(bic,1)); 

    % convert to ms
    order_time = optimalorder*(1000/sfreq);
    
    % stop loop if optimal order is less than the loop length as long as
    % you've done at least 10
    if orderi > 20
        if optimalorder < orderi
            disp(['Selected model is ',num2str(optimalorder)])
            break
        end
    end
    
end

%{

% get lowest bic for model order
[bestbicVal,bestbicIdx]=min(mean(bic,1));


%}