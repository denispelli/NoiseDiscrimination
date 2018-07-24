function [mm,td]=PupilDiameter(L,a,y,e)
% Formula for pupil diameter mm (and retinal illuminance td) versus
% luminance (cd/m^2), field area (deg^2), age (years), and number of eyes
% (1 or 2). This is the unified formula. Equation 21 from Watson & Yelott
% (2012).
%
% A.B. Watson & J.I. Yellott (2012) A unified formula for light-adapted
% pupil size. Journal of Vision 12(10):12. doi: 10.1167/12.10.12.
% http://jov.arvojournals.org/article.aspx?articleid=2279420
%
% As a check, the following code seems to reproduce their Fig. 16a, so I
% suppose I copied their formula correctly.
% L=10 .^(-4:0.5:4);
% a=900*pi;
% y=30;
% e=2;
% mm=PupilDiameter(L,a,y,e);
% semilogx(L,mm);
% xlabel('Luminance (cd/m^2)');
% ylabel('Pupil diameter (mm)');
%
% denis.pelli@nyu.edu

if nargin<4 || isempty(e)
    e=2; % Default number of eyes.
end
assert(ismember(e,1:2),'Number of eyes e must be 1 or 2.');
if nargin<3 || isempty(y)
    y=30; % Default age in years.
end
assert(y>=0,'Age y must be positive.');
if nargin<2 || isempty(a)
    a=40^2; % Default field area in deg^2.
end
if nargin<1 || isempty(L)
    error('The first argument, L, is required.');
end
switch e % Effect of number of eyes on effective luminance.
    case 1
        F=L*a/10;
    case 2
        F=L*a;
end
mm=Dsd(F,1);
y0=30; % Reference age.
% Effect of age on pupil size.
mm=mm+(y-y0)*(0.02132-0.009562*mm);
td=L.*pi.*(mm/2).^2;
end

function mm=Dsd(L,a)
% Stanley and Davies formula from Watson & Yellott 2012
% Eq. 10.
mm=7.75-5.75*(L*a/846).^0.41 ./ ((L*a/846).^0.41+2);
end