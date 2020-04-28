function image = IndexOfLuminance(cal,imageLuminance)
% image = IndexOfLuminance(cal,imageLuminance); 
%
% IndexOfLuminance uses the calibration to convert luminance to color index. 
%
% See also LuminanceOfIndex. 

% Use plusMinusChar instead of literal plus-minus sign to prevent
% corruption of this non-ASCII character.
plusMinusChar=char(177); 
image=cal.nFirst+(cal.nLast-cal.nFirst)*...
    (imageLuminance-cal.LFirst)/(cal.LLast-cal.LFirst);
image=round(image);
ii=image(:)<cal.nFirst | image(:)>cal.nLast;
if any(ii)
    msg0=sprintf(['Contrast too high? '...
        'Luminances %dx%dx%d (mean%csd %.1f%c%.1f), sd/mean %.1f, '...
        'ranging %.1f to %.1f ' ...
        'exceed linearized range %.1f to %.1f cd/m^2. '],...
       size(imageLuminance,1),size(imageLuminance,2),size(imageLuminance,3),...
       plusMinusChar,mean(imageLuminance(:)),plusMinusChar,std(imageLuminance(:)),...
       std(imageLuminance(:))/mean(imageLuminance(:)),...
       min(imageLuminance(:)),max(imageLuminance(:)),cal.LFirst,cal.LLast);
    msg1=sprintf('%.0f out-of-range pixels, with values [',sum(ii));
    msg2=sprintf(' %.0f',unique(image(ii)));
    msg3=sprintf('], were bounded to the range %d to %d.',cal.nFirst,cal.nLast);
    warning('IndexOfLuminance: %s',[msg0 msg1 msg2 msg3]);
    image=min(image,cal.nLast);
    image=max(image,cal.nFirst);
end
end

