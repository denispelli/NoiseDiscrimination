
function DecadesEqual(hAxes,xLimits,yLimits)
%DECADESEQUAL Equate x-y log unit length in MATLAB plot.
% DecadesEqual(hAxes,xLimits,yLimits);
% Posted on Stackoverflow by Ken Eaton. Nov 9, 2010.
% http://stackoverflow.com/questions/4133510/axis-equal-in-a-matlab-loglog-plot
% https://www.linkedin.com/in/kenneth-eaton-4a9704126/

if (nargin < 2) || isempty(xLimits)
   xLimits = get(hAxes,'XLim');
end
if (nargin < 3) || isempty(yLimits)
   yLimits = get(hAxes,'YLim');
end

%   logScale = diff(yLimits)/diff(xLimits);
%   powerScale = diff(log10(yLimits))/diff(log10(xLimits));
%   set(hAxes,'Xlim',xLimits,...
%             'YLim',yLimits,...
%             'DataAspectRatio',[1 logScale/powerScale 1]);

yDecade = diff(yLimits)/diff(log10(yLimits));  %# Average y decade size
xDecade = diff(xLimits)/diff(log10(xLimits));  %# Average x decade size
set(hAxes,'XLim',xLimits,'YLim',yLimits,...
   'DataAspectRatio',[1 yDecade/xDecade 1]);
end

