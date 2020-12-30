% This file verifies that the reduction of the system dynamics is done
% correctly with respect to the actuator dynamics.

% therefore, the elevator-to-pitch-angle transfer function of the full
% logitudinal LoFi model is compared to the convolution of a low-pass
% actuator model convoluted with a 5 DoF model (7 states - 2 actuator
% states)


%% setup

% check if run from correct path:
[~, lastdir, ~] = fileparts(pwd);
VerifyDirectory(lastdir)

% load Steady State system; if it doesn't exist, run Ch4_0_TrimLin.m
fprintf("Ch5_OpenLoop: Checking if SS matrices exist...")
if exist("SS_Std_LoFi_4DoF.mat", 'file') == 2
    fprintf("OK\n")
    
    load('SS_Std_LoFi_4DoF.mat');
else
    fprintf("failed: try to run trim-lin to generate them...\n")
    
    run Ch4_0_TrimLin.m
    
    fprintf("Ch5_OpenLoop: Importing SS matrix...")
    
    load('SS_Std_LoFi_4DoF.mat');
    fprintf("OK, recovered\n")
end

% make folder for the plots; if it doesn't exist yet
outdir = "Outputs/Ch4_0_TrimLin";
mkdir(outdir)
addpath(outdir)


%% load models

red5 = load("SS_Std_LoFi_5DoF");
nonred = load("SS_Std_LoFi_full");

s = tf('s');

%% elevator to theta of the full model

H_full = tf(nonred.SS_long);
H_full_elref_2_q = H_full(5, 2);


%% adding actuator back into reduced model

% el 2 theta for the reduced model
H_red5=tf(red5.SS_long);
H_red5_el_2_q = H_red5(5, 2);

% first order servo dynamics
H_el_servo = 20.2 / (s + 20.2);

% transfer function with added actuatordyamics
H_red5_el_2_q_act = H_el_servo * H_red5_el_2_q;



disp("VerifyReduction: The 2 transfer functions below should be the same:")
minreal(H_full_elref_2_q)
minreal(H_red5_el_2_q_act)



%% compare convolved functions

%step(H_full_elref_2_q - H_red5_el_2_q_act)












%% compare original functions



red4 = load("SS_Std_LoFi_4DoF");
H_red4 =tf(red4.SS_long);
H_red4_el_2_q = H_red4(4, 2);

red2 = load("SS_Std_LoFi_2DoF");
H_red2 = tf(red2.SS_long);
H_red2_el_2_q = H_red2(2, 2);

h=figure("Name", "ReductionComp",...
         "Position", [100, 100, 800, 500],...
         'Visible', show_plots);
   
t = "Longitudinal Reduction Error -- Elevator Step -- q";
XL = "Time";
YL = "\Delta q (\circ /s)";
p = make_plot_options(t, XL, YL);

stepplot(H_full_elref_2_q-H_full_elref_2_q, 10, p);
hold on
step(H_red5_el_2_q-H_full_elref_2_q, 10);
step(H_red4_el_2_q-H_full_elref_2_q, 10);
step(H_red2_el_2_q-H_full_elref_2_q, 10);
hold off

ax = gca(h);
lss = ["-", "--", "-.", "-"];
for i = 1:length(ax.Children)-1
    ax.Children(i).Children(2).LineWidth=2;
    ax.Children(i).Children(2).LineStyle=lss(i);
        
end
ax.SortMethod='ChildOrder';

legend({'8DoF -- Full Model',...
        '5DoF -- Actuator Reduced',...
        '4DoF -- No Altitude',...
        '2DoF -- Short Period Model'},...
        "fontsize", 10, "Location", "SouthEast")
    
    
zoom_ax = axes('position',[.225 .2 .3 .35]);
p = make_plot_options("8DoF -- Full Model Response",...
                      "Time", "q ($\circ$ / s)");
p.Grid = 'off';
p.Title.FontSize = 12; p.XLabel.FontSize = 8; p.YLabel.FontSize = 8;

% plot the step
stepplot(H_full_elref_2_q, 10, p);
zoom_ax.Children(1).Children(2).LineWidth=2;
zoom_ax.SortMethod='ChildOrder';



filename = strcat("OL_plot_files/", "ReductionComparison");
% print(h, '-depsc2', '-painters', filename)
set(gcf, 'Color', 'w');
export_fig Outputs/Ch4_0_TrimLin/ReductionComparison.eps -painters




%% qualitative theta plot

H_full_elref_2_theta = H_full(2, 2);
H_red5_elref_2_theta = H_red5(4, 2);
H_red4_elref_2_theta = H_red4(3, 2);
H_red2_elref_2_theta = H_red2(2, 2) * 1/s;

h=figure("Name", "ReductionCompTheta",...
         "Position", [100, 100, 800, 500],...
         'Visible', show_plots);
   
t = "Longitudinal Reduction Error -- Elevator Step -- theta";
XL = "Time";
YL = "\theta (\circ)";
p = make_plot_options(t, XL, YL);


hold on
stepplot(H_full_elref_2_theta, 10, p);
step(H_red5_elref_2_theta, 10);
step(H_red4_elref_2_theta, 10);
step(H_red2_elref_2_theta, 10);
hold off

ax = gca(h);
lss = ["-", "--", "-.", "-"];
for i = 1:length(ax.Children)-1
    ax.Children(i).Children(2).LineWidth=2;
    ax.Children(i).Children(2).LineStyle=lss(i);
end
ax.SortMethod='ChildOrder';

legend({'8DoF -- Full Model',...
        '5DoF -- Actuator Red.',...
        '4DoF -- No Altitude',...
        '2DoF -- Short Period'},...
        "fontsize", 10, "Location", "NorthEast")

set(gcf, 'Color', 'w');
export_fig Outputs/Ch4_0_TrimLin/ReductionComparisonTheta.eps -depsc -painters


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



