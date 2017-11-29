% measurePeripheralThresholds
% November 28, 2017, denis.pelli@nyu.edu
% Script for Jing to measure equivalent noise in the periphery, for the
% crowding project.

clear o
o.durationSec=0.5; % signal duration. [0.05, 0.5]
o.trialsPerRun=40;

% NOISE
o.useDynamicNoiseMovie = 1; % 0 for static noise
o.moviePreSec = 0.1; % ignored for static noise
o.moviePostSec = 0.2; % ignored for static noise
o.noiseType='binary'; % 'gaussian' or 'uniform' or 'binary'
o.noiseSpectrum='white'; % pink or white
o.noiseCheckDeg=0.09;
o.noiseSD=0.5; % max is 0.16 for gaussian, 0.5 for binary.
o.noiseEnvelopeSpaceConstantDeg=128; % always Inf for hard edge top-hat noise
o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]

% LETTER
o.targetHeightDeg=4; % Target size, range 0 to inf.
o.eccentricityXYDeg=[0 0]; % (x,y) eccentricity 
o.targetKind='letter';
o.font='Sloan';
o.alphabet='DHKNORSVZ';
o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% FIXATION
o.fixationCrossDeg = 1; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg = 0.05; % fixation line thickness
o.fixationCrossBlankedNearTarget = 0; % 0 or 1.
o.fixationCrossBlankedUntilSecAfterTarget = 0.6; % Pause after stimulus before display of fixation.
% Skipped when fixationCrossBlankedNearTarget. Not needed when eccentricity is bigger than the target.
o.markTargetLocation=1;
o.targetMarkDeg=0.5;
o.blankingRadiusReEccentricity=0;
o.blankingRadiusReTargetHeight=0;

% USER INTERFACE
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
% o.fixationCrossWeightDeg=0.05; % target line thickness
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.

% SNAPSHOT
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.saveStimulus=0;
o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
o.cropSnapshot=1; % If true (1), show only the target and noise, without unnecessary gray background.
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
o.speakInstructions=0;

% DEBUGGING
o.useFractionOfScreen=0.3; % 0: normal, 0.5: small for debugging.
o.assessContrast=0;
o.assessLoadGamma=0;
o.showCropMarks=0; % mark the bounding box of the target
o.printDurations=0;

% REPEAT
% If the two threshold contrasts, after repetition, differ by 2x or more,
% then please collect a third point.

% IMPORTANT: Use a tape measure or meter stick to measure the distance from
% your eye to the screen. The number below must be accurate.
o.observer='Jing'; % use your name
o.viewingDistanceCm=70; % viewing distance
o.font='Sloan';
o.alphabet='DHKNORSVZ';
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
% o.durationSec=0.5;
% Eccentricity = 1, 5 deg
% Duration = 0.5 s
% targetHeightDeg = 4 deg
% checkHeightDeg = targetHeightDeg/20 
% With and without noise
o.markTargetLocation=1;
o.blankingRadiusReEccentricity=0;
o.blankingRadiusReTargetHeight=0;


o.observer='Jing';
for noise = [0.16 0]
    for ecc= [5 1]
        o.targetHeightDeg= 4;
        o.eccentricityXYDeg = [ecc 0];
        o.noiseSD=noise;
        o.noiseCheckDeg=o.targetHeightDeg/20;
        o=NoiseDiscrimination(o);
        o=NoiseDiscrimination(o);
    end
end

