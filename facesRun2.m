% facesRun.m
% April 11, 2018
% Denis Pelli

%% GET READY
clear o oo
o.questPlusEnable=false;
if ~exist('rgb2lin','file')
    error('This MATLAB %s is too old. We need MATLAB 2017b or better to use the function "rgb2lin".',...
        version('-release'));
end
if o.questPlusEnable && ~exist('qpInitialize','file')
    error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
% o.printImageStatistics=true;

%% SPECIFY BASIC CONDITION
o.ratingThreshold=[7 5 5 7 7 5]; % Our threshold for beauty.
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
    o.alphabet='abcdef';
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
o.targetDurationSecs=0.2;
o.trialsPerBlock=40; %5; % default for experiment: 40; for training: 5;
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

%% SAVE INTERLEAVED CONDITIONS IN STRUCT oo
ooo={};
for task={'rate' 'identify'}
    o.task=task{1};
%     durations=Shuffle([0.017 0.05 0.15 0.5 1.5]);
    durations=Shuffle([0.017  1.5]);
    oo=repmat(o,size(durations));
    for i=1:length(durations)
        oo(i).targetDurationSecs=durations(i);
    end
    ooo{end+1}=oo;
end

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT
vars={'task' 'targetDurationSecs' 'targetHeightDeg' 'noiseSD'};
tt=table;
for i=1:length(ooo)
    t=struct2table(ooo{i},'AsArray',true);
    tt(end+1:end+height(t),:)=t(:,vars);
end
disp(tt) % Print list of conditions.

%% RUN THE CONDITIONS
for i=1:length(ooo)
    ooo{1}=NoiseDiscrimination2(ooo{1});
end
% oo=RunExperiment(oo);
return

%% PRINT SUMMARY OF RESULTS AS TABLE TT
% Include whatever you're intersted in. We skip rows missing any value.
vars={'condition' 'observer' 'trials'  'task' 'targetDurationSecs' 'targetHeightDeg' 'contrast' 'guess' 'lapse' 'steepness'};
tt=Experiment2Table(oo,vars);
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
tBeauty=t(streq(t.task,'rate'),{'targetDurationSecs' 'contrast'});
tBeauty=sortrows(tBeauty,'targetDurationSecs');
tId=t(streq(t.task,'identify'),{'targetDurationSecs' 'contrast'});
tId=sortrows(tId,'targetDurationSecs');
close all % Get rid of any existing figures.
figure(1)
loglog(tId.targetDurationSecs,tId.contrast,'r-o',tBeauty.targetDurationSecs,tBeauty.contrast,'k-x');
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
