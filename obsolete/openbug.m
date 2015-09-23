screen=0;
screenRect=Screen('Rect',screen)
screenDisplayRect=Screen('Rect',screen,1)
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseRetinaResolution');
PsychImaging('AddTask','AllViews','EnableCLUTMapping'); % may not be needed
[w,r]=PsychImaging('OpenWindow',screen,255,[0 0 100 100]);
r
sca
clear all;
Screen('Preference', 'SkipSyncTests', 1);
screen=0;
resolution=Screen('Resolution',screen);
screenBufferRect=Screen('Rect',screen);
screenDisplayRect=Screen('Rect',screen,1);
fprintf('*** Before opening any window.\n');
fprintf('resolution %dx%d\n',resolution.width, resolution.height);
fprintf('screenBufferRect %dx%d\n',screenBufferRect(3),screenBufferRect(4));
fprintf('screenDisplayRect %dx%d\n',screenDisplayRect(3),screenDisplayRect(4));
window=Screen('OpenWindow',screen);
fprintf('*** After opening window in the usual way.\n');
resolution=Screen('Resolution',screen);
screenBufferRect=Screen('Rect',screen);
screenDisplayRect=Screen('Rect',screen,1);
fprintf('resolution %dx%d\n',resolution.width, resolution.height);
fprintf('screenBufferRect %dx%d\n',screenBufferRect(3),screenBufferRect(4));
fprintf('screenDisplayRect %dx%d\n',screenDisplayRect(3),screenDisplayRect(4));
windowBufferRect=Screen('Rect',window);
windowDisplayRect=Screen('Rect',window,1);
fprintf('windowBufferRect %dx%d\n',windowBufferRect(3),windowBufferRect(4));
fprintf('windowDisplayRect %dx%d\n',windowDisplayRect(3),windowDisplayRect(4));
Screen('Flip', window,0,1); % Save snapshot.
img=Screen('GetImage',window);
fprintf('GetImage %dx%d\n',size(img,2),size(img,1));
sca
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseRetinaResolution');
window=PsychImaging('OpenWindow',screen);
screenRect=screenDisplayRect;
window=PsychImaging('OpenWindow',screen,255,screenRect,[],[],[],0);
fprintf('*** After opening window with PsychImaging and UseRetinaResolution\n');
resolution=Screen('Resolution',screen);
screenBufferRect=Screen('Rect',screen);
screenDisplayRect=Screen('Rect',screen,1);
fprintf('resolution %dx%d\n',resolution.width, resolution.height);
fprintf('screenBufferRect %dx%d\n',screenBufferRect(3),screenBufferRect(4));
fprintf('screenDisplayRect %dx%d\n',screenDisplayRect(3),screenDisplayRect(4));
windowBufferRect=Screen('Rect',window);
windowDisplayRect=Screen('Rect',window,1);
fprintf('windowBufferRect %dx%d\n',windowBufferRect(3),windowBufferRect(4));
fprintf('windowDisplayRect %dx%d\n',windowDisplayRect(3),windowDisplayRect(4));
Screen('Flip', window,0,1); % Save snapshot.
img=Screen('GetImage',window);
fprintf('GetImage %dx%d\n',size(img,2),size(img,1));
sca
