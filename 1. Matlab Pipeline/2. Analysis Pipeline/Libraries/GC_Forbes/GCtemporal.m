function [GCy2x, GCx2y] = GCtemporal(datax, datay, order)

% datax is the signal x which is in 1xN row, N is the length of data x and y;
% datay is the signal y which is in 1xN row, N is the length of data y and x;
% the unit of order is in temporal point (but not in second or milisecond)

C1 = lsRegression(datax, datax, order);
C2 = lsRegression(datay, datay, order);
C11 = lsRegression(datax, datax, order, datay, order);
C22 = lsRegression(datay, datax, order, datay, order);
error1 = lsrun(datax, C1, datax);
error2 = lsrun(datay, C2, datay);
error11 = lsrun(datax, C11, datax, datay);
error22 = lsrun(datay, C22, datax, datay);

GCy2x = log(var(error1)/var(error11));
GCx2y = log(var(error2)/var(error22));
