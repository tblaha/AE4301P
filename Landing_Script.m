clear
close("all")

%%

% reduction to 5 DoFs: 
% Longitudinal States --> h, u, \alpha, \theta, q
load("SS_GS_LoFi_5DoF")

con_trim = [xu(3), xu(7), 180/pi*xu(8), 180/pi*xu(5), 180/pi*xu(11)]';
con_init = [0, 0, 0, 0, 0]';

trim_thrust = xu(13);
trim_elevator = xu(14);
airport_elevation = 3000;

init_x_pos = - ( 10*300 + 2000 / (tand(3)) );


%% design phugoid 

% el2alpha
G_el2a = minreal(tf(SS_long(2, 2)));

% % for alpha-feedback, choose K_alpha = 0.017391
% G_alpha_closed = minreal(0.01739*G_el2a / (1 + 0.01739*G_el2a));


% for u-feedback, choose K = 0.0079068

