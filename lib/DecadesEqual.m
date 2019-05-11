
function DecadesEqual(ax,xLimits,yLimits)
%DECADESEQUAL Equate x-y log unit length in MATLAB plot.
% DecadesEqual(ax,xLimits,yLimits);
% Posted on Stackoverflow by Ken Eaton. Nov 9, 2010.
% http://stackoverflow.com/questions/4133510/axis-equal-in-a-matlab-loglog-plot
% https://www.linkedin.com/in/kenneth-eaton-4a9704126/
% May 2019, Replaced set and get calls by the newer dot notation for XLim
% and YLim.

if (nargin < 2) || isempty(xLimits)
   xLimits = ax.XLim;
end
if (nargin < 3) || isempty(yLimits)
   yLimits = ax.YLim;
end
yDecade = diff(yLimits)/diff(log10(yLimits));  % Average y decade size
xDecade = diff(xLimits)/diff(log10(xLimits));  % Average x decade size
% set(ax,'XLim',xLimits,'YLim',yLimits,...
%    'DataAspectRatio',[1 yDecade/xDecade 1]);
ax.XLim=xLimits;
ax.YLim=yLimits;
ax.DataAspectRatio=[1 yDecade/xDecade 1];
end

