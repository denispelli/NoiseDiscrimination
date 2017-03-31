% function TestLoadGammaVisually
% TestLoadGammaVisually
% Draws text using the last bit, assuming an n-bit display, for n=1:12, to
% see how many bits the display supports. Such tiny steps are hard to see
% in the middle of the luminance range, but might be visible at the lowest
% end. This test benefits from any dithering performed by the video driver.
% The dark background level of gamma (used as dark ink in letters) is
% chosen to optimize visibility. That is the same throughout (except bottom
% instruction). The background strip for each line of text is background
% plus a 1-bit step.
% Denis Pelli March 25, 2017
useFractionOfScreen=0;
BackupCluts;
Screen('Preference','SkipSyncTests',1);
oldSetting = Screen('Preference', 'TextAntiAliasing', 0);
screen = 0;
dither=61696; % Appropriate for graphics chip AMD Radeon R9 M370X 2048 MB
% That chip is used in the MacBook Pro (Retina, 15-inch, Mid 2015).
% dither=0;
Screen('ConfigureDisplay','Dithering',screen,dither);
screenBufferRect = Screen('Rect',screen);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseRetinaResolution');
PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize,high res
if ~useFractionOfScreen
   [window,screenRect] = PsychImaging('OpenWindow',screen,255);
else
   [window,screenRect] = PsychImaging('OpenWindow',screen,255,round(useFractionOfScreen*screenBufferRect));
end
leading=round(screenRect(4)/12);
r=screenRect;
r(4)=leading;
x=100;
y=leading;
gamma=[0:255;0:255;0:255]'/255; % default linear gamma
Screen('TextSize',window,round(leading/2));
Screen('TextFont',window,'Verdana');
black=0;
backgroundGamma=.2;
g=backgroundGamma;
gamma(2,1:3)=[g g g];
for i=1:12
   bit=i;
   index=1+i;
   Screen('FillRect',window,index,r);
   y=round(r(4)-leading/3);
   r=OffsetRect(r,0,leading);
   text=sprintf('%d bit performance',bit);
   Screen('DrawText',window,text,x,y,1,index,1);
   g=2^(1-bit)+backgroundGamma;
   g=min(1,g);
   gamma(1+index,1:3)=[g g g];
end
r=AlignRect(r,screenRect,'left','bottom');
Screen('FillRect',window,255,r);
Screen('DrawText',window,'Click to quit.',x,round(r(4)-leading/3),black,255,1);
loadOnNextFlip = 2; % REQUIRED for reliable LoadNormalizedGammaTable.
Screen('LoadNormalizedGammaTable',window,gamma,loadOnNextFlip);
Screen('Flip',window);
GetClicks
Screen('Close',window);
RestoreCluts
