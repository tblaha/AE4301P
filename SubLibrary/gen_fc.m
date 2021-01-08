

fprintf("gen_fc: Generating 8 flight conditions to be written to FlightConditions.mat...")

% columns: altitude [ft] | speed [ft/s] | HiFi 1/LoFi 0 | reduction level
fc = struct();
fc.con = zeros(10, 4);
fc.name = cell(10, 1);


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


%% Glideslope condition full HiFi (only for residual comparison)
% 5000ft, LoFi, reduced to 5DoF
% Longitudinal States --> h, u, \alpha, \delta, q
% Lateral States -->  all
fc.con(8, :) = [5000, 300, 1, 0];
fc.name{8}   = "GS_HiFi_full";



%% Glideslope condition reduced 5-DoF
% 5000ft, LoFi, reduced to 5DoF
% Longitudinal States --> h, u, \alpha, \delta, q
% Lateral States -->  all
fc.con(9, :) = [5000, 300, 0, 5];
fc.name{9}   = "GS_LoFi_5DoF";


%% Glideslope condition reduced 2-DoF (for pole-placement)
% 5000ft, LoFi, reduced to 2DoF
% Longitudinal States --> h, u, \alpha, \delta, q
% Lateral States -->  all
fc.con(10, :) = [5000, 300, 0, 2];
fc.name{10}   = "GS_LoFi_2DoF";


%% save as mat file

% make directory for output files, if it doesn't already exist
outdir = "Outputs/Ch4_0_TrimLin";
mkdir(outdir)
addpath(outdir)

% finally, save
save('Outputs/Ch4_0_TrimLin/FlightConditions.mat', 'fc')


%%

fprintf("done\n")
