clear o
% o.observer='junk';
% o.observer='ideal';
o.observer='denis';
o.distanceCm=30; % viewing distance
o.targetHeightDeg=2;
o.durationSec=1;
o.noiseRadiusDeg=inf;
o.eccentricityDeg=32; % 0, 2, 8, 32
o.noiseEnvelopeSpaceConstantDeg=2; % 0.5, 2, 8, inf

o.noiseCheckDeg=o.targetHeightDeg/10;
% o.isWin=0; % use the Windows code even if we're on a Mac
o.task='identify';
o.signalKind='luminance'; % Display a luminance decrement.
o.noiseType='gaussian';
o.noiseSD=0.3;
o.saveSnapshot=1; % 0 or 1.  If true (1), take snapshot for public presentation.

if 1
    % To produce a Gaussian annulus:
    o.noiseRadiusDeg=inf;
    o.annularNoiseEnvelopeRadiusDeg=3;
    o.noiseEnvelopeSpaceConstantDeg=1.7;
    o.annularNoiseBigRadiusDeg=inf;
    o.annularNoiseSmallRadiusDeg=inf;
    % Returns: o.centralNoiseEnvelopeE1degdeg
    o.trialsPerRun=4;
    o=NoiseDiscrimination(o)
    fprintf('Soft envelope "area": %.2f deg^2\n',o.centralNoiseEnvelopeE1degdeg);
end
%
if 1
    % To produce a hard-edge annulus:
    o.noiseRadiusDeg=0;
    o.annularNoiseEnvelopeRadiusDeg=0;
    o.noiseEnvelopeSpaceConstantDeg=inf;
    o.annularNoiseBigRadiusDeg=3.2; % Noise extent re target. Typically 1 or inf.
    o.annularNoiseSmallRadiusDeg=2.8; % Typically 1 or 0 (no hole).
    % Returns: o.centralNoiseEnvelopeE1degdeg
    o.trialsPerRun=4;
    o=NoiseDiscrimination(o)
    fprintf('Hard envelope "area": %.2f deg^2\n',o.centralNoiseEnvelopeE1degdeg);
end
% For a "fair" contest of annuli, we should:
%
% 1. make the central radius of the soft one
% o.annularNoiseEnvelopeRadiusDeg match the central radius of the hard one:
% (o.annularNoiseSmallRadiusDeg+o.annularNoiseBigRadiusDeg)/2
%
% 2. adjust the annulus thickness of the hard annulus
% o.annularNoiseSmallRadiusDeg-o.annularNoiseBigRadiusDeg to achieve the
% same "area" as the Gaussian annulus. This "area" is reported in a new
% variable: o.centralNoiseEnvelopeE1degdeg


% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
% o.speakInstructions=0;
% o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
% o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
% o.cropSnapshot=0; % If true (1), show only the target and noise, without unnecessary gray background.
% o.snapshotCaptionTextSizeDeg=0.5;
% o.snapshotShowsFixationBefore=1;
% o.snapshotShowsFixationAfter=0;
% o.trialsPerRun=4;
% o=NoiseDiscrimination(o)
