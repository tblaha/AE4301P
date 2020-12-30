%% setup

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
VerifyDirectory(lastdir)

% load Steady State system; if it doesn't exist, run Ch4_0_TrimLin.m
fprintf("Ch5_OpenLoop: Checking if SS matrices exist...")
if exist("SS_Std_LoFi_4DoF.mat", 'file') == 2
    fprintf("OK\n")
    
    load('SS_Std_LoFi_4DoF.mat');
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run Ch4_0_TrimLin.m
    
    fprintf("Ch5_OpenLoop: Importing SS matrix...")
    
    load('SS_Std_LoFi_4DoF.mat');
    fprintf("OK, recovered\n")
end

% make folder for the plots; if it doesn't exist yet
outdir = "Outputs/Ch5_OpenLoop";
mkdir(outdir)
addpath(outdir)

% set figure pixes sizes
fig_size = [600 400]; % width, height
fig_pos = [100 100 100+fig_size(1) 100+fig_size(2)];


%% Numeric Characteristics

fprintf("Ch5_OpenLoop: Calculate table of numerical characteristics...")

char_tab = mchar(SS_long, SS_lat);
writetable(char_tab, 'Outputs/Ch5_OpenLoop/OL_char.csv', 'WriteRowNames', true)
fprintf("OK\n")

disp("Open Loop Characteristics: ")
char_tab


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


%% PZ plots

fprintf("Ch5_OpenLoop: making Pole Zero maps...")
    run make_PZ_plots.m

fprintf("OK\n")


%% time domain plots

fprintf("Ch5_OpenLoop: making time domain response plots...")
    run make_time_plots.m

fprintf("OK\n")

%%

fprintf("Ch5_OpenLoop: done\n")

