% This function demonstrates the use of the g13ab routine from the 
% NAG toolbox for computing the sample autocorrelation function of 
% a time series. 
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart3.asp#g13timeseries
%
% Written by Jeremy Walton (jeremyw@nag.co.uk).  July 2007.

% NAG Copyright 2009.

function g13ab_demo
% Here's the time series data (I think this comes from 
% sunspot readings). 
x = [5;  11;  16;  23;  36; 
    58;  29;  20;  10;   8;
     3;   0;   0;   2;  11;
    27;  47;  63;  60;  39;
    28;  26;  22;  11;  21;
    40;  78; 122; 103;  73;
    47;  35;  11;   5;  16;
    34;  70;  81; 111; 101;
    73;  40;  20;  16;   5;
    11;  22;  40;  60;   80.9];

% nk is the number of lags for which the autocorrelations
% are required.
nk = nag_int(40);

% Call the NAG routine.
[xm, xv, coeff, stat, ifail] = g13ab(x, nk);

% Set parameters for size and position of plot.
left = 100;
bottom = 200;
width = 700;
height = 600;
fontSize = 11.5;

% Open the figure, set the properties of the plot, and set the title.
figure('Name', 'Time series autocorrelation using the NAG Toolbox', ...
       'Position', [left, bottom, width, height],...
        'NumberTitle', 'off');
axes = gca;
set(gca, 'FontSize', fontSize);
xlabel('lag');
ylabel('Coefficient');
hold on;
title('Using NAG routine g13ab for autocorrelation calculation', 'FontSize', 14);

% lag goes along the x axis.
lag = (1: 1: nk);

% set the x & y limits and ticks for the graph.
set(gca, 'xlim', [0 length(lag)]);
yrange = max(coeff)-min(coeff);
ymin = min(coeff) - 0.02*yrange;
ymax = max(coeff) + 0.02*yrange;
set(gca, 'ylim', [ymin ymax]);

% plot the data as a bar chart (the x values are discrete).
bar(lag, coeff, 0.6, 'c');

% Prepare to display text box.  We assume here that there are 
% no negative x values.  Also, we need to convert the upper x limit
% to double, otherwise the x location in the text command ends up as 
% an int, which Matlab doesn't like.
xmax = double(max(lag));
txmin = 0.4*xmax;
txmax = 0.9*xmax;
tymin = min(coeff) + 0.7*yrange;
tymax = min(coeff) + 0.9*yrange;

% Draw the text box.
fill( [txmin txmax txmax txmin], [tymin tymin tymax tymax], 'w');

% Show the results.
xoff = txmin + 0.01*xmax;
yshift = (tymax-tymin) / 3.0;
yoff = tymax-yshift;

t = sprintf('Sample mean = %5.2f', xm);
text(xoff, yoff, t, 'FontSize', fontSize);
yoff = yoff-yshift;

t = sprintf('Sample variance = %5.2f', xv);
text(xoff, yoff, t, 'FontSize', fontSize);
yoff = yoff-yshift;

uicontrol('Style', 'pushbutton', 'String', 'Close',...
    'Position', [5 5 50 28], 'Callback', 'close');
