% facesRun.m
% March, 2018
% Denis Pelli

%% GET READY
clear o oo
o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
fakeRun=false; % Enable fakeRun to check plotting before we have data.
o.seed=[]; % Fresh.
% o.seed=uint32(1506476580); % Copy seed value here to reproduce an old table of conditions.
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

%% CREATE LIST OF CONDITIONS TO BE TESTED
o.contrast=nan;
o.useDynamicNoiseMovie=false;
o.experiment='faces';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=4;
o.targetDurationSec=0.2;
o.trialsPerRun=50;
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
if ~exist('oo','var')
    oo=o;
else
    oo(end+1)=o;
end
   
%% NUMBER THE CONDITIONS (I.E. ROWS) AND PRINT THE TABLE
for i=1:length(oo)
   oo(i).condition=i;
end
t=struct2table(oo,'AsArray',true);
% We list parameters here in the order that we want them to appear as
% columns in the table, which we print in the Command Window. 
vars={'seed' 'condition' 'conditionName' 'contrast' 'guess'};
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
      if false
         % Target letter
         o.targetKind='letter';
         o.font='Sloan';
         o.alphabet='DHKNORSVZ';
      else
         % Target faces
         o.signalImagesFolder='faces';
         o.targetKind='image';
         o.alphabet='abcd1234';
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
   rows=t.trials>0;
   vars={'observer' 'trials' 'contrast' 'guess' 'lapse' 'steepness'};
   if any(rows)
      t(rows,vars) % Print the oo list of conditions, with measured flanker threshold.
   end
   
   %% SAVE SUMMARY OF RESULTS
   o=oOut;
   o.summaryFilename=[o.dataFilename '.summary' ];
   writetable(t,[o.summaryFilename '.csv']);
   save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'t','rows','vars','oo');
   fprintf('Summary saved as "%s" with extensions ".csv" and ".mat".\n',o.summaryFilename);

   %% PLOT IT
%    close all % Get rid of any existing figures.
%    figure(1)
%    n=abs([oo.noiseSD]);
%    c=abs([oo.flankerContrast]);
%    [n,i]=sort(n);
%    c=c(i);
%    loglog(0.01+n,c,'-o');
%    ylabel('Flanker threshold contrast');
%    xlabel('NoiseSD contrast');
%    xlim([0.01 1]);
%    ylim([0.01 1]);
%    daspect([1 1 1]);
%    name=[o.experiment '-' o.observer '-log.eps'];
%    title(name);
%    graphFile=fullfile(fileparts(mfilename('fullpath')),'data',name);
%    saveas(gcf,graphFile,'epsc')
%    fprintf('Plot saved as "%s".\n',graphFile);
%    figure(2)
%    plot(n,c,'-o');
%    ylabel('Flanker threshold contrast');
%    xlabel('NoiseSD contrast');
%    xlim([0 .5]);
%    ylim([0 .5]);
%    daspect([1 1 1]);
%    name=[o.experiment '-' o.observer '.eps'];
%    title(name);
%    graphFile=fullfile(fileparts(mfilename('fullpath')),'data',name);
%    saveas(gcf,graphFile,'epsc')
%    fprintf('Plot saved as "%s".\n',graphFile);
end % Run the selected conditions

