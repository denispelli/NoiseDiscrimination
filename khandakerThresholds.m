clear o
o.experimenter='Khandaker'; % use your name
o.observer='Khandaker'; % use your name
o.viewingDistanceCm=60; % viewing distance
o.durationSec=.2;
o.trialsPerRun=50;
o.targetHeightDeg=2; % letter/gabor size [2 4 8].
o.noiseSD=0.16; % noise contrast [0 0.16]
o.noiseRadiusDeg = inf;
o.noiseCheckDeg=o.targetHeightDeg/20;
o.targetKind='letter';
o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.markTargetLocation=1;
o.blankingRadiusReEccentricity=0;
o.blankingRadiusReTargetHeight=0;

o.fixationCrossDeg=2;
o.fixationCrossWeightDeg = 0.05; % target line thickness
o.fixationCrossBlankedNearTarget=0; % always present fixation
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
o.speakInstructions=0;
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
o.nearPointXYInUnitSquare=[0.5 0.5];
o.screen=0;
o.fixationCrossBlankedUntilSecAfterTarget=0;
o.fixationCrossBlankedNearTarget=0;
o.eccentricityXYDeg = [8 0];
for i=1:2
   o=NoiseDiscrimination(o);
end
sca;

