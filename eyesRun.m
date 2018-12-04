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
if false && ~streq(cal.macModelName,'MacBookPro14,3')
    % For debugging, if this isn't a 15" MacBook Pro 2017, pretend it is.
    cal.screenWidthMm=330; % 13"
    cal.screenHeightMm=206; % 8.1"
    warning('PRETENDING THIS IS A 15" MacBook Pro 2017');
end
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

%% CREATE LIST OF CONDITIONS TO BE TESTED
% In each of the 3 domains: photon, cortical, ganglion
% Two noise levels, noiseSD: 0 0.16
o.experiment='eyes';
o.thresholdParameter='contrast';
o.viewingDistanceCm=40;
o.eyes='right';
o.trialsPerBlock=40;
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
o.blankingRadiusReEccentricity=0; % No blanking.
o.moviePreSec=0.3;
o.moviePostSec=0.3;
o.targetMarkDeg=1;
o.fixationCrossDeg=3;
if false
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
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.

%% SAVE CONDITIONS IN oo
oo={};
for domain=1:3
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
            o.fixationCrossWeightDeg=0.1; % Typically 0.03. Make it much thicker for scotopic testing.
        case 2
            % cortical
            o.conditionName='cortical';
            o.eccentricityXYDeg=[0 0];
            o.targetCyclesPerDeg=0.5;
            o.targetDurationSec=0.4;
            o.desiredLuminance=[];
            o.desiredLuminanceFactor=1;
            o.useFilter=false;
            o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it much thicker for scotopic testing.
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
            o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it much thicker for scotopic testing.
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
    for eyes=Shuffle({'right' 'both'})
        %    for eyes={'right'}
        o.eyes=eyes{1};
        for noiseSD=Shuffle([0 0.3])
            %       for noiseSD=0.3
            o.noiseType='binary';
            o.targetHeightDeg=o.targetGaborCycles/o.targetCyclesPerDeg;
            o.noiseCheckDeg=o.targetHeightDeg/10;
            o.noiseSD=noiseSD;
            oo{end+1}=o;
        end % for noiseSD
    end % for eyes=
end % for domain=1:3
for i=1:length(oo)
    oo{i}.condition=i; % Number the conditions
end

%% PRINT THE LIST OF CONDITIONS (ONE PER ROW)
% All these vars must be defined in every condition.
vars={'condition' 'experiment' 'conditionName' ...
    'useFilter' 'eccentricityXYDeg' ...
    'targetDurationSec' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetGaborCycles' 'noiseSD' };
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
    clear oOut
    for oi=1:length(oo) % Edit this line to select which conditions to run now.
        o=oo{oi};
        o.block=oi;
        o.blocksDesired=length(oo);
        o.alternatives=length(o.alphabet);
        if exist('oOut','var')
            % Reuse answers from immediately preceding block.
            o.experimenter=oOut.experimenter;
            o.observer=oOut.observer;
            % Setting o.useFilter false forces o.filterTransmission=1.
            o.filterTransmission=oOut.filterTransmission;
        end
        oOut=NoiseDiscrimination(o); % RUN THE EXPERIMENT!
        oo{oi}=oOut; % Save results in oo.
        if oOut.quitExperiment
            break
        end
        fprintf('\n');
    end % for oi=1:length(oo)
end % if ~skipDataCollection

%% PRINT THE LIST OF CONDITIONS (ONE PER ROW)
% All these vars must be defined in every condition.
vars={'condition' 'experiment' 'conditionName' ...
    'useFilter' 'eccentricityXYDeg' ...
    'targetDurationSec' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetGaborCycles' 'noiseSD' };
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% PRINT THE RESULTS
% We skip any condition without all these fields.
vars={'experiment' 'condition' 'observer' 'trials' 'luminanceAtEye' 'eccentricityXYDeg' 'targetDurationSec' 'targetCyclesPerDeg' 'noiseSD' 'targetHeightDeg' 'targetCyclesPerDeg' 'N' 'contrast'};
tt=table;
for oi=1:length(oo)
    t=struct2table(oo{oi},'AsArray',true);
    if ~all(ismember({'trials' 'transcript'},t.Properties.VariableNames)) || isempty(t.trials) || t.trials==0
        % Skip condition without data.
        continue
    end
    if false
        % Create empty cell for every missing field in the condition.
        missing=~ismember(vars,t.Properties.VariableNames);
        missingNames=vars(missing);
        for i=1:length(missingNames)
            name=missingNames{i};
            t.(name)=[];
        end
    else
        % Warn, skip the condition, and report which fields were missing.
        ok=ismember(vars,t.Properties.VariableNames);
        if ~all(ok)
            missing=join(vars(~ok),' ');
            warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
            continue
        end
    end
    tt(end+1,:)=t(1,vars);
end
disp(tt) % Print the list of conditions, with results.
