function oo=ComputeNPhoton(oo)
for oi=1:length(oo)
    if ~isfield(oo(oi),'filterTransmission')
        oo(oi).filterTransmission=1;
    end
    % I'm unsure whether to include the following line here. It's too long
    % since I've thought about this code.
%     oo(oi).luminanceAtEye=oo(oi).filterTransmission*oo(oi).LBackground;
    switch oo(oi).eyes
        case {'left' 'right' 'one'}
            e=1;
        case 'both'
            e=2;
        otherwise
            error('Unknown o.eyes "%s".',oo(oi).eyes);
    end
    if isempty(oo(oi).pupilDiameterMm)
        try
            % XYDegOfXYPix fails if o.nearPointXYPix is not a field.
            xyDeg=XYDegOfXYPix(oo(oi),[0 0])-XYDegOfXYPix(oo(oi),oo(oi).stimulusRect(3:4));
            a=abs(xyDeg(1)*xyDeg(2)); % Screen area in deg^2.
        catch
            % This is accurate if the observer is fixating the center of
            % the display. Even if the observer is looking elsewhere, this
            % is probably accurate enough for this rough use, especially
            % since we are giving the area of a luminous field that is
            % assumed to be centered on fixation. Estimation of pupil
            % diameter without looking at the pupil is always rough.
            if ~isfield(oo(oi),'screenRect') || isempty(oo(oi).screenRect)
                % Began saving this May 6, 2018.
                oo(oi).screenRect=[0 0 1680 1050]; % MacBook Pro.
            end
            x=2*atan2d(0.5*RectWidth(oo(oi).screenRect)/oo(oi).pixPerCm,oo(oi).viewingDistanceCm);
            y=2*atan2d(0.5*RectHeight(oo(oi).screenRect)/oo(oi).pixPerCm,oo(oi).viewingDistanceCm);
            a=x*y;
        end
        if ~isfield(oo(oi),'age')
            oo(oi).age=20;
        end
        mm=PupilDiameter(oo(oi).LBackground,a,oo(oi).age,e);
        oo(oi).pupilDiameterMm=mm;
        oo(oi).pupilKnown=false;
    end
    oo(oi).retinalIlluminanceTd=oo(oi).luminanceAtEye*pi*oo(oi).pupilDiameterMm^2/4;
    if ~isfield(oo(oi),'A') || isempty(oo(oi).A)
        switch oo(oi).targetKind
            case {'letter' 'image'}
                oo(oi).A=oo(oi).targetHeightDeg^2;
            case {'gabor'}
                oo(oi).targetCyclesPerDeg=oo(oi).targetGaborCycles/oo(oi).targetHeightDeg;
                oo(oi).A=oo(oi).targetCyclesPerDeg^-2;
        end
    end
    if ~isfield(oo(oi),'LAT') || isempty(oo(oi).LAT)
        oo(oi).LAT=oo(oi).retinalIlluminanceTd*oo(oi).A*oo(oi).targetDurationSecs;
    end
    % Compute equivalent input noise for 100% transduction efficiency.
    q=1.26e6;
    oo(oi).NPhoton=1 ./ (q*oo(oi).retinalIlluminanceTd*e);
end % for oi=1:length(oo)
end % function

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
