function bounds=DrawCounter(oo)
% bounds=DrawCounter(oo);
% Use o.counterPlacement to specify alignment with stimulusRect.

% It would be great to display "INVALID DATA" when in debugging mode. I.e.
% whenever o.useFractionOfScreenToDebug~=0 or o.skipScreenCalibration=true.

global window scratchWindow scratchRect
global blockTrial blockTrials
persistent counterSize counterBounds
% Display counter in lower right corner.
if isempty(window)
    error('Require open window.');
end
if Screen('WindowKind',window)==0
    error('window is invalid');
end
if Screen('WindowKind',scratchWindow)==0
    error('scratchWindow is invalid');
end
Screen('TextFont',window,'Verdana');
message='';
if ~isempty(blockTrial)
    message=sprintf('Trial %d of %d. ',blockTrial,blockTrials);
end
message=sprintf('%sBlock %d of %d.',message,oo(1).block,oo(1).blocksDesired);
if isempty(scratchWindow)
    [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window);
end
counterSize=round(0.6*oo(1).textSize);
Screen('TextSize',scratchWindow,counterSize);
Screen('TextFont',scratchWindow,Screen('TextFont',window));
counterBounds=TextBounds(scratchWindow,message,1);
r=oo(1).screenRect;
if isfield(oo(1),'stimulusRect')
    r(3)=oo(1).stimulusRect(3);
end
r=InsetRect(r,counterSize/4,counterSize/4);
switch oo(1).counterPlacement
    case 'bottomRight'
        counterBounds=AlignRect(counterBounds,r,'right','bottom');
    case 'bottomLeft'
        counterBounds=AlignRect(counterBounds,r,'left','bottom');
    case 'bottomCenter'
        counterBounds=AlignRect(counterBounds,r,'center','bottom');
end
black=BlackIndex(window);
oldTextSize=Screen('TextSize',window,counterSize);
% Use whatever background is currently in use. Don't insist on white.
Screen('DrawText',window,message,counterBounds(1),counterBounds(4),black,[],1);
Screen('TextSize',window,oldTextSize);
bounds=counterBounds;
end