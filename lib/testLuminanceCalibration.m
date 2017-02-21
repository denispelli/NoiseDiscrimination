function testLuminanceCalibration()
% testLuminanceCalibration
% Tests the results of CalibrateLuminance by presenting test patterns
% similar to those calibrated, now with anticipated luminance shown.
% Denis Pelli February 2017
try
    Screen('Preference', 'SkipSyncTests', 1);
    screen=0;
    AutoBrightness(screen,0);
    Screen('ConfigureDisplay','Brightness',screen,[],1);
    [w,screenRect]=Screen('OpenWindow',screen,255,[],[],[],[],[],kPsychNeedRetinaResolution);
    
    % Compute and load a CLUT
    cal=OurScreenCalibrations(0);
    cal.LFirst=min(cal.old.L);
    cal.LLast=max(cal.old.L);
    LMean=(cal.LFirst+cal.LLast)/2;
    cal.nFirst=2;
    cal.nLast=254;
    cal=LinearizeClut(cal);
    
    [w,screenRect]=Screen('OpenWindow',screen,255,[],[],[],[],[],kPsychNeedRetinaResolution);
    Screen('LoadNormalizedGammaTable',0,cal.gamma);
    Screen('FillRect',w,0);
    Screen('TextSize',w,24);
    Screen('Flip',w);
    nL = 8;
    for i=1:nL
        L=(cal.LLast-cal.LFirst)*(i-1)/(nL-1)+cal.LFirst;
        rect=CenterRect(screenRect/4, screenRect);
        Screen('FillRect',w,128,screenRect);
        pix=IndexOfLuminance(cal,L);
        Screen('FillRect',w,pix,rect);
        Screen('DrawText',w,sprintf('%.1f cd/m^2   (DAC green %.3f)',L,cal.gamma(pix+1,2)),40,100);
        Screen('DrawText',w,'Hit any key to continue.',40,140);
        Screen('Flip', w);
        KbStrokeWait();
        Beeper();
    end
    Screen('CloseAll');
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end