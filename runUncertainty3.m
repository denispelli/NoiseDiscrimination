% runUncertainty3.m
% For Darshan Thapa's study of effects of uncertainty and complexity on
% efficiency.
% Copyright 2019, 2020 Denis G. Pelli, denis.pelli@nyu.edu
% March, 2020
% 646-258-7524

% Measure efficiency with spatial and temporal uncertainty. Also runs the
% ideal on the same conditions.
mainFolder=fileparts(mfilename('fullpath')); % Folder this m file is in.
addpath(fullfile(mainFolder,'lib')); % lib folder in that folder.
clear KbWait
clear o oo ooo
ooo={};
% o.useFractionOfScreenToDebug=0.4; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
o.useRetinaResolution=false; % Speed up 4x.

%% GEOMETRY
o.viewingDistanceCm=40;
o.askExperimenterToSetDistance=true;
o.isGazeRecorded=false;

%% PROCEDURE
o.askForPartingComments=false;
o.experiment='uncertainty';
o.thresholdParameter='contrast';

%% TASK
o.observer='';
o.trialsDesired=40;
o.isFixationCheck=false;

%% TARGET
o.isTargetFullResolution=true;
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=4;
o.contrast=-1;
o.targetKind='letter';
o.targetFont='Sloan';
o.minimumTargetHeightChecks=8;
o.alphabet='';
o.borderLetter='';
o.getAlphabetFromDisk=false;

%% FLANKER
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.useFlankers=false;
o.flankerContrast=-1;

%% NOISE
o.noiseType='ternary';

%% LUMINANCE
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
o.brightnessSetting=0.87;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 to maximize brightness.
if IsWin
    o.useNative11Bit=false;
end

%% FIXATION, NEAR POINT, AND TARGET MARKING
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.fixationBlankingRadiusReTargetHeight=0;
o.fixationBlankingRadiusReEccentricity=0;
o.isFixationBlankedNearTarget=true;
o.fixationOffsetBeforeNoiseOnsetSecs=0;
o.fixationOnsetAfterNoiseOffsetSecs=0;
o.fixationMarkDrawnOnStimulus=false;% o.conditionName='Sloan';
o.targetMarkDeg=3;
o.isTargetLocationMarked=false; % Display a mark designating target position?
o.fixationThicknessDeg=0.05; % Typically 0.03. Make it much thicker for scotopic testing.
o.useFixationDots=false;

%% RESPONSE SCREEN
o.areAnswersLabeled=false;
o.alphabetPlacement='top'; % 'top' 'bottom' 'right' or 'left' while awaiting response.
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomLeft'; % 'topLeft' 'bottomLeft'

%% PRINT ETC.
% o.printGrayLuminance=false;
% o.assessGray=true;
% o.assessLoadGamma=true;
% o.printContrastBounds=true;
o.saveSnapshot=false;

if true
    % Spatial uncertainty in rectangular area centered on fixation.
    % Temporal uncertainty.
    for MSpace=[100 1]
        for MTime=[1 10]
            o.MSpace=MSpace;
            o.MTime=MTime;
            o.showUncertainty=true;
            if  o.showUncertainty && o.isTargetLocationMarked
                error('Please don''t enable both o.showUncertainty and o.isTargetLocationMarked.');
            end
            o.uncertainDisplayDotDeg=1;
            o.uncertainParameter={'eccentricityXYDeg' 'moviePreAndPostSecs'};
            % Uncertainty is MSpace equally spaced positions in a grid
            % filling a square. and MTime equally spaced positions in time.
            radiusDeg=10;
            r=Screen('Rect',0);
            % Create rectangle of dot locations with same aspect ratio as
            % screen.
            ratio=RectWidth(r)/RectHeight(r);
            % Create square, to match shape of square noise area.
            % ratio=1;
            n=round(sqrt(ratio*MSpace));
            m=round(MSpace/n);
            s=o.targetHeightDeg;
            % o.noiseRadiusDeg=0.25*max([m n]+4)*s;
            x=(1:n)*s;
            x=x-mean(x);
            y=(1:m)*s;
            y=y-mean(y);
            eccentricityXYDegList={};
            % Doesn't work because "block" and "oi" are not yet defined.
            % fprintf('%d:%d Uncertain x:',block,oi);
            % fprintf(' %.0f',x);
            % fprintf('\n');
            % fprintf('%d:%d Uncertain y:',block,oi);
            % fprintf(' %.0f',y);
            % fprintf('\n');
            for i=1:n
                for j=1:m
                    eccentricityXYDegList{end+1}=[x(i) y(j)];
                end
            end
            o.MSpace=length(eccentricityXYDegList); % The exact value.
            o.isNoiseDynamic=true;
            o.targetDurationSecs=0.1;
            moviePreAndPostSecsList={}; % Only used if o.isNoiseDynamic.
            o.noiseCheckSecs=o.targetDurationSecs;
            totalSecs=(MTime-1)*o.targetDurationSecs;
            for i=1:MTime
                % Each iteration plans a different start time.
                preSecs=(i-1)*o.targetDurationSecs;
                % Allow 0.1 dead time before earliest target onset so we
                % can begin beep before target.
                moviePreAndPostSecsList{i}=0.1+[preSecs totalSecs-preSecs];
            end
            o.uncertainValues={eccentricityXYDegList moviePreAndPostSecsList};
            o.targetFont='Sloan';
            o.minimumTargetHeightChecks=8;
            o.targetKind='letter';
            targetKind = o.targetKind; % added by dar
            o.targetGaborPhaseDeg=nan;
            o.targetGaborSpaceConstantCycles=nan;
            o.targetGaborCycles=nan;
            o.targetCyclesPerDeg=nan;
            o.targetGaborOrientationsDeg=nan;
            o.responseLabels=false;
            o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
            o.alternatives=length(o.alphabet);
            o.alphabetPlacement='right'; % 'top' or 'right';
            o.areAnswersLabeled=false;
            o.contrast=-1;
            o.viewingDistanceCm=25;
            o.fixationMarkDrawnOnStimulus=false;
            o.fixationOnsetAfterNoiseOffsetSecs=0.6;
            ooo{end+1}=o;
            o.uncertainParameter={};
            o.uncertainValues={};
            o.showUncertainty=false;
        end
    end
end

%% Same conditions, using Forgetica
for i=1:4
    o=ooo{i};
    o.targetFont='Sans Forgetica';
    o.alphabet='abcdefghijklmnopqrstuvwxyz';
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end

%% Same conditions, using Gabor
for i=1:4
    o=ooo{i};
    o.targetKind='gabor';
    o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
    o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
    o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
    o.targetCyclesPerDeg=nan;
    o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
    o.responseLabels='VH'; % One for each targetGaborOrientationsDeg.
    o.alphabet='VH';
    o.alternatives=length(o.alphabet);
    o.areAnswersLabeled=true;
    ooo{end+1}=o;
end
if true
    % TEST WITH ZERO AND STRONG NOISE, INTERLEAVED
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            maxNoiseSD=MaxNoiseSD(oo(oi).noiseType,SignalNegPos(oo(oi)));
            if ismember(oo(oi).targetKind,{'image'})
                maxNoiseSD=0.8*maxNoiseSD;
            end
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
            oo(oi).setNearPointEccentricityTo='fixation';
            oo(oi).nearPointXYInUnitSquare=[0.5 0.5];
            oo(oi).noiseSD=maxNoiseSD;
        end
        ooNoNoise=oo;
        [ooNoNoise.noiseSD]=deal(0);
        ooo{block}=[oo ooNoNoise];
    end
end
if false
    % Measure threshold size at +/-10 deg. No noise.
    % Randomly interleave testing left and right.
    % Add fixation check.
    for block=1:length(ooo)
        o=ooo{block}(1);
        o.noiseSD=0;
        o.uncertainParameter={};
        o.uncertainValues={};
        o.isTargetFullResolution=true;
        o.targetHeightDeg=10;
        o.brightnessSetting=0.87;
        o.thresholdParameter='size';
        o.setNearPointEccentricityTo='fixation';
        o.nearPointXYInUnitSquare=[0.5 0.5];
        o.viewingDistanceCm=30;
        o.eccentricityXYDeg=[10 0];
        o.isFixationBlankedNearTarget=false;
        o.fixationOnsetAfterNoiseOffsetSecs=0.5;
        o.fixationMarkDrawnOnStimulus=false;
        oo=o;
        o.eccentricityXYDeg=-o.eccentricityXYDeg;
        oo(2)=o;
        % FIXATION TEST
        o.conditionName='Fixation check';
        o.targetKind='letter';
        o.isFixationCheck=true;
        o.eccentricityXYDeg=[0 0];
        o.thresholdParameter='spacing';
        o.useFlankers=true;
        o.targetHeightDeg=0.4;
        o.flankerSpacingDeg=1.4*o.targetHeightDeg;
        o.flankerContrast=-1;
        o.contrast=-1;
        o.targetFont='Sloan';
        o.minimumTargetHeightChecks=8;
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.targetKind='letter';
        o.alphabetPlacement='right'; % 'top' or 'right';
        o.areAnswersLabeled=false;
        o.getAlphabetFromDisk=false;
        o.alternatives=length(o.alphabet);
        oo(3)=o;
        ooo{end+1}=oo;
    end
end

%% Name each condition
for j=1:length(ooo)
    oo=ooo{j};
    for oi=1:length(oo)
        switch oo(oi).targetKind
            case 'letter'
                name=oo(oi).targetFont;
            case 'gabor'
                name=oo(oi).targetKind;
            otherwise
                error('Unknown targetKind.');
        end
        oo(oi).conditionName=sprintf('%s;%.0fdeg;MSpace=%d;MTime=%d',name,oo(oi).targetHeightDeg,oo(oi).MSpace,oo(oi).MTime);
    end
    oo=rmfield(oo,'MSpace');
    oo=rmfield(oo,'MTime');
    ooo{j}=oo;
end

if false
    % Retest contrast thresholds with ideal observer.
    for block=1:length(ooo)
        oo=ooo{block};
        if ~ismember(oo(1).thresholdParameter,{'contrast'})
            continue
        end
        for oi=1:length(oo)
            oo(oi).observer='ideal';
            oo(oi).trialsDesired=200;
        end
        ooo{end+1}=oo;
    end
end

%% ESTIMATE TIME TO COMPLETION
endsAtMin=0;
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        if ~ismember(oo(oi).observer,{'ideal'})
            endsAtMin=endsAtMin+[oo(oi).trialsDesired]/10;
        end
    end
    [ooo{block}(:).endsAtMin]=deal(endsAtMin);
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
    for oi=1:length(ooo{block})
        ooo{block}(oi).condition=oi;
        ooo{block}(oi).block=block;
    end
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
    error('Please fix this script %s so all blocks have the same set of fields.',mfilename);
end
for block=1:length(ooo)
    if block==1
        oo=ooo{block};
    else
        oo=[oo ooo{block}];
    end
end
t=struct2table(oo,'AsArray',true);
disp(t(:,{'experiment' 'block' 'condition' 'endsAtMin' 'conditionName'  ...
    'targetKind' 'noiseSD' ...
   'uncertainValues' 'uncertainParameter' ...
   'thresholdParameter' 'contrast' 'observer'   ...
    'targetFont' 'viewingDistanceCm' 'targetHeightDeg' 'eccentricityXYDeg' 'alternatives'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);