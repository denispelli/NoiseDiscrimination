% discriminateEntropy
% Denis Pelli August 2015
clear o
o.saveSnapshot=0;
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
o.signalKind='entropy'; % Display an entropy increment.
o.backgroundEntropyLevels=3;
o.task='4afc';
o.durationSec=inf;
o.task='identify';
o.durationSec=0.2;
o.beta=1.8;
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast'
o.eccentricityDeg=0;
o.noiseCheckDeg=0.37; % gives noiseCheckPix==13 on MacBook Air
o.targetHeightDeg=30*o.noiseCheckDeg;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.annularNoiseSD=0; % Typically nan (i.e. use o.noiseSD) or 0.2.
o.distanceCm=45;
o.noiseSD=0.2;
o.noiseType='gaussian';
o.fixationCrossDeg=1; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.05; % Typically 0.05. This should be much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=0; % 0 or 1.
o.speakInstructions=0;
o.runsDesired=1;
o.runNumber=1;
o.signalKind='entropy';
o=NoiseDiscrimination(o);
