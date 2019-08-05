function [oldLevel,status] = Brightness(screenNumber,newLevel)
% [oldLevel,status] = Brightness([screenNumber][,newLevel])
%
% August 2019. Always use Screen instead of Applescript, if Psychotoolbox
% version 3.0.16 or later is available.
%
% BRIGHTNESS. Get and set the "brightness" slider in the macOS: System
% Preferences: Displays panel. The function argument "newLevel" (0.0
% to 1.0) indicates the desired brightness. If you call without an argument
% then nothing is changed. The current state is always reported in
% the returned oldLevel (0.0 to 1.0). The optionally returned "status" is
% always zero unless the applescript failed, in which case oldLevel is NaN.
%
% ON ERROR:  If there is an error we close any open Psychtoolbox window.
%
% PERMISSION: If the user has not yet given permission for MATLAB to control
% the computer (in System Preferences:Security & Privacy:Accessibility),
% then we give an error alerting the user to grant this permission.
%
% Brightness.m uses the Brightness.applescript to set the "brightness"
% slider in the macOS: System Preferences: Displays panel. For use in
% MATLAB, please put both files anywhere in MATLAB's path.
%
% June 25, 2017. Written by denis.pelli@nyu.edu for the Psychtoolbox.
% June 28, 2017, Fixed type of returned value, formerly a string, to now be
% a number.
% July 20, 2017. Enhanced to cope with spaces in the path to the applescript.
% December 1, 2018. Put try-catch block around the code, to gracefully cope
% with error while Screen window obscures the MATLAB Command Window.
% Elimited the check for Screen window, which is no longer an issue.
% July 16,2019 Improved by looking at code here:
% https://apple.stackexchange.com/questions/272531/dim-screen-brightness-of-mbp-using-applescript-and-while-using-a-secondary-mon/285907
%
% This MATLAB function calls either
% Screen('ConfigureDisplay','Brightness'...) or our Brightness applescript.
% Both are equivalent to manually opening the System Preferences:Displays
% panel and adjusting the "brightness" slider. The applescript was written
% to be invoked from MATLAB, but you could call it from any macOS
% application.
%
% TECHNICAL: Adjusting the "brightness" setting in an LCD, controls the
% luminance of the fluorescent light that is behind the liquid crystal
% display. I believe that the "brightness" slider controls only the
% luminance of the source, and does not affect the liquid crystal itsef,
% which is controlled by the color lookup table. The luminance at the
% viewer's eye is presumably the product of the two factors: luminance of
% the source and transmission of the liquid crystal, at each wavelength.
%
% INSTALLATION. To work with MATLAB, please put both the .m and
% .applescript files anywhere in MATLAB's path.
%
% APPLESCRIPT IS SLOW. It uses the "System Preferences: Displays" panel,
% which takes 30 s to open if it isn't already open. We set up the
% Brightness applescript to always leave System Preferences open, so you
% won't waste your observer's time waiting 30 s for System Preferences to
% open every time you call Brightness.
%
% SCREEN CONFIGURE DISPLAY BRIGHTNESS. The macOS version of Psychtoolbox
% already has a SCREEN call to get and set the brightness, but its setting
% ability seems to be unreliable in macOS Sierra, so I'm providing this
% Applescript alternative. The Psychtoolbox call is:
% [oldBrightness]=Screen('ConfigureDisplay','Brightness', screenId [,outputId][,brightness]);
% Normally the SCREEN call is preferable because it's fast and requires no
% permissions. The solid new symptom under macOS Sierra is that the slider
% doesn't move when you change the brightness. Associated with that I find
% that the brightness doesn't always change, or changes at a later
% inappropriate time. I haven't yet managed to produce a reliably
% replicable fault, but have encountered many instances where my program
% detected, by calling the SCREEN command, that my attempt to set
% brightness had failed. Thus, this new BRIGHTNESS applescript is offered
% as a temporary work-around until Apple fixs the bug in their brightness
% API or we find a better way to work around it.
%
% APPLE SECURITY. The first time any application (e.g. MATLAB) calls
% Brightness.applescript, the request will be blocked and an error dialog
% window will appear saying the application is "not allowed assistive
% access." This means that the application needs an administrator's
% permission to access the System Preferences. A user with admin privileges
% should then click as requested to provide that permission. This needs to
% be done only once (for each application).
%
% MULTIPLE SCREENS: All my computers have only one screen, so I haven't had
% an opportunity to test the screenNumber argument.
%
% LINUX and WINDOWS. Applescript works only under macOS. When running
% under any operating system other that macOS, this program ignores the
% newLevel argument and always returns -1 as the oldLevel. It is
% conceivable that Apple's auto brightness feature is implemented on
% Macintoshes running Linux or Windows. If that applies to you, please
% consider enhancing this program to return a correct answer for that case,
% and sharing the result with me and the Psychtoolbox forum.
%
% See also:
% Screen ConfigureDisplay?
% AutoBrightness.m
% ScreenProfile.m
% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291
%
% Thanks to Mario Kleiner for explaining how macOS "brightness" works.
% Thanks to nick.peatfield@gmail.com for sharing his applescript code for
% dimmer.scpt and brighter.scpt.

if ~IsOSX
    % I believe that Applescript works only within macOS. It is conceivable
    % that Apple's display brightness control is implemented on Macintoshes
    % running Linux or Windows, in which case someone might enhance this
    % program to work for those situations.
    oldLevel = NaN;
    status = 1; % Signal failure on this unsupported OS:
    return;
end
[~,ver]=PsychtoolboxVersion;
v=ver.major*1000+ver.minor*100+ver.point;
useScreen3016= v<3016 && exist('Screen3016','file');
useScreenBrightness= v>=3016 || useScreen3016;
if nargin<2
    newLevel=[];
else
    if newLevel<0 || newLevel>1
        warning('newLevel %.1f should normally be in range 0.0 to 1.0.',newLevel)
    end
end
if nargin<1
    screenNumber=0;
end
if useScreenBrightness
    if useScreen3016
        if ~isempty(newLevel)
            Screen3016('ConfigureDisplay','Brightness',screenNumber,0,newLevel);
        end
        oldLevel=Screen3016('ConfigureDisplay','Brightness',screenNumber,0);
    else
        if ~isempty(newLevel)
            Screen('ConfigureDisplay','Brightness',screenNumber,0,newLevel);
        end
        oldLevel=Screen('ConfigureDisplay','Brightness',screenNumber,0);
    end
    return
end
try
    scriptPath = which('Brightness.applescript');
    command = ['osascript "' scriptPath '"']; % Double quotes cope with spaces in scriptPath.
    command = [command ' ' num2str(screenNumber)];
    if nargin>1
        command = [command ' ' num2str(newLevel)];
    end
    [status,oldString]=system(command); % Takes 5 s on MacBook Pro, 35 s on MacBook.
    oldLevel=str2double(oldString);
    if isempty(oldLevel) || oldLevel==-1
        error('Make sure you have admin privileges, and that System Preferences is not tied up in a dialog. Brightness applescript error: %s. ',oldString);
    end
catch e
    sca; % Close any user windows so error can be seen.
    rethrow(e);
end

