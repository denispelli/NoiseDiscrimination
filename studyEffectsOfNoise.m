  clear o
% o.observer='junk';
% o.observer='ideal';

  
%#### Adjust values within this block of code #####################
o.observer='shivam'; %add your name here
o.distanceCm=50; % viewing distance
o.targetHeightDeg=2; %letter size [2]
o.durationSec=0.2;
o.noiseRadiusDeg=inf;
o.eccentricityDeg=32; % eccentricity [32]
o.noiseEnvelopeSpaceConstantDeg=2; % noise decay radius [2, sqrt(2*16), 16]
o.noiseSD=0.2; %noise contrast [0.2]
%##################################################################


%#########################################
o.noiseCheckDeg=o.targetHeightDeg/10;
% o.isWin=0; % use the Windows code even if we're on a Mac
o.task='identify'; 
o.signalKind='luminance'; % Display a luminance decrement.
%o.noiseType='gaussian';
o.noiseType='pink';

% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
% o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
% o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
% o.cropSnapshot=0; % If true (1), show only the target and noise, without unnecessary gray background.
% o.snapshotCaptionTextSizeDeg=0.5;
% o.snapshotShowsFixationBefore=1;
% o.snapshotShowsFixationAfter=0;
%o.useFractionOfScreen=0.4; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
o.speakInstructions=0;
%o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar() (Linux compatibility)
o.trialsPerRun=80; 
o=NoiseDiscrimination(o);
sca;
