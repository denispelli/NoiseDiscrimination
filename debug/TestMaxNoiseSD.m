LMinMeanMax=[0 1 2];
signalNegPos=[-1 1];
sd=MaxNoiseSD('binary',signalNegPos,LMinMeanMax);
fprintf('[%.1f %.1f] [%.1f %.1f %.1f] %.4f\n',signalNegPos,LMinMeanMax,sd);

LMinMeanMax=[0 1 2];
signalNegPos=[0 1];
sd=MaxNoiseSD('binary',signalNegPos,LMinMeanMax);
fprintf('[%.1f %.1f] [%.1f %.1f %.1f] %.4f\n',signalNegPos,LMinMeanMax,sd);

if true
LMinMeanMax=[0 1 2];
signalNegPos=[-1 0];
sd=MaxNoiseSD('binary',signalNegPos,LMinMeanMax);
fprintf('[%.1f %.1f] [%.1f %.1f %.1f] %.4f\n',signalNegPos,LMinMeanMax,sd);

LMinMeanMax=[0 3 5];
signalNegPos=[-1 1];
sd=MaxNoiseSD('binary',signalNegPos,LMinMeanMax);
fprintf('[%.1f %.1f] [%.1f %.1f %.1f] %.4f\n',signalNegPos,LMinMeanMax,sd);

LMinMeanMax=[0 3 5];
signalNegPos=[0 1];
sd=MaxNoiseSD('binary',signalNegPos,LMinMeanMax);
fprintf('[%.1f %.1f] [%.1f %.1f %.1f] %.4f\n',signalNegPos,LMinMeanMax,sd);

LMinMeanMax=[0 3 5];
signalNegPos=[-1 0];
sd=MaxNoiseSD('binary',signalNegPos,LMinMeanMax);
fprintf('[%.1f %.1f] [%.1f %.1f %.1f] %.4f\n',signalNegPos,LMinMeanMax,sd);
end