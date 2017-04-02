clear o
% o.observer='denis'; % use your name
% o.distanceCm=60; % viewing distance
% o.durationSec=0.5; % signal duration. [0.05, 0.5] for 50 ms and 500 ms
% o.trialsPerRun=40;

% NOISE
o.useDynamicNoiseMovie = 1; % 0 for static noise
o.moviePreSec = 0; % ignored for static noise
o.moviePostSec = 0; % ignored for static noise

% o.showCropMarks=1; % mark the bounding box of the target
o.observer='denis'; % use your name
% o.observer='Chen';
o.weightIdealWithNoise=0;
o.distanceCm=70; % viewing distance
o.durationSec=0.2; % [0.05, 0.5] for 50 ms and 500 ms
o.trialsPerRun=40;
o.assessContrast=0;
o.assessLoadGamma=0;

o.font='Sloan';
o.alphabet = 'DHKNORSVZ';
% o.font='ITC Bookman Std';
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
o.eccentricityDeg=0; % eccentricity [0 8 16 32]

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
% o.eccentricityDeg=0; % eccentricity [0 8 16 32]
% o.targetKind='letter';
% o.font='Sloan';
% o.alphabet='DHKNORSVZ';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% TO REPLICATE MANOJ
% o.font='ITC Bookman Std';
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
o.useFractionOfScreen=0.2; % 0: normal, 0.5: small for debugging.
o.flipClick=0;
o.assessContrast=0;
o.assessLoadGamma=0;
% o.showCropMarks=1; % mark the bounding box of the target
o.printDurations=0;

o.measureContrast=1;
o.crsColorimeter=1; % colorimeter attached?
running_trials = 1;
o = NoiseDiscrimination(o);
if length(o.nominalContrast)>1
    folder=fileparts(mfilename('fullpath'));
    folder='';
    [nominal,i]=sort(o.nominalContrast);
    actual=o.actualContrast(i);
    step=unique(sort(abs(actual)));
    step=step(2);
    model=round(actual/step)*step;
    nominalRange=-10.^(-3:0.001:0);
    model=round(nominalRange/step)*step;
    loglog(-nominal,-actual,'o',-nominalRange,-model,'-');
    daspect([1 1 1]);
    hold on
    loglog([.001 1],[.001 1],'-g');
    xlabel('Nominal contrast');
    ylabel('Actual contrast');
    text(0.002,0.5,sprintf('Red line is %.4f*round(contrast/%.4f)',step,step));
    text(0.002,0.25,o.cal.machineName);
    savefig(fullfile(folder,[o.cal.machineName 'loglog' 'ContrastFloor']));
    hold off
    figure(2)
    plot(-nominal,-actual,'o',-nominalRange,-model,'-');
    daspect([1 1 1]);
    hold on
    loglog([0 1],[0 1],'-g');
    xlabel('Nominal contrast');
    ylabel('Actual contrast');
    text(0.001,.018,sprintf('Red line is %.4f*round(contrast/%.4f)',step,step));
    text(0.001,0.016,o.cal.machineName);
    xlim([0 0.02]);
    ylim([0 0.02]);
    hold off
    savefig(fullfile(folder,[o.cal.machineName 'ContrastFloor']));
    save(fullfile(folder,[o.cal.machineName 'ContrastFloor']),'o');
end