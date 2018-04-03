%% Maximum likelihood estimate of parameters of psychometric function.
% Analyze the data collected by <experiment>Run.
% Combine all runs of each combo of: experiment,observer,conditionName,noiseSD.
%
% denis.pelli@nyu.edu January 18, 2018
% We call QUESTPlusRecalculate, written by Shenghao Lin, to do the fit.

mergeRuns=0;
experiment='steepness';
if ~exist('skipDataCollection')
   skipDataCollection=0;
end
if ~skipDataCollection
   % Read in all MAT data files for <experiment>.
   dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   cd(dataFolder);
   matFiles=dir(fullfile(dataFolder,[experiment 'Run*.mat']));
   clear data;
   j=0;
   for i = 1:length(matFiles)
      % Extract the desired fields into "data", one row per condition,
      % merging multiple runs of same condition.
      d = load(matFiles(i).name);
      o=d.o;
      % The trial data are in o.psych:
      % o.psych.t is a unique sorted list of log c.
      % o.psych.trials is the number of trials at each contrast. trials>0.
      % o.psych.right is the number of trials with correct response at each contrast. 0<=right<=trials
      merged=0;
      if mergeRuns
         if exist('data','var')
            for j=1:length(data)
               % Match observer, noiseSD, and conditionName
               if o.trials>10 && streq(data(j).observer,o.observer) && data(j).noiseSD==o.noiseSD && streq(data(j).conditionName,o.conditionName)
                  % Merge o into matching row j.
                  merged=1;
                  data(j).psych.t=[data(j).psych.t' o.psych.t']';
                  data(j).psych.right=[data(j).psych.right o.psych.right];
                  data(j).psych.trials=[data(j).psych.trials o.psych.trials];
                  data(j).trials=data(j).trials+o.trials;
                  data(j).condition=[data(j).condition o.condition];
                  if data(j).alternatives~=o.alternatives
                     error('Trying to merge runs with unequal o.alternatives %d vs %d',data(j).alternatives,o.alternatives);
                  end
                  break
                  % We merely append the new data, without bothering to sort,
                  % or run "unique".
               end
            end
         end % exist('data','var')
      end % if mergeRuns
      if ~merged
         % Create new row for o.
         if exist('data','var')
            j=length(data)+1;
         else
            j=1;
         end
         data(j).LBackground=mean([d.cal.LFirst d.cal.LLast]); % Compute from cal in case it's not in o.
         data(j).luminanceFactor=1; % default value
         for field={'condition' 'experiment' 'dataFilename' 'experimenter' 'observer' 'trials' ...
               'alternatives' ...
               'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
               'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
               'targetCheckDeg' 'fullResolutionTarget' ...
               'noiseType' 'noiseSD'  'noiseCheckDeg' ...
               'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' 'pThreshold' ...
               'contrast' 'E' 'N' 'E1' 'luminanceFactor' 'LBackground' 'conditionName' 'psych'}
            if isfield(d.o,field{:})
               data(j).(field{:})=d.o.(field{:});
            else
               if j==1
                  warning OFF BACKTRACE
                  warning('Missing data field: %s\n',field{:});
               end
            end
         end
      end
   end
   if any([data(:).trials]<20)
      s=sprintf('Threshold condition(trials):');
      s=[s sprintf(' %d(%d),',data([data(:).trials]<20).condition,data([data(:).trials]<20).trials)];
      warning('Discarding %d threshold(s) with fewer than 20 trials. %s',sum([data(:).trials]<20),s);
      data = data([data(:).trials]>=20); % Discard thresholds with less than 20 trials.
   end
   if any([data(:).trials]<40)
      s=sprintf('Threshold condition(trials):');
      s=[s sprintf(' %d(%d),',data([data(:).trials]<40).condition,data([data(:).trials]<40).trials)];
      warning('%d threshold(s) with fewer than 40 trials. %s',sum([data(:).trials]<40),s);
   end
   % Sort by condition, where "condition" may contain several numbers.
   clear cc
   for k=1:length(data)
      cc(k)=mean(data(k).condition);
   end
   [~,ii]=sort(cc);
   data=data(ii);
   fprintf('Analyzing %d combinations of: experiment,observer,conditionName,noiseSD.\n',length(data));
end % ~skipDataCollection
assert(~isempty(data))

for i=1:length(data)
   data(i).targetCyclesPerDeg=data(i).targetGaborCycles/data(i).targetHeightDeg;
end

% Run QUESTPlus
close all % Get rid of any existing figures.
clear dataPlus
clear QUESTPlusFit % Clear the persistent variables.
for i=1:length(data)
   dataPlus(i) = QUESTPlusFit(data(i));
end

% Save plots to disk
figHandles = findall(groot, 'Type', 'figure');
for i=1:length(figHandles)
   figure(figHandles(i).Number);
   graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figHandles(i).Name '.eps']);
   saveas(gcf,graphFile,'epsc')
   % print(gcf,graphFile,'-depsc'); % equivalent to saveas above
   fprintf('Plot saved as "%s".\n',[figHandles(i).Name '.eps']);
end

%% Compute derived quantities: E0, Neq, targetCyclesPerDeg
for i=1:length(data)
   % Neq=N E0/(E-E0)
   i0=i-1;
   if i0>=1 && i0<=length(dataPlus) && dataPlus(i0).N==0
      dataPlus(i).E0=dataPlus(i0).E;
      dataPlus(i).Neq=dataPlus(i).N*dataPlus(i).E0/(dataPlus(i).E-dataPlus(i).E0);
   end
end

%% Create CSV file
t=struct2table(dataPlus);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.csv']);
writetable(t,spreadsheet);
t
fprintf('Saved in spreadsheet: \\data\\%s.csv\n',experiment);

fprintf('experiment observer conditionName trials noiseSD contrast logE steepness guessing lapse\n');
for i=1:length(dataPlus)
   o=dataPlus(i);
   fprintf('%s, %10s, %8s, trials %3d, noiseSD %.2f, contrast %.3f, logE %.2f, steepness %.1f, guessing %.2f, lapse %.2f\n',...
      o.experiment,o.observer,o.conditionName,o.trials,o.noiseSD,o.contrast,log10(o.E),o.steepness,o.guessing,o.lapse);
end