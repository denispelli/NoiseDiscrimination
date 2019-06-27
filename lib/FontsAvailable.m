function ok=FontsAvailable(fonts)
% ok=FontsAvailable(fonts)
% "fonts" is a cell array of strings, each of which is a font name.
% Returns true only if all requested fonts are available.
ok=true;
if length(fonts)==0
    return
end
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
o.useFractionOfScreenToDebug=0.25;
o.screen=0;
% fprintf('Opening the window. ...\n'); % Newline for Screen warnings.
s=GetSecs;
screenBufferRect=Screen('Rect',o.screen);
r=round(o.useFractionOfScreenToDebug*screenBufferRect);
r=AlignRect(r,screenBufferRect,'right','bottom');
[window,o.screenRect]=Screen('OpenWindow',o.screen,1.0,r);
% fprintf('Done opening window (%.1f s).\n',GetSecs-s);
if Screen(window,'WindowKind')~=1
    error('Failed attempt to open window.');
end
%% CHECK FOR NEEDED FONTS
test=struct([]);
ok=true;
for f=fonts
    font=f{1};
    test(end+1).name=sprintf('%s font',font);
    Screen('TextFont',window,font);
    % Perform dummy DrawText call, in case the OS has deferred settings.
    Screen('DrawText',window,' ',0,0);
    oldFont=Screen('TextFont',window);
    test(end).value=streq(oldFont,font);
    if ~test(end).value
        warning('The font "%s" is not available. Please install it.',font);
        ok=false;
    end
    test(end).min=true;
    test(end).ok=test(end).value;
    test(end).help=['dir ' fullfile(myPath,'fonts')];
end
Screen('Close',window);