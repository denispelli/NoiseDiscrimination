% michelleEccentricityRun.m
% May 25, 2018
% Denis Pelli for project in collaboration with Martin Barlow and Horace
% Barlow and Michelle Qiu.

%% GET READY
clear o oo
skipDataCollection=false; % Enable skipDataCollection to check plotting before we have data.
o.questPlusEnable=false;
if ~exist('struct2table','file')
    error('This MATLAB %s is too old. We need MATLAB 2013b or better to use the function "struct2table".',version('-release'));
end
if ~exist('qpInitialize','file')
    addpath('~/Dropbox/mQuestPlus');
    addpath('~/Dropbox/mQuestPlus/questplus');
end
if ~exist('qpInitialize','file')
    error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
o.localHostName=cal.localHostName;
% o.useFractionOfScreenToDebug=0.4; % 0: normal, 0.5: small for debugging.
% o.measureContrast=true;
% o.printImageStatistics=true;
% o.assessTargetLuminance=true;
o.observer='ideal';
o.observer='michelle';
o.experimenter='michelle';

%% SPECIFY BASIC CONDITION
o.experiment='michelleEccentricity';
o.nearPointXYInUnitSquare=[0.7 0.5];
o.eccentricityXYDeg=[0,0];
o.targetDurationSec=0.2;
o.eyes='both';
o.viewingDistanceCm=40;
o.isLuminanceRangeSymmetric=true;
o.alphabetPlacement='right'; % 'top' or 'right';
o.fixationThicknessDeg=0.09;
o.fixationBlankingRadiusReEccentricity=0; % No blanking.
o.fixationBlankingRadiusReTargetHeight=0;
o.targetMarkDeg=2;
o.fixationMarkDeg=3;
if true
    % Target letter
    o.targetKind='letter';
    o.targetFont='Sloan';
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
if false
    % Use QuestPlus to measure steepness.
    o.questPlusEnable=true;
    o.questPlusSteepnesses=1:0.1:5;
    o.questPlusGuessingRates=1/o.alternatives;
    o.questPlusLapseRates=0:0.01:0.05;
    o.questPlusLogIntensities=-2.5:0.05:0.5;
    o.questPlusPrint=true;
    o.questPlusPlot=true;
end
o.thresholdParameter='contrast';
o.trialsDesired=40;

%% PUT THE EXPERIMENT'S CONDITIONS IN STRUCT oo
% o.targetHeightDeg=11;
% o.noiseCheckDeg=o.targetHeightDeg/sqrt(2000);
o.targetHeightDeg=4;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.noiseCheckDeg=o.targetHeightDeg/10;
o.noiseSD=0.2;
o.targetDurationSec=0.2;
o.fixationMarkDrawnOnStimulus=true;
o.isTargetLocationMarked=true; % Is there a mark designating target position?
o.targetMarkDeg=0.1; % Just a dot.
o.contrast=-1;
oo={};
if true
    o.conditionName='Noise letter';
    o.task='identify';
    o.targetModulates='noise';
    o.targetKind='letter';
    o.eccentricityXYDeg=[10 0];
    oo{end+1}=o;
    o.eccentricityXYDeg=[0 0];
    o.fixationBlankingRadiusReTargetHeight=1.1;
    o.fixationMarkDeg=inf;
    oo{end+1}=o;
    o.fixationBlankingRadiusReTargetHeight=0;
    o.fixationMarkDeg=3;
end
if true
    o.conditionName='4afc noise';
    o.task='4afc';
    o.targetModulates='noise';
o.targetHeightDeg=2;
o.noiseRadiusDeg=o.targetHeightDeg/2;
o.noiseCheckDeg=o.targetHeightDeg/5;
    o.eccentricityXYDeg=[0 0];
    o.gapFraction4afc=4;
    oo{end+1}=o;
    o.gapFraction4afc=0.03;
    o.eccentricityXYDeg=[0 0];
    o.fixationBlankingRadiusReTargetHeight=1.1;
    o.fixationMarkDeg=inf;
    oo{end+1}=o;
end
if false
    o.conditionName='Luminance letter';
    o.task='identify';
    o.targetModulates='luminance';
    oo{end+1}=o;
end
if false
    o.conditionName='Entropy letter 2';
    o.task='identify';
    o.targetModulates='entropy';
    o.backgroundEntropyLevels=2;
    o.targetHeightDeg=11;
    o.noiseCheckDeg=o.targetHeightDeg/20;
    o.targetDurationSec=inf;
    o.noiseSD=0.2;
    oo{end+1}=o;
%     o.noiseSD=0.05;
    oo{end+1}=o;
end
if false
    o.conditionName='Entropy letter 3';
    o.task='identify';
    o.targetModulates='entropy';
    o.backgroundEntropyLevels=3;
    o.targetHeightDeg=11;
    o.noiseCheckDeg=o.targetHeightDeg/20;
    o.targetDurationSec=inf;
    o.noiseSD=0.2;
    oo{end+1}=o;
%     o.noiseSD=0.05;
    oo{end+1}=o;
end
if false
    o.conditionName='4afc luminance';
    o.task='4afc';
    o.targetModulates='luminance';
    oo{end+1}=o;
end
if false
    o.conditionName='4afc entropy';
    o.task='4afc';
    o.targetModulates='entropy';
    o.backgroundEntropyLevels=3;
    oo{end+1}=o;
end

%% POLISH THE LIST OF CONDITIONS
for oi=1:length(oo)
    o=oo{oi};
    o.condition=oi; % Number the conditions
    o.alternatives=length(o.alphabet);
    if all(o.eccentricityXYDeg==0)
        o.isTargetLocationMarked=false;
    else
        o.isTargetLocationMarked=true;
    end
    oo{oi}=o;
end

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT
% All these vars must be defined in every condition.
vars={'condition' 'conditionName' 'trialsDesired' 'noiseSD' 'targetHeightDeg'  'task' 'targetModulates' 'contrast'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print the oo list of conditions.

%% RUN THE CONDITIONS
oo=RunExperiment(oo);

%% PRINT SUMMARY OF RESULTS AS TABLE TT
% Include whatever you're intersted in. We skip rows missing any specified variable.
vars={'condition' 'conditionName' 'observer' 'trials' 'p' 'trialsSkipped' ...
     'task' 'targetModulates' 'noiseSD' 'N' 'targetHeightDeg' ...
    'contrast' 'r' 'approxRequiredNumber' 'backgroundEntropyLevels'  };
tt=Experiment2Table(oo,vars);
disp(tt) % Print the list of conditions, with results.
if isempty(tt)
    return
end



