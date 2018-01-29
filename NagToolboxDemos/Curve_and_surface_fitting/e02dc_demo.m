% This function demonstrates the use of the e02dc routine from the 
% NAG toolbox for fitting a bicubic spline surface through a set of points. 
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlab.asp#e02fittingsurface
%
% Written by Mick Pont (mick@nag.co.uk).  April 2007.
% Modifications by Jeremy Walton (jeremyw@nag.co.uk).  January 2009.
% - incorporated button handler function into this file.
% - fixed width format for output.

% NAG Copyright 2009.

function e02dc_demo(pausetime, rolling)

if nargin<1 || isempty(pausetime)
  pausetime = 0.2;
end

if nargin<2 || isempty(rolling)
  rolling = 0;
end

% Initialize input data
start = 'C';
x = [0; 0.5; 1; 1.5; 2; 2.5; 3; 3.5; 4; 4.5; 5];
y = [0; 0.5; 1; 1.5; 2; 2.5; 3; 3.5; 4];
f = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1;
     1; 1; 1.1; 1.2; 1.1; 1; 1; 1; 1; 1; 1;
     1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1;
      1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1;
      1; 1; 1; 1; 1; 1.075; 1.15; 1.075; 1; 1; 1;
      1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1;
      1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1.1;
      1.2; 1.1; 1; 1; 1; 1; 1; 1; 1; 1;
      1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1];
nx = nag_int(0);
lamda = zeros(15, 1);
mu = zeros(13, 1);
ny = nag_int(0);
wrk = zeros(592, 1);
iwrk = zeros(51, 1, 'int32');
iwrk = nag_int(iwrk);

% Plot the initial data
scrsz = get(0, 'ScreenSize');
fig = figure('Name', 'Surface fitting with NAG Toolbox for MATLAB', ...
             'Position', [scrsz(1)+30 scrsz(4)*0.2 scrsz(3)*1.0-60 scrsz(4)*0.5], ...
             'NumberTitle', 'off');
% Use double buffering to avoid flashing of animation
set(fig, 'Renderer', 'Painters', 'DoubleBuffer', 'On');

zrange = [0.975 1.25];
subplot(1,2,1);
pf = reshape(f,length(y),length(x));
surf(x, y, pf);
colormap('Winter');
set(gca, 'ZLim', zrange);
title ('Data to be fitted by bicubic spline', 'FontSize', 14);

if ~rolling
    % Create a button and wait for it to be pressed before continuing
    hbutton = uicontrol('Position', [20 20 140 40], ...
        'String', 'Start', 'Callback', @my_button_handler);
    uiwait(gcf);
else
    % Create a pause button.
    hbutton = uicontrol('Position', [20 20 140 40], ...
        'String', 'Pause', 'Callback', @my_button_handler);
end

% Set savemovie = 1 to create a bunch of PNG files with a sequence
% of movie frames.
savemovie = 0;
framenumber = 0;
if savemovie == 1
  FF = getframe(gcf);
  [FX,Map] = frame2im(FF);
  filename = sprintf('frame%d.png', framenumber);
  imwrite(FX,filename,'png');
  framenumber = framenumber + 1;
end

px = 0 : 0.1 : 5.0;
py = 0 : 0.1 : 4.0;
mx = length(px);
my = length(py);

% Fit the bicubic spline using several different smoothing parameters,
% and draw a surface, each time overwriting the previous graph.
subplot(1,2,2);
% Get current axes - so we can reuse in each surf() command.
axes = gca;

smax = 0.14;
smin = 0.0175;
s = smax;

while s >= smin

  % Compute the bicubic spline approximant with e02dc  
  [nxOut, lamdaOut, nyOut, muOut, c] = e02dc(start, x, y, f, s, nx, lamda, ny, mu, wrk, iwrk);

  % Evaluate the spline on a rectangular grid using e02df
  ff = e02df(px, py, lamdaOut(1:nxOut), muOut(1:nyOut), c);

  pff = reshape(ff,my,mx);
  surf(axes, px, py, pff);
  colormap('Winter');
  set(axes, 'ZLim', zrange);
  t = sprintf('NAG routine e02dc: fitting bicubic spline with s = %9.6f', s);
  title(t, 'FontSize', 14);
  if savemovie == 1
    FF = getframe(gcf);
    [FX,Map] = frame2im(FF);
    filename = sprintf('frame%d.png', framenumber);
    imwrite(FX,filename,'png');
    framenumber = framenumber + 1;
  end
  pause(pausetime)
  s = s * 0.975;
end

set(hbutton, 'String', 'Close');

% This function is used to handle the control button on the graphics window.

function my_button_handler(hObject, eventData)
label = get(hObject, 'String');
if strcmp(label, 'Close')
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

