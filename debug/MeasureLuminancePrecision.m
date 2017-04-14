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

% REFERENCE (FROM MARIO) FOR HP Z Book "Sea Islands" GPU:
% 10 bpc panel dither setup code for the zBooks "Sea Islands" (CIK) gpu:
% http://lxr.free-electrons.com/source/drivers/gpu/drm/radeon/cik.c#L8814
% The constants which are or'ed / added together in that code are defined
% here:
% http://lxr.free-electrons.com/source/drivers/gpu/drm/radeon/cikd.h#L989
% I simply or'ed the proper constants to get the numbers i told you, so PTB
% replicates the Linux display drivers behaviour. As you can see there are
% many parameters one could tweak for any given display. E.g., add/drop
% FMT_FRAME_RANDOM_ENABLE, FMT_HIGHPASS_RANDOM_ENABLE, or
% FMT_RGB_RANDOM_ENABLE for extra entertainment value. It's somewhat of a
% black art. The gpu also has various temporal dithering modes with even
% more parameters, or combined spatio-temporal modes. Most of these are
% never used or even validated by gpu hardware vendors to do the right
% thing. All the variations will have different effects on different types
% of display panels, at different refresh rates and pixel densities, for
% different types of still images or animations, so a panel with a true
% native high bit depths is still a more deterministic thing that simulated
% high bit depths. I would use dithering only for high level stimuli with
% low spatial frequencies for that reason.

% DENIS: Must we call "PsychColorCorrection"? I'm already doing correction
% based on my photometry.

% MARIO: No. But it's certainly more convenient and faster, and very
% accurate. That's the recommended way to do gamma correction on > 8 bpc
% framebuffers. For testing it would be better to leave it out, so you use
% a identity mapping like when testing on the Macs.

% DENIS: Must we call "FinalFormatting"? Is the call to "FinalFormatting"
% just loading an identity ga! mma? Can I, instead, just use
% LoadFormattedGammaTable to load identity?

% MARIO: No, only if you want PTB to do high precision color/gamma
% correction via the modes and settings supported by
% PsychColorCorrection(). The call itself would simply establish an
% identity gamma "curve", however operating at ~ 23 bpc linear precision
% (32 bit floating point precision is about ~ 23 bit linear precision in
% the displayable color range of 0.0 - 1.0).

% -> Another thing you could test is if that laptop can drive a
% conventional 8 bit external panel with 12 or more bits via dithering. The
% gpu can do 12 bits in the 'EnableNative16BitFramebuffer' mode. So far i
% thought +2 extra bits would be all you could get via dithering, but after
% your surprising 11 bit result on your MacBookPro, with +3 extra bits, who
% knows if there's room for more?

% -> Yet another interesting option would be booting Linux on your iMac
% 2014 Retina 5k, again with the dither settings that gave you 11 bpc under
% macOS, and see if Linux in EnableNative16BitFramebuffer mode ! can
% squeeze out more than 11 bpc.

% DENIS: I was surprised by a limitation. On macOS I enable Clut mapping
% with 4096 Clut size. Works fine. In Linux if the requested Clut size is
% larger than 256 the call to loadnormalizedgammatable with load=2 gives a
% fatal error complaining that my Clut is bigger than 256. Seems weird
% since it was already told when I enabled that I'd be using a 256 element
% soft Clut.

% MARIO: I don't understand that? What kind of clut mapping with load=2? On
% Linux the driver uses the discrete 256 slot hardware gamma table, instead
% of the non-linear gamma mapping that macOS now uses. Also PTB on Linux
% completely disables hw gamma tables in >= 10 bit modes, so all gamma
% correction is done via PsychColorCorrection(). You start off with a
% identity gamma table.

points=32;
wigglePixelNotCLUT=1;
loadIdentityCLUT=1;
ditherCLUT=61696; % Enable dither on my iMac and PowerBook Pro.
% ditherCLUT=0; % Disable dither.
useNative10Bit=1;
enableCLUTMapping=0;
CLUTMapSize=4096;
usePhotometer=1; % 1 use ColorCAL II XYZ; 0 simulate 8-bit rendering.
reciprocalOfFraction=[512]; %256 1024 % List one or more, e.g. 1, 64, 128, 256.
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
    Screen('ConfigureDisplay', 'Dithering', screen, ditherCLUT);
    if 0
       % CODE FROM MARIO & HORMET FOR LINUX HP Z BOOK
       switch nBits
          case 8; % do nothing
          case 10; PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
          case 11; PsychImaging('AddTask', 'General', 'EnableNative11BitFramebuffer');
          case 12; PsychImaging('AddTask', 'General', 'EnableNative16BitFramebuffer', [], 16);
       end
       PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma'); % Load identity gamma.
       if nBits >= 11; Screen('ConfigureDisplay', 'Dithering', screenNumber, 61696); end % 11 bpc via Bit-stealing
%        PsychColorCorrection('SetEncodingGamma', w, 1/2.50); % your display might have a different gamma
       Screen('Flip', w);
    end
    if useNative10Bit
        PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
    end
    PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
    if enableCLUTMapping
        % EnableCLUTMapping loads the software CLUT, not the hardware CLUT.
        PsychImaging('AddTask','AllViews','EnableCLUTMapping',CLUTMapSize,1); % clutSize, high res
    end
    if ~useFractionOfScreen
        [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1]);
    else
        [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1],round(useFractionOfScreen*screenBufferRect));
    end
    windowInfo=Screen('GetWindowInfo',window);
    switch(windowInfo.DisplayCoreId)
       % FIGURE OUT MAGIC DITHER NUMBER FOR THIS VIDEO DRIVER.
       case 'AMD',
          displayEngineVersion=windowInfo.GPUMinorType/10;
          switch(round(displayEngineVersion))
             case 6,
                displayGPUFamily='Southern Islands';
                % Examples:
                % AMD Radeon R9 M290X used in MacBook Pro (Retina, 15-inch, Mid 2015)
                % AMD Radeon R9 M370X used in iMac (Retina 5K, 27-inch, Late 2014)
                ditherCLUT=61696;
             case 8,
                displayGPUFamily='Sea Islands';
                % Used in hp Z Book laptop.
                ditherCLUT= 61696;
                ditherCLUT= 59648;
                % Another number you could try is 59648. This would enable
                % dithering for a native 8 bit panel, which is the wrong
                % thing to do for the laptops 10 bit panel, assuming the
                % driver docs are correct. But then, who knows?
             otherwise,
                displayGPUFamily='unkown';
          end
          fprintf('Display driver: %s version %.1f, "%s"\n',...
             windowInfo.DisplayCoreId,displayEngineVersion,displayGPUFamily);
    end
    if exist('ditherCLUT','var')
       fprintf('ConfigureDisplay Dithering %.0f\n',ditherCLUT);
       Screen('ConfigureDisplay','Dithering',screen,ditherCLUT);
    end
    if wigglePixelNotCLUT
        % Compare default CLUT with identity.
        gammaRead=Screen('ReadNormalizedGammaTable',window);
        maxEntry=size(gammaRead,1)-1;
        gamma=repmat(((0:maxEntry)/maxEntry)',1,3);
        delta=gammaRead(:,2)-gamma(:,2);
        fprintf('Difference between identity and read-back of default CLUT: mean %.9f, sd %.9f\n',mean(delta),std(delta));
    end
    if enableCLUTMapping
        % Check whether loading identity as a CLUT map is innocuous.
        % Setting CLUTMapSize=4096 affords 12-bit precision.
        gamma=repmat(((0:CLUTMapSize-1)/(CLUTMapSize-1))',1,3);
        loadOnNextFlip=0;
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
            gamma=repmat(((0:CLUTMapSize-1)/(CLUTMapSize-1))',1,3);
            if wigglePixelNotCLUT
                if loadIdentityCLUT
                    loadOnNextFlip=1;
                    Screen('LoadNormalizedGammaTable',window,gamma,loadOnNextFlip);
                end
                Screen('FillRect',window,g);
            else
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
                Screen('FillRect',window,iPixel/(CLUTMapSize-1));
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
                gamma=repmat(((0:size(gammaRead,1)-1)/(size(gammaRead,1)-1))',1,3);
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
