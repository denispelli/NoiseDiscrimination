function oOut=QUESTPlusFit(o)
% oOut=QUESTPlusFit(o);
% Input:         o:      struct of human test data.
% Output:        oOut:   add fields: contrast,steepness,guessing,lapse
% Maximum likelihood estimate of parameters of psychometric function.
% The code here computes both maximum posterior and maximum likelihood
% estimates, but we return only the maximum likelihood estimate.
%
% Written by Shenghao Lin, January 2018. Polished by denis.pelli@nyu.edu.

% For a quick test:
% load ~/Dropbox/NoiseDiscrimination/data/criterion2Run-NoiseDiscrimination-darshan.2017.12.31.14.34.39.mat

printParameters=0; % For debugging.

%% QUESTPlus initialization
steepnesses=1:0.1:5;
if isfield(o,'questPlusSteepnesses')
   steepnesses=o.questPlusSteepnesses;
end
guessingRates=1/o.alternatives;
if isfield(o,'questPlusGuessingRates')
   guessingRates=o.questPlusGuessingRates;
end
lapseRates=0:0.01:0.05;
if isfield(o,'questPlusLapseRates')
   lapseRates=o.questPlusLapseRates;
end
contrastDB=20.*transpose(o.psych.t); % transform to dB
contrastDBUnique=unique(contrastDB);
questPlusData=qpInitialize('stimParamsDomainList',{contrastDBUnique},...,
   'psiParamsDomainList',{contrastDBUnique,steepnesses,guessingRates,lapseRates},...
   'noentropy',true); % Skip the (slow) entropy calculations.

%% Pour in data
for i=1:length(contrastDB)
   for trial=1:o.psych.trials(i)
      isRight= trial<=o.psych.right(i);
      questPlusData=qpUpdate(questPlusData,contrastDB(i),isRight+1);
   end
end

%% Estimate steepness and threshold contrast.
psiParamsIndex=qpListMaxArg(questPlusData.posterior);
psiParamsquestPlus=questPlusData.psiParamsDomain(psiParamsIndex,:);
if printParameters && 0
   % Useless because it assumes a uniform prior. Stick to maximum
   % likelihood.
   fprintf('Max posterior fit:      log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
      psiParamsquestPlus(1)/20,psiParamsquestPlus(2),psiParamsquestPlus(3),psiParamsquestPlus(4));
end
psiParamsFit=qpFit(questPlusData.trialData,questPlusData.qpPF,psiParamsquestPlus,questPlusData.nOutcomes,...,
   'lowerBounds',[min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
if printParameters
   fprintf('Maximum likelihood fit: log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
      psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
end
o.contrast=10^(psiParamsFit(1)/20);   % threshold contrast
o.E=o.E1*o.contrast^2;                % threshold energy
o.steepness=psiParamsFit(2);          % steepness
o.guessing=psiParamsFit(3);
o.lapse=psiParamsFit(4);

%% Return value
oOut=o;

o.plotSteepness=true;
if o.plotSteepness
   persistent conditionName noteString firstObserver
   %% Plot trial data with maximum likelihood fit
   newFigure=~streq(o.conditionName,conditionName);
   if newFigure
         firstObserver=o.observer;
   end
   newObserver=~streq(o.observer,firstObserver);
   conditionName=o.conditionName;
   if newFigure
      noteString={};
      figure('Name',[o.experiment ':' o.conditionName],'NumberTitle','off');
      title({o.conditionName,''},'FontSize',14);
      hold on
      set(gca,'FontSize',12);
   end
   stimCounts=qpCounts(qpData(questPlusData.trialData),questPlusData.nOutcomes);
   stim=[stimCounts.stim];
   stimFine=linspace(-40,0,100)';
   plotProportionsFit=qpPFWeibull(stimFine,psiParamsFit);
   for cc=1:length(stimCounts)
      nTrials(cc)=sum(stimCounts(cc).outcomeCounts);
      pCorrect(cc)=stimCounts(cc).outcomeCounts(2)/nTrials(cc);
   end
   o.trials=sum(nTrials);
   s=sprintf('%.2f %s',o.noiseSD,o.observer);
   if o.noiseSD==0
      color=[0 0 0];
   else
      color=[1 .2 0];
   end
   if newObserver
      lineStyle='--';
   else
      lineStyle='-';
   end
   semilogx(10.^(stimFine/20),plotProportionsFit(:,2),lineStyle,'Color',color,'LineWidth',3,'DisplayName',s); 
   scatter(10.^(stim/20),pCorrect,100,'o','MarkerEdgeColor',color,'MarkerFaceColor',...
      color,'MarkerEdgeAlpha',.1,'MarkerFaceAlpha',.1,'DisplayName',s);
   set(gca,'xscale','log');
   set(gca,'XTickLabel',{'0.01' '0.1' '1'});
   xlabel('Contrast');
   ylabel('Proportion correct');
   xlim([0.01 1]); ylim([0 1]);
   set(gca,'FontSize',12);
   noteString{1}=sprintf('%s: %s %.1f c/deg, ecc %.0f deg, %.1f s\n%.0f cd/m^2, eyes %s, trials %d',...
      o.conditionName,o.targetKind,o.targetCyclesPerDeg,o.eccentricityXYDeg(1),o.targetDurationSec,o.LMean,o.eyes,o.trials);
   noteString{2}=sprintf('%8s %7s %5s %9s %8s %5s','observer','noiseSD','log c','steepness','guessing','lapse');
   noteString{end+1}=sprintf('%-8s %7.2f %5.2f %9.1f %8.2f %5.2f', ...
      o.observer,o.noiseSD,log10(o.contrast),o.steepness,o.guessing,o.lapse);
   if newFigure
      hold on
   else
      text(0.4,0.4,'noiseSD observer');
      legend('show','Location','southeast');
      legend('boxoff');
      annotation('textbox',[0.14 0.11 .5 .2],'String',noteString,...
          'FitBoxToText','on','LineStyle','none',...
          'FontName','Monospaced','FontSize',9);
      drawnow;
   end
end
end
