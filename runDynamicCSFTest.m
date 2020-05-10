% runDynamicCSFTest.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019, 2020, Denis G. Pelli, denis.pelli@nyu.edu
% denis.pelli@nyu.edu
% March 14, 2020
% 646-258-7524
mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
addpath(fullfile(mainFolder,'utilities')); % Folder in same directory as this M file.
clear KbWait o oo
ooo={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Replicate Banks Bennet and Geisler 1987, w and w/o noise.
o.observer='';
% o.observer='ideal'; % Use this to test ideal observer.
% o.useFractionOfScreenToDebug=0.3; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember(o.observer,{'ideal'})
    o.trialsDesired=200;
else
    o.trialsDesired=50;
end
if IsWin
    o.useNative11Bit=false;
end

%% FLANKER
o.flankerSpacingDeg=0.2; % Used only for fixation check.
o.useFlankers=false;
o.flankerContrast=-1;

%% FIXATION AND TARGET MARKING
o.useFixationGrid=false;
o.useFixationDots=true;
o.fixationDotsWeightDeg=0.05;
o.fixationDotsNumber=100;
o.fixationDotsWithinRadiusDeg=4;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];

%% GEOMETRY
o.viewingDistanceCm=[];
o.minScreenDeg=[];

%% LUMINANCE
o.brightnessSetting=1.0; % As calibrated.
o.isTargetLocationMarked=false;
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
o.isLuminanceRangeSymmetric=true; % False for maximum brightness.
% o.desiredLuminanceFactor=[]; % 1.8 to maximize brightness.
% o.desiredLuminanceAtEye=300;

%% NOISE
% o.noiseType='ternary'; % More noise power than 'gaussian'.
o.noiseType='binary';

%% PRINTING
% o.printContrastBounds=true;
% o.printGrayLuminance=true;
% o.printImageStatistics=false;
% o.assessContrast=true;
% o.measureContrast=true;
% o.usePhotometer=true;

%% PROCEDURE
%o.group='A'; % All conditions in group differ solely in target.
o.askForPartingComments=false; % Disabled until it's fixed.
o.isGazeRecorded=false;
o.experiment='dynamicCSF';
o.thresholdParameter='contrast';
o.askExperimenterToSetDistance=true;
machine=IdentifyComputer;

%% RESPONSE
o.counterPlacement='bottomRight';
o.instructionPlacement='bottomRight'; % 'topLeft' 'bottomLeft' 'bottomRight'

%% TARGET
o.eccentricityXYDeg=[0 0];
o.contrast=-1;
o.isTargetFullResolution=true; % NEW December 6, 2019. denis.pelli@nyu.edu
o.clipToStimulusRect=false;
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=[];


%% REPLICATE Banks, Bennet, and Geisler 1987.
o.targetKind='gaborCosCos';
o.isNoiseDynamic=true;
o.moviePreAndPostSecs=[0.5 0.5];
o.noiseType='binary'; % Most noise power.
o.noiseRadiusDeg=inf;
o.noiseCheckFrames=2;
o.conditionName='gaborCosCos';
o.targetDurationSecs=0.15;
eccentricities=0;
spatialFrequencies=[5 10];
o.clipToStimulusRect=true;
o.desiredLuminanceFactor=[]; % 1.8 to maximize brightness.
o.desiredLuminanceAtEye=300;
if o.isNoiseDynamic
    % Use fastest random number generator.
    s=rng;
    rng(s.Seed,'simdTwister');
end

%% FIXATION
o.isFixationCheck=false; % True designates the condition as a fixation check.
o.clipToStimulusRect=false;
if true
    % SEPARATE FIXATION IN TIME
    o.fixationCrossBlankedNearTarget=false;
    o.fixationOffsetBeforeNoiseOnsetSecs=0;
    o.fixationOnsetAfterNoiseOffsetSecs=0;
    o.fixationCrossDrawnOnStimulus=false;
    o.blankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
    o.blankingRadiusReEccentricity=0.5;
else
    % SEPARATE FIXATION IN SPACE
    o.fixationOffsetBeforeNoiseOnsetSecs=0;
    o.fixationOnsetAfterNoiseOffsetSecs=0;
    o.fixationCrossDrawnOnStimulus=true;
    o.blankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
    o.blankingRadiusReEccentricity=0.5;
    o.fixationCrossDeg=inf;
    o.fixationCrossBlankedNearTarget=true;
    o.alphabetPlacement='bottom';
end

for targetKind={'gaborCosCos'} % 'letter' 'gabor'
    o.targetKind=targetKind{1};
    switch o.targetKind
        case 'gaborCosCos'
            % TO REPLICATE Banks, Bennet, and Geisler 1987.
            % Contrast thresholds were estimated with a 2-interval,
            % forced-choice procedure in which contrast was varied
            % according to a 2-down/1-up staircase rule. Threshold
            % criterion P=--2*(1-P)=2-2P; 3P=2; P=0.67
            o.targetGaborCycles=7.5;
            o.pThreshold=2/3;
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
            if true
                o.conditionName='gabor3';
                o.targetGaborSpaceConstantCycles=0.75*3; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                o.targetGaborCycles=3*3; % cycles of the sinewave in targetHeight
            else
                o.conditionName='gabor1';
                o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
                o.targetGaborCycles=3; % Cycles of the sinewave in targetHeight.
            end
            o.blankingRadiusReTargetHeight=2*o.targetGaborSpaceConstantCycles/o.targetGaborCycles; % Two space constants.
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
            o.blankingRadiusReTargetHeight=0.833; % One third letter width blank margin.
        otherwise
            error('Unknown o.targetKind ''%s''.',o.targetKind);
    end
    
    % for ecc=[0 2 8 32]
    for ecc=eccentricities
        for targetCyclesPerDeg=spatialFrequencies % Replicate Banks Bennet and Geisler.
            %        for targetCyclesPerDeg=[1 3 9]
            % for deg=[0.5 2 8 32]
            o.targetCyclesPerDeg=targetCyclesPerDeg;
            deg=o.targetGaborCycles/o.targetCyclesPerDeg;
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=deg;
            o.noiseRadiusDeg=3*o.targetHeightDeg;
            % if restrictNoise
            % 	o.noiseEnvelopeSpaceConstantDeg=deg;
            % else
            % 	o.noiseEnvelopeSpaceConstantDeg=inf;
            % end
            if 1>ecc*(1-o.blankingRadiusReEccentricity) ...
                    || 1>ecc-o.blankingRadiusReTargetHeight*deg
                % Make sure at least 1 deg of fixation mark can be seen.
            end
            % MAX viewingDistanceCm while showing 1 deg of screen (and
            % maybe) fixation beyond what is blanked for target.
            screenSizeCm=machine.mm{1}/10;
            minScreenDeg=2*(1+o.blankingRadiusReTargetHeight*o.targetHeightDeg);
            maxViewingDistanceCm=floor(screenSizeCm(2)/2/tand(minScreenDeg/2));
            o.viewingDistanceCm=maxViewingDistanceCm;
            % WE NEED o.minScreenDeg
            o.minScreenDeg=2*(1+o.blankingRadiusReTargetHeight*o.targetHeightDeg);
            % Threshold size.
            degMin=NominalAcuityDeg(o.eccentricityXYDeg);
            if deg<2*degMin
                % Skip condition if not comfortably within acuity limit.
                % However, the size limit is appropriate for letters. For
                % gabors, it should be an spatial frequency limit.
                continue
            end
            % o.viewingDistanceCm=200; % FOR DEMO
            % o.fixationIsOffscreen=true; % FOR DEMO
            o.screenSizeDeg(1:2)=2*[...
                atan2d(screenSizeCm(1)/2,o.viewingDistanceCm) ...
                atan2d(screenSizeCm(2)/2,o.viewingDistanceCm)];
            
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

if false
    % EXPAND EACH CONDITION INTO TWO, ADDING NEGATIVE ECCENTRICITY.
    if norm(o.eccentricityXYDeg)>0
        for block=1:length(ooo)
            oo=ooo{block};
            oo(2)=oo(1);
            oo(2).eccentricityXYDeg=-oo(1).eccentricityXYDeg;
            ooo{block}=oo;
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
            o.fixationCrossBlankedNearTarget=true;
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
    maxNoiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(1)));
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=length(oo):-1:1
            switch oo(oi).targetKind
                case 'image'
                    noiseSD=0.8*MaxNoiseSD('gaussian',SignalNegPos(oo(oi)));
                otherwise
                    noiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(oi)));
            end
            if oo(oi).targetHeightDeg>20
                % Avoid raising threshold for 32 deg gabor too high.
                noiseSD=MaxNoiseSD('gaussian',SignalNegPos(oo(oi)))/2;
            end
            oo(oi).noiseSD=noiseSD;
            oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/20;
            if oo(oi).targetHeightDeg<1
                oo(oi).noiseSD=MaxNoiseSD('ternary',SignalNegPos(oo(oi)));
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
        else
            ooo{block}=oo;
        end
    end
end

%% TWO LUMINANCES
for block=1:length(ooo)
    [ooo{block}.desiredLuminanceAtEye]=deal(300);
    ooo{end+1}=ooo{block};
    [ooo{end}.desiredLuminanceAtEye]=deal(30);
end

%% RECOMPUTE MAX NOISE SD, WITH LMinMeanMax 
cal=OurScreenCalibrations(0);
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        LMinMeanMax=[min(cal.old.L) oo(oi).desiredLuminanceAtEye max(cal.old.L)];
        if oo(oi).noiseSD>0
            old=oo(oi).noiseSD;
            oo(oi).noiseSD=MaxNoiseSD(oo(oi).noiseType,SignalNegPos(oo(oi)),LMinMeanMax);
            fprintf('%d:%d noiseSD old %.2f, new %.2f, LMinMeanMax [%.0f %.0f %.0f]\n',block,oi,old,oo(oi).noiseSD,LMinMeanMax);
        end
    end
    ooo{block}=oo;
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

%% NEED WIRELESS KEYBOARD? WILL USER ATTACH ONE?
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

%% IF NO WIRELESS KEYBOARD THEN LIMIT VIEWING DISTANCE to 60 CM, MAX.
if ~hasWirelessKeyboard
    fprintf('<strong>No wireless keyboard, so limiting viewing distance to at most 60 cm.</strong>\n');
    for block=1:length(ooo)
        oo=ooo{block};
        for oi=1:length(oo)
            oo(oi).viewingDistanceCm=min([60 oo(oi).viewingDistanceCm]);
        end
        ooo{block}=oo;
    end
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
% Print the conditions in the Command Window.
disp(t(:,{'experiment' 'block' 'condition' 'conditionName' 'observer'  'endsAtMin' 'viewingDistanceCm' ...
    'targetHeightDeg' 'trialsDesired' 'noiseRadiusDeg' 'screenSizeDeg' 'targetCyclesPerDeg' 'noiseSD'  ...
    'desiredLuminanceAtEye' 'noiseCheckDeg' 'targetKind' 'noiseType' 'thresholdParameter'...
    'contrast'  ...
    'eccentricityXYDeg'  ...
    'fixationCrossBlankedNearTarget'}));
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