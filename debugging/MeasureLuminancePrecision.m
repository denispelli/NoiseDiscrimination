function data=MeasureLuminancePrecision
% MeasureLuminancePrecision
% Measure the luminance produced by each value loaded into the gamma table,
% to discover how precisely we can control luminance. This includes
% precision achieved through dither by the video driver.
%
% This program is short and self-contained to concisely document
% limitations in performance of LoadNormalizedGammaTable.
% Denis Pelli, March 30, 2017

clear all
steps=8; % each luminance measurement (one step) takes maybe 3 s.
ditherCLUT=61696; % Appropriate for graphics chips in the AMD Radeon "Southern
% Islands" gpu family. Such chips are used in the 
% MacBook Pro (Retina, 15-inch, Mid 2015) (AMD Radeon R9 M290X) and the 
% iMac (Retina 5K, 27-inch, Late 2014) (AMD Radeon R9 M370X).
ditherCLUT=0;
useNative10Bit=0;
enableCLUTMapping=0; % This mode cannot do better than 8 bits.
usePhotometer=1; % 1 to use ColorCAL II XYZ, or 0 to simulate 8-bit rendering.
% Each range takes about a minute to measure.
logBase2OfFractions=[8]; % Useful values include: 0, 6, 7, 8.
useFractionOfScreen=0; % Reduce our window to uncover Command Window.
BackupCluts;
Screen('Preference','SkipSyncTests',2);
try
   %% OPEN WINDOW
   screen = 0;
   screenBufferRect = Screen('Rect',screen);
   PsychImaging('PrepareConfiguration');
   PsychImaging('AddTask','General','UseRetinaResolution');
   if useNative10Bit
      PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
   end
   PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
   if enableCLUTMapping
       % EnableCLUTMapping does not load hardware CLUT, and won't help precision.
       PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize,high res
   end
   if ~useFractionOfScreen
      [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1]);
   else
      [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1],round(useFractionOfScreen*screenBufferRect));
   end
   if exist('ditherCLUT','var')
      Screen('ConfigureDisplay','Dithering',screen,ditherCLUT);
   end
   %% MEASURE LUMINANCE AT EACH GAMMA VALUE
   % Each measurement takes several seconds.
   clear data d
   t=GetSecs;
   nData=length(logBase2OfFractions);
   for iData=1:nData
      d.fraction=2.^-logBase2OfFractions(iData);
      for i=1:steps
         if d.fraction<1
            g=0.5;
         else
            g=0;
         end
         g=g+d.fraction*(i-1)/(steps-1);
         assert(g<=1)
         d.gamma(i)=g;
         gamma=[0:255;0:255;0:255]'/255;
         iPixel=126;
         for j=-4:4
             gamma(1+iPixel+j,1:3)=[g g g];
         end
         if enableCLUTMapping
             loadOnNextFlip=2;
         else
             loadOnNextFlip=1;
         end
         Screen('LoadNormalizedGammaTable',window,gamma,loadOnNextFlip);
         Screen('FillRect',window,[iPixel/255 iPixel/255 iPixel/255]);
         Screen('Flip',window);
         if usePhotometer
             L=GetLuminance; % Read photometer
         else
             % No photometer. Simulate 8-bit performance.
             L=200*round(g*255)/255;
         end
         d.L(i)=L;
      end
      data(iData)=d;
   end
   t=(GetSecs-t)/length(data)/steps;
catch
   sca
   psychrethrow(psychlasterror);
end
Screen('Close',window);
close all
RestoreCluts
sca

%% PLOT RESULTS
fprintf('Photometer took %.1f s/luminance.\n',t);
figure
for iData=1:length(data)
   d=data(iData);
   subplot(1,length(data),iData)
   plot(d.gamma,d.L);
   title(sprintf('Range/%d',1/d.fraction));
   xlabel('Gamma');
   ylabel('Luminance (cd/m^2)');
   xlim([d.gamma(1) d.gamma(end)]);
   computer=Screen('Computer');
   name=computer.machineName;
   if exist('ditherCLUT','var')
      name=sprintf('%s, dither %d',name,ditherCLUT);
   end
   if useNative10Bit
      name=sprintf('%s, useNative10Bit',name);
   end
   if enableCLUTMapping
      name=sprintf('%s, enableCLUTMapping',name);
   end
   if ~usePhotometer
      name=[name ',simulating 8 bits'];
   end
   yLim=ylim;
   y=yLim(1)+0.97*diff(yLim);
   xLim=xlim;
   x=xLim(1)+0.03*diff(xLim);
   text(x,y,name);
end
folder=fileparts(mfilename('fullpath'));
cd(folder);
name=computer.machineName;
if exist('ditherCLUT','var')
   name=sprintf('%sDither%d',name,ditherCLUT);
end
if useNative10Bit
   name=sprintf('%sUseNative10Bit',name);
end
if enableCLUTMapping
    name=sprintf('%sEnableCLUTMapping',name);
end
if ~usePhotometer
   name=[name 'Simulating8Bits'];
end
name=strrep(name,'''',''); % Remove quote marks.
savefig(name); % Save figure as figure file.
save(name,'data'); % Save data as MAT file.
end

function L=GetLuminance
% L=GetLuminance(usePhotometer)
% Measure luminance.
% Cambridge Research Systems ColorCAL II XYZ.
persistent CORRMAT
if nargin<1
   usePhotometer=1;
end
if isempty(CORRMAT)
   % Get ColorCAL II XYZ correction matrix (CRT=1; WLED LCD=2; OLED=3):
   CORRMAT=ColorCal2('ReadColorMatrix');
end
s = ColorCal2('MeasureXYZ');
XYZ = CORRMAT(4:6,:) * [s.x s.y s.z]';
L=XYZ(2);
end
