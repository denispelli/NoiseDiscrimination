function L=GetLuminance
% L=GetLuminance
% Measure luminance (cd/m^2).
% Cambridge Research Systems ColorCAL II XYZ Colorimeter.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/nest/product-support
persistent CORRMAT
if isempty(CORRMAT)
   % Get ColorCAL II XYZ correction matrix (CRT=1; WLED LCD=2; OLED=3):
   CORRMAT=ColorCal2('ReadColorMatrix');
end
s = ColorCal2('MeasureXYZ');
XYZ = CORRMAT(4:6,:) * [s.x s.y s.z]';
L=XYZ(2);
end
