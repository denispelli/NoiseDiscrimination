function [cMin,cMax]=ComputeContrastBounds(oo(oi));
% [cMin,cMax]=ComputeContrastBounds(oo(oi));
% Compute physical bounds on o.contrast and o.flankerContrast. Respects
% asymmetric luminance bounds re LBackground.

% It might work to set sMin=o.signalMin and
% sMax=o.signalMax, but my code below assumes that sMin<0
% and sMax>0, so we'd need to enforce that.
switch oo(oi).targetKind
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
nMin=oo(oi).noiseListMin*oo(oi).noiseSD/oo(oi).noiseListSd;
nMax=oo(oi).noiseListMax*oo(oi).noiseSD/oo(oi).noiseListSd;

% Given o.noiseSD and o.LBackground, tMin and tMax are the lowest and
% highest (positive or negative) possible values for the target on a
% contrast scale.
tMin=(min(cal.old.L)-oo(oi).LBackground)/oo(oi).LBackground;
tMax=(max(cal.old.L)-oo(oi).LBackground)/oo(oi).LBackground;
tMin=tMin-nMin;
tMax=tMax-nMax;
assert(tMin<0 || tMax>0,...
    'Need more range for signal. Too much noise o.noiseSD %.2f? ',...
    oo(oi).noiseSD);
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
if cMax<0
    warning('cMax %.2f negative.',cMax);
end
return