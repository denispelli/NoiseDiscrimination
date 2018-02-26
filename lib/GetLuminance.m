function L=GetLuminance
% L=GetLuminance;
% Measure luminance in cd/m^2.
% Uses the Cambridge Research Systems ColorCAL II XYZ colorimeter. This
% device consists of a photocell with a USB cable that you plug into your
% computer.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/
%
% ColorCal2 throws a fatal error if the device is not attached. You can
% protect against that by wrapping this call in a try-catch block.
%
% If you want the new reading to be unaffected by prior luminances, i find
% i need to allow 5 s for the device to settle at the new luminance before
% taking a reading. i'm measuring tiny changes (luminance quantization in
% the display), so i need very high precision. i think i'm getting at least
% 16-bit precision.
%
% Under macOS, occasionally the HID software used to access the device gets
% confused and gives an alarming fatal error. Typing "clear all" or "clear
% PsychHID" will clear the problem by flushing the HID driver, so it's
% reloaded the next time you use it.
%
% Denis Pelli 2018
persistent CORRMAT
if isempty(CORRMAT)
   % Get ColorCAL II XYZ correction matrix.
   % CORRMAT contains three correction matrices. Choose one.
   % CRT=1:3; WLED LCD=4:6; OLED=7:9
   CORRMAT=ColorCal2('ReadColorMatrix');
end
s=ColorCal2('MeasureXYZ');
XYZ=CORRMAT(4:6,:)*[s.x s.y s.z]';
L=XYZ(2);