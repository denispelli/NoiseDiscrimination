function oOut = QUESTPlusRecalculate(o)
% oOut = QUESTPlusRecalculate(o);
% Input:         o:      struct of human test data.
% Output:        oOut:   add fields: contrast, steepness, guessing, lapse
% Maximum likelihood estimate of parameters of psychometric function.
% The code here computes both maximum posterior and maximum likelihood
% estimates, but we return only the maximum likelihood estimate.
%
% Written by Shenghao Lin, January 2018. Polished by denis.pelli@nyu.edu.

% For a quick test:
% load ~/Dropbox/NoiseDiscrimination/data/criterion2Run-NoiseDiscrimination-darshan.2017.12.31.14.34.39.mat

printParameters=0; % For debugging.

%% QUESTPlus initialization
steepnesses=1.5:0.1:4;
guessingRates=1/o.alternatives;
lapseRates=0.01; % formerly 0:0.01:0.04
contrastDB = 20.*transpose(o.psych.t); % transform to dB
% When using qpUpdate (not our qpUpdateOnly), we could save time by
% quantizing to reduce the number of unique contrasts that QUESTPlus must
% consider. 
% contrastDB=0.5*round(2*contrastDB); % 0.5 dB quantization
contrastDBUnique=unique(contrastDB);
questPlusData = qpInitialize('stimParamsDomainList', {contrastDBUnique},...,
   'psiParamsDomainList',{contrastDBUnique, steepnesses, guessingRates, lapseRates},...
   'noentropy',true); % Skip the (slow) entropy calculations.

%% Pour in data
for i = 1:length(contrastDB)
   for trial=1:o.psych.trials(i)
      isRight= trial<=o.psych.right(i);
      questPlusData = qpUpdate(questPlusData, contrastDB(i), isRight+1);
%             questPlusData = qpUpdateOnly(questPlusData, contrastDB(i), isRight+1);
   end
end

%% Estimate steepness and threshold contrast.
psiParamsIndex = qpListMaxArg(questPlusData.posterior);
psiParamsquestPlus = questPlusData.psiParamsDomain(psiParamsIndex,:);
if printParameters
   fprintf('Max posterior fit parameters:      log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
      psiParamsquestPlus(1)/20,psiParamsquestPlus(2),psiParamsquestPlus(3),psiParamsquestPlus(4));
end
psiParamsFit = qpFit(questPlusData.trialData,questPlusData.qpPF,psiParamsquestPlus,questPlusData.nOutcomes,...,
   'lowerBounds', [min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
if printParameters
   fprintf('Maximum likelihood fit parameters: log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
      psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
end
o.contrast = 10^(psiParamsFit(1)/20);   % threshold contrast
o.E=o.E1*o.contrast^2;                  % threshold energy
o.steepness = psiParamsFit(2);          % steepness
o.guessing=psiParamsFit(3);
o.lapse=psiParamsFit(4);

%% Return value
oOut = o;
end
