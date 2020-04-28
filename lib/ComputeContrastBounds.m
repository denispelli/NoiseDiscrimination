function [cMin,cMax]=ComputeContrastBounds(o)
% [cMin,cMax]=ComputeContrastBounds(o);
%
% Compute physical bounds on o.contrast and o.flankerContrast. Respects
% asymmetric luminance bounds re LBackground.

% It might work to set sMin=o.signalMin and sMax=o.signalMax, but my code
% below assumes that sMin<0 and sMax>0, so we'd need to enforce that.
switch o.targetKind
    case 'image'
        sMin=-1;
        sMax=eps;
    case {'letter' 'word'}
        % Ink is +1 and paper is 0 in o.signal.image
        sMin=-eps;
        sMax=1;
    otherwise
        sMin=-1;
        sMax=1;
end
% nMin and nMax are the min and max of the zero-mean noise on a contrast
% scale.
nMin=o.noiseListMin*o.noiseSD;
nMax=o.noiseListMax*o.noiseSD;

% Given o.noiseSD and o.LBackground, tMin and tMax are the lowest and
% highest (positive or negative) possible values for the target on a
% contrast scale.
tMin=(min(o.cal.old.L)-o.LBackground)/o.LBackground;
tMax=(max(o.cal.old.L)-o.LBackground)/o.LBackground;
tMin=tMin-nMin;
tMax=tMax-nMax;
assert(tMin<0 || tMax>0,...
    'ComputeContrastBounds: Need more range for signal. Too much noise o.noiseSD %.2f? ',...
    o.noiseSD);
% Our computation of cMin and cMax assumes we know the signs of sMin and
% sMax.
assert(sMin<0 && sMax>0)
% The contrast constraints are:
% c*sMin>=tMin
% c*sMin<=tMax
% c*sMax>=tMin
% c*sMax<=tMax
% Since we know the signs of sMin and sMax:
% c<=tMin/sMin
% c>=tMax/sMin
% c>=tMin/sMax
% c<=tMax/sMax
cMax=min([tMin/sMin tMax/sMax]);
cMin=max([tMax/sMin tMin/sMax]);
if cMax<cMin
    warning('cMax %.2f < cMin %.2f.',cMax,cMin);
end
if o.printContrastBounds
    fprintf(['ComputeContrastBounds %d: LMin %.1f, LMax %.1f, LBackground %.1f, '...
        'nMin %.2f, nMax %.2f, '...
        'tMin %.2f, tMax %.2f, cMin %.2f, cMax %.2f, '...
        'contrast %.2f\n'],...
        MFileLineNr,...
        min(o.cal.old.L),max(o.cal.old.L),o.LBackground,...
        nMin,nMax,tMin,tMax,cMin,cMax,o.contrast);
    fprintf('ComputeContrastBounds: cMin %5.2f spans [%.1f %.1f] cd/m^2, cMax %.2f spans [%.1f %.1f] cd/m^2\n',...
        cMin,(1+sort(cMin*[sMin sMax]))*o.LBackground,...
        cMax,(1+sort(cMax*[sMin sMax]))*o.LBackground);
    fprintf('ComputeContrastBounds: o.contrast %5.2f spans [%.1f %.1f] cd/m^2\n',...
        o.contrast,(1+sort(o.contrast*[sMin sMax]))*o.LBackground);
    fprintf('ComputeContrastBounds: o.noiseSD %5.2f spans [%.1f %.1f] cd/m^2, \n',...
        o.noiseSD,(1+[nMin nMax])*o.LBackground);
    fprintf('ComputeContrastBounds: o.contrast %5.2f plus o.noiseSD %.2f spans [%.1f %.1f] cd/m^2, \n',...
        o.contrast,o.noiseSD,...
        (1+sort(o.contrast*[sMin sMax])+[nMin nMax])*o.LBackground);
    fprintf('ComputeContrastBounds: cMin %5.2f plus o.noiseSD %.2f spans [%.1f %.1f] cd/m^2, \n',...
        cMin,o.noiseSD,...
        (1+sort(cMin*[sMin sMax])+[nMin nMax])*o.LBackground);
    fprintf('ComputeContrastBounds: cMax %5.2f plus o.noiseSD %.2f spans [%.1f %.1f] cd/m^2, \n',...
        cMax,o.noiseSD,...
        (1+sort(cMax*[sMin sMax])+[nMin nMax])*o.LBackground);
end
return