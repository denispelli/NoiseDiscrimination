% runWords.m
% MATLAB script to run NoiseDiscrimination.m
% Copyright 2019 Denis G. Pelli, denis.pelli@nyu.edu
%
% IMPORTANT: the experimenter and observer names are incorporated into the
% file name of the data. Please enter both names consistently in every run.
%
% Please use binocular viewing, using both eyes, for all conditions.
%
% The script specifies a viewing distance of 40 cm. Please use a meter
% stick or tape measure to measure the viewing distance and ensure that the
% observer's eye is actually at the distance that the program thinks it is.
% please encourage the observer to maintain the same viewing distance for
% the whole experiment.
%
% denis.pelli@nyu.edu March 20, 2019
% 646-258-7524

% Word acuity at [0 ±10] deg ecc.
% Word efficiency at [0 0] deg ecc.

myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
addpath(fullfile(myPath,'words')); % Folder in same directory as this M file.

clear o oo ooo
ooo={};
o.readAlphabetFromDisk=false;
o.targetFont='Monaco';
o.alphabet='abcdefghijklmnopqrstuvwxyz'; % alphabet for o.words
o.alternatives=length(o.alphabet);
o.minimumTargetHeightChecks=8;
o.labelAnswers=false;
o.contrast=-1;
if 0
    o.targetKind='letter';
    o.targetFont='Sloan';
    o.alphabet='DHKNORSTVZ';
    o.alternatives=length(o.alphabet);
end
if 1
    % twoLetterWords; % Load o.words with list of words.
    fourLetterWords; % Load o.words with list of words.
    o.wordFilename='fourLetterWords';
    %     sevenLetterWords; % Load o.words with list of words.
    o.alternatives=length(o.words);
    o.targetKind='word';
end
o.experiment='Words';
o.recordGaze=false;
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=3;
o.contrast=-1;
o.noiseType='binary';
switch o.noiseType
    case 'gaussian'
        maxNoiseSD=0.16*2^0.5;
        p2=0.5;
    case 'binary'
        maxNoiseSD=0.16*2^2;
        p2=2;
end
o.blankingRadiusReTargetHeight= 0;
o.blankingRadiusReEccentricity= 0;
o.noiseCheckDeg=o.targetHeightDeg/40;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.viewingDistanceCm=40;
o.viewingDistanceCm=30;
o.noiseSD=0;
o.observer=''; % Test human.
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5];
o.observer=''; % Test human
o.fixationCrossBlankedNearTarget=true;
o.trialsPerBlock=40;
o.targetDurationSecs=0.2; % duration of display of target and flankers
o.practicePresentations=0;
o.repeatedTargets=0;
o.eyes='both';
o.noiseCheckDeg=o.targetHeightDeg/40;
o.setNearPointEccentricityTo='fixation';
o.noiseSD=0;
% USE THESE ONLY FOR DEBUGGING!
% o.useFractionOfScreenToDebug=0.5; % FOR DEBUGGING.
% o.skipScreenCalibration=true; % FOR DEBUGGING.

if 0
    o.conditionName='Peripheral acuity';
    % Block 1. Measure two thresholds, above and below fixation.
    o.thresholdParameter='size';
    o.eccentricityXYDeg=[0 10];
    o.fixationLineWeightDeg=0.4;
    o.fixationCrossDeg=3; % 0, 3, and inf are typical values.
    o.blankingRadiusReTargetHeight= 1.5;
    % Randomly interleave testing up and down.
    oo=[o o];
    oo(2).eccentricityXYDeg=-oo(2).eccentricityXYDeg;
    ooo={oo};
end
if 1
    o.conditionName='Efficiency';
    % Block 2. Measure three thresholds, one in zero and two in high noise.
    o.thresholdParameter='contrast';
    o.eccentricityXYDeg=[0 0];
    o.fixationLineWeightDeg=0.3;
    o.fixationCrossDeg=40; % 0, 3, and inf are typical values.
    o.noiseCheckDeg=o.targetHeightDeg/40;
    o.setNearPointEccentricityTo='fixation';
    o.noiseSD=0;
    oNoise=o;
    oNoise.noiseSD=maxNoiseSD;
    ooo{end+1}=[o oNoise oNoise];
end
if 1
    % Test ideal.
    % Block 3. Measure three thresholds, one in zero and two in high noise.
    ooo{end+1}=ooo{end};
    [ooo{end}.observer]=deal('ideal');
end

for i=1:length(ooo)
    [ooo{i}.block]=deal(i);
end

%% Print as a table. One row per threshold.
for i=1:length(ooo)
    if i==1
        oo=ooo{1};
    else
        try
        oo=[oo ooo{i}];
        catch e
            fprintf('Success with %d conditions in %d blocks. Failed on next block.\n',length(oo),max([oo.block]));
            throw(e)
        end
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'experiment' 'conditionName' 'targetFont' 'observer' 'noiseSD' 'targetHeightDeg' 'eccentricityXYDeg'})); 
% return

ooo=RunExperiment(ooo);