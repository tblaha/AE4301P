%================================================
%     Matlab Script File used to linearize the 
%     non-linear F-16 model. The program will 
%     Extract the longitudal and lateral 
%     direction matrices.  These system matrices 
%     will be used to create pole-zero mapping
%     and the bode plots of each to each control
%     input.
% Author: Richard S. Russell
% 
%================================================
%clear;

addpath ./ExternalModules/F16Sim/obsmutoolsfornewermatlabversions -END % required for some new MATLAB versions

global fi_flag_Simulink

if (exist("an_output", 'var') == 0)
    an_output = false;
end

if an_output
    SL_lin_block = 'LIN_F16Block_an';
    disp("FindF16Dynamics_noninteractive.m: using Modified LIN_F16Block_an.mdl for linearization")
    long_CD_rows = [21 23 25 26 29 37];
else
    SL_lin_block = 'LIN_F16Block';
    % disp("FindF16Dynamics_noninteractive.m: using Standard LIN_F16Block.mdl for linearization")
    long_CD_rows = [21 23 25 26 29];
end

newline = sprintf('\n');

%% Trim aircraft to desired altitude and velocity
%%
altitude = fc_setting.h;
velocity = fc_setting.v;

%% Initial guess for trim
%%
thrust = 5000;          % thrust, lbs
elevator = -0.09;       % elevator, degrees
alpha = 8.49;              % AOA, degrees
rudder = -0.01;             % rudder angle, degrees
aileron = 0.01;            % aileron, degrees

%% Find trim for Hifi model at desired altitude and velocity
%%
% disp('Trimming Model:');
fi_flag_Simulink = fc_setting.Fiflag;
[trim_state, trim_thrust, trim_control, dLEF, xu, cost] = trim_F16_noninteractive(thrust, elevator, alpha, aileron, rudder, velocity, altitude);

%% Find the state space model for the hifi model at the desired alt and vel.
%%
trim_state_lin = trim_state; trim_thrust_lin = trim_thrust; trim_control_lin = trim_control;
[A,B,C,D] = linmod(SL_lin_block, [trim_state_lin; trim_thrust_lin; trim_control_lin(1); trim_control_lin(2); trim_control_lin(3); ...
		dLEF; -trim_state_lin(8)*180/pi], [trim_thrust_lin; trim_control_lin(1); trim_control_lin(2); trim_control_lin(3)]);

%% Make state space model
%%
SS = ss(A,B,C,D);


%% Make MATLAB matrix
%%
mat = [A B; C D];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Longitudal Directional %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select the components that make up the longitude A matrix
%%
A_longitude = mat([3 5 7 8 11 13 14], [3 5 7 8 11 13 14]);

%% Select the components that make up the longitude B matrix
%%
B_longitude = mat([3 5 7 8 11 13 14], [19 20]);

%% Select the components that make up the longitude C matrix
%%

C_longitude = mat(long_CD_rows, [3 5 7 8 11 13 14]);

%% Select the components that make up the longitude D matrix
%%
D_longitude = mat(long_CD_rows, [19 20]);

SS_long = ss(A_longitude, B_longitude, C_longitude, D_longitude);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lateral Directional %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select the components that make up the lateral A matrix
%%
A_lateral = mat([4 6 7 9 10 12 13 15 16], [4 6 7 9 10 12 13 15 16]);

%% Select the components that make up the lateral B matrix
%%
B_lateral = mat([4 6 7 9 10 12 13 15 16], [19 21 22]);

%% Select the components that make up the lateral C matrix
%%
C_lateral = mat([22 24 25 27 28 30], [4 6 7 9 10 12 13 15 16]);

%% Select the components that make up the lateral D matrix
%%
D_lateral = mat([22 24 25 27 28 30], [19 21 22]);

SS_lat = ss(A_lateral, B_lateral, C_lateral, D_lateral);

%% Make longitudal direction SYSTEM matrix
%%
%sys_long = pck(A_longitude, B_longitude, C_longitude, D_longitude);

%% Make lateral direction SYSTEM matrix and Find poles for hifi
%%
%sys_lat = pck(A_lateral, B_lateral, C_lateral, D_lateral);
% 
% long_poles = spoles(sys_long);
% lat_poles = spoles(sys_lat);
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Display results
% 
% 
% clc;
% 
% disp(sprintf('Altitude: %.3f ft.', altitude));
% disp(sprintf('Velocity: %.3f ft/s\n\n', velocity));
% 
% disp('For HIFI Model:  ');
% disp('Longitudal Direction:  ');
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_longitude_hi(:,1) )
%     mprintf([ A_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_longitude_hi(:,1) )
%     mprintf([ B_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_longitude_hi(:,1) )
%     mprintf([ C_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_longitude_hi(:,1) )
%     mprintf([ D_longitude_hi(i,:) ],'  %.3e ')
% end %for
% 
% rifd(long_poles_hi)
% 
% disp(newline);
% 
% disp('Lateral Direaction:  ');
% 
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_lateral_hi(:,1) )
%     mprintf([ A_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_lateral_hi(:,1) )
%     mprintf([ B_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_lateral_hi(:,1) )
%     mprintf([ C_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_lateral_hi(:,1) )
%     mprintf([ D_lateral_hi(i,:) ],'  %.3e ')
% end %for
% 
% rifd(lat_poles_hi)
% 
% disp(newline);
% disp(newline);
% disp('For LOFI Model:  ');
% disp('Longitudal Direction:  ');
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_longitude_lo(:,1) )
%     mprintf([ A_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_longitude_lo(:,1) )
%     mprintf([ B_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_longitude_lo(:,1) )
%     mprintf([ C_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_longitude_lo(:,1) )
%     mprintf([ D_longitude_lo(i,:) ],'  %.3e ')
% end %for
% 
% % Display the real, imaginary, frequency (magnitude) and damping ratios
% rifd(long_poles_lo)
% 
% disp(newline);
% 
% disp('Lateral Direaction:  ');
% 
% disp(newline);
% 
% disp('A =')
% for i=1:length( A_lateral_lo(:,1) )
%     mprintf([ A_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('B =')
% for i=1:length( B_lateral_lo(:,1) )
%     mprintf([ B_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('C =')
% for i=1:length( C_lateral_lo(:,1) )
%     mprintf([ C_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% disp('D =')
% for i=1:length( D_lateral_lo(:,1) )
%     mprintf([ D_lateral_lo(i,:) ],'  %.3e ')
% end %for
% 
% % Display the real, imaginary, frequency (magnitude) and damping ratios
% rifd(lat_poles_lo)
% 
% %% All Poles
% figure(1); 
% pzmap(SS_hi, 'r', SS_lo, 'b');
% title_string = sprintf('Altitude = %.2f ft Velocity = %.2f ft/s\nAll Poles\n Blue = lofi Red = hifi.', altitude, velocity);
% title(title_string);
% sgrid;
% 
% %% Long. Poles
% %%
% figure(2); 
% pzmap(SS_long_hi, 'r', SS_long_lo, 'b');
% title_string = sprintf('Altitude = %.2f ft Velocity = %.2f ft/s\nLongitudal Directional Poles\n Blue = lofi Red = hifi.', altitude, velocity);
% title(title_string);
% sgrid;
% 
% %% Lat. Poles
% %%
% figure(3); 
% pzmap(SS_lat_hi, 'r', SS_lat_lo, 'b');
% title_string = sprintf('Altitude = %.2f ft Velocity = %.2f ft/s\nLateral Directional Poles\n Blue = lofi Red = hifi.', altitude, velocity);
% title(title_string);
% sgrid;
% 
% % Create Bode Plots
% 
% omega = logspace(-2,2,100);
% 
% sysg_lat_hi = frsp(sys_lat_hi,omega);
% sysg_lat_lo = frsp(sys_lat_lo,omega);
% 
% sysg_long_hi = frsp(sys_long_hi,omega);
% sysg_long_lo = frsp(sys_long_lo,omega);
% 
% figure;
% BodeCount = 0;
% for state = 1:1:5
%     for control = 1:1:2
%         BodeCount = BodeCount +1;
%         title_string = sprintf('Bode Plot #%d\n State = %d\n Control = %d', BodeCount,state,control);
%         vplot('bode', sel(sysg_long_hi,state,control), 'b--', sel(sysg_long_lo,state,control), 'r');
%         disp(title_string);
%         legend('hifi', 'lofi');
%         pause;
%     end
% end
% 
% for state = 1:1:6
%     for control = 1:1:3
%         BodeCount = BodeCount + 1;
%         title_string = sprintf('Bode Plot #%d\n State = %d\n Control = %d', BodeCount,state,control);
%         vplot('bode', sel(sysg_lat_hi,state,control), 'b--', sel(sysg_lat_lo,state,control), 'r');
%         disp(title_string);
%         legend('hifi', 'lofi');
%         pause;
%     end
% end
