% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
VerifyDirectory(lastdir)

% get flight conditions
if exist('FlightConditions.mat') ~= 2
    run gen_fc.m
end
load('FlightConditions.mat')

% make directory for output files, if it doesn't already exist
outdir = "Outputs/Ch4_1_Accel";
mkdir(outdir)
addpath(outdir)


%% Task 4.1 -- see LIN_F16Block_an.mdl

% accel position (used in the LIN_F16Block_an.mdl
xa = 0; % ft


%% Task 4.2 -- linear model

% subroutine that calls FindF16Dyamics
run linearize_accel.m


%% Task 4.3 output equation for xa = 0

% outputs according to F16_Manual page 21: 
% (h, \theta, v, \alpha, q)
% output a_n is appended, so we need the 6th output due to all inputs
C_an = SS_long(6, :).C;
D_an = SS_long(6, :).D;

% if x constains the states (h, \theta, v, \alpha, q,   \delta_t, \delta_e)
%                           (ft, rad, ft/sec, rad, rad/2, deg, deg)
% and u contains the inputs (\delta_t_ref, \delta_e_ref),
%                           (deg,           deg)
%
% then this is the linear output equation for the output a_n
an = @(x, u) C_an*x + D_an*u;


%% Task 4.4 -- list of states

% we have a couple coefficients that are really small; but are they
% insignificant?

% let's weigh the coefficients by their maximum following an elevator step
max_step = [-100, -10*pi/180, 12, -3.5*pi/180, -4*pi/180, 0, 1];
rel_dependency = C_an.*max_step;

% norm them such that the maximum is 1
rel_dependency = rel_dependency/max(abs(rel_dependency));

% define significance level and find significant dependencies
sig_level = 1e-2;
an_dependencies = find(abs(rel_dependency) >= sig_level);


% output:
names = ["h", "\theta", "v", "\alpha", "q", "\delta_t", "\delta_e"];

fprintf("\n")
fprintf("Ch4_1_Accel: Task 4.4 -- a_n depends on %s \n", names(an_dependencies).join(", "))
fprintf("\n")


%% Task 4.5 -- el-to-normal-acceleration transfer function

% choose 6th output, 2nd input. Use minimum realization:
el2an = minreal(tf(SS_long(6, 2)));


%% Task 4.6 -- Draw step plot

% choose first 2 seconds and include minus for ANU
%
% step(-el2an, 2) % see Task 4.9


%% Task 4.7

% the zeros of the system are
zpk_repr = zpk(el2an);
zeros_el2an = zpk_repr.Z{1};

% there largest zeros in the open left half plane (short time scale) is 
% responsible for the non-minimum phase behaviour in the first second.


%% Task 4.8

% It arises from the positive-z (so, down) force contribution of the 
% elevator. Before integration of the pitch moment to pitch rate and angle
% of attack, it results in a downwards acceleration along with the pitch up
% 
% For an aircraft where movable canards provide the rotation moment
% (specifically, NOT the Eurofighter, by Eurofighter Chief Instructor Gero
% Finke's account), this lead to a minimum phase system. However, static
% instability (for example, achieved with canards, like in the Eurofighter)
% might significantly reduce this effect.


%% Task 4.9

% we need to do two things here: look at the numerical values of the zeros
% in the transfer function and plot the step responses for a xa sweep
xa_sweep = fliplr([0, 5, 5.9, 6, 7, 15]);


% Let's use a table to store the numerical results
zeros_el2an_sweep = ...
    table(...
    'size', [length(xa_sweep), 5],...
    'VariableTypes', ["double", "double", "double", "double", "double"],...
    'VariableNames', ["x_a", "Zero1", "Zero2", "Zero3", "Zero4"],...
    'RowNames', string(xa_sweep)...
    );


% set up figure for the step plots (base axes will show short time period
% and we will have a smaller set of axes inside the base axes that show a
% bigger picture)
fig_size = [700 500]; % width, height
fig_pos = [100 100 100+fig_size(1) 100+fig_size(2)];
el2an_fig = figure("Name", "Accelerometer Position Sweep",...
                    "Position", fig_pos,...
                    "Visible", show_plots);
tshort = 0.15; %s
tlong  = 4; %s

% plot options
p_base = make_plot_options("Time Response to $-1^{\circ}$ Elevator Step",...
                      "Time t [s]", "Measured acceleration $a_n$ [g units]");
p_zoom = make_plot_options("Longer time scale",...
                      "Time t [s]", "$a_n$ [g units]");
p_zoom.Title.FontSize = 12; p_zoom.XLabel.FontSize = 8; p_zoom.YLabel.FontSize = 8;
p_zoom.Grid = 'off';

% get/make axis objects
base_ax = gca;
zoom_ax = axes('position',[.19 .51 .35 .35]);


% iterate
hold(base_ax, 'on')
hold(zoom_ax, 'on')

i = 1;
lss = ["-", "--", "-."];
for xa = xa_sweep
    % line style and line width settings
    ls = lss(mod(i, 3)+1);
    lw = 2 - floor(i/3)*0.5;
    i = i + 1;
    
    % linearize with the current choice of xa like in Task 4.2
    run linearize_accel.m
    
    % transfer function like in Task 4.5
    el2an = minreal(tf(SS_long(6, 2)));
    
    % save numerical values inside the table
    zeros_el2an_sweep{string(xa), "x_a"} = xa;
    zpk_repr = zpk(el2an);
    zeros_el2an_sweep{string(xa), 2:end} = zpk_repr.Z{1}';
    
    
    % make the plots with the 2 timescales (short and long)
    stepplot(base_ax, -el2an, tshort, p_base)
    base_ax.Children(1).Children(2).LineWidth=lw;
    base_ax.Children(1).Children(2).LineStyle=ls;
    
    stepplot(zoom_ax, -el2an, tlong, p_zoom)
    zoom_ax.Children(1).Children(2).LineWidth=lw;
    zoom_ax.Children(1).Children(2).LineStyle=ls;
end
hold(base_ax, 'off')
hold(zoom_ax, 'off')

% get the lines out of the way of the legend and the subplot
base_ax.YLim = [-0.015, 0.08];

% make legend in a beun way...
legend(base_ax, "$x_a$ = +"+string(xa_sweep)+"ft",...
      'Location', 'North East',...
      "fontsize",14)
base_ax.Legend.Interpreter = "latex";
legend(base_ax, "$x_a$ = +"+string(xa_sweep)+"ft",...
      'Location', 'North East',...
      "fontsize",14)
  

% write to output folder
set(el2an_fig, 'Color', 'w');
export_fig Outputs/Ch4_1_Accel/xa_sweep.eps -painters


% output table as well
writetable(zeros_el2an_sweep, 'Outputs/Ch4_1_Accel/Zeros_Sweep.csv',...
                              'WriteRowNames', false)

disp("Ch4_1_Accel: Sweeping through x_a (in feet) yields the following OL-zeros:")
zeros_el2an_sweep


%% Task 4.10

% The intantaneous center of rotation (so the apparent point that the
% aircraft accelerates about in pitch, due to the combination of rotation
% around the cg and downward acceleration due to the elevators) is located
% around x=5.9ft in front of the cg. Here the zero just switched to
% negative and is also very large (so only matters for very large
% frequencies.)


%% Task 4.11

% The pilot's station shall not be behind of this location as then a pull
% up initially induces a positive (so downward) acceleration. If the
% station is \underline{at} the IC, then initially only the rotational
% acceleration and velocity is felt by the pilot; allowing him/her to focus
% on that in conjunction with his/her expectation of the short-period load
% factor after some time (dictated by the CAP).
% Slightly in front of the IC would probably also be fine as then a
% negative (so upward) acceleration is initially felt which is consistent
% with the expectation going along with the input and also with the sign of
% the CAP.


%% Task 4.12

% Since the frequencies involved can be quite high (we have seen reversal
% of signs in normal acceleration within less than a 10th of a second), the
% dynamics of the fuselage might play a role.
% It has a mass distribution and bending stiffness around the y-axis, so it
% necessarily vibrates. An elevator step, as well as gusts, tank sloshing,
% firing of weapons/cannon might excite it sufficiently and depending on
% the natural frequency and amplitudes it might cross talk into the
% accelerometer unless it is placed at a node; where by definition the
% amplitude of the vibrational mode is 0.
% 
% If the fuselage characteristics are known for a range of load-outs, then
% one might also consider filtering the signal with a notch- or low-pass-
% filter at/above the relevant frequencies.

%% clean workspace 

% clearvars -except show_plots fc SS_long xa

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

