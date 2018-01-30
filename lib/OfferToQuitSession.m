function quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect)
% quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect)
if oo(1).speakEachLetter && oo(1).useSpeech
   Speak('Escape');
end
escapeKeyCode=KbName('ESCAPE');
% spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
graveAccentChar='`';
backgroundColor=oo(1).gray1;
Screen('FillRect',window,backgroundColor);
Screen('TextFont',window,oo(1).textFont,0);
black=0;
Screen('Preference','TextAntiAliasing',0);
Screen('TextSize',window,oo(1).textSize);
% Set background color for DrawFormattedText.
Screen('DrawText',window,' ',0,0,black,backgroundColor,1);
string='Quitting the run. Hit ESCAPE again to quit the whole session. Or hit RETURN to proceed with the next run.';
DrawFormattedText(window,string,instructionalMarginPix,instructionalMarginPix+0.5*oo(1).textSize,black,60,[],[],1.1);
Screen('Flip',window);
answer=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode],oo(1).deviceIndex);
quitSession=ismember(answer,[escapeChar,graveAccentChar]);
if oo(1).useSpeech
   if quitSession
      Speak('Escape. Done.');
   else
      Speak('Proceeding to next run.');
   end
end
Screen('FillRect',window);
end