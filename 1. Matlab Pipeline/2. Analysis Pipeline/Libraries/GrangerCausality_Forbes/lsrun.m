function [errorseries,error, targetsignalnew]=lsrun(targetsignal,CoE,signal1,signal2,signal3,signal4,signal5)

sizeCoE=size(CoE);
N=length(targetsignal);

targetsignalnew=zeros(1,N);
switch sizeCoE(1)
    case 1
        for i=sizeCoE(2)+1:N
            for j=1:sizeCoE(2)
                targetsignalnew(i)=targetsignalnew(i)+CoE(1,j)*signal1(i-j);
            end
        end
    case 2
        for i=sizeCoE(2)+1:N
            for j=1:sizeCoE(2)
                targetsignalnew(i)=targetsignalnew(i)+CoE(1,j)*signal1(i-j)+CoE(2,j)*signal2(i-j);
            end
        end
    case 3
        for i=sizeCoE(2)+1:N
            for j=1:sizeCoE(2)
                targetsignalnew(i)=targetsignalnew(i)+CoE(1,j)*signal1(i-j)+CoE(2,j)*signal2(i-j)+CoE(3,j)*signal3(i-j);
            end
        end
    case 4
        for i=sizeCoE(2)+1:N
            for j=1:sizeCoE(2)
                targetsignalnew(i)=targetsignalnew(i)+CoE(1,j)*signal1(i-j)+CoE(2,j)*signal2(i-j)+CoE(3,j)*signal3(i-j)+CoE(4,j)*signal4(i-j);
            end
        end
    case 5
        for i=sizeCoE(2)+1:N
            for j=1:sizeCoE(2)
                targetsignalnew(i)=targetsignalnew(i)+CoE(1,j)*signal1(i-j)+CoE(2,j)*signal2(i-j)+CoE(3,j)*signal3(i-j)+CoE(4,j)*signal4(i-j)+CoE(5,j)*signal5(i-j);
            end
        end
end

% plot(targetsignal);
% hold on;
% plot(targetsignalnew,'r');

err=zeros(1,sizeCoE(1));

for i=sizeCoE(2)+1:N
    err=err+abs(targetsignal(i)-targetsignalnew(i));
end
errorseriestmp=zeros(1,N);
for i=sizeCoE(2)+1:N
    errorseriestmp(i)=targetsignal(i)-targetsignalnew(i);
end
    
errorseries = errorseriestmp(sizeCoE(2)+1 : N);
error=sqrt(err/(N-sizeCoE(2)));

return