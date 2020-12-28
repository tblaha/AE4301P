clear
close("all")

%% setup --> import both 5DoF and 2DoF models

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
if ~strcmp(lastdir, "AE4301P")
    error(strcat("Please run ",...
                 mfilename,...
                 " from the root directory of this project"...
                 ))
end

% load Steady State system; if it doesn't exist, run trim_lin.m
fprintf("q_ctl: Checking if SS matrices exist...")
if (exist("fc_files/SS_GS_LoFi_2DoF.mat", 'file') > 0) ...
        && (exist("fc_files/SS_GS_LoFi_5DoF.mat", 'file') > 0)
    fprintf("OK\n")
    
    TwoDoF = load('fc_files/SS_GS_LoFi_2DoF.mat');
    FiveDoF = load("fc_files/SS_GS_LoFi_5DoF");
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run trim_lin.m
    
    fprintf("q_ctl: Importing SS matrix...")
    
    TwoDoF = load('fc_files/SS_GS_LoFi_2DoF.mat');
    FiveDoF = load("fc_files/SS_GS_LoFi_5DoF");
    fprintf("OK, recovered\n")
end


%% get K_alpha and K_q gains

% desired pole
% w_n = 0.03*xu(7)*0.3048; % natural freq
w_n = 1 * 2 * pi; % natural freq; a bit arbitrary right now
z   = 0.5; % damping ratio
recip_Ttheta2_target = 0.75*w_n; % reciprocal of the desired zero

SS_long = TwoDoF.SS_long;
run PlacePoles.m  % provides Ka and Kq

% clean workspace
clearvars -except Ka Kq TwoDoF FiveDoF sys_pp LL_filt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prepare workspace for Simulink execution %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 5 DoFs model:
% Longitudinal States --> h, u, \alpha, \theta, q
SS_long = FiveDoF.SS_long;
SS_long.C = eye(5); % degrees are gonna kill me, some time in the future
xu = FiveDoF.xu;


%% Scenario Configuration

airport_elevation = 3000; % ft
glideslope = 3; % degree
time_to_intercept = 10; % sec


%% Visualization config for FlightGear
% Spangdahlem Airbase Germany, 480th Fighter Squadron (F16-CJ)
% RWY 23 (commonly used for landings)

% Threshold coordinates
Th23 = [6.71346; 49.98628]; % longE; latN
Th05 = [6.68358; 49.96680]; % longE; latN

% length and bearing of runway, computed with some online great-circle tool
L_RWY   = 3042.6 / 0.3048; % ft
Psi_RWY = 224.7;           % degrees

% unit vector of coordinates along runway
RWY_vector = (Th05 - Th23) / L_RWY; % unit vector pointing from approach to threshold

% height of the runway from wikipedia plus "empirical" correction
h_RWY = 364.8 / 0.3048 + 3; % ft over MSL


%% Set initial states

% get trim condition in appropriate units for states
con_trim = [xu(3), xu(7), xu(8), xu(5), xu(11)]';
con_init = [0, 0, 0, 0, 0]';  % state space system initial conditions

% get trim condition for inputs
trim_thrust = xu(13);
trim_elevator = xu(14);

% set initial x-position as 10seconds from GS intercept
init_x_pos = - ( time_to_intercept*con_trim(2)... % distance covered until intercepting GS
                    + (con_trim(1) - airport_elevation) ... % inial height over ground
                       / (tand(glideslope)) );  % divide by tan to horiz distance until threshold

%% design flare law

h_flare = 30; % ft over ground; guess for now


%% design control loops
% 
% 
% % linearize system:
% sys = linmod('Landing');
% 
% % state space
% ss_sys = ss(sys.a, sys.b, sys.c, sys.d);
% % inputs:  [ u_th, u_ref (speed ref), u_el   , q_ref  , theta_ref ]
% % outputs: [  y_h,   y_u            , y_alpha, y_theta,       y_q, Gamma ]
% 
% 
% %%% Define loop to investigate with sisotool
% % loop_in = 1; loop_out = 2;   % Thrust to speed
% loop_in = 3; loop_out = 5;   % Elevator to q
% % loop_in = 4; loop_out = 4;   % q_ref to theta
% % loop_in = 5; loop_out = 6;   % theta_ref to Gamma (GS error)
% 
% sub_loop_tf = zpk(minreal(tf(ss_sys(loop_out, loop_in))));
% 
% % actually use SISOtool
% sisotool(sub_loop_tf)
% 
% 




