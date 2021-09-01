%% csc backconverter
% do you have vectorized lfp data that needs reversing? For example, maybe
% you downsampled your LFP, but now want to go back into matrix format, the
% code below should acheive just that!
%
% This code was tested by pulling in known matrices and sizes, running the
% code to backconvert, then ensuring that backconverted LFP canceled out
% originally recorded LFP
%
% -- INPUTS -- %
% lfp_vec:
%
% -- OUTPUTS -- %
% samples_back
%
% JS

function [samples_back] = csc_backconverter(lfp_vec)
% note that there will always be 512 rows, so I can easily backwards
% convert. Moreover, 512*n will grant you the length of vectorized data.
% therefore vectorized m/512 will give me column length n of matrixed data
m   = length(lfp_vec);
len = m/512; % the number of columns expected in normally sampled data

% loop across columns and organize data
samples_back = [];
for i = 1:len
    samples_back(:,i) = lfp_vec(1:512);
    % erase what you added, and continue
    lfp_vec(1:512)=[];
end

% tester
%{
    load('CSC7')
    m   = length(lfp_vec);
    len = m/512; 
    samples_back = [];
    for i = 1:len
        samples_back(:,i) = lfp_vec(1:512);
        lfp_vec(1:512)=[];
    end
    checker = samples_back-Samples;
    find(checker ~= 0) % this should be empty if its been done correctly
%}

