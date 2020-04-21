%% Analyze the data collected by runCSFTest.
% denis.pelli@nyu.edu
% March 14, 2020

experiment='CSFTest';
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

%% READ ALL DATA OF experiment FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'experiment' 'dataFilename' ...
    'experimenter' 'observer' 'trials' ...
    'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
    'targetCheckDeg' 'fullResolutionTarget' ...
    'targetFont' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'contrast' 'E' 'E1' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
    'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
    'pixPerCm'  'nearPointXYPix' 'NUnits' 'beginningTime' 'thresholdParameter'...
    'questMean' 'partingComments' 'blockSecs' 'blockSecsPerTrial'...
    'fullResolutionTarget'...
    'trial0Secs' 'trial1BeginComputeMovieSecs' ...
    'trial2BeginComputeCLUTSecs' 'trial3BeginComputeTextureSecs' ...
    'trial4BeginMovieSecs' 'trial5EndMovieSecs' 'trial6BeginFixationSecs'...
    'trial7ShowInstructionsSecs' 'trial8GotResponseSecs' ...
    };
oo=ReadExperimentData({experiment},vars); % Adds date and missingFields.
fprintf('%s %d thresholds.\n',experiment,length(oo));

if false
    experiment2='NoiseTest';
    oo2=ReadExperimentData(experiment2,vars); % Adds date and missingFields.
    fprintf('%s %d thresholds.\n',experiment2,length(oo2));
    for oi=1:length(oo2)
        oo2(oi).conditionName=strrep(oo2(oi).conditionName,'small','gabor');
    end
    oo=[oo oo2];
end

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

% For enhanced matching, round each targetCyclesPerDeg greater than 2 to an
% integer, less than 2 to one decimal.
if true
    for oi=1:length(oo)
        if oo(oi).targetCyclesPerDeg>2
            oo(oi).targetCyclesPerDeg=round(oo(oi).targetCyclesPerDeg);
        else
            oo(oi).targetCyclesPerDeg=round(10*oo(oi).targetCyclesPerDeg)/10;
        end
    end
end

% COMPUTE EFFICIENCY
% Select thresholdParameter='contrast', for each conditionName,
% For each observer, including ideal, use all (E,N) data to estimate deltaNOverE and Neq.
% Compute efficiency by comparing deltaNOverE of each to that of the ideal.

% Each element of aa is the average all thresholds in oo that match in:
% noiseType, conditionName, observer, targetHeight, and eccentricityXY.
% But ignore noiseType of thresholds for which noiseSD==0.
conditionNames=unique({oo.conditionName});
isIdeal=ismember(conditionNames,{'ideal'});
if any(isIdeal)
    % If present, put ideal observer first.
    conditionNames=[condditionNames(isIdeal) conditionNames(~isIdeal)];
end
observers=unique({oo.observer});
% If some names differ solely in case, then collapse all names to
% lowercase.
isObserversLower=length(unique(lower(observers)))<length(observers);
if isObserversLower
    observers=unique(lower(observers));
end
targetCyclesPerDegs=unique([oo.targetCyclesPerDeg]);
eccXsfull=arrayfun(@(x) x.eccentricityXYDeg(1),oo);
eccXs=unique(eccXsfull);
noiseTypes=unique({oo.noiseType});
aa=[];
for conditionName=conditionNames
    for observer=observers
        for targetCyclesPerDeg=targetCyclesPerDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    match=ismember({oo.conditionName},conditionName) ...
                        & ismember(lower({oo.observer}),lower(observer)) ...
                        & ismember([oo.targetCyclesPerDeg],targetCyclesPerDeg) ...
                        & ismember(eccXsfull,eccX) ...
                        & (ismember({oo.noiseType},noiseType) | ismember([oo.noiseSD],0)) ...
                        & ismember({oo.thresholdParameter},{'contrast'});
                    % We included zero noise conditions without regard to
                    % noiseType. But we keep the set of conditions only if
                    % at least one has the right noiseType.
                    if sum(match)>0 && any(ismember({oo(match).noiseType},noiseType))
                        E=[oo(match).E];
                        N=[oo(match).N];
                        [Neq,E0,deltaEOverN]=EstimateNeq(E,N);
                        m=ismember(N,max(N));
                        if max(N)>0
                            c=[oo(match).contrast];
                            c=mean(c(m));
                        end
                        EOverN=mean(E(m))/max(N);
                        m=ismember(N,0);
                        if sum(m)>0
                            c0=[oo(match).contrast];
                            c0=mean(c0(m));
                        else
                            c0=nan;
                        end
                        aa(end+1).experiment=oo(oi).experiment;
                        aa(end).conditionName=conditionName{1};
                        aa(end).observer=observer{1};
                        aa(end).c=c; % Scalar
                        aa(end).c0=c0; % Scalar
                        aa(end).EOverN=EOverN; % Scalar
                        aa(end).maxNoiseSD=max([oo(match).noiseSD]); % Scalar
                        aa(end).E=E; % Array
                        aa(end).N=N; % Array
                        aa(end).E0=E0; % Scalar
                        aa(end).Neq=Neq; % Scalar
                        aa(end).deltaEOverN=deltaEOverN; % Scalar
                        oi=find(match,1);
                        aa(end).thresholdParameter=oo(oi).thresholdParameter;
                        aa(end).eccentricityDeg=eccX;
                        aa(end).targetCyclesPerDeg=targetCyclesPerDeg;
                        aa(end).targetHeightDeg=oo(oi).targetHeightDeg;
                        aa(end).contrast=[oo(match).contrast];
                        aa(end).noiseSD=[oo(match).noiseSD];
                        aa(end).noiseType=noiseType{1};
                    end
                end
            end
        end
    end
end

% Now analyze aa, matching each human record with the corresponding ideal observer record.
for conditionName=conditionNames
    for observer=observers
        for targetCyclesPerDeg=targetCyclesPerDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    match=ismember({aa.thresholdParameter},{'contrast'})...
                        & ismember({aa.conditionName},conditionName)...
                        & ismember([aa.targetCyclesPerDeg],targetCyclesPerDeg)...
                        & ismember([aa.eccentricityDeg], eccX) ...
                        & ismember({aa.noiseType},noiseType);
                    idealMatch=match & ismember({aa.observer},{'ideal'});
                    match = match & ismember(lower({aa.observer}),lower(observer));
                    if sum(match)>0
                        aa(match).efficiency=nan;
                    end
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

%% SAVE TABLE TO DISK
t=struct2table(aa);
t=sortrows(t,'conditionName');
t=sortrows(t,'observer');
disp(t(:,{'experiment' 'conditionName' 'targetHeightDeg' 'targetCyclesPerDeg' 'efficiency' 'c' 'contrast' 'observer' 'noiseType' 'noiseIndex' 'maxNoiseSD'}));
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
% On Feb, 20, 2020 I discovered that writetable may screw up xls tables,
% but xlsx seems to be ok.
writetable(t,fullfile(dataFolder,[experiment '.xlsx']));
jsonwrite(fullfile(dataFolder,[experiment '.json']), t);
fprintf('Wrote files %s and %s to disk.\n',[experiment '.xlsx'],[experiment '.json']);

%% PLOT CONTRAST FOR EACH OBSERVER
% Convert table t to struct a
a=table2struct(t);
% figure(1);
% orient 'landscape'; % For printing.
cyan        = [0.2 0.8 0.8];
brown       = [0.2 0 0];
orange      = [1 0.5 0];
blue        = [0 0.5 1];
green       = [0 0.6 0.3];
red         = [1 0.2 0.2];
colors={[0.5 0.5 0.5] green red brown blue cyan orange };
assert(length(colors)>=length(targetCyclesPerDegs));
observerStyle={':x' '-o' '--s' '-.d' '-.^' '-->' '--<'};
if length(observerStyle)<length(observers)
    error('Please define more "observerStyle" for %d observers.',length(observers));
end
% Put ideal observer first.
observers=sort(observers);
iIdeal=ismember(observers,{'ideal'});
observers=[observers(iIdeal) observers(~iIdeal)];

% PLOT c VERSUS targetCyclesPerDeg
% figure(1);
iFigure=1;
clear lgd figureHandle
figureHandle(iFigure)=figure('Name',[experiment ' Contrast'],'NumberTitle','off','pos',[10 10 500 900]);
for conditionName=conditionNames
    iCondition=find(ismember(conditionNames,conditionName));
    subplot(length(conditionNames),1,iCondition);
    for iObserver=1:length(observers)
        for eccX=eccXs
            match=ismember({a.thresholdParameter},{'contrast'})...
                & ismember({a.conditionName},conditionName)...
                & ismember([a.eccentricityDeg],eccX);
            %         idealMatch=match & ismember({a.observer},{'ideal'});
            match = match & ismember(lower({a.observer}),lower(observers(iObserver)));
            for isZeroNoise=[false true]
                if isZeroNoise && ismember(observers(iObserver),{'ideal'})
                    continue
                end
                x=[a(match).targetCyclesPerDeg];
                if isZeroNoise
                    y=-[a(match).c0];
                else
                    y=-[a(match).c];
                end
                ok=isfinite(x) & isfinite(y);
                if ~isempty(ok)
                    if isZeroNoise
                        faceColor=[1 1 1];
                        sd=0;
                    else
                        faceColor=colors{iObserver};
                        sd=max([a(match).noiseSD]);
                    end
                    legendText=sprintf('%4.2f, %s',...
                        sd,...
                        observers{iObserver});
                    loglog(x(ok),y(ok),...
                        observerStyle{iObserver},...
                        'MarkerSize',6,...
                        'MarkerEdgeColor',colors{iObserver},...
                        'MarkerFaceColor',faceColor,...
                        'Color',colors{iObserver},...
                        'LineWidth',1.5,...
                        'DisplayName',legendText);
                    hold on
                end
            end
        end
    end
    %     ax=gca;
    %     ax.TickLength=[0.01 0.025]*2;
    %     ax.XTick=1:4;
    %     ax.XTickLabels={'Binary' 'Gaussian' 'Ternary' 'Uniform'};
    ax=gca;
    ax.TickLength=[0.01 0.025]*2;
    ax.XLim=[0.5 32];
    lgd(iCondition)=legend('Location','northwest','Box','off');
    title(lgd(iCondition),'noiseSD, observer');
    lgd(iCondition).FontName='Monaco';
    name=conditionName{1};
    title([upper(name(1)) name(2:end)],'fontsize',18)
    xlabel('Spatial frequency (c/deg)','fontsize',18);
    ylabel('Contrast threshold','fontsize',18);
    % set(findall(gcf,'-property','FontSize'),'FontSize',12)
    lgd(iCondition).FontSize=10;
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

% Set FontSize.
set(findall(gcf,'-property','FontSize'),'FontSize',12);
for iCondition=1:length(conditionNames)
    lgd(iCondition).FontSize=8;
end

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-ContrastVsSizeBig.eps']);
saveas(gcf,graphFile,'epsc');

%% PLOT EOverN FOR EACH OBSERVER
% figure(2);
iFigure=2;
clear lgd
figureHandle(iFigure)=figure('Name',[experiment ' E/N'],'NumberTitle','off','pos',[10 10 500 900]);
for conditionName=conditionNames
    iCondition=find(ismember(conditionNames,conditionName));
    subplot(length(conditionNames),1,iCondition);
    for iObserver=1:length(observers)
        for eccX=eccXs
            match=ismember({a.thresholdParameter},{'contrast'})...
                & ismember({a.conditionName},conditionName)...
                & ismember([a.eccentricityDeg],eccX);
            %         idealMatch=match & ismember({a.observer},{'ideal'});
            match = match & ismember(lower({a.observer}),lower(observers(iObserver)));
            x=[a(match).targetCyclesPerDeg];
            y=[a(match).EOverN];
            ok=isfinite(x) & isfinite(y);
            if ~isempty(ok)
                if ismember(observers(iObserver),{'ideal'})
                    faceColor=[1 1 1];
                else
                    faceColor=colors{iObserver};
                end
                loglog(x(ok),y(ok),...
                    observerStyle{iObserver},...
                    'MarkerSize',9,...
                    'MarkerEdgeColor',colors{iObserver},...
                    'MarkerFaceColor',faceColor,...
                    'Color',colors{iObserver},...
                    'LineWidth',1.5,...
                    'DisplayName',sprintf('%4.2f, %s',...
                    max([a(match).noiseSD]),observers{iObserver}));
                hold on
            end
        end
    end
    %     xlim([-4 4.5]);
    %     ax=gca;
    %     ax.TickLength=[0.01 0.025]*2;
    %     ax.XTick=1:4;
    %     ax.XTickLabels={'Binary' 'Gaussian' 'Ternary' 'Uniform'};
    %     lgd(iCondition)=legend('Location','northwest','Box','off');
    ax=gca;
    ax.TickLength=[0.01 0.025]*2;
    ax.XLim=[0.5 32];
    lgd(iCondition)=legend('Location','northwest','Box','off');
    title(lgd(iCondition),'noiseSD, observer');
    lgd(iCondition).FontName='Monaco';
    title(lgd(iCondition),'noiseSD, observer');
    lgd(iCondition).FontName='Monaco';
    name=conditionName{1};
    title([upper(name(1)) name(2:end)],'fontsize',18)
    xlabel('Spatial frequency (c/deg)','fontsize',18);
    ylabel('E/N threshold','fontsize',18);
    % ax.YLim=[10 1000];
    if true
        % Scale log unit to be 12 cm vertically.
        ax=gca;
        %ax.YLim=[0.005 0.16];
        ax.Units='centimeters';
        drawnow; % Needed for valid Position reading.
        ax.Position(4)=4*diff(log10(ax.YLim));
    end
    hold off
end

% Set FontSize.
figure(figureHandle(iFigure));
set(findall(gcf,'-property','FontSize'),'FontSize',12);
for iCondition=1:length(conditionNames)
    lgd(iCondition).FontSize=8;
end

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-EOverNVsSizeBig.eps']);
saveas(gcf,graphFile,'epsc');

%% PLOT EFFICIENCY FOR EACH OBSERVER
% figure(3);
iFigure=3;
clear lgd
figureHandle(iFigure)=figure('Name',[experiment ' Efficiency'],'NumberTitle','off','pos',[10 10 500 900]);
for conditionName=conditionNames
    iCondition=find(ismember(conditionNames,conditionName));
    subplot(length(conditionNames),1,iCondition);
    for iObserver=1:length(observers)
        for eccX=eccXs
            match=ismember({a.thresholdParameter},{'contrast'})...
                & ismember({a.conditionName},conditionName)...
                & ismember([a.eccentricityDeg],eccX);
            %         idealMatch=match & ismember({a.observer},{'ideal'});
            match = match & ismember(lower({a.observer}),lower(observers(iObserver)));
            x=[a(match).targetCyclesPerDeg];
            y=[a(match).efficiency];
            ok=isfinite(x) & isfinite(y);
            if ~isempty(ok)
                if ismember(observers(iObserver),{'ideal'})
                    faceColor=[1 1 1];
                else
                    faceColor=colors{iObserver};
                end
                loglog(x(ok),y(ok),...
                    observerStyle{iObserver},...
                    'MarkerSize',9,...
                    'MarkerEdgeColor',colors{iObserver},...
                    'MarkerFaceColor',faceColor,...
                    'Color',colors{iObserver},...
                    'LineWidth',1.5,...
                    'DisplayName',sprintf(' %4.2f, %s',...
                    max([a(match).noiseSD]),observers{iObserver}));
                hold on
            end
        end
    end
    %     xlim([-4 4.5]);
    %     ax=gca;
    %     ax.XTick=1:4;
    %     ax.XTickLabels={'Binary' 'Gaussian' 'Ternary' 'Uniform'};
    %     ax.TickLength=[0.01 0.025]*2;
    ax=gca;
    ax.TickLength=[0.01 0.025]*2;
    ax.XLim=[0.5 32];
    lgd(iCondition)=legend('Location','northwest','Box','off');
    title(lgd(iCondition),'noiseSD, observer');
    lgd(iCondition).FontName='Monaco';
    name=conditionName{1};
    title([upper(name(1)) name(2:end)],'fontsize',18)
    xlabel('Spatial frequency (c/deg)','fontsize',18);
    ylabel('Efficiency','fontsize',18);
    if true
        % Scale log unit to be 12 cm vertically.
        ax=gca;
        %ax.YLim=[0.005 0.16];
        ax.Units='centimeters';
        drawnow; % Needed for valid Position reading.
        if all(isfinite(log10(ax.YLim)))
            ax.Position(4)=4*diff(log10(ax.YLim));
        end
    end
    hold off
end

% Set FontSize.
figure(figureHandle(iFigure));
set(findall(gcf,'-property','FontSize'),'FontSize',12);
for iCondition=1:length(conditionNames)
    lgd(iCondition).FontSize=8;
end

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-EfficiencyVsSizeBig.eps']);
saveas(gcf,graphFile,'epsc');

%% FOR EACH OBSERVER: PLOT EFFICIENCY VS SIZE
% figure(4);
iFigure=4;
clear lgd
figureHandle(iFigure)=figure('Name',[experiment ' Efficiency vs Size'],'NumberTitle','off','pos',[10 10 500 900]);
for conditionName=conditionNames
    iCondition=find(ismember(conditionNames,conditionName));
    subplot(length(conditionNames),1,iCondition);
    for iObserver=1:length(observers)
        for eccX=eccXs
            match=ismember({a.thresholdParameter},{'contrast'})...
                & ismember({a.conditionName},conditionName)...
                & ismember([a.eccentricityDeg],eccX)...
                & ismember({a.noiseType},{'ternary'})...
                & ismember(lower({a.observer}),lower(observers(iObserver)));
            x=[a(match).targetCyclesPerDeg];
            y=[a(match).efficiency];
            ok=isfinite(x) & isfinite(y);
            if ~isempty(ok)
                if ismember(observers(iObserver),{'ideal'})
                    faceColor=[1 1 1];
                else
                    faceColor=colors{iObserver};
                end
                loglog(x(ok),y(ok),...
                    observerStyle{iObserver},...
                    'MarkerSize',9,...
                    'MarkerEdgeColor',colors{iObserver},...
                    'MarkerFaceColor',faceColor,...
                    'Color',colors{iObserver},...
                    'LineWidth',1.5,...
                    'DisplayName',sprintf('%4.2f, %s',...
                    max([a(match).noiseSD]),observers{iObserver}));
                hold on
            end
        end
    end
    ax=gca;
    ax.TickLength=[0.01 0.025]*2;
    ax.XLim=[0.5 32];
    lgd(iCondition)=legend('Location','northwest','Box','off');
    title(lgd(iCondition),'noiseSD, observer');
    lgd(iCondition).FontName='Monaco';
    name=conditionName{1};
    title([upper(name(1)) name(2:end)],'fontsize',18)
    xlabel('Spatial frequency (c/deg)','fontsize',18);
    ylabel('Efficiency','fontsize',18);
    ax.YLim=[0.001 1];
    if true
        % Scale log unit to be 12 cm vertically.
        ax=gca;
        %ax.YLim=[0.005 0.16];
        ax.Units='centimeters';
        drawnow; % Needed for valid Position reading.
        ax.Position(4)=4*diff(log10(ax.YLim));
    end
    hold off
end

% Set FontSize.
set(findall(gcf,'-property','FontSize'),'FontSize',12);
for conditionName=conditionNames
    iCondition=find(ismember(conditionNames,conditionName));
    lgd(iCondition).FontSize=8;
end

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-EfficiencyVsSize.eps']);
saveas(gcf,graphFile,'epsc');
