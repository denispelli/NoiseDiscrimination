% facesRun.m
% April 11, 2018
% Denis Pelli

%% GET READY
clear o oo
skipDataCollection=false; % Enable skipDataCollection to check plotting before we have data.
o.questPlusEnable=false;
if ~exist('rgb2lin','file')
    error('This MATLAB %s is too old. We need MATLAB 2017b or better to use the function "rgb2lin".',version('-release'));
end
if o.questPlusEnable && ~exist('qpInitialize','file')
    error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
o.seed=[]; % Fresh.
% o.seed=uint32(1506476580); % Copy seed value here to reproduce an old table of conditions.
if isempty(o.seed)
    rng('shuffle'); % Use clock to seed the random number generator.
    generator=rng;
    o.seed=generator.Seed;
else
    rng(o.seed);
end
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
% o.printImageStatistics=true;

%% SPECIFY BASIC CONDITION
o.symmetricLuminanceRange=false; % Allow maximum brightness.
o.desiredLuminanceFactor=1.8; % Maximize brightness.
o.responseScreenAbsoluteContrast=0.9;
if false
    % Target letter
    o.targetKind='letter';
    o.font='Sloan';
    o.alphabet='DHKNORSVZ';
else
    % Target face
    o.signalImagesFolder='faces';
    o.signalImagesAreGammaCorrected=true;
    o.targetKind='image';
    o.alphabet='abcdefghijkl';
    o.convertSignalImageToGray=false;
    o.alphabetPlacement='right'; % 'top' or 'right';
end
o.targetMargin=0;
viewingDistanceCm=40;
o.contrast=1; % Select contrast polarity.
o.useDynamicNoiseMovie=false;
o.experiment='faces';
o.task='rate';
% o.task='identify';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=15;
o.targetDurationSec=0.2;
o.trialsPerBlock=20;
o.lapse=nan;
o.steepness=nan;
o.guess=nan;
o.observer='';
o.noiseSD=0;
o.thresholdParameter='contrast';
o.conditionName='threshold';
o.blankingRadiusReTargetHeight=0;
o.targetMarkDeg=1;
o.fixationCrossDeg=3;
o.alternatives=length(o.alphabet);
if all(o.eccentricityXYDeg==0)
    o.markTargetLocation=false;
else
    o.markTargetLocation=true;
end
if false
    % Use QuestPlus to measure steepness.
    o.questPlusEnable=true;
    o.questPlusSteepnesses=1:0.1:5;
    o.questPlusGuessingRates=1/o.alternatives;
    o.questPlusLapseRates=0:0.01:0.05;
    o.questPlusLogContrasts=-2.5:0.05:0.5;
    o.questPlusPrint=true;
    o.questPlusPlot=true;
end

%% SAVE CONDITIONS IN STRUCT oo
oo={};
for beautyTask=Shuffle(0:1)
    if beautyTask
        o.task='rate';
    else
        o.task='identify';
    end
    for duration=Shuffle([0.2 1])
        o.targetDurationSec=duration;
        oo{end+1}=o;
    end
end
for i=1:length(oo)
    oo{i}.condition=i; % Number the conditions
end

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT
% Include whatever's interesting. All these vars must be defined in every condition.
vars={'seed' 'condition' 'task' 'targetDurationSec' 'targetHeightDeg' 'noiseSD'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% RUN THE CONDITIONS
oo=RunExperiment(oo);

%% PRINT SUMMARY OF RESULTS AS TABLE TT
% Include whatever you're intersted in. We skip rows missing any value.
vars={'condition' 'observer' 'trials'  'task' 'targetDurationSec' 'targetHeightDeg' 'contrast' 'guess' 'lapse' 'steepness' 'seed' };
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    if ~all(ismember({'trials' 'contrast' 'transcript'},t.Properties.VariableNames)) || isempty(t.trials) || t.trials==0
        % Skip condition without data.
        continue
    end
    % Warn, skip the condition, and report which fields were missing.
    ok=ismember(vars,t.Properties.VariableNames);
    if ~all(ok)
        missing=join(vars(~ok),' ');
        warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
        continue
    end
    tt(i,:)=t(1,vars);
end
disp(tt) % Print summary.
if isempty(tt)
    return
end

%% SAVE SUMMARY OF RESULTS
o=oo{1};
o.summaryFilename=[o.dataFilename '.summary' ];
writetable(tt,fullfile(o.dataFolder,[o.summaryFilename '.csv']));
save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'tt','oo');
fprintf('Summary saved in data folder as "%s" with extensions ".csv" and ".mat".\n',o.summaryFilename);

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
fprintf('Plot saved in data folder as "%s".\n',[o.plotFilename '.eps']);
