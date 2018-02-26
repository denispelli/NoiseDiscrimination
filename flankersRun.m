% flankersRun.m
% Show target with flankers. Measure threshold contrast of flanker (in
% noise) for reliable identification of the target.
% With and without noise.
% February, 2018
% Denis Pelli

% STANDARD CONDITION
% Measure each Neq twice.
% Letter target surrounded by letter flankers.
% Full screen noise.
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
o.viewingDistanceCm=[];
o.eyes=[];
o.desiredRetinalIlluminanceTd=[];
o.useFilter=false;
o.filterTransmission=0.115;
o.eccentricityXYDeg=[];
o.noiseSD=[];
o.targetDurationSec=[];
o.targetHeightDeg=[];
o.noiseCheckDeg=[];

cal=OurScreenCalibrations(0);
if ~streq(cal.macModelName,'MacBookPro14,3')
   % For debugging, if this isn't a 15" MacBook Pro 2017, pretend it is.
   cal.screenWidthMm=330; % 13"
   cal.screenHeightMm=206; % 8.1"
   warning('PRETENDING THIS IS A 15" MacBook Pro 2017');
end

% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
o.useFlankers=true;
o.thresholdParameter='flankerContrast';
o.contrast=-0.2;
o.flankerContrast=-0.85; % Negative for dark letters.
% o.flankerContrast=nan; % Nan requests that flanker contrast always equal signal contrast.
o.flankerSpacingDeg=6;
% Two noise levels, noiseSD: 0 0.16
o.experiment='flankers';
o.conditionName='Neq of flanker';
o.eccentricityXYDeg=[18 0];
o.targetHeightDeg=4;
o.targetDurationSec=0.2;
o.desiredLuminance=[];
o.desiredLuminanceFactor=1;
%  o.minScreenWidthDeg=10;
o.eyes='right';
for noiseSD=Shuffle([0 0.16])
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
      o.useDynamicNoiseMovie=true;
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
      fprintf(['<strong>%s: noiseSD %.2f, log N %.2f, flankerSpacingDeg %.1f, target contrast %.3f, threshold flankerContrast %.3f</strong>\n'],...
         oOut.conditionName,oOut.noiseSD,log10(oOut.N),oOut.flankerSpacingDeg,oOut.contrast,oOut.flankerContrast);
      oo(oi).flankerContrast=oOut.flankerContrast;
      oo(oi).N=oOut.N;
      oo(oi).trials=oOut.trials;
      oo(oi).data=oOut.data;
      oo(oi).psych=oOut.psych;
      if oOut.quitSession
         break
      end
   end
end % Run the selected conditions
t=struct2table(oo);
vars={'trials' 'noiseSD' 'N' 'flankerSpacingDeg' 'contrast' 'flankerContrast'};
t(:,vars) % Print the oo list of conditions, now with measured threshold


