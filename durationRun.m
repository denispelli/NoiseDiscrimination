% durationRun.m
% Measure effect of duration on Neq for each of 3 conditions, with and
% without noise. We expect duration to matter only for cortical noise.
% January 31, 2018
% Denis Pelli

% STANDARD CONDITION
% January 31, 2018
% Measure each Neq twice.
% Six observers.
% gabor target at 1 of 4 orientations
% P=0.75, assuming 4 alternatives
% luminance 250 cd/m2
% monocular, temporal field, right eye

clear all
%% CREATE LIST OF CONDITIONS TO BE TESTED
if verLessThan('matlab','R2013b')
   error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
clear o oo
skipDataCollection=false; % Used to check plotting before we have data.
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this M file

% We list parameters here in the order that we want them to appear
% as columns in the list.
o.condition=1;
o.experiment='xxx';
o.conditionName='xxx';
o.luminanceFactor=1;
o.eccentricityXYDeg=[0 0];
o.noiseSD=0.16;
o.noiseType= 'gaussian';
o.eyes='right';
o.targetDurationSec=0.2;
o.targetCyclesPerDeg=3;
o.viewingDistanceCm=40;
o.minScreenWidthDeg=[];
o.maxViewingDistanceCm=[];
o.targetGaborCycles=3;
o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
o.isTargetFullResolution=false;
o.pThreshold=0.75;
cal=OurScreenCalibrations(0);

%% Psychometric steepness.
% In each of the 3 domains:
% noiseSD: 0 0.16
o.experiment='eyes';
for domain=1:3
   switch domain
      case 1
         % photon
         o.conditionName='photon';
         o.eccentricityXYDeg=[0 0];
         o.targetCyclesPerDeg=4;
         o.targetDurationSec=0.1;
         o.luminanceFactor=1/8;
         % o.minScreenWidthDeg=10;
      case 2
         % cortical
         o.conditionName='cortical';
         o.eccentricityXYDeg=[0 0];
         o.targetCyclesPerDeg=0.5;
         o.targetDurationSec=0.4;
         o.luminanceFactor=1;
         %  o.minScreenWidthDeg=10;
      case 3
         % ganglion
         o.conditionName='ganglion';
         o.eccentricityXYDeg=[30 0];
         o.targetCyclesPerDeg=0.5;
         o.targetDurationSec=0.2;
         o.luminanceFactor=1;
         % o.minScreenWidthDeg=50;
   end
   o.eyes='right'; % 'left', 'right', 'both'.
   for targetDurationSec=Shuffle([0.1 0.2 0.4])
      o.targetDurationSec=targetDurationSec;
      for noiseSD=Shuffle([0 0.16])
         o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
         o.minScreenWidthDeg=1+abs(o.eccentricityXYDeg(1))+o.targetHeightDeg*0.75;
         o.maxViewingDistanceCm=round(cal.screenWidthMm/10/(2*tand(o.minScreenWidthDeg/2)));
         o.viewingDistanceCm=min([o.maxViewingDistanceCm 50]);
         o.noiseCheckDeg=o.targetHeightDeg/20;
         o.noiseSD=noiseSD;
         if ~exist('oo','var')
            oo=o;
         else
            oo(end+1)=o;
         end
      end
   end
end

%% Number the conditions, and print the list.
for i=1:length(oo)
   oo(i).condition=i;
end
t=struct2table(oo);
t % Print the oo list of conditions.

if skipDataCollection
   % NOT IMPLEMENTED.
   % PRODUCE FAKE RUN TO CHECK THE ANALYSIS & PLOTTING.
   data=table2struct(t);
   for i=1:length(data)
      data(i).E=10*data(i).noiseSD+1e-5*(1+floor((i-1)/8));
      data(i).trialsDesired=40;
      data(i).N=data(i).noiseSD;
      data(i).experimenter='Experimenter';
      data(i).observer='Observer';
      data(i).targetKind='gabor';
      data(i).noiseType='gaussian';
      data(i).LBackground=280*data(i).luminanceFactor;
   end
   steepnessAnalyze(data);
end
if ~skipDataCollection && 0
   %% RUN THE CONDITIONS
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" above.
   clear oOut
   for oi=1:length(oo) % Edit this line to select conditions you want to run now.
      o=oo(oi);
      %       o.useFractionOfScreenToDebug=0.4; % 0: normal, 0.5: small for debugging.
      o.trialsDesired=40;
      o.experimenter='';
      o.observer=''; % Enter observer's name at run time.
      if exist('oOut','var') && isempty(o.observer)
         % Copy from previous run.
         o.observer=oOut.observer;
      end
      if exist('oOut','var') && isempty(o.experimenter)
         % Copy from previous run.
         o.experimenter=oOut.experimenter;
      end
      o.fixationBlankingRadiusReEccentricity=0; % No blanking.
      if 0
         % Target letter
         o.targetKind='letter';
         o.targetFont='Sloan';
         o.alphabet='DHKNORSVZ';
      else
         % Target gabor
         o.targetKind='gabor';
         o.targetGaborOrientationsDeg=[0 45 90 135];
         o.targetGaborNames='1234';
         o.alphabet=o.targetGaborNames;
      end
      o.alternatives=length(o.alphabet);
      o.isNoiseDynamic=true;
      if all(o.eccentricityXYDeg==0)
         o.isTargetLocationMarked=false;
      else
         o.isTargetLocationMarked=true;
      end
      o.fixationBlankingRadiusReTargetHeight=0;
      o.moviePreSec=0.2;
      o.moviePostSec=0.2;
      o.targetMarkDeg=1;
      o.fixationMarkDeg=3;
      if false
         % We use QuestPlus to measure steepness.
         o.questPlusEnable=true;
         o.questPlusSteepnesses=1:0.1:5;
         o.questPlusGuessingRates=1/o.alternatives;
         o.questPlusLapseRates=0:0.01:0.05;
         o.questPlusLogIntensities=-2.5:0.05:0.5;
         o.questPlusPrint=true;
         o.questPlusPlot=true;
      end
      oOut=NoiseDiscrimination(o);
      if oOut.quitExperiment
         break
      end
   end
end % Run the selected conditions