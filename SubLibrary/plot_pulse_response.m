% get step respose information
Step    = stepinfo(q_cmd);
q_ratio = (Step.Overshoot / 100) + 1;
q_steady_state = evalfr(q_cmd, 0); % final value theorem

Step  = stepinfo(q_cmd_servo);
q_ratio_servo = (Step.Overshoot / 100) + 1;
q_steady_state_servo = evalfr(q_cmd_servo, 0); % final value theorem




% Calculate responses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmax = 3;
dt = 0.001;
t = 0:dt:tmax; % time vector

% input function (step up and back down)
u  = @(t) heaviside(t - tmax/6) - heaviside(t - 4*tmax/6);

% lsim the responses for no servo and servo (subscript s)
y  = lsim(q_cmd, u(t), t);
ys = lsim(q_cmd_servo, u(t), t);

q_u = y;
theta_u = cumsum(y*dt); % lazy integration for theta
qs_u = ys;
thetas_u = cumsum(ys*dt);

% calculate drop back at 4*tmax/6 wrt to steady state
DB = (interp1(t, theta_u, 4*tmax/6)) - theta_u(end);
DB_servo = (interp1(t, thetas_u, 4*tmax/6)) - thetas_u(end);

% get ratio
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
    plot(t, -q_u, "LineWidth", 1.5, "LineStyle", "-", "DisplayName", "No Servo")
    plot(t, -qs_u, "LineWidth", 1.5, "LineStyle", "--", "DisplayName", "Servo in Loop")
    plot(t, -input_u, "LineWidth", 1.5, "LineStyle", "-.", "DisplayName", "Reference")
hold off
legend("Location", "NorthEast", "FontSize", 11)
ylabel("Pitch Rate q [rad/s]")
title("Pulse Reponse of q-system", "FontSize", 16)
grid()

% theta plot
subplot(212)
hold on
    plot(t, -theta_u, "LineWidth", 1.5, "LineStyle", "-", "DisplayName", "No Servo")
    plot(t, -thetas_u, "LineWidth", 1.5, "LineStyle", "--", "DisplayName", "Servo in Loop")
    plot(t, -input_int_u, "LineWidth", 1.5, "LineStyle", "-.", "DisplayName", "Reference")
hold off
legend("Location", "NorthWest", "FontSize", 11)
ylabel("Pitch Angle \theta [rad]")
xlabel("Time t [sec]")
grid()