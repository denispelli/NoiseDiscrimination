function [quitSession,quitRun,skipTrial]=OfferEscapeOptions(window,oo,instructionalMarginPix)
% [quitSession,quitRun,skipTrial]=OfferEscapeOptions(window,o,instructionalMargin);
o=oo(1);
if o.speakEachLetter && o.useSpeech
   Speak('Escape');
end
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
returnChar=char(13);
graveAccentChar='`';
backgroundColor=o.gray1;
Screen('FillRect',window,backgroundColor);
Screen('TextFont',window,o.textFont,0);
black=0;
Screen('Preference','TextAntiAliasing',0);
Screen('TextSize',window,o.textSize);
% Set background color for DrawFormattedText.
Screen('DrawText',window,' ',0,0,black,backgroundColor,1);
lastRun=isfield(o,'runNumber') && isfield(o,'runsDesired') && o.runNumber>=o.runsDesired;
if lastRun
    nextRunMsg='';
else
    nextRunMsg='Or hit RETURN to proceed with the next run. ';
end
if nargout==3
   nextTrialMsg='Or hit SPACE to proceed to the next trial.';
else
   nextTrialMsg='';
end
string=['You escaped. Any incomplete trial was canceled. Hit ESCAPE again to quit the whole session. '...
    nextRunMsg nextTrialMsg];
DrawFormattedText(window,string,instructionalMarginPix,instructionalMarginPix+0.5*o.textSize,black,60,[],[],1.1);
Screen('Flip',window);
answer=GetKeypress([spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
quitSession=ismember(answer,[escapeChar,graveAccentChar]);
quitRun=ismember(answer,returnChar)||quitSession;
skipTrial=ismember(answer,' ');
if o.useSpeech
    if quitSession
        Speak('Done.');
    elseif quitRun
        Speak('Proceeding to next run.');
    elseif skipTrial
        Speak('Proceeding to next trial.');
    end
end
Screen('FillRect',window);
end