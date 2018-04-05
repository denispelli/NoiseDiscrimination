% facesRun.m
% March, 2018
% Denis Pelli

%% GET READY
clear o oo
skipDataCollection=false; % Enable skipDataCollection to check plotting before we have data.
o.questPlusEnable=false;
if ~exist('rgb2lin','file')
    error('This MATLAB %s is too old. We need MATLAB 2017b or better to use the function "rgb2lin".',version('-release'));
end
if o.questPlusEnable && ~exist('qpInitialize','file')
    error('This script requires the QuestPlus package. Please get it from https://github.com/BrainardLab/mQUESTPlus.')
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % Folder in same directory as this M file.
cal=OurScreenCalibrations(0);
o.seed=[]; % Fresh.
% o.seed=uint32(1506476580); % Copy seed value here to reproduce an old table of conditions.
if isempty(o.seed)
    rng('shuffle'); % Use clock to seed the random number generator.
    generator=rng;
    o.seed=generator.Seed;
else
    rng(o.seed);
end
% o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.

%% CREATE LIST OF CONDITIONS TO BE TESTED
o.symmetricLuminanceRange=false; % Allow maximum brightness.
o.desiredLuminanceFactor=2; % Maximize brightness.
if false
    % Target letter
    o.targetKind='letter';
    o.font='Sloan';
    o.alphabet='DHKNORSVZ';
else
    % Target face
    o.signalImagesFolder='faces';
    o.signalImagesAreGammaCorrected=true;
    o.targetKind='image';
    o.alphabet='abcdefghijkl';
    o.convertSignalImageToGray=false;
    o.alphabetPlacement='right'; % 'top' or 'right';
end
o.targetMargin=0;
viewingDistanceCm=40;
o.contrast=1; % Select contrast polarity.
o.useDynamicNoiseMovie=false;
o.experiment='faces';
o.task='rate';
% o.task='identify';
o.eccentricityXYDeg=[0 0];
o.targetHeightDeg=15;
o.targetDurationSec=0.2;
o.trialsPerRun=20;
o.lapse=nan;
o.steepness=nan;
o.guess=nan;
o.observer='';
o.noiseSD=0;
o.thresholdParameter='contrast';
o.conditionName='threshold';
if false
    % Use QuestPlus to measure steepness.
    o.questPlusEnable=true;
    o.questPlusSteepnesses=1:0.1:5;
    o.questPlusGuessingRates=1/o.alternatives;
    o.questPlusLapseRates=0:0.01:0.05;
    o.questPlusLogContrasts=-2.5:0.05:0.5;
    o.questPlusPrint=true;
    o.questPlusPlot=true;
end
if all(o.eccentricityXYDeg==0)
    o.markTargetLocation=false;
else
    o.markTargetLocation=true;
end
o.blankingRadiusReTargetHeight=0;
o.targetMarkDeg=1;
o.fixationCrossDeg=3;
o.alternatives=length(o.alphabet);

%% SAVE CONDITIONS IN oo
oo={};
for beautyTask=Shuffle(0:1)
    if beautyTask
        o.task='rate';
    else
        o.task='identify';
    end
    for duration=Shuffle([0.2 1])
        o.targetDurationSec=duration;
        oo{end+1}=o;
    end
end
for i=1:length(oo)
    oo{i}.condition=i; % Number the conditions
end

%% PRINT THE LIST OF CONDITIONS (ONE PER ROW)
% All these vars must be defined in every condition.
vars={'seed' 'condition' 'task' 'targetDurationSec' 'targetHeightDeg' 'noiseSD'};
tt=table;
for i=1:length(oo)
    t=struct2table(oo{i},'AsArray',true);
    tt(i,:)=t(1,vars);
end
disp(tt) % Print list of conditions.

%% RUN THE CONDITIONS
if ~skipDataCollection
    % Typically, you'll select just a few of the conditions stored in oo
    % that you want to run now. Select them from the printout of "tt" in your
    % Command Window.
    % NOTE: Typically, conditions with the same conditionName are randonly shuffled
    % every time you run this, unless you set o.seed, above, to the 'seed'
    % used to generate the table you want to reproduce.
    clear oOut
    for oi=1:length(oo) % Edit this line to select which conditions to run now.
        o=oo{oi};
        o.runNumber=oi;
        o.runsDesired=length(oo);
        if exist('oOut','var')
            % Reuse answers from immediately preceding run.
            o.experimenter=oOut.experimenter;
            o.observer=oOut.observer;
        end
        oOut=NoiseDiscrimination(o); % RUN THE EXPERIMENT!
        oo{oi}=oOut; % Save results in oo.
        if oOut.quitSession
            break
        end
        fprintf('\n');
    end
    for i=1:length(oo)
        oo{i}.condition=i; % Number the conditions
    end
    
    %% PRINT SUMMARY OF RESULTS
    % All these vars must be defined in every condition.
    vars={'condition' 'observer' 'trials'  'task' 'targetDurationSec' 'targetHeightDeg' 'contrast' 'guess' 'lapse' 'steepness' 'seed' };
    tt=table;
    for i=1:length(oo)
        t=struct2table(oo{i},'AsArray',true);
        if ~all(ismember({'trials' 'contrast' 'transcript'},t.Properties.VariableNames)) || isempty(t.trials) || t.trials==0
            % Skip condition without data.
            continue
        end
        % Warn, skip the condition, and report which fields were missing.
        ok=ismember(vars,t.Properties.VariableNames);
        if ~all(ok)
            missing=join(vars(~ok),' ');
            warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
            continue
        end
        tt(i,:)=t(1,vars);
    end
    disp(tt) % Print summary.
    
    %% SAVE SUMMARY OF RESULTS
    o=oOut;
    o.summaryFilename=[o.dataFilename '.summary' ];
    writetable(tt,fullfile(o.dataFolder,[o.summaryFilename '.csv']));
    save(fullfile(o.dataFolder,[o.summaryFilename '.mat']),'tt','oo');
    fprintf('Summary saved in data folder as "%s" with extensions ".csv" and ".mat".\n',o.summaryFilename);
    
    %% PLOT IT
    tBeauty=t(streq(t.task,'rate'),{'targetDurationSec' 'contrast'});
    tBeauty=sortrows(tBeauty,'targetDurationSec');
    tId=t(streq(t.task,'identify'),{'targetDurationSec' 'contrast'});
    tId=sortrows(tId,'targetDurationSec');
    close all % Get rid of any existing figures.
    figure(1)
    loglog(tId.targetDurationSec,tId.contrast,'r-o',tBeauty.targetDurationSec,tBeauty.contrast,'k-x');
    ylabel('Threshold contrast');
    xlabel('Duration (s)');
    xlim([0.05 2]);
    ylim([0.01 10]);
    DecadesEqual(gca);
    o.plotFilename=[o.dataFilename '.plot'];
    title(o.plotFilename);
    legendNames={};
    if height(tId)>0
        legendNames{end+1}='Identification';
    end
    if height(tBeauty)>0
        legendNames{end+1}='Beauty';
    end
    legend(legendNames,'Location','north');
    legend boxoff
    graphFile=fullfile(o.dataFolder,[o.plotFilename '.eps']);
    saveas(gcf,graphFile,'epsc')
    fprintf('Plot saved as "%s".\n',graphFile);
end % if ~skipDataCollection && true
