%#### Adjust values within this block #####################
clear o
useBackupSessions=0;
o.observer='junk';
%o.observer='ideal';
% o.observer='hyiltiz'; % use your name
o.distanceCm=70; % viewing distance
o.trialsDesired=4;
o.durationSec=1;
o.dynamicPreSignalNoisePoolDur = 0.1; % in seconds, before signal begins
o.dynamicPostSignalNoisePoolDur = 0.1; % in seconds, after signal end
o.dynamicSignalPoolSize = 100; % or 1 for static noise
% dynamicSignalPoolSize is number of frames for signal.
%o.useFlankers=1; % 0 or 1. Enable for crowding experiments.
%o.thresholdParameter='spacing';

o.targetHeightDeg=7.37; % letter/gabor size [2 4 8].
o.eccentricityXYDeg=[16 0]; % eccentricity [0 16 32]
o.noiseSD=0.1; % noise contrast [0 0.16]
o.noiseCheckDeg=o.targetHeightDeg/20;
%o.noiseCheckDeg=o.targetHeightDeg/40;
o.targetKind='letter';
% o.targetFont='Sloan';
o.targetFont='Bookman';
o.allowAnyFont=1;
o.alphabet='abcdefghijklmnopqrstuvwxyz';
o.alternatives=26;
o.printTargetBounds=0;

o.noiseEnvelopeSpaceConstantDeg=inf; % always Inf for hard edge top-hat noise
% o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]
o.noiseRadiusDeg=inf;

o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
o.fixationCrossBlankedNearTarget=0; % always present fixation

o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.


% o.targetKind='letter'; % use letter target


%o.noiseCheckDeg=o.targetHeightDeg/20;
% o.isWin=0; % use the Windows code even if we're on a Mac
%o.targetGaborPhaseDeg=90; % Phase offset of sinewave in deg at center of gabor.
%o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
%o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
%o.targetModulates='luminance'; % Display a luminance decrement.
% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
% o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
% o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
% o.cropSnapshot=0; % If true (1), show only the target and noise, without unnecessary gray background.
% o.snapshotCaptionTextSizeDeg=0.5;
% o.snapshotShowsFixationBefore=1;
% o.snapshotShowsFixationAfter=0;
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.speakInstructions=1;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.
% o.useFractionOfScreenToDebug=0.3; % 0: normal, 0.5: small for debugging.

o=NoiseDiscrimination(o);
sca;

