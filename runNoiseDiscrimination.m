clear o
% o.useFractionOfScreenToDebug=0.4; % 0: normal, 0.5: small for debugging.
o.eccentricityXYDeg=[-5 5];
o.isTargetLocationMarked=1;
o.targetHeightDeg=4;
o.isNoiseDynamic = 1;
o.moviePreSec = 0.3;
o.moviePostSec = 0.3;
o.targetMarkDeg=1;
o.fixationMarkDeg=3;
o.contrast=-1;
o=NoiseDiscrimination(o);