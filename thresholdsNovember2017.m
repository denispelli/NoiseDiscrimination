% thresholdsApril
% November 17, 2017, denis.pelli@nyu.edu
% Script for darshan, flavia, shenghao, and yichen to measure equivalent noise in the periphery.

% Neq Plan
% October 19, 2017 by Denis & Manoj
% 
% measure each Neq twice.
% six observers.
% 
% Standard condition
% gabor target at 1 of 4 orientations
% (specify gabor sigma is in number of cycles.)
% (A = 1 period x period)
% P=0.7, assuming 4 alternatives
% luminance 206 cd/m2
% monocular, temporal field, preferred eye
% duration 200 ms
% 

clear o
if verLessThan('matlab','R2013b')
   error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
o.durationSec=0.5; % signal duration. [0.05, 0.5]
o.trialsPerRun=50;

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

% SIGNAL
o.targetHeightDeg=8; % Target size, range 0 to inf.
o.eccentricityXYDeg=[0 0]; % eccentricity [0 8 16 32]

% TO REPLICATE MANOJ
% o.font='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet
% o.targetHeightDeg=2*7.64; % Manoj used xHeight of 7.64 deg.

% LETTER
% o.targetKind='letter';
% o.font='Sloan';
% o.alphabet='DHKNORSVZ';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% GABOR
o.targetKind='gabor';
o.targetGaborOrientationsDeg=[0 45 90 135];
o.targetGaborNames='1234';
o.alphabet=o.targetGaborNames;
o.alternatives=length(o.alphabet);

% FIXATION
o.fixationCrossDeg = 1; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.markTargetLocation=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
o.fixationCrossBlankedNearTarget = 0; % 0 or 1.
o.fixationCrossBlankedUntilSecAfterTarget = 0.6; % Pause after stimulus before display of fixation.
% Skipped when fixationCrossBlankedNearTarget. Not needed when eccentricity is bigger than the target.

% USER INTERFACE
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
% o.fixationCrossWeightDeg=0.05; % target line thickness
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
% o.useFractionOfScreen=0.6; % 0: normal, 0.5: small for debugging.
o.flipClick=0;
o.assessContrast=0;
o.assessLoadGamma=0;
o.showCropMarks=0; % mark the bounding box of the target
o.printDurations=0;

o.useFractionOfScreen=0.3; % 0: normal, 0.5: small for debugging.
o.assessLoadGamma = 0; % diagnostic information

clear o oo

o.observer='chen';
o.observer='satrianna';
o.observer='hortense';
o.observer='darshan';
o.observer='flavia';
o.observer='shenghao';
o.observer='yichen';
o.observer='junk'
o.experimenter=o.observer;
% switch o.observer
%    case 'denis'
%       o.preferredEye='right';
%    case 'hortense'
%       o.preferredEye='right'
%    case 'darshan'
%       o.preferredEye='right'
%    case 'flavia'
%       o.preferredEye='right'
%    case 'shenghao'
%       o.preferredEye='right'
%    case 'yichen'
%       o.preferredEye='right'
% end
if 1
   % COLLECTION, NOVEMBER 2017
   %% CREATE LIST OF CONDITIONS TO BE TESTED

   %% Effect of threshold criterion: Graph Neq vs. P.
   % In each of the 3 domains
   % P: 0.35, 0.55, 0.75, 0.95
   % size: 2, 16 deg
   % eccentricity: 0, 30 deg
   % (omit 2 deg letter at 30 deg ecc.)
      o.eyes='right'; % 'left', 'right', 'both'.
   eccs=[30 0];
   sizes = [2 16];
   Ps=[0.35, 0.55, 0.75, 0.95];
   for ecc = eccs
      switch(abs(ecc))
         case(30)
            sizes = [16];
      end
      for size = sizes
         for noiseSD = [0 0.16]
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=size;
            o.noiseCheckDeg=o.targetHeightDeg/20;
            o.noiseSD=noiseSD;
            for p=Ps
               o.pThreshold=p;
               if ~exist('oo','var');
                  oo=o;
               else
                  oo(end+1)=o;
               end
            end
         end
      end
   end

   %% Effect of Eccentricity: Graph Neq vs Eccentricity. temporal field
   % ecc: 0, 3, 10, 30, 60 deg
   % size: 2, 4, 8, 16 deg
   eccs=[60 30 10 3 0];
   sizes = [2 4 8 16];
   for ecc = eccs
      switch(abs(ecc))
         case(30),
            sizes = [4 8 16];
         case(60),
            sizes= [8 16];
      end
      for size = sizes
         for noiseSD = [0 0.16]
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=size;
            o.noiseCheckDeg=o.targetHeightDeg/20;
            o.noiseSD=noiseSD;
            if ~exist('oo','var');
               oo=o;
            else
               oo(end+1)=o;
            end
         end
      end
   end
end

% Graph E vs. N
% In each of the 3 domains
% size: 2, 16 deg
% eccentricity: 0, 30 deg
% (omit 2 deg letter at 30 deg ecc.)

size=8;
for ecc=-60
   o.eyes='right'; % 'left', 'right', 'both'.
   for noiseSD = [0 0.16]
      o.eccentricityXYDeg=[0 ecc];
      o.targetHeightDeg=size;
      o.noiseCheckDeg=o.targetHeightDeg/20;
      o.noiseSD=noiseSD;
      %          o=NoiseDiscrimination(o);
      if ~exist('oo','var');
         oo=o;
      else
         oo(end+1)=o;
      end
   end
   o.eyes='both';
   for noiseSD = [0 0.16]
      o.eccentricityXYDeg=[0 ecc];
      o.targetHeightDeg=size;
      o.noiseCheckDeg=o.targetHeightDeg/20;
      o.noiseSD=noiseSD;
      %          o=NoiseDiscrimination(o);
      if ~exist('oo','var');
         oo=o;
      else
         oo(end+1)=o;
      end
   end
end
for i=1:length(oo)
   oo(i).row=i;
end
t=struct2table(oo)
% return

% RUN THE CONDITIONS
% for oi=24:length(oo)
for oi=45
   o=oo(oi);
   o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
   o.eyes='right'; % 'left', 'right', 'both'.
   o.viewingDistanceCm=70; % viewing distance
   if 0
      o.targetKind='letter';
      o.font='Sloan';
      o.alphabet='DHKNORSVZ';
   else
      o.targetKind='gabor';
      o.targetGaborOrientationsDeg=[0 45 90 135];
      o.targetGaborNames='1234';
      o.alphabet=o.targetGaborNames;
      o.alternatives=length(o.alphabet);
   end
   o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
   o.durationSec = 0.2;
   o.noiseSD=0.16;
   o.useDynamicNoiseMovie = 1;
   o.markTargetLocation=1;
   o.blankingRadiusDeg=0;
   o.moviePreSec = 0.3;
   o.moviePostSec = 0.3;
   o.targetMarkDeg=1;
   o.fixationCrossDeg=3;
   o=NoiseDiscrimination(o);
   if o.quitNow
      break
   end
end