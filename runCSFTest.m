% runCSFTest.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019, 2020, Denis G. Pelli, denis.pelli@nyu.edu
% denis.pelli@nyu.edu
% March 14, 2020
% 646-258-7524
clear KbWait o oo
ooo={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare target thresholds in several noise distributions all with same
% noiseSD, which is highest possible.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MEASURE CSF

%% DEBUG
% o.useFractionOfScreenToDebug=0.3; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
% o.assessContrast=true;
% o.measureContrast=true;
% o.usePhotometer=true;

%% FIXATION
o.isTargetLocationMarked=false;
o.useFixationGrid=false;
o.useFixationDots=true;
o.fixationDotsWeightDeg=0.05;
o.fixationDotsNumber=100;
o.fixationDotsWithinRadiusDeg=4;

%% FLANKERS
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.useFlankers=false;
o.flankerContrast=-1;

%% GEOMETRY
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.viewingDistanceCm=[];
o.minScreenDeg=[];
o.isFixationClippedToStimulusRect=false;

%% LUMINANCE
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
o.brightnessSetting=1; % 0.87

%% NOISE
% o.noiseType='gaussian';
o.noiseType='ternary'; % More noise power than 'gaussian'.

%% OBSERVER AND TRIALS
o.observer='';
% o.observer='ideal'; % Use this to test ideal observer.
if ismember(o.observer,{'ideal'})
    o.trialsDesired=200;
else
    o.trialsDesired=40;
end

%% PATH
mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
addpath(fullfile(mainFolder,'utilities')); % Folder in same directory as this M file.

%% PRINT
% o.assessContrast=true;
% o.measureContrast=true;
% o.usePhotometer=true;

%% PROCEDURE
%o.group='A'; % Include all conditions in a group, so they differ solely in their target.
o.askForPartingComments=false; % Disabled until it's fixed.
o.isGazeRecorded=false;
o.experiment='CSFTest';
o.askExperimenterToSetDistance=true;
machine=IdentifyComputer;
if IsWin
    o.useNative11Bit=false;
end

%% RESPONSE SCREEN
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomRight'; % 'topLeft' 'bottomLeft' 'bottomRight'

%% TARGET
o.targetHeightDeg=[];
o.targetDurationSecs=0.15;
o.eccentricityXYDeg=[0 0];
o.contrast=-1;
o.thresholdParameter='contrast';
o.isTargetFullResolution=true; % NEW December 6, 2019. denis.pelli@nyu.edu

%% FIXATION
o.isFixationCheck=false; % True designates the condition as a fixation check.
o.isFixationClippedToStimulusRect=false;
if false
    % SEPARATE FIXATION IN TIME
    o.isFixationBlankedNearTarget=true;
    o.fixationOffsetBeforeNoiseOnsetSecs=0.6;
    o.fixationOnsetAfterNoiseOffsetSecs=0.6;
    o.fixationMarkDrawnOnStimulus=false;
else
    % SEPARATE FIXATION IN SPACE
    o.fixationOffsetBeforeNoiseOnsetSecs=0;
    o.fixationOnsetAfterNoiseOffsetSecs=0;
    o.fixationMarkDrawnOnStimulus=true;
    o.fixationBlankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
    o.fixationBlankingRadiusReEccentricity=0.5;
    o.fixationMarkDeg=inf;
    o.isFixationBlankedNearTarget=true;
    o.alphabetPlacement='bottom';
end

for targetKind={'gabor'} % 'letter' 'gabor'
    o.targetKind=targetKind{1};
    switch o.targetKind
        case 'gabor'
            o.minimumTargetHeightChecks=[];
            o.targetGaborOrientationsDeg=[0 45 90 135]; % Orientations relative to vertical.
            o.areAnswersLabeled=true;
            o.responseLabels='1234';
            o.alternatives=length(o.targetGaborOrientationsDeg);
            o.targetCyclesPerDeg=nan;
            o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
            if true
                o.conditionName='gabor3';
                o.targetGaborSpaceConstantCycles=0.75*3; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                o.targetGaborCycles=3*3; % cycles of the sinewave in targetHeight
            else
                o.conditionName='gabor1';
                o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                o.targetGaborCycles=3; % Cycles of the sinewave in targetHeight.
            end
            o.fixationBlankingRadiusReTargetHeight=2*o.targetGaborSpaceConstantCycles/o.targetGaborCycles; % Two space constants.
        case 'letter'
            o.conditionName='letterX';
            o.minimumTargetHeightChecks=8;
            o.targetGaborOrientationsDeg=[];
            o.alternatives=[];
            o.targetCyclesPerDeg=nan;
            o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
            o.targetGaborSpaceConstantCycles=[]; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
            o.targetGaborCycles=[]; % cycles of the sinewave in targetHeight
            o.areAnswersLabeled=false;
            o.responseLabels={};
            o.targetFont='Sloan';
            o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
            o.borderLetter='X';
            o.areAnswersLabeled=false;
            o.getAlphabetFromDisk=true;
            o.fixationBlankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
        otherwise
            error('Unknown o.targetKind ''%s''.',o.targetKind);
    end
    
    % for ecc=[0 2 8 32]
    for ecc=0
        for targetCyclesPerDeg=[1 3 9]
            % for deg=[0.5 2 8 32]
            o.targetCyclesPerDeg=targetCyclesPerDeg;
            deg=o.targetGaborCycles/o.targetCyclesPerDeg;
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=deg;
            % if restrictNoise
            % 	o.noiseEnvelopeSpaceConstantDeg=deg;
            % else
            % 	o.noiseEnvelopeSpaceConstantDeg=inf;
            % end
            if 1>ecc*(1-o.fixationBlankingRadiusReEccentricity) ...
                    || 1>ecc-o.fixationBlankingRadiusReTargetHeight*deg
                % Make sure at least 1 deg of fixation mark can be seen.
            end
            % MAX viewingDistanceCm while showing 1 deg of
            % screen (and maybe) fixation beyond what is blanked for target.
            heightCm=machine.mm{1}(2)/10;
            minScreenDeg=2*(1+o.fixationBlankingRadiusReTargetHeight*o.targetHeightDeg);
            maxViewingDistanceCm=floor(heightCm/2/tand(minScreenDeg/2));
            o.viewingDistanceCm=maxViewingDistanceCm;
            % WE NEED o.minScreenDeg
            o.minScreenDeg=2*(1+o.fixationBlankingRadiusReTargetHeight*o.targetHeightDeg);
            degMin=NominalAcuityDeg(o.eccentricityXYDeg);
            if deg<2*degMin
                continue
            end
            % o.viewingDistanceCm=200; % FOR DEMO
            % o.isFixationOffscreen=true; % FOR DEMO
            
            % EQUATE MARGINS
            % Shift right to equate right hand margin with top and bottom
            % margins.
            % r=Screen('Rect',0);
            % aspectRatio=RectWidth(r)/RectHeight(r);
            % o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
            o.alphabetPlacement='left'; % 'left' 'right' 'top' or 'bottom';
            o.contrast=-1;
            o.setNearPointEccentricityTo='fixation';
            ooo{end+1}=o;
        end
    end
end

% EXPAND EACH CONDITION INTO TWO, ADDING NEGATIVE ECCENTRICITY.
if true
    for block=1:length(ooo)
        oo=ooo{block};
        oo(2)=oo(1);
        oo(2).eccentricityXYDeg=-oo(1).eccentricityXYDeg;
        ooo{block}=oo;
    end
end

% COMPUTE MAX VIEWING DISTANCE TO RETAIN SPECIFIED UNBLANKED MARGIN FOR
% FIXATION MARK. IMPOSE CONSISTENCY WITHIN EACH BLOCK.
for i=1:length(ooo)
    oo=ooo{i};
    oo(1).minNotBlankedMarginReHeight=0.1;
    oo(1).minScreenDeg=[];
    oo(1).maxViewingDistanceCm=[];
    for oi=1:length(oo)
        o=oo(oi);
        o.minNotBlankedMarginReHeight=0.1;
        screenCm=min(machine.mm{1})/10; % Min of width and height.
        blankingDiameterDeg=2*o.fixationBlankingRadiusReTargetHeight*o.targetHeightDeg;
        o.minScreenDeg=blankingDiameterDeg/(1-2*o.minNotBlankedMarginReHeight);
        o.maxViewingDistanceCm=floor(screenCm/2/tand(o.minScreenDeg/2));
        oo(oi)=o;
    end
    [oo.viewingDistanceCm]=deal(min(200,min([oo.maxViewingDistanceCm])));
    ooo{i}=oo;
end

%% SHUFFLE. SORT BY DISTANCE.
ii=Shuffle(1:length(ooo));
ooo=ooo(ii);
d=cellfun(@(x) x.viewingDistanceCm,ooo);
[~,ii]=sort(d);
ooo=ooo(ii);

if false
    %% ADD PRACTICE CONDITION
    for ecc=32
        for deg=8
            o.conditionName='practice';
            o.isFixationBlankedNearTarget=true;
            o.trialsDesired=5; % For each condition, with and without noise.
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=deg;
            degMin=NominalAcuityDeg(o.eccentricityXYDeg);
            if restrictNoise
                o.noiseEnvelopeSpaceConstantDeg=deg;
            else
                o.noiseEnvelopeSpaceConstantDeg=inf;
            end
            if o.targetHeightDeg>16 || ecc>16
                o.viewingDistanceCm=25;
            else
                o.viewingDistanceCm=50;
            end
            if 1<ecc*(1-o.fixationBlankingRadiusReEccentricity) ...
                    || 1<ecc-o.fixationBlankingRadiusReTargetHeight*deg
                % Make sure that fixation mark has at least 1 deg radius.
                o.fixationMarkDeg=inf;
            else
                o.fixationMarkDeg=2;
            end
            r=Screen('Rect',0);
            
            %% EQUATE MARGINS
            % aspectRatio=RectWidth(r)/RectHeight(r);
            % o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
            o.alphabetPlacement='left'; % 'top' or 'right';
            o.contrast=-1;
            o.setNearPointEccentricityTo='fixation';
        end
    end
    ooo=[{o} ooo];
end

if false
    %% RUN EACH CONDITION WITH FOUR KINDS OF NOISE AND NO NOISE, INTERLEAVED.
    noiseTypeList={'gaussian' 'uniform' 'ternary' 'binary'};
    % The min value of MaxNoiseSD across our four noise types.
    maxNoiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(1)));
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=length(oo):-1:1
            switch oo(oi).targetKind
                case 'image'
                    noiseSD=0.8*maxNoiseSD;
                otherwise
                    noiseSD=maxNoiseSD;
            end
            if oo(oi).targetHeightDeg>20
                % Avoid raising threshold for 32 deg gabor too high.
                noiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(oi)))/2;
            end
            oo(oi).noiseSD=noiseSD;
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
            if oo(oi).targetHeightDeg<1
                oo(oi).noiseSD=min([MaxNoiseSD('ternary',SignalNegPos(oo(oi))) MaxNoiseSD('binary',SignalNegPos(oo(oi))) ]);
            end
        end
        [oo.noiseType]=deal(noiseTypeList{1});
        ooNoise=oo;
        oo=oo([]);
        for noiseType=noiseTypeList
            if ooNoise(1).targetHeightDeg<1 && ~ismember(noiseType,{'ternary' 'binary'})
                continue
            end
            [ooNoise.noiseType]=deal(noiseType{1});
            oo=[oo ooNoise];
        end
        [ooNoise.noiseType]=deal('ternary');
        ooNoise.noiseSD=0;
        oo=[oo ooNoise];
        ooo{block}=oo;
    end
end

%% TEST WITH ZERO (AND HIGH) NOISE, INTERLEAVED.
if true
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            maxNoiseSD=MaxNoiseSD(oo(oi).noiseType,SignalNegPos(oo(oi)));
            if ismember(oo(oi).targetKind,{'image'})
                maxNoiseSD=0.8*maxNoiseSD;
            end
            switch oo(oi).targetKind
                case 'letter'
                    oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
                case 'gabor'
                    % 10 checks per cycle.
                    oo(oi).noiseCheckDeg=(1.0/10)/oo(oi).targetCyclesPerDeg;
                otherwise
                    error('Unknown targetKind "%s".',oo(oi).targetKind);
            end
            oo(oi).noiseSD=0;
        end
        if true
            ooNoise=oo;
            [ooNoise.noiseSD]=deal(maxNoiseSD);
            ooo{block}=[oo ooNoise];
        else
            ooo{block}=oo;
        end
    end
end

%% ESTIMATED TIME TO COMPLETION
endsAtMin=0;
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        switch oo(oi).observer
            case 'ideal'
                % Ideal takes 0.8 s/trial.
                endsAtMin=endsAtMin+[oo(oi).trialsDesired]*0.8/60;
            otherwise
                % Human typically takes 6 s/trial.
                endsAtMin=endsAtMin+[oo(oi).trialsDesired]*6/60;
        end
        oo(oi).condition=oi;
    end
    ooo{block}=oo;
    [ooo{block}.endsAtMin]=deal(round(endsAtMin));
    [ooo{block}.block]=deal(block);
end

%% OOPS, NO WIRELESS KEYBOARD, SO LIMIT VIEWING DISTANCE to 60 CM, MAX.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).viewingDistanceCm=min([60 oo(oi).viewingDistanceCm]);
    end
    ooo{block}=oo;
end

%% COMPUTE MAX VIEWING DISTANCE IN REMAINING BLOCKS
maxCm=0;
for block=length(ooo):-1:1
    maxCm=max([maxCm ooo{block}(1).viewingDistanceCm]);
    [ooo{block}(:).maxViewingDistanceCm]=deal(maxCm);
end

%% MAKE SURE NEEDED FONTS ARE AVAILABLE
CheckExperimentFonts(ooo)

%% INTERLEAVED CONDITIONS MUST HAVE CONSISTENT CLUTS
bad={};
for block=1:length(ooo)
    if ~all([oo.isLuminanceRangeSymmetric]) && any([oo.isLuminanceRangeSymmetric])
        warning('block %d, o.isLuminanceRangeSymmetric must be consistent among all interleaved conditions.',block);
        bad{end+1}='o.isLuminanceRangeSymmetric';
    end
    if length(unique([oo.desiredLuminanceFactor]))>1
        warning('block %d, o.desiredLuminanceFactor must be consistent among all interleaved conditions.',block);
        bad{end+1}='o.desiredLuminanceFactor';
    end
end
bad=unique(bad);
if ~isempty(bad)
    error('Make %s consistent within each block. ',bad{:});
end

%% SORT THE FIELDS
for block=1:length(ooo)
    ooo{block}=SortFields(ooo{block});
end

%% PRINT TABLE OF CONDITIONS, ONE ROW PER THRESHOLD.
oo=[];
ok=true;
for block=1:length(ooo)
    [ooo{block}(:).block]=deal(block);
end
for block=2:length(ooo)
    % Demand perfect agreement in fields between all blocks.
    fBlock1=fieldnames(ooo{1});
    fBlock=fieldnames(ooo{block});
    if isfield(ooo{block},'conditionName')
        cond=[ooo{block}(1).conditionName ' '];
    else
        cond='';
    end
    for i=1:length(fBlock1)
        f=fBlock1{i};
        if ~ismember(f,fBlock)
            fprintf('%sBlock %d is missing field ''%s'', present in block 1.\n',cond,block,f);
            ok=false;
        end
    end
    for i=1:length(fBlock)
        f=fBlock{i};
        if ~ismember(f,fBlock1)
            fprintf('%sBlock %d has field ''%s'', missing in block 1.\n',cond,block,f);
            ok=false;
        end
    end
end
if ~ok
    error('Please fix the script so all blocks have the same set of fields.');
end
for block=1:length(ooo)
    oo=[oo ooo{block}];
end
t=struct2table(oo,'AsArray',true);
% 'uncertainParameter'...
disp(t(:,{'block' 'experiment' 'conditionName' 'observer'  'endsAtMin' 'trialsDesired' 'targetCyclesPerDeg' ...
    'noiseCheckDeg' 'targetKind' 'noiseType' 'thresholdParameter'...
    'contrast'  'noiseSD' ...
    'targetHeightDeg' 'viewingDistanceCm' 'eccentricityXYDeg' 'viewingDistanceCm' ...
    'isFixationBlankedNearTarget'})); % Print the conditions in the Command Window.
 return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);