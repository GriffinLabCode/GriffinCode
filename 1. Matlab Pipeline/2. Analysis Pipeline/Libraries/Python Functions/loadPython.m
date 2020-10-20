%% Python setup
%
% if python is not downloaded, go to the python website and download the
% recent version
%
% in terminal: 
%               py -m pip install utils
%               py -m pip install --upgrade pip
%               py -m pip install numpy
%               py -m pip install pandas
%               py -m pip install scipy
%
% -- INPUTS -- %
% pythonHome: the directory where python.exe is located. for example:
%           C:\Users\uggriffin\AppData\Local\Programs\Python\Python38
%
% -- How to call python fun -- %
% here, you could call an in house function like so 
%           py.pyShannonsEntropy.shannons_entropy(binned_data)
%
% -- Utility -- %
% You can have a single python function with a bunch of internal functions
% to call from. You can also write python code to use in matlab, or
% eventually just use python. It is a good way to transition

function [] = loadPython(pythonHome)

% information to start
disp('Make sure python and required libraries are downloaded on your machine...')

% add the python exe file
pythonHome = strcat(pythonHome,'\python.exe');

% this works if you define the location of python
pyversion(pythonHome);

% get python loading information
%try [version,location,loaded] = pyversion; catch; end;

% get the directory that houses this function
py2matDir = fileparts(which('loadPython'));

if count(py.sys.path,py2matDir) == 0
    insert(py.sys.path,int32(0),py2matDir);
end



