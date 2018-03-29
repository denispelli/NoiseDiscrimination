% facesRun.m
% March, 2018
% Denis Pelli

%% GET READY
clear o oo
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
fakeRun=false; % Enable fakeRun to check plotting before we have data.
o.seed=[]; % Fresh.
% o.seed=uint32(1506476580); % Copy seed value here to reproduce an old table of conditions.
o.questPlusEnable=false;
if o.questPlusEnable && ~exist('qpInitialize','file')
   error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
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

%% CREATE LIST OF CONDITIONS TO BE TESTED
if false
   % Target letter
   o.targetKind='letter';
   o.font='Sloan';
   o.alphabet='DHKNORSVZ';
else
   % Target faces
   o.signalImagesFolder='faces';
   o.targetKind='image';
   o.alphabet='abcdefghijkl';
   o.convertSignalImageToGray=false;
   o.alphabetPlacement='right'; % 'top' or 'right';
end
o.targetMargin=0;
viewingDistanceCm=40;
o.contrast=1; % Indicate polarity.
o.useDynamicNoiseMovie=false;
o.experiment='faces';
o.task='rate';
% o.task='identify';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=15;
o.targetDurationSec=0.2;
o.trialsPerRun=20;
o.lapse=nan;
o.steepness=nan;
o.guess=nan;
o.observer='';
o.noiseSD=0;
if isempty(o.seed)
   rng('shuffle'); % Use clock to seed the random number generator.
   generator=rng;
   o.seed=generator.Seed;
else
   rng(o.seed);
end
o.desiredLuminanceFactor=2; % Maximum brightness.
o.thresholdParameter='contrast';
o.conditionName='threshold';
for beautyTask=0:1
   if beautyTask
      o.task='rate';
   else
      o.task='identify';
   end
   for duration=[0.2 1]
      o.targetDurationSec=duration;
      if ~exist('oo','var')
         oo=o;
      else
         oo(end+1)=o;
      end
   end
end
%% NUMBER THE CONDITIONS (ONE PER ROW) AND PRINT THE TABLE
for i=1:length(oo)
   oo(i).condition=i;
end
t=struct2table(oo,'AsArray',true);
% We list parameters here in the order that we want them to appear as
% columns in the table, which we print in the Command Window. 
vars={'seed' 'condition' 'task' 'targetDurationSec' 'targetHeightDeg' };
t(:,vars) % Print the oo list of conditions.
fprintf('To recreate this table, set your o.seed to the value of "seed" listed in the table.\n');
%% RUN THE CONDITIONS
if ~fakeRun && true
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" in your
   % Command Window.
   % CAUTION: Conditions with the same conditionName are randonly shuffled
   % every time you run this, unless you set o.seed, above, to the 'seed'
   % used to generate the table you want to reproduce.
   clear oOut
   for oi=1:length(oo) % Edit this line to select which conditions to run now.
      o=oo(oi);
      if exist('oOut','var')
         % Reuse answers from immediately preceding run.
         o.experimenter=oOut.experimenter;
         o.observer=oOut.observer;
      end
      o.alternatives=length(o.alphabet);
      if all(o.eccentricityXYDeg==0)
         o.markTargetLocation=false;
      else
         o.markTargetLocation=true;
      end
      o.blankingRadiusReTargetHeight=0;
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
         oo(oi).contrast=oOut.contrast;
         oo(oi).E1=oOut.E1;
         oo(oi).alternatives=oOut.alternatives;
         oo(oi).targetKind=oOut.targetKind;
         oo(oi).LMean=oOut.LMean;
         oo(oi).targetDurationSec=oOut.targetDurationSec;
         oo(oi).eccentricityXYDeg=oOut.eccentricityXYDeg;
         oo(oi).targetCyclesPerDeg=oOut.targetCyclesPerDeg;
         oo(oi).data=oOut.data;
         oo(oi).psych=oOut.psych;
         oo(oi).guess=oOut.guess;
         oo(oi).lapse=oOut.lapse;
         oo(oi).steepness=oOut.steepness;
         oo(oi).dataFilename=oOut.dataFilename;
         oo(oi).dataFolder=oOut.dataFolder;
      end
      if oOut.quitSession
         break
      end
   end
   
   %% PRINT SUMMARY OF RESULTS
   t=struct2table(oo(1:oi),'AsArray',true);
   t.data=[];
   rows=t.trials>0;
   vars={'condition' 'observer' 'trials'  'task' 'targetDurationSec' 'targetHeightDeg' 'contrast' 'guess' 'lapse' 'steepness' 'seed' };
   if any(rows)
      t(rows,vars) % Print the oo list of conditions, with measured flanker threshold.
   end
   
   %% SAVE SUMMARY OF RESULTS
   o=oOut;
   o.summaryFilename=[o.dataFilename '.summary' ];
   writetable(t,fullfile(o.dataFolder,[o.summaryFilename '.csv']));
   save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'t','rows','vars','oo');
   fprintf('Summary saved as "%s" with extensions ".csv" and ".mat".\n',o.summaryFilename);

   %% PLOT IT
   tBeauty=t(streq(t.task,'rate'),{'targetDurationSec' 'contrast'});
   tBeauty=sortrows(tBeauty,'targetDurationSec');
   tId=t(streq(t.task,'identify'),{'targetDurationSec' 'contrast'});
   tId=sortrows(tId,'targetDurationSec');
   close all % Get rid of any existing figures.
   figure(1)
   loglog(tId.targetDurationSec,tId.contrast,'r-o',tBeauty.targetDurationSec,tBeauty.contrast,'k-x');
   ylabel('Threshold contrast');
   xlabel('Duration (s)');
   xlim([0.05 2]);
   ylim([0.01 10]);
   DecadesEqual(gca);
   o.plotFilename=[o.dataFilename '.plot'];
   title(o.plotFilename);
   legendNames={};
   if height(tId)>0
      legendNames{end+1}='Identification';
   end
   if height(tBeauty)>0
      legendNames{end+1}='Beauty';
   end
   legend(legendNames,'Location','north');
   legend boxoff
   graphFile=fullfile(o.dataFolder,[o.plotFilename '.eps']);
   saveas(gcf,graphFile,'epsc')
   fprintf('Plot saved as "%s".\n',graphFile);
end % Run the selected conditions


