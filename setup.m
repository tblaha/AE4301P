%% make path

addpath("F16Sim")
addpath("fc_files")


%% Check for mex and if not existent, mex it outselves

if exist('nlplant') ~= 3
    disp("Mex doesn't exist in F16Sim directory")
    disp("")
    disp("Attempting Compilation")
    disp("----------------")
    
    pause on
    pause(2)
    pause off
    
    cd F16Sim
    
    try
        o = evalc("mex nlplant.c");
    catch
        if exist('nlplant') == 3
            disp("Mex Produced and error; but we can continue")
        end
    end
    
    cd ../
       
end