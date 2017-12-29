%% Analyze the data collected by <experiment>Run.
experiment='criterion';
if ~exist('fakeRun')
   fakeRun=0;
end
if ~fakeRun
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
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' 'pThreshold' ...
            'contrast' 'E' 'N' 'LMean'}
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
end
assert(~isempty(data))

%% Compute derived quantities
for i=1:length(data)
   % Neq=N E0/(E-E0)
   i0=i-4;
   if i0>=1 && i0<=length(data) && data(i0).N==0
      data(i).E0=data(i0).E;
      data(i).Neq=data(i).N*data(i).E0/(data(i).E-data(i).E0);
   end
   data(i).targetCyclesPerDeg=data(i).targetGaborCycles/data(i).targetHeightDeg;
end

%% Create CSV file
t=struct2table(data);
spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.csv']);
writetable(t,spreadsheet);
t
fprintf('All selected fields for thresholds with at least 40 trials have been saved in spreadsheet: \\data\\%s.csv\n',experiment);

fprintf('Please make a log-lin plot of Neq vs. pThreshold.\n');

%% Plot
figure;
clear legendString
for domain=1:3
   ii=(domain-1)*8+4+(1:4);
   if max(ii)>length(data)
      break;
   end
   semilogy([data(ii).pThreshold],[data(ii).Neq],'-x'); 
   hold on;
   i=ii(1);
   legendString{domain}=sprintf('ecc %.0f deg, %.1f c/deg, %.1f s, %.0f cd/m^2',...
      data(i).eccentricityXYDeg(1),data(i).targetCyclesPerDeg,data(i).targetDurationSec,data(i).LMean);
   if isfield(data(i),'domainName') && ~isempty(data(i).domainName)
      legendString{domain}=[data(i).domainName ': ' legendString{domain}];
   end
end
hold off;
legend(legendString);
legend('boxoff');
title(experiment);
xlabel('pThreshold');
ylabel('Neq (s deg^2)');
clear caption
caption{1}=sprintf('experimenter %s, observer %s,', ...
   data(1).experimenter,data(1).observer);
caption{2}=sprintf('targetKind %s, noiseType %s', ...
   data(1).targetKind,data(1).noiseType);
caption{3}=sprintf('eyes %s', data(1).eyes);
annotation('textbox',[0.2 0.2 .1 .1],'String',caption,'FitBoxToText','on','LineStyle','none');
