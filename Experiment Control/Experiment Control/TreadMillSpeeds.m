%% treadmill speeds
% this function stores all treadmill speeds into a structure array
% comprised of uint8 (8 bit) variables.
%
% to get the treadmill speeds or Hex codes for it, you need to use the 
% COM helper linked to the ConductMaze software. Make sure the COM helper 
% is opened on the correct port that is virtually linked (so you may need
% a virtual com tool also). Then, set TS to 7 on ConductMaze, and send 
% that information to the COM helper. The COM helper should spit out a 
% hex code. Next, grab that hex code and use the hex2dec function to
% convert it. The result will be what you write to the micro controller to
% tell it to start/stop/adjust speed.
%
% INPUTS:
%   no inputs required
%
% OUTPUTS:
%   treadSpeed: a struct array containing all possible hex code speeds
%   converted into decimal format for maze control
%
% written by John Stout

function [treadSpeed] = TreadMillSpeeds()

% define all possible speeds up to 50 rpms
treadSpeed.two          = hex2dec(["03" "06" "00" "02" "00" "22" "A9" "F1"]);
treadSpeed.three        = hex2dec(["03" "06" "00" "02" "00" "33" "69" "FD"]);
treadSpeed.four         = hex2dec(["03" "06" "00" "02" "00" "44" "29" "DB"]);
treadSpeed.five         = hex2dec(["03" "06" "00" "02" "00" "55" "E9" "D7"]);
treadSpeed.six          = hex2dec(["03" "06" "00" "02" "00" "66" "A9" "C2"]);
treadSpeed.seven        = hex2dec(["03" "06" "00" "02" "00" "77" "69" "CE"]);
treadSpeed.eight        = hex2dec(["03" "06" "00" "02" "00" "88" "29" "8E"]);
treadSpeed.nine         = hex2dec(["03" "06" "00" "02" "00" "99" "E9" "82"]);
treadSpeed.ten          = hex2dec(["03" "06" "00" "02" "00" "AA" "A9" "97"]);
treadSpeed.eleven       = hex2dec(["03" "06" "00" "02" "00" "BB" "69" "9B"]);
treadSpeed.twelve       = hex2dec(["03" "06" "00" "02" "00" "CC" "29" "BD"]);
treadSpeed.thirteen     = hex2dec(["03" "06" "00" "02" "00" "DD" "E9" "B1"]);
treadSpeed.fourteen     = hex2dec(["03" "06" "00" "02" "00" "EE" "A9" "A4"]);
treadSpeed.fifteen      = hex2dec(["03" "06" "00" "02" "00" "FF" "69" "A8"]);
treadSpeed.sixteen      = hex2dec(["03" "06" "00" "02" "01" "10" "29" "B4"]);
treadSpeed.seventeen    = hex2dec(["03" "06" "00" "02" "01" "22" "A8" "61"]);
treadSpeed.eighteen     = hex2dec(["03" "06" "00" "02" "01" "33" "68" "6D"]);
treadSpeed.nineteen     = hex2dec(["03" "06" "00" "02" "01" "44" "28" "4B"]);
treadSpeed.twenty       = hex2dec(["03" "06" "00" "02" "01" "55" "E8" "47"]);
treadSpeed.twentyOne    = hex2dec(["03" "06" "00" "02" "01" "66" "A8" "52"]);
treadSpeed.twentyTwo    = hex2dec(["03" "06" "00" "02" "01" "77" "68" "5E"]);
treadSpeed.twentyThree  = hex2dec(["03" "06" "00" "02" "01" "88" "28" "1E"]);
treadSpeed.twentyFour   = hex2dec(["03" "06" "00" "02" "01" "99" "E8" "12"]);
treadSpeed.twentyFive   = hex2dec(["03" "06" "00" "02" "01" "AA" "A8" "07"]);
treadSpeed.twentySix    = hex2dec(["03" "06" "00" "02" "01" "BB" "68" "0B"]);
treadSpeed.twentySeven  = hex2dec(["03" "06" "00" "02" "01" "CC" "28" "2D"]);
treadSpeed.twentyEight  = hex2dec(["03" "06" "00" "02" "01" "DD" "E8" "21"]);
treadSpeed.twentyNine   = hex2dec(["03" "06" "00" "02" "01" "EE" "A8" "34"]);
treadSpeed.thirty       = hex2dec(["03" "06" "00" "02" "01" "FF" "68" "38"]);
treadSpeed.thirtyOne    = hex2dec(["03" "06" "00" "02" "02" "10" "29" "44"]);
treadSpeed.thirtyTwo    = hex2dec(["03" "06" "00" "02" "02" "21" "E8" "90"]);
treadSpeed.thirtyThree  = hex2dec(["03" "06" "00" "02" "02" "33" "68" "9D"]);
treadSpeed.thirtyFour   = hex2dec(["03" "06" "00" "02" "02" "44" "28" "BB"]);
treadSpeed.thirtyFive   = hex2dec(["03" "06" "00" "02" "02" "55" "E8" "B7"]);
treadSpeed.thirtySix    = hex2dec(["03" "06" "00" "02" "02" "66" "A8" "A2"]);
treadSpeed.thirtySeven  = hex2dec(["03" "06" "00" "02" "02" "77" "68" "AE"]);
treadSpeed.thirtyEight  = hex2dec(["03" "06" "00" "02" "02" "88" "28" "EE"]);
treadSpeed.thirtyNine   = hex2dec(["03" "06" "00" "02" "02" "99" "E8" "E2"]);
treadSpeed.fourty       = hex2dec(["03" "06" "00" "02" "02" "AA" "A8" "F7"]);
treadSpeed.fourtyOne    = hex2dec(["03" "06" "00" "02" "02" "BB" "68" "FB"]);
treadSpeed.fourtyTwo    = hex2dec(["03" "06" "00" "02" "02" "CC" "28" "DD"]);
treadSpeed.fourtyThree  = hex2dec(["03" "06" "00" "02" "02" "DD" "E8" "D1"]);
treadSpeed.fourtyFour   = hex2dec(["03" "06" "00" "02" "02" "EE" "A8" "C4"]);
treadSpeed.fourtyFive   = hex2dec(["03" "06" "00" "02" "02" "FF" "68" "C8"]);
treadSpeed.fourtySix    = hex2dec(["03" "06" "00" "02" "03" "10" "28" "D4"]);
treadSpeed.fourtySeven  = hex2dec(["03" "06" "00" "02" "03" "21" "E9" "00"]);
treadSpeed.fourtyEight  = hex2dec(["03" "06" "00" "02" "03" "32" "A8" "CD"]);
treadSpeed.fourtyNine   = hex2dec(["03" "06" "00" "02" "03" "43" "68" "E9"]);
treadSpeed.fifty        = hex2dec(["03" "06" "00" "02" "03" "55" "E9" "27"]);

end
