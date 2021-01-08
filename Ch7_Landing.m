%% setup --> import both 5DoF and 2DoF models

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
VerifyDirectory(lastdir)


% load Steady State system; if it doesn't exist, run Ch4_0_TrimLin.m
fprintf("Ch7_Landing: Checking if SS matrices exist...")
if (exist("SS_GS_LoFi_2DoF.mat", 'file') > 0) ...
        && (exist("SS_GS_LoFi_5DoF.mat", 'file') > 0)
    fprintf("OK\n")
    
    TwoDoF = load('SS_GS_LoFi_2DoF.mat');
    FiveDoF = load("SS_GS_LoFi_5DoF");
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run Ch4_0_TrimLin.m
    
    fprintf("Ch7_Landing: Importing SS matrix...")
    
    TwoDoF = load('SS_GS_LoFi_2DoF.mat');
    FiveDoF = load("SS_GS_LoFi_5DoF");
    fprintf("OK, recovered\n")
end

% make folder for the plots; if it doesn't exist yet
outdir = "Outputs/Ch7_Landing";
mkdir(outdir)
addpath(outdir)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Basically, repeat the bulk of Ch6_q_Command %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% get K_alpha and K_q gains

% desired pole
% w_n = 0.03*xu(7)*0.3048; % natural freq
w_n = 1 * 2 * pi; % natural freq; a bit arbitrary right now
z   = 0.85; % damping ratio
recip_Ttheta2_target = 0.75*w_n; % reciprocal of the desired zero

SS_long = TwoDoF.SS_long;
xu      = TwoDoF.xu;
run PlacePoles.m  % provides Ka and Kq



%% Open Loop dynamics

ss_OL = ss(A, B, C, D);
tf_OL_el2q = zpk(minreal(tf(ss_OL(2))));



%% get transfer functions of the pole placed systems

% alias for no servo
q_cmd = H_pp_filt_q;
[~, zeta, ~] = damp(q_cmd);


% alias for servo added back in
% servo TF
H_servo = 22.2/(s+22.2);

% linearize simulink model with correct implementation of servos
sim_servo = linmod("q_loop_servo");
sim_servo_ss = ss(sim_servo.a, sim_servo.b, sim_servo.c, sim_servo.d);

q_cmd_servo = zpk(minreal( tf(sim_servo_ss(2)) )); % 2nd output: q
[~, zeta_servo, ~] = damp(q_cmd_servo);


%% plot gust response 

% states at trim condition:
trim_s = [xu(8), xu(11), xu(14)]'; % computed during trim_lin.m

% define gust as task 6.3.4.
v_z_gust = 4.572; % m/s
a_ind = atan(v_z_gust / (0.3048 * xu(7))); % radians --> induced Delta AOA

% invoke plotting subroutine
run plot_gust_response.m

% export figure to results folder
set(GR, 'Color', 'w');
export_fig('Outputs/Ch7_Landing/Landing_gust_response.png', '-dpng', '-painters', GR)


%% plot pulse response

% get characteristics and current zero for non-servo and servo systems
% (only used for "Verification"
[Omega_long, Zeta_long, P_long] = damp(q_cmd);
T_theta2 = -1/q_cmd.Z{1};

[Omega_long_servo, Zeta_long_servo, P_long_servo] = damp(q_cmd_servo);
T_theta2_servo = -1/q_cmd_servo.Z{1};

% in degrees after all...
q_cmd   = 180/pi*q_cmd;
q_cmd_servo = 180/pi*q_cmd_servo;

% invoke plotting subroutine
run plot_pulse_response.m

% export figure to results folder
set(step_up_down, 'Color', 'w');
export_fig('Outputs/Ch7_Landing/Landing_step_up_down.png', '-dpng', '-painters', step_up_down)


%% clean workspace
% clearvars -except Ka Kq TwoDoF FiveDoF sys_pp LL_filt



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


h_dot_flare_zero = xu(7)*sind(-3); %[ft/s]
x1 = 1100; % ft
tau = x1/(1.5*xu(7));
h_flare = -1*tau*h_dot_flare_zero; %[ft]





%% design control loops


% % linearize system:
% sys = linmod('Landing');
% 
% % state space
% % inputs:  [ u_th, u_ref (speed ref), u_el   , q_ref  , theta_ref ]
% % outputs: [  y_h,   y_u            , y_alpha, y_theta,       y_q, Gamma, hdot ]
% ss_sys = ss(sys.a, sys.b, sys.c, sys.d);
% 
% %%% Define loop to investigate with sisotool
% % loop_in = 1; loop_out = 2;   % Thrust to speed
% % loop_in = 3; loop_out = 5;   % Elevator to q
% % loop_in = 4; loop_out = 4;   % q_ref to theta
% % loop_in = 5; loop_out = 6;   % theta_ref to Gamma (GS error)
% loop_in = 5; loop_out = 7;   % theta_ref to hdot (for Flare)
% 
% % transfer function
% sub_loop_tf = zpk(minreal(tf(ss_sys(loop_out, loop_in))));
% 
% % actually use SISOtool
% sisotool(sub_loop_tf)







