function oo=ComputeNPhoton(oo)
o=oo(1);
if ~isfield(o,'luminanceFactor')
    [oo.luminanceFactor]=deal(1);
end
if ~isfield(o,'filterTransmission')
    [oo.filterTransmission]=deal(1);
end
o=oo(1);
o.luminanceAtEye=o.luminanceFactor*o.filterTransmission*o.LBackground;
switch o.eyes
    case {'left' 'right'}
        e=1;
    case 'both'
        e=2;
    otherwise
        error('Unknown o.eyes "%s".',o.eyes);
end
if isempty(o.pupilDiameterMm)
    try
        % XYDegOfXYPix fails if o.nearPointXYPix is not a field.
        xyDeg=XYDegOfXYPix(o,[0 0])-XYDegOfXYPix(o,o.stimulusRect(3:4));
        a=abs(xyDeg(1)*xyDeg(2)); % Screen area in deg^2.
    catch
        % This is accurate if the observer is fixating the center of the
        % display. Even if the observer is looking elsewhere, this is
        % probably accurate enough for this rough use, especially since we
        % are giving the area of a luminous field that is assumed to be
        % centered on fixation. Estimation of pupil diameter without
        % looking at the pupil is always rough.
        if ~isfield(o,'screenRect')
            % Began saving this May 6, 2018.
            o.screenRect=[0 0 1680 1050]; % MacBook Pro.
        end
        x=2*atan2d(0.5*RectWidth(o.screenRect)/o.pixPerCm,o.viewingDistanceCm);
        y=2*atan2d(0.5*RectHeight(o.screenRect)/o.pixPerCm,o.viewingDistanceCm);
        a=x*y;
    end
    if ~isfield(o,'age')
        o.age=20;
        [oo.age]=deal(o.age);
    end
    mm=PupilDiameter(o.LBackground,a,o.age,e);
    o.pupilDiameterMm=mm;
    o.pupilKnown=false;
end
o.retinalIlluminanceTd=o.luminanceAtEye*pi*o.pupilDiameterMm^2/4;
% Compute equivalent input noise for 100% transduction efficiency.
q=1.26e6;
o.NPhoton=1/(q*o.retinalIlluminanceTd*e);
[oo.luminanceAtEye]=deal(o.luminanceAtEye);
[oo.retinalIlluminanceTd]=deal(o.retinalIlluminanceTd);
[oo.pupilDiameterMm]=deal(o.pupilDiameterMm);
[oo.NPhoton]=deal(o.NPhoton);
end

function xyDeg=XYDegOfXYPix(o,xyPix)
% Convert position from (x,y) coordinate in o.stimulusRect to deg (relative
% to fixation). Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. We typically put the target at the near point, but that is not
% assumed in this routine.
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
