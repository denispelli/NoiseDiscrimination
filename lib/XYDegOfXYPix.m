function xyDeg=XYDegOfXYPix(o,xyPix)
% Convert position from (x,y) coordinate in o.stimulusRect to deg (relative
% to fixation). Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. We typically put the target at the near point, but that is not
% assumed in this routine.
if isempty(o.nearPointXYPix)
    error('You must set o.nearPointXYPix before calling XYDegOfXYPix.');
end
if isempty(o.pixPerCm) || isempty(o.viewingDistanceCm)
    error('You must set o.pixPerCm and o.viewingDistanceCm before calling XYDegOfXYPix.');
end
xyPix=xyPix-o.nearPointXYPix;
rPix=sqrt(sum(xyPix.^2));
rDeg=atan2d(rPix/o.pixPerCm,o.viewingDistanceCm);
if rPix>0
    xyPix(2)=-xyPix(2); % Apple y goes down.
    xyDeg=xyPix*rDeg/rPix;
else
    xyDeg=[0 0];
end
xyDeg=xyDeg+o.nearPointXYDeg;
end
