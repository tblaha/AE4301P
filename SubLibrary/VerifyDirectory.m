function VerifyDirectory(lastdir)

    if (~strcmp(lastdir, "AE4301P")) || (exist("./F16Sim_rev/") ~= 7)
        error(strcat("Please run ",...
                     mfilename,...
                     " from the root directory of this project"...
                     ))
    end


end