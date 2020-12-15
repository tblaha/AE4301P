clear all 
load('SS_Std_LoFi_2DoF.mat');

%% place poles

run PlacePoles.m


%% evaluate

g = 9.80655;
%char_table = mchar(SS_long, SS_lat)
%zeta_sp = char_table.DampingRatio('Short Period')
%W_sp = char_table.NaturalFrequency('Short Period')

q_cmd = final_H_c_q;

[Omega_long, Zeta_long, P_long] = damp(q_cmd);

% H_red = tf(SS_long);
% H_elref_2_q = H_red(2, 2);
% 
% T_theta2 = H_elref_2_q.num{1}(2) /H_elref_2_q.num{1}(3);

% calculate T_theta2 using the zero
T_theta2 = -1/q_cmd.Z{1};

CAP = (g * (Omega_long(1))^2 * T_theta2 ) / (xu(7) * 0.3048);

if (CAP > 3.6) || (CAP < 0.085) || (Zeta_long(1) < 0.3) || ...
    (Zeta_long(1) > 2 )

warning('CAP criterion not met')
end


% "Verification" :)
CAP_veri = Omega_long(1)^2 / ( (xu(7) * 0.3048/g) * (1/T_theta2) );


%% DB "verification"

DB_over_qss = T_theta2 - ( (2 * Zeta_long(1)) / (Omega_long(1)) );




%% gust loading

v_z_gust = 4.572; % m/s
a_ind = atan(v_z_gust / (xu(7) * 0.3048));

el_max_Ka = Ka * a_ind;

sys_sim=linmod('q_loop_Convolution');
sim_ss = ss(sys_sim.a, sys_sim.b, sys_sim.c, sys_sim.d);


% states of sim_ss:   [alpha, q, some-internal-LLfilt-state-whatever]
% initial conditions: [a_ind, 0, 0]
% outputs of sim_ss:  [alpha [rad], q [rad/s], d_e [deg]]
% input of sim_ss: (d_e_pilot [deg])

% states at trim condition:
trim_s = [xu(8), xu(11), xu(14)]';

lsim(sim_ss, zeros(1, 1001), linspace(0, 2, 1001), [a_ind, 0, 0]')
% 
% 
% %% 
% 
% s = tf('s');
% k = - 0.01 - 3/s; % PI controller?
% 
% H_cl = minreal((k * q_cmd) / (1 + (k * q_cmd)))
% 
% Step = stepinfo(H_cl)
% q_ratio = (Step.Overshoot /100) + 1
% 
% q_steady_state = evalfr(H_cl,0)
% 
% dt = 0.01
% t = 0:dt:20;
% 
% H_cl_theta = minreal(H_cl/s)
% 
% 
% 
% u = @(t) heaviside(t) - heaviside(t-10);
% y = lsim(H_cl,u(t),t);
% 
% theta_u = cumsum(y*dt);
% input_u = cumsum(u(t)*dt);
% 
% figure(1)
% hold on
% plot(t, theta_u)
% plot(t, input_u)
% 
% DB = (interp1(t, theta_u, 10)) - theta_u(end)
% 
% 
% if (q_ratio <= 1) || (q_ratio > 3) || (q_ratio + ((3.5/0.3) * ...
%         DB) / q_steady_state > 3.5)
% warning('No Dropback')
% 
% end
% 
% figure(2)
% H_ol =  H_cl_theta 
% bode(H_ol)
% 
% 
% 

