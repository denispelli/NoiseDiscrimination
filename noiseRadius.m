% noiseRadiusRun.m
% Measure threshold vs noise radius at four sizes and four eccentricities.
% May 17, 2018
% Denis Pelli

% letter OR
% gabortarget at 1 of 4 orientations
% P=0.75, assuming 4 alternatives
% binocular, right field?

error('fix fixation for 1 deg ecc.');

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
o.trialsPerBlock=1;
% o.printLogOfIdeal=true;
% Screen('Preference', 'Verbosity',0);

%% SPECIFY BASIC CONDITION
o.experiment='noiseRadius'; 
o.eyes='both'; % 'left', 'right', 'both'.
o.viewingDistanceCm=40;
o.targetGaborCycles=3;
o.pThreshold=0.75;
o.useDynamicNoiseMovie=false;
o.moviePreSecs=0.2;
o.moviePostSecs=0.2;
o.fixationCrossDeg=3;
o.blankingRadiusReEccentricity=0;
o.blankingRadiusReTargetHeight=0;
o.targetMarkDeg=1;
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary' or 'ternary'
if 1
    % Target letter
    o.targetKind='letter';
    o.targetFont='Sloan';
    o.alphabet='DHKNOSVZ';
    o.contrast=-1;
else
    % Target gabor
    o.targetKind='gabor';
    o.targetGaborOrientationsDeg=[0 45 90 135];
    o.targetGaborNames='1234';
    o.alphabet=o.targetGaborNames;
    % o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
    % o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
    o.contrast=1;
end
o.alternatives=length(o.alphabet);
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

%% SPECIFY CONDITIONS IN ooo STRUCT
ooo={};
o.blankingRadiusReTargetHeight=nan;
o.targetDurationSecs=0.2;
o.desiredLuminanceAtEye=[];
o.desiredLuminanceFactor=1;
o.useFilter=false;
o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it thicker for scotopic testing.
o.noiseType='ternary';
o.saveStimulus=false;
o.noiseCheckFrames=2;
o.targetGaborCycles=3;
o.observer='';
for ecc=[0 1 8 32]
    o.eccentricityXYDeg=[ecc 0];
    for sz=16 %[0.5 4 32]
        if NominalAcuityDeg(ecc)>sz
            continue
        end
        o.targetHeightDeg=sz;
        oo=[]; % Interleave these conditions.
        for radius=0.5*sz*[4] %0.5*sz*[0.5 1 4]
            o.noiseEnvelopeSpaceConstantDeg=radius;
            o.targetCyclesPerDeg=o.targetGaborCycles/o.targetHeightDeg;
            o.alphabetPlacement='left';
            o.nearPointXYInUnitSquare=[0.80 0.5];
            if streq(o.observer,'ideal')
                % Don't waste time generating noise far from the signal.
                o.noiseRadiusDeg=o.targetHeightDeg/1.4;
            else
                o.noiseRadiusDeg=max(2*radius,4*o.targetHeightDeg);
            end
            o.noiseCheckDeg=o.targetHeightDeg/20;
            if all(o.eccentricityXYDeg==0)
                o.markTargetLocation=false;
                o.blankingRadiusReTargetHeight=0.6;
                o.fixationCrossDeg=inf;
            else
                o.markTargetLocation=true;
                o.blankingRadiusReTargetHeight=0;
                o.fixationCrossDeg=3;
            end
            switch o.targetKind
                case 'gabor'
                    o.conditionName=sprintf('%.0f-deg-%.1f-cpd',o.eccentricityXYDeg(1),o.targetCyclesPerDeg);
                case 'letter'
                    o.conditionName=sprintf('ec-%.0f-deg-%.1f-deg',o.eccentricityXYDeg(1),o.targetHeightDeg);
            end
            o.noiseSD=MaxNoiseSD(o.noiseType);
            if isempty(oo)
                oo=o;
            else
                oo(end+1)=o;
            end
        end % for radius
        ooo{end+1}=oo;
    end % for sz
end % for ecc
for i=1:length(ooo)
    [ooo{i}.block]=deal(i); % Number the blocks
end

%% PRINT THE CONDITIONS (ONE PER ROW) AS TABLE TT.
% All these vars must be defined in every condition.
vars={'block' 'experiment' 'conditionName' ...
    'eccentricityXYDeg' 'targetCyclesPerDeg' 'noiseSD' ...
    'targetDurationSecs' 'targetHeightDeg' ...
    'targetGaborCycles' 'useDynamicNoiseMovie'};
tt=table;
for i=1:length(ooo)
    t=struct2table(ooo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% RUN THE CONDITIONS.
ooo=RunExperiment(ooo);

%% PRINT SUMMARY OF RESULTS AS TABLE TT.
% Include whatever you're intersted in. We skip rows missing any value.
vars={ 'block' 'conditionName' ...
    'eccentricityXYDeg' 'targetCyclesPerDeg' 'targetHeightDeg' 'noiseSD' 'N' 'E' 'contrast' ...
    'targetGaborCycles'  'noiseCheckFrames'...
    'noiseType' 'useDynamicNoiseMovie' 'dataFilename'};
tt=table;
for i=1:length(ooo)
    t=struct2table(ooo{i},'AsArray',true);
    % Skip empty rows.
    if ~all(ismember({'trials' 'contrast' 'transcript'},t.Properties.VariableNames)) || isempty(t.trials) || all(t.trials==0)
        % Skip condition without data.
        continue
    end
    tt(end+1:end+height(t),:)=t(:,vars);
end
% for i=1:length(oo)
%     % Grab the variables we want into a one-row table.
%     t=struct2table(oo{i},'AsArray',true);
%     % Check that all vars are present. Skip any incomplete condition after
%     % warning which fields were missing.
%     ok=ismember(vars,t.Properties.VariableNames);
%     if ~all(ok)
%         missing=join(vars(~ok),' ');
%         warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
%         continue
%     end
%     % Add the complete row to our table of completed conditions.
%     tt(end+1,:)=t(1,vars);
% end
disp(tt) % Print summary.
if isempty(tt)
    return
end

%% SAVE SUMMARY OF RESULTS OF EXPERIMENT.
o=ooo{1}(1);
o.summaryFilename=[o.dataFilename '.summary'];
writetable(tt,fullfile(o.dataFolder,[o.summaryFilename '.csv']));
save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'tt','ooo');
fprintf('Experiment summary (with %d blocks) saved in data folder as "%s" with extensions ".csv" and ".mat".\n',length(ooo),o.summaryFilename);
