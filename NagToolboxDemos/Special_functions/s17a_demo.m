% This function demonstrates the use of some of the routines from the S 
% chapter of the NAG toolbox for calculating Bessel functions.
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlab.asp#sbessel
%
% Written by Mick Pont (mick@nag.co.uk).  April 2007.

% NAG Copyright 2009.

function s17a_demo(pausetime)

if nargin<1 || isempty(pausetime)
  pausetime = 0.125;
end

if pausetime < 0
  pausetime = 0;
end

% Create the figure
scrsz = get(0, 'ScreenSize');
figure('Name', 'Bessel Functions using NAG Toolbox for MATLAB', ...
       'Position', [scrsz(1)+100 scrsz(2)+20 scrsz(3)*0.8 scrsz(4)*0.8], ...
       'NumberTitle', 'off');
hold on;
title('NAG routines s17ac, s17ad, s17ae, s17af: Bessel functions', 'FontSize', 14);

% Draw an axis and legend
frx = [15 35 35 15];
fry = [-0.5 -0.5 -1.25 -1.25];
fill(frx, fry, 'w');
line([0,40], [0,0], 'Color', 'black');
line([16,19], [-0.6,-0.6], 'Color', 'red', 'Linewidth', 2);
text(20, -0.6, 's17ac - Bessel function Y_0', 'FontSize', 12);
line([16,19], [-0.8,-0.8], 'Color', 'green', 'Linewidth', 2);
text(20, -0.8, 's17ad - Bessel function Y_1', 'FontSize', 12);
line([16,19], [-1.0,-1.0], 'Color', 'blue', 'Linewidth', 2);
text(20, -1.0, 's17ae - Bessel function J_0', 'FontSize', 12);
line([16,19], [-1.2,-1.2], 'Color', 'black',  'Linewidth', 2);
text(20, -1.2, 's17ae - Bessel function J_1', 'FontSize', 12);

% Set up the arrays
x = [0.125, 0.25 : 0.25 : 40].';
n = length(x);
y0 = zeros(n,1); y1 = zeros(n,1); j0 = zeros(n,1); j1 = zeros(n,1);

for i = 1 : n
  y0(i) = s17ac(x(i));
  y1(i) = s17ad(x(i));
  j0(i) = s17ae(x(i));
  j1(i) = s17af(x(i));

  if i > 1
    line([x(i-1),x(i)], [y0(i-1),y0(i)], 'Color', 'red');

    if i > 3
      line([x(i-1),x(i)], [y1(i-1),y1(i)], 'Color', 'green');
    end

    line([x(i-1),x(i)], [j0(i-1),j0(i)], 'Color', 'blue');
    line([x(i-1),x(i)], [j1(i-1),j1(i)], 'Color', 'black');
    pause(pausetime);
  end

end

uicontrol('Style', 'pushbutton', 'String', 'Close',...
    'Position', [20 20 140 40], 'Callback', 'close');
