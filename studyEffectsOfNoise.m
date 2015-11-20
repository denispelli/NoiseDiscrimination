clear o
% o.observer='junk';
% o.observer='ideal';


%#### Adjust values within this block of code #####################
% o.observer='ideal'; %add your name here
% o.observer='shivam'; %add your name here
o.observer='xiuyun'; %add your name here

o.trialsPerRun=80;

o.distanceCm=50; % viewing distance
o.durationSec=0.2;

%For noise with Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For noise with tophat envelope (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

o.noiseRadiusDeg=inf; % change this to manipulate noise decay radius [1,sqrt(3), 3,3*sqrt(3), 9, Inf]
o.noiseEnvelopeSpaceConstantDeg=Inf; % always Inf for hard edge

o.targetHeightDeg=2; % letter size [2,sqrt(2*6),6];
o.eccentricityDeg=32; % eccentricity [0,32]
o.noiseSD=0.16; % noise contrast [0.16]

o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
% o.targetKind='letter'; % use letter target
%##################################################################
o.targetKind='gabor'; % use gabor target. one cycle within targetSize
o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
o.targetGaborNames='VH'; % "V" for vertical, and "H" for horizontal.
% When plotting the gabor data, use either spatial frequency f in c/deg, or
% period size A in deg. 
% f = o.targetGaborCycles/o.targetSizeDeg;
% A = 1/f;
% We should test the same values of o.targetHeightDeg for gabors as for
% letters.
%#########################################
o.noiseCheckDeg=o.targetHeightDeg/20;
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
o=NoiseDiscrimination(o);
sca;
