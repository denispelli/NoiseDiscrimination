% LoadGammaDemo
% Denis Pelli, 12/8/15, 2/23/17
%
% This program works properly (showing the yellow and grey squares) only
% with EnableCLUTMapping and deferred loading of the CLUT, deferLoad = 1 or
% 2. Otherwise the squares appear as black, because the CLUT "loading"
% fails to affect the first and second CLUT entry. Mario Kleiner says that
% this is the only way to achieve reliable control of color mapping.
%
% It's easy to mistakenly think you don't need EnableCLUTMapping, as
% without it, LoadNormalizedGammaTable mostly works. But the misses are
% serious. It becomes difficult or impossible to change the low-numbered
% entries in the CLUT. This program successfully changes the first two CLUT
% entries. I was unable to do that without EnableCLUTMapping.
%
% It appears that in this mode ReadNormalizedGammaTable is useless, as it
% returns a table that is unaffected by the otherwise successfull calls to
% LoadNormalizedGammaTable.
%
% It appears than when deferLoad=2, LoadNormalizedGammaTable does not
% return any output arguments. Weird, since that's the only situation in
% which "success" is useful.
sca
deferLoading=2; % Must be 1 or 2. REQUIRED.
Screen('Preference', 'SkipSyncTests', 1);
if 1
   PsychImaging('PrepareConfiguration'); % REQUIRED
   PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % REQUIRED
      PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
   [window,screenRect]=PsychImaging('OpenWindow',0,255);
else
%    [window,screenRect]=Screen('OpenWindow',0,255);
end

if 0
   o.retina=0;
   o.useNative10Bit=0;
   o.enableCLUTMapping=1;
   o.CLUTMapLength=256;
   o.maxEntry=o.CLUTMapLength-1;
   o.useFractionOfScreen=0;
   cal.screen=0;
   PsychImaging('PrepareConfiguration');
   if o.retina
      PsychImaging('AddTask','General','UseRetinaResolution');
   end
      PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
   if o.useNative10Bit
      PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
   end
   if o.enableCLUTMapping
      PsychImaging('AddTask','AllViews','EnableCLUTMapping',o.CLUTMapLength,1); % clutSize, high res
      cal.gamma=repmat((0:o.maxEntry)'/o.maxEntry,1,3); % Identity
      Screen('LoadNormalizedGammaTable',0,cal.gamma,0); % set hardware CLUT to identity.
   else
      warning('You need EnableCLUTMapping to control contrast.');
   end
   if o.enableCLUTMapping % How we use LoadNormalizedGammaTable
      loadOnNextFlip = 2; % Load software CLUT at flip.
   else
      loadOnNextFlip = 1; % Load hardware CLUT: 0. now; 1. on flip.
   end
   if ~o.useFractionOfScreen
      window=PsychImaging('OpenWindow',cal.screen,1.0);
   else
      r=round(o.useFractionOfScreen*screenBufferRect);
      r=AlignRect(r,screenBufferRect,'right','bottom');
      window=PsychImaging('OpenWindow',cal.screen,1.0,r);
   end
end

if 1
   Screen('FillRect',window,1);
   Screen('Flip',window);
   Speak('White. Click to continue.');
   GetClicks;
   
%    [gamma,dacBits,realLutSize]=Screen('ReadNormalizedGammaTable',0);
%    fprintf('gamma table size %d x %d, dacBits %d, realLutSize %d\n',size(gamma),dacBits,realLutSize);
%    gamma=gamma(round(1+(0:255)*(size(gamma,1)-1)/255),:); % Down sample to 256.
%    Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);
%    Speak('Still white. Click to continue.');
%    Screen('Flip',window);
%    GetClicks;
end

if 0
   % Apparently when using EnableCLUTMapping, what ReadNormalizedGammaTable
   % returns is irrelevant and not used.
   g=repmat((0:255)'/255,1,3);
   Screen('LoadNormalizedGammaTable',window,g,deferLoading);
   Screen('Flip',window);
   gg=Screen('ReadNormalizedGammaTable',window);
   fprintf('ReadNormalizedGammaTable returns gamma table %d x %d.\n',size(gg));
   fprintf('loaded read\n');
   for i=1:16
      fprintf('%.3f %.3f\n',g(1+floor((i-1)/4),2),gg(i,2));
   end
end

Screen('PutImage',window,0:255,screenRect);
Screen('Flip',window);
Speak('A ramp. Click to continue.');
GetClicks;

fprintf('gamma size %dx%d, dacBits %d, realLutSize %d\n',size(gamma),dacBits,realLutSize);
gamma(2,1:3)=[1 1 0]; % yellow background
Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);
Screen('FillRect',window,1/255,[0 0 300 300]);
Screen('Flip',window);
Speak('A yellow square on white. Click to continue.');
GetClicks;

fprintf('gamma size %dx%d, dacBits %d, realLutSize %d\n',size(gamma),dacBits,realLutSize);
gamma(1,1:3)=0.7; % gray
Screen('LoadNormalizedGammaTable',window,gamma,deferLoading);
Screen('FillRect',window,0,[0 0 300 300]);
Screen('Flip',window);
Speak('A grey square on white. Click to quit.');
GetClicks;

Screen('Close',window);
sca;
