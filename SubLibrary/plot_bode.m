% plot the above 
bodes = figure("Name", "BodePlots",...
               "Position", [500, 200, 600, 400],...
               "Visible", show_plots);
hold on
    % no servo
    b_noservo = bodeplot(-q_cmd_theta);
    setoptions(b_noservo, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    grid on
   
    % correct servo in loop
    b_conv = bodeplot(-q_cmd_servo_theta);
    setoptions(b_conv, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "--";
    grid on

    % bad servo outside loop
    b_sim = bodeplot(-q_cmd_convservo_theta);
    setoptions(b_sim, 'MagVisible','off');
    ax = gca;
    ax.Children(1).Children.LineWidth = 2;
    ax.Children(1).Children.LineStyle = "-.";
hold off

ax = gca;
ax.Children(1).Children.LineWidth = 2;
bodes.Children(3).XLabel.FontSize = 14;
bodes.Children(3).YLabel.FontSize = 14;
grid on

title("Closed System Phase Plot -- PIO", "FontSize", 15)

legend(["No Servo", ...
        "Servo in Loop",...
        "Servo in Front"], "Location", "NorthEast", "FontSize", 12)
