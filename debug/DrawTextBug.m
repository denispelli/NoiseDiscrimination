screen=0;
black=0;
white=1;
gray1=1/2;
Screen('Preference', 'SkipSyncTests', 1);
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