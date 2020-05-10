function [maxNoiseSD,maxSD]=MaxNoiseSD(noiseType,signalNegPos,LMinMeanMax,nMax1)
% [maxNoiseSD,allSD]=MaxNoiseSD(noiseType[,signalNegPos][,LMinMeanMax][,nMax1]);
%
% MaxNoiseSD returns the highest recommended noiseSD to measure threshold
% contrast for a target (e.g. letter or gabor) against a noise background
% with specified noiseType. As specified by LMinMeanMax, the display's
% luminance range may be asymmetric about the mean, and, as specified by
% signalMinMax, the signal may have an asymmetric range about zero. The
% noise may be any of four: gaussian, uniform, binary, ternary. Everything
% else being equal, maxNoiseSD is 2.3 times higher using binary instead of
% gaussian noise.
%
% ASYMMETRIC SIGNALS. For sinusoids or gabors, signalNegPos=[-1 1]. For
% dark letters signalNegPos=[-1 0] and for bright letters signalNegPos=[0
% 1].
%
% EXAMPLE. I currently has a situation where LMinMeanMax=[0 300 500] 
% to replicate a mean luminance of a previous study with a dufferent
% display. Using a mean lumianance more than half the max affects the max
% noise contrast that I can use differently for bright letters, dark
% letters, or gabors.
%
%% "noiseType" is a string that names the noise distribution.
% 'gaussian' noise has PDF given by a zero-mean true Gaussian clipped at
%            +/-2 SD of the true Gaussian, corresponding to the range
%            [-nMax nMax]. The returned SD is the SD of the clipped
%            distribution.
% 'uniform'  has equal probability density over the range [-nMax nMax].
% 'binary'   has 0.5 probabity at each of [-nMax nMax].
% 'ternary'  has 1/3 probability at each of [-nMax 0 nMax].
%
%% signalNegPos is a two-element array providing the most negative value 
% of the signal (or 0 if none) and the most positive value of the signal
% (or zero if none). The larger absolute value must be 1.
%% LMinMeanMax is a three-element array providing the minimum and maximum 
% luminance the display can render, and the intended mean luminance for the
% image.
%% nMax1 is the fraction of the contrast range to reserve for the noise, 
% leaving 1-nMax1 for the signal. Its default value, 0.37, is based on lots
% of experience with LMinMeanMax=[0 1 2] and signalNegPos=[-1 1].
%
% [~,allSD]=MaxNoiseSD
%
% gaussian: 0.1591
%  uniform: 0.2146
%  ternary: 0.3021
%   binary: 0.3700
%
% denis.pelli@nyu.edu, May 2020

%% PROVIDE DEFAULT VALUES FOR MISSING ARGUMENTS
if nargin<4
    nMax1=0.37; % Rule of thumb based on experience with gaussian.
end
if nargin<3 || isempty(LMinMeanMax)
    LMinMeanMax=[0 1 2];
end
if nargin<2
    signalNegPos=[-1 1];
end
if nargin<1
    noiseType='gaussian';
end

%% CHECK ARGUMENTS
if ~isempty(signalNegPos) && ...
        (length(signalNegPos)~=2 || ...
        signalNegPos(1)>0 || signalNegPos(2)<0 || ...
        max(abs(signalNegPos))~=1)
    error(['signalNegPos, if not empty, ' ...
        'must be a 2 vector that is [negative positive], ' ...
        'and the larger absolute value must be 1.']);
end
if length(LMinMeanMax)~=3 || any(diff(LMinMeanMax)<0)
    error('LMinMeanMax must be empty or a monotonically increasing series of 3 numbers.');
end
if ~isfloat(nMax1) || length(nMax1)~=1
    error('nMax1 must be a positive in the range [0.0 1.0].');
end

%% COMPUTE PERSISTENT TABLE OF NOISE STATS.
persistent sDOverBound;
if isempty(sDOverBound)
    % sDOverBound is ratio of distribution's SD to its +/- bound.
    sDOverBound.gaussian=0.43;
    sDOverBound.uniform=0.58;
    sDOverBound.ternary=std(-1:1,1);
    sDOverBound.binary=std([-1 1],1);
end

%% COMPUTE MAX NOISE SD FOR THE SPECIFIED NOISE TYPE.
% From LMinMeanMax, compute the largest possible negative and positive
% contrasts cNegPos.
cNegPos=(LMinMeanMax([1 3])-LMinMeanMax(2))/LMinMeanMax(2);
% sScalar is the largest multiplier that we can apply to the signal without
% exceeding the display's contrast range. We compute it separately for
% positive and negative contrasts and use the lesser one.
sScalar=min(abs(cNegPos./signalNegPos));
% sNegPos is the range of negative and positive contrasts reserved for the
% signal. We reserve the fraction (1-nMax1) of the max possible, leaving
% the rest for noise.
sNegPos=(1-nMax1)*sScalar*signalNegPos;
% nNegPos is the residual fraction of the contrast range that is available
% for noise.
nNegPos=cNegPos-sNegPos;
% nMax is the largest scalar that we can apply to noise with range [-1 1]
% without exceeding the allowed range nNegPos.
nMax=min(abs(nNegPos));
if ismember(noiseType,fieldnames(sDOverBound))
    maxNoiseSD=nMax*sDOverBound.(noiseType);
else
    error('Unknown noiseType ''%s''.',noiseType);
end

%% COMPUTE MAX NOISE SD FOR ALL NOISE TYPES.
if nargout>1
    for f=fieldnames(sDOverBound)'
        maxSD.(f{1})=nMax*sDOverBound.(f{1});
    end
end

