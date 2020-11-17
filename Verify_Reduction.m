% This file verifies that the reduction of the system dynamics is done
% correctly with respect to the actuator dynamics.

% therefore, the elevator-to-pitch-angle transfer function of the full
% logitudinal LoFi model is compared to the convolution of a low-pass
% actuator model convoluted with a 5 DoF model (7 states - 2 actuator
% states)


red = load("./fc_files/SS_Std_LoFi_5DoF");
nonred = load("./fc_files/SS_Std_LoFi_full");

s = tf('s');

%% elevator to theta of the full model

H_full = tf(nonred.SS_long);
H_full_elref_2_theta = H_full(2, 2)


%% adding actuator back into reduced model

% el 2 theta for the reduced model
H_red=tf(red.SS_long);
H_red_el_2_theta = H_red(4, 2);

% first order servo dynamics
H_el_servo = 20.2 / (s + 20.2);

% transfer function with added actuatordyamics
H_red_el_2_theta_act = H_el_servo * H_red_el_2_theta



%% compare

step(H_full_elref_2_theta - H_red_el_2_theta_act)

