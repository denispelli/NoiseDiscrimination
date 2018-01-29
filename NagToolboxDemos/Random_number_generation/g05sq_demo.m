% This function demonstrates the use of some of the routines from the 
% G05 chapter of the NAG toolbox for calculating random numbers.
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart3.asp#g05randomnumber
%
% Written by Mick Pont (mick@nag.co.uk).  April 2007.

% NAG Copyright 2009.

function rollcont = g05sq_demo(rolling)

global mypause;
mypause = 0.01;
if nargin < 1
  % rolling = 1 means use the full screen for plots (good for
  % rolling demo) and don't wait for key press before starting
  rolling = 0;
end

global quit;
quit = 0;
rollcont = 1;

seed = [nag_int(17625)];
% genid and subid identify the base generator
genid = nag_int(1);
subid = nag_int(1);
% Initialize the generator to a repeatable sequence
[state, ifail] = nag_rand_init_repeat(genid, subid, seed);

% The number of (x,y) pairs to generate
n = nag_int(10000);
% Generate pseudo-random numbers
a = 0;
b = 1;
[state, x, ifail] = g05sq(n, a, b, state);
[state, y, ifail] = g05sq(n, a, b, state);

% Generate quasi-random numbers
idim = nag_int(2);
genid = nag_int(4);
iskip = nag_int(1);
[iref, ifail] = g05yl(genid,idim,iskip);
[quasi, irefOut, ifail] = g05ym(n, iref);

% Now plot them, a few at a time
scrsz = get(0,'ScreenSize');
if rolling
  figure('Name', 'NAG random numbers', ...
         'Position', [0 -35 scrsz(3)*1.0 scrsz(4)*1.0], ...
         'NumberTitle', 'off');
else
  figure('Name', 'NAG random numbers', ...
         'Position', [scrsz(1)+100 scrsz(2)+50 scrsz(3)*0.8 scrsz(4)*0.8], ...
         'NumberTitle', 'off');
end

if rolling ~= 1
  % Create a control button
  procbutton = uicontrol('Position', [10 45 130 30], ...
                         'String', 'Start', 'Callback', @button_handler);
end
% Create a close button
closebutton = uicontrol('Position', [10 10 130 30], 'String', 'Quit', ...
                        'Callback', @button_handler);
if rolling ~= 1
  set(closebutton, 'Enable', 'Off');
end

uicontrol('Style', 'popup', 'String', 'Slow|Medium|Fast|Whoa', ...
          'Position', [10 70 110 30], 'TooltipString', ...
          'Chooses the speed of animation', ...
          'Value', 3, 'Callback', @animspeed);

subplot(2,1,1)
hold on;
title ('Pseudo-random numbers', 'FontSize', 14);
subplot(2,1,2)
hold on;
title ('Quasi-random numbers', 'FontSize', 14);
subplot(2,1,1)
cla;
subplot(2,1,2)
cla;

if rolling ~= 1
  % wait for the Start button to be pressed before continuing
  set(closebutton, 'Enable', 'On');
  uiwait(gcf);
end

% How many points to plot at a time
if mypause == 0.0
   % Do the lot
   nat = n;
else
   nat = 10;
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

cont = 1;
while (cont)
  for ii = 1 : nat : n
     if mypause == 0.0
        nn = n - ii + 1;
        mc = 'blue';
     else
        nn = nat;
        mc = 'red';
     end
     subplot(2,1,1)
     scatter(x(ii:ii+nn-1), y(ii:ii+nn-1), 10, 'filled', 'MarkerFaceColor', mc);
     subplot(2,1,2)
     scatter(quasi(1,ii:ii+nn-1), quasi(2,ii:ii+nn-1), 10, 'filled', 'MarkerFaceColor', mc);
     if ii > 1 && mypause ~= 0.0
       % Turn the previous plotted points blue
       subplot(2,1,1)
       scatter(x(ii-nn:ii-1), y(ii-nn:ii-1), 10, 'filled', 'MarkerFaceColor', 'blue');
       subplot(2,1,2)
       scatter(quasi(1,ii-nn:ii-1), quasi(2,ii-nn:ii-1), 10, 'filled', 'MarkerFaceColor', 'blue');
     end
     if quit == 1
         rollcont = 0;
         close all;
         return;
     end
     if mypause == 0.0
         break;
     end
     if savemovie == 1
       FF = getframe(gcf);
       [FX,Map] = frame2im(FF);
       filename = sprintf('frame%d.png', framenumber);
       imwrite(FX,filename,'png');
       framenumber = framenumber + 1;
     end
     pause(mypause);
  end
  if rolling == 1
    cont = 0;
  else
    set(procbutton, 'String', 'Restart');
    uiwait;
    subplot(2,1,1)
    cla;
    subplot(2,1,2)
    cla;
    pause(mypause);
  end
  if mypause ~= 0.0
     nat = 10;
  end
end
end

function button_handler(hObject, eventData)
global quit;
label = get(hObject, 'String');
if strcmp(label, 'Close') || strcmp(label, 'Quit')
   close;
   quit = 1;
elseif strcmp(label, 'Pause')
   set(hObject, 'String', 'Resume');
   uiwait;
elseif strcmp(label, 'Start') || strcmp(label, 'Resume') || strcmp(label, 'Restart')
   set(hObject, 'String', 'Pause');
   uiresume;
elseif strcmp(label, 'Next')
   uiresume;
end
end

function animspeed(hObject, eventData)
global mypause;
val = get(hObject, 'Value');
if val == 1
  mypause = 0.75;
elseif val == 2
  mypause = 0.125;
elseif val == 3
  mypause = 0.001;
else
  mypause = 0.0;
end
end
