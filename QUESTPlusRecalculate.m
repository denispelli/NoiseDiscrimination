function oOut = QUESTPlusRecalculate(o)

% Input:         o:      struct of human test data.
% Output:        oOut:   add fields: contrast, steepness, guessing, lapse

% load ~/Dropbox/NoiseDiscrimination/data/criterion2Run-NoiseDiscrimination-darshan.2017.12.31.14.34.39.mat

%% Quest Initialization
contrastDB = 20.*transpose(o.psych.t); % transform to dB
response=o.psych.right + 1;
if length(unique(response))>2
   error(['There are more than 2 response values: ' num2str(unique(response))]);
end
% We can quantize to reduce the number of unique values.
% contrastDB=round(contrastDB); % 1 dB quantization
contrastDBUnique=unique(contrastDB);
questData = qpParams('stimParamsDomainList', {contrastDBUnique},...,
                    'psiParamsDomainList',{contrastDBUnique, 1.5:0.1:4, 0.5, 0:0.01:0.04});
                 % psiParamsDomainList: 20*log c, beta, guess, lapse
questData = qpInitialize(questData);

%% Pour in data
%     questData = qpUpdate(questData, contrastDB, response); 
for i = 1:length(contrastDB)
    %q = qpQuery(questData);
    %fprintf('%d %d\n', q, 20*o.psych.t(i));
%     fprintf('%d %.0f dB, %d\n',i, contrastDB(i), response(i));
    questData = qpUpdate(questData, contrastDB(i), response(i)); 
end

%% Estimate Steepness and Threshold
psiParamsIndex = qpListMaxArg(questData.posterior);
psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
fprintf('Max posterior fit parameters:      log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
    psiParamsQuest(1)/20,psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4));

psiParamsFit = qpFit(questData.trialData,questData.qpPF,psiParamsQuest,questData.nOutcomes,...,
    'lowerBounds', [contrastDB(1) 1.5 0.5 0],'upperBounds',[contrastDB(40) 4 0.5 0.04]);
fprintf('Maximum likelihood fit parameters: log c %0.2f, steepness %0.1f, guessing %0.1f, lapse %0.2f\n', ...
    psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));

o.contrast = 10^(psiParamsFit(1)/20);   % threshold contrast
o.E=o.E1*o.contrast^2;
o.steepness = psiParamsFit(2);          % steepness
o.guessing=psiParamsFit(3);
o.lapse=psiParamsFit(4);
%% Return value
oOut = o;
