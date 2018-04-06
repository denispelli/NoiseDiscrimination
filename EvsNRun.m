% EvsNRun.m
% Measure E vs N for each of 3 conditions, with and
% without noise. We expect linearity always.
% April 5, 2018
% Denis Pelli

% STANDARD CONDITION
% January 31, 2018
% Measure each Neq twice.
% Six observers.
% gabor target at 1 of 4 orientations
% P=0.75, assuming 4 alternatives
% luminance 250 cd/m2
% monocular, temporal field, right eye

%% MAX SD OF EACH NOISE TYPE
% With the same bound on range, we can reach 3.3 times higher noiseSd using
% binary instead of gaussian noise. In the code below, we use steps of
% 2^0.5=1.4, so i increase noiseSd by a factor of 2^1.5=2.8 when using
% binary noise.
sdOverBound.gaussian=0.43;
sdOverBound.uniform=0.58;
sdOverBound.binary=1.41;
maxBound=0.37; % Rule of thumb based on experience with gaussian.
maxSd=struct('gaussian',maxBound*sdOverBound.gaussian,'uniform',maxBound*sdOverBound.uniform,'binary',maxBound*sdOverBound.binary);
maxSd

%% GET READY
clear o oo
skipDataCollection=false; % Enable skipDataCollection to check plotting before we have data.
o.questPlusEnable=false;
if ~exist('struct2table','file')
    error('This MATLAB %s is too old. We need MATLAB 2013b or better to use the function "struct2table".',version('-release'));
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

%% SPECIFY BASIC CONDITION
o.experiment='EvsN';
o.eyes='right'; % 'left', 'right', 'both'.
o.viewingDistanceCm=40;
o.targetGaborCycles=3;
o.pThreshold=0.75;
o.useDynamicNoiseMovie=true;
o.moviePreSec=0.2;
o.moviePostSec=0.2;
o.fixationCrossDeg=3;
o.blankingRadiusReEccentricity=0;
o.blankingRadiusReTargetHeight=0;
o.targetMarkDeg=1;
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
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'

%% SAVE CONDITIONS IN oo
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
            o.targetDurationSec=0.1;
            o.desiredLuminance=2.5; % cd/m^2
            o.desiredLuminanceFactor=[];
            o.useFilter=true;
            o.fixationCrossWeightDeg=0.05; % Typically 0.03. Use 0.05 for scotopic testing.
            o.blankingRadiusReTargetHeight=3;
            o.noiseType='gaussian';
        case 1
            % photon, gaussian noise
            o.conditionName='photon';
            o.eccentricityXYDeg=[0 0];
            o.targetCyclesPerDeg=4;
            o.targetDurationSec=0.1;
            o.desiredLuminance=2.5; % cd/m^2
            o.desiredLuminanceFactor=[];
            o.useFilter=true;
            o.fixationCrossWeightDeg=0.05; % Typically 0.03. Use 0.05 for scotopic testing.
            o.blankingRadiusReTargetHeight=3;
            o.noiseType='binary';
        case 2
            % cortical
            o.conditionName='cortical';
            o.eccentricityXYDeg=[0 0];
            o.targetCyclesPerDeg=0.5;
            o.targetDurationSec=0.4;
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
    if 0
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
        o.fixationCrossDeg=inf;
    else
        o.markTargetLocation=true;
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

%% PRINT THE CONDITIONS
% All these vars must be defined in every condition.
vars={'condition' 'experiment' 'conditionName' ...
    'useFilter' 'eccentricityXYDeg' ...
    'targetDurationSec' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetGaborCycles' 'noiseSD' 'noiseType'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% RUN THE CONDITIONS
if ~skipDataCollection
    % Typically, you'll select just a few of the conditions stored in oo
    % that you want to run now. Select them from the printout of "tt" in your
    % Command Window.
    % NOTE: Typically, conditions with the same conditionName are randonly shuffled
    % every time you run this, unless you set o.seed, above, to the 'seed'
    % used to generate the table you want to reproduce.
    clear oOut
    for oi=1:length(oo) % Edit this line to select which conditions to run now.
        o=oo{oi};
        o.runNumber=oi;
        o.runsDesired=length(oo);
        if exist('oOut','var')
            % Reuse answers from immediately preceding run.
            o.experimenter=oOut.experimenter;
            o.observer=oOut.observer;
            % Setting o.useFilter false forces o.filterTransmission=1.
            o.filterTransmission=oOut.filterTransmission;
        end
        oOut=NoiseDiscrimination(o); % RUN THE EXPERIMENT!
        oo{oi}=oOut; % Save results in oo.
        if oOut.quitSession
            break
        end
        fprintf('\n');
    end % for oi=1:length(oo)
end % if ~skipDataCollection

%% PRINT SUMMARY OF RESULTS
% All these vars must be defined in every condition.
vars={'condition' 'experiment' 'conditionName' ...
    'useFilter' 'luminanceAtEye' 'eccentricityXYDeg' ...
    'targetDurationSec' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetGaborCycles' 'noiseSD' 'N' 'noiseType' 'E' 'contrast'};
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

%% SAVE SUMMARY OF RESULTS
o=oOut;
if isfield(o,'dataFilename')
    o.summaryFilename=[o.dataFilename '.summary'];
    writetable(tt,fullfile(o.dataFolder,[o.summaryFilename '.csv']));
    save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'tt','oo');
    fprintf('Summary saved in data folder as "%s" with extensions ".csv" and ".mat".\n',o.summaryFilename);
end
