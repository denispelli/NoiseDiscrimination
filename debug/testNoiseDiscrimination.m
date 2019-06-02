clear all
% o.useFractionOfScreen=.3; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
% o.replicatePelli2006=1;
o.pThreshold=0.64; % As in Pelli et al. (2006).
% o.assessLinearity=0;
% o.assessContrast=0; % diagnostic information
% o.flipClick=0; % For debugging, speak and wait for click before and after each flip.
% o.assessGray=0; % For debugging. Diagnostic printout when we load gamma table.
% o.isWin=0; % use the Windows code even if we're on a Mac
% o.printGammaLoadings=0; % Keep a log of these calls.
% o.eccentricityDeg=0;
% o.task='4afc'; 
o.task='identify'; 
%o.signalKind='noise';  % Display a noise increment.
o.signalKind='luminance'; % Display a luminance decrement.
% % o.signalKind='entropy'; % Display an entropy increment.
o.noiseType='gaussian';
o.noiseSD=0.1;
% o.annularNoiseSD=0.2;
o.targetHeightDeg=10;
o.noiseCheckDeg=1;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.durationSec=inf;
% o.noiseRadiusDeg=1;
% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.noiseEnvelopeSpaceConstantDeg=6; 
% o.annularNoiseSmallRadiusDeg=inf;
% o.annularNoiseBigRadiusDeg=inf;
% o.yellowAnnulusSmallRadiusDeg=6; % Typically 1, or 2, or inf (for no yellow);
% o.yellowAnnulusBigRadiusDeg=7; % Typically inf.
% o.showBlackAnnulus=0;
% o.blackAnnulusContrast=-1; % (LBlack-LMean)/LMean. -1 for black line. >-1 for gray line.
% o.blackAnnulusSmallRadiusDeg=3;
% o.blackAnnulusThicknessDeg=0.1;
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
% o.saveStimulus=0; % saves stimulus from screen to o.savedStimulus
% o.textSizeDeg=0.6;
% o.fixationCrossDeg=inf;
% o.showCropMarks=0; % mark the bounding box of the target
% o.flipClick=0;
% o.speakInstructions=0;
% o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
% o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
% o.cropSnapshot=0; % If true (1), show only the target and noise, without unnecessary gray background.
% o.snapshotCaptionTextSizeDeg=0.5;
% o.snapshotShowsFixationBefore=1;
% o.snapshotShowsFixationAfter=0;
% o.showCropMarks=1;
% o.trialsInBlock=2; % Typically 40.
% o.observer='junk';
% o=NoiseDiscrimination(o);
o.trialsInBlock=40; % Typically 40.
% o.printLikelihood=0;
% o.observer='ideal';
% o.speakInstructions=1;
o=NoiseDiscrimination(o);
% o.observer='blackshot';
% o=NoiseDiscrimination(o);
sca;
