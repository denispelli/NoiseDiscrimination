% Auxillary file for e04wd_demo.m, providing the objective function (i.e.
% the function to be minimized).

% NAG Copyright 2009.
function [mode, objf, grad, user] = e04wd_objfun(mode, n, x, grad, nstate, user)

% Set use_gradients to 0 if you don't want to supply
% gradients. Then e04wd needs more function evaluations.
use_gradients = user{1}(1);

objf = 100*(x(2)-x(1)*x(1))*(x(2)-x(1)*x(1)) + (1 - x(1))*(1 - x(1));

if mode == 1 || mode == 2

    % Derivatives: grad(i) is the derivative with
    % respect to x(i), for i = 1, 2.

    if use_gradients == 1
        grad(1) = 2*(1-200*x(2))*x(1) + 400*x(1)*x(1)*x(1) - 2;
        grad(2) = 200*(x(2) - x(1)*x(1));
    end

end

% Show progress on the graph plot, if required.
if (user{1}(2) == 1)
    axes = user{2};
    oldx(1) = user{3}(1);
    oldx(2) = user{3}(2);

    % Draw a green line from previous to current point.
    line([oldx(1),x(1)], [oldx(2),x(2)], 'Color', [0 1 0], 'Linewidth', 2);

    % Change the previous plotted point to blue.
    plot(axes, oldx(1), oldx(2), 'b*', 'Linewidth', 2, 'MarkerSize', 8);

    % Plot the new point in red.
    plot(axes, x(1), x(2), 'r*', 'Linewidth', 2, 'MarkerSize', 8);

    % Save the latest point in the user array for use next time around.
    user{3}(1) = x(1);
    user{3}(2) = x(2);

    % Display the current number of objective function evaluations
    frx = [-0.75 1.4 1.4 -0.75];
    fry = [2 2 1.6 1.6];
    fill(frx, fry, 'w');
    t = sprintf('Number of evaluations of objective function = %d', user{3}(3));
    text(-0.7, 1.9, t, 'FontSize', 10);
    t = sprintf('Current point is (%5.2f, %5.2f)', x(1), x(2));
    text(-0.7, 1.8, t, 'FontSize', 10);
    t = sprintf('Objective function at this point = %15.10f', objf);
    text(-0.7, 1.7, t, 'FontSize', 10);

    % Set savemovie = 1 to create a bunch of PNG files with a sequence
    % of movie frames.
    savemovie = 0;
    if savemovie == 1
        FF = getframe(gcf);
        [FX,Map] = frame2im(FF);
        filename = sprintf('frame%d.png', user{3}(3));
        imwrite(FX,filename,'png');
    end

    % Slow down the animation.
    pause(user{1}(3));

    % One more function evaluation has been made.
    user{3}(3) = user{3}(3) + 1;
end
