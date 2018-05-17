%% Analyze the data collected by csfRun.
global printConditions figureHandle
for expt={'csf' 'csfLetters' 'csfLettersStatic' 'csfGaborsStatic'}
    experiment=expt{1};
    idealEOverN=8.5;
    readExperiment=true;
    printConditions=false;
    printFilenames=true;
    plotGraphs=true;
    myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
    addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
    dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
    cd(dataFolder);
    if readExperiment
        % Each file contains an experiment: a cell array with one cell per
        % block. Each cell contains a struct array, with an element per
        % condition and its threshold.
        matFiles=dir(fullfile(dataFolder,'EvsN-*.mat'));
        matFiles=[matFiles;dir(fullfile(dataFolder,[experiment '-*.mat']))];
    else
        % Each file contains one condition and its threshold.
        matFiles=dir(fullfile(dataFolder,[experiment '*-NoiseDiscrimination*.mat']));
    end
    close all
    % We will ignore the blocking and read every condition into one huge struct
    % array oo. Each element contains one condition and its threshold.
    oo=[];
    clear Plot % To clear the persistent variables in the subroutine below.
    oi=0;
    vars={'functionNames' 'conditionName' 'experiment' 'dataFilename' ...
        'experimenter' 'observer' 'trials' ...
        'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' 'targetCyclesPerDeg'...
        'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
        'targetCheckDeg' 'fullResolutionTarget' ...
        'noiseType' 'noiseSD'  'noiseCheckDeg' ...
        'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
        'contrast' 'E' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
        'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
        'pixPerCm' 'nearPointXYPix' 'trialsPerBlock' 'NUnits' 'useDynamicNoiseMovie' 'noiseCheckFrames'};
    for iFile=1:length(matFiles) % One file per iteration.
        % Extract the desired fields into "oo", one cell-row per threshold.
        d=load(matFiles(iFile).name);
        if readExperiment
            if contains(matFiles(iFile).name,'NoiseDiscrimination') || ~isfield(d,'ooo')
                continue
            end
            if isempty(d.ooo{1}(1).observer)
                continue
            end
            if ~startsWith(d.ooo{1}(1).functionNames,experiment)
                fprintf('Skipping function name: %s\n',d.ooo{1}(1).functionNames);
                continue
            end
            ooo=d.ooo;
        else
            if ~isfield(d,'o') || d.o.trials<d.o.trialsPerBlock
                continue
            end
            ooo={d.o};
        end
        for block=1:length(ooo)
            ooIn=ooo{block};
            % Fix error in experiment name. Assume o.functionNames is right.
            [ooIn.experiment]=deal(experiment);
            % Fill in missing names. Assume first block is right.
            [ooIn.experimenter]=deal(ooo{1}(1).experimenter);
            [ooIn.observer]=deal(ooo{1}(1).observer);
            for oiIn=1:length(ooIn)
                oi=oi+1;
                for field=vars
                    if isfield(ooIn(oiIn),field{1})
                        newField=field{1};
                        oo(oi).(newField)=ooIn(oiIn).(field{1});
                    else
                        if block==1
                            warning OFF BACKTRACE
                            warning('Missing o field: %s\n',field{:});
                        end
                    end
                end
            end
        end
    end
    if isempty(oo)
        fprintf('Couldn''t find any data for experiment "%s".\n',experiment);
        return
    end
    
    %% DISCARD THRESHOLDS WITH INSUFFICIENT TRIALS
    s=sprintf('condition(trials):');
    for oi=length(oo):-1:1
        if isempty(oo(oi).trials) || oo(oi).trials<oo(oi).trialsPerBlock
            s=[s sprintf(' %d(%d),',oi,oo(oi).trials)];
            oo(oi)=[];
        end
    end
    if sum([oo.trials]<oo(1).trialsPerBlock)>0
        warning('Discarding %d threshold(s) with fewer than %d trials: %s',sum([oo.trials]<oo(1).trialsPerBlock),oo(oi).trialsPerBlock,s);
    end
    
    %% COMPUTE DERIVED QUANTITIES
    oo=ComputeNPhoton(oo);
    for observer=unique({oo.observer})
        for conditionName=unique({oo.conditionName})
            ii=ismember({oo.conditionName},conditionName)&ismember({oo.observer},observer);
            if sum(ii(:))>1
                E=[oo(ii).E];
                N=[oo(ii).N];
                [E0,Neq]=EstimateNeq(E,N);
                efficiency=idealEOverN/(E0/Neq);
            else
                E0=[];
                Neq=[];
                efficiency=[];
            end
            [oo(ii).E0]=deal(E0);
            [oo(ii).Neq]=deal(Neq);
            [oo(ii).efficiency]=deal(efficiency);
        end
    end
    
    % PRINT
    t=struct2table(oo);
    if printFilenames
        t(:,{'dataFilename','experiment','conditionName','observer','targetCyclesPerDeg','eccentricityXYDeg','contrast','noiseSD' 'Neq' 'E0'})
    end
    
    if plotGraphs
        fprintf('Plotting %d thresholds.\n',length(oo));
        observers=unique({oo.observer});
        
        if 1
            field='contrast';
            figureHandle=[];
            subplots=[2 length(observers)];
            style={'-xk' '--xk' '-.xk' ':xk'};
            for col=1:length(observers)
                observer=observers{col};
                iiObserver=ismember({oo.observer},observer);
                if sum(iiObserver)>0
                    fprintf('%s %s %s: %d thresholds.\n',experiment,observer,field,sum(iiObserver));
                    for row=1:2
                        subplotIndex=sub2ind(fliplr(subplots),col,row);
                        switch row
                            case 1
                                which=iiObserver & [oo.noiseSD]==0;
                            case 2
                                which=iiObserver & [oo.noiseSD]>0;
                        end
                        Plot(field,oo(which),subplots,subplotIndex,style);
                    end
                end
            end
        end
        
        if 1
            field='efficiency';
            figureHandle=[];
            subplots=[2 length(observers)];
            style={'-xk' '--xk' '-.xk' ':xk'};
            for col=1:length(observers)
                observer=observers{col};
                iiObserver=ismember({oo.observer},observer);
                if sum(iiObserver)>0
                    fprintf('%s %s %s: %d thresholds.\n',experiment,observer,field,sum(iiObserver));
                    which=iiObserver & [oo.noiseSD]==0;
                    for row=1:2
                        subplotIndex=sub2ind(fliplr(subplots),col,row);
                        switch row
                            case 1
                                Plot('efficiency',oo(which),subplots,subplotIndex,style);
                            case 2
                                Plot('Neq',oo(which),subplots,subplotIndex,style);
                        end
                    end
                end
            end
        end
    end % if plotGraphs
end % for expt={}
return

%% PLOT
function Plot(field,oo,subplots,subplotIndex,style)
global printConditions figureHandle
persistent figureTitle axisHandle
if isempty(oo)
    return
end
fontSize=12*0.6;
if isempty(figureHandle)
    rect=Screen('Rect',0);
    figureTitle=[oo(1).experiment '-' field];
    figureHandle=figure('Name',figureTitle,'NumberTitle','off','pos',[10 10 900 700]);
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

% Sort by eccentricity.
for oi=1:length(oo)
    oo(oi).eccentricityXDeg=oo(oi).eccentricityXYDeg(1);
end
[~,ii]=sort([oo.eccentricityXDeg]);
oo=oo(ii);
% Sort by sf.
[~,ii]=sort([oo.targetCyclesPerDeg]);
oo=oo(ii);


% Create CSV file
vars={'experiment' 'conditionName' ...
    'experimenter' 'observer' 'trials' 'contrast' 'luminanceAtEye' 'E' 'N' ...
    'Neq' 'E0' 'efficiency' ...
    'targetKind' 'targetCyclesPerDeg' 'targetHeightDeg' 'targetDurationSecs' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'LBackground'  'dataFilename' 'useDynamicNoiseMovie' 'noiseCheckFrames'};
t=struct2table(oo);
% spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[oo(1).experiment '.csv']);
% writetable(t,spreadsheet);
if printConditions
    disp(t(:,vars));
end
% fprintf('All selected fields have been saved in spreadsheet: /data/%s.csv\n',oo(1).experiment);

% Plot
N=[oo.N];
Neq=oo(1).Neq;
E0=oo(1).E0;
if Neq>=min(N) && Neq<2*max(N)
    % Trust reasonable Neq.
    NLow=Neq/100;
    NHigh=max([N Neq*10]);
else
    % Igore crazy Neq.
    NLow=min(N(N>0)); % Smallest nonzero noise.
    NHigh=max(N);
end
sfList=unique([oo.targetCyclesPerDeg]);
yAll=[];
for iStyle=1:length(sfList)
    sf=sfList(iStyle);
    ii=[oo.targetCyclesPerDeg]==sf;
    switch oo(1).targetKind
        case 'gabor'
            legendText=sprintf('%.1f c/deg',sf);
        case 'letter'
            legendText=sprintf('%.1f deg',oo(1).targetGaborCycles/sf);
    end
    y=abs([oo(ii).(field)]);
    y(y>10^3*min(y))=nan;
    yAll=[yAll y];
    loglog([oo(ii).eccentricityXDeg]+0.15,y,style{iStyle},'DisplayName',legendText);
    hold on;
end
% NLine=logspace(log10(NLow),log10(NHigh));
% ELine=(NLine+Neq)*E0/Neq;
% loglog(NLine,ELine,style2,'DisplayName','Linear fit');
set(gca,'FontSize',fontSize);
title([oo(1).observer]);
xlabel('Eccentricity+0.15 (deg)','Interpreter','tex');
switch field
    case 'Neq'
        ylabel('Neq (s deg^2)','Interpreter','tex');
    case 'contrast'
        ylabel('Contrast','Interpreter','tex');
    case 'efficiency'
        ylabel('Efficiency','Interpreter','tex');
    otherwise
        ylabel(field,'Interpreter','tex');
end
lgd=legend('show');
lgd.Location='southwest';
lgd.FontSize=fontSize;
legend('boxoff');
oo=ComputeNPhoton(oo);
caption={};
caption{1}=sprintf('observer %s, eyes %s', ...
    oo(1).observer,oo(1).eyes);
caption{2}=sprintf('noiseSD<=%.2f, noiseCheckDeg %.3f, noiseType %s', ...
    max([oo.noiseSD]),oo(1).noiseCheckDeg,oo(1).noiseType);
caption{3}=sprintf('%.1f cd/m^2, %.1f s, %s, useDynamicNoiseMovie %d, noiseCheckFrames %d', ...
    oo(1).luminanceAtEye,oo(1).targetDurationSecs,oo(1).targetKind,oo(1).useDynamicNoiseMovie,oo(1).noiseCheckFrames);
% If necessary, expand Y range to 3 log units.
switch field
    case 'contrast'
        logUnits=3;
    otherwise
        logUnits=2;
end
ax=gca;
yLim=ax.YLim;
assert(all(isreal(yLim))&&all(yLim>0),sprintf('Complex or not positive: %f%+fi %f%+fi  %f%+fi %f%+fi\n',...
    real(yLim(1)),imag(yLim(1)),real(yLim(2)),imag(yLim(2))));
switch field
    case 'contrast'
        yLim(1)=min(yAll,[],'omitnan')/225^0.5;
    otherwise
        yLim(1)=min(yAll,[],'omitnan')/225;
end
ax.YLim=yLim;
r=diff(log10(yLim)); % Number of log units
try
    if logUnits>r
        yLim(2)=yLim(2)*10^(logUnits-r);
    end
    ax.YLim=yLim;
catch e
    r=r;
    throw(e)
end

% Scale log unit to be 1.5 cm, vertically and horizontally for all
% variables, except 3 cm per log unit of contrast.
ax=gca;
u=ax.Units;
ax.Units='centimeters';
drawnow; % Needed for valid Position reading.
pos=ax.Position;
switch field
    case 'contrast'
        ax.Position=[pos(1:2) 1.5*diff(log10(ax.XLim)) 3*diff(log10(ax.YLim))];
    otherwise
        ax.Position=[pos(1:2) 1.5*diff(log10(ax.XLim)) 1.5*diff(log10(ax.YLim))];
end
ax.Units=u;

xLim=ax.XLim;
yLim=ax.YLim;
switch field
    case 'contrast'
        text(xLim(1),yLim(1)*20^0.5,caption,'FontSize',fontSize,'VerticalAlignment','bottom');
    otherwise
        text(xLim(1),yLim(1)*20,caption,'FontSize',fontSize,'VerticalAlignment','bottom');
end

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

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')
% print(gcf,graphFile,'-depsc'); % equivalent to saveas above
end % function Plot