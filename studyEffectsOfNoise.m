  clear o
% o.observer='junk';
% o.observer='ideal';


%#### Adjust values within this block of code #####################
o.observer='xiuyun'; %add your name here
o.distanceCm=50; % viewing distance
o.durationSec=0.2;

%For Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For tophat (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

o.noiseRadiusDeg=1; % change this to manipulate noise decay radius [1,sqrt(3), 3,3*sqrt(3), 9, Inf]
o.noiseEnvelopeSpaceConstantDeg=Inf; % always Inf for hard edge

o.targetHeightDeg=1; %letter size [2,sqrt(2*6),6];
o.eccentricityDeg=32; % eccentricity [0,32]
o.noiseSD=0.16; %noise contrast [0.16]

o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='pink'; % pink or white
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
%##################################################################


%#########################################
o.noiseCheckDeg=o.targetHeightDeg/10;
% o.isWin=0; % use the Windows code even if we're on a Mac
o.task='identify';
o.signalKind='luminance'; % Display a luminance decrement.

% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
% o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
% o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
% o.cropSnapshot=0; % If true (1), show only the target and noise, without unnecessary gray background.
% o.snapshotCaptionTextSizeDeg=0.5;
% o.snapshotShowsFixationBefore=1;
% o.snapshotShowsFixationAfter=0;
% o.useFractionOfScreen=0.2; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.speakInstructions=0;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar() (Linux compatibility)
o.trialsPerRun=80;
o=NoiseDiscrimination(o);
sca;
