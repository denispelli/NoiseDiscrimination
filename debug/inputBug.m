% [Psychtoolbox] [Bugs & Features] GetChar and kbwait vs input, May 10, 2020
% Mario Kleiner
% All keystrokes recorded by GetChar() and detected by KbCheck etc.
% also go to Matlab, unless properly suppressed via ListenChar().
% Nothing new here over the last 15 years.

% This works, as it should:

input('1. Hit RETURN to continue.','s');
fprintf('2. Hit RETURN to continue.\n');
ListenChar(2);
GetChar;
FlushEvents;
ListenChar(0);
input('3. Hit RETURN to continue.','s');
input('4. Hit RETURN to continue.','s');
fprintf('5. Hit RETURN to continue.\n');
ListenChar(-1);
KbStrokeWait;
ListenChar(0);
input('6. Hit RETURN to continue.','s');

if false
    input('1. Hit RETURN to continue.','s');
    fprintf('2. Hit RETURN to continue.');
    % FlushEvents;
    % while CharAvail
    %     GetChar;
    % end
    GetChar;
    % while CharAvail
    %     GetChar;
    % end
    input('3. Hit RETURN to continue.','s');
    input('4. Hit RETURN to continue.','s');
    fprintf('5. Hit RETURN to continue.\n');
    FlushEvents
    KbWait;
    FlushEvents;
    input('6. Hit RETURN to continue.','s');
end