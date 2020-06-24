if true
    %% Analyze the data collected by runUncertaintyNew and runUncertaintySangita
    experiment='uncertaintyNew'; % November/December 2019
    experiment='uncertaintySangita'; % November/December 2019
    experiment='uncertainty';
    global printConditions makePlotLinear showLegendBox
    showLegendBox=true;
    printConditions=false;
    printFilekeys=true;
    plotGraphs=true;
    makePlotLinear=false;
    myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
    addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
    dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
    cd(dataFolder);
    close all
    clear Plot % Clear the persistent variables in the subroutine below.
    
    %% READ ALL DATA FROM EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
    vars={'experiment' 'condition' 'conditionName' 'dataFilename' ...
        'experimenter' 'observer' 'trials' ...
        'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
        'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
        'targetCheckDeg' 'isTargetFullResolution' ...
        'targetFont' 'alphabet' ...
        'noiseType' 'noiseSD'  'noiseCheckDeg' ...
        'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
        'contrast' 'E' 'E1' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
        'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
        'pixPerCm'  'nearPointXYPix' 'NUnits' 'beginningTime' 'thresholdParameter'...
        'questMean' 'partingComments'...
        'uncertainParameter' 'uncertainValues'...
        'MSpace' 'MTime'...
        'pThreshold' 'steepness' 'lapse' 'guess'};
    oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.
    
    % Retain only the specified experiment.
    ok=ismember({oo.experiment},experiment);
    oo=oo(ok);
    
    fprintf('%s %d thresholds.\n',experiment,length(oo));
    
    %% PRINT COMMENTS
    % comments={oo.partingComments};
    % ok=true(size(comments));
    % for i=1:length(comments)
    %     if isempty(comments{i}) || isempty(comments{i}{1})
    %         ok(i)=false;
    %     end
    % end
    % comments=comments(ok);
    % for i=1:length(comments)
    %     fprintf('%s\n',comments{i}{1});
    % end
    
    for conditionName=conditionNames
        for observer=observers
            match=ismember({oo.thresholdParameter},{'contrast'});
            match=match & ismember({oo.conditionName},conditionName);
            idealMatch=match & ismember({oo.observer},{'ideal'});
            match = match & ismember({oo.observer},observer);
            if any(match) && ~any(idealMatch)
                % We need an ideal threshold for this condition.
            end
         end
    end
    
    % DELETE CONDITIONS WE CAN'T ANALYZE.
    ok=ismember({oo.targetFont},{'Sloan'}) | ismember({oo.targetKind},{'gabor'});
    oo=oo(ok);
    
    % USE UncertainEOverN TO IMPLEMENT WHITE-NOISE IDEAL.
    keys={};
    values=[];
    for oi=1:length(oo)
        M=1;
        for i=1:length(oo(oi).uncertainParameter)
            M=M*length(oo(oi).uncertainValues{i});
        end
        if ismember(oo(oi).observer,{'ideal'}) && oo(oi).N>0
            psych.trialsDesired=100;
            psych.reps=1;
            psych.tGuess=0;
            psych.tGuessSd=3;
            psych.pThreshold=oo(oi).pThreshold;
            psych.beta=oo(oi).steepness;
            psych.delta=oo(oi).lapse;
            psych.gamma=oo(oi).guess;
            psych.targetKind=oo(oi).targetKind;
            psych.targetFont=oo(oi).targetFont;
            psych.alphabet=oo(oi).alphabet;
            if ~ismember(oo(oi).conditionName,keys)
                % Each condition with non-zero noise is computed only once,
                % and cached.
                keys{end+1}=oo(oi).conditionName;
                values(end+1)=UncertainEOverN(M,psych);
            end
            i=find(ismember(keys,oo(oi).conditionName));
            oo(oi).E=values(i)*oo(oi).N;
        end
    end
    
    %% COMPUTE ANY MISSING IDEAL REFERENCE
    conditionNames=unique({oo.conditionName});
    observers=unique({oo.observer});
    for conditionName=conditionNames
        for observer=observers
            match=ismember({oo.thresholdParameter},{'contrast'});
            match=match & ismember({oo.conditionName},conditionName);
            idealMatch=match & ismember({oo.observer},{'ideal'});
            match = match & ismember({oo.observer},observer);
            if any(match) && ~any(idealMatch)
                % We need an ideal threshold for this condition.
                maxN=max([oo(match).N]);
                ii=match & ismember([oo.N],maxN);
                oi=find(ii,1);
                if oo(oi).N>0
                    fprintf('Computing ideal for conditionName: %s\n',...
                        oo(oi).conditionName);
                    psych.trialsDesired=100;
                    psych.reps=100;
                    psych.tGuess=0;
                    psych.tGuessSd=3;
                    psych.pThreshold=oo(oi).pThreshold;
                    psych.beta=oo(oi).steepness;
                    psych.delta=oo(oi).lapse;
                    psych.gamma=oo(oi).guess;
                    psych.targetKind=oo(oi).targetKind;
                    psych.targetFont=oo(oi).targetFont;
                    psych.alphabet=oo(oi).alphabet;
                    % Ideal threshold in noise.
                    oo(end+1)=oo(oi);
                    oo(end).observer='ideal';
                    oo(end).trials=psych.reps*psych.trialsDesired;
                    % oo(end).deltaEOverN=UncertainEOverN(M,psych);
                    % oo(end).E0=0;
                    % oo(end).Neq=0;
                    oo(end).E=UncertainEOverN(M,psych)*oo(oi).N;
                    oo(end).contrast=sign(oo(end).contrast)*sqrt(oo(end).E/oo(end).E1);
                    oo(end).beginningTime=[];
                    oo(end).questMean=[];
                    oo(end).date=[];
                    % Ideal threshold in zero noise.
                    oo(end+1)=oo(end);
                    oo(end).E=0;
                    % oo(end).E0=0;
                    % oo(end).Neq=0;
                    oo(end).contrast=0;
                    oo(end).N=0;
                    oo(end).noiseSD=0;
                end
            end
        end
    end

    % COMPUTE EFFICIENCY
    % Select thresholdParameter='contrast', for each conditionName, For
    % each observer, including ideal, use all (E,N) data to estimate
    % deltaEOverN and Neq. Compute efficiency by comparing deltaEOverN of
    % each to that of the ideal.
    conditionNames=unique({oo.conditionName});
    observers=unique({oo.observer});
    aa=[];
    for conditionName=conditionNames
        for observer=observers
            match=ismember({oo.conditionName},conditionName) & ismember({oo.observer},observer);
            match=match & ismember({oo.thresholdParameter},{'contrast'});
            if any(match)
                E=[oo(match).E];
                N=[oo(match).N];
                [Neq,E0,deltaEOverN]=EstimateNeq(E,N);
                if deltaEOverN<0.1
                    warning('observer "%s", conditionName "%s", deltaEOverN<0.1, deltaEOverN %.2g',...
                        observer{1},conditionName{1},deltaEOverN);
                    fprintf('E=['); fprintf('%.2g ',E); fprintf('];\n');
                    fprintf('N=['); fprintf('%.2g ',N); fprintf('];\n');
                end
                aa(end+1).conditionName=conditionName{1};
                aa(end).observer=observer{1};
                aa(end).E=E; % array
                aa(end).N=N; % array
                aa(end).E0=E0; % scalar
                aa(end).Neq=Neq; % scalar
                aa(end).deltaEOverN=deltaEOverN; % scalar
                aa(end).experiment=unique({oo(match).experiment});
                aa(end).targetHeightDeg=unique([oo(match).targetHeightDeg]);
                oi=find(match,1);
                aa(end).thresholdParameter=oo(oi).thresholdParameter;
            end
        end
    end
    for ai=1:length(aa)
        % Recover MSpace, MTime, and M from the conditionName. This may not
        % be necessary, as these fields may be defined in our data files.
        MSpaceStr=regexprep(aa(ai).conditionName,'.*MSpace=(\d+).*','$1');
        MSpace=str2num(MSpaceStr);
        MTimeStr=regexprep(aa(ai).conditionName,'.*MTime=(\d+).*','$1');
        MTime=str2num(MTimeStr);
        MStr=regexprep(aa(ai).conditionName,'.*M=(\d+).*','$1');
        M=str2num(MStr);
        if isempty(MSpace)
            if isempty(M)
                MSpace=1;
            else
                MSpace=M;
            end
        end
        if isempty(MTime)
            MTime=1;
        end
        if isempty(M)
            M=MSpace*MTime;
        end
        % fprintf('%s :',aa(ai).conditionName)
        % fprintf('MSpace %d, ',MSpace);
        % fprintf('MTime %d, ',MTime);
        % fprintf('M %d, ',M);
        % fprintf('\n');
        aa(ai).M=M;
        aa(ai).MSpace=MSpace;
        aa(ai).MTime=MTime;
    end
    for conditionName=conditionNames
        for observer=observers
            match=ismember({aa.thresholdParameter},{'contrast'});
            match=match & ismember({aa.conditionName},conditionName);
            idealMatch=match & ismember({aa.observer},{'ideal'});
            match = match & ismember({aa.observer},observer);
            if any(match) && ~any(idealMatch)
                % We need an ideal threshold for this condition.
                fprintf('Missing ideal for %s, %s.\n',conditionName{1},observer{1});
            end
            if any(match) && any(idealMatch)
                assert(sum(match)==1 & sum(idealMatch)==1);
                aa(match).efficiency=aa(idealMatch).deltaEOverN ./ aa(match).deltaEOverN;
            end
        end
    end
    oo=SortFields(oo);
    aa=SortFields(aa);

    for ai=1:length(aa)
        aa(ai).maxN=max(aa(ai).N);
    end
    % human=~ismember({aa.observer},'ideal');
    % aa=struct2table(aa(human));
    ta=struct2table(aa);
    ta=sortrows(ta,'conditionName');
    disp(ta(:,{'conditionName','efficiency','observer','deltaEOverN'}));
    if ~isempty(mfilename)
    dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
    else
        dataFolder='~/Dropbox/MATLAB/NoiseDiscrimination/data/';
    end
    vars={'experiment' 'conditionName' 'thresholdParameter'  'targetHeightDeg' 'observer' 'E0' 'deltaEOverN' 'maxN' 'efficiency' 'MSpace' 'MTime' 'M'};

    % WE NEED TO DELETE STALE TABLE FIRST, OTHERWISE ANY CELLS NOT
    % OVERWITTEN REMAIN. Ugh!
    file=fullfile(dataFolder,'efficiency.xlsx');
    if exist(file,'file')
        delete(file);
    end
    writetable(ta(:,vars),file);

    fprintf('Ready to analyze %d thresholds:\n',length(oo));
    % return
    if false
    % oo=ComputeNPhoton(oo);
    % Compute efficiency
    
    % Report selected fields for each combination of conditionName & observer.
    t=struct2table(oo);
    if printFilekeys
        %     t=sortrows(t,{'targetFont','N','observer'});
        %     disp(t(:,{'targetFont','N','E','observer','noiseSD'}));
        %     tt=t(:,{'targetFont','N','E','observer','noiseSD'});
        %     t=sortrows(t,{'conditionName' 'thresholdParameter' 'N' 'observer'});
        disp(t(:,{'observer' 'conditionName' 'thresholdParameter' 'N' 'E' ...
            'targetHeightDeg'  'noiseSD' 'contrast' }));
    end
    tt=t(:,{'experiment' 'conditionName' 'thresholdParameter' 'N' 'E' 'targetHeightDeg' 'observer' 'noiseSD' 'contrast'});
    file=fullfile(dataFolder,'uncertaintyThresholds.xlsx');
    if exist(file,'file')
        delete(file);
    end
    writetable(tt,file);
    end
    return
end

close all
clear Plot % Clear the persistent variables in the subroutine below.
list=struct([]);
if plotGraphs
    %     conditionNames=unique({oo.conditionName});
    conditionNames={'gabor;M=1' 'gabor;M=104' 'letter;M=1' 'letter;M=104'};
    
    fprintf('Plotting %d thresholds.\n',length(oo));
    for observer=unique({oo.observer})
        isObserver=ismember({oo.observer},observer);
        for conditionName=conditionNames
            isConditionName=ismember({oo.conditionName},conditionName);
            which=isObserver & isConditionName;
            if sum(which)>0
                % fprintf('%s-%s-%s: %d thresholds. ',observer{1},conditionName{1},noiseType{1},sum(which));
                list(end+1).observer=observer{1};
                list(end).conditionName=conditionName{1};
                list(end).thresholds=sum(which);
                E=[oo(which).E];
                N=[oo(which).N];
                % fprintf('%s %s\n',observer{1},conditionName{1});
                [Neq,E0]=EstimateNeq(E,N);
                E1=oo(which).E1;
                E1=mean(E1);
                list(end).logC0=0.5*log10(E0/E1);
                list(end).logNeq=log10(Neq);
                list(end).logE0OverNeq=log10(E0/Neq);
                subplots=[1 length(conditionNames)];
                [~,subplotIndex]=ismember(conditionName,conditionNames);
                Plot(oo(which),subplots,subplotIndex);
            end
        end
    end
end
t=struct2table(list);
disp(t);
return

%% PLOT FUNCTION
function Plot(oo,subplots,subplotIndex)
global printConditions makePlotLinear showLegendBox
persistent previousObserver figureHandle overPlots figureTitle axisHandle
if isempty(oo)
    return
end
fontSize=12*0.6;
if isempty(get(groot,'CurrentFigure')) || ~streq(oo(1).observer,previousObserver)
    previousObserver=oo(1).observer;
    rect=Screen('Rect',0);
    figureTitle=[oo(1).experiment '-' oo(1).observer];
    if makePlotLinear
        figureTitle=[figureTitle '-linear'];
    end
    figureHandle=figure('Name',figureTitle,'NumberTitle','off','pos',[10 10 900 300]);
    orient 'landscape'; % For printing.
    overPlots=zeros(1,subplots(1)*subplots(2));
    axisHandle=zeros(1,subplots(1)*subplots(2));
    an=annotation('textbox',[0 0.9 1 .1],...
        'String',figureTitle,...
        'LineStyle','none','FontSize',fontSize*2,...
        'HorizontalAlignment','center','VerticalAlignment','top');
else
    figure(figureHandle);
end
if axisHandle(subplotIndex)==0
    % subplot(m,n,p) makes it easy to show several related graphs in one
    % figure window. Calling subplot(m,n,p) for an existing axis object
    % seems to erase it. So, when we first select that figure panel, we
    % save a handle to it, which we later reuse to select the panel by
    % calling subplot(handle), without calling subplot(m,n,p) again.
    axisHandle(subplotIndex)=subplot(subplots(1),subplots(2),subplotIndex);
else
    hold(axisHandle(subplotIndex),'on');
    subplot(axisHandle(subplotIndex));
end

% Sort by noise N. So it'll look pretty if we later connect the dots.
[~,ii]=sort([oo.N]);
oo=oo(ii);

%% Compute derived quantities: Neq, E0, and c/deg
E=[oo.E];
N=[oo.N];
[Neq,E0]=EstimateNeq(E,N);
for i=1:length(oo)
    oo(i).E0=E0;
    oo(i).Neq=Neq;
    oo(i).targetCyclesPerDeg=oo(i).targetGaborCycles/oo(i).targetHeightDeg;
end

%% Create CSV file
vars={'experiment' 'conditionName' ...
    'experimenter' 'observer' 'trials' 'contrast' 'luminanceAtEye' 'E' 'N' ...
    'targetKind' 'targetCyclesPerDeg'  'targetHeightDeg'  'targetDurationSecs' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'LBackground'  'dataFilename'};
t=struct2table(oo,'AsArray',true);
dataFilename=[oo(1).experiment '-' oo(1).conditionName '.csv'];
if printConditions
    disp(t(:,vars));
end
if false
    spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',dataFilename);
    writetable(t,spreadsheet);
    fprintf('All selected fields have been saved in spreadsheet: /data/%s\n',dataFilename);
end

% return

%% Plot
if Neq>=min(N) && Neq<2*max(N)
    % Trust reasonable Neq.
    NLow=Neq/100;
    NHigh=max([N Neq*10]);
else
    % Igore crazy Neq.
    NLow=min(N(N>0)); % Smallest nonzero noise.
    if isempty(NLow)
        NLow=eps;
    end
    NHigh=max(N);
end
overPlots(subplotIndex)=overPlots(subplotIndex)+1;
switch overPlots(subplotIndex)
    case 1
        style1='xk';
        style2='-k';
        hold off;
    case 2
        style1='ok';
        style2='--k';
        hold on;
    case 3
        style1='+k';
        style2=':k';
        hold on;
    otherwise
        style1='^k';
        style2='-.k';
        hold on;
end
legendText=sprintf('%s %s',oo(1).conditionName,oo(1).noiseType);
try
    loglog(max(N,NLow),E,style1,'DisplayName',legendText);
catch ME
    N
    NLow
    rethrow(ME)
end
hold on;
ax=gca;
NLine=logspace(log10(NLow),log10(NHigh));
ELine=(NLine+Neq)*E0/Neq;
loglog(NLine,ELine,style2,'DisplayName','Linear fit');
set(gca,'FontSize',fontSize);
title(oo(1).conditionName);
xlabel(['\it N \rm (' oo(1).NUnits ')'],'Interpreter','tex')
ylabel(['\it E \rm (' oo(1).NUnits ')'],'Interpreter','tex');
lgd=legend('show');
lgd.Location='northwest';
lgd.FontSize=fontSize;
lgd.Color='none';
if ~showLegendBox
    legend('boxoff');
end
oo=ComputeNPhoton(oo);
caption={};
caption{1}=sprintf('experimenter %s, observer %s, eyes %s', ...
    oo(1).experimenter,oo(1).observer,oo(1).eyes);
caption{2}=sprintf('noiseSD<=%.2f, noiseCheckDeg %.3f, noiseType %s', ...
    max([oo.noiseSD]),oo(1).noiseCheckDeg,oo(1).noiseType);
caption{3}=sprintf('%.1f cd/m^2, %.0f td, LAT %.2f, log NPhoton %.1f', ...
    oo(1).luminanceAtEye,oo(1).retinalIlluminanceTd,oo(1).LAT,log10(oo(1).NPhoton));
caption{4}=sprintf('ecc. [%.0f %.0f] deg, %.1f s, %s %.1f c/deg, log Neq %.2f',...
    oo(1).eccentricityXYDeg,oo(1).targetDurationSecs,oo(1).targetKind,oo(1).targetCyclesPerDeg,log10(oo(1).Neq));
if ~makePlotLinear
    text(0.02,.02,caption,'Units','normalized','FontSize',fontSize,'VerticalAlignment','bottom');
end
% Set lower Y limit to E0/40. This leaves room for the "caption" text at
% bottom of graph. If necessary, expand Y range to 3 log units.
logUnits=3;
ax=gca;
yLimits=ax.YLim;
yLimits(1)=E0/40;
r=diff(log10(yLimits)); % Number of log units
if logUnits>r
    yLimits(2)=yLimits(2)*10^(logUnits-r);
end
ax.YLim=yLimits;

% Widen graph left and right to nearest even log unit.
% Make sure graph is at least 2 log units wide.
xLimits=ax.XLim;
xLimits(1)=10^floor(log10(xLimits(1)));
xLimits(2)=10^ceil(log10(xLimits(2)));
minLogUnits=2;
neededLogUnits=minLogUnits-log10(xLimits(2)/xLimits(1));
if neededLogUnits>0
    xLimits(1)=xLimits(1)/10^(neededLogUnits/2);
    xLimits(2)=xLimits(2)*10^(neededLogUnits/2);
end
ax.XLim=xLimits;

ax=gca;
if ax.XLim(1)<=0
    warning('Lower X limit too low!! Setting it to NLow.')
    xLim=ax.XLim
    ax.XLim=[NLow xLim(2)];
    oo(1).observer
    oo(1).experiment
    oo(1).conditionName
    oo(1).noiseType
    NLow
    min(NLine)
    E0
    Neq
end

% Scale log unit to be 1.5 cm, vertically and horizontally.
ax=gca;
u=ax.Units;
ax.Units='centimeters';
drawnow; % Needed for valid Position reading.
pos=ax.Position;
ax.Position=[pos(1:2) 1.5*diff(log10(ax.XLim)) 1.5*diff(log10(ax.YLim))];
ax.Units=u;

% Add second x-axis for noise contrast noiseSD.
% ax1=gca;
% ax2=axes('Position',ax1.Position,...
%     'XAxisLocation','top',...
%     'YAxisLocation','right',...
%     'Color','none',...
%     'XColor','k','YColor','k');
% ax2.XScale=ax1.XScale;
% ax2.YScale=ax1.YScale;
% ax2.XLim=sqrt(ax1.XLim)*oo(end).noiseSD/sqrt(oo(end).N);
% ax2.YLim=ax1.YLim;
% ax2.FontSize=ax1.FontSize;
if makePlotLinear
    set(gca,'XScale','linear','YScale','linear');
    ax=gca;
    xLim=ax.XLim;
    yLim=ax.YLim;
    xLim(1)=-2*Neq;
    yLim(1)=0;
    xLim(2)=10*oo(1).Neq;
    yLim(2)=E0+(E0/Neq)*xLim(2);
    if all(isfinite(xLim))
        ax.XLim=xLim;
    end
    if all(isfinite(yLim))
        ax.YLim=yLim;
    end
    legend('hide');
    NLine=[-Neq xLim(2)];
    ELine=[0 yLim(2)];
    loglog(NLine,ELine,style2);
end
% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')

% print(gcf,graphFile,'-depsc'); % equivalent to saveas above
end