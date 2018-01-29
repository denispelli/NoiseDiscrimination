% This function demonstrates the use of the g05rd routine from the 
% NAG toolbox for constructing a copula.  
%
% Copulas can be used for a wide range of simulation problems, for example a
% Monte Carlo analysis. They are a way of constructing a wide range of
% multivariate distributions by "gluing" together two or more univariate
% distributions.
%
% For example, you wish to simulate three variables. The type of copula used,
% Gaussian, Students T etc, describes the relationship between these
% variables. The univariate distributions (usually called the marginal
% distributions in this situation) describes the range of values each of the
% variables can take. Each variable may have a different marginal
% distribution, for example one may have a Gaussian (normal) marginal
% distribution, another a Beta distribution and the third a uniform
% distribution.
%
% This demonstration shows the shape of a number of bivariate distributions
% constructed using a Gaussian copula with Beta marginal distributions.
%
% The Beta distribution can take values between 0 and 1, and as such is often
% used to simulate probabilities. The shape of a Beta distribution is defined
% by two parameters, usually called alpha and beta, and can range from a being
% highly skewed to symmetric bell curve or a straight line.
%
% At each frame of the animation the correlation between the two variables is
% changed, starting with a correlation of zero (independence between the two
% variables) and moving towards one (complete dependence), before moving back
% down again towards minus one (complete negative dependence). As the
% correlation moves closer to one (or minus one), the peak gets squashed
% together.
%
% The marginal distribution for variable 1 is also changed at each frame,
% ranging from a Beta(20,5) to a Beta(5,20). The first parameter (alpha) moves
% from 20 to 5, with the second parameter (beta) fixed. Once alpha reaches 5,
% it is fixed and beta is changed from 5 to 20. This results in the peak
% moving across the picture.
%
% The marginal distribution for variable 2 remains constant at Beta(5,5)
% (which gives a nice bell curve).
%
% The density kernel (shape of the surface) is estimated using a simple
% binning and counting algorithm (not a NAG routine). Approximately 400 bins
% are used, and the z (vertical) axis, gives the number of observations that
% falls into each of these bins.
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart2.asp#ggaussiancopula
%
% Written by Mick Pont (mick@nag.co.uk).  April 2007.

% NAG Copyright 2009.

function g05rd_demo
h = 0.05;
id = nag_int(1 / h);
did = double(id);

n = nag_int(10000);
mode = nag_int(2);
r = zeros(7, 1);

scrsz = get(0, 'ScreenSize');
fig = figure('Name', 'NAG routines g05rd and g01fe - Bivariate Gaussian Copula with Beta Marginal Distributions', ...
             'Position', [scrsz(1)+100 scrsz(2)+20 scrsz(3)*0.8 scrsz(4)*0.8], ...
             'NumberTitle', 'off');
% Use double buffering to avoid flashing of animation
set(fig, 'Renderer', 'Painters', 'DoubleBuffer', 'On');

axes = gca;   % Get current axes - so we can reuse in each surf() command.

uicontrol('Style', 'text', 'String', 'Colormap', 'HorizontalAlignment', 'left', ...
          'Position', [20 130 100 15]);
uicontrol('Style', 'popup', 'String', 'spring|hsv|hot|cool', ...
          'Position', [20 100 100 30], 'TooltipString', 'Change colormap', 'Callback', @setmap);
colormap(spring);

% Create a control button
procbutton = uicontrol('Position', [20 60 140 40], ...
                       'String', 'Start', 'Callback', @button_handler);
% Create a close button too
closebutton = uicontrol('Position', [20 20 140 40], 'String', 'Quit', ...
                        'Callback', @button_handler);
set(closebutton, 'Enable', 'Off');
global quit;
quit = 0;

framenumber = 0;

while (1)

zrange = [0 20*n/id^2];

cell = 0;
celladd = 0.1;

ax = 20;
bx = 5;

for jj = 1:31

  % Matrix c must be positive semi-definite
  c = [1, cell;
       0, 1];

  seed = nag_int(1762543);
  genid = nag_int(1);
  subid = nag_int(1);
  [state, ifail] = nag_rand_init_repeat(genid, subid, seed);
  [rOut, stateOut, x, ifail] = g05rd(mode, n, c, r, state);

  ay = 5;
  by = 5;
  tol = 1;
  
  for ii = 1:n
      [x(ii,1), ifail] = g01fe(x(ii,1), ax, bx);
      [x(ii,2), ifail] = g01fe(x(ii,2), ay, by);
  end

  % The result array x contains two rows of numbers, each
  % in the range 0.0 - 1.0. Counting these as x and y coordinates,
  % sort them into buckets of size h in a unit square. Then plot
  % the buckets as a surface.
  buckets = zeros(id, id);
  
  for ii = 1:n
    i = nag_int(x(ii,1)*did+0.5);
    j = nag_int(x(ii,2)*did+0.5);
    
    if i >= 1 && i <= id && j >= 1 && j <= id
      buckets(i,j) = buckets(i,j) + 1;
    end
    
  end

  if quit == 1
      return;
  end
  surf(axes, buckets);
  set(gca, 'ZLim', zrange);
  xlabel(axes, 'Variable 1');
  ylabel(axes, 'Variable 2');
  zlabel(axes, 'Frequency');
  t = sprintf(['variable 1 = Beta(%3.1f,%3.1f), variable 2 = Beta(%3.1f,%3.1f), ' ...
               'correlation = %3.1f'], ax, bx, ay, by, cell);
  title (t, 'FontSize', 14);

  if jj == 1
    % wait for the Start button to be pressed before continuing
    set(closebutton, 'Enable', 'On');
    uiwait(gcf);
  end

  % Set savemovie = 1 to create a bunch of PNG files with a sequence
  % of movie frames.
  savemovie = 0;
  if savemovie == 1
    FF = getframe(gcf);
    [FX,Map] = frame2im(FF);
    filename = sprintf('frame%d.png', framenumber);
    framenumber = framenumber + 1;
    imwrite(FX,filename,'png');
  end

  pause(0.25);

  if (ax > bx)
    ax = ax - 1;
  else
    bx = bx + 1;
  end

  cell = cell + celladd;
  
  if cell > 0.8 || cell < -0.8
    celladd = -celladd;
  end

end
set(procbutton, 'String', 'Start');

end

end

function setmap(hObject, eventData)
val = get(hObject,'Value');
if val == 1
    colormap(spring)
elseif val == 2
    colormap(hsv)
elseif val == 3
    colormap(hot)
elseif val == 4
    colormap(cool)
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
elseif strcmp(label, 'Start') || strcmp(label, 'Resume')
   set(hObject, 'String', 'Pause');
   uiresume;
elseif strcmp(label, 'Next')
   uiresume;
end
end
