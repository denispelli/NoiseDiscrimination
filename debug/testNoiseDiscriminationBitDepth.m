clear o % this works
o.testBitDepth=1;
o.isWin=0; % use the Windows code even if we're on a Mac
% o.useFractionOfScreen=0.3;
o.printGammaLoadings=0; % Keep a log of these calls.
o.eccentricityDeg=0;
o.noiseSD=0.3;
o.annularNoiseSD=0;
o.targetHeightDeg=6;
o.noiseRadiusDeg=0;
% o.annularNoiseSmallRadiusDeg=4;
% o.annularNoiseBigRadiusDeg=5;
% o.yellowAnnulusSmallRadiusDeg=6; % Typically 1, or 2, or inf (for no yellow);
% o.yellowAnnulusBigRadiusDeg=7; % Typically inf.
o.textSizeDeg=1;
o.fixationDiameterDeg=inf;
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
o.flipClick=0;
o.trialsDesired=10; % Typically 40.
o.speakInstructions=0;
o.saveSnapshot=0;
o.cropSnapshot=0; % Show only the target and noise, without unnecessary gray background.
% o.showCropMarks=1;
o=NoiseDiscrimination(o);
sca;