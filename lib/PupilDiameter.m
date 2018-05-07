function [mm,td]=PupilDiameter(L,a,y,e)
% Formula for pupil size (and retinal illuminance) versus luminance
% (cd/m^2), field area (deg^2), age (years), and number of eyes (1 or 2).
% This is the unified formula. Equation 21 from Watson & Yelott.
%
% Andrew B. Watson, John I. Yellott; A unified formula for
% light-adapted pupil size. Journal of Vision 2012;12(10):12. doi:
% 10.1167/12.10.12.
% http://jov.arvojournals.org/article.aspx?articleid=2279420
%
% The following code seems to reproduce Fig. 16a, so I suppose I copied the
% formula correctly.
% L=10 .^(-4:0.5:4);
% a=900*pi;
% y=30;
% e=2;
% PupilDiameter(L,a,y,e);
% semilogx(L,mm);
%
% denis.pelli@nyu.edu

if nargin<4 || isempty(e)
    e=2; % Number of eyes: 1 or 2.
end
if nargin<3 || isempty(y)
    y=30; % Age in years.
end
if nargin<2 || isempty(a)
    a=40^2; % Field area in deg^2.
end
y0=30; % Reference age.
M=[0.1 1]; % Effect of number of eyes on effective luminance.
F=L*a*M(e);
d=Dsd(F,1);
mm=Dsd(F,1)+(y-y0)*(0.02132-0.009562*Dsd(F,1));
td=L.*pi.*(mm/2).^2;
end

function mm=Dsd(L,a)
% Stanley and Davies formula from Watson & Yelott
% Eq. 10.
mm=7.75-5.75*(L*a/846).^0.41./((L*a/846).^0.41+2);
end