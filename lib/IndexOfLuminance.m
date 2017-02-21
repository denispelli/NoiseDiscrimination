function image = IndexOfLuminance(cal,imageLuminance)
% image = IndexOfLuminance(cal,imageLuminance)
% IndexOfLuminance uses the calibration to convert luminance to color
% index.
% See also LuminanceOfIndex.

image=cal.nFirst+(cal.nLast-cal.nFirst)*(imageLuminance-cal.LFirst)/(cal.LLast-cal.LFirst);
image=round(image);
ii=image(:)<cal.nFirst | image(:)>cal.nLast;
if any(ii)
    msg1=sprintf('%.0f out-of-range pixels, with values [',sum(ii));
    msg2=sprintf(' %.0f',unique(image(ii)));
    msg3=sprintf('], were bounded to the range %d to %d.',cal.nFirst,cal.nLast);
    warning('%s%s%s',msg1,msg2,msg3);
    image=min(image,cal.nLast);
    image=max(image,cal.nFirst);
end
end

