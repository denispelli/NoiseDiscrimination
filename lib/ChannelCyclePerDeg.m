function [cyclePerDeg,gaborDeg]=ChannelCyclePerDeg(deg,strokePerLetter,targetGaborCycles)
% [cyclePerDeg,gaborDeg]=ChannelCyclePerDeg(deg);
% Formula from Majaj et al. (2002).
if nargin<2
    strokePerLetter=1.6; % Sloan.
end
strokePerDeg=strokePerLetter/deg;
cyclePerDeg=10*(strokePerDeg/10)^(2/3);
if nargin<3
    targetGaborCycles=3;
end
gaborDeg=targetGaborCycles/cyclePerDeg;
end

% data=struct([]);
% for deg=[0.25 0.5 2 8 32]
%     [cyclePerDeg,gaborDeg]=ChannelCyclePerDeg(deg)
%     data(end+1).letterDeg=deg;
%     data(end).cyclePerDeg=cyclePerDeg;
%     data(end).gaborDeg=gaborDeg;
% end
% t=struct2table(data)