Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(0);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','AllViews','EnableCLUTMapping');
[window,screenRect] = PsychImaging('OpenWindow',0,255);
Screen('FillRect',window,255);
Screen('Flip',window);
Speak('Supposed to be white. Click to continue.');
GetClicks;
gamma=Screen('ReadNormalizedGammaTable',window);
gamma=interp1(gamma,1:(size(gamma,1)-1)/255:size(gamma,1),'pchip'); % Down sample to 256.
Screen('LoadNormalizedGammaTable',window,gamma,2);
Speak('Now is white. Click to continue.');
Screen('Flip',window);
GetClicks;
rect=screenRect;
rect(3)=floor(rect(4)/256);
dx=rect(3);
for i=0:255
    Screen('FillRect',window,i,rect);
    rect=OffsetRect(rect,dx,0);
end
Screen('Flip',window);
Speak('A ramp. Click to continue.');
GetClicks;
fprintf('gamma size %dx%d, dacbits %d, reallutsize %d\n',size(gamma),dacbits,realLutSize);
for i=2
    gamma(i,1:3)=[1 1 0]; % yellow background
end
Screen('LoadNormalizedGammaTable',window,gamma,2);
Screen('FillRect',window,1,[0 0 300 300]);
Screen('Flip',window);
Speak('A yellow square on white. Click to quit.');
GetClicks;
sca;
