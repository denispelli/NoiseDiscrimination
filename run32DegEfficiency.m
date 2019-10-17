% run32DegEfficiency.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019 Denis G. Pelli, denis.pelli@nyu.edu
%
% August 2, 2019 runComplexEfficiency now uses the new routine
% CheckExperimentFonts to make sure all needed fonts are in place before we
% run the experiment.
%
% June 4, 2019. Added "Fixation check" condition that is meant to be
% interleaved with all peripheral conditions. It presents an unvarying easy
% foveal identification task (a target letter between two flankers), which
% will be crowded beyond recognition if the observer's eye is more than 2
% deg from fixation. If the observer gets it wrong the program encourages
% better fixation, and runs two more foveal trials. Thus an observer who
% frequently fixates away from fixation will generate many errors and many
% extra trials. I hope this will help the observer learn to fixate
% reliably.
%
% On the first block the program asks for the experimenter's and observer's
% names. It remembers the names on subsequent blocks. It insists that the
% experiment's name be at least 3 characters and that the observer's name
% include first and last names (i.e. at least one character followed by a
% space followed by at least one character).
%
% Please use binocular viewing, using both eyes at all times.
%
% The script specifies the viewing distance. Please use a meter stick or
% tape measure to measure the viewing distance and ensure that the
% observer's eye is actually at the distance that the program thinks it is.
% Please encourage the observer to maintain the same viewing distance for
% the whole experiment.
%
% denis.pelli@nyu.edu June 4, 2019
% 646-258-7524

% Crowding distance at ±10 deg ecc x 2 orientation.
% Acuity at ±10 deg ecc.
mainFolder=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
clear KbWait
clear o oo ooo
ooo={};
if IsWin
    o.useNative11Bit=false;
end
% o.useFractionOfScreenToDebug=0.3; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
o.askForPartingComments=true;
o.recordGaze=false;
o.experiment='ComplexEfficiency';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=6;
o.contrast=-1;
o.noiseType='gaussian';
o.setNearPointEccentricityTo='target';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.blankingRadiusReTargetHeight=0;
o.blankingRadiusReEccentricity=0;
o.targetKind='letter';
o.targetHeightDeg=6;
o.thresholdParameter='contrast';
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.observer='';
o.trialsDesired=40;
o.brightnessSetting=0.87;
o.conditionName='Sloan';
o.targetFont='Sloan';
o.minimumTargetHeightChecks=8;
o.alphabet='';
o.borderLetter='';
o.labelAnswers=false;
o.getAlphabetFromDisk=false;
o.fixationCheck=false;
o.fixationCrossBlankedNearTarget=true;
o.fixationCrossBlankedUntilSecsAfterTarget=0.6;
o.fixationCrossDrawnOnStimulus=false;
o.fullResolutionTarget=false;
o.useFlankers=false;
o.flankerContrast=-1;
% o.printGrayLuminance=false;
% o.assessGray=true;
% o.assessLoadGamma=true;
% o.printContrastBounds=true;
o.symmetricLuminanceRange=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
o.viewingDistanceCm=40;
o.alphabetPlacement='top'; % 'top' 'bottom' 'right' or 'left' while awaiting response.
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomLeft'; % 'topLeft' 'bottomLeft'
o.brightnessSetting=0.87;
o.askExperimenterToSetDistance=true;

o.symmetricLuminanceRange=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 to maximize brightness.

if 1
    % Sloan
    o.fixationIsOffscreen=true;
    o.conditionName='Sloan';
    o.targetFont='Sloan';
    o.targetHeightDeg=32;
    o.eccentricityXYDeg=[32 0];
    r=Screen('Rect',0);
    % Shift right to equate right hand margin with
    % top and bottom margins.
    aspectRatio=RectWidth(r)/RectHeight(r);
    o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
    o.minimumTargetHeightChecks=8;
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.targetKind='letter';
    o.borderLetter='X';
    o.alphabetPlacement='right'; % 'top' or 'right';
    o.labelAnswers=false;
    o.getAlphabetFromDisk=true;
    o.contrast=-1;
    o.alternatives=length(o.alphabet);
    o.viewingDistanceCm=40;
    o.setNearPointEccentricityTo='target';
    ooo{end+1}=o;
end

if 1
    % Test with zero and high noise, interleaved.
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            maxNoiseSD=MaxNoiseSD(oo(oi).noiseType);
            if ismember(oo(oi).targetKind,{'image'})
                maxNoiseSD=0.8*maxNoiseSD;
            end
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
            oo(oi).noiseSD=0;
            oo(oi).noiseSD=maxNoiseSD; % DGP
        end
        ooNoise=oo;
        [ooNoise.noiseSD]=deal(maxNoiseSD);
        ooo{block}=[oo ooNoise];
    end
end
if 0
    % Measure threshold size at +/-10 deg. No noise.
    % Randomly interleave testing left and right.
    % Add fixation check.
    for block=1:length(ooo)
        o=ooo{block}(1);
        o.fullResolutionTarget=true;
        o.targetHeightDeg=10;
        o.brightnessSetting=0.87;
        o.thresholdParameter='size';
        o.setNearPointEccentricityTo='fixation';
        o.nearPointXYInUnitSquare=[0.5 0.5];
        o.viewingDistanceCm=30;
        o.eccentricityXYDeg=[10 0];
        o.fixationCrossBlankedNearTarget=false;
        o.fixationCrossBlankedUntilSecsAfterTarget=0.5;
        o.fixationCrossDrawnOnStimulus=false;
        oo=o;
        o.eccentricityXYDeg=-o.eccentricityXYDeg;
        oo(2)=o;
        % FIXATION TEST
        o.conditionName='Fixation check';
        o.targetKind='letter';
        o.fixationCheck=true;
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
        o.labelAnswers=false;
        o.getAlphabetFromDisk=false;
        o.alternatives=length(o.alphabet);
        oo(3)=o;
        ooo{end+1}=oo;
    end
end
if true
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
%% ESTIMATED TIME TO COMPLETION
willTakeMin=0;
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        if ~ismember(oo(oi).observer,{'ideal'})
            willTakeMin=willTakeMin+[oo(oi).trialsDesired]/10;
        end
    end
    [ooo{block}(:).willTakeMin]=deal(willTakeMin);
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
    if ~all([oo.symmetricLuminanceRange]) && any([oo.symmetricLuminanceRange])
        warning('block %d, o.symmetricLuminanceRange must be consistent among all interleaved conditions.',block);
        bad{end+1}='o.symmetricLuminanceRange';
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
%     'uncertainParameter'...
disp(t(:,{'block' 'experiment' 'targetKind' 'thresholdParameter'...
    'contrast' 'conditionName' 'observer' 'willTakeMin' 'noiseSD' ...
    'targetHeightDeg' 'eccentricityXYDeg' 'labelAnswers'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);