% testFixationCross
% Denis Pelli August 2015
clear o
o.task='identify';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast'
o.eccentricityDeg=0;
o.targetHeightDeg=2;
o.noiseRadiusDeg=0;
o.noiseSD=0;
o.distanceCm=45;
o.durationSec=2;
o.fixationCrossDeg=inf; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.03; % Typically 0.03. This should be much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=1; % 0 or 1.
o.speakInstructions=0;
o.task='identify';
o=NoiseDiscrimination(o);
