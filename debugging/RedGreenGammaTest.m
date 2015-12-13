% This test failed in October 2015 (using latest software) but now works
% fine in the latest Psychtoolbox release:
% PTB-INFO: This is Psychtoolbox-3 for Apple OS X, under Matlab 64-Bit (Version 3.0.12 - Build date: Nov 27 2015).
% Denis Pelli December 2015.

window=Screen('OpenWindow',0,255);
LoadIdentityClut(window);
Screen('Flip', window);
[gamma, dacbits, reallutsize]=Screen('ReadNormalizedGammaTable',window);
fprintf('gamma size %dx%d, dacbits %d, reallutsize %d\n',size(gamma),dacbits,reallutsize);

lut = (0:1/255:1)' * ones(1,3);
lut(2,1:3) = [0 1 0]; % green background of 1
lut(129,1:3)=[1 0 0]; % red square of 128

Screen('LoadNormalizedGammaTable',window,lut);
Screen('FillRect',window,[1 1 1]); % green background of 1
Screen('FillRect',window,[128 128 128],[0 0 200 200]); % red square of 128
Screen('Flip',window);
Speak('A red square on a green background. Click to quit.');
GetClicks;
sca;

