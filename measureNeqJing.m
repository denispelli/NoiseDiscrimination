% measurePeripheralThresholds
% November 28, 2017, denis.pelli@nyu.edu
% Script for Jing to measure equivalent noise in the periphery, for the
% crowding project.

clear o
o.experiment='measureNeqJing';
o.trialsDesired=40;
o.isNoiseDynamic = true; % false for static noise
o.moviePreAndPostSecs = [0.1 0.2]; % ignored for static noise
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'

% LETTER
o.targetHeightDeg=4; % Target size, range 0 to inf.
o.eccentricityXYDeg=[0 0]; % (x,y) eccentricity 
o.targetKind='letter';
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ';
o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% FIXATION
o.fixationMarkDeg = 1; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
% o.fixationThicknessDeg = 0.05; % fixation line thickness
% o.isFixationBlankedNearTarget = 0; % 0 or 1.
% o.fixationMarkBlankedUntilSecAfterTarget = 0.6; % Pause after stimulus before display of fixation.
o.isTargetLocationMarked=1;
o.targetMarkDeg=0.5;
o.fixationBlankingRadiusReEccentricity=0;
o.fixationBlankingRadiusReTargetHeight=0;
o.speakInstructions=0;

% DEBUGGING
% o.useFractionOfScreenToDebug=0.3; % 0: normal, 0.5: small for debugging.

% REPEAT
% If the two threshold contrasts, after repetition, differ by 2x or more,
% then please collect a third point.

% IMPORTANT: Use a tape measure or meter stick to measure the distance from
% your eye to the screen. The actual distance must accurately agree with
% o.viewingDistanceCm.
o.viewingDistanceCm=70; % viewing distance
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ';
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
% Eccentricity = 1, 5 deg
% Duration = 0.5 s
% targetHeightDeg = 4 deg
% checkHeightDeg = targetHeightDeg/20 
% With and without noise
o.targetDurationSecs=0.5;
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

