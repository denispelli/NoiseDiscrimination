%% Analyze the data collected by runNoiseTest.
% denis.pelli@nyu.edu
% February 20, 2020

experiment='NoiseTest';
% global printConditions makePlotLinear showLegendBox
% showLegendBox=true;
% printConditions=false;
printFilenames=true;
% plotGraphs=true;
% makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
close all
% clear Plot % Clear the persistent variables in the subroutine below.

%% READ ALL DATA OF experiment FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'experiment' 'dataFilename' ...
    'experimenter' 'observer' 'trials' ...
    'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
    'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
    'targetCheckDeg' 'fullResolutionTarget' ...
    'targetFont' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'contrast' 'E' 'E1' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
    'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
    'pixPerCm'  'nearPointXYPix' 'NUnits' 'beginningTime' 'thresholdParameter'...
    'questMean' 'partingComments' 'blockSecs' 'blockSecsPerTrial'...
    'fullResolutionTarget'};
oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.
fprintf('%s %d thresholds.\n',experiment,length(oo));

%% PRINT COMMENTS
if isfield(oo,'partingComments')
    comments={oo.partingComments};
    ok=true(size(comments));
    for i=1:length(comments)
        if isempty(comments{i}) || isempty(comments{i}{1})
            ok(i)=false;
        end
    end
    comments=comments(ok);
    for i=1:length(comments)
        fprintf('%s\n',comments{i}{1});
    end
end

% Round each target size to a power of 2.
for oi=1:numel(oo)
    oo(oi).targetHeightDeg = 2.^round(log2([oo(oi).targetHeightDeg]));
end

% Average all thresholds that match in:
% noiseType, conditionName, observer, targetHeight, and eccentricityXY.
conditionNames=unique({oo.conditionName});
observers=unique({oo.observer});
targetHeightDegs=unique([oo.targetHeightDeg]);
eccXsfull=arrayfun(@(x) x.eccentricityXYDeg(1),oo);
eccXs=unique(eccXsfull);
noiseTypes=unique({oo.noiseType});
aa=[];
for conditionName=conditionNames
    for observer=observers
        for targetHeightDeg=targetHeightDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    match=ismember({oo.conditionName},conditionName) ...
                        & ismember({oo.observer},observer) ...
                        & ismember([oo.targetHeightDeg],targetHeightDeg) ...
                        & ismember(eccXsfull,eccX) ...
                        & ismember({oo.noiseType},noiseType);
                    match=match & ismember({oo.thresholdParameter},{'contrast'});
                    if sum(match)>0
                        E=[oo(match).E];
                        N=[oo(match).N];
                        [Neq,E0,deltaEOverN]=EstimateNeq(E,N);
                        aa(end+1).conditionName=conditionName{1};
                        aa(end).observer=observer{1};
                        aa(end).E=E;
                        aa(end).N=N;
                        aa(end).E0=E0;
                        aa(end).Neq=Neq;
                        aa(end).deltaEOverN=deltaEOverN;
                        oi=find(match,1);
                        aa(end).thresholdParameter=oo(oi).thresholdParameter;
                        aa(end).eccentricityDeg=eccX;
                        aa(end).targetHeightDeg=targetHeightDeg;
                        aa(end).contrast=[oo(match).contrast];
                        aa(end).noiseSD=[oo(match).noiseSD];
                        aa(end).noiseType=noiseType{1};
                    end
                end
            end
        end
    end
end

for conditionName=conditionNames
    for observer=observers
        for targetHeightDeg=targetHeightDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    match=ismember({aa.thresholdParameter},{'contrast'})...
                        & ismember({aa.conditionName},conditionName)...
                        & ismember([aa.targetHeightDeg],targetHeightDeg)...
                        & ismember([aa.eccentricityDeg], eccX) ...
                        & ismember({aa.noiseType},noiseType);
                    idealMatch=match & ismember({aa.observer},{'ideal'});
                    match = match & ismember({aa.observer},observer);
                    if sum(match)>0 && sum(idealMatch)>0
                        assert(sum(match)==1 & sum(idealMatch)==1);
                        aa(match).efficiency=(aa(idealMatch).E/aa(idealMatch).N)/aa(match).deltaEOverN;
                    end
                end
            end
        end
    end
end
for i=1:length(aa)
    % Convert noiseType (a name) to noiseIndex (an integer).
    aa(i).noiseIndex=find(ismember(noiseTypes,aa(i).noiseType));
end
% human=~ismember({aa.observer},'ideal');

% Normalize the measured threshold contrast by the actual (not reported)
% noiseSD.
% switch noiseType % Fill noiseList with desired kind of noise.
%     case 'gaussian'
%         temp=randn([1 20000]);
%         ok=-2<=temp & temp<=2;
%         noiseList=temp(ok);
%         clear temp;
%     case 'uniform'
%         noiseList=-1:1/1024:1;
%     case 'binary'
%         noiseList=[-1 1];
%     case 'ternary'
%         noiseList=[-1 0 1];
%     otherwise
%         error('%d: Unknown noiseType "%s"',oi,oo(oi).noiseType);
% end
% oldSD=std(noiseList);
% noiseListSD=std(PsychRandSample(noiseList,[1000000 1]));
% for iNoise=1:length(noiseTypes)
%     stdReported

t=struct2table(aa);
t=sortrows(t,'conditionName');
t=sortrows(t,'observer');
disp(t(:,{'conditionName' 'targetHeightDeg' 'contrast' 'observer' 'noiseType' 'noiseIndex' 'noiseSD'}));
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
writetable(t,fullfile(dataFolder,[experiment '.xls']));
jsonwrite(fullfile(dataFolder,[experiment '.json']), t);

a=table2struct(t);
% figure(1);
figureHandle=figure('Name',experiment,'NumberTitle','off','pos',[10 10 500 800]);
% orient 'landscape'; % For printing.
degStyle={'r' 'g' 'b'};
assert(length(degStyle)>=length(targetHeightDegs));
observerStyle={'-*' '--o'};
assert(length(observerStyle)>=length(observers));

for conditionName=conditionNames
    switch conditionName{1}
        case 'letter'
            subplot(2,1,1);
        case 'gabor'
            subplot(2,1,2);
    end
    for iObserver=1:length(observers)
        for iDeg=1:length(targetHeightDegs)
            for eccX=eccXs
                match=ismember({a.thresholdParameter},{'contrast'})...
                    & ismember({a.conditionName},conditionName)...
                    & ismember([a.targetHeightDeg],targetHeightDegs(iDeg))...
                    & ismember([a.eccentricityDeg],eccX);
                %         idealMatch=match & ismember({a.observer},{'ideal'});
                match = match & ismember({a.observer},observers(iObserver));
                semilogy([a(match).noiseIndex],-[a(match).contrast],...
                    [degStyle{iDeg} observerStyle{iObserver}],...
                    'DisplayName',sprintf('%2.0f deg %s',...
                    targetHeightDegs(iDeg),observers{iObserver}));
%                 conditionName, {a(match).conditionName}, observers{iObserver}, {a(match).observer}
%                 targetHeightDegs(iDeg), [a(match). targetHeightDeg]
%                 -[a(match).contrast]
                hold on
            end
        end
    end
    xlim([-1.5 4.5]);
    ax=gca;
    ax.XTick=1:4;
    ax.XTickLabels={'Binary' 'Gaussian' 'Ternary' 'Uniform'};
    lgd=legend('Location','northwest','Box','off');
    title(lgd,'Size and Observer');
    lgd.FontName='Monaco';
    name=conditionName{1};
    title([upper(name(1)) name(2:end)],'fontsize',18)
    xlabel('Noise type','fontsize',18);
    ylabel('Contrast threshold','fontsize',18);
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    % lgd.FontSize=10;
    if true
        % Scale log unit to be 12 cm vertically.
        ax=gca;
        %ax.YLim=[0.005 0.16];
        ax.Units='centimeters';
        drawnow; % Needed for valid Position reading.
        ax.Position(4)=8*diff(log10(ax.YLim));
    end
    hold off
end

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.eps']);
saveas(gcf,graphFile,'epsc');
