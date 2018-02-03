% Measure sd of steepness estimate vs. number of trials.
% We do this once with high threshold uncertainty, and once with known threshold.
% The resulting graph shows that knowing threshold saves about 30 trials.
% January 31, 2018 denis.pelli@nyu.edu
clear QuestPlusDemo % Clear persistent initialization.
results=zeros(8,2);
for row=1:8
   nTrials=32*row;
   contrastsDB=-40:0;
   steepnesses=1:0.5:7;
   guessingRates=0.25;
   lapseRates=0.01; %0:0.01:0.04
   psiParamsDomainList={contrastsDB steepnesses guessingRates lapseRates};
   for i=1:100
      [psiParamsFit(i,:),simulatedPsiParams]=QuestPlusDemo(nTrials,psiParamsDomainList);
   end
   t = array2table([0 simulatedPsiParams; nTrials mean(psiParamsFit); nTrials std(psiParamsFit)]);
   t.Properties.VariableNames={'trials' 'contrastDB' 'steepness' 'guessing' 'lapse'};
   t.Properties.RowNames={'simulation' 'mean' 'sd'};
   t
   results(row,1:3)=[nTrials t{'mean','steepness'} t{'sd','steepness'}];
end
results
semilogy(results(:,1),results(:,3),'-','DisplayName','threshold unknown');
xlabel('trials')
ylabel('SD of steepness')

hold on
clear QuestPlusDemo
results=zeros(8,2);
for row=1:8
   nTrials=32*row;
   contrastsDB=-20;
   steepnesses=1:0.5:7;
   guessingRates=0.25;
   lapseRates=0.01; %0:0.01:0.04
   psiParamsDomainList={contrastsDB steepnesses guessingRates lapseRates};
   for i=1:100
      [psiParamsFit(i,:),simulatedPsiParams]=QuestPlusDemo(nTrials,psiParamsDomainList);
   end
   t = array2table([0 simulatedPsiParams; nTrials mean(psiParamsFit); nTrials std(psiParamsFit)]);
   t.Properties.VariableNames={'trials' 'contrastDB' 'steepness' 'guessing' 'lapse'};
   t.Properties.RowNames={'simulation' 'mean' 'sd'};
   t
   results(row,1:3)=[nTrials t{'mean','steepness'} t{'sd','steepness'}];
end
results
semilogy(results(:,1),results(:,3),'--','DisplayName','threshold known');
xlabel('trials')
ylabel('SD of steepness')
legend off
legend('show','Location','northeast');
legend('boxoff');
