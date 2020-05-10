function CalibrateScreenLuminance(screen,screenOutput)
% CalibrateScreenLuminance(screen,screenOutput)
% This will calibrate the luminance of your screen. This is often called
% "gamma" calibration, because in the days of CRTs a power law with
% exponent "gamma" was often used to describe the relation of screen
% luminance to input voltage. Results will be appended to
% "OurScreenCalibrations.m".
%
% SET BRIGHTNESS: Before starting calibration, make sure your screen is at
% the standard brightness setting that you want to use for your
% experiments. If you're using macOS, then we'll use MacDisplaySettings to
% set it for you. If you're on another OS, you need to set that up
% yourself, manually. The key point is that the calibration readings that
% you take now will generally be valuable in the future only to the extent
% that you can restore the brightness control to its setting during
% calibration. For that purpose, you may want to use maximum brightness
% because it's a setting that's easy to remember and reproduce.
%
% The angle of viewing matters, so, ideally, you should have the photometer
% look at the screen from the same direction that the observers will. Don't
% worry much about light falling on the screen, provided it won't change
% during the 15-minute calibration period. Modern displays have a 50%
% transmission filter at the front. It dims your dislay by 50%, but dims
% ambient illumination falling on the display doubly, because that light
% has to pass through it twice, to 25% net transmission. Usually it's
% better NOT to test observers in a dark room , because that will later
% tire your observers by making them work in the dark.
%
% Denis Pelli, March 23, 2015, February 25, 2017
% July 20, 2017 enhanced to use new Brightness.m.
% July 20, 2017 enhanced to use Cambrige Research Systems digital
% photometer. Record name of photometer in cal.photometer.
% July 28, 2017. Made speech optional. Turn off AutoBrightness. When Screen
% Configure Brightness is not working properly (i.e. under current macOS),
% use the applescript Brightness instead.
% April 26, 2020. Enhanced to use new MacDisplaySettings, instead of the
% now obsolete Brightness.m.
%
% 1. WE SAVE THE GAMMA TABLE TO RESTORE THE CLUT. Apple offers no easy way
% to grab the default screen profile; for Mac users, it's called a color
% profile; for programmers it's called a gamma table. It's meant to be
% loaded into your screen's color lookup table (CLUT).
% CalibrateScreenLuminance uses AppleScript to control System
% Preferences:Displays:Color to load the default gamma table into your
% CLUT, and then we save it here in cal.old.gamma. This is much more
% convenient than using AppleScript to get it yourself because running
% AppleScript is slow (many seconds if Screen Preference is not already
% open) and fragile, requiring special permissions. It is useful to have
% this table handy. Most users of OurScreenCalibrations will modify the
% CLUT. Once you've modified the CLUT, neither macOS nor Psychtoolbox
% automatically restore the default CLUT. It is automatically restored only
% when you reboot the computer. It turns out to be hard to reliably save
% and restore the CLUT because, during development, it's common for a
% program to terminate prematurely without having restored the original
% CLUT. The next program you run then risks saving and restoring the
% modified CLUT. Thus it's more reliable to have a known good copy here, in
% cal.old.gamma, that you can use to restore the CLUT when your program is
% done. Just call Screen('LoadNormalizedGammaTable',0,cal.old.gamma). For
% general use of LoadNormalizedGammaTable, you would normally worry about
% the deferLoading argument and use PsychImaging to EnableCLUTMapping, but
% for just restoring the default, I've had good luck with this basic call.
%
% 2. WE SAVE THE GAMMA TABLE TO GET WHITE RIGHT. On most displays, the
% default gamma table adjusts the values of the blue and red channels to
% achieve a consistent chroma at every luminance. My program LinearizeClut
% uses that, once it's picked the luminance by the associated green channel
% gamma value by doing a table lookup into cal.old.gamma to find the
% appropriate values for red and blue gamma. Thus all the displays produced
% by LinearClut will have the same chroma as the white in the color table
% that you saved in cal.old.gamma.
%
% I use and recommend the Cambridge Research Systems colorimeter. It's a
% photocell with a USB cable (choose USB-A or USB-C when you buy it) that
% plugs into your computer. CalibrateScreenLuminance.m supports it for
% automated readings.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/
%
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
%
% See also LinearizeClut, ourScreenCalibrations, testLuminanceCalibration,
% testGammaNull, IndexOfLuminance, LuminanceOfIndex.
%
% For macOS, Apple says, on a portable/desktop computer: Press the F1/F14
% key to decrease the brightness, and press the F2/F15 key to increase the
% brightness. If you have a second display, note that ctrl-F1 and
% ctrl-F2 usually change the brightness on the other display (or external
% display) on macOS 10.7.

forceMaximumBrightness=true;
allowEV=false; % true to allow use of a photographer's light meter as a photometer. NOT TESTED.
blindCalibration=false; % A fallback for computers that don't support Psychtoolbox GetEchoNumber.
% gamma11bpc=1/2.4; % disabled. Set display gamma.
useFractionOfScreen=0; % Set this nonzero, about 0.3, for debugging.
makeItQuickForDebugging=false;
Screen('Preference', 'SkipSyncTests', 1);
try
    commandwindow; % Bring focus to command window, if not already there.
    addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'lib')); % folder is in directory, two up from this M file
    fprintf('\nWelcome to Calibrate Screen Luminance.\n');
    while true
        reply=input('Do you want me to use computer speech to guide you (y or n)?:','s');
        if ~isempty(reply)
            break;
        end
    end
    useSpeech=ismember(reply(1),{'y' 'Y'});
    if useSpeech
        fprintf('Now using computer speech. Please turn up the volume to hear it.\n');
        Speak('Welcome to Calibrate Screen Luminance.');
    end
    % onCleanupInstance=onCleanup(@()sca); % clears screen when function is terminated.
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
    if true
        % Check for AMD video driver.
        % The GetWindowInfo command requires an open window.
        fprintf('Now opening a small window to check your video driver.\n');
        oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel',0);
        oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 1);
        oldVerbosity = Screen('Preference', 'Verbosity',0);
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
        screenBufferRect=Screen('Rect',cal.screen);
        r=round(0.1*screenBufferRect);
        r=AlignRect(r,screenBufferRect,'right','bottom');
        window=PsychImaging('OpenWindow',cal.screen,0,r);
        windowInfo=Screen('GetWindowInfo',window);
        if isfield(windowInfo,'DisplayCoreId')
            cal.displayCoreId=windowInfo.DisplayCoreId;
        else
            cal.displayCoreId='';
        end
        Screen('Close',window);
        Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
        Screen('Preference', 'SkipSyncTests', oldSkipSyncTests);
        Screen('Preference', 'Verbosity',oldVerbosity);
        using11bpc=ismember(cal.displayCoreId,{'AMD','R600'});
    else
        % Quick check for Mac models that I believe have AMD/Radeon drivers.
        % As of April 2020, this list includes all the MacBook Pro and iMac
        % models, but omits the Mac Pro. This also misses any non-Mac
        % computer with high luminance precision. E.g. my hp linux
        % computer.
        using11bpc=ismac && ismember(MacModelName,...
            {'MacBookPro9,2' 'MacBookPro10,1' 'MacBookPro11,2'  ...
            'MacBookPro11,3' 'MacBookPro11,4' 'MacBookPro11,5'  ...
            'MacBookPro13,3' 'MacBookPro14,3' 'MacBookPro15,1' ...
            'MacBookPro15,3' 'MacBookPro16,1' ...
            'iMac14,1' 'iMac15,1' 'iMac17,1' 'iMac18,3' 'iMac19,1'});
    end
    if using11bpc
        fprintf('Since you have an AMD/Radeon video driver, I''m assuming your screen luminance precision is 11 bits.\n');
        if useSpeech
            Speak('Since you have an AMD video driver, I''m assuming your screen luminance precision is 11 bits.');
        end
    else
        fprintf('Since your video driver is not AMD/Radeon, I''m assuming your screen luminance precision is 8 bits.\n');
        if useSpeech
            Speak('Since your video driver is not AMD, I''m assuming your screen luminance precision is 8 bits.');
        end
    end
    KbName('UnifyKeyNames'); % Needed to work on Windows computer.
    [cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
    cal.pixelMax=255; % ????
    
    %% Is a CRS colorimeter connected?
    % This test works on macOS, and hasn't been tested on Linux or Windows.
    try
        clear PsychHID
        fprintf('* Checking for USB photometer ...\n');
        usbHandle=PsychHID('OpenUSBDevice',2145,4097);
        if ~isempty(usbHandle)
            PsychHID('CloseUSBDevice',usbHandle);
        end
        fprintf('* USB phototometer found.\n');
        useConnectedPhotometer=true;
    catch
        fprintf('* No USB phototometer found, proceeding.\n');
        useConnectedPhotometer=false;
    end
    %    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel',0);
    %    oldVerbosity = Screen('Preference', 'Verbosity',0);
    %    oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings',1);
    %    Screen('Preference', 'Verbosity',oldVerbosity);
    %    Screen('Preference', 'Verbosity',oldVerbosity);
    %    Screen('Preference','SuppressAllWarnings',oldSuppressAllWarnings);
    if useConnectedPhotometer
        fprintf('I detect a Cambridge Research Systems colorimeter.\n');
        if useSpeech
            Speak('I detect a Cambridge Research Systems colorimeter. Shall we use it?');
        end
        while true
            reply=input('Shall we use it (y/n)?:','s');
            if ~isempty(reply)
                break;
            end
        end
        useConnectedPhotometer=ismember(reply(1),{'y' 'Y'});
    end
    if useConnectedPhotometer
        %         luminances=64+1;
        luminances=32+1; % DGP. Faster April 24, 2019
    else
        luminances=32+1;
    end
    if makeItQuickForDebugging
        luminances=4+1;  % Quick, to debug.
    end
    if useConnectedPhotometer
        msg=sprintf('Ok. I''ll take %d readings automatically, using the colorimeter.',luminances);
        msg=[msg '\nBy the way, an easy way to point the colorimeter at the screen,\n'...
            'if you''re using a laptop, is to rest the back of the screen on the table,\n'...
            'angling the keyboard to be vertical, so it won''t fall,\n'...
            'and then gently resting the colorimeter photocell directly on the screen.'];
    else
        msg=sprintf('We''ll take %d readings manually, one by one.',luminances);
    end
    fprintf([msg '\n']);
    if useSpeech
        SpeakWithoutLinefeeds(msg);
    end
    if useConnectedPhotometer
        cal.photometer='Cambridge Research Systems Colorimeter';
    else
        if useSpeech
            Speak('Please type the brand name of your photometer or light meter, followed by RETURN. If it''s the Minolta Spotmeter just hit RETURN.');
        end
        msg=input('Please type the brand name of your photometer or light meter, followed by RETURN.\nIf it''s the Minolta Spotmeter, just hit RETURN:','s');
        if useSpeech
            Speak('Ok');
        end
        if isempty(msg)
            cal.photometer='Minolta Spotmeter';
        else
            cal.photometer=msg;
        end
    end
    if ismac %|| IsLinux
        if ~ScriptingOkShowPermission
            error(['Please give MATLAB permission to control the computer. ' ...
                'You''ll need admin privileges to do this.']);
        end
        if ~makeItQuickForDebugging
            fprintf('Now checking your screen display settings.\n');
            if useSpeech
                Speak('Will now check your screen display settings');
            end
            % Peek old settings.
            [cal.oldSettings,errorMsg]=MacDisplaySettings(cal.screen);
            if ~isempty(errorMsg)
                error('MacDisplaySettings gave error: %s.',errorMsg);
            end
            cal.settings=cal.oldSettings; % Copy profile name.
            cal.settings.brightness=1.0;
            cal.settings.automatically=false;
            cal.settings.trueTone=false;
            cal.settings.nightShiftSchedule='Off';
            cal.settings.nightShiftManual=false;
            cal.settings.showProfilesForThisDisplayOnly=false;
            % Poke new settings. Force reload of profile.
            [~,errorMsg]=MacDisplaySettings(cal.screen,cal.settings);
            if ~isempty(errorMsg)
                error('MacDisplaySettings gave error: %s.',errorMsg);
            end
            cal.profile=cal.oldSettings.profile;
        else
            cal.settings.brightness=[];
            cal.settings.automatically=[];
            cal.settings.trueTone=[];
            cal.settings.nightShiftSchedule=[];
            cal.settings.nightShiftManual=[];
            cal.settings.showProfilesForThisDisplayOnly=false;
            cal.settings.profile='';
            cal.settings.profileRow=[];
        end
        if ~makeItQuickForDebugging
            fprintf('When using a flat-panel display, we usually run at maximum "brightness".\n');
            if ismac
                fprintf('Your display is currently at %.0f%% brightness.\n',...
                    100*cal.settings.brightness);
                if forceMaximumBrightness
                    b=100;
                else
                    b=[];
                    while ~isfloat(b) || length(b)~=1 || b<0 || b>100
                        if useSpeech
                            Speak('We usually run at 100% brightness. What percent brightness do you want?');
                            Speak('Please type a number from 0 to 100, followed by return.');
                        end
                        b=input('We suggest 100. What brightness percentage do you want (0 to 100)?');
                    end
                end
                cal.settings.brightness=b/100;
                [~,errorMsg]=MacDisplaySettings(cal.screen,cal.settings);
                if ~isempty(errorMsg)
                    error('MacDisplaySettings error: %s.',errorMsg);
                end
                readings=MacDisplaySettings;
                if abs(cal.settings.brightness-readings.brightness)>0.01
                    fprintf('Brightness was set to %.0f%%, but now reads as %.0f%%.\n',...
                        100*cal.settings.brightness,100*readings.brightness);
                    sca;
                    if useSpeech
                        Speak(['Error. ' ...
                            'The screen brightness changed during calibration.']);
                    end
                    error('Screen brighness changed during calibration.');
                end
            else
                cal.settings.brightness=1.0;
                cal.readings.brightness=nan;
                if useSpeech
                    Speak('Please set your screen to maximum brightness, then hit return');
                end
                fprintf('Please set your screen to maximum brightness.\n');
                input('Hit return when ready to proceed:\n','s');
            end
        end
    else
        cal.brightnessRmsError=nan;
        cal.settings.brightness = nan;
    end % if IsOSX
    
    % Get the gamma table. 
    % In April 2018 Mario Kleiner said that "dacBits" cannot be trusted and
    % may be removed. So I stopped saving it.
    cal.old.gamma=Screen('ReadNormalizedGammaTable',cal.screen,cal.screenOutput);
    cal.old.gammaIndexMax=length(cal.old.gamma)-1; % Index into gamma table is 0..gammaIndexMax.
    
    % Make sure it's a good gamma table.
    cal.old.gammaHistogramStd=std(histcounts(cal.old.gamma(:,2),10,'Normalization','probability'));
    macStd=[0.0005  0.0082  0.0085  0.0111  0.0123  0.0683 0.0082];
    if cal.old.gammaHistogramStd > max(macStd)
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
        if useSpeech
            Speak(['ERROR: To get a consistent white in your stimuli, please use System Preferences '...
                'Displays Color to select a color profile that you like. Then try again.']);
        end
        error('YOur gamma table seems custom-made. Please use an official color profile.\n');
    end
    fprintf('Successfully read your gamma table ("color profile").\n');
    
    if allowEV
        response='x';
        fprintf('Photometers usually report luminance in cd/m^2. Photographic light meters report it in EV units. \n');
        if useSpeech
            Speak('What units will you use for luminance? Type C or E');
        end
        while ~ismember(response,{'e','c'})
            response=input('What units will you use to specify luminance? Type C (for cd/m^2) or E (for EV) followed by RETURN:','S');
            response=lower(response);
        end
        useEV= response(1)=='e';
    else
        useEV=false;
    end
    
    if useEV
        luminanceUnitWords='exposure value EV';
        luminanceUnit='EV';
    else
        luminanceUnitWords='candelas per meter squared';
        luminanceUnit='cd/m^2';
    end
    fprintf(['Thanks. You will enter luminances in units of ' luminanceUnit '.\n']);
    if useEV
        fprintf('IMPORTANT: Please set the film speed to ISO 100 on your light meter.\n');
        if useSpeech
            Speak('Please set the film speed to ISO 100 on your light meter. Then hit return to continue.');
        end
        x=input('Hit RETURN to continue:','S');
    end
    fprintf('We will create a linearized gamma table that you can save for future use with this display.\n');
    computer=Screen('Computer');
    if isfield(computer,'processUserLongName')
        cal.processUserLongName=computer.processUserLongName;
    else
        try
            cal.processUserLongName = getenv('USERNAME');
        catch
            cal.processUserLongName='';
        end
    end
    if ~isfield(computer,'localHostName')
        cal.localHostName='';
    else
        cal.localHostName=computer.localHostName;
    end
    if ismac
        cal.macModelName=MacModelName;
    else
        cal.macModelName='Not-a-mac';
    end
    fprintf('Computer %s, %s, screenWidthCm %.1f, screenHeightCm %.1f\n',...
        prep(cal.localHostName),prep(cal.macModelName),cal.screenWidthMm/10,cal.screenHeightMm/10);
    fprintf('We will measure %d luminances.\n',luminances);
    if useSpeech
        Speak(sprintf('We will measure %d luminances.',luminances));
    end
    if ~useConnectedPhotometer
        fprintf(['\nINSTRUCTIONS: Use a photometer or light meter to measure the screen luminance in ' luminanceUnit '.  Then type your reading followed by RETURN.\n']);
        fprintf('If you make a mistake, you can go back by typing -1, followed by RETURN. You can always quit by hitting ESCAPE.\n');
        if useSpeech
            Speak(['Use a photometer or light meter to measure the screen luminance in ' ...
                luminanceUnitWords '.  Then type your reading followed by return.']);
            %          Speak('If you make a mistake, you can go back by typing -1, followed by return. You can always quit by hitting ESCAPE.');
        else
            %          input('\nHit RETURN once you''ve read the above instructions, and you''re ready to proceed:','s');
        end
    end
    % Screen('Preference','SkipSyncTests',1);
    cal.useRetinaResolution=false;
    
    screenBufferRect = Screen('Rect',cal.screen);
    PsychImaging('PrepareConfiguration');
    if using11bpc
        PsychImaging('AddTask','General','EnableNative11BitFramebuffer');
        cal.psychImagingOption='EnableNative11BitFramebuffer';
    else
        cal.psychImagingOption='';
    end
    PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
    %         PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','SimpleGamma');
    if ~useFractionOfScreen
        screenScalar=1;
        r=[];
    else
        screenScalar=useFractionOfScreen;
        r=round(useFractionOfScreen*screenBufferRect);
        r=AlignRect(r,screenBufferRect,'right','bottom');
    end
    [window,screenRect]=PsychImaging('OpenWindow',cal.screen,0,r);
    windowInfo=Screen('GetWindowInfo',window);
    if isfield(windowInfo,'DisplayCoreId')
        cal.displayCoreId=windowInfo.DisplayCoreId;
    else
        cal.displayCoreId='';
    end
    cal.bitsPerColorComponent=windowInfo.BitsPerColorComponent;
    %         PsychColorCorrection('SetEncodingGamma',window,gamma11bpc);
    black = BlackIndex(window);  % Retrieves the CLUT color code for white.
    white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
    i=0;
    if ~useFractionOfScreen
        HideCursor;
    end
    try
        cal.old.n=zeros(1,luminances);
        cal.old.G=zeros(1,luminances);
        while i<luminances
            i=i+1;
            Screen('FillRect',window,white/2,screenRect);
            rect=CenterRect(screenRect/2,screenRect);
            % The index is volatile (dependent on gamma table). The dac value
            % G is robust.
            cal.old.n(i)=round(cal.pixelMax*(i-1)/(luminances-1));
            cal.old.G(i)=cal.old.gamma(round(1+cal.old.n(i)*cal.old.gammaIndexMax/cal.pixelMax),2);
            v=white*cal.old.n(i)/cal.pixelMax;
            Screen('FillRect',window,v,rect);
            Screen('TextFont',window,'Arial');
            Screen('TextSize',window,20*screenScalar);
            Screen('Flip',window,0,1); % Calibration: Show test patch and instructions.
            if useConnectedPhotometer
                msg=sprintf('%d of %d.',i,luminances);
                Screen('DrawText',window,msg,10,screenRect(4)-200*screenScalar,black,white/2);
                if i==1
                    msg=sprintf('Put photometer in position, and then hit RETURN to start measuring.');
                else
                    msg=sprintf('Last reading was %.1f %s.',cal.old.L(i-1),luminanceUnit);
                end
                Screen('DrawText',window,msg,10,screenRect(4)-150*screenScalar);
                Screen('Flip',window,0,1); % Calibration: Show test patch and instructions.
                if i==1
                    if useSpeech
                        Speak('Hit RETURN when ready to begin.');
                    end
                    Screen('Flip',window,0,1); % Show instructions.
                    commandwindow; % Try to shift focus to command window, so we receive the keyboard input.
                    if false
                        % Hangs on Linux.
                        input('Hit RETURN when ready to begin','s');
                    else
                        % Works in Linux. Hopefully workds on all OSes.
                        fprintf('Hit RETURN when ready to begin.\n');
                        KbWait;
                        endd
                        Screen('DrawText',window,'Now measuring ...',10,screenRect(4)-100*screenScalar);
                        Screen('Flip',window,0,1);
                        if useSpeech
                            Speak('Starting now.');
                        end
                    end
                    WaitSecs(2);
                    n=GetLuminance;
                    if useEV
                        cal.old.L(i)=2^(n-3); % Convert EV to cd/m^2, assuming film speed is ISO 100.
                    else
                        cal.old.L(i)=n;
                    end
                else
                    if blindCalibration
                        % No echoing of typed response. Ugh. This code supports
                        % computers (Windows?) on which we cannot use GetEchoNumber.
                        msg=sprintf('%d of %d.',i,luminances);
                        Screen('DrawText',window,msg,10,screenRect(4)-200*screenScalar);
                        msg=sprintf(['Please measure luminance (' luminanceUnit ') and type it in, followed by <return>:_____']);
                        Screen('DrawText',window,msg,10,screenRect(4)-150*screenScalar);
                        msg=sprintf('For example "1.1" or "10". The screen is frozen. Just type blindly and wait to hear it.');
                        Screen('DrawText',window,msg,10,screenRect(4)-100*screenScalar);
                        msg=sprintf('If you hear a mistake, don''t worry. Typing -1 will erase the last entry.');
                        Screen('DrawText',window,msg,10,screenRect(4)-50*screenScalar);
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
                            if useSpeech
                                Speak('Erasing one setting.');
                            end
                            i=i-2;
                            continue;
                        end
                        if useSpeech
                            Speak(sprintf('%g',cal.old.L(i)));
                        end
                    else
                        msg=sprintf(['%d of %d. Please type measured luminance (' luminanceUnit '), followed by RETURN:'],i,luminances);
                        ListenChar(2); % suppress echoing of keyboard in Command Window
                        n=[];
                        while 1
                            txt=sprintf('If you make a mistake, you can go back by typing -1, followed by RETURN. You can always quit by hitting ESCAPE.\n');
                            Screen('DrawText',window,txt,10,screenRect(4)-70*screenScalar,black,white/2);
                            macsWithTouchBars={'MacBookPro14,3'}; % 2017 MacBook Pro 15";
                            if ismac && ismember(MacModelName,macsWithTouchBars)
                                txt=sprintf('If there''s no ESCAPE key, use Grave Accent `, in the upper left corner of your keyboard.\n');
                                Screen('DrawText',window,txt,10,screenRect(4)-20*screenScalar,black,white/2);
                            end
                            [n,terminatorChar]=GetEchoNumber(window,msg,10,screenRect(4)-120*screenScalar,black,white/2);
                            % [n,terminatorChar]=GetEchoNumber(window,msg,10,screenRect(4)-100,black,white/2,1); % external keyboard
                            graveAccentChar='`';
                            escapeChar=char(27);
                            controlCChar=char(3);
                            if ismember(terminatorChar,[controlCChar  escapeChar graveAccentChar])
                                if terminatorChar==controlCChar
                                    if useSpeech
                                        Speak('Control C');
                                    end
                                end
                                if ismember(terminatorChar, [escapeChar graveAccentChar])
                                    if useSpeech
                                        Speak('Escape');
                                    end
                                end
                                sca;
                                ShowCursor;
                                ListenChar;
                                fprintf('\nQUITTING: User hit Control-C, Escape, or GraveAccent.\n');
                                return
                            end
                            if ~isfloat(n) || length(n)~=1
                                Speak('Invalid. Try again.');
                            else
                                if useSpeech
                                    Speak(sprintf('%g',n));
                                end
                                break;
                            end
                        end
                        if useEV
                            cal.old.L(i)=2^(n-3); % Convert EV to cd/m^2, assuming film speed is ISO 100.
                        else
                            cal.old.L(i)=n;
                        end
                        if cal.old.L(i)<0
                            if useSpeech
                                Speak('Erasing one setting.');
                            end
                            i=i-2;
                            continue;
                        end
                        ListenChar; % restore keyboard echoing
                    end
                end
                if cal.ScreenConfigureDisplayBrightnessWorks
                    cal.readings.brightness=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
                    if abs(cal.settings.brightness-cal.readings.brightness)>0.01
                        fprintf('Brightness was set to %.0f%%, but now reads as %.0f%%.\n',100*cal.settings.brightness,100*cal.readings.brightness);
                        sca;
                        if useSpeech
                            Speak('Error. The screen brightness changed during calibration. In System Preferences, Displays, please turn off "Automatically adjust brightness".');
                        end
                        error('Screen brightness changed during calibration. In System Preferences:Displays, please turn off "Automatically adjust brightness".');
                    end
                end
                if true
                    % For debugging.
                    fprintf('i %3d, n %3d, v %.2f, L %5.1f cd/m^2\n',i,cal.old.n(i),v,cal.old.L(i));
                end
            end
            catch e
                Screen('CloseAll');
                ShowCursor;
                ListenChar;
                rethrow(e);
                return
        end
        Screen('CloseAll');
        ShowCursor;
        ListenChar; % restore
        if cal.ScreenConfigureDisplayBrightnessWorks
            cal.readings.brightness=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
            fprintf('Brightness slider should still be %.0f%%, but now reads as %.0f%%.\n',100*cal.settings.brightness,100*cal.readings.brightness);
            Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,1);
        end
        fprintf('\n\n\n');
        if useSpeech
            Speak('Thank you. Please wait for the Command Window to reappear, then please type notes, followed by RETURN.');
        end
        fprintf('\n'); % Not sure, but this FPRINTF may be needed under Windows to make INPUT work right.
        cal.notes=input('Please type one line about conditions of this calibration, \nincluding your name, the room, and the room illumination.\nYour notes:','s');
        filename='OurScreenCalibrations.m';
        fprintf('Appending this calibration data to %s.\n',filename);
        mypath=fileparts(fileparts(mfilename('fullpath')));
        fullfilename=fullfile(mypath,'lib',filename);
        fid=fopen(fullfilename,'a+');
        [mac,st]=MACAddress;
        if streq(st.Description,'Failed to find network adapter')
            mac='';
        end
        cal.MACAddress=mac;
        for f=[1,fid]
            if ~isempty(cal.MACAddress)
                fprintf(f,'if streq(MACAddress,''%s'')\n',cal.MACAddress);
                fprintf(f,'\t%% ');
            end
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
            fprintf(f,'cal.screen==%d ...\n',cal.screen);
            if ~isempty(cal.MACAddress)
                fprintf(f,'\t%% ');
            end
            fprintf(f,'&& cal.screenWidthMm==%g && cal.screenHeightMm==%g',cal.screenWidthMm,cal.screenHeightMm);
            if ismac
                fprintf(f,' ...\n');
                if ~isempty(cal.MACAddress)
                    fprintf(f,'\t%% ');
                end
                fprintf(f,'&& streq(cal.localHostName,''%s'')\n',prep(cal.localHostName));
            else
                fprintf(f,'\n');
            end
            if ~isempty(cal.MACAddress)
                fprintf(f,'\tcal.OSName=''%s'';\n',OSName);
                if ismac
                    fprintf(f,'\t%% cal.macModelName=''%s'';\n',prep(cal.macModelName));
                    fprintf(f,'\t%% cal.localHostName=''%s'';\n',prep(cal.localHostName));
                end
                fprintf(f,'\t%% cal.screen=%d;\n',cal.screen);
                fprintf(f,'\t%% cal.screenWidthMm=%g;\n',cal.screenWidthMm);
                fprintf(f,'\t%% cal.screenHeightMm=%g;\n',cal.screenHeightMm);
            end
            if length(cal.screenOutput)==1
                fprintf(f,'\tcal.screenOutput=%.0f; %% used only under Linux\n',cal.screenOutput);
            else
                fprintf(f,'\tcal.screenOutput=[]; %% used only under Linux\n');
            end
            if ~makeItQuickForDebugging
                if ismac
                    fprintf(f,'\tcal.profile=''%s'';\n',cal.profile);
                end
                keyboard; % Added by Hormet for Linux?? DGP
                fprintf(f,'\tcal.settings.brightness=%.2f;\n',cal.settings.brightness);
            end
            cal.screenRect=screenRect;
            fprintf(f,'\t%% cal.screenRect=[%d %d %d %d];\n',cal.screenRect);
            fprintf(f,'\tcal.mfilename=''%s'';\n',mfilename);
            fprintf(f,'\tcal.datestr=''%s'';\n',datestr(now));
            fprintf(f,'\tcal.photometer=''%s'';\n',cal.photometer);
            fprintf(f,'\tcal.notes=''%s'';\n',prep(cal.notes));
            if any(diff(cal.old.L)<0)
                fprintf(f,'\t%% WARNING: The luminance function cal.old.L is not monotonic.\n');
            end
            fprintf(f,'\tcal.calibratedBy=''%s'';\n',prep(cal.processUserLongName));
            fprintf(f,'\tcal.psychImagingOption=''%s'';\n',cal.psychImagingOption);
            if isfield(cal,'displayCoreId')
                fprintf(f,'\tcal.displayCoreId=''%s'';\n',cal.displayCoreId);
                fprintf(f,'\tcal.bitsPerColorComponent=''%s'';\n',cal.bitsPerColorComponent);
            end
            %       fprintf(f,'\tcal.dacBits=%d; %% From ReadNormalizedGammaTable.\n',cal.dacBits);
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
            fprintf(f,[...
                '\t%% As explained in "help OurScreenCalibrations", it is useful to have a copy\n'...
                '\t%% of your screen''s default color profile, also known as gamma table, to \n'...
                '\t%% restore the Color Lookup Table (CLUT) before you quit a session in which \n'...
                '\t%% you modified it. It''s also useful for achieving a consistent white balance.\n'...
                ]);
            fprintf(f,'\tcal.old.gamma=[');
            for i=1:size(cal.old.gamma,1)
                fprintf(f,'%.4f %.4f %.4f;',cal.old.gamma(i,:));
                if mod(i,5)==0
                    fprintf(f,'...\n');
                end
            end
            fprintf(f,'];\n');
            fprintf(f,'end\n');
        end
        fclose(fid);
        fprintf('The calibration data above, from "if" to "end", has been appended to the file %s.\n',filename);
        fprintf('Calibration finished.\n');
        cal.nFirst=1;
        cal.nLast=255;
        cal.LFirst=min(cal.old.L);
        cal.LLast=max(cal.old.L);
        cal=LinearizeClut(cal);
        figure(1);
        plot(cal.old.G,cal.old.L);
        xlabel('Gamma value');
        ylabel('Luminance (cd/m^2)');
        title('Gamma function');
        fprintf('Figure 1 shows a raw plot of the gamma function that you just measured.\n');
        if useSpeech
            Speak('Figure 1 shows a raw plot of the gamma function that you just measured.');
        end
        if any(diff(cal.old.L)<0)
            warning('The plotted luminance function (Fig. 1) is not monotonic.');
        end
        fprintf('Congratulations. You''re done.\n');
        if useSpeech
            Speak('Congratulations. You are done.');
        end
    catch me
        sca;
        ListenChar; % restore
        %     RestoreCluts;
        %     Screen('CloseAll');
        ShowCursor;
        rethrow(me);
    end % try
end % try
end % function

%% Preprocess text to remove illegal characters.
function str=prep(str)
str=regexprep(str,'''','''''');
end

%% GET LUMINANCE
function L=GetLuminance
% L=GetLuminance;
% Measure luminance (cd/m^2).
% Cambridge Research Systems ColorCAL II XYZ Colorimeter.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/nest/product-support
persistent CORRMAT
if isempty(CORRMAT)
    % Get ColorCAL II XYZ correction matrix (CRT=1; WLED LCD=2; OLED=3):
    CORRMAT=ColorCal2('ReadColorMatrix');
end
s = ColorCal2('MeasureXYZ');
if isempty(s)
    L=nan;
    return
end
XYZ = CORRMAT(4:6,:) * [s.x s.y s.z]';
L=XYZ(2);
end

function msg=StripLinefeeds(msg)
msg=strrep(msg,'\n',' ');
end

function SpeakWithoutLinefeeds(msg)
Speak(StripLinefeeds(msg));
end
