% runScalingTest.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019, 2020, Denis G. Pelli, denis.pelli@nyu.edu
% denis.pelli@nyu.edu
% February 2020
% 646-258-7524
mainFolder=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
addpath(fullfile(mainFolder,'utilities')); % Folder in same directory as this M file.
clear KbWait
clear o oo ooo
ooo={};
HasWirelessKeyboard;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare target thresholds in several noise distributions all with same
% noiseSD, which is highest possible.
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
o.askForPartingComments=false; % Disable until it's fixed.
o.isGazeRecorded=false;
o.experiment='ScalingTest';
o.eccentricityXYDeg=[0 0];
o.contrast=-1;
% o.noiseType='gaussian';
o.noiseType='ternary'; % More noise power than 'gaussian'.
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.thresholdParameter='contrast';
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.isFixationCheck=false; % True designates the condition as a fixation check.
o.fixationBlankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
o.fixationBlankingRadiusReEccentricity=0.5;
o.isFixationBlankedNearTarget=true;
o.fixationOnsetAfterNoiseOffsetSecs=0.6;
o.fixationMarkDrawnOnStimulus=false;
o.useFlankers=false;
o.flankerContrast=-1;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 for maximize brightness.
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomLeft'; % 'topLeft' 'bottomLeft'
o.brightnessSetting=0.87;
o.askExperimenterToSetDistance=true;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.desiredLuminanceFactor=1; % 1.8 to maximize brightness.
o.isTargetFullResolution=true; % NEW December 6, 2019. denis.pelli@nyu.edu
for targetKind={'letter' 'gabor'}
    o.targetKind=targetKind{1};
    switch o.targetKind
        case 'gabor'
            o.conditionName='gabor';
            o.minimumTargetHeightChecks=[];
            o.targetGaborOrientationsDeg=[0 45 90 135]; % Orientations relative to vertical.
            o.areAnswersLabeled=true;
            o.responseLabels='1234';
            o.alternatives=length(o.targetGaborOrientationsDeg);
            o.targetCyclesPerDeg=nan;
            o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
            %             o.targetGaborSpaceConstantCycles=0.75*3; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
            %             o.targetGaborCycles=3*3; % cycles of the sinewave in targetHeight
            %             o.conditionName='small';
            o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
            o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
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
    end
    % for ecc=[0 2 8 32]
    machine=IdentifyComputer;
    for ecc=[0]
        for deg=[0.5 2 8 32]
            % if restrictNoise
            % 	o.noiseEnvelopeSpaceConstantDeg=deg;
            % else
            % 	o.noiseEnvelopeSpaceConstantDeg=inf;
            % end
            if 1>ecc*(1-o.fixationBlankingRadiusReEccentricity) ...
                    || 1>ecc-o.fixationBlankingRadiusReTargetHeight*deg
                % Make sure that fixation mark has at least 1 deg radius.
                o.fixationMarkDeg=inf;
                o.fixationMarkDrawnOnStimulus=true;
            else
                o.fixationMarkDeg=2;
                o.fixationMarkDrawnOnStimulus=false;
            end
            o.isFixationBlankedNearTarget=true;
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=deg;
            degMin=NominalAcuityDeg(o.eccentricityXYDeg);
            if deg<2*degMin
                continue
            end
            % Scale viewing distance with screen height in mm.
            heightMm=machine.mm{1}(2);
%             nominalDistanceCm=25*heightMm/206;
            o.viewingDistanceCm=25/(o.targetHeightDeg/16);
            % o.viewingDistanceCm=200; % FOR DEMO
            % o.isFixationOffscreen=true; % FOR DEMO
            % EQUATE MARGINS
            r=Screen('Rect',0);
            aspectRatio=RectWidth(r)/RectHeight(r);
            o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
            o.alphabetPlacement='right'; % 'top' or 'right';
            o.contrast=-1;
            o.setNearPointEccentricityTo='fixation';
            ooo{end+1}=o;
        end
    end
end

%% SHUFFLE. SORT BY DISTANCE.
ii=Shuffle(1:length(ooo));
ooo=ooo(ii);
d=cellfun(@(x) x.viewingDistanceCm,ooo);
[~,ii]=sort(d);
ooo=ooo(ii);

if false
    % ADD PRACTICE CONDITION
    for ecc=32
        for deg=8
            o.conditionName='practice';
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
            aspectRatio=RectWidth(r)/RectHeight(r);
            o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
            o.alphabetPlacement='right'; % 'top' or 'right';
            o.contrast=-1;
            o.setNearPointEccentricityTo='fixation';
        end
    end
    ooo=[{o} ooo];
end

if false
    %% RUN EACH CONDITION WITH FOUR KINDS OF NOISE AND NO NOISE, INTERLEAVED.
    noiseTypeList={'gaussian' 'uniform' 'ternary' 'binary'};
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

if true
    % TEST WITH ZERO AND HIGH NOISE, INTERLEAVED.
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
            noiseSD=MaxNoiseSD(oo(oi).noiseType,SignalNegPos(oo(oi)));
            if oo(oi).targetHeightDeg>20
                % Avoid raising threshold for 32 deg gabor too high.
                noiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(oi)))/2;
            end
            if oo(oi).targetHeightDeg<1
                noiseSD=MaxNoiseSD('ternary',SignalNegPos(oo(oi)));
            end
            oo(oi).noiseSD=0;
        end
        ooNoise=oo;
        [ooNoise.noiseSD]=deal(noiseSD);
        ooo{block}=[oo ooNoise];
    end
end

%% ESTIMATE TIME TO COMPLETION
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
    end
    [ooo{block}(:).endsAtMin]=deal(round(endsAtMin));
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
disp(t(:,{'block' 'experiment' 'conditionName' 'observer'  'endsAtMin' 'trialsDesired'  'targetKind' 'noiseType' 'thresholdParameter'...
    'contrast'  'noiseSD' ...
    'targetHeightDeg'  'eccentricityXYDeg' 'viewingDistanceCm'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);