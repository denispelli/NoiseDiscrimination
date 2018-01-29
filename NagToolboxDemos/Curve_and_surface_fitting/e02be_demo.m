% This function demonstrates the use of the e02be & e02bb routines from the 
% NAG toolbox for fitting a cubic spline through a set of points. 
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart2.asp#e02fittingsetpoints
%
% Written by Jeremy Walton (jeremyw@nag.co.uk).  June 2007.

% NAG Copyright 2009.

function e02be_demo
% Here's the (x,y) data to be fitted, followed by the 
% weights for each point (set these to 1 if all points
% are equally important).  
x = [0.5; 1; 1.5; 2; 2.5; 3; 4; 4.5; 5; 5.5; 6; 7; 7.5];
y = [-0.372; 0.431; 1.69; 2.11; 3.1; 4.23; 4.35;
     4.81; 4.61; 4.79; 5.23; 6.35; 7.19];
w = [2; 1.5; 1; 3; 1; 0.5; 1; 2; 2.5; 1; 3; 1; 2];

% Calculate work array lengths, according to the e02be documentation.
m = length(x);
nest = m+4;
lwrk = 4*m + 16*nest + 41;

% Now initialize some parameters required by the NAG routine.
start = 'C';
n = nag_int(0);
lamda = zeros(nest,1);
wrk = zeros(lwrk, 1);
iwrk = zeros(nest, 1, 'int32');
iwrk = nag_int(iwrk);

% Plot the initial data.
figure('Name', 'Fitting a cubic spline using the NAG Toolbox', ...
    'Position', [100, 200, 700, 600], ...
    'NumberTitle', 'off');
axes = gca;
set(gca, 'FontSize', 12);
xlabel('x');
ylabel('y', 'Rotation', 0);
hold on;
title('Using NAG routines e02be, e02bb for fitting a cubic spline', 'FontSize', 14);
axis([0.3 7.8 -0.8 7.5]);

% Set up the points at which the spline is to be evaluated.
px = x(1) : 0.01 : x(m);
pf = zeros(size(px));

% Set the smoothness parameter and call the NAG routine to 
% compute the cubic spline approximation to the data.
s = 10000.0;
[nOut, lamdaOut, c, fp, wrkOut, iwrkOut, ifail] = ...
    e02be(start, x, y, w, s, n, lamda, wrk, iwrk);
for i = 1 : length(px)
  [pf(i), ifail] = e02bb(lamdaOut, c, px(i), 'ncap7', nOut);
end
plot(px, pf, 'Color', [.8 0 0], 'Linewidth', 2);

% Now do it again, for a couple of other smoothness values.
s = 0.5;
[nOut, lamdaOut, c, fp, wrkOut, iwrkOut, ifail] = ...
    e02be(start, x, y, w, s, n, lamda, wrk, iwrk);
for i = 1 : length(px)
  [pf(i), ifail] = e02bb(lamdaOut, c, px(i), 'ncap7', nOut);
end
plot(px, pf, 'Color', [0 0.8 0], 'Linewidth', 2);

s = 0.0;
[nOut, lamdaOut, c, fp, wrkOut, iwrkOut, ifail] = ...
    e02be(start, x, y, w, s, n, lamda, wrk, iwrk);
for i = 1 : length(px)
  [pf(i), ifail] = e02bb(lamdaOut, c, px(i), 'ncap7', nOut);
end
plot(px, pf, 'Color', [0 0 .8], 'Linewidth', 2);
plot(x,y,'o', 'MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize',5);

% Draw key.
x1 = 3.8;
x2 = x1 + 0.6;
x3 = x2 + 0.2;
y1 = 2;
line([x1 x2], [y1 y1], 'Color', [.8 0 0], 'Linewidth', 2);
text(x3, y1, 'Smoothness = 10000', 'FontSize', 12);
y1 = y1 - 0.6;

line([x1 x2], [y1 y1], 'Color', [0 .8 0], 'Linewidth', 2);
text(x3, y1, 'Smoothness = 0.5', 'FontSize', 12);
y1 = y1 - 0.6;

line([x1 x2], [y1 y1], 'Color', [0 0 .8], 'Linewidth', 2);
text(x3, y1, 'Smoothness = 0', 'FontSize', 12);
y1 = y1 - 0.6;

uicontrol('Style', 'pushbutton', 'String', 'Close',...
    'Position', [10 10 100 25], 'Callback', 'close');
