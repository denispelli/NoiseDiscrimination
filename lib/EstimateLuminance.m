function imageLuminance=EstimateLuminance(cal,image)
% luminance=EstimateLuminance(cal,image)
% EstimateLuminance uses existing luminance measurements to estimate the
% luminance image that will result from displaying a given integer image.
% The estimation includes the effect of quantization by the video DAC,
% which has an integer range from 0 to cal.dacMax.
% Denis Pelli, NYU, July 5, 2014
% "cal" fields
% cal.old.vG is the voltage of the green channel at pixel value cal.old.n
% cal.old.L is the luminance measured at pixel value cal.old.n
% cal.old.n is a monotonic list of pixel values that were calibrated.
% cal.gamma is the new gamma table ready for loading into the CLUT.
% cal.dacBits is the number of bits used in the digital to analog
%      converter.
imageG=ones(size(image));
image=round(image);
bad=~isfinite(image)| round(image)>size(cal.gamma,1)-1 |  round(image)<0;
image(bad)=0;
imageG(:)=cal.gamma(1+image(:),2);
dacMax=2^cal.dacBits-1;
imageG=round(imageG*dacMax)/dacMax;
imageLuminance=imageG;
imageLuminance(:)=interp1(cal.old.G,cal.old.L,imageG(:),'pchip');
imageLuminance(bad)=nan;
end
