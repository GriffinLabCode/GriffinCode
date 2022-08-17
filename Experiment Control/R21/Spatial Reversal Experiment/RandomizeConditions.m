%% generate experimental/yoked days
clear; clc;
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% some days will be between day reversal and within day reversal, some days
% will be carry out previous days reversal then within day reversal
rng('shuffle');
randDay = randsample([1,2],4);
for i = 1:4
    if randDay(i) == 1
        testingDay(i,:)='MW'; % memory of previous day -> within reversal
    elseif randDay(i) == 2
        testingDay(i,:)='BW'; % between reversal -> within reversal
    end
end
controls   = cellstr(repmat('C',[4 1]));
testingDay = cellstr(testingDay);
testingConditions=interleave_vars(testingDay,controls)';

place2store = ['X:\01.Experiments\R21\',targetRat];
cd(place2store);
save('SRT_testingDays','testingConditions')


