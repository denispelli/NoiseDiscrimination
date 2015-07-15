clear o
o.isWin=0; % use the Windows code even if we're on a Mac
o.printGammaLoadings=0; % Keep a log of these calls.
% o.useFractionOfScreen=0.2;
o.eccentricityDeg=8;
o.noiseSD=0.05;
o.annularNoiseSD=0.5;
o.targetHeightDeg=2;
o.noiseRadiusDeg=2;
o.annularNoiseSmallRadiusDeg=4; 
o.annularNoiseBigRadiusDeg=5; 
o.yellowAnnulusSmallRadiusDeg=2; % inf for no yellow;
o.yellowAnnulusBigRadiusDeg=3; % inf for no yellow;
o.noiseCheckDeg=0.1;
o.fixationWidthDeg=1;
o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
o.flipClick=0;
o.trialsPerRun=4; % Typically 40.
o.speakInstructions=0;
% o.saveSnapshot=1;
% o.cropSnapshot=1; % Show only the target and noise, without unnecessary gray background.
o=NoiseDiscrimination(o);
sca;