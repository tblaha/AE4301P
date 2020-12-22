fc_setting.h = fc.con(3, 1);
fc_setting.v = fc.con(3, 2);
fc_setting.Fiflag = fc.con(3, 3);

% define workspace variables
gD = 9.80665 / 0.3048; % ft/s^2 standard gravity

% define linearization model
SL_lin_block = 'LIN_F16Block_an';
an_output = true;

run FindF16Dynamics_noninteractive.m
% note; the above script splits the model into long and lat. This is not
% a problem, since the only states affect an are longitudinal in the first
% place. Also, states 1 and 2 (coordinates of the F16) are not included,
% but an also doesn't depend on those --> all effect on an are captured in
% SS_long

clear SL_lin_block an_output