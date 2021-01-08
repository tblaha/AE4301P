% we want to know the response to this as well and we decide to model the
% gust as an initial condition and then (pilot-)input=0
% 
% long story short: to simulate starting with these initial conditions, the
% TFs are of no use, we need SS models. Also the state space model from
% PlacePoles.m is of no use as it doesn't yet have the prefiltering
%
% so: get a nice SS model from simulink
sys_sim = linmod('q_loop'); % no servo dynamics, 
                            % see PlacePoles.m for verification
sim_ss  = ss(sys_sim.a, sys_sim.b, sys_sim.c, sys_sim.d);

% states of sys_sim:   [alpha, q, some-internal-LLfilt-state-whatever]
% initial conditions: [a_ind, 0, 0]
% outputs of sys_sim:  [alpha [rad], q [rad/s], d_e [deg]]
% input of sys_sim: (d_e_pilot [deg])

% lsim both the simulink-derived SS models for both servo and no-servo
% starting from the gust, modelled as initial condition
N = 1001;
u = zeros(1, N);       % 0 input
t = linspace(0, 2, N); % linear time vector
[yOL,t,x] = lsim(ss_OL       , u, t, [a_ind/180*pi, 0]');
[y,t,x]   = lsim(sim_ss      , u, t, [a_ind, 0, 0]');
[ys,t,x]  = lsim(sim_servo_ss, u, t, [a_ind, 0, 0, 0]'); % we have one more 
                                                         % state because of 
                                                         % an internal state
                                                         % within the pre-
                                                         % filter

% get maximum elevator deflections
[~, i] = max(abs(y(:, 3) + trim_s(3))); % biggest absolute, including trim
d_e_max = y(i, 3) + trim_s(3);
[~, i] = max(abs(ys(:, 3) + trim_s(3))); % biggest absolute, including trim
d_e_max_servo = ys(i, 3) + trim_s(3);

% plot the responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% together in one plot and DO NOT FORGET TO ADD TRIM CONDITIONS 
GR = figure("Name", "Gust Response",...
           "Position", [500, 200, 700, 700],...
           "Visible", show_plots);

% alpha plot:
subplot(311)
hold on
    plot(t, yOL(:, 1)+trim_s(1), "LineWidth", 2)
    plot(t, y(:, 1)+trim_s(1) , "LineWidth", 2, "LineStyle", "--")
    plot(t, ys(:, 1)+trim_s(1), "LineWidth", 2, "LineStyle", "-.")
hold off
legend(["Open Loop", "Pole Placed", "Pole Placed + Servo"], "FontSize", 10)
grid on
ylabel("\alpha [rad]", "Fontsize", 14)
ax = gca(GR);
ax.Title.String = "Gust Response of system. u=0, \Delta\alpha_{gust}=+"...
                  +string(round(a_ind, 3))+" rad";
ax.Title.FontSize = 14;

% q plot:
subplot(312)
hold on
    plot(t, yOL(:, 2)+trim_s(2), "LineWidth", 2)
    plot(t, y(:, 2)+trim_s(2), "LineWidth", 2, "LineStyle", "--")
    plot(t, ys(:, 2)+trim_s(2), "LineWidth", 2, "LineStyle", "-.")
hold off
legend(["Open Loop", "Pole Placed", "Pole Placed + Servo"], "FontSize", 10, "Location", "SouthEast")
grid on
ylabel("q [rad/s]", "Fontsize", 14)

% d_e (elevator deflection) plot
subplot(313)
hold on
    plot(t, ones(N, 1).*trim_s(3), "LineWidth", 2)
    plot(t, y(:, 3)+trim_s(3), "LineWidth", 2, "LineStyle", "--")
    plot(t, ys(:, 3)+trim_s(3), "LineWidth", 2, "LineStyle", "-.")
hold off
legend(["Open Loop", "Pole Placed", "Pole Placed + Servo"], "FontSize", 10)
grid on
ylabel("Elevator \delta_e [\circ]", "Fontsize", 14)

xlabel("Time t [sec]", "FontSize", 14)
