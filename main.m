%% setup

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
VerifyDirectory(lastdir)

run setup.m


%% IMPORTANT: Do you want to see plots on-screen? (they are saved anyway in the Outputs directory)

% show plots on-screen?
show_plots = "off";


%% generate flight conditions


new_section("main: generate FlightCondition.mat file")
run gen_fc.m


%% Chapter 4.1 Acclerometer

new_section("main: Running Acclerometer tasks of Chapter 4.1")
run Ch4_1_Accel.m


clearvars -except show_plots fc zeros_el2an_sweep


%% Chapter 5 Open Loop Characteristics

% observe the characteristics in the Command Window output and 6 plots that
% pop up
new_section("main: Running Open Loop tasks of Chapter 5")
run Ch5_OpenLoop.m


% Verify the longitudinal system reduction (5.0, 5.2)
%
% Observe the identical transfer functions in the Command Window output and
% the 2 plots that pop up
new_section("main: Verify the reduction techniques used in Chapter 5 and after")
run VerifyReduction.m



clearvars -except show_plots fc zeros_el2an_sweep char_tab


%% Chapter 6 q command system

new_section("main: q-Command (Chapter 6) Pole Placement and Handling Characteristics")

% note: To obtain the last line in Table 7; re-run Ch6_q_Command.m, but
% uncomment line 55
run Ch6_q_Command.m



%% Chapter 7 Landing Controller pitch 

% definitely check out Landing.slx!

new_section("main: Landing Controller (Chapter 7)")

% note: it's hard to show with a script; but the method of tuning the
% controllers/couplers of the Landing.slx was with SISOTool! 
% 1. we assigned inputs and outputs in the Simulink model
% 2. changed the Simulink model to an open-loop version of the respective loop
% 3. then linearized 
% 4. then opened SISOTool
% 5. save the result in Outputs/Ch7_Landing/Landing_controllers
% 
% Check out the last cell of the Ch7_Landing.m script:
run Ch7_Landing.m



%%

function new_section(headline)

    % our Group's standard flight condition: 30000ft, 900ft/s
    fprintf("\n")
    fprintf("\n")
    fprintf("\n")
    disp("    " + headline)
    disp("    " + repmat('-', 1, length(char(headline))))
    fprintf("\n")

end
