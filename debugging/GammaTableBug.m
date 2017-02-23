% function GammaTableBug() 
%
% I figured out what's wrong. The sequence of luminances displayed on my
% MacBook Pro 15" is smoother than the values I loaded into the CLUT. The
% white (1.0) that I requested was coming out darker because the subsequent
% values in the lookup table are darker. When I replace the neighboring
% CLUT elements with white, then I get a good white. I suppose an Apple or
% AMD engineer thought it would be helpful to smooth the CLUT. (The error
% is not visible to ReadNormalizedGammaTable.) Can we prevent that?
%
% Loads a ramp into the first 12 elements of the CLUT using
% LoadNormalizedGammaTable. The ramp goes from black (0.0) to white (1.0).
% The ramp is always read back correctly by ReadNormalizedGammaTable.
% However, the resulting luminances are wrong on my MacBook Pro, even
% though they are correct on my MacBook Air. This demo displays the 12 CLUT
% entries all at once as an image, nominally a luminance ramp, in the upper
% left. The gamma values appear below, and are also printed on the screen.
% [0 0.6617 0.7001 0.7374 0.7661 .7916 .8137 0.8361 1.0 1 1 1] One of the CLUT
% entries is displayed as a square in the middle of the screen, for
% photometry. Each time you hit the shift key it advances to the next. A
% numerical display tells you the gamma value displayed. The displayed
% luminances are wrong, as explained below, even though
% ReadNormalizedGammaTable always returns exactly what I loaded.
%
% On my MacBookPro? (running PTB 3.0.14)?, the darker part of the ramp
% looks ok, but the nominally full white, 1.0, on the right, is less bright
% than the gray that precedes it. In now runs fine on my MacBook Air, now
% running PTB 3.0.14. However, ?while running PTB 3.0.13, the MacBook Air
% displayed the nominally black patch (0.0) as white, and all the
% nominally gray and white patches appeared black.?
%
% MacBookPro, macOS 10.12.3, MATLAB 8.6.0 (R2015b), Psychtoolbox 3.0.14
% MacBookAir, macOS 10.12.3, MATLAB 8.6.0 (R2015b), Psychtoolbox 3.0.14
% 
% The last time I wrote to you about CLUT problems, you advised me to use
% EnableCLUTMapping. That helped a lot at the time. However, right now,
% I have the same problem, with or without EnableCLUTMapping.
% 
% Denis Pelli February 22, 2017
try
   Screen('Preference', 'SkipSyncTests', 1);
   screen=0;
   AutoBrightness(screen,0);
   Screen('ConfigureDisplay','Brightness',screen,[],1);
   if 1
      PsychImaging('PrepareConfiguration');
      PsychImaging('AddTask','General','UseRetinaResolution');
      % Mario says EnableCLUTMapping is the ONLY way to get reasonable
      % color mapping behavior.
      PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize, high res
      [window,screenRect]=PsychImaging('OpenWindow',screen,255);
   else
      [window,screenRect]=Screen('OpenWindow',screen,255,[],[],[],[],[],kPsychNeedRetinaResolution);
   end
   [gammaLong,dacBits]=Screen('ReadNormalizedGammaTable',0);
   saveGamma=gammaLong;
   gamma=gammaLong(round(1+(size(gammaLong,1)-1)*(0:255)/255),1:3); % scrunch down to 256
   gamma(1:12,2)=[0 0.6617 0.7001 0.7374 0.7661 .7916 .8137 0.8361 1.0 1 1 1];
   gamma(1:12,1)=gamma(1:12,2); % Copy green channel to red and blue channels.
   gamma(1:12,3)=gamma(1:12,2);
   gammaLong=Expand(gamma,1,size(gammaLong,1)/size(gamma,1)); % Match length of gamma table that we read.
   Screen('LoadNormalizedGammaTable',0,gammaLong);
   Screen('TextSize',window,40);
   for i=1:12
      rect=CenterRect(screenRect/4,screenRect);
      Screen('FillRect',window,128,screenRect);
      Screen('PutImage',window,0:11,[0 0 200 50]);
      Screen('DrawText',window,sprintf('%.3f ',gamma(1:12,2)),40,100);
      Screen('FillRect',window,i-1,rect);
      Screen('DrawText',window,sprintf('gamma(%d)=%.3f',i,gamma(i,2)),40,200);
      Screen('DrawText',window,'Hit <shift> to continue.',40,300);
      Screen('Flip', window);
      KbStrokeWait();
      Beeper();
   end
   Screen('CloseAll');
   [newGammaLong,dacBits]=Screen('ReadNormalizedGammaTable',0);
   newGamma=newGammaLong(round(1+(size(newGammaLong,1)-1)*(0:255)/255),1:3); % scrunch down to 256
   fprintf('\ndesired vs. actual gamma, scrunched to 256\n');
   for i=1:12
      fprintf('%2d %5.3f %5.3f\n',i,gamma(i,2),newGamma(i,2));
   end
   fprintf('\ndesired vs. actual gamma, full %d\n',size(gammaLong,1));
   for i=1:12*4
      fprintf('%2d %5.3f %5.3f\n',i,gammaLong(i,2),newGammaLong(i,2));
   end
   Screen('LoadNormalizedGammaTable',0,saveGamma);
catch
   sca;
   Screen('LoadNormalizedGammaTable',0,saveGamma);
   psychrethrow(psychlasterror);
end