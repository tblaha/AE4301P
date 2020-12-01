function [slope,frequency_cross] = phase_rate_check(H)

s = tf('s');
%magnitude + phase for each frequencies in vector w_out
[mag, phase, wout] = bode(H);
phase = squeeze(phase);
%find index where we cross -180 degr. (gives the index before the crossing)
idx = find((phase(1:end-1)+10^-6+180).*(phase(2:end)+10^-6+180) <= 0);

if isempty(idx)
    warning('No crossing near -180 phase found')
    slope = nan;
    frequency_cross = nan;
    return
end

%find frequency around -180 degr. over the first crossing
frequency_cross = interp1(phase(idx:idx+1), wout(idx:idx+1), -180);  

%slope near -180 [degr/Hz]
slope = diff(phase(idx:idx+1)/(diff(idx:idx+1)))/2*pi;

end

