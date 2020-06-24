function imageLuminance = LuminanceOfIndex(cal,image)
% imageLuminance = LuminanceOfIndex(cal,image)
% LuminanceOfIndex uses the linear cal mapping to convert color index to
% luminance.
% See also IndexOfLuminance.

image=round(image);
ii=image(:)<cal.nFirst | image(:)>cal.nLast;
if any(ii)
    msg1=sprintf('%d out-of-range pixels (out of %dx%d), with values [',sum(ii),size(image,1),size(image,2));
    msg2=sprintf(' %.0f',unique(image(ii)));
    msg3=sprintf('], were bounded to the range %d to %d.',cal.nFirst,cal.nLast);
    warning('%s%s%s',msg1,msg2,msg3);
    image=min(image,cal.nLast);
    image=max(image,cal.nFirst);
end
if cal.nFirst==cal.nLast
    assert(cal.LFirst == cal.LLast);
    image=double(image);
    imageLuminance=image;
    matches = image==cal.nFirst;
    imageLuminance(matches)=cal.LFirst;
else
    if false
        % Original requires 2 adds and 2 multiplies per pixel.
        imageLuminance=cal.LFirst+(cal.LLast-cal.LFirst)*(double(image)-cal.nFirst)/(cal.nLast-cal.nFirst);
    else
        % Faster version requires only 1 add and 1 multiply per pixel.
        b=(cal.LLast-cal.LFirst)/(cal.nLast-cal.nFirst);
        a=cal.LFirst-cal.nFirst*b;
        imageLuminance=a+b*double(image);
    end
end

