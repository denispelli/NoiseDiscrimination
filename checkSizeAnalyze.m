%% Analyze the data collected by checkSizeRun.
experiment='checkSize';
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
matFiles=dir(fullfile(dataFolder,[experiment 'Run*.mat']));
clear data;
for ii = 1:length(matFiles)
   % Extract the desired fields into "data", one row per threshold.
   d = load(matFiles(ii).name);
   for field={'condition' 'experiment' 'dataFilename' 'experimenter' 'observer' 'trials' ...
         'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
         'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
         'targetCheckDeg' 'fullResolutionTarget' ...
         'noiseType' 'noiseSD'  'noiseCheckDeg' ...
         'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
         'contrast' 'E' 'N' }
      if isfield(d.o,field{:})
         data(ii).(field{:})=d.o.(field{:});
      else
         if ii==1
            warning OFF BACKTRACE
            warning('Missing data field: %s\n',field{:});
         end
      end
   end
end
data = data([data(:).trials]>=40); % Discard thresholds with less than 40 trials.
fprintf('%d thresholds.\n',length(data));
assert(~isempty(data))

%% Compute derived quantities
for i=1:2:length(data)
   assert(data(i+1).N==0)
   data(i).E0=data(i+1).E;
   data(i).EE0N=(data(i).E-data(i).E0)/data(i).N;
   data(i).Neq=data(i).N*data(i).E0/(data(i).E-data(i).E0);
end

%% Create CSV file
t=struct2table(data);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.csv']);
writetable(t,spreadsheet);
t
fprintf('All selected fields for thresholds with at least 40 trials have been saved in spreadsheet: \\data\\%s.csv\n',experiment);

fprintf('Please make a log-log plot of (E-E0)/N vs. targetDurationSec, with a line for each condition: fullResolutionTarget = 0 or 1\n');

%% Plot
figure;
for i=[1 3]
   loglog([data([i i+4]).targetDurationSec],[data([i i+4]).EE0N],'-');
   hold on
end
legend(sprintf('fullRes %d',data(1).fullResolutionTarget),sprintf('fullRes %d',data(3).fullResolutionTarget));
legend('boxoff');
title(experiment);
xlabel('duration (s)');
ylabel('(E-E0)/N');
caption=sprintf('experimenter %s, observer %s, targetKind %s, noiseType %s',...
   data(1).experimenter,data(1).observer,data(1).targetKind,data(1).noiseType);
annotation('textbox',[.1 0 1 1],'String',caption,'FitBoxToText','on');
