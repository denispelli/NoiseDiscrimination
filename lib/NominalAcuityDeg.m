function nominalAcuityDeg=NominalAcuityDeg(eccentricityXYDeg)
% Eq. 13 from Song, Levi, and Pelli (2014).
% See also: NominalCriticalSpacingDeg
radialEccDeg=sqrt(sum(eccentricityXYDeg.^2))
nominalAcuityDeg=0.029*(radialEccDeg+2.72);

