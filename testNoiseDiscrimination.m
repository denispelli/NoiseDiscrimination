clear o
o.isWin=1; % use the Windows code even if we're on a Mac
o.logLoadNormalizedGammaTable=1; % Keep a log of these calls.
% o.useFractionOfScreen=1;
o.noiseSD=0.2;
o.noiseToTargetRatio=3;
o.noiseHoleToTargetRatio=0; % Typically 1 or 0 (no hole).
o.noiseOnTargetRegardless=0; % 0 (no noise in noise hole) or 1 (put noise on the target, despite any hole).
o.yellowHoleToTargetRatio=inf; % Typically 1, or 2, or inf (for no yellow);
%o.flipClick=1;
o=NoiseDiscrimination(o);
sca;