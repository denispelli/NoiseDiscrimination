% runDynamicCSFTest.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019, 2020, Denis G. Pelli, denis.pelli@nyu.edu
% denis.pelli@nyu.edu
% March 14, 2020
% 646-258-7524
mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib')); 
addpath(fullfile(mainFolder,'utilities')); 
clear KbWait o oo
ooo={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Replicate Banks, Geisler, and Bennett (1987), w and w/o noise.
o.observer='';
% o.observer='ideal'; % Use this to test ideal observer.
% o.useFractionOfScreenToDebug=0.3; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
o.screen=0;
machine=IdentifyComputer(o.screen);
if ismember(o.observer,{'ideal'})
    o.trialsDesired=200;
else
    o.trialsDesired=50;
end
if ~exist('IsWin')
    error('Please add the Psychtoolbox to MATLAB path by running UpdatePsychtoolbox.m.');
end
if IsWin
    o.useNative11Bit=false;
end

%% FLANKER
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.useFlankers=false;
o.flankerContrast=-1;

%% GEOMETRY
o.viewingDistanceCm=[];
o.minScreenDeg=[];
screenSizeXYCm=machine.mm{1}/10;
o.screenSizeXYDeg=[];

%% LUMINANCE
o.brightnessSetting=1.0; % As calibrated.
o.isTargetLocationMarked=false;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
% o.desiredLuminanceFactor=[]; % 1.8 to maximize brightness.
o.desiredLuminanceAtEye=230;
o.screen=0;
cal=OurScreenCalibrations(o.screen);
% Assuming we never change desiredLuminanceAtEye.
LMinMeanMax=[min(cal.old.L) o.desiredLuminanceAtEye max(cal.old.L)];

%% NOISE
% o.noiseType='ternary'; % More noise power than 'gaussian'.
o.noiseType='binary';
o.noiseSD=0;
o.noiseCheckFrames=2;
o.noiseCheckDeg=0;
o.noiseRadiusDeg=inf;
o.noiseEnvelopeSpaceConstantDeg=inf;

%% PRINTING
% o.printContrastBounds=true;
% o.printGrayLuminance=true;
% o.printImageStatistics=false;
% o.assessContrast=true;
% o.measureContrast=true;
% o.usePhotometer=true;

%% PROCEDURE
% o.group='A'; % All conditions in group share same fixation marks.
o.askForPartingComments=false; % Disabled until it's fixed.
o.experiment='dynamicCSF';
o.thresholdParameter='contrast';
o.askExperimenterToSetDistance=true;

%% RESPONSE
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomRight'; % 'topLeft' 'bottomLeft' 'bottomRight'

%% TARGET
o.eccentricityXYDeg=[0 0];
o.contrast=-1;
o.isTargetFullResolution=true; % NEW December 6, 2019. denis.pelli@nyu.edu
o.isFixationClippedToStimulusRect=false;
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=[];
o.targetMarginRadiusReHeight=0.75;

%% FIXATION AND TARGET MARKING
o.isFixationOffscreen=false;
o.fixationMarginRadiusDeg=0.5;
o.isGazeRecorded=false;
o.useFixationGrid=false;
o.useFixationDots=true;
o.fixationDotsWeightDeg=0.05;
o.fixationDotsNumber=100;
o.fixationDotsWithinRadiusDeg=4;
o.setNearPointEccentricityTo='target';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.isFixationCheck=false; % True designates the condition as a fixation check.
o.isFixationClippedToStimulusRect=false;
if true
    % TEMPORAL ISOLATION OF FIXATION
    o.isFixationBlankedNearTarget=false;
    o.fixationOffsetBeforeNoiseOnsetSecs=0;
    o.fixationOnsetAfterNoiseOffsetSecs=0;
    o.fixationMarkDrawnOnStimulus=false;
    o.fixationBlankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
    o.fixationBlankingRadiusReEccentricity=0.5;
else
    % SPATIAL ISOLATION OF FIXATION
    o.fixationOffsetBeforeNoiseOnsetSecs=0;
    o.fixationOnsetAfterNoiseOffsetSecs=0;
    o.fixationMarkDrawnOnStimulus=true;
    o.fixationBlankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
    o.fixationBlankingRadiusReEccentricity=0.5;
    o.fixationMarkDeg=inf;
    o.isFixationBlankedNearTarget=true;
    o.alphabetPlacement='bottom';
end

%% REPLICATE Banks, Geisler, & Bennett  (1987).
o.targetKind='gaborCosCos';
targetKinds={'gaborCosCos'};
o.isNoiseDynamic=true;
o.moviePreAndPostSecs=[0.5 0.5];
o.noiseType='binary'; % Most noise power.
o.noiseRadiusDeg=inf;
o.noiseCheckFrames=4;
o.conditionName='gaborCosCos';
o.targetDurationSecs=0.1;
eccentricities=0;
spatialFrequencies=[1 4 16]; % [0.5 2 8 32]
o.isFixationClippedToStimulusRect=true;
o.desiredLuminanceFactor=[]; % 1.8 to maximize brightness.
o.desiredLuminanceAtEye=230;
if o.isNoiseDynamic
    % Use fastest random number generator.
    s=rng;
    rng(s.Seed,'simdTwister');
end

%% MY EXPLORATION'
o.conditionName='gabor';
targetKinds={'gabor'};
% eccentricities=[0 4];
eccentricities=[0];
durations=[0.15 0.3 0.6];
allEnvelopeCycles=1.5*3; % 1.5*[1 3 9];

if false
    %% OPTIMIZE FOR HIGH SPATIAL FREQUENCY
    targetKinds={'gabor'};
    o.conditionName='gabor3';
    o.targetDurationSecs=0.3;
end

for targetKind=targetKinds % 'letter' 'gabor'
    o.targetKind=targetKind{1};
    switch o.targetKind
        case 'gaborCosCos'
            % TO REPLICATE Banks, Bennet, and Geisler 1987. Contrast
            % thresholds were estimated with a 2-interval, forced-choice
            % procedure in which contrast was varied according to a
            % 2-down/1-up staircase rule. Threshold criterion
            % P=--2*(1-P)=2-2P; 3P=2; P=0.67
            o.targetGaborCycles=7.5;
            o.pThreshold=0.67;
            o.targetDurationSecs=0.1;
            % 5, 7, 10, 14, 20, 28, and 40 c/deg.
            o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
            o.areAnswersLabeled=true;
            o.responseLabels='12';
            o.alternatives=length(o.targetGaborOrientationsDeg);
        case 'gabor'
            o.minimumTargetHeightChecks=[];
            o.targetGaborOrientationsDeg=[0 45 90 135]; % Orientations relative to vertical.
            o.areAnswersLabeled=true;
            o.responseLabels='1234';
            o.alternatives=length(o.targetGaborOrientationsDeg);
            o.targetCyclesPerDeg=nan;
            o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
            switch o.conditionName
                case 'gabor'
                    o.targetGaborSpaceConstantCycles=[]; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                    o.targetGaborCycles=[]; % cycles of the sinewave in targetHeight
                case 'gabor3'
                    o.targetGaborSpaceConstantCycles=0.75*3; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                    o.targetGaborCycles=3*3; % cycles of the sinewave in targetHeight
                case 'gabor1'
                    o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                    o.targetGaborCycles=3; % Cycles of the sinewave in targetHeight.
                otherwise
                    error('Unknown o.conditionName ''%s''.',o.conditionName);
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
            o.targetGaborCycles=[]; % Cycles of the sinewave in targetHeight
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
    end % switch o.targetKind
    for ecc=eccentricities
        for targetCyclesPerDeg=spatialFrequencies
            for envelopeCycles=allEnvelopeCycles
                for duration=durations
                    % for targetCyclesPerDeg=[1 3 9]
                    % for deg=[0.5 2 8 32]
                    o.eccentricityXYDeg=[ecc 0];
                    o.targetCyclesPerDeg=targetCyclesPerDeg;
                    o.targetEnvelopeCycles=envelopeCycles;
                    o.targetEnvelopeDeg=o.targetEnvelopeCycles/o.targetCyclesPerDeg;
                    o.targetDurationSecs=duration;
                    switch o.targetKind
                        case 'gabor'
                            o.targetGaborSpaceConstantCycles=o.targetEnvelopeCycles/2; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                            o.targetGaborCycles=2*o.targetEnvelopeCycles; % Cycles of the sinewave in targetHeight.
                    end
                    deg=o.targetGaborCycles/o.targetCyclesPerDeg;
                    o.targetHeightDeg=deg;
                    o.noiseRadiusDeg=3*o.targetHeightDeg;
                    % if restrictNoise
                    % 	o.noiseEnvelopeSpaceConstantDeg=deg;
                    % else
                    % 	o.noiseEnvelopeSpaceConstantDeg=inf;
                    % end
                    % Threshold size.
                    degMin=NominalAcuityDeg(o.eccentricityXYDeg);
                    if deg<2*degMin
                        % Skip condition if not comfortably within acuity limit.
                        % However, the size limit is appropriate for letters. For
                        % gabors, it should be an spatial frequency limit.
                        continue
                    end
                    ooo{end+1}=o;
                end
            end
        end
    end
end
clear o
if false
    % EXPAND EACH CONDITION INTO TWO, ADDING NEGATIVE ECCENTRICITY.
    if norm(oo(oi).eccentricityXYDeg)>0
        for block=1:length(ooo)
            oo=ooo{block};
            oo(2)=oo(1);
            oo(2).eccentricityXYDeg=-oo(1).eccentricityXYDeg;
            ooo{block}=oo;
        end
    end
end

%% Compute o.targetEnvelopeDeg and o.targetEnvelopeDeg, which are the full extent of envelope at 1/e.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        switch oo(oi).targetKind
            case {'gaborCos' 'gaborCosCos'}
                % Half cosine. Nonzero full extent is o.targetHeightDeg.
                oo(oi).targetEnvelopeDeg=oo(oi).targetHeightDeg*acos(exp(-1))/(pi/2); % trig scalar is 0.7602
            case 'gabor'
                oo(oi).targetEnvelopeDeg=2*oo(oi).targetGaborSpaceConstantCycles/oo(oi).targetCyclesPerDeg;
            case {'letter' 'image'}
                oo(oi).targetEnvelopeDeg=oo(oi).targetHeightDeg;
            otherwise
                error('Unknown o.targetKind ''%s''.',oo(oi).targetKind);
        end % switch oo(oi).targetKind
        if ~isfield(oo(oi),'targetEnvelopeCycles') || isempty(oo(oi).targetEnvelopeCycles)
            oo(oi).targetEnvelopeCycles=oo(oi).targetEnvelopeDeg*oo(oi).targetCyclesPerDeg;
        end
    end
    ooo{block}=oo;
end

% o.fixationMarginRadiusDeg=0.5;
% o.targetMarginRadiusReHeight=0.75;

% COMPUTE MAX VIEWING DISTANCE to respect specified margins for target and
% fixation mark. Does not consider noiseRadiusDeg or flankers.
% DEPENDS ON: eccentricityXYDeg, targetHeightDeg, and screenSizeXYCm.
for block=1:length(ooo)
    oo=ooo{block};
    % Largest target margin across all conditions in block.
    [oo.targetMarginRadiusDeg]=deal(max([oo.targetMarginRadiusReHeight].*[oo.targetHeightDeg]));
    screenSizeXYCm=machine.mm{oo(1).screen+1}/10;
    for oi=1:length(oo)
        % Relative to fixation, separately for x and y, compute greatest
        % margin extent (re fixation) along line through fixation and
        % target center.
        % Beyond fixation, away from target.
        fixationSideXYMarginDeg=max(oo(oi).fixationMarginRadiusDeg,...
            oo(oi).targetMarginRadiusDeg-abs(oo(oi).eccentricityXYDeg));
        % Beyond target, away from fixation.
        targetSideXYMarginDeg=max(oo(oi).targetMarginRadiusDeg+...
            abs(oo(oi).eccentricityXYDeg),...
            oo(oi).fixationMarginRadiusDeg);
        oo(oi).minScreenSizeXYDeg=...
            fixationSideXYMarginDeg+targetSideXYMarginDeg;
        oo(oi).maxViewingDistanceCm=(screenSizeXYCm/2) ./ ...
            tand(oo(oi).minScreenSizeXYDeg/2);
        oo(oi).maxViewingDistanceCm=min(oo(oi).maxViewingDistanceCm);
        oo(oi).maxViewingDistanceCm=floor(oo(oi).maxViewingDistanceCm);
    end
    ooo{block}=oo;
end

% Currently, the strategy is to maximize viewing distance. I'm not sure
% what's optimum, but having high pixel density in the target is good.
% Observers tire quickly when viewing distance is 25 cm. They seem happy
% indefinitely at viewing distances of 40 to 200 cm. Distances larger than
% 200 cm can be hard to accomodate in a small room.

% INITIALLY SET viewingDistanceCm to maxViewingDistanceCm, but no farther
% than 200 cm. Impose consistency of viewing distance within each block.
% maxViewingDistanceCm, above, is rigorous. Selection of desired
% viewingDistanceCm, within that bound, is quite arbitrary.
fprintf('%d: TENTATIVE VALUES OF viewingDistanceCm, screenSizeXYDeg.\n',...
    MFileLineNr);
fprintf('block:condition, viewingDistanceCm, screenSizeXYDeg\n');
for block=1:length(ooo)
    oo=ooo{block};
    [oo.viewingDistanceCm]=deal(min(200,min([oo.maxViewingDistanceCm])));
    [oo.screenSizeXYDeg(1:2)]=deal(...
        2*atan2d(screenSizeXYCm/2,oo(1).viewingDistanceCm));
    for oi=1:length(oo)
        fprintf('%d:%d %3.0f cm, [%2.0f %2.0f] deg\n',...
            block,oi,oo(oi).viewingDistanceCm,oo(oi).screenSizeXYDeg);
    end
    ooo{block}=oo;
end

%% SHUFFLE, THEN SORT BY DISTANCE.
ii=Shuffle(1:length(ooo));
ooo=ooo(ii);
d=cellfun(@(x) x.viewingDistanceCm,ooo);
[~,ii]=sort(d);
ooo=ooo(ii);

%% NEED WIRELESS KEYBOARD? WILL USER ATTACH ONE?
% Compute max viewing distance across all blocks.
maxViewingDistanceCm=[];
for block=1:length(ooo)
    maxViewingDistanceCm=max([maxViewingDistanceCm ooo{block}.viewingDistanceCm]);
end
if ~ismember(ooo{1}(1).observer,{'ideal'})
    hasWirelessKeyboard=HasWirelessKeyboard;
    if maxViewingDistanceCm>60 && ~hasWirelessKeyboard
        fprintf(['Ideally this experiment would use viewing distances up to %.0f cm, \n' ...
            'but that would require a wireless keyboard.\n'],maxViewingDistanceCm);
        hasWirelessKeyboard=RequestWirelessKeyboard;
    end
else
    hasWirelessKeyboard=true;
end

% warning('FOR DEBUGGING: SKIPPED THE CHECK, AND ASSUMING YOU HAVE A WIRELESS KEYBOARD.');
% hasWirelessKeyboard=true;

%% IF NO WIRELESS KEYBOARD THEN LIMIT VIEWING DISTANCE TO AT MOST 60 CM.
if ~hasWirelessKeyboard
    fprintf('<strong>No wireless keyboard, so limiting viewing distance to at most 60 cm.</strong>\n');
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            oo(oi).viewingDistanceCm=min([60 oo(oi).viewingDistanceCm]);
            oo(oi).screenSizeXYDeg(1:2)=...
                2*atan2d(screenSizeXYCm/2,oo(oi).viewingDistanceCm);
        end
        ooo{block}=oo;
    end
end

%% PLACE NEARPOINT ON SCREEN WHEN setNearPointEccentricityTo=='target'
% DEPENDS ON: screenSizeXYDeg, which depends on viewingDistanceCm.
targetMarginRadiusXYInUnitSquare=oo(oi).targetMarginRadiusDeg ./ oo(oi).screenSizeXYDeg;
fixationMarginRadiusXYInUnitSquare=oo(oi).fixationMarginRadiusDeg ./ oo(oi).screenSizeXYDeg;
for block=1:length(ooo)
    oo=ooo{block};
    % o.fixationMarginRadiusDeg=0.5;
    [oo.targetMarginRadiusDeg]=deal(max([oo.targetMarginRadiusReHeight].*[oo.targetHeightDeg]));
    targetMarginRadiusXYInUnitSquare=oo(oi).targetMarginRadiusDeg ./ oo(oi).screenSizeXYDeg;
    fixationMarginRadiusXYInUnitSquare=oo(oi).fixationMarginRadiusDeg./oo(oi).screenSizeXYDeg;
    if ismember(oo(1).setNearPointEccentricityTo,{'target'}) && ~oo(oi).isFixationOffscreen
        if any(oo(oi).eccentricityXYDeg~=oo(1).eccentricityXYDeg)
            % Our code assumes equal eccentricity, so skip if that's not
            % true.
            oo(oi).nearPointXYInUnitSquare=[0.5 0.5];
            error(...
                ['We allow setting ' ...
                'o.setNearPointEccentricityTo=''target'' only if all '...
                'targets are at same o.eccentricityXYDeg.']);
            continue
        end
        for oi=1:length(oo)
            % Here we place fixation, given that all targets share a single
            % (possibly nonzero) eccentricity. There are three sub-cases:
            % 1. Keep target at screen center [0.5 0.5] provided fixation
            % margin does not extend beyond screen.
            % 2. Otherwise, shift the target and fixation together
            % (conserving eccentricity) so that fixation margin is at
            % screen edge, and target is on the other side of screen
            % center. However, target margin must not extend beyond screen
            % edge.
            % 3. Otherwise flag error: The screen is too small to hold both
            % target and fixation. Suggest shorter viewing distance or
            % off-screen fixation.
            
            % 1. Begin with target at screen center.
            oo(oi).nearPointXYInUnitSquare=[0.5 0.5];
            fixationXYInUnitSquare=oo(oi).nearPointXYInUnitSquare-...
                oo(oi).eccentricityXYDeg ./ oo(oi).screenSizeXYDeg;
            % 2. If fixation margin extends beyond screen, then shift
            % target and fixation together, so fixation margin is at screen
            % edge.
            deltaXY=[0 0];
            for i=1:2 % First X, then Y.
                if fixationXYInUnitSquare(i)<fixationMarginRadiusXYInUnitSquare(i)
                    % If fixation margin is too far left or low, then push
                    % it back to screen edge.
                    deltaXY(i)= fixationMarginRadiusXYInUnitSquare(i)-fixationXYInUnitSquare(i);
                end
                if fixationXYInUnitSquare(i)>1-fixationMarginRadiusXYInUnitSquare(i)
                    % If fixation margin is too far right or too high, then
                    % push it back to screen edge.
                    deltaXY(i)= 1-fixationMarginRadiusXYInUnitSquare(i)-fixationXYInUnitSquare(i);
                end
            end
            % Shift fixation and target, together, by same deltaXY.
            fixationXYInUnitSquare=fixationXYInUnitSquare+deltaXY;
            oo(oi).nearPointXYInUnitSquare=oo(oi).nearPointXYInUnitSquare(i)+deltaXY;
            % 3. If target margin extends beyond screen edge, flag error.
            if any(oo(oi).nearPointXYInUnitSquare<targetMarginRadiusXYInUnitSquare |...
                    oo(oi).nearPointXYInUnitSquare>1-targetMarginRadiusXYInUnitSquare)
                msg=sprintf(['block %d: condition %d. targetHeightDeg %.0f and eccentricity [%.0f %.0f] deg '...
                    'too large to include both target and fixation on [%.0f %.0f] deg screen. '...
                    'Reduce %.0f viewingDistanceCm or '...
                    'use off-screen fixation.'],...
                    block,oi,...
                    oo(oi).targetHeightDeg,oo(oi).eccentricityXYDeg,...
                    oo(oi).screenSizeXYDeg,oo(oi).viewingDistanceCm);
                warning(msg);
            end
        end % for oi=
        ooo{block}=oo;
    end % if ismember(oo(1).setNearPointEccentricityTo,{'target'})
end % for block=1:length(ooo)

% THESE SETTING PRODUCE A LARGE SIGNAL, EASY TO SEE BY MANY PEOPLE LOOKING
% AT ONE SCREEN.
% o.viewingDistanceCm=200; % FOR DEMO
% o.isFixationOffscreen=true; % FOR DEMO

if false
    % EQUATE TOP AND RIGHT MARGINS
    % Shift right to equate right hand margin with top and bottom
    % margins.
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            oo(oi).contrast=-1;
            % oo(oi).setNearPointEccentricityTo='fixation';
            r=Screen('Rect',0);
            aspectRatio=RectWidth(r)/RectHeight(r);
            o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
        end
        ooo{block}=oo;
    end
end

fprintf('%d: FINAL VALUES OF viewingDistanceCm, screenSizeXYDeg, nearPointXYInUnitSquare.\n',MFileLineNr);
fprintf('block:condition, viewingDistanceCm, screenSizeXYDeg, nearPointXYInUnitSquare\n');
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        fprintf('%d:%d %3.0f cm, [%2.0f %2.0f] deg, [%3.1f %3.1f]\n',...
            block,oi,oo(oi).viewingDistanceCm,oo(oi).screenSizeXYDeg,oo(oi).nearPointXYInUnitSquare);
    end
end

if false
    %% ADD PRACTICE CONDITION
    for ecc=32
        for deg=8
            oo(oi).conditionName='practice';
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
            % viewingDistanceCm AND screenSizeXYDeg MAY BE MODIFIED ON
            % LINES 218, 289, 386, 388
            if o.targetHeightDeg>16 || ecc>16
                o.viewingDistanceCm=25;
            else
                o.viewingDistanceCm=50;
            end
            [o.screenSizeXYDeg(1:2)]=deal(...
                2*atan2d(screenSizeXYCm/2,o.viewingDistanceCm));
            if 1<ecc*(1-o.fixationBlankingRadiusReEccentricity) ...
                    || 1<ecc-o.fixationBlankingRadiusReTargetHeight*deg
                % Make sure that fixation mark has at least 1 deg radius.
                o.fixationMarkDeg=inf;
            else
                o.fixationMarkDeg=2;
            end
            r=Screen('Rect',0);
        end
    end
    ooo=[{o} ooo];
end

if false
    %% RUN EACH CONDITION WITH FOUR KINDS OF NOISE AND NO NOISE, INTERLEAVED.
    noiseTypeList={'gaussian' 'uniform' 'ternary' 'binary'};
    maxNoiseSD=MaxNoiseSD(oo(1).noiseType,SignalNegPos(oo(1)),LMinMeanMax);
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=length(oo):-1:1
            switch oo(oi).targetKind
                case 'image'
                    noiseSD=0.8*MaxNoiseSD('gaussian',SignalNegPos(oo(oi)),LMinMeanMax);
                otherwise
                    noiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(oi)),LMinMeanMax);
            end
            if oo(oi).targetHeightDeg>20
                % Avoid raising threshold for 32 deg gabor too high.
                noiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(oi)),LMinMeanMax)/2;
            end
            oo(oi).noiseSD=noiseSD;
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/20;
            if oo(oi).targetHeightDeg<1
                oo(oi).noiseSD=MaxNoiseSD('ternary',SignalNegPos(oo(oi)),LMinMeanMax);
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
            maxNoiseSD=MaxNoiseSD(oo(oi).noiseType,SignalNegPos(oo(oi)),LMinMeanMax);
            if ismember(oo(oi).targetKind,{'image'})
                maxNoiseSD=0.8*maxNoiseSD;
            end
            switch oo(oi).targetKind
                case 'letter'
                    if oo(oi).isNoiseDynamic
                        % 20 checks per letter height when making a movie.
                        oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/20;
                    else
                        % 40 checks per letter height for static noise.
                        oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
                    end
                case {'gabor' 'gaborCosCos'}
                    if oo(oi).isNoiseDynamic
                        % 5 checks per cycle when making a movie.
                        oo(oi).noiseCheckDeg=(1/5)/oo(oi).targetCyclesPerDeg;
                        % 4 checks per cycle when making a movie.
                        oo(oi).noiseCheckDeg=(1/4)/oo(oi).targetCyclesPerDeg;
                    else
                        % 10 checks per cycle for static noise.
                        oo(oi).noiseCheckDeg=(1/10)/oo(oi).targetCyclesPerDeg;
                    end
                otherwise
                    error('Unknown targetKind "%s".',oo(oi).targetKind);
            end
            oo(oi).noiseSD=0;
        end
        if true
            ooNoise=oo;
            [ooNoise.noiseSD]=deal(maxNoiseSD);
            ooo{block}=[oo ooNoise];
            %             ooo{block}=ooNoise;
        else
            ooo{block}=oo;
        end
    end
end

%% TWO LUMINANCES
if false
    for block=1:length(ooo)
        [ooo{block}.desiredLuminanceAtEye]=deal(300);
        ooo{end+1}=ooo{block};
        [ooo{end}.desiredLuminanceAtEye]=deal(30);
    end
end

for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        %         fprintf('%d:%d noiseSD %.2f,LMinMeanMax [%.0f %.0f %.0f]\n',...
        %             block,oi,oo(oi).noiseSD,LMinMeanMax);
        assert(oo(oi).desiredLuminanceAtEye==LMinMeanMax(2));
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

%% SET NOISE EXTENT
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).annularNoiseBigRadiusDeg=2*oo(oi).targetHeightDeg;
        oo(oi).annularNoiseBigRadiusDeg=inf;
        % Restrict noise radius to not extend beyond screen. This gives a
        % huge speed benefit.
        oo(oi).noiseRadiusDeg=min(oo(oi).noiseRadiusDeg,oo(oi).screenSizeXYDeg(2)/2);
    end
    ooo{block}=oo;
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
% Print the conditions in the Command Window.
disp(t(:,{'experiment' 'block' 'condition' 'conditionName' 'observer'  'endsAtMin' 'viewingDistanceCm' ...
    'noiseSD' 'targetCyclesPerDeg' 'targetEnvelopeCycles' 'targetEnvelopeDeg'  'targetDurationSecs' ...
    'nearPointXYInUnitSquare' 'screenSizeXYDeg' 'targetHeightDeg' 'eccentricityXYDeg' 'trialsDesired' 'noiseRadiusDeg' ...
    'targetEnvelopeDeg'  ...
    'desiredLuminanceAtEye' 'noiseCheckDeg' 'targetKind' 'noiseType' 'thresholdParameter'...
    'contrast'  ...
    'isGazeRecorded' ...
    ... % 'isFixationBlankedNearTarget'
    }));
% return

%% Measure threshold, one block per iteration.
doProfile=false;
if doProfile
    profile on;
end
ooo=RunExperiment(ooo);
if doProfile
    p=profile('info');
    profile off
    i=find(ismember({p.FunctionTable.FunctionName},'NoiseDiscrimination'),1);
    t=p.FunctionTable(i);
    lines=t.ExecutedLines;% [line n secs]
    clear s tt
    s.line=lines(:,1);
    s.n=lines(:,2);
    s.sTotal=lines(:,3);
    s.ms=round(1000*lines(:,3)./lines(:,2));
    fid=fopen(t.FileName);
    txt=fgetl(fid);
    text={};
    while ischar(txt)
        text{end+1}=txt;
        txt=fgetl(fid);
    end
    for i=1:length(s.line)
        s.text{i}=strip(text{s.line(i)});
    end
    s.text=s.text';
    tt=struct2table(s);
    tt=sortrows(tt,'sTotal','descend');
    tt=tt(tt.n>1,:);
    tt(1:10,{'n','sTotal','ms','line','text'})
    totalTime=sum(sortedLines(ii,3));
    fprintf('%.1f s total time in table (excluding lines executed fewer than 20 times).\n',totalTime);
end