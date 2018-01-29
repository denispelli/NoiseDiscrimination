% This function demonstrates the use of the e01be & e01bf routines from the 
% NAG toolbox for Hermite interpolation through a set of points. A cubic
% spline is also fitted through the points for comparison.
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart2.asp#e01interpolation
%
% Written by Jeremy Walton (jeremyw@nag.co.uk).  June 2007.

% NAG Copyright 2009.

function e01be_demo
% Here's the (x,y) data to be fitted.  Note that y is 
% monotonically increasing. 
x = [7.5;
     8.09;
     8.19;
     8.69;
     9.19;
     10;
     12;
     15;
     20];
f = [0;
     0;
     0.04375;
     0.16918;
     0.46943;
     0.94374;
     0.99864;
     0.99992;
     0.99999];

% Open the figure, set the properties of the plot, and set the title.
figure('Name', 'Hermite interpolation using the NAG Toolbox',...
    'Position', [100, 200, 700, 600], ...
    'NumberTitle', 'off');
axes = gca;
set(gca, 'FontSize', 12);
xlabel('x');
ylabel('y', 'Rotation', 0);
hold on;
title('Using NAG routines e01be, e01bf for Hermite interpolation', 'FontSize', 14);

% Draw the axes.
axis([7 20.5 -0.18 1.22]);

% Now call the NAG routine e01be to compute the Hermite interpolant
% through the data.
[d, ifail] = e01be(x, f);

% Set up the points at which the interpolant is to be calculated.
px = [x(1) : 0.01 : x(9)];

% Call the NAG routine e01bf to calculate the interpolant, and plot it.
[pf, ifail] = e01bf(x, f, d, px);
hold on;
plot (px, pf, '-b', 'LineWidth', 2);

% Now prepare to fit a cubic spline through the same data.
w = [1; 1; 1; 1; 1; 1; 1; 1; 1];
n = nag_int(0);
lamda = zeros(54,1);
wrk = zeros(1105, 1);
iwrk = zeros(54, 1, 'int32');
iwrk = nag_int(iwrk);
sf = zeros(size(px));
s = 0.0;
start = 'C';

% Call e02be to fit the spline.
[nOut, lamdaOut, c, fp, wrkOut, iwrkOut, ifail] = ...
    e02be(start, x, f, w, s, n, lamda, wrk, iwrk);

% Call e02bb to calculate the spline, and plot it.
for i = 1 : length(px)
  xx = px(i);
  [py, ifail] = e02bb(lamdaOut, c, xx, 'ncap7', nOut);
  ps(i) = py;
end
plot (px, ps, '-r', 'LineWidth', 2);
plot(x,f,'o', 'MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize',5);

% Draw key.
x1 = 11;
x2 = x1 + 1.0;
x3 = x2 + 0.4;
y1 = 0.4;
plot(x1,y1,'o', 'MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize',5);
plot((x1+x2)/2,y1,'o', 'MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize',5);
plot(x2,y1,'o', 'MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize',5);
text(x3, y1, 'Data points to be fitted', 'FontSize', 12);
y1 = y1 - 0.1;

line([x1 x2], [y1 y1], 'Color', [0 0 1], 'Linewidth', 2);
text(x3, y1, 'Cubic Hermite interpolant (monotonic)', 'FontSize', 12);
y1 = y1 - 0.1;

line([x1 x2], [y1 y1], 'Color', [1 0 0], 'Linewidth', 2);
text(x3, y1, 'Cubic spline interpolant', 'FontSize', 12);

uicontrol('Style', 'pushbutton', 'String', 'Close',...
    'Position', [10 10 100 25], 'Callback', 'close');
