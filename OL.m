load('SS_Std_LoFi_4DoF.mat');


%figure(1)
map_long = pzmap(SS_long);

%figure(2)
map_lat = pzmap(SS_lat);

[nat_freq_long,damping_long,poles_long] = damp(SS_long);
[nat_freq_lat,damping_lat,poles_lat] = damp(SS_lat);
T_half_long = log(0.5)./real(poles_long);
T_half_lat = log(0.5)./real(poles_lat);
time_cons_long = -1./real(poles_long);
time_cons_lat = -1./real(poles_lat);

%Longitudinal
%phugoid, pitch rate, step input
SS_pitchrate = SS_long(4,2);
plot_long_pitchrate = figure(1);
step(SS_pitchrate);
mkdir 'OL_plot_files'  
filename = strcat("OL_plot_files/", 'Pitchrate_phugoid_long');
saveas(plot_long_pitchrate, filename, 'epsc');

%short period, pitch rate, step input
SS_pitchrate = SS_long(4,2);
plot_long_pitchrate = figure(2);
step(SS_pitchrate,10);
mkdir 'OL_plot_files'  
filename = strcat("OL_plot_files/", 'Pitchrate_sp_long');
saveas(plot_long_pitchrate, filename, 'epsc');

%Lateral
%dutch roll, rudder input, yaw rate
SS_yawrate = SS_lat(4,3);
plot_lat_yawrate = figure(3);
impulse(SS_yawrate,15);
mkdir 'OL_plot_files'  
filename = strcat("OL_plot_files/", 'Yawrate_dr_lat');
saveas(plot_lat_yawrate, filename, 'epsc');

%spiral, aileron input, roll angle
SS_rollangle = SS_lat(2,2);
plot_lat_rollrate = figure(4)
impulse(SS_rollangle)
mkdir 'OL_plot_files'  
filename = strcat("OL_plot_files/", 'rollrate_spiral_lat');
saveas(plot_lat_rollangle, filename, 'epsc');

%aperiodic roll, aileron input, roll rate
SS_rollrate = SS_lat(3,2);
plot_lat_rollrate = figure(5)
step(SS_rollrate,10)
mkdir 'OL_plot_files'  
filename = strcat("OL_plot_files/", 'rollrate_aper_lat');
saveas(plot_lat_rollrate, filename, 'epsc');


