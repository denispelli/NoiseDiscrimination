function imageLuminance=EstimateLuminance(cal,image)
% EsimateLuminance use existing luminance measurements to estimate the luminance
% image that will result from displaying a given integer image. The
% estimation includes the effect of quantization by the video DAC, which
% has an integer range from 0 to cal.dacMax.
% Denis Pelli, NYU, July 5, 2014
% "cal" fields
% cal.old.vG is the voltage of the green channel at pixel value cal.old.n
% cal.old.L is the luminance measured at pixel value cal.old.n
% cal.old.n is a monotonic list of pixel values that were calibrated.
% cal.gamma is the new gamma table ready for loading into the CLUT.
imageVG=ones(size(image));
image=round(image);
bad=~isfinite(image)| image>255 |  image<0;
image(bad)=0;
imageVG(:)=cal.gamma(1+image(:),2);
imageVG=round(imageVG*cal.dacMax)/cal.dacMax;
imageLuminance=imageVG;
imageLuminance(:)=interp1(cal.old.vG,cal.old.L,imageVG(:),'pchip');
imageLuminance(bad)=nan;
end
