%% Analyze the data collected by EvsNRun.
% It seems that NoiseDiscrimination only saves MAT files with "o" and "cal",
% but Veena's data have "oo". Is "oo" saved by EvsNRun? Looking at EvsNRun,
% I see it saves "oo" and "cal" in a *summary.MAT file, but Veena doesn't
% seem to have such files.
experiment='EvsN';
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
matFiles=dir(fullfile(dataFolder,[experiment 'Run-NoiseDiscrimination*.mat']));
close all
% experiment={};
oo=[];
for i=1:length(matFiles) % One threshold file per iteration.
    % Extract the desired fields into "oo", one cell-row per threshold.
    d=load(matFiles(i).name);
    if ~isfield(d,'o')
        % Skip summary files.
        continue
    end
    for field={'condition' 'conditionName' 'experiment' 'dataFilename' ...
            'experimenter' 'observer' 'trials' ...
            'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
            'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
            'targetCheckDeg' 'fullResolutionTarget' ...
            'noiseType' 'noiseSD'  'noiseCheckDeg' ...
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
            'contrast' 'E' 'N' 'LBackground' 'conditionName'}
        if isfield(d.o,field{:})
            o.(field{:})=d.o.(field{:});
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
oo = oo([oo.trials]>=40); % Discard thresholds with less than 40 trials.
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
                subPlots=[1 length(unique({oo.conditionName}))];
                [~,subPlotIndex]=ismember(conditionName,unique({oo.conditionName}));
                Plot(oo(which),subPlots,subPlotIndex);
            end
        end
    end
end
return

function Plot(oo,subPlots,subPlotIndex)
persistent previousObserver figureHandle
if isempty(oo)
    return
end
fig = get(groot,'CurrentFigure');
if isempty(get(groot,'CurrentFigure')) || ~streq(oo(1).observer,previousObserver)
    previousObserver=oo(1).observer;
%     hold off
    figureHandle=figure;
    figure('Name',oo(1).experiment,'NumberTitle','off');
end
assert(subPlotIndex<=subPlots(1)*subPlots(2),'subPlotIndex too high.');
subplot(subPlots(1),subPlots(2),subPlotIndex);
% Sort by noise N.
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
t=struct2table(oo);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[oo(1).experiment '.csv']);
% writetable(t,spreadsheet);
t
fprintf('All selected fields have been saved in spreadsheet: /data/%s.csv\n',oo(1).experiment);


%% Plot
set(gca,'FontSize',12);
clear legendString
loglog(N,E,'x');
hold on;
NFit=logspace(log10(Neq/4),log10(max(N)));
EFit=(NFit+Neq)*E0/Neq;
loglog(NFit,EFit,'-');
legendString{subPlotIndex}=sprintf('%s %s',oo(1).conditionName,oo(1).noiseType);
legend(legendString);
legend('boxoff');
title(oo(1).conditionName);
xlabel('N (s deg^2)');
ylabel('E (s deg^2)');
% axis([0.01 1 1 100]); % Limits of x and y.
clear caption
caption{1}=sprintf('experimenter %s, observer %s,', ...
    oo(1).experimenter,oo(1).observer);
caption{2}=sprintf('targetKind %s, noiseType %s', ...
    oo(1).targetKind,oo(1).noiseType);
caption{3}=sprintf('eyes %s', oo(1).eyes);
caption{4}=sprintf('%.1f c/deg, cosine phase',oo(1).targetCyclesPerDeg);
annotation('textbox',[0.25 0.2 .1 .1],'String',caption,'FitBoxToText','on','LineStyle','none');

% pbaspect([1 1 1]); % Make vertical and horizontal axes equal in length.

% Scale so log units  have same length vertically and horizontally.
xLimits = get(gca,'XLim');
yLimits = get(gca,'YLim');
yDecade = diff(yLimits)/diff(log10(yLimits));  %# Average y decade size
xDecade = diff(xLimits)/diff(log10(xLimits));  %# Average x decade size
set(gca,'XLim',xLimits,'YLim',yLimits,'DataAspectRatio',[1 yDecade/xDecade 1]);
% hold off;

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[oo(1).experiment '.eps']);
% saveas(gcf,graphFile,'epsc')
% print(gcf,graphFile,'-depsc'); % equivalent to saveas above
end