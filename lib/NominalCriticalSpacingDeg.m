function nominalCriticalSpacingDeg=NominalCriticalSpacingDeg(eccentricityXYDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% Modified x intercept by Pelli et all. 2017.
% See also: NominalAcuityDeg
radialEccDeg=sqrt(sum(eccentricityXYDeg.^2))
nominalCriticalSpacingDeg=0.3*(radialEccDeg+0.15);
