% flankersRun.m
% Show target with flankers. Measure psychometric function: probability of
% identifying the target as a function of flanker contrast. (with and
% without noise).
% Letter target surrounded by letter flankers.
% Noise annulus on flankers only.
% P=0.75, assuming 9 alternatives
% luminance 250 cd/m2
% binocular, 20 deg right.
% March, 2018
% Denis Pelli

%% GET READY
clear o oo
skipDataCollection=false; % Enable skipDataCollection to check plotting before we have data.
o.questPlusEnable=false;
if verLessThan('matlab','R2013b')
   error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
if o.questPlusEnable && ~exist('qpInitialize','file')
   error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this M file
cal=OurScreenCalibrations(0);
if false && ~streq(cal.macModelName,'MacBookPro14,3')
   % For debugging, if this isn't a 15" MacBook Pro 2017, pretend it is.
   cal.screenWidthMm=330; % 13"
   cal.screenHeightMm=206; % 8.1"
   warning('PRETENDING THIS IS A 15" MacBook Pro 2017');
end

%% CREATE LIST OF CONDITIONS TO BE TESTED
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
o.seed=[]; % Fresh.
% o.seed=uint32(1506476580); % Copy seed value here to reproduce an old table of conditions.
o.symmetricLuminanceRange=true;
o.useDynamicNoiseMovie=true;
if true
   o.useFlankers=true;
   %    o.thresholdParameter='flankerContrast';
   o.thresholdParameter='contrast';
   o.task='identifyAll';
end
o.contrast=-0.2;
o.flankerContrast=-0.85; % Negative for dark letters.
o.flankerArrangement='radialAndTangential';
o.flankerArrangement='radial';
o.annularNoiseSD=0;
o.flankerSpacingDeg=3;
o.noiseRadiusDeg=inf;
o.annularNoiseEnvelopeRadiusDeg=o.flankerSpacingDeg;
o.noiseEnvelopeSpaceConstantDeg=o.flankerSpacingDeg/2;
o.annularNoiseBigRadiusDeg=inf;
o.annularNoiseSmallRadiusDeg=0;
o.experiment='flankers';
o.conditionName='P target id. vs. flanker contrast';
o.eccentricityXYDeg=[15 0];
o.nearPointXYInUnitSquare=[0.8 0.5];
o.targetHeightDeg=2;
o.targetDurationSec=0.2;
o.desiredLuminance=[];
o.desiredLuminanceFactor=1;
o.constantStimuli=[-0.01 -0.03 -0.1 -0.3 -0.7];
o.trialsPerBlock=50*length(o.constantStimuli);
o.useMethodOfConstantStimuli=true;
%  o.minScreenWidthDeg=10;
o.eyes='both';
% for noiseSD=Shuffle([0 0.16])
o.condition=1;
for noiseSD=[0]
   o.noiseCheckDeg=o.targetHeightDeg/20;
   o.noiseSD=noiseSD;
   if o.condition==1
      oo=o;
   else
      oo(o.condition)=o;
   end
   o.condition=o.condition+1;
end


%% PRINT THE LIST OF CONDITIONS (ONE PER ROW)
t=struct2table(oo,'AsArray',true);
% We list parameters here in the order that we want them to appear as
% columns in the table, which we print in the Command Window. Currently we
% do not save the table.
vars={'condition' 'experiment' 'noiseSD' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'constantStimuli' 'thresholdParameter'};
disp(t(:,vars)) % Print the oo list of conditions.

%% RUN THE CONDITIONS
if ~skipDataCollection && true
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" in your
   % Command Window.
   clear oOut
   for oi=1:length(oo) % Edit this line to select which conditions to run now.
      o=oo(oi);
      if exist('oOut','var')
         % Reuse answers from immediately preceding run.
         o.experimenter=oOut.experimenter;
         o.observer=oOut.observer;
         % Setting o.useFilter false forces o.filterTransmission=1.
         o.filterTransmission=oOut.filterTransmission;
      end
      o.blankingRadiusReEccentricity=0; % No blanking.
      if true
         % Target letter
         o.targetKind='letter';
         o.font='Sloan';
         o.alphabet='DHKNORSVZ';
      else
         % Target gabor
         o.targetKind='gabor';
         o.targetGaborOrientationsDeg=[0 45 90 135];
         o.targetGaborNames='1234';
         o.alphabet=o.targetGaborNames;
      end
      o.alternatives=length(o.alphabet);
      if all(o.eccentricityXYDeg==0)
         o.markTargetLocation=false;
      else
         o.markTargetLocation=true;
      end
      o.blankingRadiusReTargetHeight=0;
      o.moviePreSec=0.2;
      o.moviePostSec=0.2;
      o.targetMarkDeg=1;
      o.fixationCrossDeg=3;
      if 0
         % Use QuestPlus to measure steepness.
         o.questPlusEnable=true;
         o.questPlusSteepnesses=1:0.1:5;
         o.questPlusGuessingRates=1/o.alternatives;
         o.questPlusLapseRates=0:0.01:0.05;
         o.questPlusLogContrasts=-2.5:0.05:0.5;
         o.questPlusPrint=true;
         o.questPlusPlot=true;
      end
      oOut=NoiseDiscrimination(o);
      oo(oi).trials=oOut.trials; % Always defined.
      if isfield(oOut,'psych')
         fprintf(['<strong>%s: noiseSD %.2f, log N %.2f, flankerSpacingDeg %.1f, '...
            'target contrast %.3f, threshold flankerContrast %.3f</strong>\n'],...
            oOut.conditionName,oOut.noiseSD,log10(oOut.N),oOut.flankerSpacingDeg,...
            oOut.contrast,oOut.flankerContrast);
         oo(oi).experimenter=oOut.experimenter;
         oo(oi).observer=oOut.observer;
         oo(oi).filterTransmission=oOut.filterTransmission;
         oo(oi).flankerContrast=oOut.flankerContrast;
         oo(oi).contrast=oOut.contrast;
         oo(oi).N=oOut.N;
         oo(oi).E1=oOut.E1;
         oo(oi).alphabet=oOut.alphabet;
         oo(oi).alternatives=oOut.alternatives;
         oo(oi).targetKind=oOut.targetKind;
         oo(oi).eyes=oOut.eyes;
         oo(oi).LBackground=oOut.LBackground;
         oo(oi).targetDurationSec=oOut.targetDurationSec;
         oo(oi).eccentricityXYDeg=oOut.eccentricityXYDeg;
         oo(oi).targetCyclesPerDeg=oOut.targetCyclesPerDeg;
         oo(oi).data=oOut.data;
         oo(oi).psych=oOut.psych;
         oo(oi).transcript=oOut.transcript;
         oo(oi).dataFolder=oOut.dataFolder;
         oo(oi).dataFilename=oOut.dataFilename;
         oo(oi).trialsSkipped=oOut.trialsSkipped;
      end
      if oOut.quitExperiment
         break
      end
   end
   fprintf('\n');
   
   %% PRINT THE RESULTS
   t=struct2table(oo(1:oi),'AsArray',true);
   rows=t.trials>0;
   vars={'condition' 'observer' 'trials' 'trialsSkipped' 'noiseSD' 'N' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'flankerContrast'};
   if any(rows)
      disp(t(rows,vars)) % Print the oo list of conditions, with measured flanker threshold.
   end
   
   %% PLOT IT
   if isfield(oo(1),'psych') && isfield(oo(1).psych,'t')
      close all % Get rid of any existing figures.
      for oi=1:length(oo)
         o=oo(oi);
         disp(t(oi,vars))
         % FIT PSYCHOMETRIC FUNCTION
         clear QUESTPlusFit % Clear the persistent variables.
         o.alternatives=length(o.alphabet);
         o.questPlusLapseRates=0:0.01:0.05;
         o.questPlusGuessingRates=0:0.03:0.3;
         o.questPlusSteepnesses=[1:0.5:5 6:10];
         oOut=QUESTPlusFit(o);
         o.plotFilename=[o.dataFilename '.plot'];
         file=fullfile(o.dataFolder,[o.plotFilename '.eps']);
         saveas(gcf,file,'epsc')
         fprintf('Plot saved as "%s".\n',file);
      end
   end % if isfield(oo(1),'psych') && isfield(o.psych,'t')
end
