

% columns: altitude [ft] | speed [ft/s] | HiFi 1/LoFi 0 | reduction level
fc = struct();
fc.con = zeros(10, 4);
fc.name = cell(10,1);

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






%% save as mat file

save('fc.mat', 'fc')
