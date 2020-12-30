function [slope,frequency_cross] = phase_rate_check(H)

% magnitude + phase for each frequencies in vector w_out
[~, phase, wout] = bode(H, logspace(-1, 2, 1001));
phase = squeeze(phase); % reduce to the only non-singleton dimension

% find index where we cross -180 degr
% this will give the index just before the crossing
idx = find((phase(1:end-1)+1e-6+180).*(phase(2:end)+1e-6+180) <= 0);

% warn, if we cannot find a crossing
if isempty(idx)
    warning('No crossing through -180 phase found')
    slope = nan;
    frequency_cross = nan;
    return
end

%find frequency around -180 degr. over the first crossing
frequency_cross = interp1(phase(idx:idx+1), wout(idx:idx+1), -180) /(2*pi);

%slope near -180 [degr/Hz]
slope = diff(phase(idx:idx+1)) / (diff(wout(idx:idx+1)) / (2*pi));

end

