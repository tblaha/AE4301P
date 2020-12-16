clear
% close("all")

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
fprintf("q_ctl: Checking if SS matrices exist...")
if exist("fc_files/SS_Std_LoFi_2DoF.mat", 'file') > 0
    fprintf("OK\n")
    
    load('fc_files/SS_Std_LoFi_2DoF.mat');
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run trim_lin.m
    
    fprintf("q_ctl: Importing SS matrix...")
    
    load('fc_files/SS_Std_LoFi_2DoF.mat');
    fprintf("OK, recovered\n")
end

% make folder for the plots; if it doesn't exist yet
mkdir q_ctl_outputs

% states at trim condition:
trim_s = [xu(8), xu(11), xu(14)]'; % computed during trim_lin.m

% Visible of plots
show_plots = 'on';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Place Polse and Zeros! %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = tf('s');  % obligatory...

%% Poles placed -- no servo dynamics
% the PlacePoles.m script provides a pole placed SS system and a transfer
% function that also has correct zeros by prefiltering
run PlacePoles.m

% alias:
q_cmd = H_pp_filt_q;
[~, zeta, ~] = damp(q_cmd);


%% Pole placed (based on no servo) -- servo dynanamics added back in

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


% we want to know the response to this as well and we decide to model the
% gust as an initial condition and then (pilot-)input=0
% 
% long story short: to simulate starting with these initial conditions, the
% TFs are of no use, we need SS models. Also the state space model from
% PlacePoles.m is of no use as it doesn't yet have the prefiltering
%
% so: get a nice SS model from simulink
sys_sim = linmod('q_loop'); % no servo dynamics, 
                            % see PlacePoles.m for verification
sim_ss  = ss(sys_sim.a, sys_sim.b, sys_sim.c, sys_sim.d);

% states of sys_sim:   [alpha, q, some-internal-LLfilt-state-whatever]
% initial conditions: [a_ind, 0, 0]
% outputs of sys_sim:  [alpha [rad], q [rad/s], d_e [deg]]
% input of sys_sim: (d_e_pilot [deg])

% lsim both the simulink-derived SS models for both servo and no-servo
% starting from the gust, modelled as initial condition
N = 1001;
u = zeros(1, N);       % 0 input
t = linspace(0, 2, N); % linear time vector
[y,t,x]  = lsim(sim_ss      , u, t, [a_ind, 0, 0]');
[ys,t,x] = lsim(sim_servo_ss, u, t, [a_ind, 0, 0, 0]'); % we have one more 
                                                        % state because of 
                                                        % an internal state
                                                        % within the pre-
                                                        % filter

% get maximum elevator deflections
[~, i] = max(abs(y(:, 3) + trim_s(3))); % biggest absolute, including trim
d_e_max = y(i, 3) + trim_s(3);
[~, i] = max(abs(ys(:, 3) + trim_s(3))); % biggest absolute, including trim
d_e_max_servo = ys(i, 3) + trim_s(3);

% plot the responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% together in one plot and DO NOT FORGET TO ADD TRIM CONDITIONS 
h = figure("Name", "Gust Response",...
           "Position", [500, 200, 700, 700],...
           "Visible", show_plots);

% alpha plot:
subplot(311)
hold on
    plot(t, y(:, 1)+trim_s(1) , "LineWidth", 2)
    plot(t, ys(:, 1)+trim_s(1), "LineWidth", 2, "LineStyle", "--")
hold off
legend(["No Servo", "Servo in Loop"], "FontSize", 12)
grid on
ylabel("\alpha [rad]", "Fontsize", 14)
ax = gca;
ax.Title.String = "Gust Response of system. u=0, \Delta\alpha_{gust}=+"...
                  +string(round(a_ind, 3))+" rad";
ax.Title.FontSize = 14;

% q plot:
subplot(312)
hold on
    plot(t, y(:, 2)+trim_s(2), "LineWidth", 2)
    plot(t, ys(:, 2)+trim_s(2), "LineWidth", 2, "LineStyle", "--")
hold off
legend(["No Servo", "Servo in Loop"], "FontSize", 12, "Location", "SouthEast")
grid on
ylabel("q [rad/s]", "Fontsize", 14)

% d_e (elevator deflection) plot
subplot(313)
hold on
    plot(t, y(:, 3)+trim_s(3), "LineWidth", 2)
    plot(t, ys(:, 3)+trim_s(3), "LineWidth", 2, "LineStyle", "--")
hold off
legend(["No Servo", "Servo in Loop"], "FontSize", 12)
grid on
ylabel("Elevator \delta_e [\circ]", "Fontsize", 14)

xlabel("Time t [sec]", "FontSize", 14)


% export figure to results folder
set(h, 'Color', 'w');
export_fig q_ctl_outputs/gust_response.eps -painters



%% Gibson 1 -- Dropback (DB)
% basic idea: 
% give a pulse input of the stick (neutral-back-neutral) and plot responses
% for q (rate) and theta (attitude). Then calculate the relevant quantities
% from those plots

% in degrees after all...
q_cmd   = 180/pi*q_cmd;
q_cmd_servo = 180/pi*q_cmd_servo;

% get step respose information
Step    = stepinfo(q_cmd);
q_ratio = (Step.Overshoot / 100) + 1;
q_steady_state = evalfr(q_cmd, 0); % final value theorem

Step  = stepinfo(q_cmd_servo);
q_ratio_servo = (Step.Overshoot / 100) + 1;
q_steady_state_servo = evalfr(q_cmd_servo, 0); % final value theorem


% Calculate responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmax = 3;
dt = 0.001;
t = 0:dt:tmax; % time vector

% input function (step up and back down)
u  = @(t) heaviside(t - tmax/6) - heaviside(t - 4*tmax/6);

% lsim the responses for no servo and servo (subscript s)
y  = lsim(q_cmd, u(t), t);
ys = lsim(q_cmd_servo, u(t), t);

q_u = y;
theta_u = cumsum(y*dt); % lazy integration for theta
qs_u = ys;
thetas_u = cumsum(ys*dt);

% calculate drop back at 4*tmax/6 wrt to steady state
DB = (interp1(t, theta_u, 4*tmax/6)) - theta_u(end);
DB_servo = (interp1(t, thetas_u, 4*tmax/6)) - thetas_u(end);

% get ratio
DB_over_qss = DB/q_steady_state;
DB_over_qss_servo = DB_servo/q_steady_state_servo;

% again: "verify" at least the no-servo case using the equation from 6.3.6.
DB_over_qss_veri = T_theta2 - ( (2 * Zeta_long(1)) / (Omega_long(1)) );

disp("q_ctl: Verify Gibson 1 (DB)...")
DB_over_qss
DB_over_qss_veri


% plot the responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% scale the inputs for nicer looking plots
input_u = u(t) * q_steady_state;
input_int_u = cumsum(u(t)*dt) * q_steady_state;

% figure handle
step_up_down = figure("Name", "Step up-down",...
                      "Position", [700 200 600 600],...
                       "Visible", show_plots);

% q plot
subplot(211)
hold on
    plot(t, -q_u, "LineWidth", 1.5, "LineStyle", "-", "DisplayName", "No Servo")
    plot(t, -qs_u, "LineWidth", 1.5, "LineStyle", "--", "DisplayName", "Servo in Loop")
    plot(t, -input_u, "LineWidth", 1.5, "LineStyle", "-.", "DisplayName", "Reference")
hold off
legend("Location", "NorthEast", "FontSize", 11)
ylabel("Pitch Rate q [rad/s]")
title("Pulse Reponse of q-system", "FontSize", 16)
grid()

% theta plot
subplot(212)
hold on
    plot(t, -theta_u, "LineWidth", 1.5, "LineStyle", "-", "DisplayName", "No Servo")
    plot(t, -thetas_u, "LineWidth", 1.5, "LineStyle", "--", "DisplayName", "Servo in Loop")
    plot(t, -input_int_u, "LineWidth", 1.5, "LineStyle", "-.", "DisplayName", "Reference")
hold off
legend("Location", "NorthWest", "FontSize", 11)
ylabel("Pitch Angle \theta [rad]")
xlabel("Time t [sec]")
grid()


% export figure to results folder
set(step_up_down, 'Color', 'w');
export_fig q_ctl_outputs/step_up_down.eps -painters



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


% plot the above 
bodes = figure("Name", "BodePlots",...
               "Position", [500, 200, 600, 400],...
               "Visible", show_plots);
hold on
    % no servo
    b_noservo = bodeplot(-q_cmd_theta);
    setoptions(b_noservo, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    grid on
   
    % correct servo in loop
    b_conv = bodeplot(-q_cmd_servo_theta);
    setoptions(b_conv, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "--";
    grid on

    % bad servo outside loop
    b_sim = bodeplot(-q_cmd_convservo_theta);
    setoptions(b_sim, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "-.";
hold off

ax = gca;
ax.Children(1).Children.LineWidth = 2;
bodes.Children(3).XLabel.FontSize = 14;
bodes.Children(3).YLabel.FontSize = 14;
grid on

title("Closed System Phase Plot -- PIO", "FontSize", 15)

legend(["No Servo", ...
        "Servo in Loop",...
        "Servo in Front"], "Location", "NorthEast", "FontSize", 12)


% export figure to results folder
set(bodes, 'Color', 'w');
export_fig q_ctl_outputs/bode_plots.eps -painters




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
writetable(q_ctl_table, 'q_ctl_outputs/Handling_char.csv',...
                        'WriteRowNames', true)


q_ctl_table

% latex table strings:
% q_ctl_table{5:6, 1} = -1;
% string(q_ctl_table{:, :}').join("$ & $")

