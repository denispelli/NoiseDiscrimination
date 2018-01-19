%% Maximum likelihood estimate of parameters of psychometric function.
% Analyze the data collected by <experiment>Run.
% Combine all runs of each combo of: experiment,observer,conditionName,noiseSD.
%
% denis.pelli@nyu.edu January 18, 2018
% We call QUESTPlusRecalculate, written by Shenghao Lin, to do the fit.

experiment='criterion2';
if ~exist('fakeRun')
   fakeRun=0;
end
if ~fakeRun
   % Read in all MAT data files for <experiment>.
   dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   cd(dataFolder);
   matFiles=dir(fullfile(dataFolder,[experiment 'Run*.mat']));
   clear data;
   j=0;
   for i = 1:length(matFiles)
      % Extract the desired fields into "data", one row per condition, merging runs.
      d = load(matFiles(i).name);
      o=d.o;
      % The data are in o.psych:
      % o.psych.t is a unique sorted list of log c.
      % o.psych.trials is the number of trials at each contrast. trials>0.
      % o.psych.right is the number of trials with correct response at each contrast. 0?right?trials
      merged=0;
      if exist('data','var')
         for j=1:length(data)
            % Match observer, noiseSD, and conditionName
            if streq(data(j).observer,o.observer) && data(j).noiseSD==o.noiseSD && streq(data(j).conditionName,o.conditionName)
               % Merge d into row j.
               merged=1;
               data(j).psych.t=[data(j).psych.t' o.psych.t']';
               data(j).psych.right=[data(j).psych.right o.psych.right];
               data(j).psych.trials=[data(j).psych.trials o.psych.trials];
               data(j).trials=data(j).trials+o.trials;
               data(j).condition=[data(j).condition o.condition];
               % We merely append the new data, without bothering to sort,
               % or run "unique".
            end
         end
      end
      if ~merged
         % Create new row for d.
         if exist('data','var')
            j=length(data)+1;
         else
            j=1;
         end
         data(j).LMean=mean([d.cal.LFirst d.cal.LLast]); % Compute from cal in case it's not in o.
         data(j).luminanceFactor=1; % default value
         for field={'condition' 'experiment' 'dataFilename' 'experimenter' 'observer' 'trials' ...
               'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
               'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
               'targetCheckDeg' 'fullResolutionTarget' ...
               'noiseType' 'noiseSD'  'noiseCheckDeg' ...
               'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' 'pThreshold' ...
               'contrast' 'E' 'N' 'E1' 'luminanceFactor' 'LMean' 'conditionName' 'psych'}
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
      cc{k}=data(k).condition;
   end
   [~,ii]=sortrows(cell2mat(cc'));
   data=data(ii);
   fprintf('Analyzing %d combinations of: experiment,observer,conditionName,noiseSD.\n',length(data));
end
assert(~isempty(data))

% Run QUESTPlus
clear dataPlus
for i=1:length(data)
   dataPlus(i) = QUESTPlusRecalculate(data(i));
end

%% Compute derived quantities: E0, Neq, targetCyclesPerDeg
for i=1:length(data)
   % Neq=N E0/(E-E0)
   i0=i-1;
   if i0>=1 && i0<=length(dataPlus) && dataPlus(i0).N==0
      dataPlus(i).E0=dataPlus(i0).E;
      dataPlus(i).Neq=dataPlus(i).N*dataPlus(i).E0/(dataPlus(i).E-dataPlus(i).E0);
   end
   dataPlus(i).targetCyclesPerDeg=dataPlus(i).targetGaborCycles/dataPlus(i).targetHeightDeg;
 end

%% Create CSV file
t=struct2table(dataPlus);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.csv']);
writetable(t,spreadsheet);
t
fprintf('Saved in spreadsheet: \\data\\%s.csv\n',experiment);

for i=1:length(dataPlus)
   o=dataPlus(i);
   fprintf('experiment %s, observer %s, conditionName %8s, trials %3d, noiseSD %.2f, contrast %.3f, steepness %.1f, guessing %.1f, lapse %.2f\n',...
      o.experiment,o.observer,o.conditionName,o.trials,o.noiseSD,o.contrast,o.steepness,o.guessing,o.lapse);
end