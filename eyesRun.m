% eyesRun.m
% Measure effect of binocular vs monocular viewing on Neq for each of 3
% conditions, with and without noise. We expect that using two eyes halves
% Neq when the internal noise is independent between eyes (photon and
% ganglion) and no change when it is common to the two eyes (cortical).
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

%% CREATE LIST OF CONDITIONS TO BE TESTED
fakeRun=false; % Enable fakeRun to check plotting before we have data.
clear Screen o oo
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this M file

% We list parameters here in the order that we want them to appear as
% columns in the list. I don't think we use these values. This is just for
% the cosmetic ordering of the fields in the struct, which later determines
% the order of the columns in the table.

cal=OurScreenCalibrations(0);
if ~streq(cal.macModelName,'MacBookPro14,3')
   % For debugging, if I don't actually have a 15" MacBook Pro, pretend I do.
   cal.screenWidthMm=330; % 13"
   cal.screenHeightMm=206; % 8.1"
end

%% THREE DOMAINS
% In each of the 3 domains: photon, cortical, ganglion
% Two noise levels, noiseSD: 0 0.16
%
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
o.responseScreenContrast=1;
o.experiment='eyes';
o.condition=1;
o.viewingDistanceCm=40;
o.eyes='right';
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
for domain=3
   switch domain
      case 1
         % photon
         o.conditionName='photon';
         o.eccentricityXYDeg=[0 0];
         o.targetCyclesPerDeg=4;
         o.targetDurationSec=0.1;
         o.desiredLuminance=2.5; % cd/m^2
         o.desiredLuminanceFactor=[];
         o.useFilter=true;
         % o.minScreenWidthDeg=30; % Big to determine pupil size.
      case 2
         % cortical
         o.conditionName='cortical';
         o.eccentricityXYDeg=[0 0];
         o.targetCyclesPerDeg=0.5;
         o.targetDurationSec=0.4;
         o.desiredLuminance=[];
         o.desiredLuminanceFactor=1;
         o.useFilter=false;
         %  o.minScreenWidthDeg=10;
      case 3
         % ganglion
         o.conditionName='ganglion';
         o.eccentricityXYDeg=[30 0];
         o.nearPointXYInUnitSquare=[0.80 0.5];
         o.targetCyclesPerDeg=0.5;
         o.targetDurationSec=0.2;
         o.desiredLuminance=[];
         o.desiredLuminanceFactor=1;
         o.useFilter=false;
         % o.minScreenWidthDeg=10;
   end
   for eyes=Shuffle({'right' 'both'})
      %    for eyes={'right'}
      o.eyes=eyes{1};
      for noiseSD=Shuffle([0 0.3])
         %       for noiseSD=0.3
         o.noiseType='binary';
         o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
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
   end
end

%% Number the conditions, and print the list.
for i=1:length(oo)
   oo(i).condition=i;
end
t=struct2table(oo,'AsArray',true);
vars={'condition' 'experiment' 'conditionName' ...
   'useFilter' 'eccentricityXYDeg' ...
   'targetDurationSec' 'targetCyclesPerDeg' ...
   'targetGaborCycles' 'targetHeightDeg' 'noiseSD' };
t(:,vars) % Print the oo list of conditions.

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
      data(i).LBackground=280*data(i).luminanceFactor;
   end
   steepnessAnalyze(data);
end
if ~fakeRun && 1
   %% RUN THE CONDITIONS
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" above.
   clear oOut
   for oi=1:length(oo) % Edit this line to select the conditions you want to run now.
      o=oo(oi);
      % o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
      o.trialsPerRun=40;
      if exist('oOut','var')
         % Copy answers from immediately preceding run.
         o.experimenter=oOut.experimenter;
         o.observer=oOut.observer;
         % Setting o.useFilter false forces o.filterTransmission=1.
         o.filterTransmission=oOut.filterTransmission;
      end
      o.blankingRadiusReEccentricity=0; % No blanking.
      if false
         % Target letter
         o.targetKind='letter';
         o.font='Sloan';
         o.alphabet='DHKNORSVZ';
         o.contrast=-1; % negative contrast.
      else
         % Target gabor
         o.targetKind='gabor';
         o.targetGaborOrientationsDeg=[0 45 90 135];
         o.targetGaborNames='1234';
         o.alphabet=o.targetGaborNames;
         o.contrast=1; % positive contrast.
      end
      o.alternatives=length(o.alphabet);
      o.useDynamicNoiseMovie=true;
      if all(o.eccentricityXYDeg==0)
         o.markTargetLocation=false;
         o.blankingRadiusReTargetHeight=2;
         o.fixationCrossDeg=10;
      else
         o.markTargetLocation=true;
         o.blankingRadiusReTargetHeight=0;
         o.fixationCrossDeg=3;
      end
      o.moviePreSec=0.3;
      o.moviePostSec=0.3;
      o.targetMarkDeg=1;
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
      oo(oi).trials=oOut.trials; 
      if isempty(oo(oi).trials)
         oo(oi).trials=0;
      end
      %       fprintf(['%s: %.1f cd/m^2, luminanceFactor %.2f, filterTransmission %.3f\n'],...
      %          o.conditionName,oOut.luminance,oOut.luminanceFactor,oOut.filterTransmission);
      if isfield(oOut,'psych')
         fprintf(['<strong>%s: luminance %.1f cd/m^2, '...
            'eccentricity %.1f %.1f deg, '...
            'duration %.2f s, cyclesPerDeg %.1f, '...
            'noiseSD %.2f, log N %.2f, '...
            'contrast %.3f</strong>\n'],...
            oOut.conditionName,oOut.luminance,...
            oOut.eccentricityXYDeg, ...
            oOut.targetDurationSec, oOut.targetCyclesPerDeg,...
            oOut.noiseSD,log10(oOut.N),...
            oOut.contrast);
         oo(oi).experimenter=oOut.experimenter;
         oo(oi).observer=oOut.observer;
         oo(oi).filterTransmission=oOut.filterTransmission;
         oo(oi).luminance=oOut.luminance;
         oo(oi).contrast=oOut.contrast;
         oo(oi).N=oOut.N;
         oo(oi).data=oOut.data;
         oo(oi).psych=oOut.psych;
      end
      if oOut.quitSession
         break
      end
   end
   %% PRINT THE RESULTS
   t=struct2table(oo(1:oi),'AsArray',true);
   if iscell(t.trials)
      % This case may never occur. Just in case.
      rows=false(size(t.trials));
      for i=1:length(t.trials)
         trials=t.trials{i};
         rows(i)=~isempty(trials) && trials>0;
      end
   else
      rows=t.trials>0;
   end
%    vars={'condition' 'experiment' 'conditionName' ...
%       'viewingDistanceCm' 'eyes'  ...
%       'luminance' 'eccentricityXYDeg' ...
%       'targetDurationSec' 'targetCyclesPerDeg' ...
%       'targetGaborCycles' 'targetHeightDeg' 'noiseSD' 'noiseCheckDeg'};
    vars={'experiment' 'condition' 'observer' 'trials' 'luminance' 'eccentricityXYDeg' 'targetDurationSec' 'targetCyclesPerDeg' 'noiseSD' 'N' 'contrast'};
   if any(rows)
      t(rows,vars) % Print the oo list of conditions, with measured threshold.
   end
end % Run the selected conditions