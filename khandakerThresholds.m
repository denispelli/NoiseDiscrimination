clear o
o.experimenter='Khandaker'; % use your name
o.observer='Khandaker'; % use your name
o.distanceCm=60; % viewing distance
o.durationSec=0.2;
o.trialsPerRun=50;
o.targetHeightDeg=8; % letter/gabor size [2 4 8].
o.noiseSD=0.16; % noise contrast [0 0.16]
o.noiseRadiusDeg = inf;
o.noiseCheckDeg=o.targetHeightDeg/20;
o.targetKind='letter';
o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.targetCross=1;
o.fixationCrossDeg=2;
o.fixationCrossWeightDeg = 0.05; % target line thickness
o.fixationCrossBlankedNearTarget=0; % always present fixation
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
o.speakInstructions=0;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.
% o.useFractionOfScreen=0.3; % 0: normal, 0.5: small for debugging.
o.nearPointXYInUnitSquare=[0.5 0.5];
for ecc=[0 8]
   o.targetXYDeg = [ecc 0];
   o=NoiseDiscrimination(o);
end
sca;

