% This function demonstrates the use of the d01aj routine from the NAG
% toolbox for numerical quadrature of a one-dimensional function over a
% finite interval.
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart3.asp#d01quadrature
%
% Original version by David Sayers.
% Modifications by Jeremy Walton (jeremyw@nag.co.uk).  August 2007.
% - added comments
% - tidied graphics
% - added switch allowing user to specify the function.
% Quit button and function recycle drop-down list added by Mick. Sept 2007.

% This function uses these other files:
% d01aj_fcn1.m
% d01aj_fcn2.m
% d01aj_fcn3.m
% d01aj_fcn4.m

% NAG Copyright 2009.

function d01aj_demo
% Ask the user which function we're going to integrate.
[selection, ok] = listdlg('PromptString', 'Select a function to be integrated:', ...
    'SelectionMode', 'single', ...
    'ListSize', [220 100], ...
    'ListString', ...
    {'x*sin(30*x)/sqrt(1.0-x^2/(4.0*pi^2))';
    'x^2*abs(sin(5*x))';
    's17ae(10*x)';
    'x*exp(-x)';
    });

% If the user pressed the cancel button, then exit.
if ok == 0
    return;
end

% Open the figure, set the properties of the plot, and set the title.
figure('Name', 'Adaptive integration using the NAG Toolbox', ...
    'Position', [100, 100, 534, 800], ...
    'NumberTitle', 'off');
%axes = gca;
%set(axes, 'FontSize', 13);
%xlabel('x');

% Create a close button.
uicontrol('Position', [350 10 130 30], 'String', 'Quit', ...
    'Callback', @button_handler);

% And a function selection control.
uicontrol('Style', 'popup', 'String', ...
    'x*sin(30*x)/sqrt(1.0-x^2/(4.0*pi^2))|x^2*abs(sin(5*x))|s17ae(10*x)|x*exp(-x)', ...
    'Position', [40 10 200 30], 'TooltipString', ...
    'Chooses the function to be integrated', ...
    'Value', selection, 'Callback', @funChoice);

% Do the integration and display the results.
dodemo(selection);

end

function dodemo(selection)
% Choose the function, and the limits of integration.  These should be
% hardwired, e.g. because the first function goes imaginary for limits
% greater than 1.0.
%
% Also pick up the name of the name of the m-file containing the integrand.
% Note that, for this to work, the current matlab directory must be set to
% the directory containing this file.  One situation where this won't work
% is if the matlab directory is set elsewhere, and this function
% (d01aj_demo) is invoked from outside matlab.  The function will start
% okay, and the first choice for the integrand will load correctly, but 
% attempting to load the next choice will cause d01aj_demo to crash, 
% complaining that the integrand function is undefined.  
switch selection
    case 1
        a = -0.99;  b = 0.99;
        func = 'd01aj_fcn1';
    case 2
        a = -2.0;  b = 2.0;
        func = 'd01aj_fcn2';
    case 3
        a = -5.0;  b = 5.0;
        func = 'd01aj_fcn3';
    case 4
        a = 0.0;  b = 10.0;
        func = 'd01aj_fcn4';
    otherwise
        disp(['Error - unrecognized selection value: ', num2str(selection)]);
end

epsabs = 0.0;
epsrel = 0.000001;

% lw & liw are the dimensions of the w and iw output arrays.  lw should be
% between 800 & 2000; liw should be a quarter of that.
lw = nag_int(1000);
liw = lw/4;
iw = zeros(liw, 'int32');
iw = nag_int(iw);
w = zeros(lw, 'double');

% Call the NAG routine, and check for errors.
[result, abserr, w, iw, ifail] = d01aj(func, a, b, epsabs, epsrel);
if ifail ~= 0
    disp([' Non-zero ifail after d01aj call ', num2str(ifail)]);
    return;
end;

% Process results.  First, get the number of sub-intervals used in the
% quadrature.
nsub = iw(1);

% Then, get the endpoints (a & b) of the subintervals, the absolute error
% estimate (e) and the approximation to the integral value (r) in each
% subinterval.
alist = w(1:nsub);
blist = w(nsub+1:2*nsub);
elist = w(2*nsub+1:3*nsub);
rlist = w(3*nsub+1:4*nsub);

% Add the final (left-most) endpoint to the list of right-most endpoints.
alist = cat(1, alist, blist(nsub));

% Plot the integrals and the function curve in the upper subplot.
subplot(2, 1, 1);
hold on;
set(gca, 'FontSize', 13);
xlabel('x');
demo(alist, rlist, true, selection);
title({'Using NAG routine d01aj for numerical quadrature';...
    ['Calculated integral = ' num2str(result)]}, 'FontSize', 14);

% Plot the errors (and not the function curve) in the lower subplot.
subplot(2, 1, 2);
set(gca, 'FontSize', 13);
xlabel('x');
demo(alist, elist, false, selection);
title('Estimated errors', 'FontSize', 14);

clear epsabs epsrel iw w ifail result abserr alist blist elist rlist nsub;

end

function demo(Intervals, Integrals, doplot, selection)

% Get the dimensions of the interval and integral arrays, and check them.
[numival dummy] = size(Intervals);
if dummy ~= 1
    disp('Error - second dimension of Intervals should be 1');
    return;
end

[numigal dummy] = size(Integrals);
if dummy ~= 1
    disp('Error - second dimension of Integrals should be 1');
    return;
end

if (numigal+1) ~= numival
    disp('Error - input arrays are not consistently dimensioned');
    return;
end;

% Display the integrals or errors as a histogram.
for i = 1:1:numigal
    width=Intervals(i+1)-Intervals(i);
    if doplot
        height=Integrals(i)/width;
    else
        height=Integrals(i);
    end;
    if height>0
        h = rectangle('Position',[Intervals(i),0,width,height]);
    else if height<0
            h = rectangle('Position',[Intervals(i),height,width,-height]);
        end;
    end;

    set(h, 'Facecolor', [1.0 0.5 0]);
end;

% Display the function as a curve by calculating its value at a suitably
% large number of points between the limits.
npts = 1000;
middles=zeros(npts+1);
values=zeros(npts+1);

if doplot
    width = (Intervals(numival)-Intervals(1))/npts;
    switch selection
        case 1
            for i=1:1:npts+1
                middles(i) = Intervals(1) + (i-1)*width;
                values(i) = d01aj_fcn1(middles(i));
            end;
        case 2
            for i=1:1:npts+1
                middles(i) = Intervals(1) + (i-1)*width;
                values(i) = d01aj_fcn2(middles(i));
            end;
        case 3
            for i=1:1:npts+1
                middles(i) = Intervals(1) + (i-1)*width;
                values(i) = d01aj_fcn3(middles(i));
            end;
        case 4
            for i=1:1:npts+1
                middles(i) = Intervals(1) + (i-1)*width;
                values(i) = d01aj_fcn4(middles(i));
            end;
    end;
    plot(middles, values, 'LineWidth', 2, 'Color', [1 0 0.5]);

end;

end

% Handles the quit button.
function button_handler(hObject, eventData)
close;
end

% Called when the user selects a new function from the drop-down list.
function funChoice(hObject, eventData)
fchoice = get(hObject, 'Value');
% Clear old plots
subplot(2, 1, 1);
cla;
subplot(2, 1, 2);
cla;
% Do a new plot according to the selection.
dodemo(fchoice);
end
