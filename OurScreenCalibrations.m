function cal=OurScreenCalibrations(calRequest)
% cal=OurScreenCalibrations(cal)
% This holds our screen calibrations. Please use CalibrateScreenLuminance
% to add data for your screen to this file.
% Denis Pelli, March 24, 2015


cal=calRequest;
computer=Screen('Computer');
[cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
if IsWin
    cal.processUserLongName=getenv('USERNAME');
    cal.machineName=getenv('USERDOMAIN');
    cal.macModelName=[];
else
    cal.processUserLongName=computer.processUserLongName;
    cal.machineName=strrep(computer.machineName,'â€?',''''); % work around bug in Screen('Computer')
    cal.macModelName=MacModelName;
end
cal.screenOutput=[]; % only for Linux
cal.ScreenConfigureDisplayBrightnessWorks=1; % default value
cal.brightnessSetting=1.00; % default value
cal.brightnessRMSError=0; % default value
if ~isempty(cal.macModelName)
switch cal.macModelName
    case 'MacBookAir4,2'
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='none';
        cal.notes='Not calibrated!';
        cal.calibratedBy='nobody';
        cal.old.n=[     0    16    32    48    64    80    96   112   128   143   159   175   191   207   223   239   255];
        cal.old.L=[   1.5   1.5   3.1   7.4  12.9  19.2  26.4  34.5  43.0  54.2  66.4  80.6  93.4 107.6 119.1 130.8 137.3]; % cd/m^2
    case 'MacBookAir5,1'; % MacBook Air 11"
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='none';
        cal.notes='Not calibrated!';
        cal.calibratedBy='nobody';
        cal.old.n=[     0    16    32    48    64    80    96   112   128   143   159   175   191   207   223   239   255];
        cal.old.L=[   1.5   1.5001   3.1   7.4  12.9  19.2  26.4  34.5  43.0  54.2  66.4  80.6  93.4 107.6 119.1 130.8 137.3]; % cd/m^2
        cal.dacBits=8; % Value from ReadNormalizedGammaTable is misleading.
    case 'MacBookAir6,2'; % MacBook Air 13-inch
        cal.dacBits=8; % Value from ReadNormalizedGammaTable is misleading.
        switch cal.machineName
            case 'Santayana'
                cal.mfilename='CalibrateScreenLuminance';
                cal.datestr='none';
                cal.calibratedBy='Denis';
                cal.notes='Denis''s MacBook Air 13", Santayana. Calibrated by Denis, August 12, 2014.\n';
                cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
                cal.old.L=[ 1.0 1.01 1.1 2.0 3.5 5.7 8.0 12.0 15.5 20.6 25.3 31.8 38.1 40.1 51.7 59.1 73.6 79.8 90.1 101.7 112.0 127.4 139.6 156.0 167.8 183.5 196.5 219.0 232.0 253.0 268.2 287.3 312.1]; % cd/m^2
            otherwise
                cal.mfilename='CalibrateScreenLuminance';
                cal.datestr='none';
                cal.notes='Not calibrated!';
                cal.calibratedBy='nobody';
                cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
                cal.old.L=[ 1.0 1.01 1.1 2.0 3.5 5.7 8.0 12.0 15.5 20.6 25.3 31.8 38.1 40.1 51.7 59.1 73.6 79.8 90.1 101.7 112.0 127.4 139.6 156.0 167.8 183.5 196.5 219.0 232.0 253.0 268.2 287.3 312.1]; % cd/m^2
        end
    case 'MacBookPro9,2'
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='June 2014';
        cal.calibratedBy='Michelle';
        cal.notes='Michelle''s laptop with original gamma. Calibrated by Michelle, June 2014.\n';
        cal.old.n=[     0    16    32    48    64    80    96   112   128   143   159   175   191   207   223   239   255];
        cal.old.L=[   1.5   1.5   3.1   7.4  12.9  19.2  26.4  34.5  43.0  54.2  66.4  80.6  93.4 107.6 119.1 130.8 137.3]; % cd/m^2
    case 'iMac14,1'
        if cal.screen==0
            cal.mfilename='CalibrateScreenLuminance';
            cal.datestr='June 2014';
            cal.calibratedBy='Michelle';
            cal.notes='Laboratory 21.5-inch iMac in room 406. Calibrated by Michelle, June 2014.\n';
            cal.old.n=[     0    16    32    48    64    80    96   112   128   143   159   175   191   207   223   239   255];
            cal.old.L=[   1.5   1.9   3.5   7.7  14.4  22.8  35.7  53.5  70.4  89.6 116.0 136.3 173.2 207.9 241.6 269.8 317.4]; % cd/m^2
        else
            cal.mfilename='CalibrateScreenLuminance';
            cal.datestr='July 2014';
            cal.calibratedBy='Michelle';
            cal.notes='Bright video monitor in room 406. Calibrated by Michelle on July 10, 2014.\n';
            cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
            cal.old.L=[ 4.0 5.9 7.4 9.6 11.6 14.0 16.4 20.1 22.3 26.1 29.6 33.5 38.3 40.6 44.0 49.8 56.1 58.2 65.1 68.2 75.7 82.1 90.7 94.6 104.9 107.0 115.2 123.8 132.1 138.9 141.8 150.7 155.3]; % cd/m^2
        end
    otherwise
        warning('Not a Mac, or Mac unknown!');
end
end

if ~isfield(cal,'datestr')
    % Default values
    cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='none';
    cal.notes='none';
    cal.calibratedBy='nobody';
    cal.dacBits=8; % Assumed value.
    %	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.1 1.2 1.2 1.2 1.3 1.7 2.4 3.7 5.3 7.1 9.6 12.1 15.8 19.5 24.0 29.1 35.8 40.8 48.3 57.1 66.7 77.1 88.0 100.8 114.3 129.5 144.7 162.2 181.0 200.8 223.8 248.5 284.7]; % cd/m^2
end
if streq(cal.macModelName,'MacBookPro9,2') && cal.screen==0 && streq(cal.machineName,'Tiffany''s MacBook Pro')
    cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='23-Mar-2015 19:01:17';
    cal.notes='Tiffany Martin living room lights on. computer screen almost at 90 degree angle sitting on couch';
    cal.calibratedBy='Tiffany Martin';
    cal.dacBits=8; % Assumed value.
    %	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.3 1.2 1.3 1.5 2.2 3.3 5.5 8.1 12.3 15.9 18.9 24.4 28.5 33.9 41.5 45.9 51.0 59.7 67.6 78.7 86.4 96.3 107.3 116.7 129.8 139.2 151.3 160.5 173.9 185.7 199.5 210.2 225.6]; % cd/m^2
end
if streq(cal.macModelName,'MacBookPro9,2') && cal.screen==0 && streq(cal.machineName,'Tiffany''s MacBook Pro')
    cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='03-Apr-2015 19:22:29';
    cal.notes='Tiffany Martin in Denis office, flux off';
    cal.calibratedBy='Tiffany Martin';
    cal.dacBits=8; % Assumed value.
    %	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.2 1.3 1234.0 1.2 1.4 1.6 2.1 2.7 3.4 4.2 5.4 6.6 8.0 9.6 11.4 13.5 16.0 1.9 2.9 24.0 2.4 31.1 34.9 39.1 44.0 4.9 53.8 59.7 65.5 71.5 78.2 85.6 95.3]; % cd/m^2
end
if streq(cal.macModelName,'MacBookPro9,2') && cal.screen==0 && streq(cal.machineName,'Tiffany''s MacBook Pro')
    cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='03-Apr-2015 19:42:49';
    cal.notes='Tiffany in Rm 279 flux off';
    cal.calibratedBy='Tiffany Martin';
    cal.dacBits=8; % Assumed value.
    %	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.1 1.2 1.2 1.2 1.3 1.7 2.4 3.7 5.3 7.1 9.6 12.1 15.8 19.5 24.0 29.1 35.8 40.8 48.3 57.1 66.7 77.1 88.0 100.8 114.3 129.5 144.7 162.2 181.0 200.8 223.8 248.5 284.7]; % cd/m^2
end
if streq(cal.macModelName,'iMac14,1') && cal.screen==0 && streq(cal.machineName,'pellimac')
	cal.screenOutput=[]; % used only under Linux
	cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessReading=1.00;
	cal.brightnessRMSError=0.00; % between settings and readings
	cal.screenRect=[0 0 1280 720];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='11-May-2015 19:21:40';
	cal.notes='denis, in lab (Meyer Hall 406). room lights off. some afternoon daylight ( 7:21 pm may 11). "automatic brightness" disabled.';
	cal.calibratedBy='Denis Pelli';
	cal.dacBits=8; % Assumed value.
	cal.dacBits=10; % From ReadNormalizedGammaTable, verified with visual test.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.13 1.197 1.425 2.005 3.214 5.026 7.316 10.4 14.19 18.7 24.03 29.94 36.8 44.82 53.14 62.17 71.9 81.1 92.19 104.2 117.1 130.7 144.2 159.4 174 190.5 208.2 226.3 245.2 264.9 285.2 305.2 306.3]; % cd/m^2
end
if streq(cal.macModelName,'MacBookAir6,2') && cal.screen==0 && streq(cal.machineName,'Santayana')
    cal.screenOutput=[]; % used only under Linux
    cal.profile='Color LCD';
    cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=0.0000;
	cal.screenRect=[0 0 1440 900];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='14-May-2015 15:52:44';
	cal.notes='denis in lab';
	cal.calibratedBy='Denis Pelli';
	cal.dacBits=8; % Assumed value.
%	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.166 1.166 1.166 1.455 2.239 3.537 5.064 7.393 10.03 13.3 17.46 22.3 27.19 33.52 39.88 46.65 56.27 62.68 72.28 81.93 92.63 106.2 120.2 133.7 149.8 163.3 179.7 199.6 217.8 239.2 257.8 276.8 311]; % cd/m^2
end
if streq(cal.macModelName,'MacBookPro12,1') && cal.screen==0 && streq(cal.machineName,'Nick''s MacBook Pro')
	cal.screenOutput=[]; % used only under Linux
	cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessReading=1.00;
	cal.brightnessRMS=0.00; % between settings and readings
	%cal.screenRect=[0 0 1280 800];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='27-May-2015 17:56:56';
	cal.notes='Calibration was done on 5/27/15 on Nick Blauch''s 13.3 in 2015 MBP in Pelli Lab';
	cal.calibratedBy='Nick Blauch';
	cal.dacBits=8; % Assumed value.
%	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.054 1.088 1.283 1.85 3.417 5.244 7.556 10.18 13.82 17.95 22.64 28.14 34.3 41.6 49.56 57.47 66.82 75.91 86.85 99 111.6 125.7 139.5 154.3 169.8 188.1 206 223.7 243.7 264.9 286.6 310.1 328.1]; % cd/m^2
end
% 
% if cal.screen==0 && cal.screenWidthMm==345 && cal.screenHeightMm==194
% 	cal.screenOutput=[]; % used only under Linux
% 	cal.ScreenConfigureDisplayBrightnessWorks=0;
% 	cal.brightnessSetting=1.00;
% 	cal.brightnessRmsError=NaN;
% 	cal.screenRect=[0 0 1366 768];
% 	cal.mfilename='CalibrateScreenLuminance';
% 	cal.datestr='04-Jul-2015 19:43:51';
% 	cal.notes='Lab 1603 TPY, dusk, with lights off; ThinkPad E50 LCD, HID: MONITOR\LEN40B0, Windows 8.1 64bit, MATLAB R2015a';
% 	cal.calibratedBy='Hormet Yiltiz';
% 	cal.dacBits=8; % Assumed value.
% %	cal.dacBits=8; % From ReadNormalizedGammaTable, unverified.
% 	cal.dacMax=(2^cal.dacBits)-1;
% 	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
% 	cal.old.L=[ 2.88 4.64 6.57 8.93 11.76 14.92 18.09 20.95 25.99 29.1 32.2 36.9 42.09 46 50.12 52.91 55.09 56.52 58.23 62.27 62.06 64.9 69.44 69.95 108.1 108.8 126.4 132.5 138.4 144.2 149.3 153.6 152.6]; % cd/m^2
% end
if cal.screen==0 && cal.screenWidthMm==345 && cal.screenHeightMm==194
	cal.screenOutput=[]; % used only under Linux
	cal.ScreenConfigureDisplayBrightnessWorks=0;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=NaN;
	cal.screenRect=[0 0 1366 768];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='14-Jul-2015 20:23:19';
	cal.notes='Lab 1603 lab room total darkness; ThinkPad E50 LCD, HID: MONITOR\LEN40B0, Windows 8.1 64bit, MATLAB R2015a';
	cal.calibratedBy='';
	cal.dacBits=8; % Assumed value.
%	cal.dacBits=8; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.62 2.53 3.74 5.59 7.73 9.96 12.95 15.77 18.66 22.1 25.65 29.25 33.4 36.06 39.08 44.32 53.4 57.17 63.19 68.05 76.3 84.29 91.73 99.04 106.9 116.5 125.5 134.6 142.4 150.5 157.9 162.5 163.5]; % cd/m^2
end
