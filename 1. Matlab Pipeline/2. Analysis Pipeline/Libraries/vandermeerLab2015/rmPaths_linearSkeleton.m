% linear position startup function
function [] = rmPaths_linearSkeleton()
disp('Please note that many functions are taken from van der meer lab. ');

% This is the directory where the "Startup" function is located
s = what('vandermeerLab2015');
main_directory = s.path;

% interface with user to redefine main_directory
disp(main_directory)
prompt = 'Is the directory above the same directory where van der meer code is located? [Y/N] ';
resp = input(prompt,'s');

if contains(resp,'N') || contains(resp,'n')
    prompt = 'Please enter the directory where van der meer code is located, then press "Enter" ';
    main_directory = input(prompt,'s');
else
end

% vandermeer lab add-ons
addon{1} = '\shared\io';
addon{2} = '\shared\datatypes\tsd';
addon{3} = '\shared\util';
addon{4} = '\shared\datatypes\iv';
addon{5} = '\shared\linearize';

% addpaths
for i = 1:length(addon)
    rmpath([main_directory,addon{i}])
end

disp('Paths required for creating linear skeleton have been removed');

end


