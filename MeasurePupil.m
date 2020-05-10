function mm=MeasurePupil()
% MeasurePupil;
%
%% GLOBALS, FILES
global  cal
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this M file
if ismac && ~ScriptingOkShowPermission
   error(['Please give MATLAB permission to control the computer. ',...
      'You''ll need admin privileges to do this.']);
end
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');

%% DEFAULT VALUE FOR EVERY "o" PARAMETER
% They are overridden by what you provide in the argument struct oIn.
if nargin < 1 || ~exist('oIn','var')
   oIn.noInputArgument=true;
end
o=[];
o.clutMapLength=2048; % enough for 11-bit precision.
o.useNative10Bit=false;
o.useNative11Bit=true;
o.ditherCLUT=61696; % Use this only on Denis's PowerBook Pro and iMac 5k.
o.ditherCLUT=false; % As of June 28, 2017, there is no measurable effect of this dither control.
o.enableCLUTMapping=false; % 
o.assessBitDepth=false;
o.luminanceFactor=1;
o.useFractionOfScreenToDebug=false; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
o.observer=''; % Name of person or existing algorithm.
o.pupilDiameterMm=[];
o.useFilter=false;
o.filterTransmission=1;
o.desiredRetinalIlluminanceTd=[];
o.retinalIlluminanceTd=[];

%% SCREEN PARAMETERS
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
screenBufferRect=Screen('Rect',o.screen);
screenRect=Screen('Rect',o.screen,1);
resolution=Screen('Resolution',o.screen);
if o.useFractionOfScreenToDebug
   screenRect=round(o.useFractionOfScreenToDebug*screenRect);
end

%% GET SCREEN CALIBRATION cal
cal.screen=o.screen;
cal=OurScreenCalibrations(cal.screen);
if isfield(cal,'gamma')
   cal=rmfield(cal,'gamma');
end
if cal.screen > 0
   fprintf('Using external monitor.\n');
end
cal.clutMapLength=o.clutMapLength;
o.cal=cal;
if ~isfield(cal,'old') || ~isfield(cal.old,'L')
   fprintf('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
   error('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
end

%% Must call Brightness while no window is open.
useBrightnessFunction=true;
if useBrightnessFunction
   Brightness(cal.screen,cal.brightnessSetting); % Set brightness.
   cal.brightnessReading=Brightness(cal.screen); % Read brightness.
   if cal.brightnessReading==-1
      % If it failed, try again. The first attempt sometimes fails.
      % Not sure why. Maybe it times out.
      cal.brightnessReading=Brightness(cal.screen); % Read brightness.
   end
   if isfinite(cal.brightnessReading) && abs(cal.brightnessSetting-cal.brightnessReading)>0.01
      error('Set brightness to %.2f, but read back %.2f',cal.brightnessSetting,cal.brightnessReading);
   end
end
if ~useBrightnessFunction
   try
      % Caution: Screen ConfigureDisplay Brightness gives a fatal error
      % if not supported, and is unsupported on many devices, including
      % a video projector under macOS. We use try-catch to recover.
      % NOTE: It was my impression in summer 2017 that the Brightness
      % function (which uses AppleScript to control the System
      % Preferences Display panel) is currently more reliable than the
      % Screen ConfigureDisplay Brightness feature (which uses a macOS
      % call). The Screen call adjusts the brightness, but not the
      % slider in the Preferences Display panel, and macOS later
      % unpredictably resets the brightness to the level of the slider,
      % not what we asked for. This is a macOS bug in the Apple call
      % used by Screen.
      for i=1:3
         Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
         cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
         %          Brightness(cal.screen,cal.brightnessSetting);
         %          cal.brightnessReading=Brightness(cal.screen);
         if abs(cal.brightnessSetting-cal.brightnessReading)<0.01
            break;
         elseif i==3
            error('Tried three times to set brightness to %.2f, but read back %.2f',...
               cal.brightnessSetting,cal.brightnessReading);
         end
      end
   catch ME
      cal.brightnessReading=NaN;
   end
end
if cal.ScreenConfigureDisplayBrightnessWorks
	s=GetSecs;
	ffprintf(ff,'Calling MacDisplaySettings. ... ');
	newSettings.brightness=cal.brightnessSetting;
	newSettings.automatically=false;
	newSettings.trueTone=false;
	newSettings.nightShiftSchedule='Off';
	newSettings.nightShiftManual=false;
	oldDisplaySettings=MacDisplaySettings(cal.screen,newSettings);
	ffprintf(ff,'Done (%.1f s)\n',GetSecs-s);
   ffprintf(ff,'Setting "brightness" to %.2f, on a scale of 0.0 to 1.0;\n',cal.brightnessSetting);
end

%% TRY-CATCH BLOCK CONTAINS ALL CODE IN WHICH WINDOW IS OPEN
try
   %% OPEN WINDOW
   Screen('Preference', 'SkipSyncTests',1);
   Screen('Preference','TextAntiAliasing',1);
   if o.useFractionOfScreenToDebug
      ffprintf(ff,'Using tiny window for debugging.\n');
   end
   PsychImaging('PrepareConfiguration');
   if o.flipScreenHorizontally
      PsychImaging('AddTask','AllViews','FlipHorizontal');
   end
   if cal.hiDPIMultiple ~= 1
      PsychImaging('AddTask','General','UseRetinaResolution');
   end
   if o.useNative10Bit
      PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
   end
   if o.useNative11Bit
      PsychImaging('AddTask','General','EnableNative11BitFramebuffer');
   end
   PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
   if o.enableCLUTMapping
      o.maxEntry=o.clutMapLength-1; % moved here on Feb. 4, 2018
      PsychImaging('AddTask','AllViews','EnableCLUTMapping',o.clutMapLength,1); % clutSize, high res
      cal.gamma=repmat((0:o.maxEntry)'/o.maxEntry,1,3); % Identity
      % Set hardware CLUT to identity, without assuming we know the
      % size. On Windows, the only allowed gamma table size is 256.
      gamma=Screen('ReadNormalizedGammaTable',cal.screen);
      maxEntry=length(gamma)-1;
      gamma(:,1:3)=repmat((0:maxEntry)'/maxEntry,1,3);
      Screen('LoadNormalizedGammaTable',cal.screen,gamma,0);
   else
      warning('You need EnableCLUTMapping to control contrast.');
   end
   if o.enableCLUTMapping % How we use LoadNormalizedGammaTable
      loadOnNextFlip=2; % Load software CLUT at flip.
   else
      loadOnNextFlip=true; % Load hardware CLUT: 0. now; 1. on flip.
   end
   if ~o.useFractionOfScreenToDebug
      [window,screenRect]=PsychImaging('OpenWindow',cal.screen,1.0);
   else
      r=round(o.useFractionOfScreenToDebug*screenBufferRect);
      r=AlignRect(r,screenBufferRect,'right','bottom');
      [window,screenRect]=PsychImaging('OpenWindow',cal.screen,1.0,r);
   end
   screenRect=Screen('Rect',cal.screen,1); % screen rect in UseRetinaResolution mode
   if o.useFractionOfScreenToDebug
      screenRect=round(o.useFractionOfScreenToDebug*screenRect);
   end
   o.desiredRetinalIlluminanceTd=100;
   while 1
      
      %% ASK OBSERVER NAME
      if isempty(o.observer)
         ListenChar(2); % no echo
         Screen('FillRect',window,o.gray1);
         Screen('TextSize',window,o.textSize);
         Screen('TextFont',window,o.textFont,0);
         Screen('DrawText',window,'Hello Observer,',...
            2*o.textSize,screenRect(4)/2-5*o.textSize,black,o.gray1);
         Screen('DrawText',window,'Please slowly type your name followed by RETURN.',...
            2*o.textSize,screenRect(4)/2-3*o.textSize,black,o.gray1);
         Screen('TextSize',window,round(o.textSize*0.35));
         Screen('DrawText',window,...
             double('NoiseDiscrimination Test, Copyright 2016, 2017, 2018, 2019, Denis Pelli. All rights reserved.'),...
             2*o.textSize,screenRect(4)-o.textSize,black,o.gray1,1);
         Screen('TextSize',window,o.textSize);
         if IsWindows
            background=[];
         else
            background=o.gray1;
         end
         [name,terminatorChar]=GetEchoString2(window,'Observer name:',2*o.textSize,0.82*screenRect(4),black,background,1,o.deviceIndex);
         if ismember(terminatorChar,[escapeChar graveAccentChar])
            o.quitBlock=true;
            o.quitExperiment=OfferEscapeOptions(window,o,textMarginPix);
            if o.quitExperiment
               ffprintf(ff,'*** User typed ESCAPE twice. Experiment terminated.\n');
            else
               ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
            end
            ListenChar(0);
            ShowCursor;
            sca;
            return
         end
         o.observer=name;
         Screen('FillRect',window,o.gray1);
         % Keep the temporary window open until we open the main one, so observer
         % knows program is running.
      end
           
      %% SET SIZES OF SCREEN ELEMENTS: text, stimulusRect, etc.
      textFont='Verdana';
      o.stimulusRect=2*round(o.stimulusRect/2);
      
      %% GET WINDOW READY
      % We can safely use this no-echo mode AND collect keyboard responses
      % without worrying about writing to MATLAB console/editor.
      ListenChar(2); % no echo
      KbName('UnifyKeyNames');
      
      % Recommended by Mario Kleiner, July 2017.
      % The first 'DrawText' call triggers loading of the plugin, but may fail.
      Screen('DrawText',window,' ',0,0,0,1,1);
      o.drawTextPlugin=Screen('Preference','TextRenderer')>0;
      if ~o.drawTextPlugin
         warning('The DrawText plugin failed to load. See warning above.');
      end
      ffprintf(ff,'o.drawTextPlugin=%d %% 1 needed for accurate text rendering.\n',o.drawTextPlugin);
      
      
      % Compare hardware CLUT with identity.
      gammaRead=Screen('ReadNormalizedGammaTable',window);
      maxEntry=size(gammaRead,1)-1;
      gamma=repmat(((0:maxEntry)/maxEntry)',1,3);
      delta=gammaRead(:,2)-gamma(:,2);
      ffprintf(ff,'RMS difference between identity and read-back of hardware CLUT (%dx%d): %.9f\n',...
         size(gammaRead),rms(delta));
      if exist('cal','var')
         gray=mean([firstGrayClutEntry lastGrayClutEntry])/o.maxEntry; % CLUT color code for gray.
         assert(gray*o.maxEntry == round(gray*o.maxEntry)); % Sum of first and last is even, so gray is integer.
         LMin=min(cal.old.L);
         LMax=max(cal.old.L);
         LBackground=mean([LMin, LMax]); % Desired background luminance.
         LBackground=LBackground*(1+(rand-0.5)/32); % Tiny jitter, ±1.5%
         LBackground=o.luminanceFactor*LBackground;
         if o.assessLowLuminance
            LBackground=0.8*LMin+0.2*LMax;
         end
         % CLUT entry 1: o.gray1
         % First entry is black. Second entry is o.gray1. We have
         % two clut entries that produce the same gray. One (gray) is in
         % the middle of the CLUT and the other is at a low entry, near
         % black. The benefit of having small o.gray1 is that we get better
         % blending of letters written (as black=0) on that background by
         % Screen DrawText.
         o.gray1=1/o.maxEntry;
         assert(o.gray1*o.maxEntry <= firstGrayClutEntry-1);
         % o.gray1 is between black and the darkest stimulus luminance.
         cal.gamma(1,1:3)=0; % Black.
         cal.LFirst=LBackground;
         cal.LLast=LBackground;
         cal.nFirst=o.gray1*o.maxEntry;
         cal.nLast=o.gray1*o.maxEntry;
         cal=LinearizeClut(cal);
         
         % CLUT entries for stimulus.
         cal.LFirst=LMin;
         cal.LLast=LBackground+(LBackground-LMin); % Symmetric about LBackground.
         cal.nFirst=firstGrayClutEntry;
         cal.nLast=lastGrayClutEntry;
         cal=LinearizeClut(cal);
         ffprintf(ff,'Size of cal.gamma %d %d\n',size(cal.gamma));
         o.contrast=nan;
         Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
      end
      Screen('FillRect',window,o.gray1);
      Screen('FillRect',window,gray,o.stimulusRect);
      Screen('Flip',window); % Load gamma table
      if ~isfinite(window) || window == 0
         fprintf('error\n');
         error('Screen OpenWindow failed. Please try again.');
      end
      black=0; % CLUT color code for black.
      white=1; % CLUT color code for white.
      gray=mean([firstGrayClutEntry lastGrayClutEntry])/o.maxEntry; % Will be a CLUT color code for gray.
      Screen('FillRect',window,o.gray1);
      Screen('FillRect',window,gray,o.stimulusRect);
      Screen('Flip',window); % Screen is now all gray, at LBackground.
      if ~isempty(window)
         screenRect=Screen('Rect',window,1);
         screenWidthPix=RectWidth(screenRect);
      else
         screenWidthPix=1280;
      end
      
      %% MONOCULAR?
      if ~isfield(o,'eyes')
         error('Please set o.eyes to ''left'',''right'', or ''both''.');
      end
      if ~ismember(o.eyes,{'left','right','both'})
         error('o.eyes==''%s'' is not allowed. It must be ''left'',''right'', or ''both''.',o.eyes);
      end
      if ~exist('oOld','var') || ~isfield(oOld,'eyes') || GetSecs-oOld.secs>5*60 || ~streq(oOld.eyes,o.eyes)
         Screen('TextSize',window,o.textSize);
         Screen('TextFont',window,'Verdana');
         Screen('FillRect',window,o.gray1);
         string='';
         if streq(o.eyes,'both')
            Screen('Preference','TextAntiAliasing',1);
            string='Please use both eyes.\nHit RETURN to continue, or ESCAPE to quit.';
            Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
            DrawFormattedText(window,string,2*o.textSize,2.5*o.textSize,black,o.textLineLength,[],[],1.3);
            Screen('Flip',window); % Display request.
            if o.speakInstructions
               Speak('Please use both eyes. Hit RETURN to continue, or ESCAPE to quit.');
            end
            response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode]);
            if ismember(response,[escapeChar,graveAccentChar])
               if o.speakInstructions
                  Speak('Quitting.');
               end
               o.quitBlock=true;
               o.quitExperiment=true;
               sca;
               ListenChar;
               return
            end
         end
         if ismember(o.eyes,{'left','right'})
            Screen('Preference','TextAntiAliasing',1);
            string=sprintf('Please use just your %s eye. Cover your other eye.\nHit RETURN to continue, or ESCAPE to quit.',o.eyes);
            Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
            DrawFormattedText(window,string,2*o.textSize,2.5*o.textSize,black,o.textLineLength,[],[],1.3);
            Screen('Flip',window); % Display request.
            if o.speakInstructions
               string=sprintf('Please use just your %s eye. Cover your other eye. Hit RETURN to continue, or ESCAPE to quit.',o.eyes);
               Speak(string);
            end
            response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode]);
            if ismember(response,[escapeChar,graveAccentChar])
               if o.speakInstructions
                  Speak('Quitting.');
               end
               o.quitBlock=true;
               o.quitExperiment=true;
               sca;
               ListenChar;
               return
            end
         end
         string='';
         
         white1=1;
         black0=0;
         Screen('Preference','TextAntiAliasing',1);
         
         Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
         DrawFormattedText(window,msg,2*o.textSize,2.5*o.textSize,black,o.textLineLength,[],[],1.3);
         Screen('Flip',window,0,1); % "Starting new run ..."
         
         while 1
            %% ASK PUPIL SIZE
            ListenChar(2); % no echo
            Screen('FillRect',window,o.gray1);
            Screen('TextSize',window,o.textSize);
            Screen('TextFont',window,o.textFont,0);
            Screen('DrawText',window,'Please provide your current estimate of pupil diameter in mm,',...
               2*o.textSize,screenRect(4)/2-7*o.textSize,black,o.gray1);
            Screen('DrawText',window,'followed by RETURN. Please type slowly. (Just RETURN for default value.)',...
               2*o.textSize,screenRect(4)/2-5*o.textSize,black,o.gray1);
            if IsWindows
               background=[];
            else
               background=o.gray1;
            end
            [name,terminatorChar]=GetEchoString2(window,'Pupil diameter (mm):',...
               2*o.textSize,0.82*screenRect(4),black,background,1,o.deviceIndex);
            if ~isempty(name)
               o.pupilDiameterMm=str2num(name);
            end
            if ismember(terminatorChar,[escapeChar graveAccentChar])
               o.quitBlock=true;
               o.quitExperiment=OfferEscapeOptions(window,o,textMarginPix);
               if o.quitExperiment
                  ffprintf(ff,'*** User typed ESCAPE twice. Experiment terminated.\n');
               else
                  ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
               end
               ListenChar(0);
               ShowCursor;
               sca;
               return
            end
            Screen('FillRect',window,o.gray1);
            
            %% PUPIL SIZE
            % Measured December 2017 by Darshan.
            % Monocular right eye viewing of 250 cd/m^2 screen.
            if isempty(o.pupilDiameterMm)
               switch lower(o.observer)
                  case 'hortense'
                     o.pupilDiameterMm=3.3;
                  case 'katerina'
                     o.pupilDiameterMm=5.0;
                  case 'shenghao'
                     o.pupilDiameterMm=5.3;
                  case 'yichen'
                     o.pupilDiameterMm=4.4;
                  case 'darshan'
                     o.pupilDiameterMm=4.9;
               end
            end
            
            %% RETINAL ILLUMINANCE
            LOld=mean([min(cal.old.L) max(cal.old.L)]);
            if ~isempty(o.desiredRetinalIlluminanceTd)
               if isempty(o.pupilDiameterMm)
                  error(['When you request o.desiredRetinalIlluminanceTd, ' ...
                     'you must also specify o.pupilDiameterMm or an observer with known pupil size.']);
               end
               % o.filterTransmission refers to optical neutral density filters or
               % sunglasses.
               % o.luminanceFactor refers to software attenuation of luminance from
               % the standard middle of attainable range.
               td=o.filterTransmission*LOld*pi*o.pupilDiameterMm^2/4;
               o.luminanceFactor=o.desiredRetinalIlluminanceTd/td;
               o.luminanceFactor=min([1 max([0.125 o.luminanceFactor])]); % bounds
            end
            o.retinalIlluminanceTd=o.luminanceFactor*o.filterTransmission*LOld*pi*o.pupilDiameterMm^2/4;
            
            %% STIMULUS PARAMETERS
            o.textSize=round(o.textSizeDeg*o.pixPerDeg);
            o.textSizeDeg=o.textSize/o.pixPerDeg;
            o.textLineLength=floor(1.7*RectWidth(screenRect)/o.textSize);
            o.lineSpacing=1.5;
            o.stimulusRect=InsetRect(screenRect,0,o.lineSpacing*1.2*o.textSize);
            BackupCluts(o.screen);
            LBackground=(max(cal.old.L)+min(cal.old.L))/2;
            o.maxLRange=2*min(max(cal.old.L)-LBackground,LBackground-min(cal.old.L));
            % We use nearly the whole clut (entries 2 to 254) for stimulus generation.
            % We reserve first and last (0 and o.maxEntry), for black and white.
            firstGrayClutEntry=2;
            lastGrayClutEntry=o.clutMapLength-2;
            assert(lastGrayClutEntry<o.maxEntry);
            assert(firstGrayClutEntry>1);
            assert(mod(firstGrayClutEntry+lastGrayClutEntry,2) == 0) % Must be even, so middle is an integer.
            o.minLRange=0;
         end
         vBase=interp1(cal.old.L,cal.old.G,L);
         Screen('FillRect',window,i/1024);
         
         %% CLOSE WINDOW
         if Screen(window,'WindowKind') == 1
            % Screen takes many seconds to close. This gives us a white screen
            % while we wait.
            Screen('FillRect',window);
            Screen('Flip',window); % White screen
         end
         ListenChar(0); % flush
         ListenChar;
         sca; % Screen('CloseAll'); ShowCursor;
         RestoreCluts;
         if ismac
            AutoBrightness(cal.screen,1); % Restore autobrightness.
         end
         if ~isempty(window)
            Screen('Preference','VisualDebugLevel',oldVisualDebugLevel);
            Screen('Preference','SuppressAllWarnings',oldSupressAllWarnings);
         end
         fclose(dataFid); dataFid=-1;
         Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
         catch
            %% MATLAB catch
            ListenChar;
            sca; % screen close all
            if exist('cal','var') && isfield(cal,'old') && isfield(cal.old,'gamma')
               Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
            end
           MacDisplaySettings(cal.screen,oldSettings);
            if dataFid>-1
               fclose(dataFid);
               dataFid=-1;
            end
            [~,neworder]=sort(lower(fieldnames(o)));
            o=orderfields(o,neworder);
            psychrethrow(psychlasterror);
      end
   end % function mm=MeasurePupil
end