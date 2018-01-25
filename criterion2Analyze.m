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
   for i = 1:length(matFiles)
      % Extract the desired fields into "data", one row per threshold.
      d = load(matFiles(i).name);
      data(i).LMean=mean([d.cal.LFirst d.cal.LLast]); % Compute from cal in case it's not in o.
      data(i).luminanceFactor=1; % default value
      for field={'condition' 'experiment' 'dataFilename' 'experimenter' 'observer' 'trials' ...
            'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
            'targetHeightDeg' 'targetDurationSec' 'targetDurationSecMean'...
            'targetCheckDeg' 'fullResolutionTarget' ...
            'noiseType' 'noiseSD'  'noiseCheckDeg' ...
            'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' 'pThreshold' ...
            'contrast' 'E' 'N' 'luminanceFactor' 'LMean' 'conditionName'}
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
fprintf('All selected fields have been saved in spreadsheet: \\data\\%s.csv\n',experiment);

fprintf('Please make a log-lin plot of Neq vs. pThreshold.\n');

%% Plot
figure;
clear legendString
for domain=1:3
   ii=(domain-1)*8+4+(1:4);
   ii=ii(ii<=length(data));
   if isempty(ii)
      break;
   end
   semilogy([data(ii).pThreshold],[data(ii).Neq],'-x'); 
   hold on;
   i=ii(1);
   legendString{domain}=sprintf('ecc %.0f deg, %.1f c/deg, %.1f s',...
      data(i).eccentricityXYDeg(1),data(i).targetCyclesPerDeg,data(i).targetDurationSec);
   if isfield(data(i),'LMean') && ~isempty(data(i).LMean)
      legendString{domain}=[legendString{domain} sprintf(', %.0f cd/m^2',data(i).LMean)];
   else
      legendString{domain}=[legendString{domain} sprintf(', luminanceFactor %.2f',data(i).luminanceFactor)];
   end
   if isfield(data(i),'conditionName') && ~isempty(data(i).conditionName)
      legendString{domain}=[data(i).conditionName ': ' legendString{domain}];
   end
end
hold off
legend(legendString);
legend('boxoff');
title(experiment);
xlabel('pThreshold');
ylabel('Neq (s deg^2)');
axis([0.25 1 1e-7 1e-4]); % Limits of x and y.
clear caption
caption{1}=sprintf('experimenter %s, observer %s,', ...
   data(1).experimenter,data(1).observer);
caption{2}=sprintf('targetKind %s, noiseType %s', ...
   data(1).targetKind,data(1).noiseType);
caption{3}=sprintf('eyes %s', data(1).eyes);
annotation('textbox',[0.25 0.15 .1 .1],'String',caption,'FitBoxToText','on','LineStyle','none');

pbaspect([1 1 1]); % Make vertical and horizontal axes equal in length.

% Scale so 3 log units vertically have same length as whole horizontal range.
% xLimits = get(gca,'XLim');
% yLimits = get(gca,'YLim');
% yDecade = diff(yLimits)/diff(log10(yLimits));  %# Average y decade size
% % xDecade = diff(xLimits)/diff(log10(xLimits));  %# Average x decade size
% set(gca,'XLim',xLimits,'YLim',yLimits,...
%         'DataAspectRatio',[1 3*yDecade/diff(xLimits) 1]);

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.eps']);
saveas(gcf,graphFile,'epsc')
% print(gcf,graphFile,'-depsc'); % equivalent to saveas above