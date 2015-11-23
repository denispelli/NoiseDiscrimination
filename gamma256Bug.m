% gamma256Bug.m
% This program is a trivial example of using the CLUT to control the color
% displayed by each color index. I would expect color 0 to be the first
% CLUT entry gamma(1,:), and color 1 to the the second, gamma(2,:), and so
% on. It used to work that way until a month or so ago, when I updated my
% Mac OS. Now, by trial and error, I discover the following mapping.
% Color index Gamma subscript
% 0           9
% 1           10
% 2           11
% 128         133
% 254         255
% 255         256
% The last two entries conform to the way it's supposed to be. It appears
% that the first 8 entries are not available to me, and that 256 colors
% have been squished into the remaining 248 color-table entries. I don't
% understand what's going on. Any help would be welcome.
% denis.pelli@nyu.edu
% P.S. This weird color mapping is identical on my MacBook Air and my
% MacBook Pro 3k. Does anyone  fail to get the 5 colored squares on a
% purple background?
window=Screen('OpenWindow',0,255);
% [gamma, dacbits, reallutsize]=Screen('ReadNormalizedGammaTable',window);
% fprintf('gamma size %dx%d, dacbits %d, reallutsize %d\n',size(gamma),dacbits,reallutsize);
Screen('FillRect',window,[255 255 255]); % "purple" background
Screen('FillRect',window,[0 0 0],[0 0 100 100]); % "blue" background of 0
Screen('FillRect',window,[1 1 1],[0 100 100 200]); % "green" square of 1
Screen('FillRect',window,[2 2 2],[0 200 100 300]); % "yellow" square of 2
Screen('FillRect',window,[128 128 128],[0 300 100 400]); % "green-blue" square of 128
Screen('FillRect',window,[254 254 254],[0 400 100 500]); % "red" square of 254
gamma=0:1/255:1;
gamma=[gamma' gamma' gamma'];
gamma(9,1:3)=[0 0 1]; % makes color index 0 show blue
gamma(10,1:3)=[0 1 0]; % makes color index 1 show green
gamma(11,1:3)=[1 1 0]; % makes color index 2 show yellow
gamma(133,1:3)=[1 0 1]; % make color index 128 show red-blue
gamma(255,1:3)=[1 0 0]; % makes color index 254 show red
gamma(256,1:3)=[0.5 0.5 1]; % makes color index 255 show purple
Screen('LoadNormalizedGammaTable',window,gamma);
Screen('Flip',window);
Speak('Click to quit.');
GetClicks;
RestoreCluts;
% RestoreCluts has no effect, so here's a quick and dirty restore.
gamma=0:1/255:1;
gamma=[gamma' gamma' gamma'];
Screen('LoadNormalizedGammaTable',window,gamma);
sca;
