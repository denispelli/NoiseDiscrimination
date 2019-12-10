% CLUTMappingBug.m
%
% This program demonstrated a bug in the software CLUT mapping that
% appeared in the May 2017 release of Psychtoolbox. It was fixed today in a
% new version of PsychImaging.m, distributed on the forum by Mario Kleiner
% in anticipation of the next Psychtoolbox update.
%
% This program rigorously tests the rounding rule used to convert floating
% point color (argument to FillRect) to selection of the index in the
% software CLUT.
%
% MacBook Pro (Retina, 15-inch, Mid 2015), MATLAB 8.6.0.267246 (R2015b),
% macOS 10.12.5, Psychtoolbox 3.0.14 beta, with May 31, 2017 version of
% PsychImaging.m.
%
% This program loads the CLUT with a gray ramp, and then sets any two CLUT
% entries (upEntry and downEntry) to green. It then uses FillRect to fill
% upper half of screen with the color of upEntry, and the lower half with
% downEntry. If everything works, then both color values should display the
% same color, and the whole screen will be green.
%
% Either top or bottom or both will not be green if something's wrong with
% the rounding rule used to convert the floating point color argument of
% FillRect to an index in the CLUT.
%
% Using the May 31, 2017 version of PsychImaging.m, when I
% EnableNative10BitFramebuffer, I can't find any fault. The software CLUT
% works perfectly, even with CLUTMapLength=2048, which I need for 11-bit
% precision.
%
% It also works fine if i'm in normal 8-bit mode with CLUTMapLength=256.
% 
% However, I do get failures in 8-bit mode with CLUTMapLength=2048, but I
% don't know if anyone ever needs that combination.

% denis.pelli@nyu.edu
% May 31, 2017

clear o
o.CLUTMapLength=2048; % enough for 11-bit precision.
% o.CLUTMapLength=256; % enough for 8-bit precision.
upEntry=2047;
downEntry=1;
o.screen = 0;
try
   o.maxEntry=o.CLUTMapLength-1;
   % Screen('Preference','SkipSyncTests',1);
   PsychImaging('PrepareConfiguration');
   if 1
      % On my MacBook Pro, the bug is less severe when I enable this.
      PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
   end
   PsychImaging('AddTask','General','UseRetinaResolution'); % Irrelevant to the bug.
   PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
   PsychImaging('AddTask','AllViews','EnableCLUTMapping',o.CLUTMapLength,1); % clutSize, high res
   window=PsychImaging('OpenWindow',0,1.0);
   screenRect=Screen('Rect',window);
   upRect=screenRect;
   upRect(4)=upRect(4)/2;
%    Screen('ConfigureDisplay','Dithering',0,61696); % Irrelevant to the bug.
   Screen('Flip',window);
   Screen('FillRect',window,downEntry/o.maxEntry);
   Screen('FillRect',window,upEntry/o.maxEntry,upRect);
   Screen('TextFont',window,'Verdana',0);
   Screen('TextSize',window,36);
   Screen('DrawText',window,'Click to load green into software CLUT.',50,70,0,1,1);
   Screen('Flip',window);
   GetClicks;
   gamma=repmat(((0:o.maxEntry)/o.maxEntry)',1,3); % gray ramp
   gamma(1+downEntry,:)=[0 1 0]; % green
   gamma(1+upEntry,:)=[0 1 0]; % green
   Screen('LoadNormalizedGammaTable',window,gamma,2); % Load software CLUT at flip.
   Screen('DrawText',window,'Whole screen should be green. Click to quit.',50,70,0,1,1);
   Screen('Flip',window);
   GetClicks;
   sca; % screen close all
catch
   sca; % screen close all
   psychrethrow(psychlasterror);
end
