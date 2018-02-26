function predictedProportions = qpPFCrowding(stimParams,psiParams)
%qpPFCrowding  cdf psychometric function for effect of flanker contrast on
%identification of the target.
%
% Usage:
%     predictedProportions = qpPFCrowding(stimParams,psiParams)
%
% Description:
%     Compute the proportions of each outcome for the psychometric
%     function. We assume a detection psychometric function for the
%     flanker, with the specified threshold and steepness, but zero
%     guessing and lapse. Then we assume that when the flanker is detected,
%     the observer identifies with rate "guess", and when flanker is not
%     detected, identifies with rate nearly 1, except for lapses.
%
% Input:
%     stimParams     Matrix, with each row being a vector of stimulus parameters.
%                    Here the row vector is just a single number giving
%                    the stimulus contrast level in dB.  dB defined as
%                    20*log10(x).
%
%     psiParams      Row vector pr matrix of parameters
%                      threshold  Threshold in dB
%                      slope      Slope
%                      guess      Guess rate
%                      lapse      Lapse rate
%                    Parameterization matches the Mathematica code from the
%                    Watson QUEST+ paper. If this is passed as a matrix,
%                    must have same number of rows as stimParams and the
%                    parameters are used from corresponding rows. If it is
%                    passed as a row vector, that vector is taken as the
%                    parameters for each stimulus row.
%
% Output:
%     predictedProportions  Matrix, where each row is a vector of predicted proportions
%                           for each outcome.
%                             First entry of each row is for no/incorrect (outcome == 1)
%                             Second entry of each row is for yes/correct (outcome == 2)
%
% Optional key/value pairs
%     None

% 6/27/17  dhb  Wrote it.

%% Parse input
%
% This routine gets called many many times and should be as fast as
% possible.  The input parser is slow.  So we forego arg checking and
% optional key/value pairs.  The code below shows how they would look.
%
% p = inputParser;
% p.addRequired('stimParams',@isnumeric);
% p.addRequired('psiParams',@isnumeric);
% p.parse(stimParams,psiParams,varargin{:});

%% Here is the Matlab version
if size(psiParams,2) ~= 4
   error('Parameters vector has wrong length for qpPFCrowding');
end
if size(stimParams,2) ~= 1
   error('Each row of stimParams should have only one entry');
end
threshold = psiParams(:,1);
slope = psiParams(:,2);
guess = psiParams(:,3);
lapse = psiParams(:,4);
nStim = size(stimParams,1);
predictedProportions = zeros(nStim,2);

%% Compute, handling the two calling cases.
if length(threshold)>1
   if length(threshold) ~= nStim
      error('Number of parameter vectors passed is not one and does not match number of stimuli passed');
   end
   for ii = 1:nStim
      p = 1-exp(-10^(slope(ii)*(stimParams(ii) - threshold(ii))/20));
      p = lapse(ii)*guess(ii)+(1-lapse(ii))*(1-(1-guess(ii))*p);
      predictedProportions(ii,:) = [1-p p];
   end
else
   for ii = 1:nStim
      p = 1-exp(-10^(slope*(stimParams(ii) - threshold)/20));
      p = lapse*guess+(1-lapse)*(1-(1-guess)*p);
      predictedProportions(ii,:) = [1-p p];
   end
end