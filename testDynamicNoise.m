clear o
% o.showCropMarks=1; % mark the bounding box of the target
o.observer='denis'; % use your name
o.distanceCm=60; % viewing distance
o.durationSec=0.5; % [0.05, 0.5] for 50 ms and 500 ms 
o.trialsPerRun=40;
o.assessContrast=0;

% A value of 1 will cancel dynamic noise (only 1 flip of noise will be generated)
% Actual value will depend on frame rate and stimulus presentation duration,
% thus will be ALWAYS overwritten later for any value other than 1
o.dynamicSignalPoolSize = 2; % or 1 for static noise
o.dynamicPreSignalNoisePoolDur = 0;
o.dynamicPostSignalNoisePoolDur = 0;

o.allowAnyFont=1;
o.font='Sloan';
o.alphabet = 'DHKNORSVZ';
% o.font='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
o.alternatives=length(o.alphabet); % The number of letters to use from o.alphabet.
o.targetHeightDeg=7.64; % Target size, range 0 to inf. If you ask for too much, it gives you the max possible.
o.noiseType='binary'; % 'gaussian' or 'uniform' or 'binary'
o.noiseSpectrum='white'; % pink or white
o.noiseCheckDeg=0.09;
o.noiseSD=0.0; % noise contrast [0 0.16]
o.eccentricityDeg=0; % eccentricity [0 8 16 32]
o.noiseEnvelopeSpaceConstantDeg=128; % always Inf for hard edge top-hat noise
o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]

%For noise with Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For noise with tophat envelope (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

o.targetKind='letter';
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
% o.fixationCrossBlankedNearTarget=0; % always present fixation
% o.isWin=0; % use the Windows code even if we're on a Mac
% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.saveStimulus=0;
o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
o.cropSnapshot=1; % If true (1), show only the target and noise, without unnecessary gray background.
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.speakInstructions=0;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.
% o.useFractionOfScreen=0.3; % 0: normal, 0.5: small for debugging.
o.flipClick=0;

o = NoiseDiscrimination(o);
sca;
