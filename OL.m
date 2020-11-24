warning('off','all')
close("all")
clear

%% setup

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
if ~strcmp(lastdir, "AE4301P")
    error(strcat("Please run ",...
                 mfilename,...
                 " from the root directory of this project"...
                 ))
end

% load Steady State system; if it doesn't exist, run trim_lin.m
fprintf("OL: Checking if SS matrices exist...")
if exist("fc_files/SS_Std_LoFi_4DoF.mat", 'file') > 0
    fprintf("OK\n")
    
    load('fc_files/SS_Std_LoFi_4DoF.mat');
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run trim_lin.m
    
    fprintf("OL: Importing SS matrix...")
    
    load('fc_files/SS_Std_LoFi_4DoF.mat');
    fprintf("OK, recovered\n")
end

% make folder for the plots; if it doesn't exist yet
mkdir OL_plot_files

% set visibility of on-screen plots (they are saved as eps anyway)
show_plots = 'on';

% set figure pixes sizes
fig_size = [600 400]; % width, height
fig_pos = [100 100 100+fig_size(1) 100+fig_size(2)];


%% Numeric Characteristics

fprintf("OL: Calculate table of numerical characteristics...")

char_tab = mchar(SS_long, SS_lat);
writetable(char_tab, 'OL_plot_files/OL_char.csv', 'WriteRowNames', true)


%%%%% build output table
% with a table we have all info in a single object (char_tab) and we 
% can access elements like this:
%
%%% show entire table:
% char_tab
%
%%% example to get a scalar
% char_tab.NaturalFrequency("Phugoid");

%%% example to get a column
% char_tab.DampingRatio;

fprintf("OK\n")

%% PZ plots

fprintf("OL: making Pole Zero maps...")
    run make_PZ_plots.m

fprintf("OK\n")


%% time domain plots

fprintf("OL: making time domain response plots...")
    run make_time_plots.m

fprintf("OK\n")

%%

fprintf("OL: done\n")

