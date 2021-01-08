% plot the above 
bodes = figure("Name", "BodePlots",...
               "Position", [500, 200, 600, 400],...
               "Visible", show_plots);
hold on
    % open loop
    b_sim = bodeplot(-tf_OL_el2theta);
    setoptions(b_sim, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "-";
    
    % no servo
    b_noservo = bodeplot(-q_cmd_theta);
    setoptions(b_noservo, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "--";
    grid on
   
    % correct servo in loop
    b_servo = bodeplot(-q_cmd_servo_theta);
    setoptions(b_servo, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "-.";
    grid on
hold off

ax = gca;
ax.Children(1).Children.LineWidth = 2;
bodes.Children(3).XLabel.FontSize = 14;
bodes.Children(3).YLabel.FontSize = 14;
grid on

title("Closed System Phase Plot -- PIO", "FontSize", 15)

legend(["Open Loop System", ...
        "Pole Placed", ...
        "Pole Placed + Servo"], "Location", "SouthWest", "FontSize", 10)
