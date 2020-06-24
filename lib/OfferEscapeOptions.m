function [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo,textMarginPix)
% [quitExperiment,quitBlock,skipTrial]=OfferEscapeOptions(window,oo,textMarginPix);
o=oo(1);
if nargin<2
    error('Need at least two args.');
end
assert(isfield(o,'textFont') && ~isempty(o.textFont));
if nargin<3
    textMarginPix=2*o.textSize;
end
if o.speakEachLetter && o.useSpeech
   Speak('Escape');
end
[textSize,textLineLength]=TextSizeToFit(window); % Optimal text size.
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
Screen('TextSize',window,textSize);
black=0;
Screen('Preference','TextAntiAliasing',0);
trials=0;
trialsDesired=0;
if isfield(o,'trials') && isfield(o,'trialsDesired')
    for oi=1:length(oo)
        trials=trials+oo(oi).trials;
        trialsDesired=trialsDesired+oo(oi).trialsDesired;
    end
end
DrawCounter(o);
% Set background color for DrawFormattedText.
Screen('DrawText',window,' ',0,0,black,backgroundColor,1);
lastBlock=isfield(o,'block') && isfield(o,'blocksDesired') && o.block>=o.blocksDesired;
if lastBlock
    nextBlockMsg='';
else
    nextBlockMsg='Or hit RETURN to proceed to the next block. ';
end
if nargout==3
    nextTrialMsg='Or hit SPACE to resume from where you escaped.';
else
   nextTrialMsg='';
end
%     'Hit RETURN to proceed to the next block. ' 
string=['You escaped. Any incomplete trial was canceled. ' ...
    'Hit ESCAPE again to quit the whole experiment. '...
    nextBlockMsg nextTrialMsg];
DrawFormattedText(window,string,textMarginPix,textMarginPix+0.5*textSize,black,textLineLength,[],[],1.3);
Screen('Flip',window);
WaitSecs(0.5); % Pause to prevent spurious double hit of escape.
answer=GetKeypress([spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
quitExperiment=ismember(answer,[escapeChar,graveAccentChar]);
quitBlock=ismember(answer,returnChar)||quitExperiment;
skipTrial=ismember(answer,' ');
if quitExperiment || quitBlock && oo(1).isLastBlock
    string='Done.';
elseif quitBlock
    string='Proceeding to next block. ...';
elseif skipTrial
    string='Proceeding to next trial. ...';
end
Screen('FillRect',window,backgroundColor);
DrawFormattedText(window,string,textMarginPix,textMarginPix+0.5*textSize,black,60,[],[],1.3);
DrawCounter(o);
Screen('Flip',window);
if o.useSpeech
    %     if quitExperiment || quitBlock && oo(1).isLastBlock
    %         Speak('Done.');
    %     elseif quitBlock
    %         Speak('Proceeding to next block.');
    %     elseif skipTrial
    %         Speak('Proceeding to next trial.');
    %     end
    Speak(string);
end
end