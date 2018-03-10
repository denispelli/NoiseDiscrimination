% flankerThresholdRun.m
% Show target with flankers. Measure threshold contrast of flanker (with
% and without noise) for reliable identification of the target.
% To estimate equivalent input noise of the crowding effect of flanker.
% February, 2018
% Denis Pelli

% STANDARD CONDITION
% Measure threshold contrast of flanker to barely identify the target.
% Several noise levels.
% Letter target surrounded by letter flankers.
% Static noise annulus on flankers only. 
% P=0.75, assuming 9 alternatives
% luminance 250 cd/m2
% binocular, 20 deg right

%% CREATE LIST OF CONDITIONS TO BE TESTED
clear o oo
fakeRun=false; % Enable fakeRun to check plotting before we have data.
o.questPlusEnable=false;
if o.questPlusEnable && ~exist('qpInitialize','file')
   error('This script requires the QuestPLUS package. Please get it from github.')
end
if verLessThan('matlab','R2013b')
   error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this M file

cal=OurScreenCalibrations(0);
if false && ~streq(cal.macModelName,'MacBookPro14,3')
   % For debugging, if this isn't a 15" MacBook Pro 2017, pretend it is.
   cal.screenWidthMm=330; % 13"
   cal.screenHeightMm=206; % 8.1"
   warning('PRETENDING THIS IS A 15" MacBook Pro 2017');
end

% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
o.useDynamicNoiseMovie=false;
if true
   o.useFlankers=true;
   o.thresholdParameter='flankerContrast';
end
o.contrast=-0.2; % Fixed target contrast.
o.flankerContrast=-1; % Negative for dark letters.
% o.flankerContrast=nan; % Nan requests that flanker contrast always equal signal contrast.
o.annularNoiseSD=0;
o.flankerSpacingDeg=3;
o.noiseRadiusDeg=inf;
o.annularNoiseEnvelopeRadiusDeg=o.flankerSpacingDeg;
o.noiseEnvelopeSpaceConstantDeg=o.flankerSpacingDeg/2;
o.annularNoiseBigRadiusDeg=inf;
o.annularNoiseSmallRadiusDeg=0;
o.experiment='flankerThreshold';
o.conditionName='flanker threshold';
o.eccentricityXYDeg=[20 0];
o.targetHeightDeg=2;
o.targetDurationSec=0.2;
o.desiredLuminance=[];
o.desiredLuminanceFactor=1;
o.trialsPerRun=50;
o.guess=0.19; % Crowded identification of 20%-contrast target at 20 deg.
o.lapse=nan;
o.steepness=nan;
o.observer='';
%  o.minScreenWidthDeg=10;
o.eyes='both';
for noiseSD=Shuffle([0 0.05 0.1 ])
   %          o.minScreenWidthDeg=1+abs(o.eccentricityXYDeg(1))+o.targetHeightDeg*0.75;
   o.minScreenWidthDeg=1+o.targetHeightDeg*2;
   o.maxViewingDistanceCm=round(0.1*cal.screenWidthMm/(2*tand(o.minScreenWidthDeg/2)));
   o.viewingDistanceCm=min([o.maxViewingDistanceCm 40]);
   o.noiseCheckDeg=o.targetHeightDeg/10;
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
t=struct2table(oo,'AsArray',true);
% We list parameters here in the order that we want them to appear as
% columns in the table, which we print in the Command Window. Currently we
% do not save the table.
% vars={'condition' 'experiment' 'conditionName' ...
%    'viewingDistanceCm' 'eyes' 'desiredRetinalIlluminanceTd' ...
%    'useFilter' 'filterTransmission' 'eccentricityXYDeg' ...
%    'noiseSD' 'targetDurationSec' 'targetHeightDeg' ...
%    'noiseCheckDeg'};
vars={'condition' 'experiment' 'noiseSD' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'guess'};
t(:,vars) % Print the oo list of conditions.

%% RUN THE CONDITIONS
if ~fakeRun && true
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
      if o.questPlusEnable
         % Use QuestPlus when we don't know all the parameters.
         o.questPlusSteepnesses=1:0.1:5;
         o.questPlusGuessingRates=1/o.alternatives:0.02:0.5;
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
         oo(oi).alternatives=oOut.alternatives;
         oo(oi).targetKind=oOut.targetKind;
         oo(oi).eyes=oOut.eyes;
         oo(oi).LMean=oOut.LMean;
         oo(oi).targetDurationSec=oOut.targetDurationSec;
         oo(oi).eccentricityXYDeg=oOut.eccentricityXYDeg;
         oo(oi).targetCyclesPerDeg=oOut.targetCyclesPerDeg;
         oo(oi).data=oOut.data;
         oo(oi).psych=oOut.psych;
         oo(oi).guess=oOut.guess;
         oo(oi).lapse=oOut.lapse;
         oo(oi).steepness=oOut.steepness;
      end
      if oOut.quitSession
         break
      end
   end
   
   %% PRINT THE RESULTS
   t=struct2table(oo(1:oi),'AsArray',true);
   rows=t.trials>0;
   vars={'observer' 'trials' 'noiseSD' 'N' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'flankerContrast' 'guess' 'lapse' 'steepness'};
   if any(rows)
      t(rows,vars) % Print the oo list of conditions, with measured flanker threshold.
   end
end % Run the selected conditions

%% PLOT IT
close all % Get rid of any existing figures.
figure(1)
n=abs([oo.noiseSD]);
c=abs([oo.flankerContrast]);
[n,i]=sort(n);
c=c(i);
loglog(0.01+n,c,'-o');
ylabel('Flanker threshold contrast');
xlabel('NoiseSD contrast');
ylim([0.01 1]);
title([o.experiment '-' o.observer '.eps']);
figure(2)
plot(n,c,'-o');
ylabel('Flanker threshold contrast');
xlabel('NoiseSD contrast');
xlim([0 1]);
ylim([0 1]);
title([o.experiment '-' o.observer '.eps']);
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[o.experiment '-' o.observer '.eps']);
saveas(gcf,graphFile,'epsc')
fprintf('Plot saved as "%s".\n',graphFile);

