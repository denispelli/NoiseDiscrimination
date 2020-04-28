function testLuminanceCalibration()
% testLuminanceCalibration
% Tests the results of CalibrateLuminance by presenting test patterns
% similar to those calibrated, indicating the nominal luminance, which
% allows you to verify the luminance with a photometer.
% Denis Pelli February 2017
try
   Screen('Preference', 'SkipSyncTests', 1);
   screen=0;
   settings.brightness=1;
   settings.automatically=false;
   settings.trueTone=false;
   settings.nightShiftSchedule='Off';
   settings.nightShiftManual=false;
   oldSettings=MacDisplaySettings(settings);
   if true
      PsychImaging('PrepareConfiguration');
      PsychImaging('AddTask','General','UseRetinaResolution');
      % Mario says EnableCLUTMapping is the ONLY way to get reasonable
      % color mapping behavior.
      PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize, high res
      [window,screenRect]=PsychImaging('OpenWindow',screen,255);
   else
      [window,screenRect]=Screen('OpenWindow',screen,255,[],[],[],[],[],kPsychNeedRetinaResolution);
   end
   % Compute and load a CLUT
   cal=OurScreenCalibrations(screen);
   for j=1:2
      cal.LFirst=min(cal.old.L);
      cal.LLast=max(cal.old.L);
      LMean=(cal.LFirst+cal.LLast)/2;
      cal.LFirst=LMean+(cal.LFirst-LMean)/4^(j-1);
      cal.LLast=LMean+(cal.LLast-LMean)/4^(j-1);
      cal.nFirst=2;
      cal.nLast=8;
      cal=LinearizeClut(cal);
      Screen('LoadNormalizedGammaTable',window,cal.gamma,2);
      Screen('Flip',window);
      nL=8;
      for i=1:nL
         L=(cal.LLast-cal.LFirst)*(i-1)/(nL-1)+cal.LFirst;
         rect=CenterRect(screenRect/4, screenRect);
         Screen('FillRect',window,128,screenRect);
         Screen('PutImage',window,2:8,[100 0 150 50]);
         pix=IndexOfLuminance(cal,L);
         Screen('FillRect',window,pix,rect);
         Screen('TextSize',window,30);
         Screen('DrawText',window,sprintf('%.3f ',cal.gamma(1:9,2)),40,100);
         Screen('TextSize',window,40);
         Screen('DrawText',window,sprintf('Range %.1f to %.1f cd/m^2',cal.LFirst,cal.LLast),40,150);
         Screen('DrawText',window,sprintf('%.1f cd/m^2   (DAC green %.3f)',L,cal.gamma(pix+1,2)),40,200);
         Screen('DrawText',window,'Hit <shift> to continue.',40,250);
         Screen('Flip', window);
         KbStrokeWait();
         Beeper();
      end
   end
   Screen('CloseAll');
   Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
   MacDisplaySettings(oldSettings);
catch me
   sca;
   if exist('cal','var') && isfield(cal,'old') && isfield(cal.old,'gamma')
      Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
   end
   MacDisplaySettings(oldSettings);
   rethrow(me);
end