% CountReceptiveFields
% Denis Pelli June 2015
clear all
o.signalKind='noise';  % Display a noise increment.
% o.signalKind='luminance'; % Display a luminance decrement.
% o.signalKind='entropy'; % Display an entropy increment.
% o.task='4afc';
o.beta=1.8;
o.task='identify';
o.eccentricityDeg=0;
o.noiseCheckDeg=0.2*1.6; % adjust to achieve noiseCheckPix==13 on MacBook Air
% o.noiseCheckPix=13;
o.noiseToTargetRatio=1;
o.targetHeightDeg=30*o.noiseCheckDeg;
o.distanceCm=45;
o.noiseSD=0.2;
o.durationSec=0.2;
o.noiseType='gaussian';
o.fixationWidthDeg=1; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationLineWeightDeg=0.05; % Typically 0.05. This should be much thicker for scotopic testing.
o.fixationBlankedNearTarget=0; % 0 or 1.
% if  ~isfield(o,'idealEOverNThreshold') || ~isfinite(o.idealEOverNThreshold)
%     o.observer='ideal';
%     o.trials=1000;
%     o.runs=1;
%     o=NoiseDiscrimination(o);
%     if isfield(o,'EOverN')
%         o.idealEOverNThreshold=o.EOverN;
%     end
% end
o.trials=40;
o.observer='junk';
% You can call NoiseDiscrimination several times, with different conditions
% for each call. It is suggested that you set in advance the number of
% runsDesired and that you increment the runNumber from run to run. These
% two numbers are displayed at the top of the screen during every trial to
% keep the observer informed of progress. NoiseDiscrimination says
% "congratulations" at the end of the last run (i.e. when
% runNumber==runsDesired).
o.runNumber=1;
o.runsDesired=1;
o=NoiseDiscrimination(o);