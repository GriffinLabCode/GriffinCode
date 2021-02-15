close all;
clear all;


N=256;
% xaxis=-0.5:1/N:0.5-1/N;
c=[0.2,0.3,0.4,0.3];
nT = [0:N-1];
w1=2*pi*0.3;
w2=2*pi*0.2;
w3=2*pi*0.1;
x=zeros(1,N);
y=zeros(1,N);
z=zeros(1,N);
x=cos(w1*nT)+1.2*cos(w2*nT)+2*cos(w3*nT)+.2*randn(1,N);


% for i=5:N
%     for j=1:4
%         z(i)=z(i)+cos(w1*(i-j))*c(j);%+cos(w2*nT);
%     end
% end
% z=z+randn(1,N);%+1.2*cos(w2*nT)+2*cos(w3*nT);
% 
% for i=5:N
%     for j=1:4
%     y(i)=y(i)+z(i-j)*c(j);%+x(i-j)*c(j);%+cos(w2*nT);
%     end
% end
% y=y+randn(1,N);%+1.2*cos(w2*nT)+2*cos(w3*nT);

for i=5:N
    for j=1:4
        z(i)=z(i)+cos(w1*(i-j))*c(j);%+cos(w2*nT);
    end
end
% for i=5:N
%     for j=1:4
%         z(i)=z(i)+x(i-j)*c(j);%+cos(w2*nT);
%     end
% end


z = z + .2*randn(1,N);




order=10;
sfreq = N;

[b,a] = GCtemporal(x, z, order);
[B, A] = GCspectral(x, z, order, sfreq);


figure;
set(gcf,'color',[1,1,1]);
xaxis = 0: floor(sfreq/2)
plot(xaxis,A);
hold on;
plot(xaxis,B,'r');
hold on;
xlabel('Frequency','Fontsize',18);
ylabel('GC value','Fontsize',18);





