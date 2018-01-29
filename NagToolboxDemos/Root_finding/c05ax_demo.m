% This function demonstrates the use of the c05ax routine from the NAG
% toolbox to find the root of a function.  The functional form depends on
% the value for fchoice (1 = quadratic; 2 = exponential).
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart2.asp#c05findingroot
%
% Written by Jeremy Walton (jeremyw@nag.co.uk).  June 2007.

% NAG Copyright 2009.

function c05ax_demo
% Ask the user which function we're going to use.
[fchoice, ok] = listdlg('PromptString', 'Select a function:', ...
    'SelectionMode', 'single', ...
    'ListSize', [220 100], ...
    'ListString', ...
    {'25x^2 - 10x + 1';
    'x - exp(-x)';
    });

% Set parameters for size and position of plot.
left = 100;
bottom = 200;
width = 700;
height = 600;
fontSize = 11.5;

% Open the figure, set the properties of the plot, and set the title.
figure('Name', 'Root finding using the NAG Toolbox', ...
    'Position', [left, bottom, width, height],...
    'NumberTitle', 'off');
axes = gca;
set(gca, 'YGrid', 'On')
set(gca, 'FontSize', fontSize);
xlabel('x');
ylabel('y', 'Rotation', 0);
hold on;
title('Using NAG routine c05ax for root finding', 'FontSize', 14);

% Set up the function, and the limits of the plot.
if(fchoice == 1)
    myfun = @(x)25*x*x - 10*x + 1;
    axmax = 1.1;
    axmin = 0.0;
    aymax = 16.5;
    aymin = 0.0;
else
    myfun = @(x)x - exp(-x);
    axmax = 5.5;
    axmin = 0.0;
    aymax = 6.5;
    aymin = -1.5;
end

% Draw the axes.
axis([axmin axmax aymin aymax]);

% Draw the curve.
nx = 50;
dx = (axmax-axmin)/nx;
x = [axmin : dx : axmax];
for i = 1 : length(x)
    y(i) = myfun(x(i));
end
line(x, y, 'Color', 'blue', 'Linewidth', 2);

% Set the starting point of the search for the root.
if(fchoice == 1)
    xstart = 1.0;
else
    xstart = 5.0;
end
fstart = myfun(xstart);
xx = xstart;
fx = fstart;

% Create a button and wait for it to be pressed before continuing
hbutton = uicontrol('Position', [10 10 100 25], ...
    'String', 'Start', 'Callback', @my_button_handler);
uiwait(gcf); % Wait until "Start" button is pressed.

% Set the parameters for the NAG routine.
tol = 0.00001;
ir = nag_int(0);
c = zeros(26, 1);
ind = nag_int(1);

% Iterate until the root is found.
count = 0;
while (ind ~= nag_int(0))
    [xx, c, ind, ifail] = c05ax(xx, fx, tol, ir, c, ind);
    fx = myfun(xx);
    count = count + 1;

    % Display intermediate point.
    plot(axes, xx, fx, 'or', 'MarkerFaceColor', [1,0,0], 'MarkerSize', 8);

    pause(0.5);
end

% Display the starting & finishing points.
plot(axes, xstart, fstart, 'og', 'MarkerFaceColor', [0,1,0], 'MarkerSize', 8);
plot(axes, xx, fx, 'oy', 'MarkerFaceColor', [1,1,0], 'MarkerSize', 8);

% Prepare to display text box.  Set parameters, depending on which function
% we're using..
if(fchoice == 1)
    xmin = 0.02;
    xmax = 0.745;
    xshift = 0.02;
    ymin = 8.2;
    ymax = 13.8;
    yshift = 0.8;
else
    xmin = 1.7;
    xmax = 5.4;
    xshift = 0.1;
    ymin = -1.2;
    ymax = 1.4;
    yshift = 0.4;
end

% Draw the text box.
frx = [xmin xmax xmax xmin];
fry = [ymin ymin ymax ymax];
fill(frx, fry, 'w');

% Show the function.
xoff = xmin+xshift;
if(fchoice == 1)
    yoff = ymax-0.8*yshift;
    text('Interpreter', 'latex',...
        'String', '$y = 25x^2 - 10x + 1$',...
        'Position', [xoff, yoff], 'FontSize', 1.3*fontSize);
    yoff = yoff - 1.3*yshift;
else
    yoff = ymax-0.6*yshift;
    text('Interpreter', 'latex',...
        'String', '$y = x - e^{-x}$',...
        'Position', [xoff, yoff], 'FontSize', 1.5*fontSize);
    yoff = yoff - 1.2*yshift;
end

if ifail == 0
    % Show the results.
    t = sprintf('Root found at (x, y) = (%5.2f, %5.2g),', xx, fx);
    text(xoff, yoff, t, 'FontSize', fontSize);
    yoff = yoff-yshift;
    t = sprintf('after %d function evaluations.', count);
    text(xoff, yoff, t, 'FontSize', fontSize);
    xoff = xoff + xshift;
    yoff = yoff-yshift;
    plot(xoff, yoff, 'og', 'MarkerFaceColor', [0,1,0], 'MarkerSize', 8);
    text(xoff+2*xshift, yoff, 'Starting point', 'FontSize', fontSize);
    yoff = yoff-yshift;
    plot(xoff, yoff, 'or', 'MarkerFaceColor', [1,0,0], 'MarkerSize', 8);
    text(xoff+2*xshift, yoff, 'Intermediate points', 'FontSize', fontSize);
    yoff = yoff-yshift;
    plot(xoff, yoff, 'oy', 'MarkerFaceColor', [1,1,0], 'MarkerSize', 8);
    text(xoff+2*xshift, yoff, 'Root', 'FontSize', fontSize);
else
    t = sprintf('c05ax failed with ifail = %3d', ifail);
    text(xoff, yoff, t, 'FontSize', fontSize);
end

set(hbutton, 'String', 'Close');

end

function my_button_handler(hObject, eventData)
label = get(hObject, 'String');
if strcmp(label, 'Close') || strcmp(label, 'Quit')
    close;
elseif strcmp(label, 'Pause')
    set(hObject, 'String', 'Resume');
    uiwait;
elseif strcmp(label, 'Start') || strcmp(label, 'Resume')
    set(hObject, 'String', 'Pause');
    uiresume;
elseif strcmp(label, 'Next')
    uiresume;
end
end
