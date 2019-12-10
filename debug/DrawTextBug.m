% This program produces the wrong image when you lack the external drawtext
% plugin. The second line SHOULD be on a white background, but when you
% lack the driver, it's drawn on a gray background, like the first line.
% Following the Psychtoolbox help text to load the driver fixes the
% problem. Denis Pelli, July 2017.

% PTB-WARNING: DrawText: Failed to load external drawtext plugin [dlopen(/Applications/Psychtoolbox/PsychBasic/PsychPlugins/libptbdrawtext_ftgl64.dylib, 10): Library not loaded: /opt/X11/lib/libfreetype.6.dylib
%   Referenced from: /Applications/Psychtoolbox/PsychBasic/PsychPlugins/libptbdrawtext_ftgl64.dylib
%   Reason: Incompatible library version: libptbdrawtext_ftgl64.dylib requires version 19.0.0 or later, but libfreetype.6.dylib provides version 18.0.0]. Retrying under generic name [libptbdrawtext_ftgl64.dylib].
% PTB-WARNING: DrawText: Failed to load external drawtext plugin 'libptbdrawtext_ftgl64.dylib' [dlopen(libptbdrawtext_ftgl64.dylib, 10): image not found]. Reverting to legacy text renderer.
% PTB-WARNING: DrawText: Functionality of Screen('DrawText') and Screen('TextBounds') may be limited and text quality may be impaired.
% PTB-WARNING: DrawText: Type 'help DrawTextPlugin' at the command prompt to receive instructions for troubleshooting.

screen=0;
black=0;
white=1;
gray1=1/2;
% Screen('Preference', 'SkipSyncTests', 1);
PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask','General','UseRetinaResolution');
% PsychImaging('AddTask','General','EnableNative11BitFramebuffer');
PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
window=PsychImaging('OpenWindow',screen,1.0);
Screen('FillRect',window,gray1);
Screen('DrawText',window,'Hello world! black on gray.',24,24,black,gray1);
Screen('DrawText',window,'Hello world! black on white. Click to quit.',24,48,black,white);
Screen('Flip',window);
GetClicks;
sca