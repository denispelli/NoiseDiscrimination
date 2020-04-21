function [oldSettings,failed] = MacDisplaySettings(arg1,arg2)
% [oldSettings,failed] = MacDisplaySettings([screenNumber,][newSettings])
% MacDisplaySettings allows you to temporarily override any user
% customization of the display, to allow user testing with a known
% calibration. Peek and poke several settings in the System Preferences:
% Displays panel. You can provide neither, either, or both arguments: the
% integer screenNumber and the struct newSettings. It's ok to provide just
% "newSettings", omitting the "screenNumber" (default is 0, the main
% screen). "newSettings" can include any number, from 0 to 5, of the
% allowed settings: brightness (in the range 0 and 1), automatically (true
% or false), trueTone (true or false), nightShiftSchedule ('Off','Custom',
% or 'Sunset to Sunrise'), and nighShiftManual (true or false).
%
% Typical uses include just typing the name to learn the settings:
%
% MacDisplaySettings
%
% ans =
%
%   struct with fields:
%
%             brightness: 0.8412
%          automatically: 1
%               trueTone: []
%     nightShiftSchedule: 'Off'
%       nightShiftManual: 0
%
%
% % Specify the new settings you want.
%
% newSettings.brightness=0.87;
% newSettings.automatically=false;
% newSettings.trueTone=false;
% newSettings.nightShiftSchedule='Off';
% newSettings.nightShiftManual=false;
%
% % Read old settings and set new settings.
%
% oldSettings=MacDisplaySettings(newSettings)
%
% % Use the display, ...
% % then restore the old settings as you found them.
%
% MacDisplaySettings(oldSettings);
%
% INTRODUCTION. Apple invites Macintosh users to adjust five parameters in
% the System Preferences Displays panel to customize their display color
% and brightness by enabling dynamic adjustments of all displayed images in
% response to personal preference, ambient lighting, and time of day. Many
% users enjoy this, but, unless reliably overriden, those adjustments
% defeat our efforts to calibrate the display one day and, at a later date,
% use our calibrations to reliably present an accurately specified
% stimulus. MacDisplaySettings aims to satisfy everyone, by allowing your
% calibration and test programs to use the computer in a fixed state,
% unaffected by user whims, ambient lighting, and time of day, while saving
% and later restoring whatever custom states the users have customized it
% to. MacDisplaySettings reports and controls five settings. It allows you
% to read their current states, set them to standard values for your
% critical work, and, when you're done, restore them to their original
% values. MacDisplaySettings monitors only those five System Preferences.
% Please let me know if we should add another (denis,pelli@nyu.edu).
%
% BRIGHTNESS, AUTOBRIGHTNESS, TRUE TONE, and NIGHT SHIFT. Get and set five
% fields in the macOS: System Preferences: Displays panel: 1. the
% "brightness" slider, 2. the "Automatically adjust brightness" checkbox,
% 3. the "True Tone" checkbox, 4. the Night Shift "schedule" pop up menu,
% and 5. the Night Shift "manual" checkbox. The function's newSettings
% argument has five fields, all optional: .brightness, .automatically,
% .trueTone, .nightShiftSchedule, and .nightShiftManual. You can set any
% combination of parameters, from none to all. The output argument
% oldSettings always reports the prior state of all available fields. (True
% Tone is not available on Macs manufactured before 2018.)
%
% All the work is done by the MacDisplaySettings.applescript run handler.
% MacDisplaySettings.m merely checks arguments for validity before passing
% them to the applescript, and minimally processes the returned values
% before returning them to the calling program.
%
% INPUT ARGUMENTS. newSettings.brightness, with range 0.0 to 1.0, indicates
% the desired brightness; .automatically, .trueTone, and .nightShiftManual
% are boolean; .nightShiftSchedule is a text field corresponding to any of
% the items in the Displays pop up menu ('Off', 'Custom', 'Sunset to
% Sunrise'). (nightShiftSchedule is compatible with international systems,
% provided you use the English field names when calling
% MacDisplaySettings.m.) If you omit the newSettings argument, then
% MacDisplaySettings will only peek, without poking. Any newSettings field
% that is omitted or set to [] is not disturbed.
%
% OUTPUT ARGUMENTS. oldSettings always returns all available settings. Note
% that .trueTone is only available in some Macs manufactured in 2018 or
% later. If the applescript failed, then all fields of oldSettings are [].
%
% TIMING. On a MacBook Pro, when System Preferences is closed,
% asking MacDisplaySettings to set all the fields typically takes 3
% s, but occasionally takes longer, e.g. 60 s. (I don't know what causes
% the occasionally long delays.)
%
% ERROR REPORTING is aggressive. Out-of-range or unrecognized arguments
% produce fatal erros. When reporting an error, if you have Psychtoolbox
% installed, then any open windows are first closed (by Psychtoolbox
% "sca"), so the error message won't be hidden behind your window.
%
% REQUIREMENTS: macOS and MATLAB. In its current form, MacDisplaySettings
% has only been tested on macOS Mojave (10.14) localized for USA. Earlier
% versions of this code supported macOS 10.9 to 10.14. It's designed to
% work internationally, but that hasn't been tested. It was tested on
% MATLAB 2019a, and very likely works on any version of MATLAB new enough
% to include structs. I think, but haven't checked, that the MATLAB code is
% pure basic MATLAB (no toolboxes) with one negligible exception. Before
% reporint an error, we check for the presence of the Psychtoolbox, if
% present then we call the Psychtoolbox routine "sca" (Screen Close All) to
% close any open windows, so the error won't be hidden behind your window.
% MacDisplaySettings.applescript needs only the macOS. It should work on
% any screen, but it's only been tested on the main screen.
%
% DEVELOPERS. To write Applescript like this, I strongly recommend that you
% buy the Script Debugger app from Late Night Software.
% https://latenightsw.com/ and the UI Browser app from UI Browser by
% PFiddlesoft. https://pfiddlesoft.com/uibrowser/ The Script Debugger is a
% good editor and debugger for Applescripts. The UI Browser allows you to
% discover the user interface targets in System Preferences that your
% script will read and set.
%
% ERROR REPORTING. Before issuing a MATLAB error, if Psychtoolbox is
% installed, then we always close any open Psychtoolbox window, by calling
% "sca" (Screen Close All). This prevents the annoying situation of
% wondering what's wrong because you can't see the error message hidden
% behind your Psychtoolbox window.
%
% APPLE SECURITY. If the user has not yet given permission for MATLAB to
% control the computer (in System Preferences:Security &
% Privacy:Accessibility), then we give an error alerting the user to grant
% this permission. The error dialog window will say the application
% (MATLAB) is "not allowed assistive access." The application needs an
% administrator's permission to access the System Preferences. A user with
% admin privileges should then click as requested to provide that
% permission. This needs to be done only once for each application.
%
% TECHNICAL: Adjusting the "brightness" setting in an LCD, controls the
% luminance of the fluorescent light that is behind the liquid crystal
% display. I believe that the "brightness" slider controls only the
% luminance of the source, and does not affect the liquid crystal itsef,
% which is driven by the GPU output. The luminance at the viewer's eye is
% presumably the product of the two factors: luminance of the source and
% transmission of the liquid crystal, at each wavelength.
%
% INSTALLATION. Just put both the .m and .applescript files anywhere in
% MATLAB's path.
%
% APPLESCRIPT IS SLOW. It uses the "System Preferences: Displays" panel,
% which takes about 1 s to open if it isn't already open. We set up the
% Brightness applescript to always leave System Preferences open, so you
% won't waste your observer's time waiting a second for System Preferences
% to open every time you call Brightness. Following rules of thumb that I
% saw in online applescript code, there are several 0.2 s delays. I imagine
% those delays could be reduced by specifically waiting on whatever
% reesource is needed. But the worst case runtime of 7 s on a MacBook Pro
% is fine for my usage.
%
% MULTIPLE SCREENS: All my computers have only one screen, so I haven't had
% an opportunity to test the screenNumber argument.
%
%% HISTORY
% June 25, 2017. Written by denis.pelli@nyu.edu for the Psychtoolbox.
% June 28, 2017, Fixed type of returned value, formerly a string, to now be
% a number.
% July 20, 2017. Enhanced to cope with spaces in the path to the
% applescript.
% December 1, 2018. Put try-catch block around the code, to
% gracefully cope with error while Screen window obscures the MATLAB
% Command Window. Eliminated the check for Screen window, which is no
% longer an issue.
% July 16,2019 Improved by looking at code here:
% https://apple.stackexchange.com/questions/272531/dim-screen-brightness-of-mbp-using-applescript-and-while-using-a-secondary-mon/285907
% August 2019. If Psychotoolbox version at least 3.0.16, then use Screen
% instead of Applescript.
% April 2020. Enhanced to read and set Brightness, Automatically, and True
% Tone, not just Brightness slider.
% April 14, 2020. Added loops (in the applescript) to wait for "tab group
% 1" before accessing it. I hope this will eliminate the occasional
% failures, in which MacDisplaySettings.m returns [] for brightness and
% automatic, but returns correct values for night shift.
%
% Thanks to Mario Kleiner for explaining how macOS "brightness" works.
% Thanks to nick.peatfield@gmail.com for sharing his applescript code for
% dimmer.scpt and brighter.scpt. And to Hormet Yiltiz for noting that we
% need to control Night Shift.
%
% See also:
% Screen ConfigureDisplay?
% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291
% Script Debugger app from Late Night Software. https://latenightsw.com/
% UI Browser app from UI Browser by PFiddlesoft. https://pfiddlesoft.com/uibrowser/

oldSettings.brightness=[];
oldSettings.automatically=[];
oldSettings.trueTone=[];
oldSettings.nightShiftSchedule=[];
oldSettings.nightShiftManual=[];
failed=false;

if ~IsOSX
    % I believe that Applescript works only within macOS. It is conceivable
    % that Apple's display brightness control is implemented on Macintoshes
    % running Linux or Windows, in which case someone might enhance this
    % program to work for those situations.
    failed = true; % Signal failure on this unsupported OS:
    return;
end
% The Psychtoolbox Screen function sets Brightness more quickly than
% applescript can, but we're setting five fields, of which Psychtoolbox
% only sets one, so there's no time savings in using Psychtoolbox. Most
% of the time spent in applescript is in getting acess to Screen
% Preferences. Once we're reading it, reading and writing extra fields
% doesn't take long.
useScreenBrightness=false;

switch nargin
    case 0
        screenNumber=0;
        newSettings=oldSettings;
    case 1
        switch class(arg1)
            case 'double'
                screenNumber=arg1;
                newSettings=oldSettings;
            case 'struct'
                screenNumber=0;
                newSettings=arg1;
            otherwise
                CloseWindows
                error('Single argument must be either double or struct.');
        end
    case 2
        screenNumber=arg1;
        newSettings=arg2;
    otherwise
        CloseWindows
        error('At most two arguments are allowed.');
end
if ~isstruct(newSettings)
    CloseWindows
    error('The newSettings argument must be a struct.');
end
if isfield(newSettings,'brightness') && ...
        ~isempty(newSettings.brightness) && ...
        (newSettings.brightness<0 || newSettings.brightness>1)
    CloseWindows
    error('newSettings.brightness %.1f must be in the range 0.0 to 1.0, otherwise [] to ignore it.',newSettings.brightness)
end
if isfield(newSettings,'automatically') && ...
        ~isempty(newSettings.automatically) && ...
        ~ismember(newSettings.automatically,0:1) && ...
        ~islogical(newSettings.automatically)
    CloseWindows
    error('newSettings.automatically %.1f must be 0 or 1, otherwise [] or omitted to ignore it.',newSettings.automatically)
end
if isfield(newSettings,'trueTone') && ...
        ~isempty(newSettings.trueTone) && ...
        ~ismember(newSettings.trueTone,0:1) && ...
        ~islogical(newSettings.trueTone)
    CloseWindows
    error('newSettings.trueTone %.1f must be 0 or 1, otherwise [] or omitted to ignore it.',newSettings.trueTone)
end
if isfield(newSettings,'nightShiftSchedule') && ~isempty(newSettings.nightShiftSchedule) && ...
        ~ismember(newSettings.nightShiftSchedule,{'Off','Custom','Sunset to Sunrise'})
    CloseWindows
    error('newSettings.nightShiftSchedule %.1f must be ''Off'',''Custom'', or ''Sunset to Sunrise'', otherwise [] or omitted to ignore it.',...
        newSettings.nightShiftSchedule)
end
if isfield(newSettings,'nightShiftManual') && ...
        ~isempty(newSettings.nightShiftManual) && ...
        ~ismember(newSettings.nightShiftManual,0:1) && ...
        ~islogical(newSettings.nightShiftManual)
    CloseWindows
    error('newSettings.nightShiftManual %.1f must be 0 or 1, otherwise [] or omitted to ignore it.',...
        newSettings.nightShiftManual)
end
fields=fieldnames(newSettings);
ok=ismember(fields,fieldnames(oldSettings));
if any(~ok)
    CloseWindows
    error('Unknown newSetting field ''%s''.',fields{find(~ok,1)});
end
if useScreenBrightness
    if isfield(newSettings,'brightness') && ~isempty(newSettings.brightness)
        oldSettings.brightness=Screen('ConfigureDisplay','Brightness',...
            screenNumber,0,newSettings.brightness);
    else
        oldSettings.brightness=...
            Screen('ConfigureDisplay','Brightness',screenNumber,0);
    end
    newSettings.brightness=[]; % Remove it from the to-do list.
end
try
    % Call MacDisplaySettings.applescript
    scriptPath = which('MacDisplaySettings.applescript');
    command = ['osascript "' scriptPath '"']; % Double quotes cope with spaces in scriptPath.
    command = [command ' ' num2str(screenNumber)];
    if ~isfield(newSettings,'brightness') || isempty(newSettings.brightness)
        newSettings.brightness=-1;
    end
    if ~isfield(newSettings,'automatically') || ...
            isempty(newSettings.automatically)
        newSettings.automatically=-1;
    end
    if ~isfield(newSettings,'trueTone') || isempty(newSettings.trueTone)
        newSettings.trueTone=-1;
    end
    if ~isfield(newSettings,'nightShiftSchedule') || ...
            isempty(newSettings.nightShiftSchedule)
        newSettings.nightShiftSchedule=-1;
    else
        % Convert pop up menu choice from text to index.
        i=find(ismember({'Off','Custom','Sunset to Sunrise'},...
            newSettings.nightShiftSchedule));
        if i==0
            CloseWindows
            error('newSettings.nightShiftSchedule=''%s'' but should be one of: ''Off'',''Custom'',''Sunset to Sunrise''.',...
                newSettings.nightShiftSchedule);
        end
        newSettings.nightShiftSchedule=i;
    end
    if ~isfield(newSettings,'nightShiftManual') || ...
            isempty(newSettings.nightShiftManual)
        newSettings.nightShiftManual=-1;
    end
    command = [command ' ' num2str(newSettings.brightness) ' '...
        num2str(newSettings.automatically) ' ' ...
        num2str(newSettings.trueTone) ' '...
        num2str(newSettings.nightShiftSchedule) ' ' ...
        num2str(newSettings.nightShiftManual)];
    [failed,oldString]=system(command); % Takes 4 to 9 s on MacBook Pro.
    %     fprintf('%s\n',oldString);
    if failed
        CloseWindows
        error('Applescript error: failed=%d, oldString=%s.',...
            failed,oldString);
    end
    if streq('-99',oldString(1:3))
        CloseWindows
        warning(['If you haven''t already, please unlock System '...
            'Preferences: Security & Privacy: Privacy and give MATLAB ' ...
            'permission for Full Disk Access and Automation.')];
        error('Applescript returned error: %s',oldString);
    end
    [v,count,errMsg]=sscanf(oldString,'%f, %d, %d, %d, %d',5);
    if count<3 || ~isempty(errMsg)
        warning('sscanf processed %d of 5 values. sscanf error: %s',...
            count,errMsg);
    end
    if count>=1
        oldSettings.brightness=v(1);
    end
    if count>=2
        oldSettings.automatically=v(2);
    end
    if count>=3
        oldSettings.trueTone=v(3);
    end
    if count>=4
        oldSettings.nightShiftSchedule=v(4);
    end
    if count>=5
        oldSettings.nightShiftManual=v(5);
    end
    if oldSettings.brightness==-1
        oldSettings.brightness=[];
    end
    if oldSettings.automatically==-1
        oldSettings.automatically=[];
    end
    if oldSettings.trueTone==-1
        oldSettings.trueTone=[];
    end
    % Convert pop up menu choice from index to text.
    switch oldSettings.nightShiftSchedule
        case 1
            oldSettings.nightShiftSchedule='Off';
        case 2
            oldSettings.nightShiftSchedule='Custom';
        case 3
            oldSettings.nightShiftSchedule='Sunset to Sunrise';
        case -1
            oldSettings.nightShiftSchedule='';
        otherwise
            CloseWindows
            error('Illegal values of oldSettings.nightShiftSchedule %d.',...
                oldSettings.nightShiftSchedule);
    end
    if oldSettings.nightShiftManual==-1
        oldSettings.nightShiftManual=[];
    end
    oldSettings.automatically=logical(oldSettings.automatically);
    oldSettings.trueTone=logical(oldSettings.trueTone);
    oldSettings.nightShiftManual=logical(oldSettings.nightShiftManual);
    if failed || isempty(oldSettings.brightness)
        warning('Applescript failed. Here follows some diagnostic output.');
        failed
        oldString
        oldSettings
        CloseWindows
        error(['MacDisplaySettings.applescript failed. ' ...
            'Make sure you have admin privileges, ' ...
            'and that System Preferences is not tied up in a dialog. ' ...
            'Brightness applescript error: %s. '],oldString);
    end
catch e
    CloseWindows
    rethrow(e);
end
end

function CloseWindows
if exist('PsychtoolboxVersion','file') && ~isempty(Screen('Windows'))
    % Close any user windows to make sure that error can be seen.
    sca
end
end
