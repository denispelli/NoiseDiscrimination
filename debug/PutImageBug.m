% PutImageBug.m
% Mario explained that PutImage with high-res color has been broken for
% years, and will be fixed in the next major release of Psychtoolbox,
% presumably in summer 2017.
%
% PutImage doesn't work when I set:
% PsychImaging('AddTask','General','NormalizedHighresColorRange',1); 
%
% This program demonstrates the fault. It shows a series of images. It
% describes each in speech, and then waits for your click to proceed to the
% next image. All the images are fine except the ramps, because the ramps
% are rendered by PutImage.

% MacBook Pro (Retina, 15-inch, Mid 2015), MATLAB 8.6.0.267246 (R2015b),
% Psychtoolbox 3.0.14 beta, macOS 10.12.5

% denis.pelli@nyu.edu May 31, 2017

clear all
deferLoading=2; 
Screen('Preference','SkipSyncTests',1);
PsychImaging('PrepareConfiguration'); 
PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); 
PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
[window,screenRect]=PsychImaging('OpenWindow',0,1);
gamma=repmat((0:255)'/255,1,3);
Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);

Screen('FillRect',window,1);
Screen('Flip',window);
Speak('White. Click to continue.');
GetClicks;

gamma=repmat((0:255)'/255,1,3);
gamma(1+1,1:3)=[1 1 0]; % yellow in entry 1
Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);
Screen('FillRect',window,1/255,[0 0 300 300]);
Screen('Flip',window);
Speak('A yellow square on white. Click to continue.');
GetClicks;

gamma=repmat((0:255)'/255,1,3);
gamma(1+0,1:3)=0.7; % gray in entry 0
Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);
Screen('FillRect',window,0,[0 0 300 300]);
Screen('Flip',window);
Speak('A grey square on white. Click to continue.');
GetClicks;

gamma=repmat((0:255)'/255,1,3);
Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);

% Trying to produce grayscale ramp, but I get a black screen.
Screen('PutImage',window,(0:255)/255,screenRect); % a ramp
Screen('Flip',window);
Speak('A ramp, 0 to 1. Click to continue.');
GetClicks;

% Trying to produce grayscale ramp, but I get a black screen.
Screen('PutImage',window,uint8(0:255),screenRect); % a ramp
Screen('Flip',window);
Speak('An unsigned 8-bit integer ramp 0 to 255. Click to continue.');
GetClicks;

% Trying to produce grayscale ramp, but I get a black screen.
Screen('PutImage',window,0:255,screenRect); % a ramp
Screen('Flip',window);
Speak('A float ramp 0 to 255. Click to quit.');
GetClicks;

Screen('Close',window);
