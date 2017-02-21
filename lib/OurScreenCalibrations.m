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
    cal.machineName=strrep(computer.machineName,'鈄1�7',''''); % work around bug in Screen('Computer')
    cal.osversion=computer.kern.version;
    cal.macModelName=[];
elseif computer.osx || computer.macintosh
    cal.processUserLongName=computer.processUserLongName;
    cal.machineName=strrep(computer.machineName,'鈄1�7',''''); % work around bug in Screen('Computer')
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
    
    if streq(cal.macModelName,'MacBookPro12,1') && cal.screen==0 && cal.screenWidthMm==285 && cal.screenHeightMm==179 && streq(cal.machineName,'UNKNOWN! QUERY FAILED DUE TO EMPTY OR PROBLEMATIC NAME.')
        cal.screenOutput=[]; % used only under Linux
        %cal.profile='';
        cal.ScreenConfigureDisplayBrightnessWorks=1;
        cal.brightnessSetting=1.00;
        cal.brightnessRmsError=0.0000;
        cal.screenRect=[0 0 1280 800];
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='22-Sep-2015 16:30';
        cal.notes='Shivam Verma 406 16:30 Env:50-70cd/m2 MBP13';
        cal.calibratedBy='Shivam Verma';
        cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
        cal.dacMax=(2^cal.dacBits)-1;
        cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
        cal.old.L=[ 1.1 1.2 1.21 1.22 1.3 1.7 2.4 3.7 5.3 7.1 9.6 12.1 15.8 19.5 24.0 29.1 35.8 40.8 48.3 57.1 66.7 77.1 88.0 100.8 114.3 129.5 144.7 162.2 181.0 200.8 223.8 248.5 284.7]; % cd/m^2
    end
    
    if streq(cal.macModelName,'MacBookPro12,1') && cal.screen==0 && cal.screenWidthMm==286 && cal.screenHeightMm==179 && streq(cal.machineName,'UNKNOWN! QUERY FAILED DUE TO EMPTY OR PROBLEMATIC NAME.')
        cal.screenOutput=[]; % used only under Linux
        cal.profile='/Users/Oana/Downloads/Archive/AutoBrightness/ScreenProfile.applescript:3700:3704: execution error: System Events got an error: Can��t get window 1 of process "System Preferences". Invalid index. (-1719)';
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
    
    if streq(cal.macModelName,'MacBookPro12,1') && cal.screen==0 && cal.screenWidthMm==285 && cal.screenHeightMm==179 && streq(cal.machineName,'UNKNOWN! QUERY FAILED DUE TO EMPTY OR PROBLEMATIC NAME.')
        cal.screenOutput=[]; % used only under Linux
        %cal.profile='';
        cal.ScreenConfigureDisplayBrightnessWorks=1;
        cal.brightnessSetting=1.00;
        cal.brightnessRmsError=0.0000;
        cal.screenRect=[0 0 1280 800];
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='22-Sep-2015 16:30';
        cal.notes='Shivam Verma 406 16:30 Env:50-70cd/m2 MBP13';
        cal.calibratedBy='Shivam Verma';
        cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
        cal.dacMax=(2^cal.dacBits)-1;
        cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
        cal.old.L=[ 1.1 1.2 1.21 1.22 1.3 1.7 2.4 3.7 5.3 7.1 9.6 12.1 15.8 19.5 24.0 29.1 35.8 40.8 48.3 57.1 66.7 77.1 88.0 100.8 114.3 129.5 144.7 162.2 181.0 200.8 223.8 248.5 284.7]; % cd/m^2
    end
    
    if IsOSX && streq(cal.macModelName,'MacBookPro12,1') && cal.screen==0 && cal.screenWidthMm==286 && cal.screenHeightMm==179 && streq(cal.machineName,'Kant')
        cal.screenOutput=[]; % used only under Linux
        cal.profile='CIE RGB';
        cal.ScreenConfigureDisplayBrightnessWorks=1;
        cal.brightnessSetting=1.00;
        cal.brightnessRmsError=0.0000;
        % cal.screenRect=[0 0 1280 800];
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='26-Sep-2015 14:32:53';
        cal.notes='Xiuyun MBP new 13 14:31 Env: 28-47cd/m2 Meyer 406';
        cal.calibratedBy='Xiuyun Wu';
        cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
        cal.dacMax=(2^cal.dacBits)-1;
        cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
        cal.old.L=[ 1.154 1.225 1.507 2.279 3.414 5.276 7.461 10.18 13.47 17.46 22.01 27.3 33.04 40.03 46.85 54.35 63.1 71.46 81.58 92.77 104.7 117.2 130.1 142.9 157.2 173.9 190.5 208 226.4 247 265.9 285 308.2]; % cd/m^2
    end
    
    if IsOSX && streq(cal.macModelName,'MacBookAir5,1') && cal.screen==0 && cal.screenWidthMm==260 && cal.screenHeightMm==140 && streq(cal.machineName,'Kant')
        cal.screenOutput=[]; % used only under Linux
        cal.profile='Color LCD';
        cal.ScreenConfigureDisplayBrightnessWorks=1;
        cal.brightnessSetting=1.00;
        cal.brightnessRmsError=0.0000;
        % cal.screenRect=[0 0 1366 768];
        cal.mfilename='CalibrateScreenLuminance';
        cal.datestr='26-Sep-2015 15:07:15';
        cal.notes='Hormet MBA11'' Meyer 406 9/26 15:06 Env.:40-60cd/m2';
        cal.calibratedBy='Hormet Yiltiz';
        cal.dacBits=10; % From ReadNormalizedGammaTable, unverified.
        cal.dacMax=(2^cal.dacBits)-1;
        cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
        cal.old.L=[ 1.991 2.045 2.167 2.557 3.281 4.469 6.667 9.642 12.81 16.58 20.59 25.03 30.38 36.29 43.17 50.17 57.96 65.19 75.67 85.81 97.61 109.2 123.1 137.7 152.1 168.8 185.4 203.4 223.6 246.9 269.5 293.5 332.7]; % cd/m^2
    end
    
else
    
    if IsWin && cal.screen==0 && cal.screenWidthMm==677 && cal.screenHeightMm==381
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
    
    if cal.screen==0 && strcmpi(cal.machineName, 'ThPad')
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
end
if IsOSX && streq(cal.macModelName,'MacBookPro11,3') && cal.screen==0 && cal.screenWidthMm==331 && cal.screenHeightMm==206 && streq(cal.machineName,'Ivy')
    cal.screenOutput=[]; % used only under Linux
    cal.profile='Color LCD';
    cal.ScreenConfigureDisplayBrightnessWorks=1;
    cal.brightnessSetting=1.00;
    cal.brightnessRmsError=0.0000;
    % cal.screenRect=[0 0 1440 900];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='15-Dec-2016 12:47:32';
    cal.notes='Hormet Yiltiz calibrated. Env background luminance: 3-6 cd/m2. Monitor mean lum: 53.06 cd/m2. Noon, with curtains on.';
    cal.calibratedBy='qcao';
    cal.dacBits=12; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 8 16 24 32 40 48 56 64 72 80 88 96 104 112 120 128 135 143 151 159 167 175 183 191 199 207 215 223 231 239 247 255];
    cal.old.L=[ 1.521 1.238 1.999 2.797 4.372 6.234 7.869 10.19 13.19 16.55 20.07 24.71 29.87 34.52 40.84 47.29 53.11 59.82 67.1 75.65 83.49 92.95 103.4 111.5 122 130.4 141.6 153.3 166.5 182.3 194.4 209.4 223]; % cd/m^2
end
if IsLinux && cal.screen==0 && strcmpi(cal.machineName, 'ZBook') %cal.screenWidthMm==508 && cal.screenHeightMm==285
    cal.screenOutput=[]; % used only under Linux
    cal.ScreenConfigureDisplayBrightnessWorks=0;
    cal.brightnessSetting=1.00;
    cal.brightnessRmsError=NaN;
    % cal.screenRect=[0 0 1920 1080];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='17-Dec-2016 17:43:53';
    cal.notes='HYiltiz calibrated HP ZBook 17 G2 Ubuntu 14.04 ATI Bonaire XT (Radeon R9 M280X) GPU, 60Hz, Meyer #956, Environment (background wall) luminance: 53.60 cd/m2. Calibrated with tripods. 64 levels.';
    cal.calibratedBy='';
    cal.dacBits=8; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 131 135 139 143 147 151 155 159 163 167 171 175 179 183 187 191 195 199 203 207 211 215 219 223 227 231 235 239 243 247 251 255];
    cal.old.L=[ 6.275 6.273 6.248 6.47 6.708 6.92 7.378 7.92 8.59 9.348 10.38 11.49 12.79 14.32 16.09 17.89 19.79 21.81 23.92 26.14 28.88 31.58 34.27 37.32 40.65 43.83 47.35 50.8 54.53 58.13 61.86 66.48 71.42 75.24 80.24 85.02 90.65 95.83 100.7 106 111.5 116.9 122.3 128.1 133.7 139.5 145.8 151.9 158.2 165 171.9 179.2 186.5 194.4 202.3 210.5 218.8 227.4 236 244.3 253 261.3 270.4 281.8 299.4]; % cd/m^2
end
if IsLinux && cal.screen==1 && cal.screenWidthMm==361 && cal.screenHeightMm==203 && strcmpi(cal.machineName, 'ThPad')
    cal.screenOutput=[]; % used only under Linux
    cal.ScreenConfigureDisplayBrightnessWorks=0;
    cal.brightnessSetting=1.00;
    cal.brightnessRmsError=NaN;
    % cal.screenRect=[0 0 1366 768];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='20-Dec-2016 19:34:42';
    cal.notes='HYiltiz calibrated ThPad with Debian 8 testing, Linux 4.7.0-1, Octave 4.0.3, Psychtoolbox 3.0.13, Photometer params.: measuring mode (ABS.), RESP. (SLOW), CALIB. (PRESET), at Meyer 957 Workstation, Env luminance background 48.68-39.88cd/m2, viewing distance ~ 70 cm.';
    cal.calibratedBy='';
    cal.dacBits=8; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 131 135 139 143 147 151 155 159 163 167 171 175 179 183 187 191 195 199 203 207 211 215 219 223 227 231 235 239 243 247 251 255];
    cal.old.L=[ 3.623 3.675 3.683 3.688 3.71 3.783 3.903 4.07 4.288 4.555 4.868 5.228 5.645 6.09 6.605 7.158 7.773 8.44 9.165 9.935 10.77 11.63 12.56 13.5 14.54 15.58 16.72 17.85 19.06 20.38 21.73 23.16 24.65 25.93 27.79 29.7 31.74 33.9 36.14 38.54 41.07 43.73 46.49 49.38 52.44 55.69 59.09 62.74 66.48 70.92 75.71 80.69 85.77 91.18 96.43 101.8 107.3 113 118.9 125.1 131.9 139 145.4 150.5 151.1]; % cd/m^2
end
if IsOSX && streq(cal.macModelName,'iMac15,1') && cal.screen==0 && cal.screenWidthMm==541 && cal.screenHeightMm==338 && streq(cal.machineName,'pelliamdimac')
    cal.screenOutput=[]; % used only under Linux
    cal.profile='iMac';
    cal.ScreenConfigureDisplayBrightnessWorks=1;
    cal.brightnessSetting=1.00;
    cal.brightnessRmsError=0.0000;
    % cal.screenRect=[0 0 1280 800];
    cal.mfilename='CalibrateScreenLuminance';
    cal.datestr='20-Feb-2017 18:55:21';
    cal.notes='iMac in lab, feb. 20, room lights on. at night. luminance of drop down screen 36.33 cd/m^2';
    cal.calibratedBy='Denis Pelli';
    cal.dacBits=12; % From ReadNormalizedGammaTable, unverified.
    cal.dacMax=(2^cal.dacBits)-1;
    cal.old.n=[ 0 128 256 384 512 640 768 896 1024 1152 1280 1408 1536 1664 1792 1920 2048 2175 2303 2431 2559 2687 2815 2943 3071 3199 3327 3455 3583 3711 3839 3967 4095];
    cal.old.L=[ 1.732 1.83 2.169 3.018 4.714 7.309 10.25 13.89 18.58 24.04 29.92 36.64 44.47 53.14 62.73 73.03 83.8 93.85 107 122.1 137.4 153.5 169.7 186.3 204.6 223.6 247 271.2 297.7 324.6 353.7 382 406.5]; % cd/m^2
end
