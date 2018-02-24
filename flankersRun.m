% flankersRun.m
% Show target with flankers.
% EVENTUALLY: We want to measure threshold contrast of flanker (in noise) for reliable
% identification of the target. 
% With and without noise. 
% February, 2018
% Denis Pelli

% STANDARD CONDITION
% Measure each Neq twice.
% Letter target surrounded by letter flankers.
% P=0.75, assuming 9 alternatives
% luminance 250 cd/m2
% monocular, temporal field, right eye

clear all
%% CREATE LIST OF CONDITIONS TO BE TESTED
if verLessThan('matlab','R2013b')
   error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
clear o oo
fakeRun=false; % Enable fakeRun to check plotting before we have data.

% We list parameters here in the order that we want them to appear as
% columns in the list. I don't think we use these values. This is just for
% the cosmetic ordering of the fields in the struct, which later determines
% the order of the columns in the table.
o.condition=1;
o.experiment='';
o.conditionName='';
o.viewingDistanceCm=40;
o.eyes='right';
o.desiredRetinalIlluminanceTd=[];
o.useFilter=false;
o.eccentricityXYDeg=[0 0];
o.noiseSD=0;
o.targetDurationSec=0.2;
o.targetCyclesPerDeg=3;
o.targetGaborCycles=3;
o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
o.noiseCheckDeg=o.targetHeightDeg/20;

cal=OurScreenCalibrations(0);
if false && ~streq(cal.macModelName,'MacBookPro14,3')
   % For debugging, if this isn't a 15" MacBook Pro 2017, pretend it is.
   cal.screenWidthMm=330; % 13"
   cal.screenHeightMm=206; % 8.1"
   warning('PRETENDING THIS IS A 15" MacBook Pro 2017');
end

o.useFlankers=true;
o.thresholdParameter='flankerContrast';
o.contrast=0.2;
o.flankerContrast=-0.85; % Negative for dark letters.
% o.flankerContrast=nan; % Nan requests that flanker contrast always equal signal contrast.
o.flankerSpacingDeg=3;
%       o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
% Two noise levels, noiseSD: 0 0.16
o.experiment='flankers';
o.conditionName='cortical';
o.eccentricityXYDeg=[18 0];
o.targetHeightDeg=2;
o.targetDurationSec=2;
o.desiredLuminance=[];
o.desiredLuminanceFactor=1;
%  o.minScreenWidthDeg=10;
o.eyes='right';
% for noiseSD=Shuffle([0 0.16])
for noiseSD=[.06 0]
   %          o.minScreenWidthDeg=1+abs(o.eccentricityXYDeg(1))+o.targetHeightDeg*0.75;
   o.minScreenWidthDeg=1+o.targetHeightDeg*2;
   o.maxViewingDistanceCm=round(0.1*cal.screenWidthMm/(2*tand(o.minScreenWidthDeg/2)));
   o.viewingDistanceCm=min([o.maxViewingDistanceCm 40]);
   o.noiseCheckDeg=o.targetHeightDeg/20;
   o.noiseSD=noiseSD;
   if ~exist('oo','var')
      oo=o;
   else
      oo(end+1)=o;
   end
end


%% Number the conditions, and print the list.
for i=1:length(oo)
   oo(i).condition=i;
end
t=struct2table(oo);
t % Print the oo list of conditions.

if fakeRun
   % NOT IMPLEMENTED.
   % PRODUCE FAKE RUN TO CHECK THE ANALYSIS & PLOTTING.
   data=table2struct(t);
   for i=1:length(data)
      data(i).E=10*data(i).noiseSD+1e-5*(1+floor((i-1)/8));
      data(i).trialsPerRun=40;
      data(i).N=data(i).noiseSD;
      data(i).experimenter='Experimenter';
      data(i).observer='Observer';
      data(i).targetKind='gabor';
      data(i).noiseType='gaussian';
      data(i).LMean=280*data(i).luminanceFactor;
   end
   steepnessAnalyze(data);
end
if ~fakeRun && 1
   %% RUN THE CONDITIONS
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" in your
   % Command Window.
   clear oOut
   for oi=1:length(oo) % Edit this line to select which conditions to run now.
      o=oo(oi);
      o.trialsPerRun=40;
      if exist('oOut','var')
         % Copy answers from immediately preceding run.
         o.experimenter=oOut.experimenter;
         o.observer=oOut.observer;
         % Setting o.useFilter false forces o.filterTransmission=1.
         o.filterTransmission=oOut.filterTransmission;
      end
      o.blankingRadiusReEccentricity=0; % No blanking.
      if 1
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
      o.useDynamicNoiseMovie=false;
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
      fprintf(['%s: %.1f cd/m^2, luminanceFactor %.2f, filterTransmission %.3f\n'],...
         o.conditionName,oOut.luminance,oOut.luminanceFactor,oOut.filterTransmission);
      if ~isempty(oOut.pupilDiameterMm)
         fprintf(['%s: retinalIlluminanceTd %.1f td, pupilDiameterMm %.1f\n'],...
            o.conditionName,oOut.retinalIlluminanceTd,oOut.pupilDiameterMm);
      end
      if oOut.quitSession
         break
      end
   end
end % Run the selected conditions