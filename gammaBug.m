% gammaBug.m
% Psychtoolbox Revision 7283 fixed the bug. December 8, 2015.
% This program is a trivial example of using the CLUT to control the color
% displayed by a particular color index. I would expect color 0 to be the
% first CLUT entry, and color 1 to the the second, and so on. It used to
% work that way until a month or so ago, when I updated my Mac OS. Now the
% 37th entry of the 1024-long gamma table controls color 1 and the 531th
% entry controls color 128. I'm willing to program around anything, but I
% don't understand what's going on. Any help would be welcome.
% denis.pelli@nyu.edu
window=Screen('OpenWindow',0,255);
[gamma, dacbits, reallutsize]=Screen('ReadNormalizedGammaTable',window);
fprintf('gamma size %dx%d, dacbits %d, reallutsize %d\n',size(gamma),dacbits,reallutsize);
gamma(37,1:3)=[0 1 0]; % green background of 1
gamma(531,1:3)=[1 0 0]; % red square of 128
Screen('LoadNormalizedGammaTable',window,gamma);
Screen('FillRect',window,[1 1 1]); % green background of 1
Screen('FillRect',window,[128 128 128],[0 0 200 200]); % red square of 128
Screen('Flip',window);
Speak('A red square on a green background. Click to quit.');
GetClicks;
sca;
