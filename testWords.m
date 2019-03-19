% runComplexEfficiency.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2018 Denis G. Pelli, denis.pelli@nyu.edu
%
% The script specifies "Darshan" as experimenter. You can change that in
% the script below if necessary. On the first block the program will ask
% the observer's name. On subsequent blocks it will remember the observer's
% name.
%
% Please use binocular viewing, using both eyes all the times.
%
% The script specifies a viewing distance of 40 cm. Please use a meter
% stick or tape measure to measure the viewing distance and ensure that the
% observer's eye is actually at the distance that the program thinks it is.
% please encourage the observer to maintain the same viewing distance for
% the whole experiment.
%
% denis.pelli@nyu.edu November 20, 2018
% 646-258-7524

% Crowding distance at ±10 deg ecc x 2 orientation.
% Acuity at ±10 deg ecc.

clear o oo ooo
ooo={};
o.recordGaze=false;
o.experiment='ComplexEfficiency';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=6;
o.contrast=-1;
o.noiseType='binary';
o.blankingRadiusReTargetHeight= 0;
o.blankingRadiusReEccentricity= 0;

if 1
    % Sloan
    o.targetFont='Calibri';
    o.minimumTargetHeightChecks=8;
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
    o.labelAnswers=false;
%     o.eccentricityXYDeg=[-10 0];
%     o.readAlphabetFromDisk=true;
%     ooo{end+1}=o;
%     o.eccentricityXYDeg=[10 0];
    o.readAlphabetFromDisk=false;
    o.targetKind='word';
    o.words={'ONE' 'TWO' 'THE'};
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'; % alphabet for o.words
    o.alternatives=length(o.words);
    ooo{end+1}=o;
end
if 0
    % Checkers alphabet
    o.targetFont='Checkers';
    o.minimumTargetHeightChecks=16;
    o.alphabet='abcdefghijklmnopqrstuvwxyz';
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end

% % Randomly interleave testing left and right.
% for i=1:length(ooo)
%     o=ooo{i};
%     o.block=i;
%     o.setNearPointEccentricityTo='fixation';
%     o.nearPointXYInUnitSquare=[0.5 0.5];
%     o.viewingDistanceCm=40;
%     o.eccentricityXYDeg=[-10 0];
%     oo=o;
%     o.eccentricityXYDeg=[10 0];
%     oo(2)=o;
%     ooo{i}=oo;
% end

% Test with zero and high noise.
for i=1:length(ooo)
    oo=ooo{i};
    for oi=1:length(oo)
        oo(oi).observer='';
        %   oo(oi).observer='ideal';
%         switch oo(oi).noiseType
%             case 'gaussian'
%                 maxNoiseSD=0.16*2^0.5;
%                 p2=0.5;
%             case 'binary'
%                 maxNoiseSD=0.16*2^2;
%                 p2=2;
%         end
%         oo(oi).noiseCheckDeg=oo(oi).targetHeightDeg/40;
        oo(oi).block=i;
        oo(oi).setNearPointEccentricityTo='fixation';
        oo(oi).nearPointXYInUnitSquare=[0.5 0.5];
        oo(oi).viewingDistanceCm=40;
        oo(oi).noiseSD=0;
    end
%     ooNoise=oo;
%     [ooNoise.noiseSD]=deal(maxNoiseSD);
%     ooo{i}=[oo ooNoise];
    ooo{i}=oo;
end

%% Print as a table. One row per threshold.
oo=[];
for i=1:length(ooo)
    [ooo{i}(:).block]=deal(i);
    oo=[oo ooo{i}];
end
t=struct2table(oo,'AsArray',true);
disp(t(:,{'block' 'experiment' 'targetFont' 'observer' 'noiseSD' 'targetHeightDeg' 'eccentricityXYDeg'})); % Print the conditions in the Command Window.
% return

%% Measure threshold, one block per iteration.
for i=1:length(ooo)
    oo=ooo{i};
    for oi=1:length(oo)
%         oo(oi).useFractionOfScreenToDebug=0.5; % USE ONLY FOR DEBUGGING.
%         oo(oi).rushToDebug=true; % USE ONLY FOR DEBUGGING.
        oo(oi).block=oi;
        oo(oi).blocksDesired=length(ooo);
        oo(oi).isFirstBlock=false;
        oo(oi).isLastBlock=false;
%         oo(oi).alternatives=length(oo(oi).alphabet);
        if i==1
            oo(oi).experimenter='Darshan';
        else
            oo(oi).experimenter=old.experimenter;
            oo(oi).observer=old.observer;
            oo(oi).viewingDistanceCm=old.viewingDistanceCm;
        end
        oo(oi).fixationCrossBlankedNearTarget=false;
        oo(oi).fixationLineWeightDeg=0.1;
        oo(oi).fixationCrossDeg=1; % 0, 3, and inf are typical values.
        oo(oi).trialsPerBlock=50;
        oo(oi).practicePresentations=0;
        oo(oi).targetDurationSecs=0.2; % duration of display of target and flankers
        oo(oi).repeatedTargets=0;
    end
    ooo{i}=oo;
    ooo{1}(1).isFirstBlock=true;
    ooo{end}(1).isLastBlock=true;
    oo=ooo{i};
    oo=NoiseDiscrimination2(oo);
    if ~any([oo.quitBlock])
        fprintf('Finished block %d.\n',i);
    end
    if any([oo.quitExperiment])
        break
    end
    old=oo(1); % Allow reuse of settings.
end
