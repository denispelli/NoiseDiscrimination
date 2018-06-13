function criticalSpacingDeg=NominalCriticalSpacingDeg(eccentricityXYDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% The argument can be a scalar radial eccentricity in deg, or a vector of x
% and y eccentricity in deg.
% Modified x intercept by Pelli et al. 2017.
% See also: NominalAcuityDeg
if length(eccentricityXYDeg)<1 || length(eccentricityXYDeg)>2
    error('The eccentricityXYDeg argument must be a scalar (radial) or an x y vector (cartesian).');
end
radialEccDeg=sqrt(sum(eccentricityXYDeg.^2));
criticalSpacingDeg=0.3*(radialEccDeg+0.15);
