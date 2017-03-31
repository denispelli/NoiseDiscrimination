function data=MeasureLuminancePrecision
% MeasureLuminancePrecision
% Measure how the luminance produced by a value loaded into the gamma
% table, is affected by the immediately adjoining CLUT entries. One might
% expect no effect, but the AMD driver seems to smooth the gamma table.
% This surprising effect might be useful in attaining very low contrast.
% Denis Pelli, March 30, 2017

%dither=0; % Comment out this line to not set dithering.
steps=32;
pixelValue=100;
gValues=0.5; %[0.2 0.5 0.8];
usePhotometer=1; % Use ColorCAL II XYZ, or simulate 8-bit rendering.
% Each range takes about a minute to measure.
useFractionOfScreen=.3; % Restrict our window size, for access to Command Window.
BackupCluts;
Screen('Preference','SkipSyncTests',2);
try
   %% OPEN WINDOW
   screen = 0;
   screenBufferRect = Screen('Rect',screen);
   PsychImaging('PrepareConfiguration');
   PsychImaging('AddTask','General','UseRetinaResolution');
   % Trying EnableNative10BitFramebuffer was a long shot.
   %    PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
   % EnableCLUTMapping does not load hardware CLUT, and won't help precision.
   %    PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize,high res
   if ~useFractionOfScreen
      [window,screenRect] = PsychImaging('OpenWindow',screen,255);
   else
      [window,screenRect] = PsychImaging('OpenWindow',screen,255,round(useFractionOfScreen*screenBufferRect));
   end
   if exist('dither','var')
      Screen('ConfigureDisplay', 'Dithering', screen, dither);
   end
   %% MEASURE LUMINANCE AT EACH GAMMA VALUE
   % Each measurement takes several seconds.
   Screen('FillRect',window,pixelValue);
   Screen('Flip',window);
   iData=1;
   clear data
   gamma=[0:255;0:255;0:255]'/255;
   index=pixelValue+1;
   gamma(index-1:index+1,1:3)=0.5;
   L=LuminanceOfGamma(window,gamma,usePhotometer); % Read photometer
   % discard first reading.
   for gRef=gValues
      for correlation=[-1 1]
         for i=1:steps
            gSide1=(i-1)/(steps-1);
            switch(correlation)
               case 1, gSide2=gSide1;
               case -1, gSide2=1-gSide1;
               otherwise, error('illegal correlation');
            end
            gamma(index-1,1:3)=gSide1;
            gamma(index+1,1:3)=gSide2;
            L=LuminanceOfGamma(window,gamma,usePhotometer); % Read photometer
            data(iData).gRef=gRef;
            data(iData).correlation=correlation;
            data(iData).gSide1(i)=gSide1;
            data(iData).gSide2(i)=gSide2;
            data(iData).L(i)=L;
         end
         nData=iData;
         iData=iData+1;
      end
   end
catch
   sca
   psychrethrow(psychlasterror);
end
Screen('Close',window);
close all
RestoreCluts
sca

%% PLOT RESULTS
figure
for iData=1:nData
   d=data(iData);
   subplot(1,nData,iData)
   plot(d.gSide1,d.L,'-');
   title(sprintf('corr %d, g %.2f',d.correlation,d.gRef));
   xlabel('Side gamma');
   ylabel('Luminance (cd/m^2)');
   computer=Screen('Computer');
   name=computer.machineName;
   text(0,min(d.L),name);
end
folder=fileparts(mfilename('fullpath'));
cd(folder);
name=['leak-' computer.machineName];
name=strrep(name,'''',''); % Remove quote marks.
savefig(name); % Save figure as figure file.
save(name,'data'); % Save data as MAT file.
end

function L=LuminanceOfGamma(window,gamma,usePhotometer)
% L=LuminanceOfGamma(window,g,usePhotometer)
% Measure luminance produced by gamma table.
% Cambridge Research Systems ColorCAL II XYZ.
persistent CORRMAT
if nargin<3
   usePhotometer=1;
end
if nargin<2
   error('LuminanceOfGamma needs at least 2 arguments.');
end
if usePhotometer && isempty(CORRMAT)
   % Get ColorCAL II XYZ correction matrix (CRT=1; WLED LCD=2; OLED=3):
   CORRMAT=ColorCal2('ReadColorMatrix');
end
Screen('LoadNormalizedGammaTable',window,gamma,0);
WaitSecs(0.1);
if usePhotometer
   s = ColorCal2('MeasureXYZ');
   XYZ = CORRMAT(4:6,:) * [s.x s.y s.z]';
   L=XYZ(2);
else
   % No photometer. Simulate 8-bit performance.
   L=200*round(g*255)/255;
end
end
