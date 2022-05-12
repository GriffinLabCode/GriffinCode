function [GCy2x, GCx2y, frequencies, E1, E2] = GCspectral(datax, datay, order, sfreq)

% datax is the signal x which is in 1xN row, N is the length of data x and y;
% datay is the signal y which is in 1xN row, N is the length of data y and x;
% sfreq is the sampling frequency
% the unit of order is in temporal point (but not in second or milisecond)


% output: GCy2x is the granger causality value of data y to data x, it has
%         sfreq/2 + 1 points, meaning from 0 hz to sfreq/2 hz


C1=lsRegression(datax,datax,order,datay,order);
C2=lsRegression(datay,datax,order,datay,order);
[E1,error1]=lsrun(datax,C1,datax,datay);
[E2,error2]=lsrun(datay,C2,datax,datay);

[AAA,BBB]=Granger2Dfre(C1,C2,E1,E2,sfreq);

GCy2x = AAA(floor(sfreq/2) : end);
GCx2y = BBB(floor(sfreq/2) : end);

% define frequency range
frequencies = 0:floor(sfreq/2);