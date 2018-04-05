% flankersRun.m
% Show target with two flankers. Report all three. Measure "threshold"
% contrast of flankers to bring target identification to 75% correct.
% P=0.75, assuming 9 alternatives
% luminance 250 cd/m2
% binocular, 15 deg up.
% April 4, 2018
% Denis Pelli for project in collaboration with Katerina Malakhova.

%% GET READY
clear o oo
skipDataCollection=false; % Enable skipDataCollection to check plotting before we have data.
o.questPlusEnable=false;
if verLessThan('matlab','R2013b')
    error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
if o.questPlusEnable && ~exist('qpInitialize','file')
    error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
if false && ~streq(cal.macModelName,'MacBookPro14,3')
    % For debugging, if this isn't a 15" MacBook Pro 2017, pretend it is.
    cal.screenWidthMm=330; % 13"
    cal.screenHeightMm=206; % 8.1"
    warning('PRETENDING THIS IS A 15" MacBook Pro 2017');
end
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
o.seed=[]; % Fresh.
% o.seed=uint32(1506476580); % Copy seed value here to reproduce an old table of conditions.

%% CREATE LIST OF CONDITIONS TO BE TESTED
o.symmetricLuminanceRange=true;
o.useDynamicNoiseMovie=true;
o.alphabetPlacement='right'; % 'top' or 'right';
o.annularNoiseSD=0;
o.noiseRadiusDeg=inf;
o.annularNoiseBigRadiusDeg=inf;
o.annularNoiseSmallRadiusDeg=0;
% if false
%     o.constantStimuli=[-0.06];
%     o.trialsPerRun=50*length(o.constantStimuli);
%     o.useMethodOfConstantStimuli=true;
% else
%     o.trialsPerRun=300;
%     o.constantStimuli=[];
%     o.useMethodOfConstantStimuli=false;
% end
o.experiment='flankers';
o.targetHeightDeg=2;
o.targetDurationSec=0.2;
o.eyes='both';
o.contrast=-0.16;
o.flankerContrast=-0.6; % Negative for dark letters.
o.flankerArrangement='tangential'; % 'radial' 'radialAndTangential'
o.viewingDistanceCm=40;
o.flankerSpacingDeg=2;
o.eccentricityXYDeg=[0,15];
o.nearPointXYInUnitSquare=[0.5 0.9];
o.annularNoiseEnvelopeRadiusDeg=o.flankerSpacingDeg;
o.noiseEnvelopeSpaceConstantDeg=o.flankerSpacingDeg/2;
o.fixationCrossWeightDeg=0.09;
o.blankingRadiusReEccentricity=0; % No blanking.
oo={};
if true
    o.trialsPerRun=50;
    o.conditionName='Target threshold contrast, no flankers';
    o.useFlankers=false;
    o.thresholdParameter='contrast';
    o.task='identify';
    o.nearPointXYInUnitSquare=[0.5 0.9];
    o.eccentricityXYDeg=[0,ecc];
    o.noiseCheckDeg=o.targetHeightDeg/20;
    o.noiseSD=noiseSD;
    oo{end+1}=o;
end
o.conditionName='Flanker threshold contrast for crowding of target';
o.trialsPerRun=300;
o.useFlankers=true;
o.thresholdParameter='flankerContrast';
o.task='identifyAll';
if true
    % Target letter
    o.targetKind='letter';
    o.font='Sloan';
    o.alphabet='DHKNORSVZ';
else
    % Target gabor
    o.targetKind='gabor';
    o.targetGaborOrientationsDeg=[0 45 90 135];
    o.targetGaborNames='1234';
    o.alphabet=o.targetGaborNames;
end
o.alternatives=length(o.alphabet);
o.blankingRadiusReTargetHeight=0;
o.moviePreSec=0.2;
o.moviePostSec=0.2;
o.targetMarkDeg=1;
o.fixationCrossDeg=3;
if 0
    % Use QuestPlus to measure steepness.
    o.questPlusEnable=true;
    o.questPlusSteepnesses=1:0.1:5;
    o.questPlusGuessingRates=1/o.alternatives;
    o.questPlusLapseRates=0:0.01:0.05;
    o.questPlusLogContrasts=-2.5:0.05:0.5;
    o.questPlusPrint=true;
    o.questPlusPlot=true;
end

% for noiseSD=Shuffle([0 0.16])
for noiseSD=[0]
    o.noiseCheckDeg=o.targetHeightDeg/20;
    o.noiseSD=noiseSD;
    oo{end+1}=o;
end
for i=1:length(oo)
    oo{i}.condition=i;
end

%% PRINT THE LIST OF CONDITIONS (ONE PER ROW)
% All these vars must be defined in every condition.
vars={'condition' 'conditionName' 'trialsPerRun' 'noiseSD' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'thresholdParameter'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print the oo list of conditions.

%% RUN THE CONDITIONS
if ~skipDataCollection
    % Typically, you'll select just a few of the conditions stored in oo
    % that you want to run now. Select them from the printout of "tt" in your
    % Command Window.
    clear oOut
    for oi=1:length(oo) % Edit this line to select which conditions to run now.
        o=oo{oi};
        o.runNumber=oi;
        o.runsDesired=length(oo);
        if exist('oOut','var')
            % Reuse answers from immediately preceding run.
            o.experimenter=oOut.experimenter;
            o.observer=oOut.observer;
            % Setting o.useFilter false forces o.filterTransmission=1.
            o.filterTransmission=oOut.filterTransmission;
        end
        if all(o.eccentricityXYDeg==0)
            o.markTargetLocation=false;
        else
            o.markTargetLocation=true;
        end
        oOut=NoiseDiscrimination(o); % RUN THE EXPERIMENT!
        oo{oi}=oOut; % Save results in oo.
        if isfield(oOut,'psych')
            fprintf(['<strong>%s: noiseSD %.2f, log N %.2f, flankerSpacingDeg %.1f, '...
                'target contrast %.3f, threshold flankerContrast %.3f</strong>\n'],...
                oOut.conditionName,oOut.noiseSD,log10(oOut.N),oOut.flankerSpacingDeg,...
                oOut.contrast,oOut.flankerContrast);
        end
        if oOut.quitSession
            break
        end
    end
    fprintf('\n');
end % if ~skipDataCollection

%% PRINT THE LIST OF CONDITIONS (ONE PER ROW)
% All these vars must be defined in every condition.
vars={'condition' 'experiment' 'noiseSD' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'thresholdParameter'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% PRINT THE RESULTS
% We skip any condition without all these fields.
vars={'condition' 'observer' 'trials' 'trialsSkipped' 'noiseSD' 'N' 'flankerSpacingDeg' 'eccentricityXYDeg' 'contrast' 'flankerContrast'};
tt=table;
for oi=1:length(oo)
    t=struct2table(oo{oi},'AsArray',true);
    if ~all(ismember({'trials' 'transcript'},t.Properties.VariableNames)) || isempty(t.trials) || t.trials==0
        % Skip condition without data.
        continue
    end
    if false
        % Create empty cell for every missing field in the condition.
        missing=~ismember(vars,t.Properties.VariableNames);
        missingNames=vars(missing);
        for i=1:length(missingNames)
            name=missingNames{i};
            t.(name)=[];
        end
    else
        % Warn, skip the condition, and report which fields were missing.
        ok=ismember(vars,t.Properties.VariableNames);
        if ~all(ok)
            missing=join(vars(~ok),' ');
            warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
            continue
        end
    end
    tt(end+1,:)=t(1,vars);
end
disp(tt) % Print the list of conditions, with results.

close all % Get rid of any existing figures.
for i=1:height(tt)
    %% PLOT IT
    o=oo{tt.condition(i)};
    disp(tt(i,:))
    
    % FIT PSYCHOMETRIC FUNCTION
    clear QUESTPlusFit % Clear the persistent variables.
    o.alternatives=length(o.alphabet);
    o.questPlusLapseRates=0:0.01:0.05;
    o.questPlusGuessingRates=0:0.03:0.3;
    o.questPlusSteepnesses=[1:0.5:5 6:10];
    oOut=QUESTPlusFit(o);
    o.plotFilename=[o.dataFilename '.plot'];
    file=fullfile(o.dataFolder,[o.plotFilename '.eps']);
    saveas(gcf,file,'epsc')
    fprintf('Plot saved in data folder as "%s".\n',[o.plotFilename '.eps']);
    
    %% PRELIMINARY ANALYSIS
    n=length(o.transcript.response);
    left=zeros([1,n]);
    middle=zeros([1,n]);
    right=zeros([1,n]);
    for i=1:n
        left(i)=o.transcript.flankers{i}(1)==o.transcript.flankerResponse{i}(1);
        middle(i)=o.transcript.target(i)==o.transcript.response(i);
        right(i)=o.transcript.flankers{i}(2)==o.transcript.flankerResponse{i}(2);
    end
    outer=left | right;
    fprintf('Run %d, %d trials. Proportion correct, by position: %.2f %.2f %.2f\n',o.condition,n,sum(left)/n,sum(middle)/n,sum(right)/n);
    a=[left' middle' right' outer'];
    [r,p] = corrcoef(a);
    disp('Correlation matrix, left, middle, right, outer:')
    disp(r)
    for i=1:n
        left(i)=ismember(o.transcript.flankers{i}(1),[o.transcript.flankerResponse{i} o.transcript.response(i)]);
        middle(i)=ismember(o.transcript.target(i),[o.transcript.flankerResponse{i} o.transcript.response(i)]);
        right(i)=ismember(o.transcript.flankers{i}(2),[o.transcript.flankerResponse{i} o.transcript.response(i)]);
    end
    fprintf('Run %d, %d trials. Proportion correct, ignoring position errors: %.2f %.2f %.2f\n',o.condition,n,sum(left)/n,sum(middle)/n,sum(right)/n);
end


