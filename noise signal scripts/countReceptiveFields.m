% countReceptiveFields
% Denis Pelli June 2015
clear all
o.saveSnapshot=0;
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
% o.targetKind='entropy'; % Display an entropy increment.
o.task='4afc';
o.steepness=1.8;
% o.task='identify';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast'
o.eccentricityXYDeg=[0 0];
o.noiseCheckDeg=0.37; % gives noiseCheckPix==13 on MacBook Air
% o.noiseCheckPix=13;
o.targetHeightDeg=30*o.noiseCheckDeg;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.annularNoiseSD=0; % Typically nan (i.e. use o.noiseSD) or 0.2. 
o.viewingDistanceCm=45;
o.noiseSD=0.2;
o.viewingDistanceCm=inf;
o.noiseType='gaussian';
o.fixationCrossDeg=inf; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.05; % Typically 0.05. This should be much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=0; % 0 or 1.
% if  ~isfield(o,'idealEOverNThreshold') || ~isfinite(o.idealEOverNThreshold)
%     o.observer='ideal';
%     o.trials=1000;
%     o.blocks=1;
%     o=NoiseDiscrimination(o);
%     if isfield(o,'EOverN')
%         o.idealEOverNThreshold=o.EOverN;
%     end
% end
o.observer='Denis';
o.observer='ideal';
% You can call NoiseDiscrimination several times, with different conditions
% for each call. It is suggested that you set in advance the number of
% runsDesired and that you increment the runNumber from run to run. These
% two numbers are displayed at the top of the screen during every trial to
% keep the observer informed of progress. NoiseDiscrimination says
% "congratulations" at the end of the last run (i.e. when
% runNumber==runsDesired).
o.blocksDesired=1000;
o.speakInstructions=0;
% o.observer='ideal';
% o.trialsPerRun=1000;
logEOverN=[];
for i=1:o.blocksDesired
    o.blockNumber=i;
    o.targetKind='noise';  % Display a noise increment.
    o=NoiseDiscrimination(o);
    logApproxRequiredNumber(i)=o.logApproxRequiredNumber;
    o.efficiency=10^(o.logApproxRequiredNumber-3.11);
    if o.quitNow
        break;
    end
    o.targetKind='luminance'; % Display a luminance decrement.
    o.idealEOverN=10^1.12;
    o=NoiseDiscrimination(o);
    logEOverN(i)=log10(o.EOverN);
    if o.quitNow
        break;
    end
end
fprintf('log n %.2f ± %.2f\n',mean(logApproxRequiredNumber),std(logApproxRequiredNumber)/sqrt(length(logApproxRequiredNumber)));
fprintf('log E/N %.2f ± %.2f\n',mean(logEOverN),std(logEOverN)/sqrt(length(logEOverN)));
fprintf('noise log efficiency %.2f ± %.2f\n',mean(logApproxRequiredNumber)-3.11,std(logApproxRequiredNumber)/sqrt(length(logApproxRequiredNumber)));
fprintf('luminance log efficiency %.2f ± %.2f\n',1.12-mean(logEOverN),std(logEOverN)/sqrt(length(logEOverN)));
% After 3 runs of the ideal with 1000 trials/run, I get:
% log n 3.11 ± 0.00
% log E/N 1.12 ± 0.00
