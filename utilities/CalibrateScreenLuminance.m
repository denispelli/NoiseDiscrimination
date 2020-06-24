function CalibrateScreenLuminance(screen,screenOutput,brightnesses)
% CalibrateScreenLuminance(screen,screenOutput,brightnesses)
%
% This will calibrate the luminance of your screen. This is often called
% "gamma" calibration, because in the days of CRTs a power law with
% exponent "gamma" was often used to fit the dependence of screen luminance
% on input voltage. Results will be appended to "OurScreenCalibrations.m".
% The whole calibration (and appending to calibration file) is done for
% each value in "brightnesses". The default for brightnesses used to be
% 1.0, and now is [1.00 0.86 0.54 0.08].
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
% better NOT to test observers in a dark room, because working in the dark
% can be tiring and soporific.
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
% May 13, 2020. Enhance to accept muliple brightnesses. It runs a full
% luminance calibration at each brightness. You later retrieve the
% corresponding calibration by calling OurScreenCalibrations(screen,
% brightness).
%
% 1. WE SAVE THE COLOR PROFILE. Saving the color profile (also known as
% "gamma table") used during calibration allows you to confidently recreate
% the conditions under which you calibrated your display. You needn''t
% worry whether an Operating System update might change a named color
% profile. The color profile is meant to be loaded into your screen's color
% lookup table (CLUT). CalibrateScreenLuminance uses AppleScript to control
% System Preferences:Displays:Color to load your current default gamma
% table into your CLUT, and then we save it here in cal.old.gamma. To
% restore the CLUT to the calibration conditions, Just call
% Screen('LoadNormalizedGammaTable',0,cal.old.gamma).
%
% 2. WE SAVE THE COLOR PROFILE TO GET WHITE RIGHT. On most displays, the
% default color profile (i.e. gamma table) adjusts the values of the blue
% and red channels to achieve a consistent chroma at every luminance. My
% program LinearizeClut uses that, once it's picked the luminance by the
% associated green channel gamma value by doing a table lookup into
% cal.old.gamma to find the appropriate values for red and blue gamma. Thus
% all the displays produced by LinearClut will have the same chroma as the
% white in the color table that you saved in cal.old.gamma.
%
% I use and recommend the Cambridge Research Systems colorimeter. It's a
% photocell with a USB cable that plugs into your computer. Choose USB-A or
% USB-C when you buy it. CalibrateScreenLuminance.m supports it for
% automated readings.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/
%
% Photometers that report in cd/m^2 tend to be expensive. So note that
% there are very cheap apps that run on smart phones and report luminance
% in EV units. EV (exposure value) units are a photographers term, and are
% relative to a film speed. From two web pages, I have the impression that
% if one sets the film speed to ISO 100, then luminance L (cd/m^2) can be
% computed from the EV reading as
% L = 2^(EV-3)
% http://www.sekonic.com/downloads/l-408_english.pdf
% https://www.resna.org/sites/default/files/legacy/conference/proceedings/2010/Outcomes/Student%20Papers/HilderbrandH.html
% To facilitate use of such cheap light meters, I've added an EV mode to
% the program, allowing you to specify each luminance in EV units. It is
% still untested.
%
% See also LinearizeClut, ourScreenCalibrations, testLuminanceCalibration,
% testGammaNull, IndexOfLuminance, LuminanceOfIndex.
%
% For macOS, Apple says, on a portable/desktop computer: Press the F1/F14
% key to decrease the brightness, and press the F2/F15 key to increase the
% brightness. If you have a second display, note that ctrl-F1 and
% ctrl-F2 usually change the brightness on the other display (or external
% display) on macOS 10.7. However, if macOS can control brightness, then
% you're much better off using MacDisplaySettings, which is built-into
% CalibrateScreenLuminance.

% The Psychtoolbox PsychHID tends to get confused if you interrupt it and
% then reconnect. Mario Kleiner advises NOT to clear particular
% Psychtoolbox drivers, so the only safe thing to do is to "clear all".
clear all % Flush drivers.
close all % Close figures.
global useFractionOfScreen screenScalar useConnectedPhotometer ...
    isBlindCalibration useSpeech useEV isQuickForDebugging ...
    luminanceUnit luminanceUnitWords
if nargin<3
    brightnesses=[1.00 0.86 0.54 0.08];
    % These settings reduce the luminance gain of my MacBook Pro by
    % factors of [1 0.5 0.1 0.01];
end
cleanup=onCleanup(@() sca); % Close window if user hits Control-C.
askUserToSpecifyBrightness=false;
% allowEV=true allows use of a photographer's light meter as a photometer.
allowEV=false; % NOT TESTED.
% isBlindCalibration=true is a fallback for computers that don't support
% Psychtoolbox GetEchoNumber.
isBlindCalibration=false;
% gamma11bpc=1/2.4; % disabled. Set display gamma.
useFractionOfScreen=0; % Set this nonzero, e.g. 0.3, for debugging.
isQuickForDebugging=false;
% We need this to run under macOS. Otherwise Psychtoolbox Screen throws too
% many warnings and errors.
Screen('Preference','SkipSyncTests',1);
try
    commandwindow; % Focus on command window.
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
    if nargin>1
        % Used only under Linux.
        cal.screenOutput=screenOutput;
    else
        cal.screenOutput=[];
    end
    if nargin>0
        cal.screen=screen;
    else
        cal.screen=max(Screen('Screens'));
    end
    if true
        % Check for AMD video driver.
        % The GetWindowInfo command requires an open window.
        fprintf('Now opening a small window to check your video driver. ...\n');
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
        % Quick check for Mac models that I believe have AMD/Radeon
        % drivers. As of April 2020, this list includes all the MacBook Pro
        % and iMac models, but omits the Mac Pro. This also misses any
        % non-Mac computer with high luminance precision. E.g. my hp linux
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
    else
        fprintf('Since your video driver is not AMD/Radeon, I''m assuming your screen luminance precision is 8 bits.\n');
    end
    KbName('UnifyKeyNames'); % Needed to work on Windows computer.
    [cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
    cal.pixelMax=255; % ????
    
    %% Is a CRS colorimeter connected?
    % This test works on macOS, and hasn't been tested on Linux or Windows.
    try
        %         clear PsychHID
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
        luminances=32+1; % DGP. Faster April 24, 2019
    else
        luminances=32+1;
    end
    if isQuickForDebugging
        luminances=2+1;  % Quick, to debug.
        brightnesses=1.0;
    end
    if useConnectedPhotometer
        msg=sprintf(['Ok. I''ll use the colorimeter to take %d readings '...
            'at each of %d brightness settings.'],...
            luminances,length(brightnesses));
    else
        msg=sprintf(['We''ll take %d readings manually, one by one, '...
            'at each of %d brightness settings.'],...
            luminances,length(brightnesses));
    end
    fprintf([msg '\n']);
    if useSpeech
        SpeakWithoutLinefeeds(msg);
    end
    if useConnectedPhotometer
        cal.photometer='Cambridge Research Systems Colorimeter';
    else
        if useSpeech
            Speak('Please type the brand name of your photometer or light meter, followed by RETURN. If it''s the Minolta Spotmeter just hit RETURN:');
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
        if ~isQuickForDebugging
            fprintf('Now checking your display settings. ...\n');
            if useSpeech
                Speak('We''ll now check your display settings');
            end
            % Peek old settings.
            [cal.oldSettings,errorMsg]=MacDisplaySettings(cal.screen);
            if ~isempty(errorMsg)
                error('MacDisplaySettings gave error: %s.',errorMsg);
            end
            cal.settings.profile=cal.oldSettings.profile;
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
        if ~isQuickForDebugging
            fprintf('When using a flat-panel display, we usually run at maximum "brightness".\n');
            if ismac
                fprintf('Your display is currently at %.0f%% brightness.\n',...
                    100*cal.settings.brightness);
                if askUserToSpecifyBrightness
                    b=[];
                    while ~isfloat(b) || length(b)~=1 || b<0 || b>100
                        if useSpeech
                            Speak('What percent brightness do you want? We recommend 100%.');
                            Speak('Please type a number from 0 to 100, followed by return.');
                        end
                        b=input('We suggest 100. What brightness percentage do you want (0 to 100)?');
                    end
                    brightnesses=b;
                end
            else
                brightnesses=1.0;
                cal.readings.brightness=nan;
                if useSpeech
                    Speak('Please set your screen to maximum brightness, then hit return');
                end
                fprintf('Please set your screen to maximum brightness.\n');
                input('Hit RETURN when ready to proceed:\n','s');
            end
        end
    else
        cal.settings.brightness = 1.0;
        cal.readings.brightness=nan;
    end % if IsOSX
    
    % GET THE GAMMA TABLE.
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
        error('Your gamma table seems custom-made. Please use an official color profile.\n');
    end
    fprintf('Successfully read your gamma table ("color profile").\n');
    % In April 2018 Mario Kleiner said that "dacBits" cannot be trusted and
    % may be removed. So I stopped saving it.
    
    if allowEV
        response='x';
        fprintf('Photometers usually report luminance in cd/m^2. Photographic light meters report it in EV units. \n');
        if useSpeech
            Speak('What units will you use for luminance? Type C or E');
        end
        while ~ismember(response,{'e','c'})
            response=input('What units will you use to specify luminance? Type c (for cd/m^2) or e (for EV) followed by RETURN:','S');
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
            Speak('Please set the film speed to ISO 100 on your light meter. Then hit return to continue:');
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
    fprintf('We will measure %d luminances at each of %d brightness settings.\n',...
        luminances,length(brightnesses));
    if useSpeech
        Speak(sprintf('We will measure %d luminances at each of %d brightness settings.',...
            luminances,length(brightnesses)));
        Speak('Please type one line about the conditions of this calibration.');
    end
    % fprintf('\n'); % ?? This FPRINTF may be needed under Windows to make INPUT work right.
    cal.notes=input(['Please type one line about conditions of '...
        'this calibration, \n'...
        'including your name, the room, and the room illumination.\n'...
        'Your notes:'],'s');
    msg=['Thank you.\n'...
        'We will soon display a black rectangle and ask you to set up the \n'...
        'photocell so that it''s stable and pointing at the black rectangle.\n'...
        '\n'...
        'If you''re using a laptop and the photocell is \n'...
        'not heavy, an easy and stable way to aim the photocell at the screen \n'...
        'is to rest the back of the screen on the table, angling the \n'...
        'keyboard to be vertical so it won''t fall, and then gently rest \n'...
        'the photocell directly on the screen. \n'...
        ];
    fprintf(msg);
    if useSpeech
        SpeakWithoutLinefeeds([msg 'Hit RETURN to continue.']);
    end
    input('Hit RETURN to continue:');
    if ~useConnectedPhotometer
        fprintf(['\nINSTRUCTIONS: Use a photometer or light meter to measure the screen luminance in ' luminanceUnit '.  Then type your reading followed by RETURN.\n']);
        fprintf('If you make a mistake, you can go back by typing -1, followed by RETURN. You can always quit by hitting ESCAPE.\n');
        if useSpeech
            Speak(['Use a photometer or light meter to measure the screen luminance in ' ...
                luminanceUnitWords '.  Then type your reading followed by return.']);
            % Speak('If you make a mistake, you can go back by typing -1, followed by return. You can always quit by hitting ESCAPE.');
        else
            % input('\nHit RETURN once you''ve read the above instructions, and you''re ready to proceed:','s');
        end
    end
    if useSpeech
        Speak('Hit RETURN to continue, and wait a minute for the window to open.');
    end
    input('Hit RETURN to continue, and wait a minute for the window to open:');
    cal.useRetinaResolution=true;
    screenBufferRect=Screen('Rect',cal.screen);
    PsychImaging('PrepareConfiguration');
    if using11bpc
        PsychImaging('AddTask','General','EnableNative11BitFramebuffer');
        cal.psychImagingOption='EnableNative11BitFramebuffer';
    else
        cal.psychImagingOption='';
    end
    PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
    % PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','SimpleGamma');
    if ~useFractionOfScreen
        screenScalar=1;
        r=[];
    else
        screenScalar=useFractionOfScreen;
        r=round(useFractionOfScreen*screenBufferRect);
        r=AlignRect(r,screenBufferRect,'right','bottom');
    end
    window=PsychImaging('OpenWindow',cal.screen,0,r);
    for i=1:length(brightnesses)
        cal.settings.brightness=brightnesses(i);
        isFirstBrightness= i==1;
        countMsg=sprintf('%d of %d.',i,length(brightnesses));
        if ismac
            fprintf('Setting brightness to %.0f%%. ...\n',...
                100*cal.settings.brightness);
            clear s;
            s.brightness=cal.settings.brightness;
            [~,errorMsg]=MacDisplaySettings(cal.screen,s);
            if ~isempty(errorMsg)
                error('MacDisplaySettings: %s',errorMsg);
            end
        else
            input('Set brightness to %.0f%%, and hit RETURN to continue:',...
                100*cal.settings.brightness);
        end
        MeasureAndSave(window,cal,luminances,isFirstBrightness,countMsg);
    end
catch ME
    sca;
    rethrow(ME);
end % try
sca % Close window.
figure(1); % Show plots.
if isQuickForDebugging
    cal.oldSettings.brightness=1;
end
MacDisplaySettings(cal.screen,cal.oldSettings); % Restore.
msg=sprintf(['Figure 1 shows a raw plot of the %d gamma '...
    'functions that you just measured.'],length(brightnesses));
fprintf('%s\n',msg);
if useSpeech
    Speak(msg);
end

%% SAVE PLOT TO DISK
mainPath=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(mainPath,'data');
folderName='data';
if ~exist(folder,'dir')
    % If we can't find the data folder, then use this folder.
    folder=fileparts(mfilename('fullpath'));
    folderName='this';
end
number=strrep(MACAddress,':','');
filename=sprintf('Calibrate-%s-screen%d-%s.eps',...
    cal.localHostName,cal.screen,number);
graphFile=fullfile(folder,filename);
saveas(gcf,graphFile,'epsc');
fprintf('Plot saved as %s in %s folder.\n',filename,folderName);

%% GOODBYE
fprintf('Congratulations. You''re done.\n');
if useSpeech
    Speak('Congratulations. You are done.');
end
end % function

%% MEASURE AND SAVE
function MeasureAndSave(window,cal,luminances,isFirstBrightness,countMsg)
global useFractionOfScreen screenScalar useConnectedPhotometer ...
    isBlindCalibration useSpeech useEV isQuickForDebugging ...
    luminanceUnit luminanceUnitWords

%% MEASURE ALL LUMINANCES AT ONE BRIGHTNESS
screenRect=Screen('Rect',window);
windowInfo=Screen('GetWindowInfo',window);
if isfield(windowInfo,'DisplayCoreId')
    cal.displayCoreId=windowInfo.DisplayCoreId;
else
    cal.displayCoreId='';
end
cal.bitsPerColorComponent=windowInfo.BitsPerColorComponent;
% PsychColorCorrection('SetEncodingGamma',window,gamma11bpc);
black = BlackIndex(window);  % Retrieves the CLUT color code for white.
white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
if ~useFractionOfScreen
    HideCursor;
end
i=0;
try
    cal.old.n=zeros(1,luminances);
    cal.old.G=zeros(1,luminances);
    while i<luminances
        i=i+1;
        Screen('FillRect',window,white/2,screenRect);
        rect=CenterRect(screenRect/2,screenRect);
        % The index is volatile (dependent on gamma table). The DAC value G
        % is robust.
        cal.old.n(i)=round(cal.pixelMax*(i-1)/(luminances-1));
        cal.old.G(i)=cal.old.gamma(round(1+cal.old.n(i)*cal.old.gammaIndexMax/cal.pixelMax),2);
        v=white*cal.old.n(i)/cal.pixelMax;
        Screen('FillRect',window,v,rect);
        Screen('TextFont',window,'Arial');
        Screen('TextSize',window,20*screenScalar);
        Screen('Flip',window,0,1); % Show test patch and instructions.
        if useConnectedPhotometer
            msg=sprintf('Luminance %d of %d. At %.0f%% brightness. %s',...
                i,luminances,cal.settings.brightness*100,countMsg);
            Screen('DrawText',window,msg,10,...
                screenRect(4)-200*screenScalar,black,white/2);
            if i==1 % First luminance.
                if isFirstBrightness
                    % Explain before measurement begins.
                    msg=sprintf('Put photometer in position, and then hit RETURN to start measuring:');
                else
                    % Measurement in progress. Nothing to explain.
                    msg='';
                end
            else
                % Report previous luminance.
                msg=sprintf('Last reading was %.1f %s.',cal.old.L(i-1),luminanceUnit);
            end % if i==1
            Screen('DrawText',window,msg,10,screenRect(4)-150*screenScalar);
            Screen('Flip',window,0,1); % Show test patch and instructions.
            if i==1 && isFirstBrightness
                if useSpeech
                    Speak(['Please get ready. The photocell should be stable and pointing at the '...
                        'black rectangle. Hit RETURN when ready to begin.']);
                end
                % Screen('Flip',window,0,1); % Show instructions.
                % Shift focus to command window, to receive the keyboard
                % input.
                commandwindow;
                if true
                    % This should work in all OSes. Hormet reported that it
                    % hung on Linux, but that may have been due to my goof
                    % of leaving an earlier call to ListenChar(2) not
                    % balanced by a call to ListenChar(0).
                    input('Hit RETURN when ready to begin:','s');
                else
                    % This too should work in all OSes. Without the calls
                    % to ListenChar the character received by KbWait is
                    % also sent to MATLAB and is received by the next
                    % "input" statement.
                    fprintf('Hit RETURN when ready to begin:\n');
                    ListenChar(-1);
                    KbWait;
                    ListenChar(0);
                end
            end % i==1 && isFirstBrightness
            Screen('DrawText',window,'Now measuring ...',...
                10,screenRect(4)-100*screenScalar);
            Screen('Flip',window,0,1);
            if useSpeech && i==1 && isFirstBrightness
                Speak('Now starting.');
            end
            WaitSecs(2); % Let photometer settle, for max precision.
            n=GetLuminance;
            if useEV
                cal.old.L(i)=2^(n-3); % Convert EV to cd/m^2, assuming film speed is ISO 100.
            else
                cal.old.L(i)=n;
            end
        else % not useConnectedPhotometer
            if isBlindCalibration
                % No echoing of typed response. Ugh. This code supports
                % computers (Windows?) on which we cannot use
                % GetEchoNumber.
                msg=sprintf('%d of %d.',i,luminances);
                Screen('DrawText',window,msg,10,screenRect(4)-200*screenScalar);
                msg=sprintf(['Please measure luminance (' luminanceUnit ') and type it in, followed by <return>:_____']);
                Screen('DrawText',window,msg,10,screenRect(4)-150*screenScalar);
                msg=sprintf('For example "1.1" or "10". The screen is frozen. Just type blindly and wait to hear what you type.');
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
            else % not isBlindCalibration
                msg=sprintf(['%d of %d. ' ...
                    'Please type measured luminance (' luminanceUnit ...
                    '), followed by RETURN:'],i,luminances);
                n=[];
                while true
                    txt=sprintf('If you make a mistake, you can go back by typing -1, followed by RETURN. You can always quit by hitting ESCAPE.\n');
                    Screen('DrawText',window,txt,10,screenRect(4)-70*screenScalar,black,white/2);
                    macsWithTouchBars={'MacBookPro14,3'}; % 2017 MacBook Pro 15";
                    if ismac && ismember(MacModelName,macsWithTouchBars)
                        txt=sprintf('If there''s no ESCAPE key, use Grave Accent `, in the upper left corner of your keyboard.\n');
                        Screen('DrawText',window,txt,10,screenRect(4)-20*screenScalar,black,white/2);
                    end
                    % Unless we call ListenChar, the characters typed for
                    % GetEchoNumber will also be received by MATLAB.
                    ListenChar(2);
                    [n,terminatorChar]=GetEchoNumber(window,msg,10,screenRect(4)-120*screenScalar,black,white/2);
                    FlushEvents;
                    ListenChar(0);
                    graveAccentChar='`';
                    escapeChar=char(27);
                    controlCChar=char(3);
                    if ismember(terminatorChar,[controlCChar escapeChar graveAccentChar])
                        if terminatorChar==controlCChar
                            if useSpeech
                                Speak('Control C');
                            end
                        end
                        if ismember(terminatorChar,[escapeChar graveAccentChar])
                            if useSpeech
                                Speak('Escape');
                            end
                        end
                        sca;
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
                    % Convert EV to cd/m^2, assuming film speed is ISO
                    % 100.
                    cal.old.L(i)=2^(n-3);
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
            end % if isBlindCalibration
        end % useConnectedPhotometer
        if isfield(cal,'ScreenConfigureDisplayBrightnessWorks') && ...
                cal.ScreenConfigureDisplayBrightnessWorks
            cal.readings.brightness=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
            if abs(cal.settings.brightness-cal.readings.brightness)>0.01
                fprintf(['Brightness was set to %.0f%%, '...
                    'but now reads as %.0f%%.\n'],...
                    100*cal.settings.brightness,...
                    100*cal.readings.brightness);
                sca;
                if useSpeech
                    Speak(['Error. The screen brightness changed '...
                        'during calibration. '...
                        'In System Preferences, Displays, '...
                        'please turn off '...
                        '"Automatically adjust brightness".']);
                end
                error(['Screen brightness changed during '...
                    'calibration. In System Preferences:Displays, '...
                    'please turn off "Automatically adjust '...
                    'brightness".']);
            end
        end % if cal.ScreenConfigureDisplayBrightnessWorks
        if true
            % For debugging.
            fprintf('i %3d, n %3d, v %.2f, L %5.1f cd/m^2\n',...
                i,cal.old.n(i),v,cal.old.L(i));
        end
    end % while i<luminances
catch ME
    sca;
    ListenChar;
    rethrow(ME);
    return
end % try

% THEN ADD THE NEW CALIBRATION DATA TO OurScreenCalibrations.m
if isfield(cal,'ScreenConfigureDisplayBrightnessWorks') && ...
        cal.ScreenConfigureDisplayBrightnessWorks
    cal.readings.brightness=Screen('ConfigureDisplay',...
        'Brightness',cal.screen,cal.screenOutput);
    fprintf(['Brightness slider should still be %.0f%%, '...
        'but now reads as %.0f%%.\n'],...
        100*cal.settings.brightness,100*cal.readings.brightness);
    Screen('ConfigureDisplay','Brightness',...
        cal.screen,cal.screenOutput,1);
end
fprintf('\n\n\n');
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
for f=[1 fid]
    fprintf(f,'if');
    fprintf(f,' screen==%d',cal.screen);
    fprintf(f,' && cal.screenWidthMm==%.0f',cal.screenWidthMm);
    fprintf(f,' && brightness==%.2f',cal.settings.brightness);
    if ~isempty(cal.MACAddress)
        fprintf(f,' && streq(MACAddress,''%s'')',cal.MACAddress);
    end
    fprintf(f,'\n');
    fprintf(f,'\t%% ');
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
        fprintf(f,'streq(cal.macModelName,''%s'') && ',...
            prep(cal.macModelName));
    end
    fprintf(f,'cal.screen==%d ...\n',cal.screen);
    if ~isempty(cal.MACAddress)
        fprintf(f,'\t%% ');
    end
    fprintf(f,'&& cal.screenWidthMm==%g && cal.screenHeightMm==%g',...
        cal.screenWidthMm,cal.screenHeightMm);
    if ismac
        fprintf(f,' ...\n');
        if ~isempty(cal.MACAddress)
            fprintf(f,'\t%% ');
        end
        fprintf(f,'&& streq(cal.localHostName,''%s'')\n',...
            prep(cal.localHostName));
    else
        fprintf(f,'\n');
    end
    if ~isempty(cal.MACAddress)
        fprintf(f,'\tcal.OSName=''%s'';\n',OSName);
        if ismac
            fprintf(f,'\t%% cal.macModelName=''%s'';\n',...
                prep(cal.macModelName));
            fprintf(f,'\t%% cal.localHostName=''%s'';\n',...
                prep(cal.localHostName));
        end
        fprintf(f,'\t%% cal.screen=%d;\n',cal.screen);
        fprintf(f,'\t%% cal.screenWidthMm=%g;\n',cal.screenWidthMm);
        fprintf(f,'\t%% cal.screenHeightMm=%g;\n',cal.screenHeightMm);
    end
    if length(cal.screenOutput)==1
        fprintf(f,'\tcal.screenOutput=%.0f; %% used only under Linux\n',...
            cal.screenOutput);
    else
        fprintf(f,'\tcal.screenOutput=[]; %% used only under Linux\n');
    end
    % keyboard; % Added by Hormet to debug Linux?? DGP
    if isfield(cal,'profile')
        fprintf(f,'\tcal.profile=''%s'';\n',cal.profile);
    end
    fprintf(f,'\tcal.settings.brightness=%.2f;\n',...
        cal.settings.brightness);
    cal.screenRect=screenRect;
    fprintf(f,'\t%% cal.screenRect=[%d %d %d %d];\n',...
        cal.screenRect);
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
    % fprintf(f,'\tcal.dacBits=%d; %% From ReadNormalizedGammaTable.\n',cal.dacBits);
    fprintf(f,'\tcal.old.gammaIndexMax=%d;\n',cal.old.gammaIndexMax);
    fprintf(f,'\tcal.old.gammaHistogramStd=%.4f;\n',...
        cal.old.gammaHistogramStd);
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
        '\t%% As explained in "help OurScreenCalibrations", we save a copy\n'...
        '\t%% of the color profile (also known as "gamma table") used during calibration.\n' ...
        '\t%% This allows you to recreate the conditions under which you calibrated your \n'...
        '\t%% display. Thus you needn''t worry whether an Operating System update might change a named \n' ...
        '\t%% color profile.\n' ...
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
end % for f=[1 fid]
fclose(fid);
fprintf('The calibration data above, from "if" to "end", has been appended to the file %s.\n',filename);
fprintf('Calibration finished for %.0f%% brightness.\n',100*cal.settings.brightness);
cal.nFirst=1;
cal.nLast=255;
cal.LFirst=min(cal.old.L);
cal.LLast=max(cal.old.L);
cal=LinearizeClut(cal);

%% PLOT IT
persistent brightnessCounter LMax firstBrightness firstL
if isFirstBrightness
    brightnessCounter=1;
    LMax=max(cal.old.L);
    firstBrightness=cal.settings.brightness;
    firstL=cal.old.L;
else
    brightnessCounter=brightnessCounter+1;
    LMax=max([LMax max(cal.old.L)]);
end
cyan        = [0.2 0.8 0.8];
brown       = [0.2 0 0];
orange      = [1 0.5 0];
blue        = [0 0.5 1];
green       = [0 0.6 0.3];
red         = [1 0.2 0.2];
colors={[0.5 0.5 0.5] green red brown blue cyan orange};
color=colors{brightnessCounter};
fig=figure(1);
fig.Position=[10 10 500 900];
try
    for iplot=1:3
        subplot(3,1,iplot);
        switch iplot
            case 1
                plot(cal.old.G,cal.old.L,'k-',...
                    'LineWidth',1.5,'Color',color, ...
                    'DisplayName',...
                    sprintf('%3.0f%%',100*cal.settings.brightness));
                ylabel('Luminance (cd/m^2)');
                ax=gca;
                ax.YLim=[0 LMax];
                lgd=legend('Location','northwest','Box','off');
                title(lgd,'Brightness setting');
            case 2
                semilogy(cal.old.G,cal.old.L,'k-',...
                    'LineWidth',1.5,'Color',color, ...
                    'DisplayName',...
                    sprintf('%3.0f%%',100*cal.settings.brightness));
                ylabel('Luminance (cd/m^2)');
                ax=gca;
                ax.YLim=[LMax/10000 LMax];
                lgd=legend('Location','southeast','Box','off');
                title(lgd,'Brightness setting');
            case 3
                g=max(cal.old.L)/max(firstL);
                semilogy(cal.old.G,cal.old.L ./firstL,'k-',...
                    'LineWidth',1.5,'Color',color, ...
                    'DisplayName',...
                    sprintf('%3.0f%%, %4.2f',100*cal.settings.brightness,g));
                txt=sprintf('Luminance re that at %.0f%% brightness',100*firstBrightness);
                ylabel(txt);
                ax=gca;
                ax.YLim=[1.5/1000 1.5];
                lgd=legend('Location','southeast','Box','off');
                title(lgd,'Brightness, Gain');
        end
        hold on
        xlabel('Pixel value');
        title('Gamma function');
        lgd.FontName='Monaco';
    end
catch ME
    warning(ME.message);
end
if any(diff(cal.old.L)<0)
    warning(['%.0f%% brightness in Fig. 1: '...
        'The plotted luminance function is not monotonic.'],...
        100*cal.settings.brightness);
end
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
