
%% Longitudinal

%%%%%%% phugoid, pitch rate, step input
plot_long_pitchrate = figure("Name", "Phugoid",...
                             "Position", fig_pos,...
                             "Visible", show_plots);

SS_el_pitchrate = SS_long(4,2);

% set plot options
p = make_plot_options("Time Response to $1^{\circ}$ Elevator Step",...
                      "Time t [s]", "Pitch Rate q [$\circ$ / s]");

% plot the step
stepplot(SS_el_pitchrate, 1000, p);
base_ax = gca;

% increase line thickness
base_ax.Children(1).Children(2).LineWidth=1.5;


%%%%%%%%% In same plot: Short Period, pitch rate, step input

% create new axes to zoom around Origin
zoom_ax = axes('position',[.35 .2 .35 .38]);

% set plot options
p = make_plot_options("Zoom closer to $t=0$",...
                      "Time t [s]", "Pitch Rate q [$\circ$ / s]");
p.Title.FontSize = 12; p.XLabel.FontSize = 8; p.YLabel.FontSize = 8;

% plot the step
stepplot(SS_el_pitchrate, 12, p);
zoom_ax.Children(1).Children(2).LineWidth=1.5;

% save plot
filename = strcat("Outputs/Ch5_OpenLoop/", 'TR_Pitchrate_Phugoid_and_sp_long');
print(plot_long_pitchrate, '-depsc2', '-painters', filename)  % looks better for some reason...
% saveas(plot_long_pitchrate, filename, 'epsc2');



% %short period, pitch rate, step input
% plot_long_pitchrate = figure("Name", "Short Period",...
%                              "Position", fig_pos,...
%                              "Visible", show_plots);
%                          
% SS_el_pitchrate = SS_long(4,2);
% step(SS_el_pitchrate, 10);
% filename = strcat("OL_results/", 'TR_Pitchrate_sp_long');
% saveas(plot_long_pitchrate, filename, 'epsc');

%% Lateral

%%%%%%% dutch roll, rudder input, yaw rate
plot_lat_yawrate = figure("Name", "Dutch Roll",...
                             "Position", fig_pos,...
                             "Visible", show_plots);

SS_yawrate = SS_lat(4,3);

% set plot options
p = make_plot_options("Time Response to $1^{\circ} s$ Rudder Impulse",...
                      "Time t [s]", "Yaw Rate r [$\circ$ / s]");

% plot the impulse
impulseplot(SS_yawrate,15, p);
base_ax = gca;

% increase line thickness
base_ax.Children(1).Children(2).LineWidth=1.5;

% save
filename = strcat("Outputs/Ch5_OpenLoop/", 'TR_Yawrate_dr_lat');
print(plot_lat_yawrate, '-depsc2', '-painters', filename)  % looks better for some reason...
% saveas(plot_lat_yawrate, filename, 'epsc');




%%%%%%% spiral, aileron input, roll angle
plot_lat_rollangle = figure("Name", "Spiral",...
                             "Position", fig_pos,...
                             "Visible", show_plots);
SS_rollangle = SS_lat(2,2);

% set plot options
p = make_plot_options("Time Response to $1^{\circ} s$ Aileron Impulse",...
                      "Time t [s]", "Roll Angle $\phi$ [$\circ$]");

% plot the impulse
impulseplot(SS_rollangle, 800, p)
base_ax = gca;

% increase line thickness
base_ax.Children(1).Children(2).LineWidth=1.5;

% save
filename = strcat("Outputs/Ch5_OpenLoop/", 'TR_rollrate_spiral_lat');
print(plot_lat_rollangle, '-depsc2', '-painters', filename)  % looks better for some reason...
% saveas(plot_lat_rollangle, filename, 'epsc');




%%%%%%% aperiodic roll, aileron input, roll rate
plot_lat_rollrate = figure("Name", "ApRoll",...
                             "Position", fig_pos,...
                             "Visible", show_plots);
SS_rollrate = SS_lat(3,2);

% set plot options
p = make_plot_options("Time Response to $1^{\circ}$ Aileron Step",...
                      "Time t [s]", "Roll Rate p [$\circ$ / s]");

% plot the step
stepplot(SS_rollrate,10, p)
base_ax = gca;

% increase line thickness
base_ax.Children(1).Children(2).LineWidth=1.5;

% save
filename = strcat("Outputs/Ch5_OpenLoop/", 'TR_rollrate_aper_lat');
print(plot_lat_rollrate, '-depsc2', '-painters', filename)  % looks better for some reason...
% saveas(plot_lat_rollrate, filename, 'epsc');



%% helper functions


function p = make_plot_options(Title, XLabel, YLabel)
    
    p = timeoptions;
    
    p.Title.String = Title;
    p.XLabel.String = XLabel;
    p.YLabel.String = YLabel;
    p.Title.Interpreter = 'latex'; 
    p.XLabel.Interpreter = 'latex'; 
    p.YLabel.Interpreter = 'latex';
    p.Title.FontSize = 18; p.XLabel.FontSize = 16; p.YLabel.FontSize = 16;
    p.Grid = 'on';
    
end