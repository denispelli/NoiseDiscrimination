% countReceptiveFields
% Denis Pelli June 2015
clear o
o.saveSnapshot=1;
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
% o.signalKind='entropy'; % Display an entropy increment.
% o.task='4afc';
o.beta=1.8;
o.task='identify';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast'
o.eccentricityDeg=0;
o.noiseCheckDeg=0.37; % gives noiseCheckPix==13 on MacBook Air
% o.noiseCheckPix=13;
o.targetHeightDeg=30*o.noiseCheckDeg;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.annularNoiseSD=0; % Typically nan (i.e. use o.noiseSD) or 0.2.
o.distanceCm=45;
o.noiseSD=0.2;
o.durationSec=0.2;
o.noiseType='gaussian';
o.fixationCrossDeg=inf; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.05; % Typically 0.05. This should be much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=0; % 0 or 1.
% if  ~isfield(o,'idealEOverNThreshold') || ~isfinite(o.idealEOverNThreshold)
%     o.observer='ideal';
%     o.trials=1000;
%     o.runs=1;
%     o=NoiseDiscrimination(o);
%     if isfield(o,'EOverN')
%         o.idealEOverNThreshold=o.EOverN;
%     end
% end
o.observer='Denis';
% You can call NoiseDiscrimination several times, with different conditions
% for each call. It is suggested that you set in advance the number of
% blocksDesired and that you increment the blockNumber from run to run. These
% two numbers are displayed at the top of the screen during every trial to
% keep the observer informed of progress. NoiseDiscrimination says
% "congratulations" at the end of the last run (i.e. when
% blockNumber==blocksDesired).
o.blocksDesired=1;
o.speakInstructions=0;
o.signalKind='noise';  % Display a noise increment.
o.cropSnapshot=1;
o.blockNumber=1;
o.cropSnapshot=1;
o.saveSnapshot=1;
o.durationSec=2;
if 1
    o.task='identify';
else
    o.task='4afc';
    o.gapFraction4afc=1/30; % Typically 0, 0.03, or 0.2. Gap, as a fraction of o.targetHeightDeg, between the four squares in 4afc task, ignored in identify task.
    o.textSizeDeg=0.6;
    o.showResponseNumbers=0;
    o.fixationCrossDeg=0; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
end
o.tGuess=log10(2);
o.tSnapshot=log10(2-1);
% o=NoiseDiscrimination(o);
% o.tSnapshot=log10(1.5-1);
% o=NoiseDiscrimination(o);
o.tSnapshot=log10(1.1-1);
o=NoiseDiscrimination(o);
