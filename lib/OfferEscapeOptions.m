function [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo,textMarginPix)
% [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,o,textMarginPix);
o=oo(1);
if o.speakEachLetter && o.useSpeech
   Speak('Escape');
end
o.textSize=TextSizeToFit(window); % Set optimum text size.
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
trials=0;
trialsDesired=0;
if isfield(o,'trials')&&isfield(o,'trialsPerBlock')
    for oi=1:length(oo)
        trials=trials+oo(oi).trials;
        trialsDesired=trialsDesired+oo(oi).trialsPerBlock;
    end
end
if isfield(o,'blockNumber')&&isfield(o,'blocksDesired')&&isfield(o,'textSize')
   message=sprintf('Trial %d of %d. Block %d of %d.',trials,trialsDesired,o.blockNumber,o.blocksDesired);
   if isfield(o,'experiment')
      message=[message ' Experiment "' o.experiment '".'];
   end
   Screen('DrawText',window,message,o.textSize/2,o.textSize/2,black,backgroundColor);
   y=o.textSize;
else
    y=0;
end
Screen('TextSize',window,o.textSize);
% Set background color for DrawFormattedText.
Screen('DrawText',window,' ',0,0,black,backgroundColor,1);
lastBlock=isfield(o,'blockNumber') && isfield(o,'blocksDesired') && o.blockNumber>=o.blocksDesired;
if lastBlock
    nextBlockMsg='';
else
    nextBlockMsg='Or hit RETURN to proceed to the next block. ';
end
if nargout==3
   nextTrialMsg='Or hit SPACE to proceed to the next trial.';
else
   nextTrialMsg='';
end
string=['You escaped. Any incomplete trial was canceled. Hit ESCAPE again to quit the whole experiment. '...
    nextBlockMsg nextTrialMsg];
DrawFormattedText(window,string,textMarginPix,textMarginPix+0.5*o.textSize+y,black,60,[],[],1.1);
Screen('Flip',window);
answer=GetKeypress([spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
quitExperiment=ismember(answer,[escapeChar,graveAccentChar]);
quitBlock=ismember(answer,returnChar)||quitExperiment;
skipTrial=ismember(answer,' ');
if o.useSpeech
    if quitExperiment
        Speak('Done.');
    elseif quitBlock
        Speak('Proceeding to next block.');
    elseif skipTrial
        Speak('Proceeding to next trial.');
    end
end
Screen('FillRect',window);
end