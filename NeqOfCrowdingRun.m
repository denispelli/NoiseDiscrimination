% NeqOfCrowdingRun.m
% Show target with two flankers. Measure threshold contrast of flankers to
% bring target identification to 75% correct.
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
    addpath('/Applications/mQuestPlus');
    addpath('/Applications/mQuestPlus/questplus');
    addpath('/Applications/mQuestPlus/psifunctions');
    addpath('/Applications/mQuestPlus/utilities');
    addpath('/Applications/mQuestPlus/printplot');
    addpath('/Applications/mQuestPlus/dataproc');
    addpath('/Applications/mQuestPlus/mathworkscentral/allcomb');
    addpath('/Applications/mQuestPlus/mathworkscentral/von_mises_cdf');
end
if ~exist('qpInitialize','file')
    error(['This script requires the QuestPlus package. ' ...
        'Please get it from https://github.com/BrainardLab/mQUESTPlus and ' ...
        'put it in your Applications folder. ' ...
        'Make sure the folder name is precisely "mQuestPlus". '...
        'You might need to remove a trailing "-master".']);
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
o.localHostName=cal.localHostName;
% o.useFractionOfScreenToDebug=0.4; % 0: normal, 0.5: small for debugging.

%% SPECIFY BASIC CONDITION
o.experiment='NeqOfCrowding';
o.nearPointXYInUnitSquare=[0.5 0.8];
o.eccentricityXYDeg=[0 15];
o.flankerSpacingDeg=3;
o.targetHeightDeg=2;
o.noiseCheckDeg=o.targetHeightDeg/20;
o.targetDurationSecs=0.2;
o.moviePreSecs=0.2;
o.moviePostSecs=0.2;
o.eyes='both';
o.contrast=-0.16;
o.flankerContrast=-1; % Negative for dark letters.
o.flankerArrangement='tangential'; % 'radial' 'radialAndTangential'
o.viewingDistanceCm=40;
o.symmetricLuminanceRange=true;
o.useDynamicNoiseMovie=true;
o.alphabetPlacement='right'; % 'top' or 'right';
o.annularNoiseSD=0;
o.noiseRadiusDeg=inf;
o.markTargetLocation=true;
o.fixationCrossWeightDeg=0.09;
o.fixationCrossDeg=3;
o.blankingRadiusReEccentricity=0; % No blanking.
o.blankingRadiusReTargetHeight=2;
o.targetMarkDeg=15;
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
    o.questPlusLogContrasts=-2.5:0.05:0.5;
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
    o.trialsInBlock=300;
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
    o.trialsInBlock=40;
    o.useFlankers=false;
    o.thresholdParameter='contrast';
    o.task='identify';
    o.noiseRadiusDeg=inf;
    o.noiseRaisedCosineEdgeThicknessDeg=0;
    o.complementNoiseEnvelope=false;
    o.noiseSD=0;
%     oo{end+1}=o;
    o.noiseSD=MaxNoiseSD(o.noiseType)/2;
%     oo{end}=[oo{end} o];
    o.noiseSD=MaxNoiseSD(o.noiseType);
%     oo{end}=[oo{end} o];
    o.conditionName='Threshold contrast noise-free target';
    o.noiseRadiusDeg=o.flankerSpacingDeg/2;
    o.noiseRaisedCosineEdgeThicknessDeg=o.flankerSpacingDeg/2;
    o.complementNoiseEnvelope=true;
%     oo{end}=[oo{end} o];
    oo{end+1}=o;
end
if true
%     o.useDynamicNoiseMovie=false;
%     o.targetDurationSecs=inf;
    o.conditionName='Threshold flanker contrast for crowding';
    o.trialsInBlock=40;
    o.useFlankers=true;
    o.contrast=-0.4;
    o.thresholdParameter='flankerContrast';
    o.thresholdResponseTo='target';
    o.task='identify';
    o.noiseCheckDeg=o.targetHeightDeg/20;
    % Create full-field noise with a soft-edged hole sparing the target.
    o.annularNoiseSD=0;
    o.noiseRadiusDeg=o.flankerSpacingDeg/2;
    o.noiseRaisedCosineEdgeThicknessDeg=o.flankerSpacingDeg/2;
    o.complementNoiseEnvelope=true;
    o.noiseSD=0;
    oo{end+1}=o;
    o.noiseSD=MaxNoiseSD(o.noiseType)/2;
    oo{end}=[oo{end} o];
    o.noiseSD=MaxNoiseSD(o.noiseType);
    oo{end}=[oo{end} o];
end

%% POLISH THE LIST OF CONDITIONS
for oi=1:length(oo)
    o=oo{oi};
    for ii=1:length(o)
        o(ii).alternatives=length(o(ii).alphabet);
    end
%     if all(o(1).eccentricityXYDeg==0)
%         o(1).markTargetLocation=false;
%     else
%         o(1).markTargetLocation=true;
%     end
    oo{oi}=o;
end

%% LOOK FOR PARTIAL RUNS OF THIS EXPERIMENT
oo=OfferToResumeExperiment(oo);

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT
% All these vars must be defined in every condition.
vars={'conditionName' 'trialsInBlock' 'noiseSD' 'targetHeightDeg' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'thresholdParameter'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt=vertcat(tt,t(:,vars));
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
for oi=1:length(oo)
    o=oo{oi};
    clear QUESTPlusFit % Clear the persistent variables.
    for ii=1:length(o)
        o(ii).alternatives=length(o(ii).alphabet);
        o(ii).questPlusLapseRates=0:0.01:0.05;
        o(ii).questPlusGuessingRates=0:0.03:0.3;
        o(ii).questPlusSteepnesses=[1:0.5:5 6:10];
        if isfield(o(ii),'psych') && isfield(o(ii).psych,'t')
            oOut=QUESTPlusFit(o(ii));
            o(ii).plotFilename=[o(ii).dataFilename '.plot'];
            file=fullfile(o(ii).dataFolder,[o(ii).plotFilename '.eps']);
            saveas(gcf,file,'epsc')
            fprintf('Plot saved in data folder as "%s".\n',[o(ii).plotFilename '.eps']);
        else
            fprintf('Skipping condition "%s", which has no o.psych record.\n',o(ii).conditionName);
        end
    end
    
    %% PRELIMINARY ANALYSIS OF FLANKER DATA
    for ii=1:length(o)
        if isfield(o(ii),'transcript') && isfield(o(ii).transcript,'flankers') && isfield(o(ii).transcript,'flankerResponse')
            n=length(o(ii).transcript.response);
            left=zeros([1,n]);
            middle=zeros([1,n]);
            right=zeros([1,n]);
            for i=1:n
                left(i)=o(ii).transcript.flankers{i}(1)==o(ii).transcript.flankerResponse{i}(1);
                switch o(ii).thresholdResponseTo
                    case 'target'
                        middle(i)=o(ii).transcript.target(i)==o(ii).transcript.response{i};
                    case 'flankers'
                        middle(i)=o(ii).transcript.target(i)==o(ii).transcript.targetResponse{i};
                end
                right(i)=o(ii).transcript.flankers{i}(2)==o(ii).transcript.flankerResponse{i}(2);
            end
            outer=left | right;
            fprintf('Condition %d, %d trials. Proportion correct, by position: %.2f %.2f %.2f\n',...
                oi,n,sum(left)/n,sum(middle)/n,sum(right)/n);
            a=[left' middle' right' outer'];
            [r,p] = corrcoef(a);
            disp('Correlation matrix, left, middle, right, outer:')
            disp(r)
            for i=1:n
                left(i)=ismember(o(ii).transcript.flankers{i}(1),[o(ii).transcript.flankerResponse{i} o(ii).transcript.targetResponse{i}]);
                middle(i)=ismember(o(ii).transcript.target(i),[o(ii).transcript.flankerResponse{i} o(ii).transcript.targetResponse{i}]);
                right(i)=ismember(o(ii).transcript.flankers{i}(2),[o(ii).transcript.flankerResponse{i} o(ii).transcript.targetResponse{i}]);
            end
            fprintf('Condition %d, %d trials. Proportion correct, ignoring position errors: %.2f %.2f %.2f\n',...
                oi,n,sum(left)/n,sum(middle)/n,sum(right)/n);
        end
    end
end


