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
Screen('FillRect',window);
Screen('TextFont',window,oo(1).textFont,0);
black=0;
white=255;
Screen('Preference','TextAntiAliasing',0);
% Screen('TextSize',window,round(oo(1).textSize*0.35));
% Screen('DrawText',window,double('NoiseDiscrimination Test, Copyright 2016, 2017, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,white,1);
Screen('TextSize',window,oo(1).textSize);
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