function CalibrateScreenLuminance(screen,screenOutput)
% This will calibrate the luminance of your screen. This is often called
% "gamma" calibration, because in the days of CRTs a power law with
% exponent "gamma" was often used to describe the relation of screen
% luminance to input voltage. Before starting calibration, make sure your
% screen is at maximum brightness, by repeatedly pressing the keyboard
% "brighter" key (labeled with a sunburst), or use the System
% Preferences:Displays and push the brightness slider all the way to the
% right. It's important to maintain the lighting conditions of the computer
% screen in the room when you test people. The angle of viewing matters
% too, so you should have the photometer look at the screen from the same
% direction that the observers will. Please minimize incident light falling
% on the screen, but don't make the room dark, because that's tiring.
% Results will be appended to "OurScreenCalibrations.m".
% Denis Pelli, March 23, 2015
%
% See also LinearizeClut, ourScreenCalibrations, testLuminanceCalibration,
% testGammaNull, IndexOfLuminance, LuminanceOfIndex.

% Photometers that report in cd/m^2 tend to be expensive. However, there
% are very cheap apps that run on an iPhone and report luminance in EV
% units. EV (exposure value) units are a photographers term, and are
% relative to a film speed. From two web pages I have the impression that
% if one set the film speed to ISO 100, then luminance L (cd/m^2) can be
% computed from the EV reading as
% L = 2^(EV-3)
% http://www.sekonic.com/downloads/l-408_english.pdf
% https://www.resna.org/sites/default/files/legacy/conference/proceedings/2010/Outcomes/Student%20Papers/HilderbrandH.html
% To facilitate use of such cheap light meters, I've added an EV mode to
% the program, allowing you to specify each luminance in EV units.

% For Mac OSX, Apple says, on a portable/desktop computer: Press the F1/F14 key to
% decrease the brightness, and press the F2/F15 key to increase the
% brightness.
% Intenet comment: If you have a second display, note that ctrl-F1 and
% ctrl-F2 usually change the brightness on the other display (or external
% display) on OS X 10.7.

% From nick.peatfield@gmail.com May 9, 2015
% dimmer.scpt:
% tell application "System Events"
%         key code 107
%     end tell
%
% brighter.scpt:
% tell application "System Events"
%         key code 113
%     end tell
%
% Add the script to the Matlab path. Run this Matlab command to dim the
% built-in screen:
% system('osascript dimmer.scpt')
% Run this to brighten it:
% system('osascript brighter.scpt')
% For max brightness, run the script 16 times.

% Me: Does anyone know how to control or read the Mac OSX brightness
% setting from within MATLAB?
% Mario: Current PTB has this:
% [oldBrightness]=Screen('ConfigureDisplay','Brightness', screenId [,outputId][,brightness]);
% E.g.,
% Screen('ConfigureDisplay', 'Brightness',0,0,0.25)
% sets the brightness of the display on screen 0 to 25% and returns the
% old value. This is supported on OSX and Linux, but not on Windows.
% screenId and outputId are interchangeable on OSX, because on OSX Screen
% == Output, whereas on Linux outputId would set/get the brightness on a
% given video output "outputId" for a given X-Screen "screenId". Iow., on
% OSX you could leave one out [] or set both to the same value. Range is
% 0.0 - 1.0. This controls the display backlight brightness on supported
% displays, like the brightness keys do. E.g., it works on the MacBooks,
% probably also on iMac's, but there isn't a guarantee it will work on
% non-Apple displays or non-builtin Apple displays. However, there isn't
% any high level api for this and bits of the low level api we use has been
% marked as "deprecated, will be removed in a future OSX version, there is
% no replacement" since OSX 10.9. So it works on current OSX versions if it
% works at all for your display, but could already be gone forever with the
% next major OSX update, together with some other low level features in the
% general area of fine display control. Just as on OSX, on Linux support
% for brightness is display specific - works with some displays but not
% with others.
% http://osxdaily.com/2010/05/15/stop-the-macbook-pro-and-macbook-screen-from-dimming/
addpath('lib');
addpath('AutoBrightness');
try
    Speak('Welcome to Calibrate Screen Luminance.');
    fprintf('This program uses computer speech. Please turn up the volume to hear it.\n');
%     onCleanupInstance=onCleanup(@()sca); % clears screen when function is terminated.
    if nargin>1
        cal.screenOutput=screenOutput; % used only under Linux
    else
        cal.screenOutput=[]; % used only under Linux
    end
    if nargin>0
        cal.screen=screen;
    else
        cal.screen=max(Screen('Screens'));
    end
    KbName('UnifyKeyNames'); % Needed to work on Windows computer.
    blindCalibration=0;
    luminances=32+1;
    %     luminances=3; % for quick debugging
    using10bpc=false;
    gamma10bpc=1/2.4;
    [cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
    % screenRect=Screen('Rect',cal.screen); % gives unreliable answer on
    % Retina display
    
    cal.pixelMax=255;
    fprintf('\n%s %s\n',mfilename,datestr(now));
    fprintf('Calibrate luminance.\n');
    if IsOSX %|| IsLinux
        if ~ScriptingOkShowPermission
            error('Please give MATLAB permission to control the computer. You''ll need admin privileges to do this.');
        end
        cal.profile=ScreenProfile(cal.screen); % Get name of current profile.
        % Now select some other profile.
        ScreenProfile(cal.screen,'Apple RGB');
        ScreenProfile(cal.screen,'CIE RGB'); % At least one of these two profiles will not be the original profile.
        ScreenProfile(cal.screen,cal.profile); % Freshly load the original profile.
        AutoBrightness(0); % Disable Apple's automatic adjustment of brightness
        cal.autoBrightnessDisabled=1;
        fprintf('Now checking your screen brightness control.\n');
        Speak('Now checking your screen brightness control');
        cal.brightnessSetting=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
        desiredBrightness=[(0:4)/4 cal.brightnessSetting];
        for i=1:length(desiredBrightness)
            Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,desiredBrightness(i));
            brightness(i)=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
        end
        cal.brightnessRmsError=rms(desiredBrightness-brightness);
        if cal.brightnessRmsError>0.01
            fprintf('WARNING: Screen ConfigureDisplay Brightness not available for this screen. RMS error %.3f\n',cal.brightnessRmsError);
            cal.ScreenConfigureDisplayBrightnessWorks=0;
        else
            cal.ScreenConfigureDisplayBrightnessWorks=1;
            fprintf('Screen ConfigureDisplay Brightness works.\n');
        end
    else
        cal.ScreenConfigureDisplayBrightnessWorks=0;
        cal.brightnessRmsError=nan;
    end
    fprintf('When using a flat-panel display, we usually run at maximum "brightness".\n');
    if cal.ScreenConfigureDisplayBrightnessWorks
        fprintf('Your display is currently at %.0f%% brightness.\n',100*cal.brightnessSetting);
        b=[];
        while ~isfloat(b) || length(b)~=1 || b<0 || b>100
            Speak('We usually run at 100% brightness. What percent brightness do you want?');
            Speak('Please type a number from 0 to 100, followed by return.');
            b=input('What brightness percentage do you want (0 to 100)?');
        end
        cal.brightnessSetting=b/100;
        Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
        brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
        if abs(cal.brightnessSetting-brightnessReading)>0.01
            fprintf('Brightness was set to %.0f%%, but now reads as %.0f%%.\n',100*cal.brightnessSetting,100*brightnessReading);
            sca;
            Speak('Error. The screen brightness changed during calibration. In System Preferences Displays please turn off "Automatically adjust brightness".');
            error('Screen brighness changed during calibration. In System Preferences:Displays, please turn off "Automatically adjust brightness".');
        end
    else
        cal.brightnessSetting=1;
        cal.brightnessReading=nan;
        Speak('Please set your screen to maximum brightness, then hit return');
        fprintf('Please set your screen to maximum brightness.\n');
        input('Hit return when ready to proceed:\n');
    end
    
    % Get the gamma table.
    [cal.old.gamma,cal.dacBits]=Screen('ReadNormalizedGammaTable',cal.screen,cal.screenOutput);
    cal.old.gammaIndexMax=length(cal.old.gamma)-1; % index into gamma table is 0..gammaIndexMax.

    % Make sure it's a good gamma table.
    cal.old.gammaHistogramStd=std(histcounts(cal.old.gamma(:,2),10,'Normalization','probability'));
    macStd=[0.0005  0.0082  0.0085  0.0111  0.0123  0.0683 0.0082];
    if cal.old.gammaHistogramStd > max(macStd);
       fprintf(['CalibrateScreenLuminance: Probably this is not an Apple profile.\n'...
          'We suggest that you use Apple:System preferences:Displays:Color:Display profile:\n'...
          'to select another profile and then reselect the profile you want. The \n'...
          'histogram of your display''s current color profile (or "gamma table") is very uneven,\n' ...
          'which suggest that it''s custom-made by the user, not supplied by the manufacturer.  \n'...
          'For calibration, it''s best to save one of the manufacturer''s original gamma tables\n'...
          'in the calibration record. We use it later to achieve a consistent white at all \n'...
          'luminances. Please ask our computer''s operating system to load a manufacturer-\n'...
          'supplied color profile. In macOS, use System Preferences:Displays:Color.\n'...
          'The profile you choose will determine only the precise color cast of white.\n'...
          'The gamma function produced by our software is independent of the profile \n'...
          'you select. Only the shade of white is affected. Then try again to run \n'...
          'CalibrateScreenLuminance.\n']);
       Speak(['ERROR: To get a consistent white in your stimuli, please use System Preferences '...
          'Displays Color to select a color profile that you like. Then try again.']);
       error('YOur gamma table seems custom-made. Please use an official color profile.\n');
    end
    fprintf('Successfully read your gamma table ("color profile").\n');
    
    useEV=0;
%     response='x';
%     Speak('What units will you use for luminance? Type E or C');
%     while ~ismember(response,{'e','c'})
%         response=input('What units will you use to specify luminance? Type   e (for EV)   or c (for cd/m^2) followed by return:','S');
%         response=lower(response);
%     end
%     useEV= response=='e';
    if useEV
        luminanceUnitWords='exposure value EV';
        luminanceUnit='EV';
    else
        luminanceUnitWords='candelas per meter squared';
        luminanceUnit='cd/m^2';
    end
    fprintf(['Thanks. You will enter luminances in units of ' luminanceUnit '\n']);
    if useEV
        Speak('Please set the film speed to ISO 100 on your light meter. Then hit return to continue.');
        fprintf('IMPORTANT: Please set the film speed to ISO 100 on your light meter.\n');
        x=input('Hit return to continue:','S');
    end
    fprintf('We will create a linearized gamma table that you can save for future use with this display.\n');
    computer=Screen('Computer');
    if isfield(computer,'processUserLongName')
        cal.processUserLongName=computer.processUserLongName;
    else
        cal.processUserLongName='';
    end
    if isfield(computer,'machineName')
        cal.machineName=strrep(computer.machineName,'’','''');  % work around bug in Screen('Computer')
    else
        cal.machineName='';
    end
    if ismac
        cal.macModelName=MacModelName;
    else
        cal.macModelName='Not-a-mac';
    end
    screenRect=Screen('Rect',cal.screen);
    fprintf('Computer %s, %s, screenWidthCm %.1f, screenHeightCm %.1f\n',prep(cal.machineName),prep(cal.macModelName),cal.screenWidthMm/10,cal.screenHeightMm/10);
    Speak(sprintf('We will now measure %d luminances.',luminances));
    Speak(['Use a photometer to measure the screen luminance in ' luminanceUnitWords '.  Then type your reading followed by return.']);
    Speak('If you make a mistake, you can go back by typing -1, followed by return.');
    Screen('Preference', 'SkipSyncTests', 1);
    cal.useRetinaResolution=0;
    if ~using10bpc
        [window,screenRect]=Screen('OpenWindow',cal.screen,[],[],[],[],[],0);
    else
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
        PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
        [window,screenRect]=PsychImaging('OpenWindow', cal.screen, 0, []);
        PsychColorCorrection('SetEncodingGamma', window, gamma10bpc);
    end
    white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
    fprintf('white %0.1f\n',white);
    i=0;
    while i<luminances
        i=i+1;
        Screen('FillRect',window,white/2,screenRect);
        rect=CenterRect(screenRect/2,screenRect);
        % The index is volatile (dependent on gamma table). The dac value
        % G is robust.
        cal.old.n(i)=round(cal.pixelMax*(i-1)/(luminances-1));
        cal.old.G(i)=cal.old.gamma(round(1+cal.old.n(i)*cal.old.gammaIndexMax/cal.pixelMax),2);
        Screen('FillRect',window,white*cal.old.n(i)/cal.pixelMax,rect);
        Screen('TextFont',window,'Verdana');
        Screen('TextSize',window,20);
        Screen('Flip',window,0,1); % Calibration: Show test patch and instructions.
        if blindCalibration
            msg=sprintf('%d of %d.',i,luminances);
            Screen('DrawText',window,msg,10,screenRect(4)-200);
            msg=sprintf(['Please measure luminance (' luminanceUnit ') and type it in, followed by <return>:_____']);
            Screen('DrawText',window,msg,10,screenRect(4)-150);
            msg=sprintf('For example "1.1" or "10". The screen is frozen. Just type blindly and wait to hear it.');
            Screen('DrawText',window,msg,10,screenRect(4)-100);
            msg=sprintf('If you hear a mistake, don''t worry. Typing -1 will erase the last entry.');
            Screen('DrawText',window,msg,10,screenRect(4)-50);
            Screen('Flip',window,0,1); % Calibration: Show test patch and instructions.
            echo off all
            s=input('','s');
            x=sscanf(s,'%f');
            if isempty(x)
                Speak('Invalid. Try again.');
                i=i-1;
                continue;
            else
                if useEV
                    cal.old.L(i)=2^(x-3); % Convert EV to cd/m^2, assuming film speed is ISO 100.
                else
                    cal.old.L(i)=x;
                end
            end
            if cal.old.L(i)<0
                Speak('Erasing one setting.');
                i=i-2;
                continue;
            end
            Speak(sprintf('%g',cal.old.L(i)));
        else
            msg=sprintf(['%d of %d. Please typed measured luminance (' luminanceUnit '), followed by <return>:'],i,luminances);
            ListenChar(2); % suppress echoing of keyboard in Command Window
            n=[];
            while 1
                n=GetEchoNumber(window,msg,10,screenRect(4)-40,0,255/2);
                % n=GetEchoNumber(window,msg,10,screenRect(4)-40,0,255/2,1); % external keyboard
                if ~isfloat(n) || length(n)~=1
                    Speak('Invalid. Try again.');
                else
                    Speak(sprintf('%g',n));
                    break;
                end
            end
            if useEV
                cal.old.L(i)=2^(n-3); % Convert EV to cd/m^2, assuming film speed is ISO 100.
            else
                cal.old.L(i)=n;
            end
            if cal.old.L(i)<0
                Speak('Erasing one setting.');
                i=i-2;
                continue;
            end
            ListenChar; % restore keyboard echoing
        end
        if cal.ScreenConfigureDisplayBrightnessWorks
            cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
            if abs(cal.brightnessSetting-cal.brightnessReading)>0.01
                fprintf('Brightness was set to %.0f%%, but now reads as %.0f%%.\n',100*cal.brightnessSetting,100*cal.brightnessReading);
                sca;
                Speak('Error. The screen brightness changed during calibration. In System Preferences, Displays, please turn off "Automatically adjust brightness".');
                error('Screen brighness changed during calibration. In System Preferences:Displays, please turn off "Automatically adjust brightness".');
            end
        end
    end
    Screen('CloseAll');
    ShowCursor;
    sca;
    if cal.ScreenConfigureDisplayBrightnessWorks
        cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
        fprintf('Brightness still set to %.0f%%, now reads as %.0f%%.\n',100*cal.brightnessSetting,100*cal.brightnessReading);
        Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,1);
    end
    fprintf('\n\n\n');
    Speak('Thank you. Please wait for the Command Window to reappear, then please type notes, followed by return.');
    fprintf('\n'); % Not sure, but this FPRINTF may be needed under Windows to make INPUT work right.
    cal.notes=input('Please type one line about conditions of this calibration, including your name.\nYour notes:','s');
    filename='OurScreenCalibrations.m';
    fprintf('Appending this calibration data to %s.\n',filename);
    mypath=fileparts(mfilename('fullpath'));
    fullfilename=fullfile(mypath,'lib', filename);
    fid=fopen(fullfilename,'a+');
    for f=[1,fid]
        fprintf(f,'if ');
        if IsWin
            fprintf(f,'IsWin && ');
        end
        if IsLinux
            fprintf(f,'IsLinux && ');
        end
        if IsOSX
            fprintf(f,'IsOSX && ');
        end
        if ismac
            fprintf(f,'streq(cal.macModelName,''%s'') && ',prep(cal.macModelName));
        end
        fprintf(f,'cal.screen==%d',cal.screen);
        fprintf(f,' && cal.screenWidthMm==%g && cal.screenHeightMm==%g',cal.screenWidthMm,cal.screenHeightMm);
        if ismac
            fprintf(f,' && streq(cal.machineName,''%s'')',prep(cal.machineName));
        end
        fprintf(f,'\n');
        if length(cal.screenOutput)==1
            fprintf(f,'\tcal.screenOutput=%.0f; %% used only under Linux\n',cal.screenOutput);
        else
            fprintf(f,'\tcal.screenOutput=[]; %% used only under Linux\n',cal.screenOutput);
        end
        if ismac
            fprintf(f,'\tcal.profile=''%s'';\n',cal.profile);
        end
        fprintf(f,'\tcal.ScreenConfigureDisplayBrightnessWorks=%.0f;\n',cal.ScreenConfigureDisplayBrightnessWorks);
        fprintf(f,'\tcal.brightnessSetting=%.2f;\n',cal.brightnessSetting);
        fprintf(f,'\tcal.brightnessRmsError=%.4f;\n',cal.brightnessRmsError);
        cal.screenRect=screenRect;
        fprintf(f,'\t%% cal.screenRect=[%d %d %d %d];\n',cal.screenRect);
        fprintf(f,'\tcal.mfilename=''%s'';\n',mfilename);
        fprintf(f,'\tcal.datestr=''%s'';\n',datestr(now));
        fprintf(f,'\tcal.notes=''%s'';\n',prep(cal.notes));
        fprintf(f,'\tcal.calibratedBy=''%s'';\n',prep(cal.processUserLongName));
        fprintf(f,'\tcal.dacBits=%d; %% From ReadNormalizedGammaTable.\n',cal.dacBits);
        fprintf(f,'\tcal.old.gammaIndexMax=%d;\n',cal.old.gammaIndexMax);
        fprintf(f,'\tcal.old.gammaHistogramStd=%.4f;\n',cal.old.gammaHistogramStd);
        fprintf(f,'\tcal.old.G=[');
        fprintf(f,' %g',cal.old.G);
        fprintf(f,'];\n');
        fprintf(f,'\tcal.old.L=[');
        fprintf(f,' %g',cal.old.L);
        fprintf(f,']; %% cd/m^2\n');
        fprintf(f,'\tcal.old.n=[');
        fprintf(f,' %g',cal.old.n);
        fprintf(f,'];\n');
        fprintf(f,'\tcal.old.gamma=[');
        for i=1:size(cal.old.gamma,1)
           fprintf(f,'%.4f %.4f %.4f;',cal.old.gamma(i,:));
           if mod(i,4)==0
              fprintf(f,'...\n');
           end
        end
        fprintf(f,'];\n');
        fprintf(f,'end\n');
    end
    fclose(fid);
    fprintf('The calibration data above, from "if" to "end", has been appended to the file %s.\n',filename);
    fprintf('Calibration finished. Now testing for monotonicity.\n');
    Speak('Now testing for monotonicity.');
    cal.nFirst=1;
    cal.nLast=255;
    cal.LFirst=min(cal.old.L);
    cal.LLast=max(cal.old.L);
    cal=LinearizeClut(cal);
    fprintf('Congratulations. You''re done.\n');
    Speak('Congratulations. You are done.');
catch
    sca;
%     ListenChar(0); % flush
%     ListenChar; % restore
%     FlushEvents('KeyDown');
%     RestoreCluts;
%     Screen('CloseAll');
%     ShowCursor;
    psychrethrow(psychlasterror);
end

% Preprocess text to remove illegal characters.
function str=prep(str)
    str=regexprep(str,'''','''''');
return
