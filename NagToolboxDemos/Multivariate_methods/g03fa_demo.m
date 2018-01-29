% This function demonstrates the use of the g03ea and g03fa routines from
% the NAG toolbox for calculating a dissimilarity matrix and and performing
% metric scaling to analyse a multivariate dataset.
%
% More information on this demo can be found at
% http://www.nag.co.uk/industryarticles/usingtoolboxmatlabpart3.asp#g03multivariate
%
% Written by Jeremy Walton (jeremyw@nag.co.uk).  October 2007.

% NAG Copyright 2009.

function g03fa_demo

% These are the region labels.
label = char( 'Surrey', 'Shropshire', 'Yorkshire', 'Perthshire', ...
    'Aberdeen', 'Eilean Gamhna', 'Alps', 'Yugoslavia', 'Germany', ...
    'Norway', 'Pyrenees I', 'Pyrenees II', 'North Spain', 'South Spain' );

% This is the vole data.  14 rows (one for each region), 13 columns
% (one for each variable).
data0 = [
    [48.5  89.2   7.9  42.1  92.1 100.0 100.0 ...
    35.3  11.4 100.0  71.9  31.6   2.8];
    [67.7  67.0   2.0  23.0  93.0 100.0  86.0 ...
    44.0  14.0  99.0  97.0  31.0  17.0];
    [51.7  84.8   0.0  31.3  88.2 100.0  94.1 ...
    18.8  25.0 100.0  83.3  33.3   5.9];
    [42.9  50.0   0.0  50.0  77.3 100.0  90.9 ...
    36.4  59.1 100.0 100.0  38.9   0.0];
    [18.1  79.6   4.1  44.9  79.6 100.0  77.6 ...
    16.7  37.1 100.0  90.4   9.8   0.0];
    [65.0  81.8   9.1  31.8  81.8 100.0  59.1 ...
    20.0  30.0 100.0 100.0   5.0   9.1];
    [57.1  76.2  21.4  38.1  66.7  97.6  14.3 ...
    23.5   9.5 100.0  91.4  11.8  17.5];
    [26.7  53.1  23.5  38.2  44.1  94.1  11.8 ...
    11.8  18.2 100.0  94.9  12.5   5.9];
    [38.5  67.9  17.9  21.4  82.1 100.0  60.7 ...
    35.7  24.0 100.0  91.7  37.5   0.0];
    [33.3  83.3  27.8  29.4  86.1 100.0  63.9 ...
    53.8  18.8 100.0  83.3   8.3  34.3];
    [47.6  92.9  26.7  10.0  36.7 100.0  50.0 ...
    14.3   7.4 100.0  86.4  90.9   3.3];
    [60.0  90.9  13.6  68.2  40.9 100.0  18.2 ...
    100.0  5.0  80.0  90.0  50.0   0.0];
    [53.8  88.1   7.1  33.3  88.1 100.0  19.0 ...
    85.7   9.8  73.8  72.2  73.7   2.4];
    [29.2  74.0  16.0  46.0  86.0 100.0  18.0 ...
    88.0  16.3  72.0  80.4  69.6   4.0];
    ];

% Invoke this standard transform to remove the effect of unequal variances
% between ranges.
data1 = asin(1.0 - 0.02*data0);

% Initialze D to zero before adding distances to D.
update = 'I';

% Distances are squared Euclidean.
dist = 'S';

% No scaling for the variables.
scal = 'U';

% Number of observations (regions in which data is gathered).
nobs = nag_int(14);

% Number of variables (measurements in each region).
nvar = nag_int(13);

% Which variables are to be included in the distance computation?
isx = ones(1, nvar, 'int32');
isx = nag_int(isx);

% Scaling parameter for each variable (not used, but must be supplied).
s = ones(1, nvar, 'double');

% Input distance matrix (not used, but must be supplied).
d = zeros(nobs*(nobs-1)/2, 1, 'double');

% Call the NAG routine to calculate the dissimilarity matrix.
[sOut, dOut, ifail] = g03ea(update, dist, scal, data1, isx, s, ...
    d, 'm', nvar);

% Standardize the matrix by the number of variables.
dOut = dOut ./ double(nvar);

% Now correct for the bias caused by the different number of observations
% in each region.
ns = [19 50 17 11 49 11 21 17 14 18 16 11 21 25];

jend = nobs-1;
for j = 1:jend
    istart = j+1;
    for i = istart:nobs
        index = (i-1)*(i-2)/2 + j;
        dOut(index) = abs(dOut(index) - (1.0/ns(i) + 1.0/ns(j)));
    end
end

% Now prepare for the metric scaling from nvar to ndim dimensions.
roots = 'l';
ndim = nag_int(3);
[x, eval, ifail] = g03fa(roots, nobs, dOut, ndim);

% Colours for each region, according to its species.  Note that
% Pyrenees I was wrongly coloured red in the original version of the
% NAGNews article featuring this demo.
colours = [ ...
    [0 0 0]; ...% Surrey
    [0 0 0]; ...% Shropshire
    [0 0 0]; ...% Yorkshire
    [0 0 0]; ...% Perthshire
    [0 0 0]; ...% Aberdeen
    [0 0 0]; ...% Eilean Gamhna
    [0 0 1]; ...% Alps
    [0 0 1]; ...% Yugoslavia
    [0 0 1]; ...% Germany
    [0 0 1]; ...% Norway
    [0 0 1]; ...% Pyrenees I
    [1 0 0]; ...% Pyrenees II
    [1 0 0]; ...% North Spain
    [1 0 0]; ...% South Spain
    ];

% Set parameters for size and position of plot.
left = 100;
bottom = 200;
width = 534;
height = 500;
fontSize = 13; % or 20 for full-screen display;

% Open the figure, set the properties of the plot, and set the title.
figure('Name', 'Metric scaling using the NAG Toolbox', ...
    'Position', [left, bottom, width, height],...
    'NumberTitle', 'off');
axes = gca;
set(gca, 'FontSize', fontSize);

% Do the scatter plot of the 3D data.  The parameters to the view command 
% have been determined empirically to try and get a decent view of the 
% points.
scatter3(x(1:nobs), x(nobs+1:2*nobs), x(2*nobs+1:3*nobs), ...
    40.0, colours, 'filled'), view(-81, 62);

% Add the labels, coloured according to species.
dims = size(label);
for i = 1 : nobs
    text(x(i), x(nobs+i), x(2*nobs+i), label(i,1:dims(2)), ...
        'Color', [colours(i), colours(nobs+i), colours(2*nobs+i)], ...
        'FontSize', fontSize);
end

xlabel(axes,'Variable 1');
ylabel(axes,'Variable 2');
zlabel(axes,'Variable 3','Rotation',90);

title('Using NAG routine g03fa for metric scaling', 'FontSize', fontSize+1);


