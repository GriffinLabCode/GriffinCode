clear all
close all
clc

% Example on how to read a .doric file using Matlab
%
% Note:
% This example will not work with Octave. In case you want to use Octave you can
% use the load() function and you can navigate in the struct with the help of
% some functions like isstruct(), fieldnames (), numfields()
%
% Example file generated with an FPC
% There is two way to do it Automatically or Manually


%First set the name of the file that you want to extract the data from in
%this example the file is in the current folder where we have the matlab script
filename = 'Console_Acq_0000.doric'; 


%------------ Automatically------------------------------
%It's possible to use a function that we codded to extract all the data
%automatically. The function is named ExtractDataAcquisition .

Data_Acquired = ExtractDataAcquisition(filename);

for k = 1:length(Data_Acquired)
    figure
    Datatmp = Data_Acquired(k);
    plot(Datatmp.Data(2).Data,Datatmp.Data(1).Data)
    title(Datatmp.Name)
end





%--------------------Manually-----------------------------
%It's also possible to do every thing manually 
%To help you it's possible to display what is inside a .doric file:
%h5disp(filename,'/DataAcquisition','min')


%It will give that:
% HDF5 Console_Acq_0000.doric 
% Group '/DataAcquisition' 
%     Group '/DataAcquisition/FPConsole' 
%         Group '/DataAcquisition/FPConsole/Signals' 
%             Group '/DataAcquisition/FPConsole/Signals/Series0001' 
%                 Group '/DataAcquisition/FPConsole/Signals/Series0001/AnalogIn' 
%                     Dataset 'AIN01' 
%                     Dataset 'Time' 
%                 Group '/DataAcquisition/FPConsole/Signals/Series0001/AnalogOut' 
%                     Dataset 'AOUT01' 
%                     Dataset 'Time' 




%If for example I want to load data and time from the AnalogIn channel I use those commands:
SignalIn = h5read(filename,'/DataAcquisition/FPConsole/Signals/Series0001/AnalogIn/AIN01');
SignalInInfo = h5info(filename,'/DataAcquisition/FPConsole/Signals/Series0001/AnalogIn/AIN01').Attributes;

TimeIn = h5read(filename,'/DataAcquisition/FPConsole/Signals/Series0001/AnalogIn/Time');
TimeInInfo = h5info(filename,'/DataAcquisition/FPConsole/Signals/Series0001/AnalogIn/Time').Attributes;

figure
plot(TimeIn,SignalIn)