function [quitSession,quitRun,skipTrial]=OfferEscapeOptions(window,oo,instructionalMarginPix)
% [quitSession,quitRun,skipTrial]=OfferEscapeOptions(window,o,instructionalMargin)
if oo(1).speakEachLetter && oo(1).useSpeech
   Speak('Escape');
end
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
returnChar=char(13);
graveAccentChar='`';
backgroundColor=oo(1).gray1;
Screen('FillRect',window,backgroundColor);
Screen('TextFont',window,oo(1).textFont,0);
black=0;
Screen('Preference','TextAntiAliasing',0);
Screen('TextSize',window,oo(1).textSize);
% Set background color for DrawFormattedText.
Screen('DrawText',window,' ',0,0,black,backgroundColor,1);
if nargout==3
   string='You escaped. Any incomplete trial was canceled. Hit ESCAPE again to quit the whole session. Or hit RETURN to proceed with the next run. Or hit SPACE to proceed to the next trial.';
else
   string='You escaped. Hit ESCAPE again to quit the whole session. Or hit RETURN to proceed with the next run.';
end
DrawFormattedText(window,string,instructionalMarginPix,instructionalMarginPix+0.5*oo(1).textSize,black,60,[],[],1.1);
Screen('Flip',window);
answer=GetKeypress([spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],oo(1).deviceIndex);
quitSession=ismember(answer,[escapeChar,graveAccentChar]);
quitRun=ismember(answer,returnChar)||quitSession;
skipTrial=ismember(answer,' ');
if oo(1).useSpeech
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