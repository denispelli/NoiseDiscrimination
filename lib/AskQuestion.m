function [reply,o]=AskQuestion(oo,text)
% [reply,o]=AskQuestion(oo,text)
% "text" argument is a struct with several fields, each containing a
% string: text.big, text.small, text.fine, text.question,
% text.setTextSizeToMakeThisLineFit. We optionally return "o" which the
% input o, but some fields may be modified: o.textSize o.quitExperiment
% o.quitBlock and o.skipTrial. If "text" has the field
% text.setTextSizeToMakeThisLineFit then o.textSize is adjusted to make the
% line just fit horizontally within o.screenRect. text.big, text.small,
% text.fine, and text.question are strings. '/n' produces a newline. Each
% string starts on a new line. "reply" is the string typed by the observer,
% terminated by RETURN.
global ff
o=oo(1);
if isempty(o.window) || ismember(o.observer,o.algorithmicObservers)
    reply='';
    return
end
escapeChar=char(27);
graveAccentChar='`';
black=0;
% o.textSize=TextSizeToFit(o.window); % Leave as set by user.
ListenChar(2); % no echo
Screen('FillRect',o.window,o.gray1);
Screen('TextSize',o.window,o.textSize);
Screen('TextFont',o.window,o.textFont,0);
DrawCounter(o);

% Display question.
x=2*o.textSize;
y=o.screenRect(4)/2-(1+ceil(length(text.big)/o.textLineLength))*1.3*o.textSize;
Screen('DrawText',o.window,' ',0,0,black,o.gray1); % Set background.
if isfield(text,'big')
    assert(ischar(text.big));
    [~,y]=DrawFormattedText(o.window,text.big,...
        x,y,black,...
        o.textLineLength,[],[],1.3);
    y=y+1.3*o.textSize;
end
if isfield(text,'small')
    assert(ischar(text.small));
    scalar=0.6;
    sz=round(scalar*o.textSize);
    scalar=sz/o.textSize;
    Screen('TextSize',o.window,sz);
    [~,y]=DrawFormattedText(o.window,text.small,...
        x,y,black,...
        o.textLineLength/scalar,[],[],1.3);
    y=y+1.3*scalar*o.textSize;
end
if isfield(text,'fine')
    assert(ischar(text.fine));
    scalar=0.35;
    sz=round(scalar*o.textSize);
    scalar=sz/o.textSize;
    Screen('TextSize',o.window,sz);
    y=o.screenRect(4)-o.textSize;
    [~,y]=DrawFormattedText(o.window,text.fine,...
        x,y,black,...
        o.textLineLength/scalar,[],[],1.3);
end
if IsWindows
    background=[];
else
    background=o.gray1;
end
% Screen('Flip',o.window,0,1); % DGP June 26, 2019.
% fprintf('%d: o.deviceIndex %.0f.\n',MFileLineNr,o.deviceIndex);
Screen('TextSize',o.window,o.textSize);
[reply,terminatorChar]=GetEchoString2(o.window,text.question,...
    x,0.82*o.screenRect(4),black,background,1,o.deviceIndex);
if ismember(terminatorChar,[escapeChar graveAccentChar])
    [o.quitExperiment,o.quitBlock,o.skipTrial]=...
        OfferEscapeOptions(o.window,oo,o.textMarginPix);
    if o.quitExperiment
        ffprintf(ff,'*** User typed ESCAPE twice. Experiment terminated.\n');
    elseif o.quitBlock
        ffprintf(ff,'*** User typed ESCAPE. Block terminated.\n');
    else
        ffprintf(ff,'*** User typed ESCAPE, but chose to continue.\n');
    end
end
Screen('FillRect',o.window,o.gray1);
DrawCounter(o);
Screen('Flip',o.window); % Flip screen, to let observer know her answer was accepted.
end % function AskQuestion
