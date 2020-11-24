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

    