clear all 
load('SS_Std_LoFi_2DoF.mat')

g = 9.80655
%char_table = mchar(SS_long, SS_lat)
%zeta_sp = char_table.DampingRatio('Short Period')
%W_sp = char_table.NaturalFrequency('Short Period')

[Omega_long, Zeta_long, P_long] = damp(SS_long); 

H_red = tf(SS_long);
H_elref_2_q = H_red(2, 2)

T_theta2 = H_elref_2_q.num{1}(2) /H_elref_2_q.num{1}(3)  

CAP = (g * (Omega_long(1))^2 * T_theta2 ) / (xu(7) * 0.3048)

if (CAP > 3.6) || (CAP < 0.085) || (Zeta_long(1) < 0.3) || ...
    (Zeta_long(1) > 2 )

warning('CAP criterion not met')
end 

%% 
s = tf('s')
k = - 0.01 - 3/s
H_cl = minreal((k * H_elref_2_q) / (1 + (k * H_elref_2_q)))
Step = stepinfo(H_cl)
q_ratio = (Step.Overshoot /100) + 1

q_steady_state = evalfr(H_cl,0)

dt = 0.01
t = 0:dt:20;

H_cl_theta = minreal(H_cl/s)



u = @(t) heaviside(t) - heaviside(t-10);
y = lsim(H_cl,u(t),t);

theta_u = cumsum(y*dt);
input_u = cumsum(u(t)*dt);

figure(1)
hold on
plot(t, theta_u)
plot(t, input_u)

DB = (interp1(t, theta_u, 10)) - theta_u(end)


if (q_ratio <= 1) || (q_ratio > 3) || (q_ratio + ((3.5/0.3) * ...
        DB) / q_steady_state > 3.5)
warning('No Dropback')

end

figure(2)
H_ol =  H_cl_theta 
bode(H_ol)




