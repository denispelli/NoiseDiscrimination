function maxNoiseSD=MaxNoiseSD(noiseType)
%% MAX SD OF EACH NOISE TYPE
% With the same bound on range, we can reach 3.3 times higher noiseSD using
% binary instead of gaussian noise. In the code below, we use steps of
% 2^0.5=1.4, so I increase max noiseSD by a factor of 2^1.5=2.8 when using
% binary noise.
persistent maxSD
if isempty(maxSD)
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

