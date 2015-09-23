% I hoped this would show the problem I'm having with NoiseDiscrimation.m
% when running under Windows. NoiseDiscrimation fails to show the fixation
% mark on the next flip after it is drawn. I copied the more relevant
% Screen commands but this program runs fine on Windows. All the programs
% run fine on Macintosh.
% Denis July 4, 2015
[savedGamma,dacBits]=Screen('ReadNormalizedGammaTable',0); 
Screen('Preference','SkipSyncTests',1);
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel',0);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings',1);
screenRect=[0 0 200 200];
window=Screen('OpenWindow',0,255,screenRect);
[scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window,[],[0 0 400 400]);
Screen('FillRect',scratchWindow,255);
Screen('Close',scratchWindow);
Screen('FillRect',window);
displayImage=Screen('GetImage',window);
Screen('DrawText',window,'Hello world',10,50,0,255,1);
fixationLines=[-100 100 0 0 ;0 0 -100 100];
Screen('DrawLines',window,fixationLines,4,0,[100 100]); % fixation
gamma=[0:255;0:255;0:255]'/255;
Screen('LoadNormalizedGammaTable',window,gamma,1); % Wait for Flip.
Screen('Flip', window); % Show gray screen at LMean with fixation and crop marks.
WaitSecs(1);
% Screen('DrawLines',window,fixationLines,4,0,[100 100]); % fixation
Screen('Flip', window); % Show gray screen at LMean with fixation and crop marks.
WaitSecs(1);
sca