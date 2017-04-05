function L=LuminanceOfG(cal,G)
% luminance=LuminanceOfG(cal,G)
% EstimateLuminance uses existing luminance measurements to estimate the
% luminance image that will result from displaying a given G image, where G is the green component of the RGB DAC signal.
% Denis Pelli, NYU, April 4, 2017
% "cal" fields
% cal.old.G is the voltage of the green channel 
% cal.old.L is the luminance measured at that voltage
bad=~isfinite(G)| round(G)>size(cal.gamma,1)-1 |  round(G)<0;
G(bad)=0;
L=G;
L(:)=interp1(cal.old.G,cal.old.L,G(:),'pchip');
L(bad)=nan;
end
