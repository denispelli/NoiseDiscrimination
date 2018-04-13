%% Analyze the data collected by EvsNRun.
% It seems that NoiseDiscrimination only saves "o" and "cal" in MAT files,
% but Veena's data have "oo". Is "oo" saved by EvsNRUN? Looking at EvsNRun,
% I see it saves "oo" and "cal" in a *summary.MAT file, but Veena doesn't
% seem to have such files.
experiment='EvsN';
if ~exist('skipDataCollection')
   skipDataCollection=false;
end
if ~skipDataCollection
   dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   cd(dataFolder);
   matFiles=dir(fullfile(dataFolder,[experiment 'Run-NoiseDiscrimination*.mat']));
   clear data;
   for i = 1:length(matFiles)
      % Extract the desired fields into "data", one row per threshold.
      d = load(matFiles(i).name);
%       data(i).LBackground=mean([d.cal.LFirst d.cal.LLast]); % Compute from cal in case it's not in o.
      data(i).luminanceFactor=1; % default value
      for field={'condition' 'experiment' 'dataFilename' 'experimenter' 'observer' 'trials' ...
            'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
            'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
            'targetCheckDeg' 'fullResolutionTarget' ...
            'noiseType' 'noiseSD'  'noiseCheckDeg' ...
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
            'contrast' 'E' 'N' 'LBackground' 'conditionName'}
         if isfield(d.o,field{:})
            data(i).(field{:})=d.o.(field{:});
         else
            if i==1
               warning OFF BACKTRACE
               warning('Missing data field: %s\n',field{:});
            end
         end
      end
   end
   if any([data(:).trials]<40)
      s=sprintf('Threshold condition(trials):');
      s=[s sprintf(' %d(%d),',data([data(:).trials]<40).condition,data([data(:).trials]<40).trials)];
      warning('%d threshold(s) with fewer than 40 trials. %s',sum([data(:).trials]<40),s);
   end
   %    data = data([data(:).trials]>=40); % Discard thresholds with less than 40 trials.
   % Sort by condition
   [~,ii]=sort([data(:).condition]);
   data=data(ii);
   fprintf('Plotting %d thresholds.\n',length(data));
end
assert(~isempty(data))
return
%% Compute derived quantities
for j=1:5:length(data)
   for i=j:j+3
      assert(data(j+4).N==0)
      data(i).E0=data(j+4).E;
      % (E-E0)/N
      data(i).EE0N=(data(i).E-data(i).E0)/data(i).N;
      % Neq=N E0/(E-E0)
      data(i).Neq=data(i).N*data(i).E0/(data(i).E-data(i).E0);
      data(i).targetCyclesPerDeg=data(i).targetGaborCycles/data(i).targetHeightDeg;
   end
end

%% Create CSV file
t=struct2table(data);
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
   loglog([data(ii).noiseCheckDeg],[data(ii).EE0N],'-x'); 
   hold on;
   legendString{graph}=sprintf('fullResolutionTarget %d',data(i).fullResolutionTarget);
   if isfield(data(i),'conditionName') && ~isempty(data(i).conditionName)
      legendString{graph}=[data(i).conditionName ': ' legendString{graph}];
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
   data(1).experimenter,data(1).observer);
caption{2}=sprintf('targetKind %s, noiseType %s', ...
   data(1).targetKind,data(1).noiseType);
caption{3}=sprintf('eyes %s', data(1).eyes);
caption{4}=sprintf('%.1f c/deg, cosine phase',data(1).targetCyclesPerDeg);
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