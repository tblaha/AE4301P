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
B_c = ones(2, 1);
C_c = C;
D_c = D;

sys_c = ss(A_c, B_c, C_c, D_c);






