function maxNoiseSD=MaxNoiseSD(noiseType)
% maxNoiseSD=MaxNoiseSD(noiseType);
% This returns the value of SD for the given kind of noise that will just
% barely respect the bounds [-maxBound maxBound]. With the same bound on
% range, we can reach 3.3 times higher noiseSD using binary instead of
% gaussian noise.
% "Gaussian" noise has PDF given by a zero-mean true Gaussian clipped at
% +/-2 SD of true Gaussian. The returned SD is the SD of the clipped
% distribution. Uniform has equal probability density over the range
% [-maxBound maxBound]. Binary has 0.5 probabity at each of [-maxBound
% maxBound]. Ternary has 1/3 probability at each of [-maxBound 0 maxBound].
persistent maxSD
if isempty(maxSD)
    % sDOverBound is ratio of distribution's SD over its +/- bound.
    sDOverBound.gaussian=0.43;
    sDOverBound.uniform=0.58;
    sDOverBound.binary=std([-1 1]);
    sDOverBound.ternary=std(-1:1);
    maxBound=0.37; % Rule of thumb based on experience with gaussian.
    maxSD=struct('gaussian',maxBound*sDOverBound.gaussian,...
        'uniform',maxBound*sDOverBound.uniform,...
        'binary',maxBound*sDOverBound.binary,...
        'ternary',maxBound*sDOverBound.ternary);
end
if ~ismember(noiseType,{'gaussian' 'binary' 'ternary' 'uniform'})
    error('Unknown noiseType ''%s''.',noiseType);
end
maxNoiseSD=maxSD.(noiseType);

