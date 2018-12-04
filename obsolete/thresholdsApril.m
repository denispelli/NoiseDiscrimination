% thresholdsApril
% April 21, 2017, denis.pelli@nyu.edu
% Script for Ning and Chen to measure equivalent noise in the periphery.

clear o
o.durationSec=0.5; % signal duration. [0.05, 0.5]
o.trialsPerBlock=40;

% NOISE
o.useDynamicNoiseMovie = 1; % 0 for static noise
o.moviePreSec = 0.1; % ignored for static noise
o.moviePostSec = 0.2; % ignored for static noise
o.noiseType='binary'; % 'gaussian' or 'uniform' or 'binary'
o.noiseSpectrum='white'; % pink or white
o.noiseCheckDeg=0.09;
o.noiseSD=0.5; % max is 0.16 for gaussian, 0.5 for binary.
o.noiseEnvelopeSpaceConstantDeg=128; % always Inf for hard edge top-hat noise
o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]

% LETTER
o.targetHeightDeg=8; % Target size, range 0 to inf.
eccentricityDeg=0; % eccentricity [0 8 16 32]
o.targetKind='letter';
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ';
o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% TO REPLICATE MANOJ
% o.targetFont='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet
% o.targetHeightDeg=2*7.64; % Manoj used xHeight of 7.64 deg.

% FIXATION
o.fixationCrossDeg = 1; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
o.fixationCrossBlankedNearTarget = 0; % 0 or 1.
o.fixationCrossBlankedUntilSecAfterTarget = 0.6; % Pause after stimulus before display of fixation.
% Skipped when fixationCrossBlankedNearTarget. Not needed when eccentricity is bigger than the target.

% USER INTERFACE
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.isKbLegacy=0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.

% SNAPSHOT
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.saveStimulus=0;
o.snapshotLetterContrast=0.01; % nan to request program default. If set, this determines o.tSnapshot.
o.cropSnapshot=1; % If true (1), show only the target and noise, without unnecessary gray background.
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
o.speakInstructions=0;

% DEBUGGING
o.useFractionOfScreen=0; % 0: normal, 0.5: small for debugging.
o.flipClick=0;
o.assessContrast=0;
o.assessLoadGamma=0;
o.showCropMarks=0; % mark the bounding box of the target
o.printDurations=0;

if 1
   % NEW DATA COLLECTION, APRIL 21, 2017
o.useFractionOfScreen=0; % 0: normal, 0.5: small for debugging.
o.isKbLegacy=1;
o.observer='ning';
   % o.observer='chen';
   o.observer='satrianna';
   o.eyes='left'; % 'left', 'right', 'both'.
   % IMPORTANT: Use a tape measure or meter stick to measure the distance
   % from your eye to the screen. The number below must be accurate.
   o.distanceCm=70; % viewing distance
   o.targetFont='Sloan';
   o.alphabet='DHKNORSVZ';
   o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
   o.durationSec = 0.2;
   eccs=[-60 60 -30 30 -10 10 3 0];
   if streq(o.eyes,'left')
      eccs=-eccs;
   end
   for ecc = eccs;
      o.nearPointXYInUnitSquare=[.5 .5];
      if ecc>10
         o.nearPointXYInUnitSquare=[.95 .5];
      end
      if ecc<-10
         o.nearPointXYInUnitSquare=[.05 .5];
      end
      sizes = [2 4 8 16];
      switch(abs(ecc))
         case(30),
            sizes = [4 8 16];
         case(60),
            sizes= [8 16];
      end
      for LetterSize = sizes
         for noiseSD = [0 0.16]
            o.targetXYDeg=[ecc 0];
            o.targetHeightDeg=LetterSize;
            o.noiseCheckDeg=o.targetHeightDeg/20;
            o.noiseSD=noiseSD;
            o=NoiseDiscrimination(o);
         end
      end
   end
end

