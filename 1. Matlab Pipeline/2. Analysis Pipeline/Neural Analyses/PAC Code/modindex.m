function [M] = modindex(data,disp,shuffle,N,PhaseBins)

%   This function calculates the degree of phase-amplitude coupling between 
%   two filtered signals by using the Kullback-Leibler distance between an 
%   observed phase-amplitude distribution and a uniform phase-amplitude
%   distribution to calculate a modulation index value 

%   For reference, see:
%   Tort, ABL, Komorowski, R, Eichenbaum, H, & Kopell, N (2010). Measuring
%   phase-amplitude coupling between neuronal oscillations of different
%   frequencies. J Neurophys, 104: 1195-1210.
%   
% Input:
%   data:           Structural array containing phase and amplitude values for two
%                   filtered signals (obtained via either Hilbert transformation or
%                   Morlet wavelet filtering; see "makedatafile.m", or "makedatafile_morlet.m")
%   disp:           Binary containing 'y' if phase-amplitude plot is desired; otherwise, 'n'
%      N:           Number of phase bins (default = 18)

% Output:
%   M.MI:           Modulation index value
%   M.NormAmp:      Normalized amplitude values for each phase bin
%   M.PhaseAxis:    Phase values used for generation of phase-amplitude
%                   plot
%   M.phase:        Phase with highest amplitude value (preferred phase)

% hlh wrote? Unclear who og author is.
% JS modified and wrote shuffled amplitude procedure

%%

if exist('N')==0 
   N = 18;
end

% number of samples for normalizing
totalTime = length(data.Xg_env)/data.srate;

% phase bins for theta
if exist('PhaseBins')==0
    PhaseBins = 0 : 360/N : 360-(360/N);
end

if contains(shuffle,'y') 
    for k = 1:N
        % define temporary variables
        phase_temp = data.Xt_phase;
        amp_temp   = data.Xg_env;
        data_temp  = data.Xt_phase;

        % remove nan phases
        phase_temp(isnan(data_temp))=[];
        amp_temp(isnan(data_temp))=[];

        % Finds all real points where phase falls within a given bin    
        index_real = find (data.Xt_phase >= PhaseBins(k) & data.Xt_phase < PhaseBins(k)+(360/N));

        % perform a shuffling procedure and pull data 1000 times
        numSamples2Pull = length(index_real); % make sure you pull the same number of samples that would actually be pulled
        for n = 1:1000
            shuff_amp(n) = mean(randsample(amp_temp,numSamples2Pull));
        end
        
        % take the average of all shuffled amplitudes
        Bin(k).amp = mean(shuff_amp);        
    end    
else
    for k = 1:N

            % Finds all points where phase falls within a given bin    
            index = find (data.Xt_phase >= PhaseBins(k) & data.Xt_phase < PhaseBins(k)+(360/N));

            % amplitudes that are within the designated phase bins 
            Bin(k).amp = mean(data.Xg_env(index));
    end
end

S = sum([Bin.amp]);

for k = 1:N
        Bin(k).NormAmp = Bin(k).amp / S;  %Normalized amplitude distribution
end

U(1:N) = 1/N;
P = [Bin.NormAmp];
KLdist = sum (P.*(log(P./U)));  %Kullback-Leibler distance
                                %D(P,U)= sum [ P(j) * log(P(j)/U(j)) ]
                                %for each bin of distribution
[Y,I] = max(P);

M.MI=KLdist/log(N);             %Modulation Index (MI) = KL distance divided by the log of the number of bins
M.amp = [Bin.amp];
M.NormAmp = P;
M.PhaseAxis = 360/N/2 : 360/N : 360-(360/N/2);
M.phase = PhaseBins(I);         %Theta phase with highest gamma amplitude
M.normMI = M.MI/totalTime; % JS update 3-16

%Generate plot of normalized gamma amplitude as a function of phase (two full cycles)

if disp == 'y'
    figure1=figure;
    axes1 = axes('Parent',figure1,'YTick',[0 0.02 0.04 0.06 0.08],'XTick',[0 180 360 540 720]);
    xlim(axes1, [0 720]);
    ylim(axes1, [0 0.08]);
    hold(axes1,'all')
    
    phase=[M.PhaseAxis 360+M.PhaseAxis];
    amp=[M.NormAmp M.NormAmp];
    
    bar(phase,amp,'BarWidth',1);
end

end

