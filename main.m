close("all")
clear

%% setup

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
if (~strcmp(lastdir, "AE4301P")) || (exist("./F16Sim_rev/") ~= 7)
    error(strcat("Please run ",...
                 mfilename,...
                 " from the root directory of this project"...
                 ))
end

run setup.m

%% generate flight conditions

% our Group's standard flight condition: 30000ft, 900ft/s
run gen_fc.m


%% Accel.m block

% accelerometer tasks



%% OL.m block

% observe the characteristics in the Command Window output and 6 plots that
% pop up
run OL.m


% Verify the longitudinal system reduction (5.0, 5.2)
%
% Observe the identical transfer functions in the Command Window output and
% the 2 plots that pop up
run Verify_Reduction.m



