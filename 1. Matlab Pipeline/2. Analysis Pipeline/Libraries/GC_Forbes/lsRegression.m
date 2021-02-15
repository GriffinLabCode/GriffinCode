function CoE=lsRegression(targetsignal,signal1,lenFilter1,signal2,lenFilter2,signal3,lenFilter3,signal4,lenFilter4,signal5,lenFilter5)

n=(nargin-1)/2;
N=length(targetsignal);
Smatrix=zeros(n,N);
Fmatrix=zeros(1,n);

for i=1:5
    if i<=n
        switch i
            case 1
                Smatrix(i,:)=signal1;
                Fmatrix(i)=lenFilter1;
            case 2
                Smatrix(i,:)=signal2;
                Fmatrix(i)=lenFilter2;
            case 3
                Smatrix(i,:)=signal3;
                Fmatrix(i)=lenFilter3;
            case 4
                Smatrix(i,:)=signal4;
                Fmatrix(i)=lenFilter4;
            case 5
                Smatrix(i,:)=signal5;
                Fmatrix(i)=lenFilter5;
        end
    end
end
lenMatrix=0;
for i=1:n
    lenMatrix=lenMatrix+Fmatrix(i);
end
maxLenFilter=max(Fmatrix);

CoM=zeros(lenMatrix);
D=zeros(lenMatrix,1);

for i=1:5
    if i<=n
        switch i
            case 1
                for j=1:Fmatrix(1)
                    for t=maxLenFilter+1:N
                        D(j)=D(j)+2*targetsignal(t)*Smatrix(1,t-j);
                    end
                end
            case 2
                for j=1:Fmatrix(2)
                    reg=Fmatrix(1);
                    for t=maxLenFilter+1:N
                        D(reg+j)=D(reg+j)+2*targetsignal(t)*Smatrix(2,t-j);
                    end
                end
            case 3
                for j=1:Fmatrix(3)
                    reg=Fmatrix(1)+Fmatrix(2);
                    for t=maxLenFilter+1:N
                        D(reg+j)=D(reg+j)+2*targetsignal(t)*Smatrix(3,t-j);
                    end
                end
            case 4
                for j=1:Fmatrix(4)
                    reg=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                    for t=maxLenFilter+1:N
                        D(reg+j)=D(reg+j)+2*targetsignal(t)*Smatrix(4,t-j);
                    end
                end
            case 5
                for j=1:Fmatrix(5)
                    reg=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                    for t=maxLenFilter+1:N
                        D(reg+j)=D(reg+j)+2*targetsignal(t)*Smatrix(5,t-j);
                    end
                end
        end
    end
end
    
for i=1:5
    if i<=n
        switch i
            case 1
                for j=1:5
                    if j<=n
                        switch j
                            case 1
                                for p=1:Fmatrix(1)
                                    for q=1:Fmatrix(1)
                                        for t=maxLenFilter+1:N
                                            CoM(p,q)=CoM(p,q)+2*Smatrix(1,t-p)*Smatrix(1,t-q);
                                        end
                                    end
                                end
                            case 2
                                for p=1:Fmatrix(1)
                                    for q=1:Fmatrix(2)
                                        reg2=Fmatrix(1);
                                        for t=maxLenFilter+1:N
                                            CoM(p,reg2+q)=CoM(p,reg2+q)+2*Smatrix(1,t-p)*Smatrix(2,t-q);
                                        end
                                    end
                                end
                            case 3
                                for p=1:Fmatrix(1)
                                    for q=1:Fmatrix(3)
                                        reg2=Fmatrix(1)+Fmatrix(2);
                                        for t=maxLenFilter+1:N
                                            CoM(p,reg2+q)=CoM(p,reg2+q)+2*Smatrix(1,t-p)*Smatrix(3,t-q);
                                        end
                                    end
                                end
                            case 4
                                for p=1:Fmatrix(1)
                                    for q=1:Fmatrix(4)
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        for t=maxLenFilter+1:N
                                            CoM(p,reg2+q)=CoM(p,reg2+q)+2*Smatrix(1,t-p)*Smatrix(4,t-q);
                                        end
                                    end
                                end
                            case 5
                                for p=1:Fmatrix(1)
                                    for q=1:Fmatrix(5)
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        for t=maxLenFilter+1:N
                                            CoM(p,reg2+q)=CoM(p,reg2+q)+2*Smatrix(1,t-p)*Smatrix(5,t-q);
                                        end
                                    end
                                end
                        end
                    end
                end
            case 2
                for j=1:5
                    if j<=n
                        switch j
                            case 1
                                for p=1:Fmatrix(2)
                                    for q=1:Fmatrix(1)
                                        reg1=Fmatrix(1);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,q)=CoM(reg1+p,q)+2*Smatrix(2,t-p)*Smatrix(1,t-q);
                                        end
                                    end
                                end
                            case 2
                                for p=1:Fmatrix(2)
                                    for q=1:Fmatrix(2)
                                        reg1=Fmatrix(1);
                                        reg2=Fmatrix(1);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(2,t-p)*Smatrix(2,t-q);
                                        end
                                    end
                                end
                            case 3
                                for p=1:Fmatrix(2)
                                    for q=1:Fmatrix(3)
                                        reg1=Fmatrix(1);
                                        reg2=Fmatrix(1)+Fmatrix(2);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(2,t-p)*Smatrix(3,t-q);
                                        end
                                    end
                                end
                            case 4
                                for p=1:Fmatrix(2)
                                    for q=1:Fmatrix(4)
                                        reg1=Fmatrix(1);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(2,t-p)*Smatrix(4,t-q);
                                        end
                                    end
                                end
                            case 5
                                for p=1:Fmatrix(2)
                                    for q=1:Fmatrix(5)
                                        reg1=Fmatrix(1);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(2,t-p)*Smatrix(5,t-q);
                                        end
                                    end
                                end
                        end
                    end
                end
            case 3
                for j=1:5
                    if j<=n
                        switch j
                            case 1
                                for p=1:Fmatrix(3)
                                    for q=1:Fmatrix(1)
                                        reg1=Fmatrix(1)+Fmatrix(2);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,q)=CoM(reg1+p,q)+2*Smatrix(3,t-p)*Smatrix(1,t-q);
                                        end
                                    end
                                end
                            case 2
                                for p=1:Fmatrix(3)
                                    for q=1:Fmatrix(2)
                                        reg1=Fmatrix(1)+Fmatrix(2);
                                        reg2=Fmatrix(1);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(3,t-p)*Smatrix(2,t-q);
                                        end
                                    end
                                end
                            case 3
                                for p=1:Fmatrix(3)
                                    for q=1:Fmatrix(3)
                                        reg1=Fmatrix(1)+Fmatrix(2);
                                        reg2=Fmatrix(1)+Fmatrix(2);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(3,t-p)*Smatrix(3,t-q);
                                        end
                                    end
                                end
                            case 4
                                for p=1:Fmatrix(3)
                                    for q=1:Fmatrix(4)
                                        reg1=Fmatrix(1)+Fmatrix(2);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(3,t-p)*Smatrix(4,t-q);
                                        end
                                    end
                                end
                            case 5
                                for p=1:Fmatrix(3)
                                    for q=1:Fmatrix(5)
                                        reg1=Fmatrix(1)+Fmatrix(2);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(3,t-p)*Smatrix(5,t-q);
                                        end
                                    end
                                end
                        end
                    end
                end
            case 4
                for j=1:5
                    if j<=n
                        switch j
                            case 1
                                for p=1:Fmatrix(4)
                                    for q=1:Fmatrix(1)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,q)=CoM(reg1+p,q)+2*Smatrix(4,t-p)*Smatrix(1,t-q);
                                        end
                                    end
                                end
                            case 2
                                for p=1:Fmatrix(4)
                                    for q=1:Fmatrix(2)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        reg2=Fmatrix(1);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(4,t-p)*Smatrix(2,t-q);
                                        end
                                    end
                                end
                            case 3
                                for p=1:Fmatrix(4)
                                    for q=1:Fmatrix(3)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        reg2=Fmatrix(1)+Fmatrix(2);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(4,t-p)*Smatrix(3,t-q);
                                        end
                                    end
                                end
                            case 4
                                for p=1:Fmatrix(4)
                                    for q=1:Fmatrix(4)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(4,t-p)*Smatrix(4,t-q);
                                        end
                                    end
                                end
                            case 5
                                for p=1:Fmatrix(4)
                                    for q=1:Fmatrix(5)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(4,t-p)*Smatrix(5,t-q);
                                        end
                                    end
                                end
                        end
                    end
                end
            case 5
                for j=1:5
                    if j<=n
                        switch j
                            case 1
                                for p=1:Fmatrix(5)
                                    for q=1:Fmatrix(1)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,q)=CoM(reg1+p,q)+2*Smatrix(5,t-p)*Smatrix(1,t-q);
                                        end
                                    end
                                end
                            case 2
                                for p=1:Fmatrix(5)
                                    for q=1:Fmatrix(2)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        reg2=Fmatrix(1);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(5,t-p)*Smatrix(2,t-q);
                                        end
                                    end
                                end
                            case 3
                                for p=1:Fmatrix(5)
                                    for q=1:Fmatrix(3)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        reg2=Fmatrix(1)+Fmatrix(2);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(5,t-p)*Smatrix(3,t-q);
                                        end
                                    end
                                end
                            case 4
                                for p=1:Fmatrix(5)
                                    for q=1:Fmatrix(4)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(5,t-p)*Smatrix(4,t-q);
                                        end
                                    end
                                end
                            case 5
                                for p=1:Fmatrix(5)
                                    for q=1:Fmatrix(5)
                                        reg1=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        reg2=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                                        for t=maxLenFilter+1:N
                                            CoM(reg1+p,reg2+q)=CoM(reg1+p,reg2+q)+2*Smatrix(5,t-p)*Smatrix(5,t-q);
                                        end
                                    end
                                end
                        end
                    end
                end
        end
    end
end


CoEsingle=CoM\D;
CoE=zeros(n,maxLenFilter);
for i=1:5
    if i<=n
        switch i
            case 1
                for j=1:Fmatrix(1)
                    CoE(1,j)=CoEsingle(j);
                end
            case 2
                for j=1:Fmatrix(2)
                    reg=Fmatrix(1);
                    CoE(2,j)=CoEsingle(reg+j);
                end
            case 3
                for j=1:Fmatrix(3)
                    reg=Fmatrix(1)+Fmatrix(2);
                    CoE(3,j)=CoEsingle(reg+j);
                end
            case 4
                for j=1:Fmatrix(4)
                    reg=Fmatrix(1)+Fmatrix(2)+Fmatrix(3);
                    CoE(4,j)=CoEsingle(reg+j);
                end
            case 5
                for j=1:Fmatrix(5)
                    reg=Fmatrix(1)+Fmatrix(2)+Fmatrix(3)+Fmatrix(4);
                    CoE(5,j)=CoEsingle(reg+j);
                end
        end
    end
end



return