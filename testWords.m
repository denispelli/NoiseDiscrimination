% test Words.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019 Denis G. Pelli, denis.pelli@nyu.edu
%
% The script specifies "Darshan" as experimenter. You can change that in
% the script below if necessary. On the first block the program will ask
% the observer's name. On subsequent blocks it will remember the observer's
% name.
%
% Please use binocular viewing, using both eyes, for all conditions.
%
% The script specifies a viewing distance of 40 cm. Please use a meter
% stick or tape measure to measure the viewing distance and ensure that the
% observer's eye is actually at the distance that the program thinks it is.
% please encourage the observer to maintain the same viewing distance for
% the whole experiment.
%
% denis.pelli@nyu.edu March 18, 2019
% 646-258-7524

% Acuity at ±10 deg ecc.
% Efficiency at 0 deg ecc.
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.

clear o oo ooo
ooo={};
o.words={'abed' 'able' 'ably' 'aces' 'ache' 'acid' 'acre' 'acts' 'adds' ...
    'adze' 'aeon' 'afar' 'aged' 'ages' 'agog' 'ague' 'ahem' 'aide' 'aids' ...
    'aims' 'airs' 'airy' 'ajar' 'akin' 'alas' 'alee' 'alit' 'ally' 'also' ...
    'alto' 'alum' 'amah' 'amen' 'amid' 'ammo' 'amps' 'anal' 'anew' 'anon' ...
    'ante' 'ants' 'anus' 'apes' 'apex' 'arch' 'arcs' 'area' 'arid' 'arms' ...
    'army' 'arts' 'arty' 'arum' 'asks' 'asst' 'atom' 'atop' 'aunt' 'aura' ...
    'auto' 'aver' 'avid' 'away' 'awed' 'axes' 'axis' 'axle' 'ayah' 'ayes' ...
    'babe' 'baby' 'back' 'bade' 'bags' 'bail' 'bait' 'bake' 'bald' 'bale' ...
    'zoom' }; 
% 1817 words, after removing contractions, proper nouns, and three obscenities.
o.experiment='Words';
o.recordGaze=false;
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=3;
o.contrast=-1;
o.noiseType='binary';
o.blankingRadiusReTargetHeight= 0;
o.blankingRadiusReEccentricity= 0;
o.noiseCheckDeg=o.targetHeightDeg/40;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.viewingDistanceCm=40;
o.noiseSD=0;
o.observer=''; % Test human
o.fixationLineWeightDeg=0.2;
o.fixationCrossDeg=3; % 0, 3, and inf are typical values.

if 1
    % Calibri
    o.conditionName='Peripheral acuity';
    o.thresholdParameter='size';
    o.eccentricityXYDeg=[0 10];
    o.targetFont='Monaco';
    o.minimumTargetHeightChecks=8;
    %     o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    %     o.borderLetter='X';
    o.labelAnswers=false;
    o.targetKind='word';
    o.alphabet='abcdefghijklmnopqrstuvwxyz'; % alphabet for o.words
    o.alternatives=length(o.words);
    o.readAlphabetFromDisk=false;
    ooo{end+1}=o;
end

% Randomly interleave testing up and down.
for i=1:length(ooo)
    o=ooo{i};
    o.setNearPointEccentricityTo='fixation';
    o.nearPointXYInUnitSquare=[0.5 0.5];
    o.viewingDistanceCm=40;
    oo=[o o];
    oo(2).eccentricityXYDeg=-oo(2).eccentricityXYDeg;
    ooo{i}=oo;
end

if 1
    % Test once with zero and twice with high noise, interleaved.
    o=ooo{1}(1);
    o.conditionName='Efficiency';
    o.thresholdParameter='contrast';
    o.eccentricityXYDeg=[0 0];
    o.observer=''; % Test human
    o.blankingRadiusReTargetHeight= 1.5;
    o.fixationLineWeightDeg=0.2;
    o.fixationCrossDeg=40; % 0, 3, and inf are typical values.
    switch o.noiseType
        case 'gaussian'
            maxNoiseSD=0.16*2^0.5;
            p2=0.5;
        case 'binary'
            maxNoiseSD=0.16*2^2;
            p2=2;
    end
    o.noiseCheckDeg=o.targetHeightDeg/40;
    o.setNearPointEccentricityTo='fixation';
    o.nearPointXYInUnitSquare=[0.5 0.5];
    o.viewingDistanceCm=40;
    o.noiseSD=0;
    oNoise=o;
    oNoise.noiseSD=maxNoiseSD;
    ooo{end+1}=[o oNoise oNoise];
end
if 1
    % Test ideal too.
    oo=ooo{end};
    [oo.observer]=deal('ideal');
    ooo{end+1}=oo;
end

for i=1:length(ooo)
    oo=ooo{i};
    for oi=1:length(oo)
        oo(oi).fixationCrossBlankedNearTarget=true;
        oo(oi).trialsDesired=40;
        oo(oi).practicePresentations=0;
        oo(oi).targetDurationSecs=0.2; % duration of display of target and flankers
        oo(oi).repeatedTargets=0;
        oo(oi).eyes='both';
        % USE THESE ONLY FOR DEBUGGING! %
        oo(oi).useFractionOfScreenToDebug=0.5; % USE ONLY FOR DEBUGGING.
%         oo(oi).skipScreenCalibration=true; % USE ONLY FOR DEBUGGING.
    end
    ooo{i}=oo;
end

% ooo={ooo{3}};

%% Print as a table. One row per threshold.
for i=1:length(ooo)
    [ooo{i}.block]=deal(i);
    if i==1
        oo=ooo{1};
    else
        oo=[oo ooo{i}];
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'experiment' 'conditionName' 'targetFont' 'observer' 'noiseSD' 'targetHeightDeg' 'eccentricityXYDeg'})); 
% return

ooo=RunExperiment(ooo);