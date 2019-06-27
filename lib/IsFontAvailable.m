function ok=IsFontAvailable(font)
% ok=IsFontAvailable(font)
% "font" is a string or a cell array of strings. Each string is a font name.
% Returns a logical array, one element per font, indicating true if
% available.
if isempty(font)
    ok=logical([]);
    return
end
switch class(font)
    case 'cell'
        fonts=font;
    case 'char'
        fonts={font};
end
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
o.useFractionOfScreenToDebug=0.25;
o.screen=0;
% fprintf('Opening the window. ...\n'); % Newline for Screen warnings.
s=GetSecs;
screenBufferRect=Screen('Rect',o.screen);
r=round(o.useFractionOfScreenToDebug*screenBufferRect);
r=AlignRect(r,screenBufferRect,'right','bottom');
windows=Screen('Windows');
oldVerbosity=Screen('Preference','Verbosity',0);
if isempty(windows)
    % Nothings open, so open a window.
    [window,o.screenRect]=Screen('OpenWindow',o.screen,1.0,r);
    if Screen(window,'WindowKind')~=1
        error('Failed attempt to open window.');
    end
else
    % There already is an open window, so open an offscreen window.
    window=[];
    for i=1:length(windows)
        if Screen(windows(i),'WindowKind')==1
            [window,o.screenRect]=Screen('OpenOffscreenWindow',o.screen,1.0,r);
            break;
        end
    end
    if Screen(window,'WindowKind')~=-1
        error('Failed attempt to open offscreen window.');
    end
end
% fprintf('Done opening window (%.1f s).\n',GetSecs-s);

%% CHECK FOR NEEDED FONTS
test=struct([]);
ok=logical([]);
for i=1:length(fonts)
    font=fonts{1};
    test(end+1).name=sprintf('%s font',font);
    Screen('TextFont',window,font);
    % Perform dummy DrawText call, in case the OS has deferred settings.
    Screen('DrawText',window,' ',0,0);
    oldFont=Screen('TextFont',window);
    test(end).value=streq(oldFont,font);
    ok(i)=test(end).value;
    if ~test(end).value
        warning('The font "%s" is not available. Please install it.',font);
    end
    test(end).min=true;
    test(end).ok=test(end).value;
    test(end).help=['dir ' fullfile(myPath,'fonts')];
end
Screen('Close',window);
Screen('Preference','Verbosity',oldVerbosity);
