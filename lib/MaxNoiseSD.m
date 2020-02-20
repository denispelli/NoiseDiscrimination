function [maxNoiseSD,allSD]=MaxNoiseSD(noiseType,maxBound)
% [maxNoiseSD,allSD]=MaxNoiseSD(noiseType [,maxBound]);
% Returns the value of SD, for the given kind of noise, that will just
% barely respect the bounds [-maxBound maxBound]. With the same bound on
% range, we can reach 3.3 times higher noiseSD using binary instead of
% gaussian noise.
%
% "noiseType": 'gaussian' noise has PDF given by a zero-mean true Gaussian
% clipped at +/-2 SD of true Gaussian. The returned SD is the SD of the
% clipped distribution. 'uniform' noise has equal probability density over
% the range [-maxBound maxBound]. 'binary' has 0.5 probabity at each of
% [-maxBound maxBound]. 'ternary' has 1/3 probability at each of [-maxBound
% 0 maxBound].
%
% "maxBound": The default values of maxBound, 0.37, is based on lots of
% experience and has worked well.
%
% SUMMARY:
% gaussian: 0.1591
%  uniform: 0.2146
%  ternary: 0.3700
%   binary: 0.5233
%
% denis.pelli@nyu.edu, February 2020
if nargin<2
    maxBound=0.37; % Rule of thumb based on experience with gaussian.
end
persistent maxSD
if isempty(maxSD)
    % sDOverBound is ratio of distribution's SD over its +/- bound.
    sDOverBound.gaussian=0.43;
    sDOverBound.uniform=0.58;
    sDOverBound.ternary=std(-1:1);
    sDOverBound.binary=std([-1 1]);
    maxSD=struct('gaussian',maxBound*sDOverBound.gaussian,...
        'uniform',maxBound*sDOverBound.uniform,...
        'ternary',maxBound*sDOverBound.ternary,...
        'binary',maxBound*sDOverBound.binary);
end
if ~ismember(noiseType,{'gaussian' 'uniform' 'ternary' 'binary'})
    error('Unknown noiseType ''%s''.',noiseType);
end
maxNoiseSD=maxSD.(noiseType);
allSD=maxSD;