% get step respose information
Step    = stepinfo(tf_OL_el2q);
q_ratio_OL = (Step.Overshoot / 100) + 1;
q_steady_state_OL = evalfr(tf_OL_el2q, 0); % final value theorem

Step    = stepinfo(q_cmd);
q_ratio = (Step.Overshoot / 100) + 1;
q_steady_state = evalfr(q_cmd, 0); % final value theorem

Step  = stepinfo(q_cmd_servo);
q_ratio_servo = (Step.Overshoot / 100) + 1;
q_steady_state_servo = evalfr(q_cmd_servo, 0); % final value theorem



tf_OL_el2q = tf_OL_el2q * q_steady_state/q_steady_state_OL;



% Calculate responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmax = 4.5;
dt = 0.001;
t = 0:dt:tmax; % time vector

% input function (step up and back down)
u  = @(t) heaviside(t - tmax/9) - heaviside(t - 5*tmax/9);

% lsim the responses for no servo and servo (subscript s)
yOL = lsim(tf_OL_el2q, u(t), t);
y   = lsim(q_cmd, u(t), t);
ys  = lsim(q_cmd_servo, u(t), t);

% get q and theta responses
qOL_u = yOL;
thetaOL_u = cumsum(yOL*dt); % lazy integration for theta
q_u = y;
theta_u = cumsum(y*dt);
qs_u = ys;
thetas_u = cumsum(ys*dt);

% calculate drop back at 4*tmax/6 wrt to steady state
DB_OL = (interp1(t, thetaOL_u, 5*tmax/9)) - thetaOL_u(end);
DB = (interp1(t, theta_u, 5*tmax/9)) - theta_u(end);
DB_servo = (interp1(t, thetas_u, 5*tmax/9)) - thetas_u(end);

% get ratio
DB_over_qss_OL = DB_OL/q_steady_state_OL;
DB_over_qss = DB/q_steady_state;
DB_over_qss_servo = DB_servo/q_steady_state_servo;

% again: "verify" at least the no-servo case using the equation from 6.3.6.
DB_over_qss_veri = T_theta2 - ( (2 * Zeta_long(1)) / (Omega_long(1)) );


disp("Ch6_q_Command: 'Verify' Gibson 1 (DB)...")
DB_over_qss
DB_over_qss_veri


% plot the responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% scale the inputs for nicer looking plots
input_u = u(t) * q_steady_state;
input_int_u = cumsum(u(t)*dt) * q_steady_state;

% figure handle
step_up_down = figure("Name", "Step up-down",...
                      "Position", [700 200 600 600],...
                       "Visible", show_plots);

% q plot
subplot(211)
hold on
    plot(t, -qOL_u, "LineWidth", 1.5, "LineStyle", "-", "DisplayName", "Open Loop")
    plot(t, -q_u, "LineWidth", 1.5, "LineStyle", "--", "DisplayName", "Pole Placed")
    plot(t, -qs_u, "LineWidth", 1.5, "LineStyle", "-.", "DisplayName", "Pole Placed + Servo")
    plot(t, -input_u, "LineWidth", 0.5, "LineStyle", "-", "DisplayName", "Reference")
hold off
legend("Location", "NorthEast", "FontSize", 9)
ylabel("Pitch Rate q [rad/s]")
title("Pulse Reponse of q-system", "FontSize", 16)
grid()
% ylim([-0.2, 0.35])

% theta plot
subplot(212)
hold on
    plot(t, -thetaOL_u, "LineWidth", 1.5, "LineStyle", "-", "DisplayName", "Open Loop")
    plot(t, -theta_u, "LineWidth", 1.5, "LineStyle", "--", "DisplayName", "Pole Placed")
    plot(t, -theta_u, "LineWidth", 1.5, "LineStyle", "-.", "DisplayName", "Pole Placed + Servo")
    plot(t, -input_int_u, "LineWidth", 0.5, "LineStyle", "-", "DisplayName", "Reference")
hold off
legend("Location", "NorthWest", "FontSize", 9)
ylabel("Pitch Angle \theta [rad]")
xlabel("Time t [sec]")
grid()