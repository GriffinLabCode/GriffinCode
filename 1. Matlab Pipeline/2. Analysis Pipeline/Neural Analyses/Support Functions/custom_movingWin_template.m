%% get theta coherence in moving window
% this code performs a moving window method nearly identical to chronux
% methods. It was tested using coherencyc, and compared against
% cohgramc
%
% -- INPUTS -- %
% data1: lfp data
% data2: lfp data
% params: parameters for your stuff
%
% -- OUTPUTS -- %
% you define them
%
% taken from chronux

function [varargout] = custom_movingWin_template(data1,data2,srate)

% reorient data
data1 = change_row_to_column(data1);
data2 = change_row_to_column(data2);

% preparatory steps
f = [1:.5:20];
Fs = srate;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
[N,Ch]=check_consistency(data1,data2);
winstart=1:Nstep:N-Nwin+1;
nw=length(winstart);

C = [];
for n=1:nw
    
    % get data
    indx     = winstart(n):winstart(n)+Nwin-1;
    datawin1 = data1(indx,:);
    datawin2 = data2(indx,:);
    
    % detrend
    %datawin1 = detrend(datawin1,3);
    %datawin2 = detrend(datawin2,3);
    
    % compute coherence
    %c = mscohere(datawin1,datawin2,[],[],f,srate);  
    
    % store coherence
    %C(n,:)=c;
end
% reorient coherence matrix
%C = C';

end