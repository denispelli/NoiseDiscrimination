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
% When using qpUpdate (not our pqUpdateOnly), we could save time by
% quantizing to reduce the number of unique contrasts that QUEST must
% consider. 
% contrastDB=0.5*round(2*contrastDB); % 0.5 dB quantization
contrastDBUnique=unique(contrastDB);
questData = qpParams('stimParamsDomainList', {contrastDBUnique},...,
   'psiParamsDomainList',{contrastDBUnique, steepnesses, guessingRates, lapseRates});
questData = qpInitialize(questData);

%% Pour in data
for i = 1:length(contrastDB)
   for trial=1:o.psych.trials(i)
      isRight= trial<=o.psych.right(i);
%       questData = qpUpdate(questData, contrastDB(i), isRight+1);
            questData = qpUpdateOnly(questData, contrastDB(i), isRight+1);
   end
end

%% Estimate steepness and threshold contrast.
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
o.E=o.E1*o.contrast^2;                  % threshold energy
o.steepness = psiParamsFit(2);          % steepness
o.guessing=psiParamsFit(3);
o.lapse=psiParamsFit(4);

%% Return value
oOut = o;
end

function questData = qpUpdateOnly(questData,stim,outcome,varargin)
% qpUpdateOnly  Update just the trial data in the questData structure for
% the trial stimulus and outcome. We save time by not computing entropies,
% as in the original qpUpdate.
%
% Usage:
%     questData = qpUpdateOnly(questData,stim,outcome)
%
% Description:
%     Update the questData strucgure given the stimulus and outcome of
%     a trial.  Computes the new likelihood of the whole data stream given
%     the stimulus/outcomes so far, updates the posterior, ...
%
% Input:
%     questData       questData structure before the trial.
%
%     stim            Stimulus parameters on trial (row vector).  Must be contained in
%                     questData.stimParamsDomain, otherwise an error is thrown.
%
%     outcome         What happened on the trial.
%
% Output:
%     questData       Updated questData structure.  This adds and/or keeps up to date the following
%                     fields of the questData structure.
%                       trialData - Trial data array, a struct array containing stimulus and outcome for each trial.
%                         Initialized on the first call and updated thereafter. This has subfields for both stimulus
%                         and outcome.
%                       stimIndices - Index into stimulus domain for stimulus used on each trial.  This can be useful
%                         for looking at how much and which parts of the stimulus domain were used in a run.
%                       logLikelihood - Updated for trial outcome.
%                       posterior - Update for trial outcome.
%                       entropyAfterTrial - The entropy of the posterior after the trail. Initialized on the first
%                         call and updated thereafter.
%                       expectedNextEntropiesByStim - Updated for trial outcome.
%
% Optional key/value pairs
%   None
%

%% Get stimulus index from stimulus
stimIndex = qpStimToStimIndex(stim,questData.stimParamsDomain);
if (stimIndex == 0)
   error('Trying to update with a stimulus outside the domain');
end

%% Check for legal outcome
if (round(outcome) ~= outcome | outcome < 1 | outcome > questData.nOutcomes)
   error('Illegal value provided for outcome, given initialization');
end

%% Add trial data to list
%
% Create first element of the array if necessary.
if (isfield(questData,'trialData'))
   nTrials = length(questData.trialData);
   questData.trialData(nTrials+1,1).stim = stim;
   questData.trialData(nTrials+1,1).outcome = outcome;
   questData.stimIndices(nTrials+1,1) = stimIndex;
else
   nTrials = 0;
   questData.trialData.stim = stim;
   questData.trialData.outcome = outcome;
   questData.stimIndices = stimIndex;
end
questData.posterior = qpUnitizeArray(questData.posterior .* squeeze(questData.precomputedOutcomeProportions(stimIndex,:,outcome))');
end