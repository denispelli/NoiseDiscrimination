% EvsNRun.m
% Measure E vs N for each of 3 conditions, with and
% without noise. We expect linearity always.
% April 5, 2018
% Denis Pelli

% Measure each Neq twice.
% Six observers.
% gabor target at 1 of 4 orientations
% P=0.75, assuming 4 alternatives
% monocular, temporal field, right eye

%% GET READY
clear o oo
o.questPlusEnable=false;
if ~exist('struct2table','file')
    error('This MATLAB %s is too old. We need MATLAB 2013b or better to use the function "struct2table".',version('-release'));
end
if o.questPlusEnable && ~exist('qpInitialize','file')
    error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
% o.useFractionOfScreenToDebug=0.4; % 0: normal, 0.5: small for debugging.
% o.observer='ideal';
% o.trialsDesired=100;

%% SPECIFY BASIC CONDITION
o.experiment='EvsN';
o.eyes='right'; % 'left', 'right', 'both'.
o.viewingDistanceCm=40;
o.targetGaborCycles=3;
o.pThreshold=0.75;
o.isNoiseDynamic=true;
o.moviePreAndPostSecs=[0.2 0.2];
o.fixationCrossDeg=3;
o.blankingRadiusReEccentricity=0;
o.blankingRadiusReTargetHeight=0;
o.targetMarkDeg=1;
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
if 0
    % Target letter
    o.targetKind='letter';
    o.targetFont='Sloan';
    o.alphabet='DHKNORSVZ';
else
    % Target gabor
    o.targetKind='gabor';
    o.targetGaborOrientationsDeg=[0 45 90 135];
    o.responseLabels='1234';
    o.alphabet=o.responseLabels;
end
o.alternatives=length(o.alphabet);
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

%% SPECIFY CONDITIONS IN oo STRUCT
oo={};
% THREE DOMAINS: photon, cortical, ganglion
for domain=0:3
    o.blankingRadiusReTargetHeight=nan;
    switch domain
        case 0
            % photon, binary noise
            o.conditionName='photon';
            o.eccentricityXYDeg=[0 0];
            o.targetCyclesPerDeg=4;
            o.targetDurationSecs=0.1;
            o.desiredLuminanceFactor=2.5/500; % cd/m^2
            o.noiseCheckFrames=10;
            o.useFilter=true;
            o.fixationCrossWeightDeg=0.05; % Typically 0.03. Use 0.05 for scotopic testing.
            o.blankingRadiusReTargetHeight=3;
            o.noiseType='gaussian';
        case 1
            % photon, gaussian noise
            o.conditionName='photon';
            o.eccentricityXYDeg=[0 0];
            o.targetCyclesPerDeg=4;
            o.targetDurationSecs=0.1;
            o.desiredLuminance=[];
            o.desiredLuminanceFactor=2.5/500;
            o.useFilter=true;
            o.fixationCrossWeightDeg=0.05; % Typically 0.03. Use 0.05 for scotopic testing.
            o.blankingRadiusReTargetHeight=3;
            o.noiseType='binary';
        case 2
            % cortical
            o.conditionName='cortical';
            o.eccentricityXYDeg=[0 0];
            o.targetCyclesPerDeg=0.5;
            o.targetDurationSecs=0.4;
            o.desiredLuminance=[];
            o.desiredLuminanceFactor=1;
            o.useFilter=false;
            o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it thicker for scotopic testing.
            o.noiseType='binary';
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
            o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it thicker for scotopic testing.
            o.noiseType='binary';
    end
    o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
    if all(o.eccentricityXYDeg==0)
        o.isTargetLocationMarked=false;
        o.fixationCrossDeg=inf;
    else
        o.isTargetLocationMarked=true;
        o.blankingRadiusReTargetHeight=0;
        o.fixationCrossDeg=3;
    end
    switch o.noiseType
        case 'gaussian'
            maxNoiseSD=0.16*2^0.5;
            p2=0.5;
        case 'binary'
            maxNoiseSD=0.16*2^2;
            p2=2;
    end
    for noiseSD=Shuffle([0 2.^(-4:1.5:p2)*0.16])
        o.noiseSD=noiseSD;
        o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
        o.noiseCheckDeg=o.targetHeightDeg/20;
        oo{end+1}=o;
    end
end
for i=1:length(oo)
    oo{i}.condition=i; % Number the conditions
end

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT.
% All these vars must be defined in every condition.
vars={'condition' 'experiment' 'conditionName' ...
    'useFilter' 'eccentricityXYDeg' ...
    'targetDurationSecs' 'targetHeightDeg' ...
    'targetCyclesPerDeg' 'targetGaborCycles' ...
    'noiseSD' 'noiseType' 'noiseCheckFrames'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% RUN THE CONDITIONS.
oo=RunExperiment(oo);

%% PRINT SUMMARY OF RESULTS AS TABLE TT.
% Include whatever you're intersted in. We skip rows missing any value.
vars={'condition' 'experiment' 'conditionName' ...
    'useFilter' 'luminanceAtEye' 'eccentricityXYDeg' ...
    'targetDurationSecs' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetGaborCycles'  'noiseCheckFrames'...
    'noiseSD' 'N' 'noiseType' 'E' 'contrast' 'dataFilename' 'dataFolder'};
tt=table;
for i=1:length(oo)
    % Grab the variables we want into a one-row table.
    t=struct2table(oo{i},'AsArray',true);
    % Skip empty rows.
    if ~all(ismember({'trials' 'contrast' 'transcript'},t.Properties.VariableNames)) || isempty(t.trials) || t.trials==0
        % Skip condition without data.
        continue
    end
    % Check that all vars are present. Skip any incomplete condition after
    % warning which fields were missing.
    ok=ismember(vars,t.Properties.VariableNames);
    if ~all(ok)
        missing=join(vars(~ok),' ');
        warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
        continue
    end
    % Add the complete row to our table of completed conditions.
    tt(end+1,:)=t(1,vars);
end
disp(tt) % Print summary.
if isempty(tt)
    return
end

%% SAVE SUMMARY OF RESULTS OF EXPERIMENT.
o=oo{1};
o.summaryFilename=[o.dataFilename '.summary'];
writetable(tt,fullfile(o.dataFolder,[o.summaryFilename '.csv']));
save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'tt','oo');
fprintf('Experiment summary (with %d blocks) saved in data folder as "%s" with extensions ".csv" and ".mat".\n',length(oo),o.summaryFilename);
