function cal=OurScreenCalibrations(screen)
% cal=OurScreenCalibrations(screen)
% This holds our screen calibrations. Please use CalibrateScreenLuminance
% to add data for your screen to this file. If you'll send the resulting
% file to me, I'll add your screen calibration to the master copy of
% OurScreenCalibrations.m, so you can use the master copy of the software.
% Denis Pelli, March 24, 2015, July 28, 2015.
if nargin>0
    cal.screen=screen;
else
    cal.screen=0;
end
screenBufferRect=Screen('Rect',cal.screen); 
screenRect=Screen('Rect',cal.screen,1); 
% Detect HiDPI mode, e.g. on a Retina display.
% resolution=Screen('Resolution',cal.screen);
cal.hiDPIMultiple=RectWidth(screenRect)/RectWidth(screenBufferRect);
cal.dualResRetinaDisplay=cal.hiDPIMultiple~=1;


% cal=calRequest;
computer=Screen('Computer');
[cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
if computer.windows
    cal.processUserLongName=getenv('USERNAME');
    cal.machineName=getenv('USERDOMAIN');
    cal.macModelName=[];
elseif computer.linux
    cal.processUserLongName=getenv('USER');
    cal.machineName=strrep(computer.machineName,'閳�',''''); % work around bug in Screen('Computer')
    cal.osversion=computer.kern.version;
    cal.macModelName=[];
elseif computer.osx || computer.macintosh
    cal.processUserLongName=computer.processUserLongName;
    cal.machineName=strrep(computer.machineName,'閳�',''''); % work around bug in Screen('Computer')
    cal.macModelName=MacModelName;
end
cal.screenOutput=[]; % only for Linux
cal.ScreenConfigureDisplayBrightnessWorks=1; % default value
cal.brightnessSetting=1.00; % default value
cal.brightnessRMSError=0; % default value

[savedGamma,cal.dacBits]=Screen('ReadNormalizedGammaTable',cal.screen);
cal.dacMax=(2^cal.dacBits)-1;


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
    case 'MacBookAir6,2'; % MacBook Air 13-inch
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
end
if ~isfield(cal,'datestr')
    % Default values
    cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='none';
    cal.notes='none';
    cal.calibratedBy='nobody';
    cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.1 1.2 1.21 1.22 1.3 1.7 2.4 3.7 5.3 7.1 9.6 12.1 15.8 19.5 24.0 29.1 35.8 40.8 48.3 57.1 66.7 77.1 88.0 100.8 114.3 129.5 144.7 162.2 181.0 200.8 223.8 248.5 284.7]; % cd/m^2
end
if streq(cal.macModelName,'MacBookPro9,2') && cal.screen==0 && streq(cal.machineName,'Tiffany''s MacBook Pro')
    cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='23-Mar-2015 19:01:17';
    cal.notes='Tiffany Martin living room lights on. computer screen almost at 90 degree angle sitting on couch';
    cal.calibratedBy='Tiffany Martin';
    cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
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
    cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
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
    cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
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
% 	cal.screenRect=[0 0 1280 720];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='11-May-2015 19:21:40';
	cal.notes='denis, in lab (Meyer Hall 406). room lights off. some afternoon daylight ( 7:21 pm may 11). "automatic brightness" disabled.';
	cal.calibratedBy='Denis Pelli';
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
	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
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
	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.054 1.088 1.283 1.85 3.417 5.244 7.556 10.18 13.82 17.95 22.64 28.14 34.3 41.6 49.56 57.47 66.82 75.91 86.85 99 111.6 125.7 139.5 154.3 169.8 188.1 206 223.7 243.7 264.9 286.6 310.1 328.1]; % cd/m^2
end
if streq(cal.macModelName,'iMac15,1') && cal.screen==0 && cal.screenWidthMm==599 && cal.screenHeightMm==340 && streq(cal.machineName,'pelliamdimac')
	cal.screenOutput=[]; % used only under Linux
	cal.profile='iMac';
	cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=0.0000;
% 	cal.screenRect=[0 0 2560 1440];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='29-Jul-2015 09:23:36';
	cal.notes='Jacob Altholz, New iMac Callibration, Lights off, one shade closed';
	cal.calibratedBy='Lab';
	cal.dacBits=12; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.484 1.566 1.915 2.775 4.495 7.151 10.17 13.9 18.7 24.33 30.36 37.29 45.37 54.36 64.31 75.22 86.43 97.1 110.7 126.2 142.1 158.2 175 192.1 210.9 231.4 254.6 280.9 307 334.1 364.4 393.2 420.2]; % cd/m^2
end
if streq(cal.macModelName,'MacBookAir4,2') && cal.screen==0 && streq(cal.machineName,'Rose')
	cal.screenOutput=[]; % used only under Linux
%	cal.profile='osascript: /Users/scotopic/Documents/MATLAB/noisediscrimination-software: No such file or directory';
	cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=0.0000;
% 	cal.screenRect=[0 0 1440 900];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='01-Jun-2015 16:59:38';
	cal.notes='Jacob Altholz 6/1/15';
	cal.calibratedBy='Jacob Altholz';
	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 0.787 0.97 1.115 1.469 2.162 3.278 4.727 6.758 9.371 12.52 15.78 20.35 25.18 30.33 36.81 43.8 51.34 59.55 70.46 80.43 91.12 102.4 116.9 130.9 144.7 162.1 178.3 197.6 216.4 235.3 258.9 282.6 324.5]; % cd/m^2
end
if streq(cal.macModelName,'MacBookPro11,5') && cal.screen==0 && cal.screenWidthMm==331 && cal.screenHeightMm==206 && streq(cal.machineName,'Denis''s MacBook Pro 5K')
    cal.screenOutput=[]; % used only under Linux
    cal.profile='Color LCD';
    cal.ScreenConfigureDisplayBrightnessWorks=1;
    cal.brightnessSetting=1.00;
    cal.brightnessRmsError=0.0000;
    % cal.screenRect=[0 0 1440 900];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='30-Jul-2015 11:19:40';
    cal.notes=' Jacob Altholz, Michelle''s Desk in the office';
    cal.calibratedBy='Lab';
    cal.dacBits=12; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.071 1.14 1.472 2.504 3.761 6.023 8.715 11.57 15.2 19.59 24.7 30.54 37.1 44.48 52.54 61.46 70.72 80.14 91.5 103.8 117 130.8 145.3 159.7 175.6 193.3 211.6 231.7 252.8 274.9 298.5 320.9 348.9]; % cd/m^2
end
if streq(cal.macModelName,'iMac15,1') && cal.screen==0 && cal.screenWidthMm==602 && cal.screenHeightMm==341 && streq(cal.machineName,'pelliamdimac')
	cal.screenOutput=[]; % used only under Linux
	cal.profile='iMac';
	cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=0.0000;
	% cal.screenRect=[0 0 1600 900];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='28-Aug-2015 17:45:04';
	cal.notes='calibration done by Michelle Qiu at 5:45 PM on August 28, 2015';
	cal.calibratedBy='Lab';
	cal.dacBits=12; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.24 1.242 1.613 2.506 4.349 7.091 10.01 13.89 19.21 24.71 30.47 36.86 45.06 55.14 63.33 74.51 88.68 97.94 110.9 123.4 146.8 157.7 182.6 192.8 211.7 242.2 249.2 292 315.7 346.1 374.2 387.6 426.1]; % cd/m^2
end

if streq(cal.macModelName,'MacBookPro12,1') && cal.screen==0 && cal.screenWidthMm==286 && cal.screenHeightMm==179 && streq(cal.machineName,'UNKNOWN! QUERY FAILED DUE TO EMPTY OR PROBLEMATIC NAME.')
	cal.screenOutput=[]; % used only under Linux
	cal.profile='/Users/Oana/Downloads/Archive/AutoBrightness/ScreenProfile.applescript:3700:3704: execution error: System Events got an error: Can’t get window 1 of process "System Preferences". Invalid index. (-1719)';
	cal.ScreenConfigureDisplayBrightnessWorks=1;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=0.0000;
	% cal.screenRect=[0 0 1280 800];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='22-Sep-2015 16:17:17';
	cal.notes='Oana Meyer 406 16:15 Env:50-70cd/m2 MBP13';
	cal.calibratedBy='Oana Daniela Dumitru';
	cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 1.3 1.449 1.584 2.362 3.446 5.096 7.153 9.688 12.77 16.54 20.8 25.77 25.75 37.64 41.51 51.28 59.53 67.29 76.88 87.17 98.6 110 122.4 134.7 147.8 163.9 178.7 195 211.9 230.5 248.8 266.4 283.3]; % cd/m^2
end

else
    
if IsWin && cal.screen==0 && cal.screenWidthMm==677 && cal.screenHeightMm==381
    disp('hi');
	cal.screenOutput=[]; % used only under Linux
	cal.ScreenConfigureDisplayBrightnessWorks=0;
	cal.brightnessSetting=1.00;
	cal.brightnessRmsError=NaN;
	% cal.screenRect=[0 0 1920 1080];
	cal.mfilename='CalibrateScreenLuminance';
	cal.datestr='21-Sep-2015 18:03:19';
	cal.notes='Xiuyun Dell 15'' Win7 Meyer406 18:00 With Lights Env 25-35cd/m2';
	cal.calibratedBy='';
	cal.dacBits=8; % From ReadNormalizedGammaTable, unverified.
	cal.dacMax=(2^cal.dacBits)-1;
	cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
	cal.old.L=[ 3.718 3.729 3.892 4.15 5.052 6.079 7.317 8.909 11.08 13.8 17.46 21.6 26.55 32.12 38.17 44.51 52.07 58.17 66.44 74.86 85.2 94.96 106.8 119.4 132.9 148.7 165.8 181.9 201.5 221.1 241.6 265.1 287.2]; % cd/m^2
end
end
