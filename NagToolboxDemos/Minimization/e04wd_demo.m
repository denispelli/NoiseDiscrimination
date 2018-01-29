% This function demonstrates the use of the e04wd routine from the NAG 
% toolbox for finding the local minimum of a function - in this case, 
% Rosenbrock's Function:
%   F = 100*(x2-x1^2)^2 + (1-x1)^2
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlab.asp#e04minimization
%
% Written by Mick Pont (mick@nag.co.uk).  April 2007.

% This function uses these other files:
% e04wd_objfun.m
% confun.m
% my_button_handler.m

% NAG Copyright 2009.

function e04wd_demo(use_grads, pause_time, rolling)

if nargin < 3

    % rolling = 1 means use the full screen for plots (good for
    % rolling demo) and don't wait for key press before starting.
    rolling = 0;

    if nargin < 2

        if nargin < 1
            use_grads = 1;
        end

        if use_grads == 0
            pause_time = 0.01;
        else
            pause_time = 1;
        end

    end

end

global usederivs;
usederivs = use_grads;
global mypause;
mypause = pause_time;

% There are no linear or nonlinear constraints.
a = [];
istate = zeros(2, 1, 'int32');
istate = nag_int(istate);
ccon = [];
cjac = [];
clamda = zeros(2,1);
hess = zeros(2);

% Bounds on the variables.
bl = [-10; -10];
bu = [10; 10];

% Initial guess at solution.
x = [-2.75; 1.3];

% Create data for contour plot of Rosenbrock's function.
px = -3 : 0.05 : 1.5;
py = -1 : 0.05 : 3;
pf = zeros(length(py),length(px));

% User structure to pass to objective function.
% user {1}(1) use gradients? 1 = yes
% user {1}(2) plot progress? 1 = yes
% user {1}(3) pause time in seconds after each point is plotted
% user {2} axes of the plotting figure
% user {3}(1) x coordinate of the previous plotted point
% user {3}(2) y coordinate of the previous plotted point
% user {3}(3) number of calls to this evaluation function

global user;
user = cell(3,1);

for i = 1:length(py)

    for j = 1:length(px)
        xx = [px(j); py(i)];
        ggrad=[0; 0];
        nstate = nag_int(0);
        user{1} = zeros(3,1);
        user{3} = zeros(3,1);
        [mode, pf(i,j)] = e04wd_objfun(0, 2, xx, ggrad, nstate, user);
    end

end

scrsz = get(0, 'ScreenSize');

if rolling
    figure('Name', 'Minimum of Rosenbrock''s Function using NAG Toolbox for MATLAB', ...
        'Position', [0 -35 scrsz(3)*1.0 scrsz(4)*1.0], ...
        'NumberTitle', 'off');
else
    figure('Name', 'Minimum of Rosenbrock''s Function using NAG Toolbox for MATLAB', ...
        'Position', [scrsz(1)+100 scrsz(2)+20 scrsz(3)*0.8 scrsz(4)*0.8], ...
        'NumberTitle', 'off');
end
axes = gca;

% Heights of contours required are in vector v.
v = [5 30 100 220 400 700 1200 2000 3000 4500 6500 9000];
[C,h] = contour(axes, px, py, pf, v, 'Linewidth', 1);
set(h, 'ShowText', 'on', 'TextStep', get(h,'LevelStep')*2);
colormap('prism');
hold on;

% Plot the true minimum with a green circle.
plot(axes, 1, 1, 'go', 'Linewidth', 2, 'MarkerSize', 16);

if use_grads == 1
    title('NAG routine e04wd: minimizing Rosenbrock''s Function (gradients provided)', 'FontSize', 14);
else
    title('NAG routine e04wd: minimizing Rosenbrock''s Function (gradients not provided)', 'FontSize', 14);
end

% Plot the starting point with a blue circle.
plot(axes, x(1), x(2), 'bo', 'Linewidth', 2, 'MarkerSize', 16);

% Add a legend.
frx = [-2.85 -1.15 -1.15 -2.85];
fry = [-0.35 -0.35 -0.975 -0.975];
fill(frx, fry, 'w');
%text('Interpreter', 'latex',...
%     'String', '$f(x,y) = 100(y-x^2)^2 + (1-x)^2$',...
%     'Position', [-2.75, -0.45], 'FontSize', 12);
text(-2.75, -0.45, 'f(x,y) = 100(y-x^2)^2 + (1-x)^2', 'FontSize', 12);
plot(axes, -2.75, -0.6, 'bo', 'Linewidth', 2, 'MarkerSize', 10);
text(-2.65, -0.6, 'Starting point', 'FontSize', 10);
plot(axes, -2.75, -0.7, 'r*', 'Linewidth', 2, 'MarkerSize', 8);
text(-2.65, -0.7, 'Current evaluation point', 'FontSize', 10);
plot(axes, -2.75, -0.8, 'b*', 'Linewidth', 2, 'MarkerSize', 8);
text(-2.65, -0.8, 'Previous evaluation points', 'FontSize', 10);
plot(axes, -2.75, -0.9, 'go', 'Linewidth', 2, 'MarkerSize', 10);
text(-2.65, -0.9, 'Target minimum', 'FontSize', 10);
% Draw a green line from previous to current point
line([-2.0,-1.8], [-0.6,-0.6], 'Color', [0 1 0], 'Linewidth', 2);
text(-1.75, -0.6, 'Search path', 'FontSize', 10);

if rolling ~= 1
    % Create a button and wait for it to be pressed before continuing.
    hbutton = uicontrol('Position', [10 20 140 40], ...
        'String', 'Start', 'Callback', @my_button_handler);
    ud = uicontrol('Style', 'popup', 'String', 'Use derivatives|No derivatives', ...
        'Position', [10 60 110 30], 'TooltipString', ...
        'Decides whether e04wd should use analytical derivatives', ...
        'Value', 1, 'Callback', @usederivatives);
    usederivatives(ud, 0);
    hspeed = uicontrol('Style', 'popup', 'String', 'Slow|Medium|Fast', ...
        'Position', [10 90 110 30], 'TooltipString', ...
        'Chooses the speed of animation', ...
        'Value', 1, 'Callback', @animspeed);

    uiwait(gcf); % Wait until "Start" button is pressed.

    % Disable other buttons once animation is underway.
    set(hspeed, 'Enable', 'Off');
    set(ud, 'Enable', 'Off');
else
    % Create a pause button.
    hbutton = uicontrol('Position', [10 20 140 40], ...
        'String', 'Pause', 'Callback', @my_button_handler);
end



frx = [-0.75 1.4 1.4 -0.75];
fry = [2 2 1.6 1.6];
fill(frx, fry, 'w');

user{1}(1) = usederivs;
user{1}(2) = 1;
user{1}(3) = mypause;
user{2} = axes;
user{3}(1) = x(1);
user{3}(2) = x(2);
user{3}(3) = 0;

% Initialize the minimization routine e04wd using e04wc.
[iw, rw] = e04wc();

% Solve the problem using NAG routine e04wd.
[majits, istateOut, cconOut, cjacOut, clamdaOut, objf, grad, hessOut, xOut, iwOut, rwOut, user] = ...
    e04wd(a, bl, bu, 'confun', 'e04wd_objfun', istate, ccon, cjac, clamda, hess, x, iw, rw, 'user', user);

% Show the results.
fill(frx, fry, 'w');
t = sprintf('Number of evaluations of objective function = %d', user{3}(3));
text(-0.7, 1.9, t, 'FontSize', 10);
t = sprintf('Minimum point is at (%5.2f, %5.2f)', xOut(1), xOut(2));
text(-0.7, 1.8, t, 'FontSize', 10);
t = sprintf('Objective function at minimum = %15.10f', objf);
text(-0.7, 1.7, t, 'FontSize', 10);

set(hbutton, 'String', 'Close');

end

function usederivatives(hObject, eventData)
global usederivs;
val = get(hObject, 'Value');
if val == 1
    usederivs = 1;
    title('NAG routine e04wd: minimizing Rosenbrock''s Function (gradients provided)', 'FontSize', 14);
elseif val == 2
    usederivs = 0;
    title('NAG routine e04wd: minimizing Rosenbrock''s Function (gradients not provided)', 'FontSize', 14);
end
end

function animspeed(hObject, eventData)
global mypause;
val = get(hObject, 'Value');
if val == 1
    mypause = 0.5;
elseif val == 2
    mypause = 0.125;
else
    mypause = 0.01;
end
end
