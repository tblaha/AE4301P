

% columns: altitude [ft] | speed [ft/s] | HiFi 1/LoFi 0 | reduction level
fc = struct();
fc.con = zeros(8, 4);
fc.name = cell(8, 1);

%%% TODO: find out leading edge flap


%% standard
% standard, LoFi, non-reduced
fc.con(1, :) = [30000, 900, 0, 0];
fc.name{1}   = "Std_LoFi_full";

% standard, HiFi, non-reduced
fc.con(2, :) = [30000, 900, 1, 0];
fc.name{2}   = "Std_HiFi_full";


%% accel
% accel, LoFi, non-reduced
fc.con(3, :) = [15000, 500, 0, 0];
fc.name{3}   = "Accel_LoFi_full";

% accel, HiFi, non-reduced
fc.con(4, :) = [15000, 500, 1, 0];
fc.name{4}   = "Accel_HiFi_full";


%% standard reduced 5-DoF (for fair actuator reduction comparison)
% standard, LoFi, reduced to 5DoF
% Longitudinal States --> h, u, \alpha, \delta, q
% Lateral States -->  all
fc.con(5, :) = [30000, 900, 0, 5];
fc.name{5}   = "Std_LoFi_5DoF";


%% standard reduced 4-DoF 
% standard, LoFi, reduced to 4DoF
% Longitudinal States --> u, \alpha, \delta, q
% Lateral States -->  \beta, \phi, p, r
fc.con(6, :) = [30000, 900, 0, 4];
fc.name{6}   = "Std_LoFi_4DoF";


%% standard reduced 2-DoF 
% standard, LoFi, reduced to 4DoF
% Longitudinal States --> \alpha, q
% Lateral States -->  all
fc.con(7, :) = [30000, 900, 0, 2];
fc.name{7}   = "Std_LoFi_2DoF";


%% Glideslope condition reduced 5-DoF
% 5000ft, LoFi, reduced to 5DoF
% Longitudinal States --> h, u, \alpha, \delta, q
% Lateral States -->  all
fc.con(8, :) = [5000, 300, 0, 5];
fc.name{8}   = "GS_LoFi_5DoF";


%% save as mat file

save('fc.mat', 'fc')
