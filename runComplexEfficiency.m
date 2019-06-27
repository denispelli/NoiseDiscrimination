% runComplexEfficiency.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019 Denis G. Pelli, denis.pelli@nyu.edu
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
% On the first block the program will ask the experimenter's and observer's
% names. On subsequent blocks it will remember the names.
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
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
clear KbWait
clear o oo ooo
ooo={};
% o.useFractionOfScreenToDebug=0.3; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
o.recordGaze=false;
o.experiment='ComplexEfficiency';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=6;
o.contrast=-1;
o.noiseType='gaussian';
o.setNearPointEccentricityTo='fixation';
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
o.readAlphabetFromDisk=false;
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
% As of June 23, alphabetPlacement='bottom' prevents showing labels, labelAnswers=true;
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomLeft'; % 'topLeft' 'bottomLeft'
o.brightnessSetting=0.87;
if 1
    if false
        % Target letter
        o.conditionName='Sloan';
        o.targetKind='letter';
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ';
        o.alphabetPlacement='right'; % 'top' or 'right';
    else
        % Target face
        o.conditionName='face';
        o.signalImagesFolder='faces';
        o.signalImagesAreGammaCorrected=true;
        o.convertSignalImageToGray=true;
        o.alphabetPlacement='right'; % 'top' or 'right';
        o.targetKind='image';
        o.alphabet='abcdefghijklmnopq';
        o.brightnessSetting=0.87;
        o.labelAnswers=true;
        o.symmetricLuminanceRange=false; % False for maximum brightness.
        o.desiredLuminanceFactor=1.1; % 1.8 for maximize brightness.
    end
    o.targetMargin=0;
    o.viewingDistanceCm=40;
    o.contrast=1; % Select contrast polarity.
    o.task='identify';
    o.eccentricityXYDeg=[0 0];
    o.targetHeightDeg=10;
    o.targetDurationSecs=0.15;
    o.trialsDesired=40;
    o.lapse=nan;
    o.steepness=nan;
    o.guess=nan;
    o.observer='';
    o.noiseSD=0;
    o.thresholdParameter='contrast';
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
o.symmetricLuminanceRange=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
if 1
    % Sloan
    o.conditionName='Sloan';
    o.targetFont='Sloan';
    o.minimumTargetHeightChecks=8;
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.targetKind='letter';
    o.borderLetter='X';
    o.labelAnswers=false;
    o.readAlphabetFromDisk=true;
    o.contrast=-1;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 0
    % Checkers alphabet
    o.conditionName='Checkers';
    o.targetFont='Checkers';
    o.minimumTargetHeightChecks=16;
    o.alphabet='abcdefghijklmnopqrstuvwxyz';
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 1
    % Animals alphabet
    o.conditionName='Animals';
    o.targetFont='Animals';
    o.minimumTargetHeightChecks=16;
    o.alphabetPlacement='top';
    o.alphabet='abcdefghijklmnopqrstuvwxyz';
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=false;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 1
    % Sans Forgetica
    o.targetFont='Sans Forgetica';
    o.conditionName=o.targetFont;
    o.minimumTargetHeightChecks=8;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
    o.labelAnswers=false;
    o.readAlphabetFromDisk=true;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 0
    % Kuenstler
    o.targetFont='Kuenstler Script LT Medium';
    o.conditionName=o.targetFont;
    o.minimumTargetHeightChecks=12;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 0
    % Black Sabbath
    o.targetFont='SabbathBlackRegular';
    o.conditionName=o.targetFont;
    o.minimumTargetHeightChecks=10;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 0
    % Chinese from Qihan
    o.targetFont='Songti TC Regular';
    o.conditionName=o.targetFont;
    o.minimumTargetHeightChecks=16;
    o.alphabet=[20687 30524 38590 33310 28982 23627 29245 27169 32032 21338 26222 ...
        31661 28246 36891 24808 38065 22251 23500 39119 40517];
    o.alphabet=char(o.alphabet);
    o.alphabetPlacement='top';
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    o.alternatives=length(o.alphabet);
    ooo{end+1}=o;
end
if 0
    % Japanese: Katakana, Hiragani, and Kanji
    % from Ayaka
    o.targetFont='Hiragino Mincho ProN W3';
    japaneseScript='Kanji';
    o.conditionName=japaneseScript;
    o.alphabetPlacement='top';
    switch japaneseScript
        case 'Katakana'
            o.alphabet=[12450 12452 12454 12456 12458 12459 12461 12463 12465 12467 12469 ... % Katakana from Ayaka
                12471 12473 12475 12477 12479 12481 12484 12486 12488 12490 12491 ... % Katakana from Ayaka
                12492 12493 12494 12495 12498 12501 12408 12507 12510 12511 12512 ... % Katakana from Ayaka
                12513 12514 12516 12518 12520 12521 12522 12523 12524 12525 12527 ... % Katakana from Ayaka
                12530 12531];                                                      % Katakana from Ayaka
            o.minimumTargetHeightChecks=16;
        case 'Hiragana'
            o.alphabet=[12354 12362 12363 12365 12379 12383 12394 12395 12396 12397 12399 ... % Hiragana from Ayako
                12405 12411 12414 12415 12416 12417 12420 12422 12434];            % Hiragana from Ayako
            o.minimumTargetHeightChecks=16;
        case 'Kanji'
            o.alphabet=[25010 35009 33016 23041 22654 24149 36605 32302 21213 21127 35069 ... % Kanji from Ayaka
                37806 32190 26286 37707 38525 34276 38360 38627 28187];               % Kanji from Ayaka
            o.minimumTargetHeightChecks=16;
    end
    o.alphabet=char(o.alphabet);
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    o.alternatives=length(o.alphabet);
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
            oo(oi).setNearPointEccentricityTo='fixation';
            oo(oi).nearPointXYInUnitSquare=[0.5 0.5];
            oo(oi).noiseSD=0;
        end
        ooNoise=oo;
        [ooNoise.noiseSD]=deal(maxNoiseSD);
        ooo{block}=[oo ooNoise];
    end
end

if true
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
        %% FIXATION TEST
        o.symmetricLuminanceRange=true; % False for maximum brightness.
        o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
        o.conditionName='Fixation check';
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
        o.labelAnswers=false;
        o.readAlphabetFromDisk=false;
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
%% ESTIMATED TIME OF ARRIVAL (ETA)
etaMin=0;
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        if ~ismember(oo(oi).observer,{'ideal'})
            etaMin=etaMin+[oo(oi).trialsDesired]/10;
        end
    end
    [ooo{block}(:).etaMin]=deal(etaMin);
end
%% COMPUTE MAX VIEWING DISTANCE IN REMAINING BLOCKS
maxCm=0;
for block=length(ooo):-1:1
    maxCm=max([maxCm ooo{block}(1).viewingDistanceCm]);
    [ooo{block}(:).maxViewingDistanceCm]=deal(maxCm);
end
%% MAKE SURE NEEDED FONTS ARE AVAILABLE
if isfield(ooo{1}(1),'targetFont')
    fonts={};
    for block=1:length(ooo)
        for oi=1:length(ooo{block})
            fonts{end+1}=ooo{block}(oi).targetFont;
        end
    end
    fonts=unique(fonts);
    if ~FontsAvailable(fonts)
        error('Please install missing fonts.');
    end
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
disp(t(:,{'block' 'experiment' 'targetKind' 'thresholdParameter'...
    'contrast' 'conditionName' 'observer' 'etaMin' 'noiseSD' ...
    'targetHeightDeg' 'eccentricityXYDeg' 'labelAnswers'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);