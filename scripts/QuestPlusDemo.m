function [psiParamsFit,simulatedPsiParams]=QuestPlusDemo(nTrials,psiParamsDomainList)
%[psiParamsFit,simulatedPsiParams]=QuestPlusDemo(nTrials,psiParamsDomainList)
%
% Estimate parameters of a Weibull psychometric function.

% 07/22/17  dhb  Wrote original at suggestion of dgp. 
% 1/18  dgp Highly modified.

printResults=false;
plotResults=false;
%% Initialize
%
% Set parameters, using key value pairs to override defaults as needed.
% (See "help qpParams" for what is available.)
%
% Here we set the range for the stimulus (contrast in dB) and the
% psychometric function parameters (see qpPFWeibull).
%
% Note that the space on which the stimulus is gridded affects the prior
% used by QUEST+.  QUEST+ assigns equal probability to each listed
% stimulus, so that the prior implied if you grid contrast in dB is
% different from that if you grid contrast on a linear scale.
if nargin<1
   nTrials = 32;
end
if nargin<2
   contrastsDB=-40:0;
   steepnesses=1:7;
   guessingRates=0.25;
   lapseRates=0:0.01:0.04;
else
   contrastsDB=psiParamsDomainList{1};
   steepnesses=psiParamsDomainList{2};
   guessingRates=psiParamsDomainList{3};
   lapseRates=psiParamsDomainList{4};
end
persistent questDataInit
if isempty(questDataInit)
   % This will persist until you "clear QuestPlusDemo".
   questDataInit = qpInitialize('stimParamsDomainList',{[-40:1:0]}, ...
      'psiParamsDomainList',{contrastsDB,steepnesses,guessingRates,lapseRates});
end
questData=questDataInit;

%% Set up simulated observer
simulatedPsiParams = [-20,3,0.25,0.02];
simulatedObserverFun = @(x) qpSimulatedObserver(x,@qpPFWeibull,simulatedPsiParams);

%% Simulate trials, using QUEST+ to tell us what contrast to test.
for tt = 1:nTrials
   stim = qpQuery(questData);
   outcome = simulatedObserverFun(stim);
   questData = qpUpdate(questData,stim,outcome);
end

%% Find out QUEST+'s estimate of the stimulus parameters, obtained
% on the gridded parameter domain.
psiParamsIndex = qpListMaxArg(questData.posterior);
psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
if printResults
   fprintf('Simulated parameters: %0.1f, %0.1f, %0.1f, %0.2f\n', ...
      simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4));
%    fprintf('Max posterior QUEST+ parameters: %0.1f, %0.1f, %0.1f, %0.2f\n', ...
%       psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4));
end
%% Find maximum likelihood fit.  Use psiParams from QUEST+ as the starting
% parameter for the search, and impose as parameter bounds the range
% provided to QUEST+.
psiParamsFit = qpFit(questData.trialData,questData.qpPF,psiParamsQuest,questData.nOutcomes,...
   'lowerBounds', [min(contrastsDB) min(steepnesses) min(guessingRates) min(lapseRates)],...
   'upperBounds',[max(contrastsDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
if printResults
   fprintf('Maximum likelihood fit parameters: %0.1f, %0.1f, %0.1f, %0.2f\n', ...
      psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
end

if plotResults
   %% Plot of trial locations with maximum likelihood fit
   close all
   figure; clf; hold on
   stimCounts = qpCounts(qpData(questData.trialData),questData.nOutcomes);
   stim = [stimCounts.stim];
   stimFine = linspace(-40,0,100)';
   plotProportionsFit = qpPFWeibull(stimFine,psiParamsFit);
   for cc = 1:length(stimCounts)
      nTrials(cc) = sum(stimCounts(cc).outcomeCounts);
      pCorrect(cc) = stimCounts(cc).outcomeCounts(2)/nTrials(cc);
   end
   
   for cc = 1:length(stimCounts)
      h = scatter(stim(cc),pCorrect(cc),100,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],...
         'MarkerFaceAlpha',nTrials(cc)/max(nTrials),'MarkerEdgeAlpha',nTrials(cc)/max(nTrials));
   end
   plot(stimFine,plotProportionsFit(:,2),'-','Color',[1.0 0.2 0.0],'LineWidth',3);
   xlabel('Stimulus Value');
   ylabel('Proportion Correct');
   xlim([-40 00]); ylim([0 1]);
   title({'Estimate Weibull threshold, slope, and lapse', ''});
   drawnow;
end
