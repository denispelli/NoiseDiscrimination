function textSize=TextSizeToFit(window,lineOfText,o)
% Set textSize so our lineOfText just fits on screen.
global screenRect % Might be reduced to produce a small display for debugging.
if nargin<1
    error('You must provide "window" when calling textSize=TextSizeToFit(window,lineOfText,o).');
end
if nargin<2
    lineOfText='Standard line of text xx xxxxx xxxxxxxx xx XXXXXX. xxxx.....xx';
end
if nargin<3
    o.textMarginPix=round(0.08*min(RectWidth(screenRect),RectHeight(screenRect)));
    o.textSize=39;
    o.textFont='Verdana';
end
Screen('TextSize',window,o.textSize);
Screen('TextFont',window,o.textFont,0);
font=Screen('TextFont',window);
if ~streq(font,o.textFont)
    warning off backtrace
    warning('The o.textFont "%s" is not available. Using %s instead.',o.textFont,font);
    warning on backtrace
end
boundsRect=Screen('TextBounds',window,lineOfText);
fraction=RectWidth(boundsRect)/(RectWidth(screenRect)-2*o.textMarginPix);
% Adjust textSize so our line fits perfectly.
textSize=round(o.textSize/fraction);
Screen('TextSize',window,textSize);
end
