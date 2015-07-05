function E = IdealE(p,n,corr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% cal.vG=interp1(cal.old.L,cal.old.vG,cal.L,'pchip'); % (takes 100 ms) interpolate green voltage vG at luminance L
if nargin<1
    p=0.5;
end
if nargin<2
    n=1;
end
if nargin<3
    corr=0;
end
E = fzero(@(E) p-IdealP(E,n,corr),20);
end

