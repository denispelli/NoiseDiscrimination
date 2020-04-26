clear o
% o.observer='denis'; % use your name
% o.distanceCm=60; % viewing distance
% o.durationSec=0.5; % signal duration. [0.05, 0.5] for 50 ms and 500 ms
% o.trialsDesired=40;

% NOISE
o.isNoiseDynamic = 1; % 0 for static noise
o.moviePreSec = 0; % ignored for static noise
o.moviePostSec = 0; % ignored for static noise

% o.showCropMarks=1; % mark the bounding box of the target
o.observer='denis'; % use your name
% o.observer='Chen';
o.weightIdealWithNoise=0;
o.distanceCm=70; % viewing distance
o.durationSec=0.2; % [0.05, 0.5] for 50 ms and 500 ms
o.trialsDesired=40;
o.assessContrast=0;
o.assessLoadGamma=0;

o.targetFont='Sloan';
o.alphabet = 'DHKNORSVZ';
% o.targetFont='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet
o.targetHeightDeg=7.64; % Target size, range 0 to inf. If you ask for too much, it gives you the max possible.
% o.targetHeightDeg=7.64*2;

o.noiseType='binary'; % 'gaussian' or 'uniform' or 'binary'
% o.noiseType='gaussian';
o.noiseSpectrum='white'; % pink or white
o.noiseCheckDeg=0.092;

o.noiseSD=0; % max is 0.16 for gaussian, 0.5 for binary.

% o.noiseCheckDeg=0.09*8;
% o.noiseSD=0; % noise contrast [0 0.16]
o.eccentricityXYDeg=[0 0]; % eccentricity [0 8 16 32]

o.noiseEnvelopeSpaceConstantDeg=128; % always Inf for hard edge top-hat noise
o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]
% For noise with Gaussian envelope (soft)
% o.noiseRadiusDeg=inf;
% noiseEnvelopeSpaceConstantDeg: 1
%
% For noise with tophat envelope (sharp cut off beyond disk with radius 1)
% o.noiseRadiusDeg=1;
% noiseEnvelopeSpaceConstantDeg: Inf

% LETTER
% o.targetHeightDeg=7.64; % Target size, range 0 to inf.
% o.eccentricityXYDeg=[0 0]; % eccentricity [0 8 16 32]
% o.targetKind='letter';
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% TO REPLICATE MANOJ
% o.targetFont='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet
% o.targetHeightDeg=2*7.64; % Manoj used xHeight of 7.64 deg.

% FIXATION & USER INTERFACE
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
% o.fixationCrossBlankedNearTarget=0; % always present fixation
% o.isWin=0; % use the Windows code even if we're on a Mac
% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.isKbLegacy=0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.

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
o.useFractionOfScreenToDebug=0; % 0: normal, 0.5: small for debugging.
o.flipClick=0;
o.assessContrast=1;
o.assessLoadGamma=0;
% o.showCropMarks=1; % mark the bounding box of the target
o.printDurations=1;

% duration_value = [0.034,0.05,0.1,0.2,0.4,0.8];
% exp_value = [duration_value,duration_value;zeros(1,6),ones(1,6)*0.5]';
% exp_value = Shuffle(exp_value);
% for ii = 1:length(exp_value)
%     o.durationSec = exp_value(ii,1);
%     o.noiseSD = exp_value(ii,2);

o = NoiseDiscrimination(o);

