function xyPix=XYPixOfXYDeg(o,xyDeg)
% Convert position from deg (relative to fixation) to (x,y) coordinate in
% o.stimulusRect. Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. In terms of geometry, the
% perspective transformation is relative to location of near point, which
% is orthogonal to line of sight. "location" refers to the near point. We
% typically put the target there, but that is not assumed in this routine.
% In spatial-uncertainty experiments, we typically put fixation at the near
% point.
xyDeg=xyDeg-o.nearPointXYDeg;
rDeg=sqrt(sum(xyDeg.^2));
rPix=o.pixPerCm*o.viewingDistanceCm*tand(rDeg);
if rDeg>0
    xyPix=xyDeg*rPix/rDeg;
    xyPix(2)=-xyPix(2); % Apple y goes down.
else
    xyPix=[0 0];
end
xyPix=xyPix+o.nearPointXYPix;
end
