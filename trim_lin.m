clear all

load('fc');

for fc_idx = 1:length(fc.name)
    fc_setting.h = fc.con(fc_idx, 1);
    fc_setting.v = fc.con(fc_idx, 2);
    fc_setting.Fiflag = fc.con(fc_idx, 3);
    
    
    %run FindF16Dynamics_noninteractive.m
    
    SS_long = ""
    SS_lat = ""
    
    filename = strcat("SS_", fc.name{fc_idx});
    save(filename, 'SS_long', 'SS_lat')
end




% 