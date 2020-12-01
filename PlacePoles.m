%clear
load("fc_files/SS_Std_LoFi_2DoF.mat")

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
T_theta_2_target = 1/(0.75*w_n);

a = -w_n;
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
B_c = [0;1];
C_c = C;
D_c = D;


sys_c = ss(A_c, B_c, C_c, D_c);

s = tf('s');
H_c = tf(sys_c);
H_servo = 22.2/(s+22.2);
H_c_q= H_c(2,1)*H_servo;
H_c_theta = minreal(H_c_q*(1/s));

bode(H_c_theta)
[slope,frequency_cross] = phase_rate_check(H_c_theta)




