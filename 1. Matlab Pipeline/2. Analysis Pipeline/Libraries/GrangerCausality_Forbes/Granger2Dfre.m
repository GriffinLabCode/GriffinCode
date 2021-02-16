function [Grangery2x,Grangerx2y]=Granger2Dfre(Cy2x,Cx2y,errory2x,errorx2y,sfreq)

dimensionCy2x=size(Cy2x);
dimensionCx2y=size(Cx2y);
maxlenthC=max(dimensionCy2x(2),dimensionCx2y(2));
if dimensionCy2x(2)<maxlenthC
    C=zeros(2,maxlenthC);
    for p=1:2
        for q=1:dimensionCy2x
            C(p,q)=Cy2x(p,q)
        end
    end
    Cy2x=C;
end
if dimensionCx2y(2)<maxlenthC
    C=zeros(2,maxlenthC);
    for p=1:2
        for q=1:dimensionCx2y
            C(p,q)=Cx2y(p,q);
        end
    end
    Cx2y=C;
end

C=zeros(2,2,maxlenthC);

C(1,:,:)=Cy2x;
C(2,:,:)=Cx2y;
E=cov(errory2x,errorx2y);
H=zeros(2,2);
N=sfreq;
for f=-floor(N/2)+1:floor(N/2)

    A=zeros(2,2);
    for p=1:2
        for q=1:2
            for k=1:maxlenthC
                A(p,q)=A(p,q)-C(p,q,k)*exp(-j*2*pi*f*k/N);
            end
        end
    end
    for p=1:2
        A(p,p)=1+A(p,p);
    end
    H=A^-1;
    Hxx=H(1,1)+E(1,2)/E(1,1)*H(1,2);
    Hyy=H(2,2)+E(2,1)/E(2,2)*H(2,1);
    Hxy=H(1,2);
    Hyx=H(2,1);
    Sxx=Hxx*E(1,1)*Hxx'+Hxy*(E(2,2)-E(1,2)*E(2,1)/E(1,1))*Hxy';
    Syy=Hyy*E(2,2)*Hyy'+Hyx*(E(1,1)-E(1,2)*E(2,1)/E(2,2))*Hyx';
    
    Grangery2x(f+floor(N/2))=log(abs(Sxx)/abs(Hxx*E(1,1)*Hxx'));
    Grangerx2y(f+floor(N/2))=log(abs(Syy)/abs(Hyy*E(2,2)*Hyy'));
end


