% countReceptiveFields
% Denis Pelli June 2015
clear o
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.

o.experimenter='junk';
o.observer='junk';
% o.observer='ideal';
o.trialsInBlock=40;

o.experiment='countReceptiveFields';
o.blankingRadiusReTargetHeight= 0;
o.blankingRadiusReEccentricity= 0;
o.saveSnapshot=0;
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
% o.targetKind='entropy'; % Display an entropy increment.
o.task='4afc';
o.steepness=1.8;
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast'
o.eccentricityXYDeg=[0 0];
o.noiseCheckDeg=0.37; % gives noiseCheckPix==13 on MacBook Air
o.targetHeightDeg=30*o.noiseCheckDeg;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.annularNoiseSD=0; % Typically nan (i.e. use o.noiseSD) or 0.2.
o.viewingDistanceCm=45;
o.noiseSD=0.2;
o.noiseType='gaussian';
o.fixationCrossWeightDeg=0.05; % Typically 0.05. This should be much thicker for scotopic testing.
o.fixationCrossBlankedUntilSecAfterTarget=0;
o.idealEOverNThreshold=10^1.12;
% if  ~isfield(o,'idealEOverNThreshold') || ~isfinite(o.idealEOverNThreshold)
%     o.observer='ideal';
%     o.trials=1000;
%     o.blocks=1;
%     o=NoiseDiscrimination(o);
%     if isfield(o,'EOverN')
%         o.idealEOverNThreshold=o.EOverN;
%     end
% end
o.speakInstructions=0;
% o.trialsPerRun=1000;
o.fixationCrossDrawnOnStimulus=true;

%% THE oo ARRAY STRUCT HAS ONE ELEMENT PER CONDITION
oo={};

if true
    o.condition='letter noise';
    o.task='identify';
    o.targetKind='letter';
    o.targetModulates='noise';  % Display a noise increment.
    o.contrast=-1;
    o.fixationCrossDeg=inf; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
    o.fixationCrossBlankedNearTarget=true; % false or true.
    o.blankingRadiusReTargetHeight=0.5;
    oo{end+1}=o;
end

o.condition='4afc noise';
o.task='4afc';
o.targetModulates='noise';  % Display a noise increment.
o.fixationCrossDrawnOnStimulus=true;
o.fixationCrossDeg=1; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossBlankedNearTarget=false; % false or true.
o.blankingRadiusReTargetHeight=0;
oo{end+1}=o;

o.condition='4afc luminance';
o.task='4afc';
o.targetModulates='luminance'; % Display a luminance decrement.
o.fixationCrossDrawnOnStimulus=true;
o.fixationCrossDeg=1; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossBlankedNearTarget=false; % false or true.
o.blankingRadiusReTargetHeight=0;
oo{end+1}=o;

for oi=1:length(oo)
    o=oo{oi};
    o.block=oi;
    o.blocksDesired=length(oo);
    o.condition=oi;
    oo{oi}=o;
end

%% RUN THE EXPERIMENT
oo=RunExperiment(oo);

%% COLLECT STATS
clear logEOverN approxRequiredNumber logApproxRequiredNumber
i=1;
for oi=1:length(oo)
    o=oo{oi};
    switch o.targetModulates
        case 'noise'
            if isfield(o,'logApproxRequiredNumber')
                logApproxRequiredNumber(i)=o.logApproxRequiredNumber;
                o.efficiency=10^(o.logApproxRequiredNumber-3.11);
            else
                logApproxRequiredNumber(i)=nan;
                o.efficiency=nan;
            end
        case 'luminance'
            if isfield(o,'EOverN')
                logEOverN(i)=log10(o.EOverN);
            else
                logEOverN(i)=nan;
            end
    end
    oo{oi}=o;
end


%% PRINT RESULTS
fprintf('log n %.2f ± %.2f\n',nanmean(logApproxRequiredNumber),std(logApproxRequiredNumber)/sqrt(length(logApproxRequiredNumber)));
fprintf('log E/N %.2f ± %.2f\n',nanmean(logEOverN),std(logEOverN)/sqrt(length(logEOverN)));
fprintf('noise log efficiency %.2f ± %.2f\n',nanmean(logApproxRequiredNumber)-3.11,std(logApproxRequiredNumber)/sqrt(length(logApproxRequiredNumber)));
fprintf('luminance log efficiency %.2f ± %.2f\n',1.12-nanmean(logEOverN),std(logEOverN)/sqrt(length(logEOverN)));
% After 3 runs of the ideal with 1000 trials/run, I get:
% log n 3.11 ± 0.00
% log E/N 1.12 ± 0.00
