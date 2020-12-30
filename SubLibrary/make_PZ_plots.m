%% PZ plots

%%%%%%%%%%% longitudinal plot
map_long = figure("Name", "PZ_long",...
                  "Position", fig_pos,...
                  'Visible', show_plots); 

% base pz map
pz_long = pzplot(SS_long);
base_ax = gca;

% title and grid formatting
p = getoptions(pz_long);
p.Title.FontSize = 16;
p.Title.String = "Pole-Zero Map -- Longitudinal Modes";
p.Grid = 'on';
p.GridColor = [0.5, 0.5, 0.5];
setoptions(pz_long, p)

% increase visibility of the markers
set(base_ax.Children(1).Children, 'MarkerSize', 10)
set(base_ax.Children(1).Children, 'LineWidth', 2)

% Make Short Period Arrows
annotation(map_long,'arrow',[0.324175824175824 0.224175824175824],...
    [0.8023316519546 0.199243379571248]);
annotation(map_long,'arrow',[0.314285714285714 0.241758241758242],...
    [0.829760403530895 0.83084867591425]);
annotation(map_long,'textbox',...
    [0.315384615384615 0.80219419924338 0.161868131868132 0.038264817150063],...
    'String',{'Short Period'},...
    'FitBoxToText','off', 'FontSize', 10);

% create new axes to zoom around Phugoid
zoom_ax = axes('position',[.43 .4 .35 .4]);
pz_long_zoom = pzplot(SS_long);

% size, title, ticks formatting
p = getoptions(pz_long_zoom);
p.Title.String = "Zoom at Phugoid";
p.XLabel.FontSize = 8;
p.YLabel.FontSize = 8;
p.Xlim = {[-0.02, 0.02]};
p.Ylim = {[-0.1, 0.1]};
p.TickLabel.FontSize = 8;
setoptions(pz_long_zoom, p)

% special s-grid for it not to look like a mess
sgrid([0.3, 0.2, 0.1, 0.05], [0.02, 0.05, 0.2])

% again, increase marker size
set(zoom_ax.Children(1).Children, 'MarkerSize', 10)
set(zoom_ax.Children(1).Children, 'LineWidth', 2)

% whatever this does?
axis tight


% Make Phugoid Arrows
annotation(map_long,'arrow',[0.658888888888889 0.596666666666667],...
    [0.64875 0.665]);
annotation(map_long,'arrow',[0.671111111111111 0.586666666666667],...
    [0.6175 0.51125]);
annotation(map_long,'textbox',...
    [0.657777777777778 0.618750000000001 0.0922222222222222 0.0402499999999999],...
    'String',{'Phugoid'},...
    'FitBoxToText','off');

% annotate zoom lines:
annotation(map_long,'line',[0.78 0.898888888888889],[0.77125 0.5275],...
    'LineStyle','--');
annotation(map_long,'line',[0.896666666666667 0.781111111111111],...
    [0.47875 0.4025],...
    'LineStyle','--');


% save plot
filename = 'Outputs/Ch5_OpenLoop/PZ_map_long';
print(map_long, '-depsc2', '-painters', filename)  % looks better for some reason...
% saveas(map_long, filename, 'epsc')




%%%%%%%% Lateral PLots
map_lat = figure("Name", "PZ_lat",...
                  "Position", fig_pos,...
                  'Visible', show_plots); 

% base pz map
pz_lat = pzplot(SS_lat);
base_ax = gca;

% title and grid formatting
p = getoptions(pz_lat);
p.Title.FontSize = 16;
p.Title.String = "Pole-Zero Map -- Lateral Modes";
p.Grid = 'on';
p.GridColor = [0.5, 0.5, 0.5];
setoptions(pz_lat, p)

% increase visibility of the markers
set(base_ax.Children(1).Children, 'MarkerSize', 10)
set(base_ax.Children(1).Children, 'LineWidth', 2)


% Ap Roll Arrow
annotation(map_lat,'textbox',...
    [0.161111111111111 0.54875 0.122222222222222 0.0765000000000003],...
    'String',{'Aperiodic Roll'},...
    'FitBoxToText','off');
annotation(map_lat,'arrow',[0.183333333333333 0.168888888888889],...
    [0.54875 0.52]);

% Dutch Roll Arrows
annotation(map_lat,'textbox',...
    [0.623333333333333 0.795 0.136666666666667 0.0415],'String',{'Dutch Roll'},...
    'FitBoxToText','off');
annotation(map_lat,'arrow',[0.76 0.803333333333333],[0.819 0.83625]);
annotation(map_lat,'arrow',[0.751111111111111 0.812222222222222],...
    [0.794 0.18625]);


% create new axes to zoom around Ap Roll
zoom_ax = axes('position',[.35 .3 .35 .4]);
pz_lat_zoom = pzplot(SS_lat);

% size, title, ticks formatting
p = getoptions(pz_lat_zoom);
p.Title.String = "Zoom at Spiral";
p.XLabel.FontSize = 8;
p.YLabel.FontSize = 8;
p.Xlim = {[-0.02, 0.02]};
p.Ylim = {[-0.05, 0.05]};
p.TickLabel.FontSize = 8;
setoptions(pz_lat_zoom, p)

% special s-grid for it not to look like a mess
sgrid([0.8, 0.5, 0.2], [0.01, 0.025, 0.06])

% again, increase marker size
set(zoom_ax.Children(1).Children, 'MarkerSize', 10)
set(zoom_ax.Children(1).Children, 'LineWidth', 2)

% whatever this does?
axis tight


% Spiral Arrow
annotation(map_lat,'textbox',...
    [0.552222222222222 0.51 0.0833333333333334 0.0414999999999998],...
    'String','Spiral',...
    'FitBoxToText','off');
annotation(map_lat,'arrow',[0.551111111111111 0.487777777777778],...
    [0.52275 0.49125]);

% zoom lines
annotation(map_lat,'line',[0.7 0.902222222222222],[0.67525 0.525],...
    'LineStyle','--');
annotation(map_lat,'line',[0.7 0.9],[0.3025 0.48375],'LineStyle','--');

% save plot
filename = 'Outputs/Ch5_OpenLoop/PZ_map_lat';
print(map_lat, '-depsc2', '-painters', filename)  % looks better for some reason...
% saveas(map_lat, filename, 'epsc')


