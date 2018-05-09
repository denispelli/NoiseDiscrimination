%% Analyze the data collected by EvsNRun.
% It seems that NoiseDiscrimination only saves MAT files with "o" and
% "cal", but Veena's data have "oo". Is "oo" saved by EvsNRun? Looking at
% EvsNRun, I see it saves "oo" and "cal" in a *summary.MAT file, but Veena
% doesn't seem to have such files.
global printConditions
printConditions=false;
printFilenames=true;
plotGraphs=true;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
experiment='EvsN';
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
matFiles=dir(fullfile(dataFolder,[experiment '*-NoiseDiscrimination*.mat']));
close all
% experiment={};
oo=[];
clear Plot % To clear the persistent variables in the subroutine below.
for i=1:length(matFiles) % One threshold file per iteration.
    % Extract the desired fields into "oo", one cell-row per threshold.
    d=load(matFiles(i).name);
    if ~isfield(d,'o')
        % Skip summary files.
        continue
    end
    usesSecsPlural=contains(matFiles(i).name,'NoiseDiscrimination2');
    if usesSecsPlural
        vars={'condition' 'conditionName' 'experiment' 'dataFilename' ...
            'experimenter' 'observer' 'trials' ...
            'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
            'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
            'targetCheckDeg' 'fullResolutionTarget' ...
            'noiseType' 'noiseSD'  'noiseCheckDeg' ...
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
            'contrast' 'E' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
            'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
            'pixPerCm' 'screenRect' 'nearPointXYPix'};
    else
        vars={'condition' 'conditionName' 'experiment' 'dataFilename' ...
            'experimenter' 'observer' 'trials' ...
            'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
            'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean' 'targetDurationSecSD'...
            'targetCheckDeg' 'fullResolutionTarget' ...
            'noiseType' 'noiseSD'  'noiseCheckDeg' ...
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
            'contrast' 'E' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
            'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
            'pixPerCm' 'nearPointXYPix'};
    end
    o=struct;
    for field=vars
        if isfield(d.o,field{1})
            if usesSecsPlural
                newField=field{1};
            else
                newField=strrep(field{1},'Sec','Secs');
            end
            o.(newField)=d.o.(field{1});
        else
            if i==1
                warning OFF BACKTRACE
                warning('Missing o field: %s\n',field{:});
            end
        end
    end
    if isempty(oo)
        oo=o;
    else
        oo(end+1)=o; % Add row for this threshold.
    end
end
if any([oo.trials]<40)
    s=sprintf('condition(trials):');
    s=[s sprintf(' %d(%d),',oo([oo.trials]<40).condition,oo([oo.trials]<40).trials)];
    warning('Discarding %d threshold(s) with fewer than 40 trials: %s',sum([oo.trials]<40),s);
end
oo = oo([oo.trials]>=40); % Discard thresholds with fewer than 40 trials.

oo=ComputeNPhoton(oo);

% Report the luminance fields of each file.
t=struct2table(oo);
if printFilenames
    t(:,{'dataFilename','conditionName','observer','LBackground','filterTransmission','useFilter' 'luminanceFactor' 'luminanceAtEye' 'A' 'targetDurationSecs' 'LAT'})
end
fprintf('Unique o.luminanceAtEye: ');
u=unique(t.luminanceAtEye);
fprintf('%.0f, ',u);
fprintf('\n');

if plotGraphs
    fprintf('Plotting %d thresholds.\n',length(oo));
    for observer=unique({oo.observer})
        isObserver=ismember({oo.observer},observer);
        for conditionName=unique({oo.conditionName})
            isConditionName=ismember({oo.conditionName},conditionName);
            for noiseType=unique({oo.noiseType})
                isNoiseType=ismember({oo.noiseType},noiseType);
                which=isObserver & isConditionName & isNoiseType;
                if sum(which)>0
                    fprintf('%s-%s-%s: %d thresholds.\n',observer{1},conditionName{1},noiseType{1},sum(which));
                    subplots=[1 length(unique({oo.conditionName}))];
                    [~,subplotIndex]=ismember(conditionName,unique({oo.conditionName}));
                    Plot(oo(which),subplots,subplotIndex);
                end
            end
        end
    end
end
return

function Plot(oo,subplots,subplotIndex)
global printConditions
persistent previousObserver figureHandle overPlots figureTitle axisHandle
if isempty(oo)
    return
end
fontSize=12*0.6;
if isempty(get(groot,'CurrentFigure')) || ~streq(oo(1).observer,previousObserver)
    previousObserver=oo(1).observer;
    rect=Screen('Rect',0);
    figureTitle=[oo(1).experiment '-' oo(1).observer];
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

%% Compute derived quantities
E=[oo.E];
N=[oo.N];
[E0,Neq]=EstimateNeq(E,N);
for i=1:length(oo)
    oo(i).E0=E0;
    oo(i).Neq=Neq;
    oo(i).targetCyclesPerDeg=oo(i).targetGaborCycles/oo(i).targetHeightDeg;
end

%% Create CSV file
vars={'condition' 'experiment' 'conditionName' ...
    'experimenter' 'observer' 'trials' 'contrast' 'luminanceAtEye' 'E' 'N' ...
    'targetKind' 'targetCyclesPerDeg'  'targetHeightDeg'  'targetDurationSecs' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'LBackground'  'dataFilename'};
t=struct2table(oo);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[oo(1).experiment '.csv']);
% writetable(t,spreadsheet);
if printConditions
    disp(t(:,vars));
end
fprintf('All selected fields have been saved in spreadsheet: /data/%s.csv\n',oo(1).experiment);

%% Plot
if Neq>=min(N) && Neq<2*max(N)
    % Trust reasonable Neq. 
    NLow=Neq/100;
    NHigh=max([N Neq*10]);
else
    % Igore crazy Neq. 
    NLow=min(N(N>0)); % Smallest nonzero noise.
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
loglog(max(N,NLow),E,style1,'DisplayName',legendText);
hold on;
ax=gca;
NLine=logspace(log10(NLow),log10(NHigh));
ELine=(NLine+Neq)*E0/Neq;
loglog(NLine,ELine,style2,'DisplayName','Linear fit');
set(gca,'FontSize',fontSize);
title(oo(1).conditionName);
xlabel('\it N \rm (s deg^2)','Interpreter','tex')
ylabel('\it E \rm (s deg^2)','Interpreter','tex');
lgd=legend('show');
lgd.Location='northwest';
lgd.FontSize=fontSize;
legend('boxoff');
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
text(0.02,.02,caption,'Units','normalized','FontSize',fontSize,'VerticalAlignment','bottom');
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

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')
% print(gcf,graphFile,'-depsc'); % equivalent to saveas above
end