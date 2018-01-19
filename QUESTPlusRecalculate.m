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

%% Quest initialization
steepnesses=1.5:0.1:4;
guessingRates=0.5;
lapseRates=0.01; % formerly 0:0.01:0.04
contrastDB = 20.*transpose(o.psych.t); % transform to dB
% We save time by quantizing to reduce the number of unique contrasts that QUEST must consider.
contrastDB=0.5*round(2*contrastDB); % 0.5 dB quantization
contrastDBUnique=unique(contrastDB);
questData = qpParams('stimParamsDomainList', {contrastDBUnique},...,
                    'psiParamsDomainList',{contrastDBUnique, steepnesses, guessingRates, lapseRates});
questData = qpInitialize(questData);

%% Pour in data
for i = 1:length(contrastDB)
   for trial=1:o.psych.trials(i)
      isRight= trial<=o.psych.right(i);
      questData = qpUpdate(questData, contrastDB(i), isRight+1);
   end
end

%% Estimate Steepness and Threshold
psiParamsIndex = qpListMaxArg(questData.posterior);
psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
if printParameters
   fprintf('Max posterior fit parameters:      log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
      psiParamsQuest(1)/20,psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4));
end
psiParamsFit = qpFit(questData.trialData,questData.qpPF,psiParamsQuest,questData.nOutcomes,...,
   'lowerBounds', [min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
if printParameters
   fprintf('Maximum likelihood fit parameters: log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
      psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
end
o.contrast = 10^(psiParamsFit(1)/20);   % threshold contrast
o.E=o.E1*o.contrast^2;
o.steepness = psiParamsFit(2);          % steepness
o.guessing=psiParamsFit(3);
o.lapse=psiParamsFit(4);

%% Return value
oOut = o;
