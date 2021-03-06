function data=MeasureLuminancePrecision
% data=MeasureLuminancePrecision
% INSTRUCTIONS: Currently this program requires a Cambridge Research
% Systems photometer. You could easily adapt it to another photometer. Plug
% your photometer's USB cable into your computer, carefully place your
% photometer stably against your computer's screen, set PARAMETERS (below),
% then run. The results will be displayed as a graph in a MATLAB figure
% window, and also saved in three files (in the same folder as this file)
% with filename extensions: png, fig, and mat. The main part of the
% filename describes the testing conditions, e.g.
% DenissMacBookPro5K-Dithering61696-UseNative10Bit-LoadIdentityCLUT-Luminances8.fig
%
% EXPLANATION: Using Psychtoolbox SCREEN imaging, measures how precisely we
% can control display luminance. Loads identity into the Color Lookup Table
% (CLUT) and measures the luminance produced by each value loaded into a
% large identical patch of image pixels. (This program varies only
% luminance, not hue, always varying the three RGB channels together, but
% the conclusion about bits of precision per channel almost certainly
% applies to general-purpose presentation of arbitrary RGB colors.) The
% attained precision will be achieved mostly by the digital-to-analog
% converter and, perhaps, partly through dither by the video driver. Since
% the 1980's most digital computer displays allocate 8 bits per color
% channel (R, G, B). In the past few years, some displays now accept 10
% bits for each channel and pass that through from the pixel in memory
% through the color lookup table (CLUT) to the digital to analog converter
% that controls light output. In 2016-2017,  Mario Kleiner enhanced The
% Psychtoolbox SCREEN function to allow specification of each color
% component (R G B) as a floating point number, where 0 is black and 1 is
% maximum output, so that your software, without change, will drive any
% display and benefit from as much precision as the display hardward and
% driver provide.
%
% Typically you'll run MeasureLuminancePrecision from the command line. It
% will make all the requested measurements and plot the results. Each
% figure is saved as both a FIG and PNG file, and the data are saved as a
% MAT file. The data are also returned as the output argument: luminance
% out "L" vs floating point color value "v" in.
%
% To use this program to measure the precision of your computer display you
% need three things:
% 1. MATLAB or Octave. http://mathworks.com
% 2. The Psychtoolbox, free from http://psychtoolbox.org.
% 3. A Cambridge Research Systems photometer or colorimeter.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/
% It's plug and play, taking power through its USB cable.
% It would be very easy to modify this program to work with any other
% photometer.
%
% As of April 2017, Apple documents indicate that only two products in
% their current macOS offerings attain 10-bit precision from pixel to
% display (in each of the three RGB channels): Apple's high-end MacBook Pro
% 15" retina laptop and iMac 27" retina desktop. I tested my MacBook Pro
% (Retina, 15-inch, Mid 2015) and iMac (Retina 5K, 27-inch, Late 2014).
% Both use AMD drivers. Using MeasureLuminancePrecision, I have documented
% 11-bit luminance precision on both of these displays, enabling both
% useNative10Bit and dither,
% https://www.macrumors.com/2015/10/30/4k-5k-imacs-10-bit-color-depth-osx-el-capitan/
% https://developer.apple.com/library/content/samplecode/DeepImageDisplayWithOpenGL/Introduction/Intro.html#//apple_ref/doc/uid/TP40016622
% https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_11_2.html#//apple_ref/doc/uid/TP40016630-SW1

% My Linux Hewlett-Packard Z Book laptop attains 10-bit luminance
% precision. I have not yet succeeded in getting dither to work on the Z
% Book. Thanks to my former student, H�rmet Yiltiz, for setting up the Z
% Book and getting 10-bit imaging to work, with help from Mario Kleiner.
%
% MacBook Pro driving NEC PA244UHD 4K display 
% https://macperformanceguide.com/blog/2016/20161127_1422-Apple2016MacBookPro-10-bit-color.html
%
% PARAMETERS:
% luminances = number of luminances to measure, 3 s each.
% reciprocalOfFraction = list desired values, e.g. 1, 64, 128, 256.
% useNative10Bit = whether to enable the driver's 10-bit mode. Recommended.
% usePhotometer = 1 use ColorCAL II XYZ; 0 simulate 8-bit rendering.
% ditherCLUT = 61696; Required for dither on my iMac and MacBook Pro. 
%
% For dither, the magic number 61696 is appropriate for the graphics chips
% belonging to the AMD Radeon "Southern Islands" gpu family. Such chips are
% used in the MacBook Pro (Retina, 15-inch, Mid 2015) (AMD Radeon R9 M290X)
% and the iMac (Retina 5K, 27-inch, Late 2014) (AMD Radeon R9 M370X). As
% far as I know, in April 2017, those are the only Apple Macs with AMD
% drivers, and may be the only Macs that support more-than-8-bit luminance
% precision.
%
% Denis Pelli, April 24, 2017

%% DITHERING NOTES
% (FROM MARIO) FOR HP Z Book "Sea Islands" GPU:
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
% just loading an identity gamma? Can I, instead, just use
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

%% FROM MARIO

% Denis could you send me the .mat files with various measured curves? Also
% a measurement of the iMac Retina, just with 'EnableNative10Bit' mode, but
% *without* any of the special dither settings - after a machine reboot -
% would be good. I'd like to know how it behaves at Apples factory settings
% without our PTB specific hacks, as those are so machine specific.

% Btw., so far i still didn't manage to replicate your 11 bpc with
% dithering finding on any AMD hardware + 8 bit display here, even with
% more modern AMD graphics cards, so i'm still puzzled by that result. I'll
% probably add some debug code to the next PTB beta for you to run on
% macOS, to dump some hardware settings, maybe that'd give some clues about
% how that 11 bpc instead of expected max 10 bpc happens.

%% SOFTWARE CLUT
% The following 4 parameters allow testing of the software CLUT, but that's
% a relatively unimportant option and not usable on the Z Book (restricted
% to 8 bit table), so you might as well not bother testing the software
% CLUT.
% My experiments with LoadNormalizedGammaTable indicate that it is accurate
% only for very smooth gamma functions. (Mario says this is because it
% stores only a functional approximation, not the requested values.) Thus
% fiddling with the CLUT is not a recommended way to achieve fine steps in
% luminance. It is generally better to leave the CLUT alone and adjust the
% pixel values.
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
%
%% PARAMETERS
% Set "luminances" to determine how many luminances are measured to produce your
% final graph. 32 is typically enough, and the CRS photometer takes 3
% s/point.
% Set "reciprocalOfFraction" to specify what fraction of the full luminance
% range you want to explore. Setting it to 1 will explore the whole range.
% To demonstrate 10-bit precision over the whole range you'd need 2^10=1024
% steps, which will take a long time, 3,000 s, nearly an hour. Setting
% reciprocalOfFraction=256 will test only 1/256 of the range, which is
% enough to reveal whether there are any steps finer than 8-bit precision.
% You can request several ranges by listing them, e.g. [1 128]. You'll get
% a graph for each. Each graph will use the specified number of luminances.

luminances=16; % Photometer takes 3 s/luminance. 32 luminances is enough for a pretty graph.
reciprocalOfFraction=[512]; % 256 1024 % List one or more, e.g. 1, 64, 128, 256.
enableDithering=[]; % 1 enable. [] default. 0 disable.
useNative10Bit=1; % Enable this to get 10-bit (or better) performance.
usePhotometer=1; % 1 use ColorCAL II XYZ; 0 simulate 8-bit rendering.

useFractionOfScreen=0; % For debugging, reduce our window to expose Command Window.

% wigglePixelNotCLUT = whether to vary the value of the pixel or CLUT.
% loadIdentityCLUT = whether to load an identity into CLUT.
% enableCLUTMapping = whether to use software table lookup. See below.

% CLUTMapSize = power of 2. CLUTMapping limits resolution to log2(CLUTMapSize).
wigglePixelNotCLUT=1; % 1 is fine. The software CLUT is not important.
loadIdentityCLUT=1; % 1 is fine.
enableCLUTMapping=0; % 1 use software CLUT. 0 don't. Not needed. 
CLUTMapSize=4096; % Size of software CLUT. Limits resolution to log2(CLUTMapSize) bits.

%% BEGIN
BackupCluts;
% Screen('Preference','SkipSyncTests',2); % May no longer be needed.
% Screen('Preference','SkipSyncTests',1); %  For Mario.
% Screen('Preference','Verbosity',10); % For Mario.
try
    %% OPEN WINDOW
    screen = 0;
    screenBufferRect = Screen('Rect',screen);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','General','UseRetinaResolution');
    if 0
       % CODE FROM MARIO FOR LINUX HP Z BOOK
       switch nBits
          case 8; % do nothing
          case 10; PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
          case 11; PsychImaging('AddTask','General','EnableNative11BitFramebuffer');
          case 12; PsychImaging('AddTask','General','EnableNative16BitFramebuffer',[],16);
       end
       PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','SimpleGamma'); % Load identity gamma.
       if nBits >= 11; Screen('ConfigureDisplay','Dithering',screenNumber,61696); end % 11 bpc via Bit-stealing
       %        PsychColorCorrection('SetEncodingGamma',w,1/2.50); % your display might have a different gamma
       Screen('Flip',w);
    end
    if useNative10Bit
        PsychImaging('AddTask','General','EnableNative10BitFramebuffer');
    end
    PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
    if enableCLUTMapping
        % EnableCLUTMapping loads the software CLUT,not the hardware CLUT.
        % This works with any clutSize on MacBook Pro and iMac. On HP zBook
        % it uselessly works only at clutSize=256.
        PsychImaging('AddTask','AllViews','EnableCLUTMapping',CLUTMapSize,1); % clutSize,high res
    end
    if ~useFractionOfScreen
        [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1]);
    else
        [window,screenRect] = PsychImaging('OpenWindow',screen,[1 1 1],round(useFractionOfScreen*screenBufferRect));
    end
    windowInfo=Screen('GetWindowInfo',window);
    switch(windowInfo.DisplayCoreId)
       % Choose the right magic dither code for the video driver. Currently
       % this works only for AMD drivers on  Apple's iMac and MacBook Pro,
       % and HP's Z Book. See Dithering Notes above.
       case 'AMD',
          displayEngineVersion=windowInfo.GPUMinorType/10;
          switch(round(displayEngineVersion))
             case 6,
                displayGPUFamily='Southern Islands';
                % Examples:
                % AMD Radeon R9 M290X used in MacBook Pro (Retina, 15-inch, Mid 2015)
                % AMD Radeon R9 M370X used in iMac (Retina 5K, 27-inch, Late 2014)
                ditheringCode=61696;
             case 8,
                displayGPUFamily='Sea Islands';
                % Used in HP Z Book laptop.
                % ditherCLUT= 61696;
                ditheringCode= 59648;
                % MARIO: Another number you could try is 59648. This would
                % enable dithering for a native 8-bit panel, which is the
                % wrong thing to do for the laptop's 10-bit panel, assuming
                % the driver docs are correct. But then, who knows?
             otherwise,
                displayGPUFamily='unknown';
          end
          fprintf('Display driver: %s version %.1f, "%s"\n',...
             windowInfo.DisplayCoreId,displayEngineVersion,displayGPUFamily);
    end
    if ~enableDithering
       ditheringCode=0;
    end
    if isfinite(enableDithering)
       fprintf('ConfigureDisplay Dithering %.0f\n',ditheringCode);
       % The documentation suggests that the first call enables, and the
       % second call sets the value.
       Screen('ConfigureDisplay','Dithering',screen,ditheringCode);
       Screen('ConfigureDisplay','Dithering',screen,ditheringCode);
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
    %% MEASURE LUMINANCE AT EACH VALUE
    % Each measurement takes several seconds.
    clear data d
    t=GetSecs;
    nData=length(reciprocalOfFraction);
    for iData=1:nData
        d.fraction=1/reciprocalOfFraction(iData);
        for i=1:luminances
            if d.fraction<1
                g=0.5;
            else
                g=0;
            end
            g=g+d.fraction*(i-1)/(luminances-1);
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
            Screen('TextSize',window,64);
            msg=sprintf('Series %d of %d.\n',iData,nData);
            Screen('DrawText',window,msg,100,100,0);
            msg=sprintf('%d luminances spanning 1/%.0f of digital range.',luminances,1/d.fraction);
            Screen('DrawText',window,msg,100,200,0);
            Screen('DrawText',window,sprintf('Luminance %d of %d.',i,luminances),100,300,0);
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
    t=(GetSecs-t)/length(data)/luminances;
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
    title(sprintf('%.0f luminances spanning 1/%.0f of digital range',luminances,1/d.fraction));
    if wigglePixelNotCLUT
        xlabel('Pixel value');
    else
        xlabel('CLUT');
    end
    ylabel('Luminance (cd/m^2)');
    xlim([d.v(1) d.v(end)]);
    computer=Screen('Computer');
    name=[computer.machineName ','];
    yLim=ylim;
    dy=-0.06*diff(yLim);
    y=yLim(2)+dy;
    xLim=xlim;
    x=xLim(1)+0.03*diff(xLim);
    text(x,y,name);
    name='';
    if isfinite(enableDithering)
        name=sprintf('%sditheringCode %d, ',name,ditheringCode);
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
        name=sprintf('%sCLUTMapSize=%d, ',name,CLUTMapSize);
    end
    if ~usePhotometer
        name=[name 'simulating 8 bits, '];
    end
    y=y+dy;
    text(x,y,name);
    name='';
    name=sprintf('%sluminances %d',name,luminances);
    y=y+dy;
    text(x,y,name);
    name='';
end
folder=fileparts(mfilename('fullpath'));
cd(folder);
name=computer.machineName;
if isfinite(enableDithering)
    name=sprintf('%s-Dithering%d',name,ditheringCode);
end
if useNative10Bit
    name=sprintf('%s-UseNative10Bit',name);
end
if loadIdentityCLUT
    name=[name '-LoadIdentityCLUT'];
end
if enableCLUTMapping
    name=sprintf('%s-CLUTMapSize%d',name,CLUTMapSize);
end
if ~usePhotometer
    name=[name '-Simulating8Bits'];
end
name=sprintf('%s-Luminances%d',name,luminances);
name=strrep(name,'''',''); % Remove quote marks.
name=strrep(name,' ',''); % Remove spaces.
savefig(gcf,name,'compact'); % Save figure as fig file.
print(gcf,'-dpng',name); % Save figure as png file.
save(name,'data'); % Save data as MAT file.
end

%% GET LUMINANCE
function L=GetLuminance
% L=GetLuminance(usePhotometer)
% Measure luminance (cd/m^2).
% Cambridge Research Systems ColorCAL II XYZ Colorimeter.
% http://www.crsltd.com/tools-for-vision-science/light-measurement-display-calibation/colorcal-mkii-colorimeter/nest/product-support
persistent CORRMAT
if isempty(CORRMAT)
    % Get ColorCAL II XYZ correction matrix (CRT=1; WLED LCD=2; OLED=3):
    CORRMAT=ColorCal2('ReadColorMatrix');
end
s = ColorCal2('MeasureXYZ');
XYZ = CORRMAT(4:6,:) * [s.x s.y s.z]';
L=XYZ(2);
end
