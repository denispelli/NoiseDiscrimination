% runComplexEfficiency.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2018 Denis G. Pelli, denis.pelli@nyu.edu
%
% The script specifies "Darshan" as experimenter. You can change that in
% the script below if necessary. On the first block the program will ask
% the observer's name. On subsequent blocks it will remember the observer's
% name.
%
% Please use binocular viewing, using both eyes at all times.
%
% The script specifies a viewing distance of 40 cm. Please use a meter
% stick or tape measure to measure the viewing distance and ensure that the
% observer's eye is actually at the distance that the program thinks it is.
% Please encourage the observer to maintain the same viewing distance for
% the whole experiment.
%
% denis.pelli@nyu.edu November 20, 2018
% 646-258-7524

% Crowding distance at ±10 deg ecc x 2 orientation.
% Acuity at ±10 deg ecc.

clear o oo ooo
% 


% o.useFractionOfScreenToDebug=0.5; % USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.

ooo={};
o.targetFont='Sloan';
% o.minimumTargetHeightChecks=8;
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
% o.labelAnswers=false;
% o.readAlphabetFromDisk=true;
% o.recordGaze=false;

o.experiment='GaborEfficiency';
o.targetHeightDeg=6;
o.contrast=1;
o.noiseType='gaussian';
o.blankingRadiusReTargetHeight=0;
o.blankingRadiusReEccentricity=0;
o.trials=50; 
o.targetGaborOrientationsDeg=[0 45 90 135]; % Orientations relative to vertical.
o.responseLabels='1234';
o.alternatives=length(o.targetGaborOrientationsDeg);

if 1
    % Gabor
    o.targetKind='gabor'; % one cycle within targetSize
    o.eccentricityXYDeg=[5 0];
    o.viewingDistanceCm=40;
    o.targetCyclesPerDeg=nan;
    o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
    o.conditionName='big';
    o.targetHeightDeg=6;
    o.targetGaborSpaceConstantCycles=0.75*3; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
    o.targetGaborCycles=3*3; % cycles of the sinewave in targetHeight
    ooo{end+1}=o;
    o.conditionName='small';
    o.targetHeightDeg=2;
    o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
    o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
    ooo{end+1}=o;
end
o.targetKind='letter'; % one cycle within targetSize
o.targetHeightDeg=6;

% Randomly interleave testing left and right.
for block=1:length(ooo)
    o=ooo{block};
    o.setNearPointEccentricityTo='fixation';
    o.nearPointXYInUnitSquare=[0.5 0.5];
    oo=o;
    o.eccentricityXYDeg=-o.eccentricityXYDeg;
    oo(2)=o;
    ooo{block}=oo;
end

% Test with zero and high noise.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).observer='';
        %   oo(oi).observer='ideal';
        switch oo(oi).noiseType
            case 'gaussian'
                maxNoiseSD=0.16*2^0.5;
                p2=0.5;
            case 'binary'
                maxNoiseSD=0.16*2^2;
                p2=2;
        end
        oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
        oo(oi).block=block;
        oo(oi).setNearPointEccentricityTo='fixation';
        oo(oi).nearPointXYInUnitSquare=[0.5 0.5];
        oo(oi).viewingDistanceCm=40;
        oo(oi).noiseSD=0;
    end
    ooNoise=oo;
    [ooNoise.noiseSD]=deal(maxNoiseSD);
    ooo{block}=[oo ooNoise];
end

% Retest with ideal.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).observer='ideal';
    end
    ooo{end+1}=oo;
end

%% Print as a table. One row per threshold.
oo=[];
for block=1:length(ooo)
    [ooo{block}(:).block]=deal(block);
    oo=[oo ooo{block}];
end
t=struct2table(oo);
disp(t(:,{'block' 'experiment' 'targetKind' 'targetFont' 'observer' ...
    'noiseSD' 'targetHeightDeg' 'eccentricityXYDeg'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).block=block;
        oo(oi).blocksDesired=length(ooo);
        oo(oi).isFirstBlock= block==1;
        oo(oi).isLastBlock= block==length(ooo);
        if isempty(oo(oi).alternatives)
            oo(oi).alternatives=length(oo(oi).alphabet);
        end
        if block==1
            oo(oi).experimenter='';
        else
            oo(oi).experimenter=old.experimenter;
            if isempty(oo(oi).observer)
                oo(oi).observer=old.observer;
            end
        end
        oo(oi).fixationCrossBlankedNearTarget=false;
        oo(oi).fixationLineWeightDeg=0.1;
        oo(oi).fixationCrossDeg=1; % 0, 3, and inf are typical values.
        oo(oi).trialsDesired=50;
        oo(oi).practicePresentations=0;
        oo(oi).targetDurationSecs=0.2; % duration of display of target and flankers
        oo(oi).repeatedTargets=0;
    end
    ooo{block}=oo;
    oo=ooo{block};
    oo=NoiseDiscrimination(oo);
    ooo{block}=oo;
    if any([oo.quitExperiment])
        break
    end
    old=oo(1); % Allow reuse of settings.
end
