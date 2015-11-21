%#### Adjust values within this block #####################
clear o
% o.observer='junk';
% o.observer='ideal';
o.observer='hyiltiz'; %add your name here
o.distanceCm=50; % viewing distance
o.durationSec=0.2;
o.trialsPerRun=80;

%For Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For tophat (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

o.noiseRadiusDeg=inf; % change this to manipulate noise decay radius [1,1.7,3,5.2,9,Inf]
o.noiseEnvelopeSpaceConstantDeg=Inf; % always Inf for hard edge

o.targetHeightDeg=6; %letter size [2,3.5,6];
o.eccentricityDeg=0; % eccentricity [0,32]
o.noiseSD=0.16; %noise contrast [0.16]

o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness

o.targetKind='gabor'; % one cycle within targetSize
o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
% o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
% o.targetGaborNames='VH'; % Observer types V for vertical or H for horizontal.
o.targetGaborOrientationsDeg=[0 30 60 90]; % Orientations relative to vertical.
o.targetGaborNames='0369'; % Observer types 0 for 0 deg, 3 for 30 deg, 6 for 60 deg, or 9 for 90 deg.
%##################################################################


%## Fixed values, for all current testing. Do not adjust. #######################################
% o.useFractionOfScreen=0.5; % Normally 0, or 0.5 for debugging.
o.noiseCheckDeg=o.targetHeightDeg/20;
o.task='identify';
o.targetModulates='luminance'; % Display a luminance decrement.
% o.isWin=0; % use the Windows code even if we're on a Mac
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
o=NoiseDiscrimination(o);
sca;



