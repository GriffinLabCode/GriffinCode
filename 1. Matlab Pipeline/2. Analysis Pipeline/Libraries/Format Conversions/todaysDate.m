%% function that extracts todays date
% primarily useful for saving variables
% output is a string with '_' delimeter useful for saving variables.
function [date] = todaysDate()
    date = char(datetime("today"));
    date = strsplit(date,'-');
    date = join(date,'_');
    date = date{:};
    