% runBigGaborTest.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019, 2020, Denis G. Pelli, denis.pelli@nyu.edu
% denis.pelli@nyu.edu
% February 2020
% 646-258-7524
mainFolder=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
addpath(fullfile(mainFolder,'utilities')); % Folder in same directory as this M file.
clear KbWait o oo
ooo={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare target thresholds in several noise distributions all with same
% noiseSD, which is highest possible.
% CAUTION: Only o.setNearPointEccentricityTo='target' if all conditions have same eccentricity.
o.observer='';
o.observer='ideal'; % Use this to test ideal observer.
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
machine=IdentifyComputer;
o.isGazeRecorded=false;
o.experiment='BigGaborTest';
o.eccentricityXYDeg=[0 0];
o.contrast=-1;
% o.noiseType='gaussian';
o.noiseType='ternary'; % More noise power than 'gaussian'.
o.setNearPointEccentricityTo='target';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.thresholdParameter='contrast';
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.isFixationCheck=false; % True designates the condition as a fixation check.
o.blankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
o.blankingRadiusReEccentricity=0.5;
o.fixationCrossBlankedNearTarget=true;
o.fixationOnsetAfterNoiseOffsetSecs=0.6;
o.fixationCrossDrawnOnStimulus=false;
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

o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=[];
o.fixationCrossDeg=inf;
o.clipToStimulusRect=false;
o.fixationCrossDrawnOnStimulus=true;
o.fixationCrossBlankedNearTarget=true;
o.viewingDistanceCm=[];
o.alphabetPlacement='right';
o.minScreenDeg=[];
machine=IdentifyComputer;

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
            % o.targetGaborSpaceConstantCycles=0.75*3; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
            % o.targetGaborCycles=3*3; % cycles of the sinewave in targetHeight
            % o.conditionName='small';
            o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
            o.targetGaborCycles=3; % Cycles of the sinewave in targetHeight.
            o.blankingRadiusReTargetHeight=2*o.targetGaborSpaceConstantCycles/o.targetGaborCycles; % Two space constants.
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
            o.blankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
        otherwise
            error('Unknown o.targetKind ''%s''.',o.targetKind);
    end
    % for ecc=[0 2 8 32]
    for ecc=0
        % for deg=[0.5 2 8 32]
        for deg=[8 32]
            for isFixationLocal=1
                % if restrictNoise
                % 	o.noiseEnvelopeSpaceConstantDeg=deg;
                % else
                % 	o.noiseEnvelopeSpaceConstantDeg=inf;
                % end
                %             if 1>ecc*(1-o.blankingRadiusReEccentricity) ...
                %                     || 1>ecc-o.blankingRadiusReTargetHeight*deg
                % Make sure that fixation mark has at least 1 deg radius.
                o.eccentricityXYDeg=[ecc 0];
                o.targetHeightDeg=deg;
                heightCm=machine.mm{1}(2)/10;
                if ~isFixationLocal
                    o.fixationCrossDeg=inf;
                    o.clipToStimulusRect=false;
                    o.fixationCrossDrawnOnStimulus=true;
                    o.fixationCrossBlankedNearTarget=true;
                    % Maximize viewingDistanceCm while showing 1 deg of
                    % fixation.
                    minScreenDeg=2*(1+o.blankingRadiusReTargetHeight*o.targetHeightDeg);
                    maxViewingDistanceCm=heightCm/2/tand(minScreenDeg/2);
                    o.viewingDistanceCm=maxViewingDistanceCm; %12.5*heightCm/20.6;
                    % o.conditionName='local';
                else
                    o.fixationCrossDeg=2;
                    o.clipToStimulusRect=true;
                    o.fixationCrossDrawnOnStimulus=false;
                    o.fixationCrossBlankedNearTarget=false;
                    o.viewingDistanceCm=25*heightCm/20.6;
                    % o.conditionName='gabor-RemoteFixation';
                end
                % WE NEED o.minScreenDeg
                o.minScreenDeg=2*(1+o.blankingRadiusReTargetHeight*o.targetHeightDeg);
                degMin=NominalAcuityDeg(o.eccentricityXYDeg);
                if deg<2*degMin
                    continue
                end
                % o.viewingDistanceCm=200; % FOR DEMO
                % o.fixationIsOffscreen=true; % FOR DEMO
                % EQUATE MARGINS
                r=Screen('Rect',0);
                aspectRatio=RectWidth(r)/RectHeight(r);
                o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
                o.alphabetPlacement='right'; % 'top' or 'right';
                o.contrast=-1;
                o.setNearPointEccentricityTo='target';
                ooo{end+1}=o;
            end
        end
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
        blankingDiameterDeg=2*o.blankingRadiusReTargetHeight*o.targetHeightDeg;
        o.minScreenDeg=blankingDiameterDeg/(1-2*o.minNotBlankedMarginReHeight);
        o.maxViewingDistanceCm=screenCm/2/tand(o.minScreenDeg/2);
        oo(oi)=o;
    end
    oo.viewingDistanceCm=deal(min(oo.maxViewingDistanceCm));
    ooo{i}=oo;
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
            if 1<ecc*(1-o.blankingRadiusReEccentricity) ...
                    || 1<ecc-o.blankingRadiusReTargetHeight*deg
                % Make sure that fixation mark has at least 1 deg radius.
                o.fixationCrossDeg=inf;
            else
                o.fixationCrossDeg=2;
            end
            r=Screen('Rect',0);
            
            %% EQUATE MARGINS
            aspectRatio=RectWidth(r)/RectHeight(r);
            o.nearPointXYInUnitSquare=[1-0.5/aspectRatio 0.5];
            o.alphabetPlacement='right'; % 'top' or 'right';
            o.contrast=-1;
            o.setNearPointEccentricityTo='target';
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
            maxNoiseSD=MaxNoiseSD(oo(oi).noiseType,SignalNegPos(oo(oi)));
            if ismember(oo(oi).targetKind,{'image'})
                maxNoiseSD=0.8*maxNoiseSD;
            end
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
            oo(oi).noiseSD=0;
        end
        ooNoise=oo;
        [ooNoise.noiseSD]=deal(maxNoiseSD);
        ooo{block}=[oo ooNoise];
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
    'targetHeightDeg'  'eccentricityXYDeg' 'viewingDistanceCm' 'fixationCrossBlankedNearTarget'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
ooo=RunExperiment(ooo);