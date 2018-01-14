%% Analyze the data collected by <experiment>Run.
experiment='criterion2';
if ~exist('fakeRun')
   fakeRun=0;
end
if ~fakeRun
   dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   cd(dataFolder);
   matFiles=dir(fullfile(dataFolder,[experiment 'Run*.mat']));
   clear data;
   j=0;
   for i = 1:length(matFiles)
      % Extract the desired fields into "data", one row per condition, merging runs.
      d = load(matFiles(i).name);
      o=d.o;
      if any(o.psych.trials~=1)
         bad=find(o.psych.trials~=1);
         bad=bad(1);
         fprintf('Too many trials: index %d, logC %.2f, trials %d, right %d\n',bad,o.psych.t(bad),o.psych.trials(bad),o.psych.right(bad));
%          error(['%s: o.psych.trials not equal to 1: ' num2str(unique(o.psych.right))],matFiles(i).name);
         o.psych.right(bad)=round(o.psych.right(bad)/o.psych.trials(bad));
         o.psych.trials(bad)=1;
      end
      if ~all(ismember(unique(o.psych.right),[0 1]))
         error(['%s: The o.psych.right values are not binary: ' num2str(unique(o.psych.right))],matFiles(i).name);
      end

      merged=0;
      if exist('data','var')
         for j=1:length(data)
            if streq(data(j).observer,o.observer) && data(j).noiseSD==o.noiseSD && streq(data(j).conditionName,o.conditionName)
               % Merge d into row j.
               merged=1;
               data(j).psych.t=[data(j).psych.t' o.psych.t']';
               data(j).psych.right=[data(j).psych.right o.psych.right];
               data(j).psych.trials=[data(j).psych.trials o.psych.trials];
               data(j).trials=data(j).trials+o.trials;
               data(j).condition=[data(j).condition o.condition];
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
   if any([data(:).trials]<40)
      s=sprintf('Threshold condition(trials):');
      s=[s sprintf(' %d(%d),',data([data(:).trials]<40).condition,data([data(:).trials]<40).trials)];
      warning('%d threshold(s) with fewer than 40 trials. %s',sum([data(:).trials]<40),s);
   end
%    data = data([data(:).trials]>=40); % Discard thresholds with less than 40 trials.
   % Sort by condition, where "condition" may contain several numbers.
   clear cc
   for k=1:length(data)
      cc{k}=data(k).condition;
   end
   [~,ii]=sortrows(cell2mat(cc'));
   data=data(ii);
   fprintf('Analyzing %d conditions.\n',length(data));
end
assert(~isempty(data))

%% Compute derived quantities
clear dataPlus
for i=1:length(data)
   dataPlus(i) = QUESTPlusRecalculate(data(i));
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
fprintf('All selected fields have been saved in spreadsheet: \\data\\%s.csv\n',experiment);

