clear all
Screen('Preference', 'SkipSyncTests', 1);
o.screen=0;
screenRect=Screen('Rect',o.screen) % refers to write buffer, not display, on Retina display in HiDPI mode
screenRectReal=Screen('Rect',o.screen,1) % refers to write buffer, not display, on Retina display in HiDPI mode
% Detect HiDPI mode (probably occurs on Retina display)
resolution=Screen('Resolution',o.screen)
cal.hiDPIMultiple=resolution.width/RectWidth(screenRect)

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseRetinaResolution');
[win winRect]=PsychImaging('OpenWindow', o.screen);
winRect
winRect=Screen('Rect',win)
winRectReal=Screen('Rect',win,1)

screenRect=Screen('Rect',o.screen) % refers to write buffer, not display, on Retina display in HiDPI mode
screenRectReal=Screen('Rect',o.screen,1) % refers to write buffer, not display, on Retina display in HiDPI mode
% Detect HiDPI mode (probably occurs on Retina display)
resolution=Screen('Resolution',o.screen)
cal.hiDPIMultiple=resolution.width/RectWidth(screenRect)

sca
