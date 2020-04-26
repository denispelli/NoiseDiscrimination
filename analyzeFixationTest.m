%% Analyze the data collected by runNoiseTest.
% denis.pelli@nyu.edu
% February 20, 2020

experiment='FixationTest';
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
    'targetCheckDeg' 'isTargetFullResolution' ...
    'targetFont' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'contrast' 'E' 'E1' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
    'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
    'pixPerCm'  'nearPointXYPix' 'NUnits' 'beginningTime' 'thresholdParameter'...
    'questMean' 'partingComments' 'blockSecs' 'blockSecsPerTrial'...
    'isTargetFullResolution'};
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

% Round each target size greater than 2 to an integer, less than 2 to one decimal.
for oi=1:length(oo)
    if oo(oi).targetHeightDeg>2
        oo(oi).targetHeightDeg=round(oo(oi).targetHeightDeg);
    else
        oo(oi).targetHeightDeg=round(10*oo(oi).targetHeightDeg)/10;
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
                        aa(end+1).conditionName=conditionName{1};
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

% Now analyze aa, matching each human record with the correponding ideal observer record.
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

%% SAVE TABLE TO DISK
t=struct2table(aa);
t=sortrows(t,'conditionName');
t=sortrows(t,'observer');
if isfield(aa,'efficiency')
    disp(t(:,{'conditionName' 'targetHeightDeg' 'efficiency' 'c' 'contrast' 'noiseSD' 'observer' 'noiseType' 'noiseIndex' 'maxNoiseSD'}));
else
    disp(t(:,{'conditionName' 'targetHeightDeg' 'c' 'contrast' 'noiseSD' 'observer' 'noiseType' 'noiseIndex' 'maxNoiseSD'}));
end
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
colors={green red brown blue cyan orange };
assert(length(colors)>=length(targetHeightDegs));
observerStyle={':x' '-o' '--s' '-.d'};
if length(observerStyle)<length(observers)
    error('Please define more "observerStyle" for %d observers.',length(observers));
end
% Put ideal observer first.
observers=sort(observers);
iIdeal=ismember(observers,{'ideal'});
observers=[observers(iIdeal) observers(~iIdeal)];

% PLOT c VERSUS conditionName
% figure(1);
iFigure=1;
figureHandle(iFigure)=figure('Name',[experiment ' Contrast'],'NumberTitle','off','pos',[10 10 500 900]);
    for iObserver=1:length(observers)
        for eccX=eccXs
            match=ismember({a.thresholdParameter},{'contrast'})...
                & ismember([a.eccentricityDeg],eccX);
            match = match & ismember({a.observer},observers(iObserver));
            for isZeroNoise=[false true]
                if isZeroNoise && ismember(observers(iObserver),{'ideal'})
                    continue
                end
                x=find(ismember({a(match).conditionName},conditionNames));
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
                        faceColor=colors{iDeg};
                        sd=max([a(match).noiseSD]);
                    end
                    legendText=sprintf('%4.2f, %s',...
                        sd,...
                        observers{iObserver});
                    semilogy(x(ok),y(ok),...
                        observerStyle{iObserver},...
                        'MarkerSize',6,...
                        'MarkerEdgeColor',colors{iDeg},...
                        'MarkerFaceColor',faceColor,...
                        'Color',colors{iDeg},...
                        'LineWidth',1.5,...
                        'DisplayName',legendText);
                    hold on
                end
            end
        end
    end
xlim([-4 length(conditionNames)+0.5]);
ax=gca;
ax.TickLength=[0.01 0.025]*2;
ax.XTick=1:4;
xLabels=strrep(conditionNames,'gabor-','');
xLabels=strrep(xLabels,'Fixation','');
ax.XTickLabels=xLabels;
lgd(iFigure)=legend('Location','northwest','Box','off');
title(lgd(iFigure),'noiseSD, condition, observer');
lgd(iFigure).FontName='Monaco';
title('Contrast','fontsize',18)
xlabel('ConditionName','fontsize',18);
ylabel('Contrast threshold','fontsize',18);
% set(findall(gcf,'-property','FontSize'),'FontSize',12)
lgd(iFigure).FontSize=10;
if false
    % Scale log unit to be 12 cm vertically.
    ax=gca;
    %ax.YLim=[0.005 0.16];
    ax.Units='centimeters';
    drawnow; % Needed for valid Position reading.
    ax.Position(4)=8*diff(log10(ax.YLim));
end
hold off


% Set FontSize.
set(findall(gcf,'-property','FontSize'),'FontSize',12);
lgd(iFigure).FontSize=8;

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-ContrastVsFixation.eps']);
saveas(gcf,graphFile,'epsc');

%% PLOT EOverN FOR EACH OBSERVER
% figure(2);
iFigure=2;
figureHandle(iFigure)=figure('Name',[experiment ' E/N'],'NumberTitle','off','pos',[10 10 500 900]);
for iObserver=1:length(observers)
    for eccX=eccXs
        match=ismember({a.thresholdParameter},{'contrast'})...
            & ismember([a.eccentricityDeg],eccX)...
            & ismember({a.observer},observers(iObserver));
        x=find(ismember({a(match).conditionName},conditionNames));
        y=[a(match).EOverN];
        ok=isfinite(x) & isfinite(y);
        if ~isempty(ok)
            if ismember(observers(iObserver),{'ideal'})
                faceColor=[1 1 1];
            else
                faceColor=colors{iDeg};
            end
            semilogy(x(ok),y(ok),...
                observerStyle{iObserver},...
                'MarkerSize',9,...
                'MarkerEdgeColor',colors{iDeg},...
                'MarkerFaceColor',faceColor,...
                'Color',colors{iDeg},...
                'LineWidth',1.5,...
                'DisplayName',sprintf('%4.2f, %s',...
                max([a(match).noiseSD]),observers{iObserver}));
            hold on
        end
    end
end
xlim([-4 length(conditionNames)+0.5]);
ax=gca;
ax.TickLength=[0.01 0.025]*2;
ax.XTick=1:4;
xLabels=strrep(conditionNames,'gabor-','');
xLabels=strrep(xLabels,'Fixation','');
ax.XTickLabels=xLabels;
lgd(iFigure)=legend('Location','northwest','Box','off');
title(lgd(iFigure),'noiseSD, condition, observer');
lgd(iFigure).FontName='Monaco';
title('E/N','fontsize',18)
xlabel('ConditionName','fontsize',18);
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

% Set FontSize.
set(findall(gcf,'-property','FontSize'),'FontSize',12);
lgd(iFigure).FontSize=8;

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-EOverNVsFixation.eps']);
saveas(gcf,graphFile,'epsc');

%% PLOT EFICIENCY FOR EACH OBSERVER
% figure(3);
iFigure=3;
figureHandle(iFigure)=figure('Name',[experiment ' Efficiency'],'NumberTitle','off','pos',[10 10 500 900]);
for iObserver=1:length(observers)
    for eccX=eccXs
        match=ismember({a.thresholdParameter},{'contrast'})...
            & ismember([a.eccentricityDeg],eccX);
        match = match & ismember({a.observer},observers(iObserver));
        x=find(ismember({a(match).conditionName},conditionNames));
        y=[a(match).efficiency];
        ok=isfinite(x) & isfinite(y);
        if ~isempty(ok)
            if ismember(observers(iObserver),{'ideal'})
                faceColor=[1 1 1];
            else
                faceColor=colors{iDeg};
            end
            semilogy(x(ok),y(ok),...
                observerStyle{iObserver},...
                'MarkerSize',9,...
                'MarkerEdgeColor',colors{iDeg},...
                'MarkerFaceColor',faceColor,...
                'Color',colors{iDeg},...
                'LineWidth',1.5,...
                'DisplayName',sprintf('%4.2f, %s',...
                max([a(match).noiseSD]),observers{iObserver}));
            hold on
        end
    end
end
xlim([-4 length(conditionNames)+0.5]);
ax=gca;
ax.TickLength=[0.01 0.025]*2;
ax.XTick=1:4;
xLabels=strrep(conditionNames,'gabor-','');
xLabels=strrep(xLabels,'Fixation','');
ax.XTickLabels=xLabels;
lgd(iFigure)=legend('Location','northwest','Box','off');
title(lgd(iFigure),'noiseSD, condition, observer');
lgd(iFigure).FontName='Monaco';
title('Efficiency','fontsize',18)
xlabel('Size (deg)','fontsize',18);
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

% Set FontSize.
set(findall(gcf,'-property','FontSize'),'FontSize',12);
lgd(iFigure).FontSize=8;

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '-EfficiencyVsFixation.eps']);
saveas(gcf,graphFile,'epsc');
