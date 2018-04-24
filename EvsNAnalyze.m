%% Analyze the data collected by EvsNRun.
% It seems that NoiseDiscrimination only saves MAT files with "o" and "cal",
% but Veena's data have "oo". Is "oo" saved by EvsNRun? Looking at EvsNRun,
% I see it saves "oo" and "cal" in a *summary.MAT file, but Veena doesn't
% seem to have such files.
experiment='EvsN';
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
matFiles=dir(fullfile(dataFolder,[experiment 'Run-NoiseDiscrimination*.mat']));
% experiment={};
oo={};
for i=1:length(matFiles) % One threshold file per iteration.
    % Extract the desired fields into "oo", one cell-row per threshold.
    d=load(matFiles(i).name);
    if ~isfield(d,'o')
        % Skip summary files.
        continue
    end
    o=d.o;
    oo{end+1}={}; % New row for this threshold.
    for field={'condition' 'conditionName' 'experiment' 'dataFilename' ...
            'experimenter' 'observer' 'trials' ...
            'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
            'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
            'targetCheckDeg' 'fullResolutionTarget' ...
            'noiseType' 'noiseSD'  'noiseCheckDeg' ...
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
            'contrast' 'E' 'N' 'LBackground' 'conditionName'}
        if isfield(o,field{:})
            oo{end}.(field{:})=o.(field{:});
        else
            if i==1
                warning OFF BACKTRACE
                warning('Missing o field: %s\n',field{:});
            end
        end
    end
end
trials=[];
for i=1:length(oo)
    trials(i)=oo{i}.trials;
end
if any(trials<40)
    s=sprintf('condition(trials):');
    s=[s sprintf(' %d(%d),',oo{trials<40}.condition,oo{trials<40}.trials)];
    warning('Discarding %d threshold(s) with fewer than 40 trials: %s',sum(trials<40),s);
end
oo = oo(trials>=40); % Discard thresholds with less than 40 trials.
observers={};
for i=1:length(oo)
    observers{i}=oo{i}.observer;
end
uniqueObservers=unique(observers);
fprintf('Plotting %d thresholds.\n',length(oo));
ooo=oo;
for observer=uniqueObservers
    oo=ooo(ismember(observers,observer));
    fprintf('Observer %s, %d thresholds.\n',observer{1},length(oo));
end
assert(~isempty(oo))
% Sort by condition number.
condition=[];
for i=1:length(oo)
    condition(i)=oo{i}.condition;
end
[~,ii]=sort(condition);
oo=oo(ii);
return
%% Compute derived quantities
for j=1:length(oo)
    switch oo{j}.conditionName
        case 'photon'
            switch oo{j}.noiseType
                case 'binary'
                case 'gaussian'
            end
        case 'ganglion'
        case 'cortical'
    end
end
for condition={'photon' 'ganglion' 'cortical'}
    which=oo.N==0
        assert(oo{j+4}.N==0)
        oo{i}.E0=oo{j+4}.E;
        % (E-E0)/N
        oo{i}.EE0N=(oo{i}.E-oo{i}.E0)/oo{i}.N;
        % Neq=N E0/(E-E0)
        oo{i}.Neq=oo{i}.N*oo{i}.E0/(oo{i}.E-oo{i}.E0);
        oo{i}.targetCyclesPerDeg=oo{i}.targetGaborCycles/oo{i}.targetHeightDeg;
    
end

%% Create CSV file
t=struct2table(oo);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.csv']);
writetable(t,spreadsheet);
t
fprintf('All selected fields have been saved in spreadsheet: \\data\\%s.csv\n',experiment);

fprintf('Please make a log-log plot of (E-E0)/N vs. noiseCheckDeg, with a line for each condition: fullResolutionTarget = 0 or 1\n');

%% Plot
figure;
set(gca,'FontSize',12);
clear legendString
for graph=1:2
    ii=(graph-1)*5+(1:4);
    i=ii(1);
    loglog([oo{ii}.noiseCheckDeg],[oo{ii}.EE0N],'-x');
    hold on;
    legendString{graph}=sprintf('fullResolutionTarget %d',oo{i}.fullResolutionTarget);
    if isfield(oo{i},'conditionName') && ~isempty(oo{i}.conditionName)
        legendString{graph}=[oo{i}.conditionName ': ' legendString{graph}];
    end
end
hold off
legend(legendString);
legend('boxoff');
title(experiment);
xlabel('noiseCheckDeg');
ylabel('(E-E0)/N');
axis([0.01 1 1 100]); % Limits of x and y.
clear caption
caption{1}=sprintf('experimenter %s, observer %s,', ...
    oo{1}.experimenter,oo{1}.observer);
caption{2}=sprintf('targetKind %s, noiseType %s', ...
    oo{1}.targetKind,oo{1}.noiseType);
caption{3}=sprintf('eyes %s', oo{1}.eyes);
caption{4}=sprintf('%.1f c/deg, cosine phase',oo{1}.targetCyclesPerDeg);
annotation('textbox',[0.25 0.2 .1 .1],'String',caption,'FitBoxToText','on','LineStyle','none');

% pbaspect([1 1 1]); % Make vertical and horizontal axes equal in length.

% Scale so log units  have same length vertically and horizontally.
xLimits = get(gca,'XLim');
yLimits = get(gca,'YLim');
yDecade = diff(yLimits)/diff(log10(yLimits));  %# Average y decade size
xDecade = diff(xLimits)/diff(log10(xLimits));  %# Average x decade size
set(gca,'XLim',xLimits,'YLim',yLimits,'DataAspectRatio',[1 yDecade/xDecade 1]);

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.eps']);
saveas(gcf,graphFile,'epsc')
% print(gcf,graphFile,'-depsc'); % equivalent to saveas above