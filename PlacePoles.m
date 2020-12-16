% Take 2DoF SS_long, as produced by trim_lin.m, and place poles to what
% task 6.3.3. suggests.

%% Desired pole and zero locations

w_n = 0.03*xu(7)*0.3048; % natural freq
z   = 0.5; % damping ratio
recip_Ttheta2_target = 0.75*w_n; % reciprocal of the desired zero

% express pole as complex pole:
a = -z*w_n;           % Re part 
b = w_n*sqrt(1-z^2);  % Im part (only the square of this will be 
                      % required later, so sign doesn't matter)

target = a + b*1i;    % complex pole


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Computation of gains %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get system in convenient form (use only the elevator input)

A = SS_long.A;
B = SS_long.B(:, 2); % only elevator feedback
C = SS_long.C;
D = SS_long.D(:, 2); % only elevator feedback

% Transform the system to Kalman Decomposition (B = [1 0]')
T = [B, A*B]; % controllability matrix used as transformation matrix

A_tilde = T \ A * T;
B_tilde = T \ B;
C_tilde = C * T;

 
%% Pole placement in Kalman Decomposition Form
% see report for derivation of those equations

% note: a and q are not actually related to  the states alpha and q, so the 
%       subscripts here are a bit misleading 
Ka_tilde = 2*a - A_tilde(2, 2);
Kq_tilde = -A_tilde(1, 2) + Ka_tilde * (A_tilde(2, 2) - a)...
           + (a^2 - b^2 - A_tilde(2, 2)*a);

% State feedback matrix in Kalman Decomposition Form
F_tilde = [Ka_tilde, Kq_tilde];


%% Transform back to [alpha, q] system

F = F_tilde / T;

% get the _actual_ gains relating to states [alpha, q]
Ka = F(1); 
Kq = F(2);


%%%%%%%%%%%%%%%%%%%%%%%
%% Set up new system %%
%%%%%%%%%%%%%%%%%%%%%%%

% subscript pp --> pole-placed
A_pp = (A+B*F); % note, that the negatives (if required) are in F
B_pp = B; % same input (direct to elevator)
C_pp = eye(2); % let's stick with radians!
D_pp = D; % zero anyway

% set up the matlab state space object
sys_pp = ss(A_pp, B_pp, C_pp, D_pp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prefiltering to place zero %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% get transfer function from elevator to q/theta
s = tf('s');
H_pp = tf(sys_pp);

% for q: just pick 2nd output
H_pp_q = minreal(H_pp(2));

% for theta: integrate q once
H_pp_theta = minreal(H_pp_q*1/s);


%% Design Lead or Lag filter with unity gain at 0Hz

% find actual ("present") value of the zero in the TF
H_pp_q = zpk(H_pp_q);
recip_Ttheta2_actual = -H_pp_q.Z{1}(1); % mind definition of Tt2 vs zpk

% design Lead-Lag (actually just lag, if you look at the poles/zeros)
LL_filt = recip_Ttheta2_actual/recip_Ttheta2_target *...
    ((s + recip_Ttheta2_target) / (s + recip_Ttheta2_actual));

% convolve with the pole-placed H_c_q
H_pp_filt_q = minreal(LL_filt * H_pp_q);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Verifiation: Compare to Simulink Model %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% linearize; state-spaceify; get transfer function
sim_sys = linmod("q_loop");
ss_sim_sys_q = ss(sim_sys.a, sim_sys.b, sim_sys.c, sim_sys.d);
ss_sim_sys_el2q_tf = minreal(zpk(tf(ss_sim_sys_q(2))));

% compare tf's from the simulink to one calulated above
disp("PlacePoles.m: Verify same implementation PLacePoles.m and q_loop.mdl...")
ss_sim_sys_el2q_tf
H_pp_filt_q

