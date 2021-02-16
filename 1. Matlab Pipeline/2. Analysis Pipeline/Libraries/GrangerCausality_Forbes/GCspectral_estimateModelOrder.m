function [GCy2x, GCx2y, frequencies, optimalorder, order_val] = GCspectral_estimateModelOrder(datax, datay, orderRuns, sfreq)

% datax is the signal x which is in 1xN row, N is the length of data x and y;
% datay is the signal y which is in 1xN row, N is the length of data y and x;
% sfreq is the sampling frequency
% the unit of order is in temporal point (but not in second or milisecond)


% output: GCy2x is the granger causality value of data y to data x, it has
%         sfreq/2 + 1 points, meaning from 0 hz to sfreq/2 hz

if orderRuns < 10
    orderRuns = 10;
    disp('Do not do less than 10 orderRuns - corrected')
end

for orderi = 1:orderRuns
    % set up mats
    C1 = []; C2 = []; E1 = []; E2 = []; error1 = []; error2 = [];
    
    % least square regression on data
    C1=lsRegression(datax,datax,orderi,datay,orderi);
    C2=lsRegression(datay,datax,orderi,datay,orderi);
    [E1,error1]=lsrun(datax,C1,datax,datay);
    [E2,error2]=lsrun(datay,C2,datax,datay);

    % calculate the covariance of errors from x2y and y2x regressions
    E=cov(E1,E2); 
    
    % num data points (datax and datay should be the same length)
    nPoints = length(datax);
    
    % calculate bic
    bic(orderi) = log(det(E)) + (log(nPoints)*orderi*2^2)/nPoints;
    
    % disp
    disp(['Attempted model order ',num2str(orderi)])
    
    % get temporary bic average
    [order_val,optimalorder] = min(mean(bic,1)); 
    
    % stop loop if optimal order is less than the loop length as long as
    % you've done at least 10
    if orderi > 20
        if optimalorder < orderi
            disp(['Selected model is ',num2str(optimalorder)])
            break
        end
    end
    
end

% freq domain granger using the model order above
[AAA,BBB]=Granger2Dfre(C1,C2,E1,E2,sfreq);

% extract estimates
GCy2x = AAA(floor(sfreq/2) : end);
GCx2y = BBB(floor(sfreq/2) : end);

% define frequency range
frequencies = 0:floor(sfreq/2);
