% threeLettersRun.m
% Show target with two flankers. Report all three. Measure threshold
% contrast of flankers to bring target identification to 75% correct.
% P=0.75, assuming 9 alternatives
% luminance 250 cd/m2
% binocular, 15 deg vertical eccentricity.
% April 4, 2018
% Denis Pelli for project in collaboration with Katerina Malakhova.

%% GET READY
clear o oo
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

%% SPECIFY BASIC CONDITION
o.experiment='threeLetters';
o.nearPointXYInUnitSquare=[0.5 0.9];
o.eccentricityXYDeg=[0,15];
o.flankerSpacingDeg=3;
o.targetHeightDeg=2;
o.noiseCheckDeg=o.targetHeightDeg/20;
o.targetDurationSecs=0.2;
o.eyes='both';
o.contrast=-0.16;
o.flankerContrast=-1; % Negative for dark letters.
o.flankerArrangement='tangential'; % 'radial' 'radialAndTangential'
o.viewingDistanceCm=40;
o.isLuminanceRangeSymmetric=true;
o.isNoiseDynamic=true;
o.alphabetPlacement='right'; % 'top' or 'right';
o.annularNoiseSD=0;
o.noiseRadiusDeg=inf;
if false
    o.annularNoiseBigRadiusDeg=inf;
    o.annularNoiseSmallRadiusDeg=0;
    o.annularNoiseEnvelopeRadiusDeg=o.flankerSpacingDeg;
    o.noiseEnvelopeSpaceConstantDeg=o.flankerSpacingDeg/2;
end
o.fixationCrossWeightDeg=0.09;
o.blankingRadiusReEccentricity=0; % No blanking.
o.blankingRadiusReTargetHeight=0;
o.moviePreAndPostSecs=[0.2 0.2];
o.targetMarkDeg=2;
o.fixationCrossDeg=3;
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
o.noiseSD=0;
o.thresholdParameter='contrast';

%% PUT THE EXPERIMENT'S CONDITIONS IN STRUCT oo
oo={};
o.noiseType='ternary';

if false
    o.contrast=-0.15;
    o.trialsDesired=300;
    o.constantStimuli=-10 .^ (-1.1:0.05:-0.6);
    o.useMethodOfConstantStimuli=true;
    o.conditionName='various flanker contrasts';
    o.useFlankers=true;
    o.thresholdParameter='flankerContrast';
    o.task='identifyAll';
    oo{end+1}=o;
end
o.useMethodOfConstantStimuli=false;
if true
    o.conditionName='Threshold contrast';
    o.trialsDesired=40;
    o.useFlankers=false;
    o.thresholdParameter='contrast';
    o.task='identify';
    o.noiseSD=0;
    oo{end+1}=o;
    o.noiseSD=MaxNoiseSD(o.noiseType,SignalNegPos(o));
    oo{end+1}=o;
end
if true
    o.conditionName='Threshold flanker contrast for crowding';
    o.trialsDesired=40;
    o.useFlankers=true;
    o.contrast=-0.2;
    o.thresholdParameter='flankerContrast';
    o.thresholdResponseTo='flankers';
    o.task='identifyAll';
    o.noiseCheckDeg=o.targetHeightDeg/20;
    o.noiseSD=0;
    oo{end+1}=o;
    o.noiseSD=MaxNoiseSD(o.noiseType,SignalNegPos(o));
    oo{end+1}=o;
end

%% POLISH THE LIST OF CONDITIONS
for oi=1:length(oo)
    o=oo{oi};
    o.alternatives=length(o.alphabet);
    if all(o.eccentricityXYDeg==0)
        o.isTargetLocationMarked=false;
    else
        o.isTargetLocationMarked=true;
    end
    oo{oi}=o;
end

%% LOOK FOR PARTIAL RUNS OF THIS EXPERIMENT
oo=OfferToResumeExperiment(oo);

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT
% All these vars must be defined in every condition.
vars={'conditionName' 'trialsDesired' 'noiseSD' 'targetHeightDeg' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'thresholdParameter'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print the oo list of conditions.

%% RUN THE CONDITIONS
oo=RunExperiment(oo);

%% PRINT SUMMARY OF RESULTS AS TABLE TT
% Include whatever you're interested in. We skip rows missing any specified variable.
vars={'conditionName' 'observer' 'trials' 'trialsSkipped' ...
    'noiseSD' 'N' 'targetHeightDeg' 'flankerSpacingDeg' ...
    'eccentricityXYDeg' 'contrast' 'flankerContrast' };
tt=Experiment2Table(oo,vars);
disp(tt) % Print the list of conditions, with results.
if isempty(tt)
    return
end

%% FIT PSYCHOMETRIC FUNCTION
close all % Get rid of any existing figures.
for oi=1:height(tt)
    o=oo{oi};
    clear QUESTPlusFit % Clear the persistent variables.
    o.alternatives=length(o.alphabet);
    o.questPlusLapseRates=0:0.01:0.05;
    o.questPlusGuessingRates=0:0.03:0.3;
    o.questPlusSteepnesses=[1:0.5:5 6:10];
    oOut=QUESTPlusFit(o);
    o.plotFilename=[o.dataFilename '.plot'];
    file=fullfile(o.dataFolder,[o.plotFilename '.eps']);
    saveas(gcf,file,'epsc')
    fprintf('Plot saved in data folder as "%s".\n',[o.plotFilename '.eps']);
    
    %% PRELIMINARY ANALYSIS OF FLANKER DATA
    if isfield(o,'transcript') && isfield(o.transcript,'flankers') && isfield(o.transcript,'flankerResponse')
        n=length(o.transcript.response);
        left=zeros([1,n]);
        middle=zeros([1,n]);
        right=zeros([1,n]);
        for i=1:n
            left(i)=o.transcript.flankers{i}(1)==o.transcript.flankerResponse{i}(1);
            switch o.thresholdResponseTo
                case 'target'
                    middle(i)=o.transcript.target(i)==o.transcript.response{i};
                case 'flankers'
                    middle(i)=o.transcript.target(i)==o.transcript.targetResponse{i};
            end
            right(i)=o.transcript.flankers{i}(2)==o.transcript.flankerResponse{i}(2);
        end
        outer=left | right;
        fprintf('Condition %d, %d trials. Proportion correct, by position: %.2f %.2f %.2f\n',...
            oi,n,sum(left)/n,sum(middle)/n,sum(right)/n);
        a=[left' middle' right' outer'];
        [r,p] = corrcoef(a);
        disp('Correlation matrix, left, middle, right, outer:')
        disp(r)
        for i=1:n
            left(i)=ismember(o.transcript.flankers{i}(1),[o.transcript.flankerResponse{i} o.transcript.targetResponse{i}]);
            middle(i)=ismember(o.transcript.target(i),[o.transcript.flankerResponse{i} o.transcript.targetResponse{i}]);
            right(i)=ismember(o.transcript.flankers{i}(2),[o.transcript.flankerResponse{i} o.transcript.targetResponse{i}]);
        end
        fprintf('Condition %d, %d trials. Proportion correct, ignoring position errors: %.2f %.2f %.2f\n',...
            oi,n,sum(left)/n,sum(middle)/n,sum(right)/n);
    end
end


