% clear
% load("fc_files/SS_Std_LoFi_2DoF.mat")

%%

A = SS_long.A;
B = SS_long.B(:, 2); % only elevator feedback
C = SS_long.C;
D = SS_long.D(:, 2); % only elevator feedback

T = [B, A*B];

A_tilde = T \ A * T;
B_tilde = T \ B;
C_tilde = C * T;

w_n = 0.03*xu(7)*0.3048;
z   = 0.5;

a = -z*w_n;
b = w_n*sqrt(1-z^2);
target = a + b*1i;

Ka_tilde = 2*a - A_tilde(2, 2);
Kq_tilde = -A_tilde(1, 2) + Ka_tilde * (A_tilde(2, 2) - a) + (a^2 - b^2 - A_tilde(2, 2)*a);

F_tilde = [Ka_tilde, Kq_tilde];
F = F_tilde * inv(T);

Ka = F(1);
Kq = F(2);


%%

A_c = (A+B*F);
% B_c = B*F*[0; 1]; % q-command mdl
B_c = B; % convolution mdl
C_c = eye(2);
D_c = D;


sys_c = ss(A_c, B_c, C_c, D_c);

s = tf('s');
H_c = tf(sys_c);
H_servo = 22.2/(s+22.2);
H_c_q = minreal(H_c(2,1));
H_c_theta = minreal(H_c_q*1/s);

% bode(H_c_theta)
[slope,frequency_cross] = phase_rate_check(H_c_theta);


%%

recip_Ttheta2_target = 0.75*w_n;
% recip_Ttheta2_actual = 1 / (H_c_q.num{1}(3) /H_c_q.num{1}(4)):
H_c_q = zpk(H_c_q);
recip_Ttheta2_actual = -H_c_q.Z{1}(1);  % seems more robust

% design Lead-Lag (actually just lag, if you look at the poles/zeros)
LL_filt = recip_Ttheta2_actual/recip_Ttheta2_target *...
    ((s + recip_Ttheta2_target) / (s + recip_Ttheta2_actual));

% premultiply with the pole-placed H_c_q
final_H_c_q = minreal(LL_filt * H_c_q);

% even though the H_c_q is pole-placed, there is still not guarantee that
% an input is tracked (after, what _is_ the input to a pole placed system?)
% 
% for now, just scale it:
%H_c_q
%scaled_H_c_q = final_H_c_q / evalfr(final_H_c_q, 0)

% step plot
% close("all")
% figure("name", "Compare Pre-Filter", "Visible", "off")
% hold on
% step(-H_c_q, 6)
% step(-final_H_c_q, 6)
% hold off
% 
% grid on
% legend(["No Prefilter", "Lead Prefilter"])



%% compare to simulink model
% modelname = "q_loop_Convolution";
% modelname = "q_loop_qcmd";

% sys = linmod(modelname); ss_sys_q = ss(sys.a, sys.b, sys.c, sys.d); minreal(zpk(tf(ss_sys_q)))*180/pi
% final_H_c_q

