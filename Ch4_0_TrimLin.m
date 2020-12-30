%% setup

% check if run from correct path
[~, lastdir, ~] = fileparts(pwd);
if ~strcmp(lastdir, "AE4301P")
    error(strcat("Please run ",...
                 mfilename,...
                 " from the root directory of this project"...
                 ))
end


%% generate and load the flight conditions

disp("trim-lin: Load FlightConditions.mat file...")
load('FlightConditions');


%% Run the non-interactive trimming

% make directory for output files, if it doesn't already exist
outdir = "Outputs/Ch4_0_TrimLin";
mkdir(outdir)
addpath(outdir)

cd ExternalModules/F16Sim/

try
    for fc_idx = 1:length(fc.name)
        %% Run the trimming and linearization routine
        
        disp(strcat("trim-lin: trimming and linearizing condition ", ...
                     fc.name{fc_idx}...
                     ))

        % setting flight condition for the FindF16Dynamics script
        fc_setting.h = fc.con(fc_idx, 1);
        fc_setting.v = fc.con(fc_idx, 2);
        fc_setting.Fiflag = fc.con(fc_idx, 3);

        run FindF16Dynamics_noninteractive.m

        
        %% reducing dynamics
        if fc.con(fc_idx, 4) > 0
            disp(strcat("trim-lin: reducing condition ", ...
                     fc.name{fc_idx}...
                     ))
        end

        if fc.con(fc_idx, 4) == 5
            % reduction to 5 DoFs: 

            % Longitudinal States --> h, u, \alpha, \theta, q
            long_states = [1, 3, 4, 2, 5];
            long_act_states = [6, 7];
            A_long = SS_long.A(long_states, long_states);
            B_long = SS_long.A(long_states, long_act_states);
            C_long = SS_long.C(long_states, long_states);
            D_long = SS_long.D(long_states, :);
            SS_long = ss(A_long, B_long, C_long, D_long);

            % laterial states --> not needed, just keep full
            
        elseif fc.con(fc_idx, 4) == 4
            % reduction to 4 DoFs: 

            % Longitudinal States --> u, \alpha, \theta, q
            long_states = [3, 4, 2, 5];
            long_act_states = [6, 7];
            A_long = SS_long.A(long_states, long_states);
            B_long = SS_long.A(long_states, long_act_states);
            C_long = SS_long.C(long_states, long_states);
            D_long = SS_long.D(long_states, :);
            SS_long = ss(A_long, B_long, C_long, D_long);


            % Lateral States -->  \beta, \phi, p, r
            lat_states = [4, 1, 5, 6];
            lat_act_states = [7, 8, 9];
            A_lat = SS_lat.A(lat_states, lat_states);
            B_lat = SS_lat.A(lat_states, lat_act_states);
            C_lat = SS_lat.C(lat_states, lat_states);
            D_lat = SS_lat.D(lat_states, :);
            SS_lat = ss(A_lat, B_lat, C_lat, D_lat);

        elseif fc.con(fc_idx, 4) == 2
            % reduction to 2 DoFs

            % Longitudinal States --> \alpha, \theta, q
            long_states = [4, 5];
            long_act_states = [6, 7];
            A_long = SS_long.A(long_states, long_states);
            B_long = SS_long.A(long_states, long_act_states);
            C_long = SS_long.C(long_states, long_states);
            D_long = SS_long.D(long_states, :);
            SS_long = ss(A_long, B_long, C_long, D_long);
            
            % laterial states --> not needed, just keep full
            
        end

        %% saving SS matrices to file
        filename = strcat("../../Outputs/Ch4_0_TrimLin/SS_", fc.name{fc_idx});
        save(filename, 'SS_long', 'SS_lat', 'xu', 'cost')

    end
    
catch ME
    
    %% go back to project root
    cd("../../")
    rethrow(ME)
    
end

cd("../../")


%% 

fprintf("trim_lin: done\n")
