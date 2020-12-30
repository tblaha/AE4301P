% assign flight condition to variable used by FindF16Dynamics.m
fc_setting.h = fc.con(3, 1);
fc_setting.v = fc.con(3, 2);
fc_setting.Fiflag = fc.con(3, 3);

% define workspace variables
gD = 9.80665 / 0.3048; % ft/s^2 standard gravity

% tell FindF16Dynamics.m to use the modified LIN_F16Block_an.m
an_output = true;

% run linearization
run FindF16Dynamics_noninteractive.m


