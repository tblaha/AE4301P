%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run Simulation and Post Process %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out = sim('Landing');


%%
% naming of outputs
Pitch_Hold_Names = ["\Delta \theta_{ref}"; "\Delta \theta";
                    "\Delta q_{ref}"; "\Delta q";
                    "\Delta \delta_{e_{ref}}"; "\Delta \delta_{e}";
                    ];
Speed_Hold_Names = ["\Delta \delta_{t_{ref}}"; "\Delta \delta_t";
                    "Thrust"; "\Delta u";
                    ];

Glideslope_Names = ["\gamma"; "\Gamma"; 
                    "GS active"; "GS gain"; 
                    "\Delta \theta_{ref, GS}"; "\Delta \theta";
                    ];

Flare_Names = ["$\dot{h}_{ref}$"; "$\dot{h}$";
               "Flare active"; "h"; "x";
               "$\Delta \theta_{ref, Flare}$";
               ];


%% Simulation Plot Options

% line styles and colors
lss  = ["-", "--", "-."];
cols = [0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];
lw   = 1.5;

% font sizes
lfs = 12;

% subplots
subplot_codes = [121, 122];
GS_lim    = [0, 133]; % sec
Flare_lim = [134, 141]; % sec
limits    = [GS_lim; Flare_lim]; % sec
Titles    = ["Glideslope Tracking", "Flare Manoeuvre"];

t = out.tout;



%% Pitch Mode

% figure handle
Pitch_Hold_handle = figure("Name", "Pitch Hold Performance",...
                           "Position", [700 200 1000 500],...
                           "Visible", show_plots);

sgtitle("Pitch Controller Performance")

axs = [];
for i = 1:length(subplot_codes)
    
    axs(i) = subplot(subplot_codes(i));
    title(Titles(i))
    hold on
        plot(t, out.Pitch_Hold(:, 1), "DisplayName", Pitch_Hold_Names(1),...
                "linewidth", lw, "linestyle", lss(2), "color", cols(1, :))
        plot(t, out.Pitch_Hold(:, 2), "DisplayName", Pitch_Hold_Names(2),...
                "linewidth", lw, "linestyle", lss(1), "color", cols(1, :))
        
        plot(t, out.Pitch_Hold(:, 3), "DisplayName", Pitch_Hold_Names(3),...
                "linewidth", lw, "linestyle", lss(2), "color", cols(2, :))
        plot(t, out.Pitch_Hold(:, 4), "DisplayName", Pitch_Hold_Names(4),...
                "linewidth", lw, "linestyle", lss(1), "color", cols(2, :))
        
        plot(t, out.Pitch_Hold(:, 5), "DisplayName", Pitch_Hold_Names(5),...
                "linewidth", lw, "linestyle", lss(2), "color", cols(3, :))
        plot(t, out.Pitch_Hold(:, 6), "DisplayName", Pitch_Hold_Names(6),...
                "linewidth", lw, "linestyle", lss(1), "color", cols(3, :))
    hold off
    
    grid on
    if i == 1
        xlim([5 50])
    else
        xlim(limits(i, :))
    end
    xlabel("Time [s]")
    % set(axs(i), 'XLimSpec', 'Tight');
    
    % if i == 1
        ylabel("Angle [deg] / Rate [deg/s]")
    % end
end
legend("Location", "SouthEast", "FontSize", lfs)
linkaxes(axs, 'y')


% export figure to results folder
set(Pitch_Hold_handle, 'Color', 'w');
export_fig Outputs/Ch7_Landing/PitchController.eps -painters



%% Speed Mode

% figure handle
Speed_Hold_handle = figure("Name", "Speed Hold Performance",...
                           "Position", [700 200 1000 500],...
                           "Visible", show_plots);

sgtitle("Speed Controller Performance")

axs = [];
for i = 1:length(subplot_codes)
    
    axs(i) = subplot(subplot_codes(i));
    title(Titles(i))
    hold on
    
        yyaxis left
        plot(t, out.Speed_Hold(:, 1), "DisplayName", Speed_Hold_Names(1),...
                "linewidth", lw, "linestyle", lss(2), "color", cols(1, :))
        plot(t, out.Speed_Hold(:, 2), "DisplayName", Speed_Hold_Names(2),...
                "linewidth", lw, "linestyle", lss(1), "color", cols(1, :))
        plot(t, out.Speed_Hold(:, 3), "DisplayName", Speed_Hold_Names(3),...
                "linewidth", lw, "linestyle", lss(3), "color", cols(1, :))
        ylabel("Thrust [lbs \cdot 10^3]")
        
        yyaxis right
        plot(t, out.Speed_Hold(:, 4), "DisplayName", Speed_Hold_Names(4),...
                "linewidth", lw, "linestyle", lss(1), "color", cols(2, :))
        ylabel("u -- Speed Deviation [ft/s]")
        
    hold off
    
    grid on
    xlim(limits(i, :))
    xlabel("Time [s]")
end
legend("Location", "East", "FontSize", lfs)
linkaxes(axs, 'y')



% export figure to results folder
set(Speed_Hold_handle, 'Color', 'w');
export_fig Outputs/Ch7_Landing/SpeedMode.eps -painters




%% Glideslope Mode

% figure handle
Glideslope_handle = figure("Name", "Glideslope Performance",...
                           "Position", [700 200 1000 500],...
                           "Visible", show_plots);

sgtitle("Glideslope Performance")

axs = [];
% axs(1) = subplot(subplot_codes(1));
% title(Titles(1))
hold on

    yyaxis left
    plot(t, out.Glideslope(:, 1), "DisplayName", Glideslope_Names(1),...
            "linewidth", lw, "linestyle", lss(1), "color", cols(1, :))
    plot(t, out.Glideslope(:, 2), "DisplayName", Glideslope_Names(2),...
            "linewidth", lw, "linestyle", lss(1), "color", cols(3, :))
    plot(t, out.Glideslope(:, 5), "DisplayName", Glideslope_Names(5),...
            "linewidth", lw, "linestyle", lss(2), "color", cols(4, :))
    plot(t, out.Glideslope(:, 6), "DisplayName", Glideslope_Names(6),...
            "linewidth", lw, "linestyle", lss(1), "color", cols(4, :))
    ylabel("Angle [deg]")

    yyaxis right
    plot(t, out.Glideslope(:, 3), "DisplayName", Glideslope_Names(3),...
            "linewidth", 1, "linestyle", lss(1), "color", cols(2, :))
    plot(t, out.Glideslope(:, 4), "DisplayName", Glideslope_Names(4),...
            "linewidth", 1, "linestyle", lss(3), "color", cols(2, :))
    ylabel("[-]")
    ylim([-0.1, 1.4])

hold off
grid on
xlim(limits(1, :))
xlabel("Time [s]")
legend("Location", "East", "FontSize", lfs)


% export figure to results folder
set(Glideslope_handle, 'Color', 'w');
export_fig Outputs/Ch7_Landing/GlideslopeCoupler.eps -painters



%% Flare Mode

% figure handle
Flare_handle = figure("Name", "Flare Performance",...
                      "Position", [700 200 1000 500],...
                      "Visible", show_plots);

sgtitle("Flare Controller Performance")

subplot(121)
hold on

    yyaxis left
    plot(t, out.Flare(:, 1), "DisplayName", Flare_Names(1),...
            "linewidth", lw, "linestyle", lss(2), "color", cols(1, :))
    plot(t, out.Flare(:, 2), "DisplayName", Flare_Names(2),...
            "linewidth", lw, "linestyle", lss(1), "color", cols(1, :))
    ylabel("Vertical Rate [ft/s]")

    yyaxis right
    plot(t, out.Flare(:, 6), "DisplayName", Flare_Names(6),...
            "linewidth", lw, "linestyle", lss(2), "color", cols(2, :))
    plot(t, out.Flare(:, 3), "DisplayName", Flare_Names(3),...
            "linewidth", 1, "linestyle", lss(1), "color", cols(3, :))
    ylabel("[-] / deg")
    ylim([-0.5, 4])

hold off

grid on
xlim(limits(2, :))
xlabel("Time [s]")
legend("Location", "SouthEast",'interpreter','latex', "FontSize", lfs)


subplot(122)
hold on

    yyaxis left
    plot(t, out.Flare(:, 4), "DisplayName", Flare_Names(4),...
            "linewidth", lw, "linestyle", lss(1), "color", cols(1, :))
    ylabel("Altitude [ft]")
    
    yyaxis right
    plot(t, out.Flare(:, 5), "DisplayName", Flare_Names(5),...
            "linewidth", lw, "linestyle", lss(2), "color", cols(2, :))
    plot(t, 500*out.Flare(:, 3), "DisplayName", Flare_Names(3),...
            "linewidth", 1, "linestyle", lss(1), "color", cols(2, :))
    ylabel("Distance from Threshold [ft]")

hold off

grid on
xlim(limits(2, :))
xlabel("Time [s]")


legend("Location", "NorthEast", "Fontsize", lfs)



% export figure to results folder
set(Flare_handle, 'Color', 'w');
export_fig Outputs/Ch7_Landing/FlareController.eps -painters





