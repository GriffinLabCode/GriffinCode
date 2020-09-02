%% principle_comp.m

%   This script performs principal component analysis on firing rate
%   differences between tasks during left, right, correct, and incorrect
%   trial types

%   This script hasn't been used for any real purpose, but I thought it
%   might be a good way to visualize the principal components of interest that explain
%   the most variance in the data

%   The script gives a lot of outputs:

%   Principle components mapped back out onto firing rate differences:

%   PC1_1 = Correlation coefficient of first principle component for left vs. right during DA start-box
%   PC1_2 = Correlation coefficient of first principle component for correct vs. error during DA start-box
%   PC1_3 = Correlation coefficient of first principle component for left vs. right during DA stem traversals
%   PC1_4 = Correlation coefficient of first principle component for correct vs. error during DA stem traversals
%   PC1_5 = Correlation coefficient of first principle component for left vs. right during DA choice-point traversals
%   PC1_6 = Correlation coefficient of first principle component for correct vs. error during DA choice-point traversals
%   PC1_7 = Correlation coefficient of first principle component for left vs. right during CD start-box
%   PC1_8 = Correlation coefficient of first principle component for correct vs. error during CD start-box
%   PC1_9 = Correlation coefficient of first principle component for left vs. right during CD stem traversals
%   PC1_10 = Correlation coefficient of first principle component for correct vs. error during CD stem traversals
%   PC1_11 = Correlation coefficient of first principle component for left vs. right during CD choice-point traversals
%   PC1_12 = Correlation coefficient of first principle component for correct vs. error during CD choice-point traversals
%   PC1_13 = Correlation coefficient of first principle component for DA vs. CD start-box
%   PC1_14 = Correlation coefficient of first principle component for DA vs. CD stem
%   PC1_15 = Correlation coefficient of first principle component for DA vs. CD choice-point
%   
%   COEFF =         Principal component coefficients (all principal components).
%                   Rows = trial type comparisons (see PC1_1 through PC1_15 above)
%                   Columns = Principal components 

%   SCORE =         Principal component scores
%   latent =        Variances of principal component scores
%   reconstructed = Principal component residuals
%   C =             Covariance scores
%   D =             Diagonal matrix of eigenvalues
%   V =             Corresponding matrix of eigenvectors

%%

clear all, clc, close all

netDrive = 'X:\';
expFolder = '01.Experiments\mPFC-Hippocampus_DualTask\';
session = '1203\1203-1\';

datafolder = strcat(netDrive,expFolder,session);
load(strcat(datafolder, 'Intervals.mat'));
load(strcat(datafolder, 'VT1.mat'));

cd(datafolder)
clusters = dir('TT*.txt');

clear rat session expFolder

numtrials1 = size(Int1,1);
numtrials2 = size(Int2,1);

% Get firing rates for maze locations of interest
% Separate firing rates based on correct, incorrect, left-turn, and
% right-turn trials
for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    cluster = clusters(ci).name(1:end-4);
    for dai = 2:numtrials1
        spk_temp_delay = find(spikeTimes>Int1(dai-1,8) & spikeTimes<Int1(dai,1));
        spk_temp_stem = find(spikeTimes>Int1(dai,1) & spikeTimes<Int1(dai,5));
        spk_temp_cp = find(spikeTimes>Int1(dai,5) & spikeTimes<Int1(dai,6));
        time_delay = (Int1(dai,1) - Int1(dai-1,8))/1e6;
        time_stem = (Int1(dai,5) - Int1(dai,1))/1e6;
        time_cp = (Int1(dai,6) - Int1(dai,5))/1e6;
        fr_delay = length(spk_temp_delay)/time_delay;
        fr_stem = length(spk_temp_stem)/time_stem;
        fr_cp = length(spk_temp_cp)/time_cp;
        if Int1(dai,3) == 0
            delay_left_da(dai,:) = fr_delay;
            stem_left_da(dai,:) = fr_stem;
            cp_left_da(dai,:) = fr_cp;
        else
            delay_right_da(dai,:) = fr_delay;
            stem_right_da(dai,:) = fr_stem;
            cp_right_da(dai,:) = fr_cp;
        end
        if Int1(dai,4) == 0
            delay_correct_da(dai,:) = fr_delay;
            stem_correct_da(dai,:) = fr_stem;
            cp_correct_da(dai,:) = fr_cp;
        else
            delay_error_da(dai,:) = fr_delay;
            stem_error_da(dai,:) = fr_stem;
            cp_error_da(dai,:) = fr_cp;
        end
        delay_da(dai-1) = fr_delay;
        stem_da(dai-1) = fr_stem;
        cp_da(dai-1) = fr_cp;
    end
        for cdi = 2:numtrials2
        spk_temp_delay = find(spikeTimes>Int2(cdi-1,8) & spikeTimes<Int2(cdi,1));
        spk_temp_stem = find(spikeTimes>Int2(cdi-1,1) & spikeTimes<Int2(cdi-1,5));
        spk_temp_cp = find(spikeTimes>Int2(cdi-1,5) & spikeTimes<Int2(cdi-1,6));
        time_delay = (Int2(cdi,1) - Int2(cdi-1,8))/1e6;
        time_stem = (Int2(cdi-1,5) - Int2(cdi-1,1))/1e6;
        time_cp = (Int2(cdi-1,6) - Int2(cdi-1,5))/1e6;
        fr_delay = length(spk_temp_delay)/time_delay;
        fr_stem = length(spk_temp_stem)/time_stem;
        fr_cp = length(spk_temp_cp)/time_cp;
        if Int2(cdi,3) == 0
            delay_left_cd(cdi,:) = fr_delay;
        else 
            delay_right_cd(cdi,:) = fr_delay;
        end
        if Int2(cdi-1,3) == 0
            stem_left_cd(cdi,:) = fr_stem;
            cp_left_cd(cdi,:) = fr_cp;
        else
            stem_right_cd(cdi,:) = fr_stem;
            cp_right_cd(cdi,:) = fr_cp;
        end
        if Int2(cdi,4) == 0
            delay_correct_cd(cdi,:) = fr_delay;
        else
            delay_error_cd(cdi,:) = fr_delay;
        end
        if Int2(cdi-1,4) == 0
            stem_correct_cd(cdi,:) = fr_stem;
            cp_correct_cd(cdi,:) = fr_cp;
        else
            
            stem_error_cd(cdi,:) = fr_stem;
            cp_error_cd(cdi,:) = fr_cp;
        end
        delay_cd(cdi-1) = fr_delay;
        stem_cd(cdi-1) = fr_stem;
        cp_cd(cdi-1) = fr_cp;
        end
    
    delay_right_da(delay_right_da == 0) = NaN;    
    delay_right_da = delay_right_da(isfinite(delay_right_da(:, 1)), :);
    delay_left_da(delay_left_da == 0) = NaN;    
    delay_left_da = delay_left_da(isfinite(delay_left_da(:, 1)), :);
    delay_correct_da(delay_correct_da == 0) = NaN;    
    delay_correct_da = delay_correct_da(isfinite(delay_correct_da(:, 1)), :);
    delay_error_da(delay_error_da == 0) = NaN;    
    delay_error_da = delay_error_da(isfinite(delay_error_da(:, 1)), :);
    stem_right_da(stem_right_da == 0) = NaN;    
    stem_right_da = stem_right_da(isfinite(stem_right_da(:, 1)), :);
    stem_left_da(stem_left_da == 0) = NaN;    
    stem_left_da = stem_left_da(isfinite(stem_left_da(:, 1)), :);
    stem_correct_da(stem_correct_da == 0) = NaN;    
    stem_correct_da = stem_correct_da(isfinite(stem_correct_da(:, 1)), :);
    stem_error_da(stem_error_da == 0) = NaN;    
    stem_error_da = stem_error_da(isfinite(stem_error_da(:, 1)), :);
    cp_right_da(cp_right_da == 0) = NaN;    
    cp_right_da = cp_right_da(isfinite(cp_right_da(:, 1)), :);
    cp_left_da(cp_left_da == 0) = NaN;    
    cp_left_da = cp_left_da(isfinite(cp_left_da(:, 1)), :);
    cp_correct_da(cp_correct_da == 0) = NaN;    
    cp_correct_da = cp_correct_da(isfinite(cp_correct_da(:, 1)), :);
    cp_error_da(cp_error_da == 0) = NaN;    
    cp_error_da = cp_error_da(isfinite(cp_error_da(:, 1)), :);
    delay_right_cd(delay_right_cd == 0) = NaN;    
    delay_right_cd = delay_right_cd(isfinite(delay_right_cd(:, 1)), :);
    delay_left_cd(delay_left_cd == 0) = NaN;    
    delay_left_cd = delay_left_cd(isfinite(delay_left_cd(:, 1)), :);
    delay_correct_cd(delay_correct_cd == 0) = NaN;    
    delay_correct_cd = delay_correct_cd(isfinite(delay_correct_cd(:, 1)), :);
    delay_error_cd(delay_error_cd == 0) = NaN;    
    delay_error_cd = delay_error_cd(isfinite(delay_error_cd(:, 1)), :);
    stem_right_cd(stem_right_cd == 0) = NaN;    
    stem_right_cd = stem_right_cd(isfinite(stem_right_cd(:, 1)), :);
    stem_left_cd(stem_left_cd == 0) = NaN;    
    stem_left_cd = stem_left_cd(isfinite(stem_left_cd(:, 1)), :);
    stem_correct_cd(stem_correct_cd == 0) = NaN;    
    stem_correct_cd = stem_correct_cd(isfinite(stem_correct_cd(:, 1)), :);
    stem_error_cd(stem_error_cd == 0) = NaN;    
    stem_error_cd = stem_error_cd(isfinite(stem_error_cd(:, 1)), :);
    cp_right_cd(cp_right_cd == 0) = NaN;    
    cp_right_cd = cp_right_cd(isfinite(cp_right_cd(:, 1)), :);
    cp_left_cd(cp_left_cd == 0) = NaN;    
    cp_left_cd = cp_left_cd(isfinite(cp_left_cd(:, 1)), :);
    cp_correct_cd(cp_correct_cd == 0) = NaN;    
    cp_correct_cd = cp_correct_cd(isfinite(cp_correct_cd(:, 1)), :);
    cp_error_cd(cp_error_cd == 0) = NaN;    
    cp_error_cd = cp_error_cd(isfinite(cp_error_cd(:, 1)), :);
    
    delay_left_da_mean = mean(delay_left_da);
    delay_right_da_mean = mean(delay_right_da);
    delay_correct_da_mean = mean(delay_correct_da);
    delay_error_da_mean = mean(delay_error_da);
    delay_left_cd_mean = mean(delay_left_cd);
    delay_right_cd_mean = mean(delay_right_cd);
    delay_correct_cd_mean = mean(delay_correct_cd);
    delay_error_cd_mean = mean(delay_error_cd);
    stem_left_da_mean = mean(stem_left_da);
    stem_right_da_mean = mean(stem_right_da);
    stem_correct_da_mean = mean(stem_correct_da);
    stem_error_da_mean = mean(stem_error_da);
    stem_left_cd_mean = mean(stem_left_cd);
    stem_right_cd_mean = mean(stem_right_cd);
    stem_correct_cd_mean = mean(stem_correct_cd);
    stem_error_cd_mean = mean(stem_error_cd);
    cp_left_da_mean = mean(cp_left_da);
    cp_right_da_mean = mean(cp_right_da);
    cp_correct_da_mean = mean(cp_correct_da);
    cp_error_da_mean = mean(cp_error_da);
    cp_left_cd_mean = mean(cp_left_cd);
    cp_right_cd_mean = mean(cp_right_cd);
    cp_correct_cd_mean = mean(cp_correct_cd);
    cp_error_cd_mean = mean(cp_error_cd);
    delay_da_mean = mean(delay_da);
    stem_da_mean = mean(stem_da);
    cp_da_mean = mean(cp_da);
    delay_cd_mean = mean(delay_cd);
    stem_cd_mean = mean(stem_cd);
    cp_cd_mean = mean(cp_cd);
    
    PCA(ci,1) = abs(delay_left_da_mean - delay_right_da_mean);
    PCA(ci,2) = abs(delay_correct_da_mean - delay_error_da_mean);
    PCA(ci,3) = abs(stem_left_da_mean - stem_right_da_mean);
    PCA(ci,4) = abs(stem_correct_da_mean - stem_error_da_mean);
    PCA(ci,5) = abs(cp_left_da_mean - cp_right_da_mean);
    PCA(ci,6) = abs(cp_correct_da_mean - cp_error_da_mean);
    PCA(ci,7) = abs(delay_left_cd_mean - delay_right_cd_mean);
    PCA(ci,8) = abs(delay_correct_cd_mean - delay_error_cd_mean);
    PCA(ci,9) = abs(stem_left_cd_mean - stem_right_cd_mean);
    PCA(ci,10) = abs(stem_correct_cd_mean - stem_error_cd_mean);
    PCA(ci,11) = abs(cp_left_cd_mean - cp_right_cd_mean);
    PCA(ci,12) = abs(cp_correct_cd_mean - cp_error_cd_mean);
    PCA(ci,13) = abs(delay_da_mean - delay_cd_mean);
    PCA(ci,14) = abs(stem_da_mean - stem_cd_mean);
    PCA(ci,15) = abs(cp_da_mean - cp_cd_mean);
    
end

% Perform principal components analysis on firing rate differences between
% tasks
% Return the covariance scores for the first principal component for each
% condition
PCA(isnan(PCA)) = 0;
[COEFF, SCORE, latent, tsquared, explained] = pca(PCA);
max_PC1 = max(COEFF(:,1));
max_PC2 = max(COEFF(:,2));
idx_1 = find(COEFF(:,1) == max_PC1);
idx_2 = find(COEFF(:,2) == max_PC2);
PC1_1 = COEFF(1,1);
PC1_2 = COEFF(2,1);
PC1_3 = COEFF(3,1);
PC1_4 = COEFF(4,1);
PC1_5 = COEFF(5,1);
PC1_6 = COEFF(6,1);
PC1_7 = COEFF(7,1);
PC1_8 = COEFF(8,1);
PC1_9 = COEFF(9,1);
PC1_10 = COEFF(10,1);
PC1_11 = COEFF(11,1);
PC1_12 = COEFF(12,1);
PC1_13 = COEFF(13,1);
PC1_14 = COEFF(14,1);
PC1_15 = COEFF(15,1);
[~,reconstructed] = pcares(PCA,2);
C = cov(PCA);
[V, D] = eig(C);
DA_Correct = find(Int1(:,4) == 0);
DA_Performance = length(DA_Correct)/size(Int1,1);
CD_Correct = find(Int2(:,4) == 0);
CD_Performance = length(CD_Correct)/size(Int2,1);
figure()
pareto(explained)
xlabel('Principal Component')
ylabel('Variance Explained (%)')

clear cdi ci cluster clusters cp_cd cp_cd_mean cp_correct_cd cp_correct_cd_mean cp_correct_da cp_correct_da_mean cp_da cp_da_mean cp_error_cd cp_error_cd_mean cp_error_da cp_error_da_mean cp_left_cd cp_left_cd_mean cp_left_da cp_left_da_mean cp_right_cd cp_right_cd_mean cp_right-da cp_right_da_mean dai datafolder delay_cd delay_cd_mean delay_correct_cd delay_correct_cd_mean delay_correct_da delay_correct_da_mean delay_da delay_da_mean delay_error_cd delay_error_cd_mean delay_error_da delay_error_da_mean delay_left_cd delay_left_cd_mean delay_left_da delay_left_da_mean delay_right_cd delay_right_cd_mean delay_right_da delay_right_da_mean ExtractedAngle ExtractedX ExtractedY fr_cp fr_delay fr_stem Int1 Int2 Int1 netDrive numtrials1 numtrials2 spikeTimes spk_temp_cp spk_temp_delay spk_temp_stem stem_cd stem_cd_mean stem_correct_cd stem_correct_cd_mean stem_correct_da stem_correct_da_mean stem_da stem_da_mean stem_error_cd stem_error_cd_mean stem_error_da stem_error_da_mean stem_left_cd stem_left_cd_mean stem_left_da stem_left_da_mean stem_right_cd stem_right_cd_mean stem_right_da stem_right_da_mean time_cp time_delay time_stem TimeStamps tsquared C CD_Correct cp_right_da DA_Correct idx_1 idx_2 Int3   