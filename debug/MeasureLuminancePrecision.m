function data=MeasureLuminancePrecision
% MeasureLuminancePrecision
% Measure the luminance produced by each value loaded into the pixel or
% Color Lookup Table (CLUT), to discover how precisely we can control
% luminance. This includes precision achieved through dither by the video
% driver.
%
% My experiments with LoadNormalizedGammaTable indicate that it is accurate
% only for very smooth gamma functions. (Mario says this is because it
% stores only a functional approximation, not the requested values.) Thus
% fiddling with the CLUT is not a recommended way to achieve fine steps in
% luminance. It is generally better to leave the CLUT alone and adjust the
% pixel values.
%
% Happily, the AMD drivers on the MacBook Pro (Retina, 15-inch, Mid 2015)
% and the iMac (Retina 5K, 27-inch, Late 2014) both provide a 10-bit
% pathway from pixel to display. On my PowerBook Pro, enabling both
% useNative10Bit and dither, I get 11-bit luminance precision.
%
% PARAMETERS:
% wigglePixelNotCLUT = whether to vary the value of the pixel or CLUT.
% points = number of luminances to measure, 3 s each.
% loadIdentityCLUT = whether to load an identity into CLUT.
% useNative10Bit = whether to enable the driver's 10-bit mode. Recommended.
% enableCLUTMapping = whether to use software table lookup. See below.
% CLUTMapSize = power of 2. CLUTMapping limits resolution to log2(CLUTMapSize).
% usePhotometer = 1 use ColorCAL II XYZ; 0 simulate 8-bit rendering.
% reciprocalOfFraction = list desired values, e.g. 1, 64, 128, 256.
% useFractionOfScreen = 0 normal; f<1 reduce our window *f to expose Command Window.
% ditherCLUT = 61696; Required for dither on my iMac and MacBook Pro. Recommended.
%
% For dither, the magic number 61696 is appropriate for graphics chips in
% the AMD Radeon "Southern Islands" gpu family. Such chips are used in the
% MacBook Pro (Retina, 15-inch, Mid 2015) (AMD Radeon R9 M290X) and the
% iMac (Retina 5K, 27-inch, Late 2014) (AMD Radeon R9 M370X). As far as I
% know, in April 2017, those are the only Apple Macs with AMD drivers, and
% may be the only Macs that support more-than-8-bit luminance precision.
%
% enableCLUTMapping is easily misunderstood. It does NOT modify the
% hardware CLUT through which each pixel is processed. CLUTMapping is an
% extra transformation that occurs BEFORE the hardware CLUT. One could be
% confused by the fact that the same command,
% Screen('LoadNormalizedGammaTable',window,loadAtFlip) either loads the
% CLUT or the CLUTMap. The last argument is set to 0 or 1 to load the CLUT,
% and 2 to load the CLUTMap. If you'll be loading the CLUTMap, you must
% declare that intention in advance by calling
% PsychImaging('AddTask','AllViews','EnableCLUTMapping',CLUTMapSize,1);
% when you're getting ready to open your window. In that call, you specify
% the CLUTMapSize, and this puts a ceiling of log2(CLUTMapSize) bits on your
% luminance resolution. The best resolution on my PowerBook Pro is 11
% bits, so I set the CLUTMapSize to 4096, corresponding to 12-bit
% precision, more than I need. If you use CLUTMapping, then you will
% typically want to make the table length (a power of 2) long enough to not
% limit your luminance resolution. You can use enableCLUTMapping to turn
% CLUTMapping on and off and thus see whether it's limiting resolution.
%
% Denis Pelli, April 2, 2017

points=64;
wigglePixelNotCLUT=1;
loadIdentityCLUT=1;
ditherCLUT=61696; % Enable dither on my iMac and PowerBook Pro.
% ditherCLUT=0; % Disable dither.
useNative10Bit=1;
enableCLUTMapping=0;
CLUTMapSize=4096;
usePhotometer=0; % 1 use ColorCAL II XYZ; 0 simulate 8-bit rendering.
reciprocalOfFraction=[1 128]; %256 1024 % List one or more, e.g. 1, 64, 128, 256.
useFractionOfScreen=0; % Reduce our window to expose Command Window.
BackupCluts;
Screen('Preference','SkipSyncTests',2);
% Screen('Preference','SkipSyncTests',1); %  For Mario.
% Screen('Preference','Verbosity',10); % For Mario.
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
      PsychImaging('AddTask','AllViews','EnableCLUTMapping',CLUTMapSize,1); % clutSize, high res
   end
   if ~useFractionOfScreen
      [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1]);
   else
      [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1],round(useFractionOfScreen*screenBufferRect));
   end
   if exist('ditherCLUT','var')
      Screen('ConfigureDisplay','Dithering',screen,ditherCLUT);
   end
   if wigglePixelNotCLUT
      % Compare default CLUT with identity.
      gamma=repmat(((0:1023)/1023)',1,3);
      gammaRead=Screen('ReadNormalizedGammaTable',window);
      assert(length(gamma)==length(gammaRead))
      delta=gammaRead(:,2)-gamma(:,2);
      fprintf('Difference between identity and read-back of default CLUT: mean %.9f, sd %.9f\n',mean(delta),std(delta));
   end
   if enableCLUTMapping
      % Check whether loading identity as a CLUT map is innocuous.
      % CLUTMapSize=4096 affords 12-bit precision.
      gamma=repmat(((0:CLUTMapSize-1)/(CLUTMapSize-1))',1,3);
      loadOnNextFlip=2;
      Screen('LoadNormalizedGammaTable',window,gamma,loadOnNextFlip);
      Screen('Flip',window);
   end
   %% MEASURE LUMINANCE AT EACH VALUE OF CLUT OR PIXEL
   % Each measurement takes several seconds.
   clear data d
   t=GetSecs;
   nData=length(reciprocalOfFraction);
   for iData=1:nData
      d.fraction=1/reciprocalOfFraction(iData);
      for i=1:points
         if d.fraction<1
            g=0.5;
         else
            g=0;
         end
         g=g+d.fraction*(i-1)/(points-1);
         assert(g<=1)
         d.v(i)=g;
         if wigglePixelNotCLUT
            if loadIdentityCLUT
               gamma=repmat(((0:1023)/1023)',1,3);
               loadOnNextFlip=1;
               Screen('LoadNormalizedGammaTable',window,gamma,loadOnNextFlip);
            end
            Screen('FillRect',window,g);
         else
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
         end
         Screen('Flip',window);
         if usePhotometer
            L=GetLuminance; % Read photometer
         else
            % No photometer. Simulate 8-bit performance.
            L=200*round(g*255)/255;
         end
         d.L(i)=L;
         if loadIdentityCLUT
            gammaRead=Screen('ReadNormalizedGammaTable',window);
            delta=gammaRead(:,2)-gamma(:,2);
            fprintf('Difference in read-back of identity CLUT: mean %.9f, sd %.9f\n',mean(delta),std(delta));
            if 0
               % Report all errors in identity CLUT.
               list=gamma(:,2)~=gammaRead(:,2);
               fprintf('%d differences between gamma table loaded vs. read. Checking only green channel.\n',sum(list));
               n=1:1024;
               fprintf('Subs.\tEntry\tLoad\tRead\tDiff\n');
               for j=n(list)
                  fprintf('%d\t%d\t%.3f\t%.3f\t%.9f\n',j,j-1,gamma(j,2),gammaRead(j,2),gammaRead(j,2)-gamma(j,2));
               end
            end
         end
      end
      data(iData)=d;
   end
   t=(GetSecs-t)/length(data)/points;
catch
   sca
   RestoreCluts
   psychrethrow(psychlasterror);
end
Screen('Close',window);
close all
RestoreCluts
sca

%% PLOT RESULTS
fprintf('Photometer took %.1f s/luminance.\n',t);
figure;
set(gcf,'PaperPositionMode','auto');
set(gcf,'Position',[0 300 320*length(data) 320]);

for iData=1:length(data)
   d=data(iData);
   subplot(1,length(data),iData)
   plot(d.v,d.L);
   ha=gca;
   ha.TickLength(1)=0.02;
   pbaspect([1 1 1]);
   title(sprintf('Range / %d',1/d.fraction));
   if wigglePixelNotCLUT
      xlabel('Pixel value');
   else
      xlabel('CLUT');
   end
   ylabel('Luminance (cd/m^2)');
   xlim([d.v(1) d.v(end)]);
   computer=Screen('Computer');
   name=[computer.machineName ', '];
   yLim=ylim;
   dy=-0.06*diff(yLim);
   y=yLim(2)+dy;
   xLim=xlim;
   x=xLim(1)+0.03*diff(xLim);
   text(x,y,name);
   name='';
   if exist('ditherCLUT','var')
      name=sprintf('%sdither %d, ',name,ditherCLUT);
   end
   if useNative10Bit
      name=sprintf('%suseNative10Bit, ',name);
   end
   y=y+dy;
   text(x,y,name);
   name='';
   if loadIdentityCLUT
      name=[name 'loadIdentityCLUT, '];
   end
   if enableCLUTMapping
      name=sprintf('%s CLUTMapSize=%d, ',name,CLUTMapSize);
   end
   if ~usePhotometer
      name=[name 'simulating 8 bits, '];
   end
   y=y+dy;
   text(x,y,name);
   name='';
   name=sprintf('%spoints %d',name,points);
   y=y+dy;
   text(x,y,name);
   name='';
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
if loadIdentityCLUT
   name=[name 'LoadIdentityCLUT'];
end
if enableCLUTMapping
   name=sprintf('%sCLUTMapSize%d',name,CLUTMapSize);
end
if ~usePhotometer
   name=[name 'Simulating8Bits'];
end
name=sprintf('%sPoints%d',name,points);
name=strrep(name,'''',''); % Remove quote marks.
name=strrep(name,' ',''); % Remove spaces.
savefig(gcf,name,'compact'); % Save figure as figure file.
print(gcf,'-dpng',name); % Save figure as png file.
save(name,'data'); % Save data as MAT file.
end

function L=GetLuminance
% L=GetLuminance(usePhotometer)
% Measure luminance (cd/m^2).
% Cambridge Research Systems ColorCAL II XYZ Colorimeter.
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
