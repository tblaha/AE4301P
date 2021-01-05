%% setup

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
VerifyDirectory(lastdir)

% load Steady State system; if it doesn't exist, run Ch4_0_TrimLin.m
fprintf("Ch6_q_Command: Checking if SS matrices exist...")
if exist("SS_Std_LoFi_2DoF.mat", 'file') > 0
    fprintf("OK\n")
    
    load('SS_Std_LoFi_2DoF.mat');
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run Ch4_0_TrimLin.m
    
    fprintf("Ch6_q_Command: Importing SS matrix...")
    
    load('SS_Std_LoFi_2DoF.mat');
    fprintf("OK, recovered\n")
end

% make folder for the plots; if it doesn't exist yet
outdir = "Outputs/Ch6_q_Command";
mkdir(outdir)
addpath(outdir)

% states at trim condition:
trim_s = [xu(8), xu(11), xu(14)]'; % computed during trim_lin.m

% NOTE! All of the items below are done for 2 systems
% A: the pole placed system w/out servo dynamics (TF: q_cmd)
% B: the pole placed system with servo dynamics added in the loop (TF:
%    q_cmd_servo. However, pole placement way done assuming no servo, such
%    that adding it back-in slightly distorts the achieved frequency and
%    damping
% 
% To obtain the slower reponse presented in the last line of table 7,
% uncomment line 55 and run again.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Place Polse and Zeros! %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = tf('s');  % obligatory...


%% Poles placed -- no servo dynamics
% the PlacePoles.m script provides a pole placed SS system and a transfer
% function that also has correct zeros by prefiltering

% desired pole
w_n = 0.03*xu(7)*0.3048; % natural freq
% w_n = 0.7 * 0.03*xu(7)*0.3048; % natural freq, but only 70%
z   = 0.5; % damping ratio
recip_Ttheta2_target = 0.75*w_n; % reciprocal of the desired zero

% place those o's and x's
run PlacePoles.m

% alias:
q_cmd = H_pp_filt_q;
[~, zeta, ~] = damp(q_cmd);


%% Pole placed -- servo dynanamics added back in

% servo TF
H_servo = 22.2/(s+22.2);

% linearize simulink model with correct implementation of servos
sim_servo = linmod("q_loop_servo");
sim_servo_ss = ss(sim_servo.a, sim_servo.b, sim_servo.c, sim_servo.d);

q_cmd_servo = zpk(minreal( tf(sim_servo_ss(2)) )); % 2nd output: q
[~, zeta_servo, ~] = damp(q_cmd_servo);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate All Handling Criteria %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we calculate CAP as well as Gibson 1 and 2 and verify their results
% also, vertical gust response is verified
g = 9.80655; % gravity
V0 = xu(7) * 0.3048; % trimmed speed in m/s

%% CAP (Control Anticipation Parameters)

% get characteristics and current zero for non-servo and servo systems
[Omega_long, Zeta_long, P_long] = damp(q_cmd);
T_theta2 = -1/q_cmd.Z{1};

[Omega_long_servo, Zeta_long_servo, P_long_servo] = damp(q_cmd_servo);
T_theta2_servo = -1/q_cmd_servo.Z{1};

% calculate CAP as Equation 6.3 in the Assignment
CAP       = (g * (Omega_long(1))^2 * T_theta2 )             / V0;
CAP_servo = (g * (Omega_long_servo(1))^2 * T_theta2_servo ) / V0;


% Checks and Verification, at least for the no-servo case:
% 
% warn, if we exceed the bounds given in Figure 6.1 - Cat B - Level 1
if (CAP > 3.6) || (CAP < 0.085) || (Zeta_long(1) < 0.3) || ...
    (Zeta_long(1) > 2 )
    warning('CAP criterion not met')
end

% "Verification" :) according to Task 6.3.6.
CAP_veri = Omega_long(1)^2 / ( (V0/g) * (1/T_theta2) );


%% gust loading

% define gust as task 6.3.4.
v_z_gust = 4.572; % m/s
a_ind = atan(v_z_gust / V0); % radians --> induced Delta AOA

% max elevator deflection due to initial Delta AOA
el_max_Ka = Ka * a_ind;

% invoke plotting subroutine
run plot_gust_response.m

% export figure to results folder
set(h, 'Color', 'w');
export_fig Outputs/Ch6_q_Command/gust_response.png -painters


%% Gibson 1 -- Dropback (DB)
% basic idea: 
% give a pulse input of the stick (neutral-back-neutral) and plot responses
% for q (rate) and theta (attitude). Then calculate the relevant quantities
% from those plots

% in degrees after all...
q_cmd   = 180/pi*q_cmd;
q_cmd_servo = 180/pi*q_cmd_servo;

% invoke plotting subroutine
run plot_pulse_response.m

% export figure to results folder
set(step_up_down, 'Color', 'w');
export_fig Outputs/Ch6_q_Command/step_up_down.png -painters


%% Gibson II (PIO)
% we shall see that it was necessary to get the elevator deflection back
% into the model to make sure that we actually get any -180^ crossings...

% no-servo model:
q_cmd_theta = q_cmd * 1/s; % integrate once for theta
[slope, frequency_cross] = phase_rate_check(-q_cmd_theta);

% proper servo in the loop
q_cmd_servo_theta = minreal(q_cmd_servo * 1/s); % integrate once
[slope_servo,frequency_cross_servo] = phase_rate_check(-q_cmd_servo_theta);

% to prove that it makes no sense to "post-convolve" the elevator servo
% dynamics back into the model:
q_cmd_convservo_theta = (q_cmd * H_servo) * 1/s; % integrate once for theta
[slope_convservo, frequency_cross_convservo] =...
    phase_rate_check(-q_cmd_convservo_theta);

% invoke plotting subroutine
run plot_bode.m

% export figure to results folder
set(bodes, 'Color', 'w');
export_fig Outputs/Ch6_q_Command/bode_plots.png -painters



%%%%%%%%%%%%%%%%%%
%% Output Table %%
%%%%%%%%%%%%%%%%%%

% names of the parameters
Parameters = ["CAP", "zeta", ...
                     "Gibson 1 - qm/qs", "Gibson 1 - DB/qs", ...
                     "Gibson 2 - XOver", "Gibson 2 - Phase Rate",...
                     "Gust max el"];

% Names of the two cases: no-servo and servo in loop
models = ["NoServo", "ServoInLoop"];

% make table
q_ctl_table = table(...
    [CAP, zeta(1), q_ratio, DB_over_qss, frequency_cross, slope, d_e_max]',...
    [CAP_servo, zeta_servo(1), q_ratio_servo, DB_over_qss_servo,...
     frequency_cross_servo, slope_servo, d_e_max_servo]',...
     'VariableNames', models,...
     'RowNames', Parameters...
     );

% output to csv
writetable(q_ctl_table, 'Outputs/Ch6_q_Command/Handling_char.csv',...
                        'WriteRowNames', true)

disp("Ch6_q_Command: Handling Characteristics after Pole/Zero placment")
q_ctl_table

% latex table strings:
% q_ctl_table{5:6, 1} = -1;
% string(q_ctl_table{:, :}').join("$ & $")



%% To obtain the last line in Table xx; re-run this file but uncomment line 54




