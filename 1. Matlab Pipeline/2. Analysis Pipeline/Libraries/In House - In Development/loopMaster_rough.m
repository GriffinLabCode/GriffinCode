% is there a way to call on any function? The answer is yes. Its simple,
% but whats not simple is being able to provide all the required inputs


function [varargout] = loopMaster(fun_name)


if contains(loop_Datafolders,'y') | contains(loop_Datafolders,'Y')

    % calculate firing rate for all sessions
    cd(Datafolders);
    folder_names = dir;

    % adjust the looping index?
    prompt  = 'Adjust the looping index? [Y/N] ';
    adjLoop = input(prompt,'s');

    if adjLoop == 'Y'
        prompt = 'Enter the loop index ';
        looper = str2num(input(prompt,'s'));
    else
        looper = 3:length(folder_names);
    end

    % loop across folders
    out = cell([1 length(folder_names)-2]);
    
    for nn = looper    

        Datafolders = Datafolders;
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(nn).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);

        % get VTE data in a structure array that is organized based on
        % rat, day condition, and infusion type
        apply_fun = str2func(fun_name);
        
        % number of inputs
        name = cell(nargin,1);
        inputname(nargin(apply_fun))
        
        inputname(apply_fun)
        
        help(apply_fun)
        
        [out] = apply_fun(datafolder,int_name,vt_name,missing_data,middleStemPosition,stemOrientation,preSmooth,mazeLoc);


        % disp
        disp(['Finished with session ',num2str(nn-2)])

    end
    
end