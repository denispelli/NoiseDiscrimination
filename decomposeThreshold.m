function [obs ideal] = decomposeThreshold(obsFile, idealFile)
% the _runs_ files is simply a table created by reading in many runs (output of
% NoiseDiscrimination) We read in the obsFile (a _runs_ file), then introduce
% the experiment control variables as a set of condition variables for this
% subject. Then, using this conditions, we look for matching conditions from
% a dataset obtained by an ideal observer; the conditions for the ideal observer
% can be a superset of observer's conditoins. For specific conditions that are
% missing a matching ideal data, we simply run the ideal for that condition,
% so that, after generating a new _run_ for ideal that includes the previously
% run data, that missing condition no longer persists. To tolarate some minuscle
% differences of condition parameter values due to different experiment hardware
% condition, we use a cost function to decide a condition match, rather than
% exact match. Last, we look for the observer's baseline data (no noise).
% Once we have these, we can decomopse thresholds into equivalent noise and
% efficiency.
%
% Hormet Yiltiz, 2016
% Copyright 2016
% GNU GPLv3+

if nargin < 2
  obsFile = './results/hty/HTY_runs_201658.mat';
  obsFile = './results/krish/krish_runs_201659.mat';
  obsFile = './results/xiuyun_rawData/analysis/xiuyun_runs_201659.mat';
  
  idealFile = './results/ideal_runs_201641.mat';
  idealFile = './results/ideal_runs_20160505.mat';
  idealFile = './results/ideal_runs_20160509.mat';
end

isExactMatch = 1;
isColectIdeal = 0;
isCollectObserver = 0;
isWriteToDisk = 1;

% experiment conditions and their weighst for cost-function based matching
% Deg based conditions are compared in the logarithmic scale
conditionsCell = {'targetSize', 10; 'noiseContrast', 10; 'noiseDecayRadius', 10; 'noiseRadiusDeg', 2; 'eccentricity', 10; 'noiseSpectrum', 10; 'noiseCheckDeg', 10; 'targetKind', 10}; % absolute difference compared against 1
dataCell = {'noisePowerSpectralDensity', 'thresholdEnergy', 'energyAtUnitContrast', 'thresholdLogContrast', 'pAccuracy', 'logEbyN'};


obs = load(obsFile);
ideal = load(idealFile);

obs.name = cell2mat(regexprep(regexp(obsFile,'[^/]*_runs_', 'match'), '_runs_', ''));
obs.tabdata = sortrows(obs.tabdata,{'targetSize', 'eccentricity'});
ideal.tabdata = sortrows(ideal.tabdata,{'targetSize', 'eccentricity'});

[obs.dataTable, obs.conditionTable, obs.missingBaselineTable] = collapser(obs.tabdata, conditionsCell, dataCell, obs.tabdata, isExactMatch);
[ideal.dataTable, ideal.conditionTable, ideal.missingBaselineTable] = collapser(ideal.tabdata, conditionsCell, dataCell, obs.tabdata, isExactMatch);

missingIdealsIndex = ideal.dataTable.nRuns<1;
if sum(missingIdealsIndex)>0
  warning('decomopseThreshold:idealMissing', 'You have %d ideal conditions missing! Printed below.', sum(missingIdealsIndex));
  disp(ideal.dataTable(ideal.dataTable.nRuns<1,:));
  if isColectIdeal; dataCollector(ideal.dataTable(ideal.dataTable.nRuns<1,:), 'ideal');end
end


if size(obs.missingBaselineTable,1)>0
  warning('decomopseThreshold:baselineMissing', 'You have %d baseline conditions missing! Printed below.', size(obs.missingBaselineTable,1));
  disp(obs.missingBaselineTable);
  if isCollectObserver
    observer = input('Going to collect missing baseline conditions. Type in your observer name below:\n', 's');
    missingTable = repmat(obs.missingBaselineTable,[2 1]);
    missingTable = missingTable(randperm(size(missingTable,1)),:); % randomize
    %     dataCollector(missingTable, observer);
  end
end


% now calculate Neq and efficiency
obs.dataTable.meanThreshold = cellfun(@(x) mean(10.^x), obs.dataTable.thresholdLogContrast);
obs.dataTable.sdThreshold = cellfun(@(x) std(10.^x), obs.dataTable.thresholdLogContrast);

% only these can have Neq
validIndex = cellfun(@(x) sum(x)>0, obs.dataTable.matchingBaselineIndex);
Neq = cellfun(@(N, E, E0) N.* mean(E0) ./(E - mean(E0)), obs.dataTable.noisePowerSpectralDensity(validIndex), obs.dataTable.thresholdEnergy(validIndex), obs.dataTable.thresholdEnergy(cell2mat(obs.dataTable.matchingBaselineIndex(validIndex))), 'UniformOutput', false);
% above cellfun line for Neq equals to the below for loop
% Neq = cellfun(@(N, E, E0Index) N.* mean(obs.dataTable.thresholdEnergy{E0Index}) ./(E - mean(obs.dataTable.thresholdEnergy{E0Index})), obs.dataTable.noisePowerSpectralDensity(validIndex), obs.dataTable.thresholdEnergy(validIndex), obs.dataTable.matchingBaselineIndex(validIndex), 'UniformOutput', false);
% a = obs.dataTable.noisePowerSpectralDensity(validIndex);
% for i=1:numel(a)
%   try
%     N = obs.dataTable.noisePowerSpectralDensity(validIndex); N=N{i};
%     E = obs.dataTable.thresholdEnergy(validIndex); E=E{i};
%     E0Index = obs.dataTable.matchingBaselineIndex(validIndex); E0Index=E0Index{i};
%     Neq{i} = N.* mean(obs.dataTable.thresholdEnergy{E0Index}) ./(E - mean(obs.dataTable.thresholdEnergy{E0Index}))
%   catch
%     keyboard
%   end
% end
obs.dataTable.Neq = repmat({NaN},size(obs.dataTable,1),1); % missing data are NaN
obs.dataTable.Neq(validIndex) = Neq; % can get multiple Neq for each noise condition using mean baseline
obs.dataTable.meanNeq = cellfun(@(x) mean(x), obs.dataTable.Neq);
obs.dataTable.sdNeq = cellfun(@(x) std(x), obs.dataTable.Neq);



Efficiency = cellfun(@(Eideal, E, E0) mean(Eideal) ./(E - mean(E0)), ideal.dataTable.thresholdEnergy(validIndex), obs.dataTable.thresholdEnergy(validIndex), obs.dataTable.thresholdEnergy(cell2mat(obs.dataTable.matchingBaselineIndex(validIndex))), 'UniformOutput', false);
obs.dataTable.Efficiency = repmat({NaN},size(obs.dataTable,1),1); % missing data are NaN
obs.dataTable.Efficiency(validIndex) = Efficiency; % can get multiple Efficiency for each noise condition using mean baseline
obs.dataTable.meanEfficiency = cellfun(@(x) mean(x), obs.dataTable.Efficiency);
obs.dataTable.sdEfficiency = cellfun(@(x) std(x), obs.dataTable.Efficiency);

obs.idealDataTable = ideal.dataTable; % include the ideal as well

% now export
if isWriteToDisk
  nonCellFieldIndex = cellfun(@(x) isnumeric(obs.dataTable.(x)), fieldnames(obs.dataTable));
  exportedFields = nonCellFieldIndex | strcmp('hardOrSoft', fieldnames(obs.dataTable)); % hardOrSoft is cell, but needs export
  mkdir('results/');
  exportFileName = ['results/' obs.name '_conditions_' datestr(now, 'YYYYmmddHHMM')];
  writetable(obs.dataTable(:,exportedFields), [exportFileName '.csv'], 'Delimiter',',');
  save([exportFileName '.mat'], '-struct', 'obs');
  fprintf('Decomposed data table exported as:\n%s\n%s\n', [exportFileName '.csv'], [exportFileName '.mat']);
end

% disp('Congrats!')

end


%% Helper functions

function [dataTable, conditionTable, missingBaselineTable] = collapser(dataIn, conditionsCell, dataCell, conditionSeed, isExactMatch)
warning('off', 'MATLAB:table:RowsAddedNewVars');

dataIn.noiseDecayRadius(dataIn.noiseContrast==0)=0;
dataIn.noiseRadiusDeg(dataIn.noiseContrast==0)=0;
dataIn.noiseCheckDeg(dataIn.noiseContrast==0)=0;
conditionSeed.noiseDecayRadius(conditionSeed.noiseContrast==0)=0;
conditionSeed.noiseRadiusDeg(conditionSeed.noiseContrast==0)=0;
conditionSeed.noiseCheckDeg(conditionSeed.noiseContrast==0)=0;

% use costs instead!
%dataIn.noiseDecayRadius(dataIn.noiseDecayRadius>32)=32;
%dataIn.noiseRadiusDeg(dataIn.noiseRadiusDeg>32)=32;
%conditionSeed.noiseDecayRadius(conditionSeed.noiseDecayRadius>32)=32;
%conditionSeed.noiseRadiusDeg(conditionSeed.noiseRadiusDeg>32)=32;

conditionsCost = cell2mat(conditionsCell(:,2));
conditionsCell = conditionsCell(:,1)';
conditionIndex = cellfun(@(x) find(strcmp(x,fieldnames(dataIn))),conditionsCell,'UniformOutput', true);

% any condition that doesn't say noise
baselineInConditionsIndex = cellfun(@(x) isempty(x),regexp(conditionsCell, '.*noise.*')); % use in conditionTable
baselineConditionCell = conditionsCell(baselineInConditionsIndex);
baselineConditionIndex = cellfun(@(x) find(strcmp(x,fieldnames(dataIn))),baselineConditionCell,'UniformOutput', true); % use in dataTable

conditionsArray = [];
for iCell = conditionsCell
  % base conditions only on the observer data, not ideal data
  conditionsArray = [conditionsArray conditionSeed.(iCell{1})];
end
conditionTable = array2table(unique(conditionsArray, 'rows'),'VariableNames',conditionsCell);
dataTable = conditionTable;
% record comes later
dataTable.isGlobalNoise = NaN(size(dataTable(:,1),1),1);
dataTable.noiseR = NaN(size(dataTable(:,1),1),1);
dataTable.hardOrSoft = cell(size(dataTable(:,1),1),1);

for iDataCell=dataCell
  dataTable.(iDataCell{1})= cell(size(dataTable,1),1);
end
dataIndex = cellfun(@(x) sum(strcmp(dataCell,x))==1,fieldnames(dataTable),'UniformOutput', true);


% now fill in the data
for iCondition = 1:size(conditionTable,1)
  repeatedRunsIndex = matcher(dataIn{:,conditionIndex}, conditionTable{iCondition,:}, conditionsCost, isExactMatch);
  dataTable.nRuns(iCondition) = sum(repeatedRunsIndex); % pad in number of runs (condition repititions)

  baselineGroupConditionIndex = all(conditionTable{:,baselineInConditionsIndex} == repmat(conditionTable{iCondition,baselineInConditionsIndex}, size(conditionTable,1),1),2);
  % baselineGroupRunIndex = all(dataIn{:,baselineConditionIndex} == repmat(conditionTable{iCondition,baselineInConditionsIndex}, size(dataIn,1),1),2);
  baselineGroupIndex = baselineGroupConditionIndex;
  matchingBaselineIndex = find(baselineGroupIndex & dataTable.noiseContrast==0)';
  if isempty(matchingBaselineIndex)
    % we found a missing baseline!
    matchingBaselineIndex = -1;
  end
  dataTable.matchingBaselineIndex(iCondition) = {matchingBaselineIndex};

  [noiseR, isGlobalNoise, hardOrSoft] = getNoiseRadius(dataTable(baselineGroupIndex,:));
  dataTable.noiseR(baselineGroupIndex) = noiseR;
  dataTable.isGlobalNoise(baselineGroupIndex) = isGlobalNoise;
  dataTable.hardOrSoft(baselineGroupIndex) = hardOrSoft;

  for iDataCell=dataCell
    dataTable.(iDataCell{1})(iCondition) = {dataIn{repeatedRunsIndex,iDataCell{1}}'};
  end
end

% baseline conditions does not need an index for baseline; record as NaN
dataTable.matchingBaselineIndex(dataTable.noiseContrast==0) = repmat({NaN}, size(dataTable.matchingBaselineIndex(dataTable.noiseContrast==0)));

missingBaselineIndex = cellfun(@(x) numel(x)==1 && x==-1, dataTable.matchingBaselineIndex);
missingBaselineTable = unique(dataTable(missingBaselineIndex,baselineInConditionsIndex),'rows');

end % collapser

%%
function repeatedRunsIndex = matcher(dataConditions, currentCondition, conditionsCost, isExactMatch)
if isExactMatch
  repeatedRunsIndex = all(dataConditions == repmat(currentCondition, size(dataConditions,1),1),2);
else
  % compare in log scale: targetSize, eccentricity, radii
  dataConditions(:,[1 3 4 5]) = log10(dataConditions(:,[1 3 4 5])+1);
  currentCondition([1 3 4 5]) = log10(currentCondition([1 3 4 5])+1);
  repeatedRunsIndex = abs(dataConditions - repmat(currentCondition, size(dataConditions,1),1)) * conditionsCost < 1;
  if sum(dataConditions(:,1) > 15 & dataConditions(:,2) > 0 & dataConditions(:,4) > 13) > 0
    keyboard
  end
end
end % matcher

%%
function [noiseR, isGlobalNoise, hardOrSoft] = getNoiseRadius(groupDataTable)
% find out the global noise condition
%     % for soft noise: noiseDecayRadius is manipulated while noiseRadiusDeg is the maximum viewing angle of the physical display
%     % for hard noise: noiseRadiusDeg   is manipulated while noiseDecayRadius is Inf
noiseR = NaN(size(groupDataTable,1),1);
hardOrSoft = cell(size(groupDataTable,1),1);
for iCondition = 1:size(groupDataTable,1)
  if groupDataTable.noiseContrast(iCondition) == 0
    % no noise condition
    hardOrSoft{iCondition} = '';
    noiseR(iCondition) = 0;
  elseif isinf(groupDataTable.noiseDecayRadius(iCondition))
    assert(isfinite(groupDataTable.noiseRadiusDeg(iCondition)));
    hardOrSoft{iCondition} = 'hard';
    noiseR(iCondition) = groupDataTable.noiseRadiusDeg(iCondition); % noise radius
  elseif isfinite(groupDataTable.noiseDecayRadius(iCondition)) && groupDataTable.noiseRadiusDeg(iCondition) > 0
    hardOrSoft{iCondition} = 'soft';
    noiseR(iCondition) = groupDataTable.noiseDecayRadius(iCondition);
  else
    warning('decomposeThreshold:getNoiseRadius:mixedHardSoftNoiseTrials', 'Cannot distinguish noise type for this set of conditions!');
    disp(unique(conditionTable(baselineGroupIndex,:),'rows'));
    warning('Dropping to console, try to debug/fix the above issue:');
    keyboard
  end
end
%relativeRToTargetSize = noiseR ./ groupDataTable.targetSize;
% if sum(abs(groupDataTable.targetSize -4) < 0.3 & abs(groupDataTable.eccentricity -16) < 0.3)>0
%   keyboard
% end
if numel(noiseR) == 1
  if noiseR > 0
    isGlobalNoise = 1;
  elseif noiseR == 0
    isGlobalNoise = 0;
  else
    warning('wow, you saw a Unicorn!');keyboard;
  end
else
  isGlobalNoise = ismember(noiseR, grpstats(noiseR, hardOrSoft, @max));
  if isempty(isGlobalNoise); isGlobalNoise = 0;end % when it only has baselines
end

end

%%
function dataCollector(missingT, observer)

o.observer=observer;
o.weightIdealWithNoise=0;
o.distanceCm=50; % viewing distance
o.durationSec=0.2;
o.trialsPerBlock=1e4;

%For noise with Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For noise with tophat envelope (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

% ############# we test target size x ecc w/o noise #######
o.targetHeightDeg=8; % letter/gabor size [2 4 8].
o.eccentricityDeg=0; % eccentricity [0 16 32]
o.noiseSD=0.16; % noise contrast [0 0.16]
% We want to compare these:
o.noiseCheckDeg=o.targetHeightDeg/20;
%o.noiseCheckDeg=o.targetHeightDeg/40;
% #########################################################

o.targetKind='letter';

o.noiseEnvelopeSpaceConstantDeg=32; % always Inf for hard edge top-hat noise
% o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]
o.noiseRadiusDeg=inf;

o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
% o.fixationCrossBlankedNearTarget=0; % always present fixation

o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.

o.speakInstructions=0;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.

for i = 1:size(missingT,1)
  o.targetHeightDeg = missingT.targetSize(i);
  o.noiseSD = missingT.noiseContrast(i);
  o.noiseEnvelopeSpaceConstantDeg=missingT.noiseDecayRadius(i);
  o.noiseRadiusDeg=missingT.noiseRadiusDeg(i);
  o.eccentricityDeg=missingT.eccentricity(i);
  %   o.targetKind = 'letter'
  o.noiseCheckDeg=o.targetHeightDeg/20;

  o = NoiseDiscrimination(o);
end

end

