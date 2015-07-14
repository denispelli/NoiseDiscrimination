clear o
o.isWin=1; % use the Windows code even if we're on a Mac
o.printGammaLoadings=0; % Keep a log of these calls.
o.useFractionOfScreen=1;
o.noiseSD=0.4;
o.eccentricityDeg=8;
o.fixationWidthDeg=1;
o.noiseToTargetRatio=1.35;
o.noiseCheckPix=1;
o.noiseHoleToTargetRatio=1.25; % Typically 1 or 0 (no hole).
o.noiseOnTargetRegardless=0; % 0 (no noise in noise hole) or 1 (put noise on the target, despite any hole).
%o.yellowHoleToTargetRatio=2; % Typically 1, or 2, or inf (for no yellow);
o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
o.flipClick=0;
o.trialsPerRun=70; % Typically 40.
o.speakInstructions=1;
o=NoiseDiscrimination(o);
sca;