function nominalCriticalSpacingDeg=NominalCriticalSpacingDeg(eccentricityDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% See also: NominalAcuityDeg
nominalCriticalSpacingDeg=0.3*(eccentricityDeg+0.45);
