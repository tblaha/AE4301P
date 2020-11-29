function char_tab = mchar(SS_long, SS_lat)

    %%%%%% longidutinal

    [omega_long, zeta_long, p_long] = damp(SS_long);
    tau_long = -1./real(p_long);
    T2_long  = log(2)*tau_long;
    
    %%%%%% lateral

    [omega_lat, zeta_lat, p_lat] = damp(SS_lat);
    tau_lat = -1./real(p_lat);
    T2_lat  = log(2)*tau_lat;
    
    %%%%% build output table
    % with a table we have all info in a single object (char_tab) and we 
    % can access elements like this:
    %
    %%% show entire table:
    % char_tab
    %
    %%% example to get a scalar
    % char_tab.NaturalFrequency("Phugoid");

    %%% example to get a column
    % char_tab.DampingRatio;

    % names of the modes (in order)
    long_modes = ["Phugoid", "Phugoid Conjugate", ...
                  "Short Period", "Short Period Conjugate"
                  ];
    lat_modes = ["Spiral", "Aperiodic Roll", "Dutch Roll", "Dutch Roll Conjugate"];

    % variable names, units, symbols in order
    var_names = ["NaturalFrequency", "DampingRatio", ...
                        "TimeConstant", "HalfTime", "Pole"];
    var_units = {'rad s^-1', '', 's', 's', 's^-1'};
    var_symbols = ["\omega_n", "\zeta", "\tau", "T_2", "p"];

    % make table
    char_tab = table([omega_long; omega_lat],...
                     [zeta_long; zeta_lat],...
                     [tau_long; tau_lat],...
                     [T2_long; T2_lat],...
                     [p_long; p_lat],...
                     'VariableNames', var_names,...
                     'RowNames', [long_modes, lat_modes]);

    % set additional properties
    char_tab.Properties.VariableUnits = var_units;
    char_tab = addprop(char_tab, 'LaTeXSymbols', 'variable');
    char_tab.Properties.CustomProperties.LaTeXSymbols = var_symbols;


end