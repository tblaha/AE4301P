%% clear everything

% Clear command window:
clc;

% Close figures:
try
  close('all', 'hidden');
catch  % do nothing
end

% clear workspace
clear

% Close open files:
fclose('all');

% Reset the warning status   EDITED:
warning('off', 'all');


%% make path

disp("setup.m: Setting up matlab-path")
% restore path
path(pathdef)

% external stuff
addpath("ExternalModules")
addpath("ExternalModules/F16Sim")
addpath("ExternalModules/export_fig")

% F16 simulator modifications
addpath(genpath("F16Sim_rev"))

% Functions/Models/Outputs
addpath(genpath("SubLibrary"))
addpath(genpath("SSModels"))
addpath(genpath("SLModels"))

% outputs
mkdir("Outputs")
addpath(genpath("Outputs"))

%% default variables, if main is not run

show_plots = "off";


%% Check for mex and if not existent, mex it outselves

if exist('nlplant') ~= 3
    disp("setup.m: Mex doesn't exist in F16Sim directory")
    disp("")
    disp("setup.m: Attempting Compilation")
    disp("setup.m: ----------------")
    
    pause on
    pause(2)
    pause off
    
    cd ExternalModules/F16Sim
    
    try
        o = evalc("mex nlplant.c");
    catch
        if exist('nlplant') == 3
            disp("setup.m: Mexing produced an error; but we can continue")
        else
            disp("setup.m: mexing failed. Please manage to obtain nlplant.*mex yourself")
        end
    end
    
    cd ../../
       
end