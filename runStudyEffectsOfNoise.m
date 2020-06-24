% runStudyEffectsOfNoise.m
% March 02, 2020, April 18, 2020
mainFolder=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
addpath(fullfile(mainFolder,'utilities')); % Folder in same directory as this M file.
clear KbWait o oo
ooo={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The session is about 1 hour, including letter and gabor targets. Best to
% run this twice, to assess repeatability.
o.observer='';
% o.observer='ideal'; % Use this to test ideal observer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember(o.observer,{'ideal'})
    o.trialsDesired=200;
else
    o.trialsDesired=40;
end
if IsWin
    o.useNative11Bit=false;
end
% o.useFractionOfScreenToDebug=0.3; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
o.group='A'; % Include all conditions in a group, so they differ solely in their target.
o.isTargetLocationMarked=false;
o.useFixationGrid=false;
o.useFixationDots=true;
o.fixationDotsWeightDeg=0.05;
o.fixationDotsNumber=100;
o.fixationDotsWithinRadiusDeg=4;
o.targetDurationSecs=0.15;
o.askForPartingComments=false; % Disabled until it's fixed.
o.isGazeRecorded=false;
o.experiment='StudyEffectsOfNoise';
o.eccentricityXYDeg=[0 0];
o.contrast=-1;
% o.noiseType='gaussian';
o.noiseType='ternary'; % More noise power than 'gaussian'.
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.thresholdParameter='contrast';
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.useFlankers=false;
o.flankerContrast=-1;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomRight'; % 'topLeft' 'bottomLeft' 'bottomRight'
o.brightnessSetting=0.87;
o.askExperimenterToSetDistance=true;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 to maximize brightness.
o.isTargetFullResolution=true; % NEW December 6, 2019. denis.pelli@nyu.edu
o.isFixationClippedToStimulusRect=false;
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=[];
o.viewingDistanceCm=[];
o.minScreenDeg=[];
machine=IdentifyComputer;

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

for targetKind={'letter'} % 'gabor'}
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
            o.conditionName='letter';
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
    
    %% TABLE OF SIZE & ECC.
    tableCell = ...
        {0    [0.5 1   2 4 8 16];
        8    [	  1   2 4 8 16   ];
        16   [    1   2 4 8 16   ];
        32   [        2 4 8 16   ];}
    for iecc=1:size(tableCell,1)
        for ideg=1:size(tableCell{iecc,2},2)
            ecc = tableCell{iecc, 1};
            deg = tableCell{1, 2}(ideg);
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=deg;
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
if false
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
            o.noiseEnvelopeSpaceConstantDeg=inf;
            if o.targetHeightDeg>16 || ecc>16
                o.viewingDistanceCm=25;
            else
                o.viewingDistanceCm=60;
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

%% TEST WITH ZERO AND HIGH NOISE, WITH SEVERAL NOISE ENVELOPES.
if true
    NoiseDecayRadiusOverLetterRadius = [0.33, 0.58, 1.00, 1.75, 3.00, 32];
    % Each condition in oo becomes several conditions in ooNew.
    for block=1:length(ooo)
        oo=ooo{block};
        ooNew=[];
        for oi=1:length(oo)
            % if oo(oi).targetHeightDeg>16 && ismember(oo(oi).targetKind,{'letter'})
            %     % For 32 deg letter we reduce noise to stay below contrast
            %     % ceiling.
            %     maxNoiseSD=0.6*maxNoiseSD;
            % end
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
            % Add a new condition for each value in NoiseDecayRadiusOverLetterRadius.
            for iRatio=0:length(NoiseDecayRadiusOverLetterRadius)
                if iRatio==0
                    % no noise
                    oo(oi).noiseSD = 0; % Override previously specified noiseSD.
                    oo(oi).noiseEnvelopeSpaceConstantDeg = NaN;
                    %           iCounter = iCounter + 1;
                else
                    % high noise; noise decay radius (maxNoiseSD was already computed above)
                    oo(oi).noiseSD = maxNoiseSD;
                    oo(oi).noiseEnvelopeSpaceConstantDeg = ...
                        NoiseDecayRadiusOverLetterRadius(iRatio).*oo(oi).targetHeightDeg/2;
                end
                % Add condition to this block.
                ooNew=[ooNew oo(oi)];
            end
        end
        ooo{block}=ooNew;
    end
end

%% ESTIMATED TIME TO COMPLETION
% endsAtMin field is new name to be more self explanatory.
% Set block and condition fields.
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

%% PRINT TABLE OF CONDITIONS, ONE ROW PER THRESHOLD.
oo=[];
ok=true;
for block=1:length(ooo)
    [ooo{block}(:).block]=deal(block);
end
for block=2:length(ooo)
    % Demand that all blocks have the same fields.
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
% Print the conditions.
disp(t(:,{ 'experiment' 'endsAtMin' 'block' 'condition' 'conditionName'   ...
    'observer' 'targetKind' 'eccentricityXYDeg' 'targetHeightDeg' 'targetCyclesPerDeg'  'noiseCheckDeg' ...
    'noiseSD' 'noiseEnvelopeSpaceConstantDeg'...
    'viewingDistanceCm'  'trialsDesired' 'isFixationBlankedNearTarget'}));
% 'thresholdParameter'  'contrast' 'fixationBlankingRadiusReTargetHeight' 'uncertainParameter'
% return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);