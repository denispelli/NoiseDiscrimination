%#### Adjust values within this block #####################
clear o
o.observer='junk';
% o.observer='ideal';
% o.observer='hormet'; % use your name
% o.observer='xiuyun'; % use your name
% o.observer='shivam'; % use your name
o.distanceCm=50; % viewing distance
o.durationSec=0.2;
o.trialsPerRun=80;

%For noise with Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For noise with tophat envelope (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

% ############# we test target size x ecc w/o noise #######
% o.targetHeightDeg=6; % OLD: letter or gabor size [2 3.5 6];
o.targetHeightDeg=8; % letter/gabor size [2 4 8].
o.eccentricityDeg=0; % eccentricity [0 16 32]
o.noiseSD=0.16; % noise contrast [0 0.16]
% We want to compare these:
    o.noiseCheckDeg=o.targetHeightDeg/20; 
    o.noiseCheckDeg=o.targetHeightDeg/40;
% #########################################################

% ############# We plan to test these soon #######
% Also size 16 at [0 32] ecc. Also sizes [0.5 1] at 0 deg ecc. Also size 1 at 16 ecc.
% #########################################################

% ############## Below is constant for this week ##########
% o.targetKind='letter';
o.targetKind='gabor'; % a grating patch
% These two sets of orientation produce the same gabors, they differ only
% in the order in which they appear on the response screen. The first set
% begins at 0 vertical. The second set begins at horizontal. Use whichever
% you prefer.
o.targetGaborOrientationsDeg=[0 30 60 90 120 150]; % Orientations relative to vertical.
o.targetGaborOrientationsDeg=[-90 -60 -30 0 30 60]; % Orientations relative to vertical.
o.targetGaborNames='123456'; % Observer types 1 for 0 deg, 2 for 30 deg, etc.
%##########################################################

% o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
% o.targetGaborNames='VH'; % Observer types V for vertical or H for horizontal.

o.targetHeightDeg=2; % letter size [2,sqrt(2*6),6];
o.eccentricityDeg=32; % eccentricity [0,32]
o.noiseSD=0.16; % noise contrast [0.16]

%## Fixed values, for all current testing. Do not adjust. #####
% Gaussian noise envelope: soft cut off
% o.noiseRadiusDeg=inf;
% noiseEnvelopeSpaceConstantDeg: 1

% Top-hat noise envelope: sharp cut off
o.noiseEnvelopeSpaceConstantDeg=Inf; % always Inf for hard edge
% o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]
o.noiseRadiusDeg=inf;

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
o.targetGaborPhaseDeg=90; % Phase offset of sinewave in deg at center of gabor.
o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
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
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.speakInstructions=0;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.
% o.useFractionOfScreen=0.3; % 0: normal, 0.5: small for debugging.
o=NoiseDiscrimination(o);
sca;



