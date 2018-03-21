function o=NoiseDiscrimination(oIn)
% o=NoiseDiscrimination(o);
%
% Pass all your parameters in the "o" struct, which will be returned with
% all the results as additional fields. NoiseDiscrimination may adjust some
% of your parameters to satisfy physical constraints. Constraints include
% the screen size, resolution, and maximum possible contrast.
%
% You should write a short script that loads all your parameters into an
% "o" struct and calls o=NoiseDiscrimination(o). Within your script it's
% fine to keep reusing o, with little or no change. However, at the
% beginning of your script, I recommend calling "clear o" to make sure that
% you don't carry over any values from a prior session.
%
% OFF THE NYU CAMPUS: If you have an NYU netid and you're using the NYU
% MATLAB license server then you can work from off campus if you install
% NYU's free VPN software on your computer:
% http://www.nyu.edu/its/nyunet/offcampus/vpn/#services
%
% ALTERNATE FOR ESCAPE KEY: The 2017 MacBook Pro with the task bar has no
% built-in ESCAPE key. (The task bar sometimes simulates ESCAPE key, but I
% don't know if we can count on it being there.) To support computers
% without ESCAPE keys, NoiseDiscrimination accepts the GRAVE ACCENT key as
% equivalent to the ESCAPE key.
%
% SNAPSHOT. It is useful to take snapshots of the stimulus produced by
% NoiseDiscrimination. Such snapshots can be used in papers and talks to
% show our stimuli. If you request a snapshot then NoiseDiscrimination
% saves the first stimulus to a PNG image file and then quits with a fake
% error. To help you keep track of how you made each stimulus image file,
% some information about the condition is contained in the file name and in
% a caption on the figure. The caption may not be included if you enable
% cropping. Here are the parameters that you can control:
% o.saveSnapshot=true; % If true, take snapshot for public presentation.
% o.snapshotContrast=0.2; % nan to request program default.
% o.cropSnapshot=false; % If true, crop to include only target and noise,
%                   % plus response numbers, if displayed.
% o.snapshotCaptionTextSizeDeg=0.5;
%
% Standard condition for counting V1 neurons: o.noiseCheckPix=13;
% height=30*o.noiseCheckPix; o.viewingDistanceCm=45; SD=0.2, o.targetDurationSec=0.2 s.
%
% BRIGHTNESS SEEKER. Observer 'brightnessSeeker' is a model of the human
% observer with a saturation of brightness, based on an old research
% project of mine. As the noise gets stronger, this artificial o.observer
% "sees" it as dimmer and will identify the dim letter or choose the
% dimmest square. The strength of the saturation is set by
% "o.observerQuadratic=-1.2;" There's no need to adjust that. If we make
% that number big, like -10, this o.observer performs much like the ideal.
% If the number is zero, it'll be just guessing. I'm pretty sure -1.2 is
% the right setting.
%
% ANTIALIASING ARTIFACTS. It wasn't easy to get the instructional text to
% image well. It's black, on a gray background, but the antialiasing in the
% font rendering surrounded each letter with with intermediate levels of
% gray. The intermediate values were problematic. In my CLUT, the
% intermediate values between gray (roughly 0.5) and black (0) were much
% closer in luminance to the gray, making the letter seem too thin. Worse,
% I am computing a new color table (CLUT) for each trial, so this made the
% halo around the instructions flicker every time the CLUT changed.
% Eventually I realized that black is zero and that by making the gray
% background have an index of 1, the letters are indeed binary, since the
% font rendering software emits only integers and there are no integers
% between 0 and 1. This leaves me free to do whatever I want with the rest
% of the color table. The letters are imaged well, because the antialiasing
% software is allowed to do its best with the binary gamut.
%
% Similarly, it wasn't easy to put the signal on the screen without getting
% a dark halo on the MacBookPro Retina display. That display, like other
% high-resolution displays, insists on interpolating around the edge.
% Pasting a grayscale image (128) on a background set to 1 resulted in
% intermediate pixel values which were all darker than the background gray.
% I fixed this by making the background be 128. Thus the background is
% always gray LMean, but it's produced by a color index of 128 inside
% stimulusRect, and a color index of 1 outside it. This is drawn by calling
% FillRect with 1 for the whole screen, and again with 128 for the
% stimulusRect.
%
% FIXATION CROSS. The fixation cross is quite flexible. You specify its
% size (full width) and stroke thickness in deg. If you request
% o.fixationCrossBlankedNearTarget=1 then we maintain a blank margin (with
% no fixation line) around the target that is at least a target width (to
% avoid overlap masking) and at least half the eccentricity (to avoid
% crowding). Otherwise the fixation cross is blanked during target
% presentation and until o.fixationCrossBlankedUntilSecAfterTarget.
%
% ANNULAR GAUSSIAN NOISE ENVELOPE. Use these three parameters to specify an
% annular gaussian envelope. The amplitude is a Gaussian of R-Ra where R is
% the distance from letter center and Ra is
% o.annularNoiseEnvelopeRadiusDeg. When Ra is zero, this reduces to a
% normal gaussian centered on the letter. The code now computes a new
% summary of the "area" of the envelope: o.centralNoiseEnvelopeE1DegDeg We
% should equate this when we compare hard edge annulus with gaussian
% envelope.
%
% See also LinearizeClut, CalibrateScreenLuminance, OurScreenCalibrations,
% testLuminanceCalibration, testGammaNull, IndexOfLuminance,
% LuminanceOfIndex, MeasureLuminancePrecision.

% VIEWING GEOMETRY
% o.viewingDistanceCm % Distance from eye to near point.
% o.nearPointXYInUnitSquare=[0.8 0.5]; % Rough location of near point in o.stimlusRect re lower left corner.
% o.nearPointXYPix % screen coordinate of point on screen closest to viewer's eye.
% o.nearPointXYDeg % eccentricity of near point re fixation. Right & up are +.
% 1. Set displayNearPointXYDeg to eccentricityXYDeg, roughly.
% 2. Set displayNearPointXYPix according to o.nearPointXYInUnitSquare.
% 3. Ask viewer to adjust display so desired near point is at desired viewing distance and orthogonal to line of sight from eye.
% 4. If using off-screen fixation, put it at same distance from eye, and compute its position relative to near point.

%% CURRENT ISSUES
% This happened more than once, but very rarely. I can't reliably reproduce it.
% Warning: 245 out-of-range pixels, with values [ -9], were bounded to the range 2 to 2046.
% > In IndexOfLuminance (line 14)
%   In NoiseDiscrimination (line 2027)
%
% The estimated gray index is 0.5027 (161.8 cd/m^2), not 0.5002 (161.0 cd/m^2).
% Warning: The gray index changed!
% > In NoiseDiscrimination (line 2316)
%   In khandakerThresholds (line 25)

%% EXTRA DOCUMENTATION

% On Feb 25, 2017 13:25, "Denis Pelli" <denis.pelli@nyu.edu> wrote:
% REPLICATING MANOJ'S NEQ MEASUREMENTS
%
% Replicating was more challenging than we expected. In December we found
% that Hormet's (new) Neq was about 4-6 time higher than Manoj's (old) Neq.
% We pursued many leads, and found two causes: 1. contrast calibration
% error and 2. lack of auditory cueing.
%
% 1. CONTRAST. We discovered a bug deep in my gamma-correction
% contrast-control software. in effect the displayed contrast of everything
% on the screen was roughly half of what it was supposed to be. this caused
% thresholds on a blank screen to be over-estimated by roughly a factor of
% 2. it did not affect thresholds in noise, because the calibration error
% attenuates signal and noise equally, resulting in the same
% signal-to-noise ratio, which is what determines performance. doubling the
% reported threshold contrast quadruples E0, which roughly quadruples Neq=
% N*E0/(E-E0). That's why Hormet's estimates of Neq were about a factor of
% 4 too high.
%
% 2. CUEING. Without a beep, threshold for the signal without noise was
% raised and variable, because there's no way to know when the signal
% occurs. When visual noise is present, the noise cues the time of
% presentation. Adding the beep made threshold without noise about a factor
% of 0.7 lower, and much more reliable.
%
% Along the way, not knowing which difference mattered, we tried to
% reproduce Manoj's signal and noise. We switched from Sloan to Bookman
% (which required enhancing our new software to work with any font) and we
% adopted his noise parameters (small noiseCheckDeg, binary noise). We
% mistakenly used half the letter size. I'm guessing that letter size
% matters and that the rest may be negligible.
%
% STIMULUS PARAMETERS TO MEASURE NEQ
% (NoiseAfterSec=NoiseBeforeSec)
%
% Manoj, years ago
% ITC Bookman Light, xHeightDeg 7.37
% binary, noiseCheckDeg 0.091, checkSec 0.013, noiseSD 0.5, noiseBeforeSec 0.5
% N 2.69E-05
% Luminance 112 cd/m^2, pupilDiameterMm 3.5
%
% Hormet, December, 2016
% Sloan, xHeightDeg 7.34
% gaussian, noiseCheckDeg 0.368, checkSec 0.017, noiseSD 0.16, noiseBeforeSec 0.2
% N 5.89e-05
% Luminance 212 cd/m^2, pupilDiameterMm 3.5
%
% Ning, February 24, 2017
% ITC Bookman Light, xHeightDeg 3.7
% binary, noiseCheckDeg 0.092, checkSec 0.013, noiseSD 0.5, noiseBeforeSec 0.2
% N 3.59E-05
% Luminance ?? cd/m^2, pupilDiameterMm 3.5

%%%%%%%%%%%%%%%%%%%%%%%%
% MAY 31, 2017 from Mario Kleiner
% Providing a fix for CLUT bugs in May 2017 Psychtoolbox.
% Hi Denis,
%
% all bugs should be fixed in my GitHub master branch.
%
% - 'PutImage' was utterly broken for normalized color range mode since
% forever. If this ever worked for you with that task, it would be a
% miracle. A fixed Screen() mex file will have to wait for the next
% official beta release, probably a couple of days out.
%
% In general i don't recommend use of PutImage in new code. It is awful
% code with no flexibility, miserable performance, and essentially no
% testing ever. It only exists for backwards compatibility with ancient
% code, and to scare little children.
%
% The 'PutImage' bug has to wait for the next beta release, because
% rebooting into OSX to recompile mex files puts me in a miserable mood
% very quickly, so we want to avoid that as much as possible, and i already
% lost 6 hours to this.
%
% ...
%
% For luts > 256 slots you will need a floating point framebuffer that can
% accurately represent more than 8 bit, that's why it got worse for your
% 2048 slot lut. Enabling the 11 bpc framebuffer would also cause PTB to
% use a 32 bit float ~ 23 bit linear precision intermediate virtual
% framebuffer, so that's why that partially fixed the 2048 slot lut.
%
% If you don't use a float framebuffer the data path was like this:
%
% floating point color (~23 bit) rendering into -> 8 bpc virtual
% framebuffer (rounding/quantizing from 23 bpc to 8 bpc=loss of
% precision, potential roundoff errors)-> lut mapping (convert 8 bpc back
% to 23 bpc, index into lut, output 23 bpc) -> System framebuffer of 8 bpc.
%
% With native 11 bpc mode you have:
%
% floating point color (~23 bit) rendering into -> 23 bpc virtual
% framebuffer -> lut mapping (23 bpc input index into lut, output 23 bpc)
% -> Downconversion to max. 11 bpc system framebuffer on Apple OSX. So no
% loss of precision or rounding before the lut lookup.
%
% The CLUT bugs will be fixed with this new PsychImaging.m file:
%
% https://raw.githubusercontent.com/kleinerm/Psychtoolbox-3/master/Psychtoolbox/PsychGLImageProcessing/PsychImaging.m
%
% -mario

%% DITHERING
% Dear Beau
%
% Thanks. Here are my five technical questions (below) about how dithering
% is done on my iMac 5k and MacBook Pro.
%
% MEASUREMENTS. I've been measuring the luminance precision that I can
% attain on various Apple machines. (You've got a copy of my MATLAB test
% program, MeasureLuminancePrecision.m.) I'm very happy to be getting 11
% bits (per color channel) on my iMac 5k and my MacBook Pro (Retina,
% 15-inch, Mid 2015). Both have AMD 'Southern Islands' GPUs. AMD Radeon R9
% M290X in MacBook Pro (Retina, 15-inch, Mid 2015) AMD Radeon R9 M370X in
% iMac (Retina 5K, 27-inch, Late 2014) Apple claims "deep color" for the
% iMac 5k, and not for the MacBook Pro. I get 11 bits on both.
% https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_11_2.html#//apple_ref/doc/uid/TP40016630-SW1
% https://developer.apple.com/library/content/samplecode/DeepImageDisplayWithOpenGL/Introduction/Intro.html#//apple_ref/doc/uid/TP40016622
%
% IMPRESSIONS. Mario Kleiner supports the Psychtoolbox software, which is
% used by hundreds of scientists worldwide to do vision research on
% Macintosh computers. http://psychtoolbox.com I've done various tests with
% Mario, peeking at video GPU registers. He has the impression that
% requesting 10-bit mode in fact turns on the dithering, giving us 1 extra
% bit improvement over the iMac's 10-bit panel and 3 extra bits over the
% MacBook Pro's 8-bit panel. We are guessing that dithering is done by the
% GPU, because the very welcome dithering is unfortunately accompanied by
% loss of ability to achieve reliable time synchronization of our software
% with the display, presumably because dithering by the GPU introduces an
% indirection in the video pipeline.
%
% CONCERNS. I'm using the 11-bit precision to measure visual sensitivity
% thresholds that my professional reputation depends on. Here's a link to
% my latest poster:
% http://psych.nyu.edu/pelli/pubs/pelli2017vss-peripheral-noise.pdf The
% threshold contrasts in Fig. 2 with zero noise require luminance precision
% better than 8 bits. 10 bits might be enough. 11 bits is dandy. However,
% I'm worried that there may be systematic consequences of the dither that
% affect the archival sensitivity functions that I'm measuring and
% publishing (like those on the poster).
%
% Might an Apple engineer answer five questions about dithering on the
% MacBook Pro and iMac?
%
% FIVE QUESTIONS: 1. When in 10-bit mode, do the Macs just add a 1- or
% 3-bit static dither image to all video output before it goes through the
% 8- or 10-bit panel? 2. Is there error diffusion? 3. Does the same pixel
% image always produce the same luminance image? 4. Are successive images
% dithered independently? 5. While using dither, any suggestions for how I
% might synchronize my program to the frame store?
%
% Best Denis
%
% Mario's guesses about what's happening.
%
% What you have under macOS 10.12 in high-precision mode is half-float
% "framebuffers", which store pixels in 16 bit non-linear floating point
% format, and that allows in practice to represent at most 11 bits per
% channel linear precision for the displayable intensity range 0.0 - 1.0.
% Psychtoolbox renders into this half-float framebuffer, which is not
% actually the real framebuffer, but "faked" by the OS. Then at Flip time,
% that buffer's content is converted into the actual framebuffer format by
% the OS (probably the display server), applying Apple's proprietary
% dithering during the process, and the dithered output goes to an 8-bit
% framebuffer on the MacBook Pro, and a 10-bit framebuffer on the iMac.
% Then (presumably) the MacBookPro drives an 8-bit panel from its 8-bit
% framebuffer, and the iMac drives a native 10-bit panel from its 10-bit
% framebuffer. This indirection through the half-float to native 8- or
% 10-bit framebuffer seems to prevent precise control over when stimulus
% onset happens and any precise timestamping, killing our timing, causing
% sync test failures.
%
% It seems that under macOS, these computers are neither using the true
% depth of their framebuffers (8 and 10 bit) nor the hardware dithering.
% Instead Apple uses a proprietary algorithm. So technically it is not the
% dithering itself impairing performance so much that it kills timing.
% Instead it is the indirection from the half-float framebuffer to the real
% framebuffer that makes timing control impossible. It's the same
% mechanism/indirection used when one displays non-fullscreen windows,
% where precise timing is also impossible, because the Quartz desktop
% compositor redirects all our output into intermediate buffers to perform
% image compositing into the true framebuffer to add some bling to the
% desktop GUI.
%
% I assume the dithering is implemented by use of shaders on the GPU, maybe
% OpenGL/Metal shading language based, maybe using the OpenCL GPU compute
% language. This way they can implement their own proprietary dithering
% method, but still get hardware acceleration of the dithering from the
% GPU, so it only takes milliseconds instead of tens or hundreds of
% milliseconds. That means it doesn't impair performance too much, it only
% impairs timing of applications that need tight timing control and
% timestamping.
%
% Of course it still means they can't do really advanced algorithms, given
% a high resolution display and the constraint of only having a few msecs
% time. Probably only algorithms that operate in a small pixel
% neighbourhood of each pixel as anything else would be rather compute
% intense. Most likely not temporal dithering, as that would be more
% difficult for a software implementation, and potentially suck way more of
% the holy battery power on a laptop, but spatial dithering, but
% potentially with a dither pattern that changes at each Screen('flip'),
% ie. not re-randomized at video refresh rate, but still different for each
% stimulus frame you present.
%
% I assume the potential artifacts caused by this and its trade-offs will
% be larger the more bits you have to fake. So on the iMac it is probably
% not too bad, as you get 10 bits from the actual display hardware, so only
% have to add 1 bit via dithering. On the MacBook Pro you have to fake 3
% extra bits. In other words. i assume the dither algorithm is different
% for the MacBook Pro and the iMac.

%% BIT STEALING
% On 06/04/2017 08:47 AM, Denis Pelli wrote:
% dear mario thanks. i asked about timing because i care about timing. if
% he can help, great. if he can't help, it seems good to get at least one
% of the apple engineers thinking about it. if they know people care about
% this they might give more weight to it in the future. thanks for
% reminding me about the bit stealing. i can try doing photometry on it. i
% suppose that will give the expected answer. i'm less
%
% MARIO ON BIT STEALING: I don't know how good it is, and it probably
% depends a lot on the emission characteristics of the panels in use, given
% that it was originally used on CRT monitors etc. I never read the
% original article as it was behind a pay-wall, and this is a
% implementation based on some website that introduced the same trick (see
% the help text), not the scientific article. But somebody who read the
% article told me it is essentially the same. At least measuring that one
% panel on 1/128th of the range with your script gave expected results. A
% full measurement would have required long enough access to a suitable
% black cubicle instead of the regular lab space with no controlled
% lighting at all.
%
% DENIS: sure how to estimate visibility of the artifacts. i suppose if i
% don't
%
% MARIO: I didn't perceive variation on a 8 bpc panel with your script. You
% probably could use the ColorCal x,y,z measurements to not only get
% average luminance but average color/saturation and see if anything
% changes systematically with your stimulus? Probably not, but who knows?
% If the way the color vectors are "tilted" off the pure luminance r=g=b
% axis would create some systematic "color contrast" edges in "color space"
% maybe it could somehow subconsciously enhance contrast if you are really
% unlucky?
%
% DENIS: see any color variation i don't need to worry. do you think that
% i'd have much better timing with bit stealing?
%
% MARIO: On Linux it won't impair timing at all, you should always get
% excellent timing.
%
% On OSX you have at least the chance of better timing on AMD graphics, as
% the processing is done within PTB, not some Apple intermediate layers. On
% the MBP with standard 8 bpc framebuffer it would probably work as well as
% anything can work timing-wise on osx. On the iMac i think a couple of
% forum posts about sync failures and their specific symptoms indicated
% that timing is always broken regardless if half-float framebuffers are
% used or not. That's weird, because there isn't any reason for a
% troublesome indirection if no custom dithering is used, but maybe that's
% just some OS bug or lazyness - not switching to normal processing even if
% special processing isn't needed.
%
% Anyway you'll find out quickly if the sync failures go away at least most
% of the time or not at all. And if you run with skipsynctest setting 1, so
% PTB continues even in case of sync failures, it will print diagnostic
% messages at each flip that will quickly tell.
%
% Of course you could also dual-boot the iMac under Linux and then have
% perfect timing and a 10 bpc panel like on the Linux HP laptop, plus the
% bit-stealing style + 2.7 bits enhancements.
%
% Or if you had a CRT around, go back to the roots and get a VideoSwitcher
% for about $300 (help PsychVideoSwitcher), which is pretty much the video
% attenuator as you co-invented it, just for use with regular color
% monitors, with some improvements. PTB has drivers for it under the
% PsychImaging tasks "EnableVideoSwitcherSimpleLuminanceOutput" and
% "EnableVideoSwitcherCalibratedLuminanceOutput". Up to 16 bit luminance
% precision iirc.
%
% http://lobes.osu.edu/videoSwitcher/
%
% -mario

%% INPUT ARGUMENT
if exist('oIn','var') && isfield(oIn,'quitSession') && oIn.quitSession
   % If the user wants to quit, then return immediately.
   o=oIn;
   return
end

%% SUGGESTED VALUES FOR ANNULUS
if false
   % Copy this to produce a Gaussian annulus:
   o.noiseSD=0.2; % Usually in the range 0 to 0.4. Typically 0.2.
   o.annularNoiseSD=0;
   o.noiseRadiusDeg=inf;
   o.annularNoiseEnvelopeRadiusDeg=2;
   o.noiseEnvelopeSpaceConstantDeg=1.1;
   o.annularNoiseBigRadiusDeg=inf;
   o.annularNoiseSmallRadiusDeg=inf;
   % Returns: o.centralNoiseEnvelopeE1DegDeg
end
if false
   % Copy this to produce a hard-edge annulus:
   o.noiseSD=0; % Usually in the range 0 to 0.4. Typically 0.2.
   o.annularNoiseSD=0.2; % Typically nan (i.e. use o.noiseSD) or 0.2.
   o.noiseRadiusDeg=0;
   o.annularNoiseEnvelopeRadiusDeg=0;
   o.noiseEnvelopeSpaceConstantDeg=inf;
   o.annularNoiseBigRadiusDeg=3; % Noise extent re target. Typically 1 or inf.
   o.annularNoiseSmallRadiusDeg=1; % Typically 1 or 0 (no hole).
   % Returns: o.centralNoiseEnvelopeE1DegDeg
end
% For a "fair" contest of hard and soft annuli, we should:
%
% 1. make the central radius of the soft one
% o.annularNoiseEnvelopeRadiusDeg match the central radius of the hard one:
% (o.annularNoiseSmallRadiusDeg+o.annularNoiseBigRadiusDeg)/2
%
% 2. adjust the annulus thickness of the hard annulus
% o.annularNoiseBigRadiusDeg-o.annularNoiseSmallRadiusDeg to achieve the
% same "area" as the Gaussian annulus. This "area" is reported in a new
% variable: o.centralNoiseEnvelopeE1DegDeg

%% GLOBALS, FILES
global window fixationLines fixationCrossWeightPix labelBounds ...
   screenRect tTest idealT64 leftEdgeOfResponse checks img cal ...
   ff whichSignal dataFid trial
% This list of global variables is shared only with the several newly
% created subroutines at the end of this file. The list is woefully
% incomplete as the new routines haven't been tested as subroutines, and
% many of their formerly locally variables need to be made global.
global oOld % Saved from last run. Skip prompts that were the same in recent run.
addpath(fullfile(fileparts(mfilename('fullpath')),'AutoBrightness')); % folder in same directory as this M file
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this M file
% echo_executing_commands(2, 'local');
% diary ./diary.log
% [~, vStruct]=PsychtoolboxVersion;
% if IsOSX && vStruct.major*1000+vStruct.minor*100+vStruct.point < 3013
%    error('Your Mac OSX Psychtoolbox is too old. We need at least Version 3.0.13. Please run: UpdatePsychtoolbox');
% end
rng('shuffle'); % Use time to seed the random number generator.
if ismac && ~ScriptingOkShowPermission
   error(['Please give MATLAB permission to control the computer. ',...
      'You''ll need admin privileges to do this.']);
end
plusMinusChar=char(177); % Use this instead of literal plus minus sign to prevent corruption of this non-ASCII character.
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
ff=1; % Once we open a data file, ff will print to both screen and data file.

%% DEFAULT VALUE FOR EVERY "o" PARAMETER
% They are overridden by what you provide in the argument struct oIn.
if nargin < 1 || ~exist('oIn','var')
   oIn.noInputArgument=true;
end
o=[];
o.questPlusEnable=false;
o.questPlusSteepnesses=1:0.1:5;
o.questPlusGuessingRates=nan; % 1/alternatives
o.questPlusLapseRates=[0:0.01:0.05];
o.questPlusLogContrasts=-3:0.05:0.5;
o.questPlusPrint=true;
o.questPlusPlot=true;
o.guess=nan;
o.lapse=0.02;
o.replicatePelli2006=false;
o.clutMapLength=2048; % enough for 11-bit precision.
o.useNative10Bit=false;
o.useNative11Bit=true;
o.ditherCLUT=61696; % Use this only on Denis's PowerBook Pro and iMac 5k.
o.ditherCLUT=false; % As of June 28, 2017, there is no measurable effect of this dither control.
o.enableCLUTMapping=true; % Required. Using software CLUT.
o.assessBitDepth=false;
o.useFractionOfScreen=false; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
o.viewingDistanceCm=50; % viewing distance
o.flipScreenHorizontally=false; % Use this when viewing the display in a mirror.
o.observer=''; % Name of person or algorithm.
% o.observer='brightnessSeeker'; % Existing algorithm instead of person.
% o.observer='blackshot'; % Existing algorithm instead of person.
% o.observer='maximum'; % Existing algorithm instead of person.
% o.observer='ideal'; % Existing algorithm instead of person.
algorithmicObservers={'ideal', 'brightnessSeeker', 'blackshot', 'maximum'};
o.experimenter='';
o.experiment='';
o.eyes='both'; % 'left', 'right', 'both', or 'one', which asks user to specify at runtime.
o.luminanceTransmission=1; % Less than one for dark glasses or neutral density filter.
o.trialsPerRun=40; % Typically 40.
o.trials=0; % Initialize trial counter so it's defined even if user quits early.
o.runNumber=1; % For display only, indicate the run number. When o.runNumber==runsDesired this program says "Congratulations" before returning.
o.runsDesired=1; % How many runs you to plan to do, used solely for display (and congratulations).
o.speakInstructions=false;
o.congratulateWhenDone=true; % 0 or 1. Spoken after last run (i.e. when o.runNumber==o.runsDesired). You can turn this off.
o.quitRun=false; % Returned value is true if the user aborts this run (i.e. threshold).
o.quitSession=false; % Returned value is true if the observer wants to quit now; no more runs.
o.targetKind='letter';
% o.targetKind='gabor'; % one cycle within targetSize
o.font='Sloan';
% o.font='Bookman';
% o.allowAnyFont=false; % Old code assumes Sloan font.
o.allowAnyFont=true; % New code supports any font.
o.alphabet='DHKNORSVZ';
o.printTargetBounds=false;
o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
o.targetCyclesPerDeg=nan;
o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
o.targetGaborNames='VH';
o.targetModulates='luminance'; % Display a luminance decrement.
% o.targetModulates='entropy'; % Display an entropy increment.
% o.targetModulates='noise';  % Display a noise increment.
o.task='identify'; % 'identify' or '4afc'
% o.thresholdParameter='size';
% o.thresholdParameter='spacing';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast','size', 'spacing', or 'flankerContrast'.
o.constantStimuli=[];
o.useMethodOfConstantStimuli=false;
o.thresholdPolarity=1; % Must be -1 or 1;
% WARNING: size and spacing are not yet fully implemented.
o.alternatives=9; % The number of letters to use from o.alphabet.
o.tGuess=nan; % Specify a finite value for Quest, or nan for default.
o.tGuessSd=nan; % Specify a finite value for Quest, or nan for default.
o.pThreshold=0.75;
o.steepness=[]; % Typically 1.7, 3.5, or []. [] asks NoiseDiscrimination to set this at runtime.
o.eccentricityXYDeg=[0 0]; % eccentricity of target center re fixation, + for right & up.
o.nearPointXYInUnitSquare=[0.5 0.5]; % location of target center on screen. [0 0]  lower right, [1 1] upper right.
o.targetHeightDeg=2; % Target size, range 0 to inf. If you ask for too
% much, it gives you the max possible.
% o.targetHeightDeg=30*o.noiseCheckDeg; % standard for counting neurons
% project
o.minimumTargetHeightChecks=8; % Minimum target resolution, in units of the check size.
o.fullResolutionTarget=false; % True to render signal at full resolution (targetCheckPix=1). False to use noise resolution (targetCheckPix=noiseCheckPix).
o.targetMargin=0.25; % Minimum from edge of target to edge of o.stimulusRect, as fraction of targetHeightDeg.
o.targetDurationSec=0.2; % Typically 0.2 or inf (wait indefinitely for response).
o.contrast=1; % Default is positive contrast.
o.useFlankers=false; % Enable for crowding experiments.
o.flankerContrast=-0.85; % Negative for dark letters.
o.flankerContrast=nan; % Nan requests that flanker contrast always equal target contrast.
o.flankerSpacingDeg=4;
% o.flankerSpacingDeg=1.4*o.targetHeightDeg; % Put this in your code, if
% you like. It won't work here.
o.noiseSD=0.2; % Usually in the range 0 to 0.4. Typically 0.2.
% o.noiseSD=0; % Usually in the range 0 to 0.4. Typically 0.2.
o.annularNoiseSD=0; % Typically nan (i.e. use o.noiseSD) or 0.2.
o.noiseCheckDeg=0.05; % Typically 0.05 or 0.2.
o.noiseRadiusDeg=inf; % When o.task=4afc, the program will set o.noiseRadiusDeg=o.targetHeightDeg/2;
o.noiseEnvelopeSpaceConstantDeg=inf;
o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at noiseRadiusDeg.
o.noiseSpectrum='white'; % 'pink' or 'white'
o.showBlackAnnulus=false;
o.blackAnnulusContrast=-1; % (LBlack-LMean)/LMean. -1 for black line. >-1 for gray line.
o.blackAnnulusSmallRadiusDeg=2;
o.blackAnnulusThicknessDeg=0.1;
o.annularNoiseBigRadiusDeg=inf; % Noise extent in deg, or inf.
o.annularNoiseSmallRadiusDeg=inf; % Hole extent or 0 (no hole).
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
o.noiseFrozenInTrial=false; % 0 or 1.  If true (1), use same noise at all locations
o.noiseFrozenInRun=false; % 0 or 1.  If true (1), use same noise on every trial
o.noiseFrozenInRunSeed=0; % 0 or positive integer. If o.noiseFrozenInRun, then any nonzero positive integer will be used as the seed for the run.
o.markTargetLocation=false; % Is there a mark designating target position?
o.targetMarkDeg=1;
o.useFixation=true;
o.fixationIsOffscreen=false;
o.fixationCrossDeg=inf; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=true; % 0 or 1.
o.fixationCrossBlankedUntilSecAfterTarget=0.6; % Pause after stimulus before display of fixation. Skipped when fixationCrossBlankedNearTarget. Not needed when eccentricity is bigger than the target.
o.blankingRadiusReTargetHeight= nan;
o.blankingRadiusReEccentricity= 0.5;
o.textSizeDeg=0.6;
o.saveSnapshot=false; % 0 or 1.  If true (1), take snapshot for public presentation.;
o.snapshotContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.;
o.tSnapshot=nan; % nan to request program defaults.;
o.cropSnapshot=false; % If true (1), show only the target and noise, without unnecessary gray background.;
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=true;
o.snapshotShowsFixationAfter=false;
o.saveStimulus=false; % saves to o.savedStimulus;
o.gapFraction4afc=0.03; % Typically 0, 0.03, or 0.2. Gap, as a fraction of o.targetHeightDeg, between the four squares in 4afc task, ignored in identify task.;
o.showCropMarks=false; % mark the bounding box of the target
o.showResponseNumbers=true;
o.responseNumbersInCorners=false;
o.printCrossCorrelation=false;
o.printLikelihood=false;
o.assessLinearity=false;
o.assessContrast=false; % diagnostic information
o.measureContrast=false;
o.usePhotometer=true; % use photometer or 8-bit model
o.assessLoadGamma=false; % diagnostic information
o.assessLowLuminance=false;
o.assessGray=false; % For debugging. Diagnostic printout when we load gamma table.
o.assessTargetLuminance=false;
% o.observerQuadratic=-1.2; % estimated from old second harmonic data
o.observerQuadratic=-0.7; % adjusted to fit noise letter data.
o.backgroundEntropyLevels=2; % Value used only if o.targetModulates is 'entropy'
o.idealEOverNThreshold=nan; % You can run the ideal first, and then provide its threshold as a reference when testing human observers.
o.screen=0;
o.screen=max(Screen('Screens'));
o.alphabetPlacement='top'; % 'top' or 'right';
o.replicatePelli2006=false;
o.isWin=IsWin; % override this to simulate Windows on a Mac.
o.movieFrameFlipSec=[]; % flip times (useful to calculate frame drops)
o.useDynamicNoiseMovie=false; % 0 for static noise
o.moviePreSec=0;
o.moviePostSec=0;
o.likelyTargetDurationSec=[];
o.measuredTargetDurationSec=[];
o.movieFrameFlipSec=[];
o.printDurations=false;
o.newClutForEachImage=true;
o.experiment='';
o.condition=1;
o.conditionName='';
o.minScreenWidthDeg=nan;
o.maxViewingDistanceCm=nan;
o.useFilter=false;
o.filterTransmission=0.115; % our dark glasses.
o.desiredRetinalIlluminanceTd=[];
o.desiredLuminance=[];
o.desiredLuminanceFactor=1;
o.luminanceFactor=1;
o.luminance=[];
o.retinalIlluminanceTd=[];
o.pupilDiameterMm=[];
o.annularNoiseEnvelopeRadiusDeg=0;
o.labelAlternatives=[];
o.trialsPerRun=40;
o.runsDesired=1;
o.eyes='both';
o.readAlphabetFromDisk=false;
o.borderLetter=[];
o.seed=[];
% The user can only set fields that are initialized above. Thixxxs is meant to
% catch any mistakes where the user tries to set a field that isn't used
% below. We ignore input fields that are known output fields. Any field
% that is neither already initialized or a known output field is flagged as
% a fatal error, so it gets fixed immediately.

%% READ USER-SUPPLIED o PARAMETERS
if false
   % ACCEPT ALL o PARAMETERS.
   % All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
   fields=fieldnames(oIn);
   for i=1:length(fields)
      field=fields{i};
      o.(field)=oIn.(field);
   end
else
   % ACCEPT ONLY KNOWN o PARAMETERS.
   % For each condition, all fields in the user-supplied "oIn" overwrite
   % corresponding fields in "o". We ignore any field in oIn that is not
   % already defined in o. If the ignored field is a known output field,
   % then we ignore it silently. We warn of unknown fields because they
   % might be typos for input fields.
   conditions=1;
   initializedFields=fieldnames(o);
   knownOutputFields={'labelAlternatives' 'beginningTime' ...
      'functionNames' 'dataFilename' 'dataFolder' 'cal' 'pixPerDeg' ...
      'lineSpacing' 'stimulusRect' 'noiseCheckPix' 'maxLRange' ...
      'minLRange' 'targetHeightPix' ...
      'contrast' 'targetWidthPix' 'checkSec' 'moviePreFrames'...
      'movieSignalFrames' 'moviePostFrames' 'movieFrames' 'noiseSize'...
      'annularNoiseSmallSize' 'annularNoiseBigSize' 'canvasSize'...
      'noiseListBound' 'noiseIsFiltered' 'noiseListSd' 'N' 'NUnits' ...
      'targetRectLocal' 'xHeightPix' 'xHeightDeg' 'HHeightPix' ...
      'HHeightDeg' 'alphabetHeightDeg' 'annularNoiseEnvelopeRadiusDeg' ...
      'centralNoiseEnvelopeE1DegDeg' 'E1' 'data' 'psych' 'questMean'...
      'questSd' 'p' 'trials' 'EOverN' 'efficiency' 'targetDurationSecMean'...
      'targetDurationSecSD' 'E' 'signal' 'newCal'...
      'beamPositionQueriesAvailable' ...
      'drawTextPlugin' 'fixationXYPix' 'maxEntry' 'nearPointXYDeg'...
      'nearPointXYPix' 'pixPerCm' 'psychtoolboxKernelDriverLoaded'...
      'targetXYPix' 'textLineLength' 'textSize' 'unknownFields'...
      'deviceIndex' 'speakEachLetter' 'targetCheckDeg' 'targetCheckPix'...
      'textFont'  'LMean' 'targetCyclesPerDeg' 'contrast' ...
      'thresholdParameterValueList' 'noInputArgument' ...
      };
   unknownFields={};
   for condition=1:conditions
      oo(condition)=o;
      inputFields=fieldnames(oIn(condition));
      oo(condition).unknownFields={};
      for i=1:length(inputFields)
         if ismember(inputFields{i},initializedFields)
            % We accept only the parameters that we initialized above.
            % Overwrite initial value.
            oo(condition).(inputFields{i})=oIn(condition).(inputFields{i});
         elseif ~ismember(inputFields{i},knownOutputFields)
            % Report unknown field
            unknownFields{end+1}=inputFields{i};
            oo(condition).unknownFields{end+1}=inputFields{i};
         end
      end
      oo(condition).unknownFields=unique(oo(condition).unknownFields);
   end
   unknownFields=unique(unknownFields);
   if ~isempty(unknownFields)
      error(['Unknown field(s) in input struct:' sprintf(' o.%s',unknownFields{:}) '.']);
      %       warning off backtrace
      %       warning(['ERROR: unknown o input fields:' sprintf(' %s',unknownFields{:}) '.']);
      %       warning on backtrace
      %       o.quitSession=true;
      %       return
   end
   o=oo(1);
end

%% SCREEN PARAMETERS
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
screenBufferRect=Screen('Rect',o.screen);
screenRect=Screen('Rect',o.screen,1);
resolution=Screen('Resolution',o.screen);
if o.useFractionOfScreen
   screenRect=round(o.useFractionOfScreen*screenRect);
end

%% OLD FEATURE: REPLICATE PELLI 2006
% 3/23/17 moved this block of code to after reading o parameters. Untested in new location.
% if o.replicatePelli2006 || isfield(oIn,'replicatePelli2006') && oIn.replicatePelli2006
%     % Set parameter defaults to match conditions of Pelli et al. (2006). Their
%     % Table A (p. 4668) reports that ideal log E is -2.59 for Sloan, and
%     % that log N is -3.60. Thus they reported ideal log E/N 1.01. This
%     % script recreates their conditions and gets the same ideal threshold
%     % E/N. Phew!
%     % Pelli, D. G., Burns, C. W., Farell, B., & Moore-Page, D. C. (2006)
%     % Feature detection and letter identification. Vision Research, 46(28),
%     % 4646-4674.
%     % https://psych.nyu.edu/pelli/pubs/pelli2006letters.pdf
%     % https://psych.nyu.edu/pelli/papers.html
%     o.idealEOverNThreshold=10^(-2.59--3.60); % from Table A of Pelli et al. 2006
%     o.observer='ideal';
%     o.trialsPerRun=1000;
%     o.alphabet='CDHKNORSVZ'; % As in Pelli et al. (2006)
%     o.alternatives=10; % As in Pelli et al. (2006).
%     o.pThreshold=0.64; % As in Pelli et al. (2006).
%     o.noiseType='gaussian';
%     o.noiseSD=0.25;
%     o.noiseCheckDeg=0.063;
%     o.targetHeightDeg=29*o.noiseCheckDeg;
%     o.pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
%     o.pixPerDeg=2/0.0633; % As in Pelli et al. (2006).
%     degPerCm=o.pixPerCm/o.pixPerDeg;
%     o.viewingDistanceCm=57/degPerCm;
% end

%% SET UP MISCELLANEOUS
%onCleanupInstance=onCleanup(@()listenchar;sca); % clears screen and restores keyboard when function terminated.
useImresize=exist('imresize','file'); % Requires the Image Processing Toolbox.
if isnan(o.annularNoiseSD)
   o.annularNoiseSD=o.noiseSD;
end
if o.saveSnapshot
   if isfinite(o.snapshotContrast) && streq(o.targetModulates,'luminance')
      o.tSnapshot=log10(abs(o.snapshotContrast));
   end
   if ~isfinite(o.tSnapshot)
      switch o.targetModulates
         case 'luminance'
            o.tSnapshot=-0.0; % log10(contrast)
         case 'noise'
            o.tSnapshot=.3; % log10(r-1)
         case 'entropy'
            o.tSnapshot=0; % log10(r-1)
         otherwise
            error('Unknown o.targetModulates "%s".',o.targetModulates);
      end
   end
end
if streq(o.targetKind,'gabor')
   assert(length(o.targetGaborNames) >= length(o.targetGaborOrientationsDeg))
   o.alternatives=length(o.targetGaborOrientationsDeg);
   o.alphabet=o.targetGaborNames(1:o.alternatives);
end
if isempty(o.labelAlternatives)
   switch o.targetKind
      case 'gabor'
         o.labelAlternatives=true;
      case 'letter'
         o.labelAlternatives=false;
   end
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
   catch
      cal.brightnessReading=NaN;
   end
end
if cal.ScreenConfigureDisplayBrightnessWorks
   AutoBrightness(cal.screen,0);
   ffprintf(ff,'Turning autobrightness off. Setting "brightness" to %.2f, on a scale of 0.0 to 1.0;\n',cal.brightnessSetting);
end


%% TRY-CATCH BLOCK CONTAINS ALL CODE IN WHICH WINDOW IS OPEN
try
   %% OPEN WINDOW
   Screen('Preference', 'SkipSyncTests',1);
   Screen('Preference','TextAntiAliasing',1);
   if o.useFractionOfScreen
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
   if ~o.useFractionOfScreen
      [window,screenRect]=PsychImaging('OpenWindow',cal.screen,1.0);
   else
      r=round(o.useFractionOfScreen*screenBufferRect);
      r=AlignRect(r,screenBufferRect,'right','bottom');
      [window,screenRect]=PsychImaging('OpenWindow',cal.screen,1.0,r);
   end
   screenRect=Screen('Rect',cal.screen,1); % screen rect in UseRetinaResolution mode
   if o.useFractionOfScreen
      screenRect=round(o.useFractionOfScreen*screenRect);
   end
   % if cal.hiDPIMultiple~=1
   %     ffprintf(ff,'HiDPI: It doesn''t matter, but you might be curious to know.\n');
   %     if ismac
   %         str='Your Retina display';
   %     else
   %         str='Your display';
   %     end
   %     ffprintf(ff,'%s is in dual-resolution HiDPI mode. Display resolution is %.2fx buffer resolution.\n',str,cal.hiDPIMultiple);
   %     ffprintf(ff,'Draw buffer is %d x %d. ',screenBufferRect(3:4));
   %     ffprintf(ff,'Display is %d x %d.\n',screenRect(3:4));
   %     ffprintf(ff,'We are using it in its native %d x %d resolution.\n',resolution.width,resolution.height);
   %     ffprintf(ff,'You can use Switch Res X (http://www.madrau.com/) to select a pure resolution, not HiDPI.\n');
   % end
   
   %% ASK EXPERIMENTER NAME
   instructionalMarginPix=round(0.08*min(RectWidth(screenRect),RectHeight(screenRect)));
   o.textSize=39;
   o.textFont='Verdana';
   if window
      % Adjust textSize so our string fits on screen.
      Screen('TextSize',window,o.textSize);
      Screen('TextFont',window,o.textFont,0);
      font=Screen('TextFont',window);
      if ~streq(font,o.textFont)
         warning off backtrace
         warning('The o.textFont "%s" is not available. Using %s instead.',o.textFont,font);
         warning on backtrace
      end
      instructionalTextLineSample='Please slowly type your name followed by RETURN. more.....more';
      boundsRect=Screen('TextBounds',window,instructionalTextLineSample);
      fraction=RectWidth(boundsRect)/(RectWidth(screenRect)-2*instructionalMarginPix);
      % Adjust textSize so our line fits perfectly.
      o.textSize=round(o.textSize/fraction);
   end
   black=0; % The CLUT color code for black.
   white=WhiteIndex(window); % Retrieves the CLUT color code for white.
   o.gray1=mean([white black]);
   o.deviceIndex=-3; % all keyboard and keypad devices
   o.speakEachLetter=false;
   o.useSpeech=false;
   if isempty(o.experimenter)
      ListenChar(2); % no echo
      Screen('FillRect',window,o.gray1);
      Screen('TextSize',window,o.textSize);
      Screen('TextFont',window,o.textFont,0);
      Screen('DrawText',window,'Hello,',instructionalMarginPix,screenRect(4)/2-5*o.textSize,black,o.gray1);
      Screen('DrawText',window,'Please slowly type the experimenter''s name followed by RETURN.',instructionalMarginPix,screenRect(4)/2-3*o.textSize,black,o.gray1);
      Screen('TextSize',window,round(0.6*o.textSize));
      Screen('DrawText',window,'I''ll remember your answers, to skip these questions on the next run.',instructionalMarginPix,screenRect(4)/2-1.5*o.textSize,black,o.gray1);
      Screen('TextSize',window,round(o.textSize*0.35));
      Screen('DrawText',window,double('NoiseDiscrimination Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,o.gray1,1);
      if IsWindows
         background=[];
      else
         background=o.gray1;
      end
      Screen('TextSize',window,o.textSize);
      fprintf('*Waiting for experimenter name.\n');
      [name,terminatorChar]=GetEchoString(window,'Experimenter name:',instructionalMarginPix,0.82*screenRect(4),black,background,1,o.deviceIndex);
      if ismember(terminatorChar,[escapeChar graveAccentChar])
         o.quitRun=true;
         o.quitSession=OfferToQuitSession(window,o,instructionalMarginPix,screenRect);
         if o.quitSession
            ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
         else
            ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
         end
         ListenChar(0);
         ShowCursor;
         sca;
         return
      end
      Screen('FillRect',window,o.gray1);
      o.experimenter=name;
   end
   
   %% ASK OBSERVER NAME
   if isempty(o.observer)
      ListenChar(2); % no echo
      Screen('FillRect',window,o.gray1);
      Screen('TextSize',window,o.textSize);
      Screen('TextFont',window,o.textFont,0);
      Screen('DrawText',window,'Hello Observer,',...
         instructionalMarginPix,screenRect(4)/2-5*o.textSize,black,o.gray1);
      Screen('DrawText',window,'Please slowly type your name followed by RETURN.',...
         instructionalMarginPix,screenRect(4)/2-3*o.textSize,black,o.gray1);
      Screen('TextSize',window,round(o.textSize*0.35));
      Screen('DrawText',window,double('NoiseDiscrimination Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,o.gray1,1);
      Screen('TextSize',window,o.textSize);
      if IsWindows
         background=[];
      else
         background=o.gray1;
      end
      fprintf('*Waiting for observer name.\n');
      [name,terminatorChar]=GetEchoString(window,'Observer name:',instructionalMarginPix,0.82*screenRect(4),black,background,1,o.deviceIndex);
      if ismember(terminatorChar,[escapeChar graveAccentChar])
         o.quitRun=true;
         o.quitSession=OfferToQuitSession(window,o,instructionalMarginPix,screenRect);
         if o.quitSession
            ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
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
   
   %% ASK FILTER TRANSMISSION
   persistent previousRunUsedFilter
   if ~o.useFilter
      o.filterTransmission=1;
      if previousRunUsedFilter
         % If the preceding run had a filter, and this run does not, we ask
         % the observer to remove the filter or sunglasses.
         ListenChar(2); % no echo
         Screen('FillRect',window,o.gray1);
         Screen('TextSize',window,o.textSize);
         Screen('TextFont',window,o.textFont,0);
         Screen('DrawText',window,'Please remove any filter or sunglasses.',...
            instructionalMarginPix,screenRect(4)/2-7*o.textSize,black,o.gray1);
         Screen('DrawText',window,'Hit RETURN to continue.',...
            instructionalMarginPix,screenRect(4)/2-5*o.textSize,black,o.gray1);
         Screen('TextSize',window,round(o.textSize*0.35));
         Screen('DrawText',window,double('NoiseDiscrimination Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,o.gray1,1);
         Screen('TextSize',window,o.textSize);
         if IsWindows
            background=[];
         else
            background=o.gray1;
         end
         fprintf('*Waiting for observer to remove sunglasses.\n');
         [~,terminatorChar]=GetEchoString(window,'',...
            instructionalMarginPix,0.82*screenRect(4),black,background,1,o.deviceIndex);
         if ismember(terminatorChar,[escapeChar graveAccentChar])
            o.quitRun=true;
            o.quitSession=OfferToQuitSession(window,o,instructionalMarginPix,screenRect);
            if o.quitSession
               ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
            else
               ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
            end
            ListenChar(0);
            ShowCursor;
            sca;
            return
         end
         Screen('FillRect',window,o.gray1);
         % Keep the temporary window open until we open the main one, so
         % observer knows program is running.
      end
   else % if ~o.useFilter
      ListenChar(2); % no echo
      Screen('FillRect',window,o.gray1);
      Screen('TextSize',window,o.textSize);
      Screen('TextFont',window,o.textFont,0);
      Screen('DrawText',window,'Please use a filter or sunglasses to reduce the luminance.',...
         instructionalMarginPix,screenRect(4)/2-9*o.textSize,black,o.gray1);
      Screen('DrawText',window,'(Our lab sunglasses transmit 0.115)',...
         instructionalMarginPix,screenRect(4)/2-7*o.textSize,black,o.gray1);
      Screen('DrawText',window,'Please slowly type its transmission (between 0.000 and 1.000)',...
         instructionalMarginPix,screenRect(4)/2-5*o.textSize,black,o.gray1);
      if isempty(o.filterTransmission)
         Screen('DrawText',window,'followed by RETURN.',...
            instructionalMarginPix,screenRect(4)/2-3*o.textSize,black,o.gray1);
      else
         Screen('DrawText',window,sprintf('followed by RETURN. Or just hit RETURN to say: %.3f',o.filterTransmission),...
            instructionalMarginPix,screenRect(4)/2-3*o.textSize,black,o.gray1);
      end
      Screen('TextSize',window,round(o.textSize*0.35));
      Screen('DrawText',window,double('NoiseDiscrimination Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,o.gray1,1);
      Screen('TextSize',window,o.textSize);
      if IsWindows
         background=[];
      else
         background=o.gray1;
      end
      fprintf('*Waiting for observer to specify filter transmission.\n');
      [name,terminatorChar]=GetEchoString(window,'Filter transmission:',...
         instructionalMarginPix,0.82*screenRect(4),black,background,1,o.deviceIndex);
      if ~isempty(name)
         o.filterTransmission=str2num(name);
      end
      if isempty(o.filterTransmission)
         error('You must specify the filter transmission.');
      end
      if ismember(terminatorChar,[escapeChar graveAccentChar])
         o.quitRun=true;
         o.quitSession=OfferToQuitSession(window,o,instructionalMarginPix,screenRect);
         if o.quitSession
            ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
         else
            ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
         end
         ListenChar(0);
         ShowCursor;
         sca;
         return
      end
      Screen('FillRect',window,o.gray1);
      % Keep the temporary window open until we open the main one, so observer
      % knows program is running.
   end % if previousRunUsedFilter
   previousRunUsedFilter=o.useFilter;
   
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
   
   %% LUMINANCE
   % LStandard is the highest luminance at which we can display a sinusoid
   % at maximum contrast (nearly 1). I have done most of my experiments at
   % that luminance.
   LStandard=mean([min(cal.old.L) max(cal.old.L)]);
   if 1 ~= ~isempty(o.desiredRetinalIlluminanceTd)+~isempty(o.desiredLuminance)+~isempty(o.desiredLuminanceFactor)
      error('You must specify one and only one of o.desiredLuminanceFactor, o.desiredLuminance, and o.desiredRetinalIlluminanceTd.');
   end
   if ~isempty(o.desiredLuminance)
      o.luminanceFactor=o.desiredLuminance/(LStandard*o.filterTransmission);
   end
   if ~isempty(o.desiredLuminanceFactor)
      o.luminanceFactor=o.desiredLuminanceFactor;
   end
   if ~isempty(o.desiredRetinalIlluminanceTd)
      if isempty(o.pupilDiameterMm)
         error(['When you request o.desiredRetinalIlluminanceTd, ' ...
            'you must also specify o.pupilDiameterMm or an observer with known pupil size.']);
      end
      % o.filterTransmission refers to optical neutral density filters or
      % sunglasses.
      % o.luminanceFactor refers to software attenuation of luminance from
      % the standard middle of attainable range.
      td=o.filterTransmission*LStandard*pi*o.pupilDiameterMm^2/4;
      o.luminanceFactor=o.desiredRetinalIlluminanceTd/td;
   end
   o.luminanceFactor=min([max(cal.old.L)/LStandard o.luminanceFactor]); % upper bound
   o.luminance=o.luminanceFactor*o.filterTransmission*LStandard;
   o.retinalIlluminanceTd=o.luminance*pi*o.pupilDiameterMm^2/4;
   % Need to update all reports of luminance to include effect of filter.
   
   %% OPEN OUTPUT FILES
   o.beginningTime=now;
   t=datevec(o.beginningTime);
   stack=dbstack;
   if length(stack) == 1
      o.functionNames=stack.name;
   else
      o.functionNames=[stack(2).name '-' stack(1).name];
   end
   o.dataFilename=sprintf('%s-%s.%d.%d.%d.%d.%d.%d',o.functionNames,o.observer,round(t));
   o.dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   if ~exist(o.dataFolder,'dir')
      success=mkdir(o.dataFolder);
      if ~success
         error('Failed attempt to create data folder: %s',o.dataFolder);
      end
   end
   st=dbstack('-completenames',1);
   if ~isempty(st)
      o.scriptName=st.name; % Save name of calling script.
      o.script=fileread(st.file); % Save a copy of the calling script.
   else
      o.scriptName='';
      o.script='';
   end
   dataFid=fopen(fullfile(o.dataFolder,[o.dataFilename '.txt']),'rt');
   if dataFid ~= -1
      error('Oops. There''s already a file called "%s.txt". Try again.',o.dataFilename);
   end
   [dataFid,msg]=fopen(fullfile(o.dataFolder,[o.dataFilename '.txt']),'wt');
   if dataFid == -1
      error('%s. Could not create data file: %s',msg,[o.dataFilename '.txt']);
   end
   assert(dataFid > -1);
   ff=[1 dataFid];
   fprintf('\nSaving results in two data files:\n');
   ffprintf(ff,'%s\n',o.dataFilename);
   ffprintf(ff,'%s %s\n',o.functionNames,datestr(now));
   ffprintf(ff,'observer %s, task %s, alternatives %d,  steepness %.1f,\n',o.observer,o.task,o.alternatives,o.steepness);
   
   %% STIMULUS PARAMETERS
   o.pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
   degPerCm=57/o.viewingDistanceCm;
   o.pixPerDeg=o.pixPerCm/degPerCm;
   o.textSize=round(o.textSizeDeg*o.pixPerDeg);
   o.textSizeDeg=o.textSize/o.pixPerDeg;
   o.textLineLength=floor(1.9*RectWidth(screenRect)/o.textSize);
   o.lineSpacing=1.5;
   o.stimulusRect=InsetRect(screenRect,0,o.lineSpacing*1.2*o.textSize);
   o.noiseCheckPix=round(o.noiseCheckDeg*o.pixPerDeg);
   switch o.task
      case 'identify'
         o.noiseCheckPix=min(o.noiseCheckPix,RectHeight(o.stimulusRect));
      case '4afc'
         o.noiseCheckPix=min(o.noiseCheckPix,floor(RectHeight(o.stimulusRect)/(2+o.gapFraction4afc)));
         o.noiseRadiusDeg=o.targetHeightDeg/2;
   end
   o.noiseCheckPix=max(o.noiseCheckPix,1);
   o.noiseCheckDeg=o.noiseCheckPix/o.pixPerDeg;
   if o.fullResolutionTarget
      o.targetCheckPix=1;
   else
      o.targetCheckPix=o.noiseCheckPix;
   end
   o.targetCheckDeg=o.targetCheckPix/o.pixPerDeg;
   BackupCluts(o.screen);
   LMean=(max(cal.old.L)+min(cal.old.L))/2;
   o.maxLRange=2*min(max(cal.old.L)-LMean,LMean-min(cal.old.L));
   % We use nearly the whole clut (entries 2 to 254) for stimulus generation.
   % We reserve first and last (0 and o.maxEntry), for black and white.
   firstGrayClutEntry=2;
   lastGrayClutEntry=o.clutMapLength-2;
   assert(lastGrayClutEntry<o.maxEntry);
   assert(firstGrayClutEntry>1);
   assert(mod(firstGrayClutEntry+lastGrayClutEntry,2) == 0) % Must be even, so middle is an integer.
   o.minLRange=0;
   
   %% SET SIZES OF SCREEN ELEMENTS: text, stimulusRect, etc.
   textFont='Verdana';
   if streq(o.task,'identify')
      o.showResponseNumbers=false; % Inappropriate so suppress.
      switch o.alphabetPlacement
         case 'right'
            o.stimulusRect(3)=o.stimulusRect(3)-RectHeight(screenRect)/max(6,o.alternatives);
         case 'top'
            o.stimulusRect(2)=max(o.stimulusRect(2),screenRect(2)+0.5*RectWidth(screenRect)/max(6,o.alternatives));
         otherwise
            error('Unknown alphabetPlacement "%d".\n',o.alphabetPlacement);
      end
   end
   o.stimulusRect=2*round(o.stimulusRect/2);
   if streq(o.task,'identify')
      o.targetHeightPix=2*round(0.5*o.targetHeightDeg/o.targetCheckDeg)*o.targetCheckPix; % even round multiple of check size
      if o.targetHeightPix < o.minimumTargetHeightChecks*o.targetCheckPix
         ffprintf(ff,'Increasing requested targetHeight checks from %d to %d, the minimum.\n',o.targetHeightPix/o.targetCheckPix,o.minimumTargetHeightChecks);
         o.targetHeightPix=2*ceil(0.5*o.minimumTargetHeightChecks)*o.targetCheckPix;
      end
   else
      o.targetHeightPix=round(o.targetHeightDeg/o.targetCheckDeg)*o.targetCheckPix; % round multiple of check size
   end
   switch o.task
      case 'identify'
         maxStimulusHeight=RectHeight(o.stimulusRect);
      case '4afc'
         maxStimulusHeight=RectHeight(o.stimulusRect)/(2+o.gapFraction4afc);
         maxStimulusHeight=floor(maxStimulusHeight);
      otherwise
         error('Unknown o.task "%s".',o.task);
   end
   o.targetHeightDeg=o.targetHeightPix/o.pixPerDeg;
   if o.noiseRadiusDeg > maxStimulusHeight/o.pixPerDeg
      ffprintf(ff,'Reducing requested o.noiseRadiusDeg (%.1f deg) to %.1f deg, the max possible.\n',...
         o.noiseRadiusDeg,maxStimulusHeight/o.pixPerDeg);
      o.noiseRadiusDeg=maxStimulusHeight/o.pixPerDeg;
   end
   if o.useFlankers
      flankerSpacingPix=round(o.flankerSpacingDeg*o.pixPerDeg);
   end
   % The actual clipping is done using o.stimulusRect. This restriction of
   % noiseRadius and annularNoiseBigRadius is merely to save time (and
   % excessive texture size) by not computing pixels that won't be seen.
   % The actual clipping is done using o.stimulusRect.
   o.noiseRadiusDeg=max(o.noiseRadiusDeg,0);
   o.noiseRadiusDeg=min(o.noiseRadiusDeg,RectWidth(screenRect)/o.pixPerDeg);
   o.noiseRaisedCosineEdgeThicknessDeg=max(0,o.noiseRaisedCosineEdgeThicknessDeg);
   o.noiseRaisedCosineEdgeThicknessDeg=min(o.noiseRaisedCosineEdgeThicknessDeg,2*o.noiseRadiusDeg);
   o.annularNoiseSmallRadiusDeg=max(o.noiseRadiusDeg,o.annularNoiseSmallRadiusDeg); % "noise" and annularNoise cannot overlap.
   o.annularNoiseBigRadiusDeg=max(o.annularNoiseBigRadiusDeg,o.annularNoiseSmallRadiusDeg); % Big radius is at least as big as small radius.
   o.annularNoiseBigRadiusDeg=min(o.annularNoiseBigRadiusDeg,RectWidth(screenRect)/o.pixPerDeg);
   o.annularNoiseSmallRadiusDeg=min(o.annularNoiseBigRadiusDeg,o.annularNoiseSmallRadiusDeg); % Big radius is at least as big as small radius.
   if isnan(o.blankingRadiusReTargetHeight)
      switch o.targetKind
         case 'letter'
            o.blankingRadiusReTargetHeight=1.5; % Make blanking radius 1.5 times
            %                                       % target height. That's a good
            %                                       % value for letters, which are
            %                                       % strong right up to the edge of
            %                                       % the target height.
         case 'gabor'
            o.blankingRadiusReTargetHeight=0.5; % Make blanking radius 0.5 times
            %                                       % target height. That's good for gabors,
            %                                       % which are greatly diminished
            %                                       % at their edge.
      end
   end
   fixationCrossPix=round(o.fixationCrossDeg*o.pixPerDeg);
   fixationCrossWeightPix=round(o.fixationCrossWeightDeg*o.pixPerDeg);
   fixationCrossWeightPix=max(1,fixationCrossWeightPix);
   o.fixationCrossWeightDeg=fixationCrossWeightPix/o.pixPerDeg;
   
   % The entire screen is in screenRect. The stimulus is in stimulusRect,
   % which is within screenRect. Every pixel not in stimulusRect is in one or
   % more of the caption rects, which form a border on three sides of the
   % screen. The caption rects overlap each other.
   topCaptionRect=screenRect;
   topCaptionRect(4)=o.stimulusRect(2); % top caption (trial number)
   bottomCaptionRect=screenRect;
   bottomCaptionRect(2)=o.stimulusRect(4); % bottom caption (instructions)
   rightCaptionRect=screenRect;
   rightCaptionRect(1)=o.stimulusRect(3); % right caption
   leftCaptionRect=screenRect;
   leftCaptionRect(3)=o.stimulusRect(1); % left caption
   % The caption rects are hardly used. It turns out that I typically do a
   % FillRect of screenRect with the caption background (1), and then a
   % smaller FillRect of stimulusRect with the stimulus background (128).
   textStyle=0; % plain
   
   %% PARAMETERS RELATED TO THRESHOLD
   switch o.task
      case '4afc'
         idealT64=-.90;
      case 'identify'
         idealT64=-0.30;
   end
   switch o.observer
      case algorithmicObservers
         if isempty(o.steepness) || ~isfinite(o.steepness)
            o.steepness=1.7;
         end
         if isempty(o.trialsPerRun) || ~isfinite(o.trialsPerRun)
            o.trialsPerRun=1000;
         end
         if isempty(o.runsDesired) || ~isfinite(o.runsDesired)
            o.runsDesired=10;
         end
         %         degPerCm=57/o.viewingDistanceCm;
         %         o.pixPerCm=45; % for MacBook at native resolution.
         %         o.pixPerDeg=o.pixPerCm/degPerCm;
      otherwise
         if isempty(o.steepness) || ~isfinite(o.steepness)
            switch o.targetModulates
               case 'luminance'
                  o.steepness=3.5;
               case {'noise', 'entropy'}
                  o.steepness=1.7;
            end
         end
   end
   if streq(o.task,'4afc')
      o.alternatives=1;
   end
   
   %% NUMBER OF POSSIBLE SIGNALS
   clear signal
   if o.alternatives > length(o.alphabet)
      if o.speakInstructions
         Speak('Too many o.alternatives');
      end
      error('Too many o.alternatives');
   end
   for i=1:o.alternatives
      signal(i).letter=o.alphabet(i);
   end
   
   %% REPORT CONFIGURATION
   if streq(o.observer,'brightnessSeeker')
      ffprintf(ff,'observerQuadratic %.2f\n',o.observerQuadratic);
   end
   [screenWidthMm, screenHeightMm]=Screen('DisplaySize',cal.screen);
   cal.screenWidthCm=screenWidthMm/10;
   ffprintf(ff,'Computer %s, %s, screen %d, %dx%d, %.1fx%.1f cm\n',cal.localHostName,cal.macModelName,cal.screen,RectWidth(screenRect),RectHeight(screenRect),screenWidthMm/10,screenHeightMm/10);
   assert(cal.screenWidthCm == screenWidthMm/10);
   ffprintf(ff,'Computer account %s.\n',cal.processUserLongName);
   ffprintf(ff,'%s %s calibrated by %s on %s.\n',cal.localHostName,cal.macModelName,cal.calibratedBy,cal.datestr);
   ffprintf(ff,'%s\n',cal.notes);
   ffprintf(ff,'cal.ScreenConfigureDisplayBrightnessWorks=%.0f;\n',cal.ScreenConfigureDisplayBrightnessWorks);
   if ismac && isfield(cal,'profile')
      ffprintf(ff,'cal.profile=''%s'';\n',cal.profile);
      oldProfile=ScreenProfile(cal.screen);
      if streq(oldProfile,cal.profile)
         if streq(cal.profile,'ColorMatch RGB')
            ScreenProfile(cal.screen,'Apple RGB');
         else
            ScreenProfile(cal.screen,'ColorMatch RGB');
         end
      end
      ScreenProfile(cal.screen,cal.profile);
   end
   Screen('Preference','SkipSyncTests',1);
   oldVisualDebugLevel=Screen('Preference','VisualDebugLevel',0);
   oldSupressAllWarnings=Screen('Preference','SuppressAllWarnings',1);
   %    if window~=0
   %       Screen('Close',window); % Close temporary window
   %    end
   
   %% OPEN WINDOW IF OBSERVER IS HUMAN
   % We can safely use this no-echo mode AND collect keyboard responses
   % without worrying about writing to MATLAB console/editor.
   ListenChar(2); % no echo
   KbName('UnifyKeyNames');
   if ~ismember(o.observer,algorithmicObservers) || streq(o.task,'identify')
      % If o.observer is human, we need an open window for the whole
      % experiment, in which to display stimuli. If o.observer is machine,
      % we need a screen only briefly, to create the targets to be
      % identified.
      % openwindow was here
      if false
         % This code to enable dithering is what Mario suggested, but it
         % makes no difference at all. I get dithering on my MacBook Pro
         % and iMac if and only if I EnableNative10BitFramebuffer, above. I
         % haven't tested whether this dithering-control code affects my
         % MacBook Air, but that's irrelevant since its screen is too
         % viewing-angle dependent for use in measuring threshold, which is
         % why I need dithering.
         windowInfo=Screen('GetWindowInfo',window);
         o.displayCoreId=windowInfo.DisplayCoreId;
         switch(o.displayCoreId)
            case 'AMD'
               o.displayEngineVersion=windowInfo.GPUMinorType/10;
               switch(round(o.displayEngineVersion))
                  case 6
                     o.displayGPUFamily='Southern Islands';
                     % Examples:
                     % AMD Radeon R9 M290X in MacBook Pro (Retina, 15-inch, Mid 2015)
                     % AMD Radeon R9 M370X in iMac (Retina 5K, 27-inch, Late 2014)
                     o.ditherCLUT=61696;
                  case 8
                     o.displayGPUFamily='Sea Islands';
                     % Used in hp Z Book laptop.
                     o.ditherCLUT=59648; % Untested.
                     % MARIO: Another number you could try is 59648. This
                     % would enable dithering for a native 8 bit panel, which
                     % is the wrong thing to do for the laptops 10 bit panel,
                     % assuming the driver docs are correct. But then, who
                     % knows?
               end
         end
         Screen('ConfigureDisplay','Dithering',cal.screen,o.ditherCLUT);
      end % if false
      
      % Recommended by Mario Kleiner, July 2017.
      % The first 'DrawText' call triggers loading of the plugin, but may fail.
      Screen('DrawText',window,' ',0,0,0,1,1);
      o.drawTextPlugin=Screen('Preference','TextRenderer')>0;
      if ~o.drawTextPlugin
         warning('The DrawText plugin failed to load. See warning above.');
      end
      ffprintf(ff,'o.drawTextPlugin %s %% Need true for accurate text rendering.\n',mat2str(o.drawTextPlugin));
      
      % Recommended by Mario Kleiner, July 2017.
      winfo=Screen('GetWindowInfo', window);
      o.beamPositionQueriesAvailable= winfo.Beamposition ~= -1 && winfo.VBLEndline ~= -1;
      ffprintf(ff,'o.beamPositionQueries %s %% true for best timing.\n',mat2str(o.beamPositionQueriesAvailable));
      if ismac
         % Rec by microfish@fishmonkey.com.au, July 22, 2017
         o.psychtoolboxKernelDriverLoaded=~system('kextstat -l -k | grep PsychtoolboxKernelDriver > /dev/null');
         ffprintf(ff,'o.psychtoolboxKernelDriverLoaded %s %% true for best timing.\n',mat2str(o.psychtoolboxKernelDriverLoaded));
      else
         o.psychtoolboxKernelDriverLoaded=false;
      end
      
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
         LMean=mean([LMin, LMax]); % Desired background luminance.
         %          LMean=LMean*(1+(rand-0.5)/32); % Tiny jitter, ±1.5%
         LMean=o.luminanceFactor*LMean;
         if o.assessLowLuminance
            LMean=0.8*LMin+0.2*LMax;
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
         cal.LFirst=LMean;
         cal.LLast=LMean;
         cal.nFirst=o.gray1*o.maxEntry;
         cal.nLast=o.gray1*o.maxEntry;
         cal=LinearizeClut(cal);
         
         % CLUT entries for stimulus.
         
         cal.LFirst=LMin;
         cal.LLast=LMean+(LMean-LMin); % Symmetric about LMean.
         cal.nFirst=firstGrayClutEntry;
         cal.nLast=lastGrayClutEntry;
         cal=LinearizeClut(cal);
         ffprintf(ff,'Size of cal.gamma %d %d\n',size(cal.gamma));
         
         %          ffprintf(ff,'Non-stimulus background is %.1f cd/m^2 at CLUT entry %d (and %d).\n',LMean,o.gray1*o.maxEntry,gray*o.maxEntry);
         %          ffprintf(ff,'%.1f cd/m^2 at %d\n',LuminanceOfIndex(cal,gray*o.maxEntry),o.gray1*o.maxEntry);
         %          ffprintf(ff,'%.3f dac at %d; %.3f dac at %d\n',cal.gamma(o.gray1*o.maxEntry+1,2),o.gray1*o.maxEntry,cal.gamma(gray*o.maxEntry+1,2),gray*o.maxEntry);
         
         Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
         if o.assessLoadGamma
            ffprintf(ff,'Line %d: o.contrast %.3f, LoadNormalizedGammaTable 0.5*range/mean=%.3f\n', ...
               MFileLineNr,o.contrast,(cal.LLast-cal.LFirst)/(cal.LLast+cal.LFirst));
         end
         Screen('FillRect',window,o.gray1);
         Screen('FillRect',window,gray,o.stimulusRect);
      else
         Screen('FillRect',window);
      end % if exist('cal')
      Screen('Flip',window); % Load gamma table
      if ~isfinite(window) || window == 0
         fprintf('error\n');
         error('Screen OpenWindow failed. Please try again.');
      end
      black=0; % The CLUT color code for black.
      white=1; % The CLUT color code for white.
      gray=mean([firstGrayClutEntry lastGrayClutEntry])/o.maxEntry; % Will be a CLUT color code for gray.
      Screen('FillRect',window,o.gray1);
      Screen('FillRect',window,gray,o.stimulusRect);
      Screen('Flip',window); % Screen is now all gray, at LMean.
   else
      window=-1;
   end
   if window >= 0
      screenRect=Screen('Rect',window,1);
      screenWidthPix=RectWidth(screenRect);
   else
      screenWidthPix=1280;
   end
   o.pixPerCm=screenWidthPix/cal.screenWidthCm;
   degPerCm=57/o.viewingDistanceCm;
   o.pixPerDeg=o.pixPerCm/degPerCm;
   
   %% CONFIRM OLD ANSWERS IF STALE OR OBSERVER CHANGED
   if ~isempty(oOld) && (GetSecs-oOld.secs>10*60 || ~streq(oOld.observer,o.observer))
      Screen('Preference','TextAntiAliasing',1);
      Screen('TextSize',window,o.textSize);
      Screen('TextFont',window,'Verdana');
      Screen('FillRect',window,o.gray1);
      string=sprintf('Confirming: Experimenter %s and observer %s.',o.experimenter,o.observer);
      if o.useFilter
         string=sprintf('%s With filter transmission %.3f.',string,o.filterTransmission);
      end
      string=sprintf('%s Right?\nHit RETURN to continue, or ESCAPE to quit.',string);
      Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
      DrawFormattedText(window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
      Screen('Flip',window); % Display request.
      if o.speakInstructions
         Speak(sprintf('Observer %s, right? If ok, hit RETURN to continue, otherwise hit ESCAPE to quit.',o.observer));
      end
      fprintf('*Confirming observer name.\n');
      response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode]);
      if ismember(response,[escapeChar,graveAccentChar])
         if o.speakInstructions
            Speak('Quitting.');
         end
         o.quitRun=true;
         o.quitSession=true;
         sca;
         ListenChar;
         return
      end
   end
   
   %% MONOCULAR?
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
         DrawFormattedText(window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
         Screen('Flip',window); % Display request.
         if o.speakInstructions
            Speak('Please use both eyes. Hit RETURN to continue, or ESCAPE to quit.');
         end
         fprintf('*Asking which eye(s).\n');
         response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode]);
         if ismember(response,[escapeChar,graveAccentChar])
            if o.speakInstructions
               Speak('Quitting.');
            end
            o.quitRun=true;
            o.quitSession=true;
            sca;
            ListenChar;
            return
         end
      end
      if ismember(o.eyes,{'left','right'})
         Screen('Preference','TextAntiAliasing',1);
         string=sprintf('Please use just your %s eye. Cover your other eye.\nHit RETURN to continue, or ESCAPE to quit.',o.eyes);
         Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
         DrawFormattedText(window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
         Screen('Flip',window); % Display request.
         if o.speakInstructions
            string=sprintf('Please use just your %s eye. Cover your other eye. Hit RETURN to continue, or ESCAPE to quit.',o.eyes);
            Speak(string);
         end
         fprintf('*Telling observer which eye(s) to use.\n');
         response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode]);
         if ismember(response,[escapeChar,graveAccentChar])
            if o.speakInstructions
               Speak('Quitting.');
            end
            o.quitRun=true;
            o.quitSession=true;
            sca;
            ListenChar;
            return
         end
      end
      string='';
      while streq(o.eyes,'one')
         Screen('Preference','TextAntiAliasing',1);
         string=[string 'Which eye will you use, left or right? Please type L or R:'];
         Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
         DrawFormattedText(window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
         Screen('Flip',window); % Display request.
         if o.speakInstructions
            Speak(string);
         end
         fprintf('*Asking observer which eye(s).\n');
         response=GetKeypress([KbName('L') KbName('R') escapeKeyCode graveAccentKeyCode]);
         if ismember(response,[escapeChar,graveAccentChar])
            if o.speakInstructions
               Speak('Quitting.');
            end
            o.quitRun=true;
            o.quitSession=true;
            sca;
            ListenChar;
            return
         end
         response=upper(response);
         switch(response)
            case 'L'
               o.eyes='left';
            case 'R'
               o.eyes='right';
            otherwise
               string=sprintf('Illegal response ''%s''. ',response);
         end
      end
      Screen('FillRect',window,o.gray1);
      Screen('Flip',window); % Blank to acknowledge response.
   end
   if streq(o.eyes,'both')
      ffprintf(ff,'Observer is using %s eyes.\n',o.eyes);
   else
      ffprintf(ff,'Observer is using %s eye.\n',o.eyes);
   end
   
   %% PLACE FIXATION AND NEAR-POINT OF DISPLAY
   % DISPLAY NEAR POINT
   % VIEWING GEOMETRY
   % o.nearPointXYInUnitSquare % rough location in o.stimulusRect re lower-left corner.
   % o.nearPointXYPix % near point screen coordinate.
   % o.viewingDistanceCm % Distance from eye to near point.
   % o.nearPointXYDeg % (x,y) eccentricity of near point.
   % 1. assign target ecc. to displayNearPoint
   % 2. pick a good (x,y) on the screen for the displayNearPoint.
   % 3. ask viewer to adjust display to adjust display distance so (x,y) is at desired viewing distance and orthogonal to line of sight from eye to (x,y).
   % 4. If using off-screen fixation, put it at same distance from eye, and compute its position, left or right of (x,y) to put (x,y) at desired ecc.
   
   % PLACE TARGET AT NEAR POINT
   o.nearPointXYDeg=o.eccentricityXYDeg;
   
   fprintf('*Waiting for observer to set viewing distance.\n');
   o=SetUpNearPoint(window,o);
   if o.quitSession
      return
   end
   
   o=SetUpFixation(window,o,ff);
   if o.quitSession
      return
   end
   
   gap=o.gapFraction4afc*o.targetHeightPix;
   
   %% SET NOISE PARAMETERS
   o.targetWidthPix=o.targetHeightPix;
   o.targetHeightPix=o.targetCheckPix*round(o.targetHeightPix/o.targetCheckPix);
   o.targetWidthPix=o.targetCheckPix*round(o.targetWidthPix/o.targetCheckPix);
   
   MAX_FRAMES=100; % Better to limit than crash the GPU.
   if window ~= -1
      frameRate=1/Screen('GetFlipInterval',window);
   else
      frameRate=60;
   end
   ffprintf(ff,'Frame rate %.1f Hz.\n',frameRate);
   o.targetDurationSec=max(1,round(o.targetDurationSec*frameRate))/frameRate;
   if o.useDynamicNoiseMovie
      o.checkSec=1/frameRate;
   else
      o.checkSec=o.targetDurationSec;
   end
   if ~o.useDynamicNoiseMovie
      o.moviePreFrames=0;
      o.movieSignalFrames=1;
      o.moviePostFrames=0;
   else
      o.moviePreFrames=round(o.moviePreSec*frameRate);
      o.movieSignalFrames=round(o.targetDurationSec*frameRate);
      if o.movieSignalFrames < 1
         o.movieSignalFrames=1;
      end
      o.moviePostFrames=round(o.moviePostSec*frameRate);
      if o.moviePreFrames+o.moviePostFrames>=MAX_FRAMES
         error('o.moviePreSec+o.moviePostSec=%.1f s too long for movie with MAX_FRAMES %d.\n',...
            o.moviePreSec+o.moviePostSec,MAX_FRAMES);
      end
   end
   o.movieFrames=o.moviePreFrames+o.movieSignalFrames+o.moviePostFrames;
   if o.movieFrames>MAX_FRAMES
      o.movieFrames=MAX_FRAMES;
      o.movieSignalFrames=o.movieFrames-o.moviePreFrames-o.moviePostFrames;
      o.targetDurationSec=o.movieSignalFrames/frameRate;
      ffprintf(ff,'Constrained by MAX_FRAMES %d, reducing duration to %.3f s\n',MAX_FRAMES,o.targetDurationSec);
   end
   
   ffprintf(ff,'o.pixPerDeg %.1f, o.viewingDistanceCm %.1f\n',o.pixPerDeg,o.viewingDistanceCm);
   if streq(o.task,'identify')
      ffprintf(ff,'Minimum letter resolution is %.0f checks.\n',o.minimumTargetHeightChecks);
   end
   switch o.targetKind
      case 'letter'
         ffprintf(ff,'o.font %s\n',o.font);
      case 'gabor'
         ffprintf(ff,'o.targetGaborSpaceConstantCycles %.1f\n',o.targetGaborSpaceConstantCycles);
         ffprintf(ff,'o.targetGaborCycles %.1f\n',o.targetGaborCycles);
         ffprintf(ff,'o.targetGaborOrientationsDeg [');
         ffprintf(ff,' %.0f',o.targetGaborOrientationsDeg);
         ffprintf(ff,']\n');
   end
   ffprintf(ff,'o.targetHeightPix %.0f, o.targetCheckPix %.0f, o.noiseCheckPix %.0f, o.targetDurationSec %.2f s\n',o.targetHeightPix,o.targetCheckPix,o.noiseCheckPix,o.targetDurationSec);
   ffprintf(ff,'o.targetModulates %s\n',o.targetModulates);
   ffprintf(ff,'o.thresholdParameter %s\n',o.thresholdParameter);
   if streq(o.targetModulates,'entropy')
      o.noiseType='uniform';
      ffprintf(ff,'o.backgroundEntropyLevels %d\n',o.backgroundEntropyLevels);
   end
   ffprintf(ff,'o.noiseType %s, o.noiseSD %.3f',o.noiseType,o.noiseSD);
   if isfinite(o.annularNoiseSD)
      ffprintf(ff,', o.annularNoiseSD %.3f',o.annularNoiseSD);
   end
   if o.noiseFrozenInTrial
      ffprintf(ff,', frozenInTrial');
   end
   if o.noiseFrozenInRun
      ffprintf(ff,', frozenInRun');
   end
   ffprintf(ff,'\n');
   o.noiseSize=2*o.noiseRadiusDeg*[1, 1]*o.pixPerDeg/o.noiseCheckPix;
   switch o.task
      case 'identify'
         o.noiseSize=2*round(o.noiseSize/2); % Even numbers, so we can center it on letter.
      case '4afc'
         o.noiseSize=round(o.noiseSize);
   end
   o.noiseRadiusDeg=0.5*o.noiseSize(1)*o.noiseCheckPix/o.pixPerDeg;
   noiseBorder=ceil(0.5*o.noiseRaisedCosineEdgeThicknessDeg*o.pixPerDeg/o.noiseCheckPix);
   o.noiseSize=o.noiseSize+2*noiseBorder;
   o.annularNoiseSmallSize=2*o.annularNoiseSmallRadiusDeg*[1, 1]*o.pixPerDeg/o.noiseCheckPix;
   o.annularNoiseSmallSize(2)=min(o.annularNoiseSmallSize(2),RectHeight(o.stimulusRect)/o.noiseCheckPix);
   o.annularNoiseSmallSize=2*round(o.annularNoiseSmallSize/2); % An even number, so we can center it on center of letter.
   o.annularNoiseSmallRadiusDeg=0.5*o.annularNoiseSmallSize(1)/(o.pixPerDeg/o.noiseCheckPix);
   o.annularNoiseBigSize=2*o.annularNoiseBigRadiusDeg*[1, 1]*o.pixPerDeg/o.noiseCheckPix;
   o.annularNoiseBigSize(2)=min(o.annularNoiseBigSize(2),RectHeight(o.stimulusRect)/o.noiseCheckPix);
   o.annularNoiseBigSize=2*round(o.annularNoiseBigSize/2); % An even number, so we can center it on center of letter.
   o.annularNoiseBigRadiusDeg=0.5*o.annularNoiseBigSize(1)/(o.pixPerDeg/o.noiseCheckPix);
   
   % Make o.canvasSize just big enough to hold everything we're showing,
   % including signal, flankers, and noise. We limit o.canvasSize to fit in
   % o.stimulusRect.
   o.canvasSize=[o.targetHeightPix o.targetWidthPix]/o.targetCheckPix;
   o.canvasSize=2*o.canvasSize; % Denis. For extended noise background.
   if o.useFlankers
      o.canvasSize=o.canvasSize+[2 2]*flankerSpacingPix/o.targetCheckPix;
   end
   o.canvasSize=max(o.canvasSize,o.noiseSize*o.noiseCheckPix/o.targetCheckPix);
   if o.annularNoiseBigRadiusDeg > o.annularNoiseSmallRadiusDeg
      o.canvasSize=max(o.canvasSize,2*o.annularNoiseBigRadiusDeg*[1, 1]*o.pixPerDeg/o.noiseCheckPix);
   end
   switch o.task
      case 'identify'
         o.canvasSize=min(o.canvasSize,floor(RectHeight(o.stimulusRect)/o.targetCheckPix));
         o.canvasSize=2*round(o.canvasSize/2); % Even number of checks, so we can center it on letter.
      case '4afc'
         o.canvasSize=min(o.canvasSize,floor(maxStimulusHeight/o.targetCheckPix));
         o.canvasSize=round(o.canvasSize);
   end
   o.canvasSize=(o.noiseCheckPix/o.targetCheckPix)*round(o.canvasSize*o.targetCheckPix/o.noiseCheckPix); % Make it a multiple of noiseCheckPix.
   ffprintf(ff,'Noise height %.2f deg. Noise hole %.2f deg. Height is %.2fT and hole is %.2fT, where T is target height.\n', ...
      o.annularNoiseBigRadiusDeg*o.targetHeightDeg,o.annularNoiseSmallRadiusDeg*o.targetHeightDeg,o.annularNoiseBigRadiusDeg,o.annularNoiseSmallRadiusDeg);
   if o.assessLowLuminance
      ffprintf(ff,'o.assessLowLuminance %d %% check out DAC limits at low end.\n',o.assessLowLuminance);
   end
   if o.useFlankers
      ffprintf(ff,'Adding four flankers at center spacing of %.0f pix=%.1f deg=%.1fx letter height. Dark contrast %.3f (nan means same as target).\n',...
         flankerSpacingPix,flankerSpacingPix/o.pixPerDeg,flankerSpacingPix/o.targetHeightPix,o.flankerContrast);
   end
   if o.useFixation
      fix.markTargetLocation= o.markTargetLocation;
      fixationXYPix=round(XYPixOfXYDeg(o,[0 0])); % location of fixation
      fix.xy=fixationXYPix;            %  location of fixation on screen.
      fix.eccentricityXYPix=o.targetXYPix-fixationXYPix;  % xy offset of target from fixation.
      fix.clipRect=o.stimulusRect;
      fix.fixationCrossPix=fixationCrossPix;% Width & height of fixation cross.
      fix.targetMarkPix=o.targetMarkDeg*o.pixPerDeg;
      fix.blankingRadiusReEccentricity=o.blankingRadiusReEccentricity;
      fix.blankingRadiusReTargetHeight=o.blankingRadiusReTargetHeight;
      fix.targetHeightPix=o.targetHeightPix;
      [fixationLines,o.markTargetLocation]=ComputeFixationLines2(fix);
   end
   if window ~= -1 && ~isempty(fixationLines)
      Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,black); % fixation
   end
   clear tSample
   
   % Compute noiseList
   switch o.noiseType % Fill noiseList with desired kind of noise.
      case 'gaussian'
         o.noiseListBound=2;
         temp=randn([1 20000]);
         ok=temp.^2<o.noiseListBound^2;
         noiseList=temp(ok);
         clear temp;
      case 'uniform'
         o.noiseListBound=1;
         noiseList=-1:1/1024:1;
      case 'binary'
         o.noiseListBound=1;
         noiseList=[-1 1];
      otherwise
         error('Unknown noiseType "%s"',o.noiseType);
   end
   
   % Compute MTF to filter the noise.
   fNyquist=0.5/o.noiseCheckDeg;
   fLow=0;
   fHigh=fNyquist;
   switch o.noiseSpectrum
      case 'pink'
         o.noiseSpectrumExponent=-1;
         if all(o.noiseSize > 0)
            mtf=MtfPowerLaw(o.noiseSize,o.noiseSpectrumExponent,fLow/fNyquist,fHigh/fNyquist);
         else
            mtf=[];
         end
         o.noiseIsFiltered=true;
      case 'white'
         mtf=ones(o.noiseSize);
         o.noiseIsFiltered=false;
   end
   if o.noiseSD == 0
      mtf=0;
   end
   
   o.noiseListSd=std(noiseList);
   a=0.9*o.noiseListSd/o.noiseListBound;
   if o.noiseSD > a
      ffprintf(ff,'WARNING: Requested o.noiseSD %.2f too high. Reduced to %.2f\n',o.noiseSD,a);
      o.noiseSD=a;
   end
   if isfinite(o.annularNoiseSD) && o.annularNoiseSD > a
      ffprintf(ff,'WARNING: Requested o.annularNoiseSD %.2f too high. Reduced to %.2f\n',o.annularNoiseSD,a);
      o.annularNoiseSD=a;
   end
   % END OF NOISE COMPUTATION
   
   %% PREPARE SOUNDS
   rightBeep=MakeBeep(2000,0.05);
   rightBeep(end)=0;
   wrongBeep=MakeBeep(500,0.5);
   wrongBeep(end)=0;
   temp=zeros(size(wrongBeep));
   temp(1:length(rightBeep))=rightBeep;
   rightBeep=temp; % extend rightBeep with silence to same length as wrongBeep
   purr=MakeBeep(200,0.6);
   purr(end)=0;
   Snd('Open');
   
   %% PREPARE TARGET IMAGE
   switch o.task
      case '4afc'
         object='Square';
      case 'identify'
         object='Letter';
      otherwise
         error('Unknown task %d',o.task);
   end
   checks=o.targetHeightPix/o.noiseCheckPix;
   ffprintf(ff,'Target height %.1f deg is %.1 targetChecks or %.1f noiseChecks.\n',...
      o.targetHeightDeg,o.targetHeightPix/o.targetCheckPix,o.targetHeightPix/o.noiseCheckPix);
   ffprintf(ff,'%s size %.1f deg, targetCheck %.3f deg, noiseCheck %.3f deg.\n',...
      object,o.targetHeightDeg,o.targetCheckDeg,o.noiseCheckDeg);
   if streq(object,'Letter')
      ffprintf(ff,'Nominal letter size is %.2f deg. See o.alphabetHeightDeg below for actual size. \n',o.targetHeightDeg);
   end
   if streq(o.task,'4afc')
      ffprintf(ff,'o.gapFraction4afc %.2f, gap %.2f deg\n',o.gapFraction4afc,gap/o.pixPerDeg);
   end
   if o.showCropMarks
      ffprintf(ff,'Showing crop marks.\n');
   else
      ffprintf(ff,'No crop marks.\n');
   end
   if streq(o.task,'4afc')
      if o.showResponseNumbers
         ffprintf(ff,'Showing response numbers.\n');
      else
         ffprintf(ff,'No response numbers. Assuming o.observer already knows them.\n');
      end
   end
   fixationXYPix=(o.targetXYPix-o.stimulusRect(1:2))./[RectWidth(o.stimulusRect) RectHeight(o.stimulusRect)];
   fixationXYPix(2)=1-fixationXYPix(2);
   string=sprintf('Target is at (%.1f %.1f) deg, (%.2f %.2f) in unit square. ',...
      o.eccentricityXYDeg,fixationXYPix);
   if o.useFixation
      if o.fixationIsOffscreen
         string=[string 'Using off-screen fixation mark.'];
      else
         string=[string 'Using on-screen fixation mark.'];
      end
   else
      string=[string 'No fixation.'];
   end
   ffprintf(ff,'%s\n',string);
   o.N=o.noiseCheckPix^2*o.pixPerDeg^-2*o.noiseSD^2;
   o.NUnits='deg^2';
   temporal='Static';
   if o.useDynamicNoiseMovie
      o.N=o.N*o.checkSec;
      o.NUnits='s deg^2';
      temporal='Dynamic';
   end
   ffprintf(ff,'%s noise power spectral density N %s log=%.2f\n', ...
      temporal,o.NUnits,log10(o.N));
   ffprintf(ff,'pThreshold %.2f, steepness %.1f\n',o.pThreshold,o.steepness);
   ffprintf(ff,'o.trialsPerRun %.0f\n',o.trialsPerRun);
   
   %% COMPUTE signal(i).image FOR ALL i.
   white1=1;
   black0=0;
   Screen('Preference','TextAntiAliasing',0);
   switch o.task % Compute masks and envelopes
      case '4afc'
         % boundsRect contains all 4 positions.
         boundsRect=[-o.targetWidthPix, -o.targetHeightPix, o.targetWidthPix+gap, o.targetHeightPix+gap];
         boundsRect=CenterRect(boundsRect,[o.targetXYPix o.targetXYPix]);
         targetRect=round([0 0 o.targetHeightPix o.targetHeightPix]/o.targetCheckPix);
         signal(1).image=ones(targetRect(3:4));
      case 'identify'
         switch o.targetKind
            case 'letter'
               scratchHeight=round(3*o.targetHeightPix/o.targetCheckPix);
               [scratchWindow, scratchRect]=Screen('OpenOffscreenWindow',-1,[],[0 0 scratchHeight scratchHeight],8);
               if ~streq(o.font,'Sloan') && ~o.allowAnyFont
                  warning('You should set o.allowAnyFont=1 unless o.font=''Sloan''.');
               end
               oldFont=Screen('TextFont',scratchWindow,o.font);
               Screen('DrawText',scratchWindow,o.alternatives(1),0,scratchRect(4)); % Must draw first to learn actual font used.
               font=Screen('TextFont',scratchWindow);
               if ~streq(font,o.font)
                  error('Font missing! Requested font "%s", but got "%s". Please install the missing font.\n',o.font,font);
               end
               oldSize=Screen('TextSize',scratchWindow,round(o.targetHeightPix/o.targetCheckPix));
               oldStyle=Screen('TextStyle',scratchWindow,0);
               canvasRect=[0 0 o.canvasSize]; % o.canvasSize =[width height];
               if o.allowAnyFont
                  clear letters
                  for i=1:o.alternatives
                     letters{i}=signal(i).letter;
                  end
                  o.targetRectLocal=TextCenteredBounds(scratchWindow,letters,1);
               else
                  o.targetRectLocal=round([0 0 o.targetHeightPix o.targetHeightPix]/o.targetCheckPix);
               end
               r=TextBounds(scratchWindow,'x',1);
               o.xHeightPix=RectHeight(r)*o.targetCheckPix;
               o.xHeightDeg=o.xHeightPix/o.pixPerDeg;
               r=TextBounds(scratchWindow,'H',1);
               o.HHeightPix=RectHeight(r)*o.targetCheckPix;
               o.HHeightDeg=o.HHeightPix/o.pixPerDeg;
               ffprintf(ff,'o.xHeightDeg %.2f deg (traditional typographer''s x-height)\n',o.xHeightDeg);
               ffprintf(ff,'o.HHeightDeg %.2f deg (capital H ascender height)\n',o.HHeightDeg);
               alphabetHeightPix=RectHeight(o.targetRectLocal)*o.targetCheckPix;
               o.alphabetHeightDeg=alphabetHeightPix/o.pixPerDeg;
               ffprintf(ff,'o.alphabetHeightDeg %.2f deg (bounding box for letters used, including any ascenders and descenders)\n',o.alphabetHeightDeg);
               if o.printTargetBounds
                  fprintf('o.targetRectLocal [%d %d %d %d]\n',o.targetRectLocal);
               end
               for i=1:o.alternatives
                  Screen('FillRect',scratchWindow,white1);
                  rect=CenterRect(canvasRect,scratchRect);
                  targetRect=CenterRect(o.targetRectLocal,rect);
                  if ~o.allowAnyFont
                     % Draw position is left at baseline
                     % targetRect is just big enough to hold any Sloan letter.
                     % targetRect=round([0 0 1 1]*o.targetHeightPix/o.targetCheckPix),
                     x=targetRect(1);
                     y=targetRect(4);
                  else
                     % Desired draw position is horizontal middle at baseline.
                     % targetRect is just big enough to hold any letter.
                     % targetRect allows for descenders and extension in any
                     % direction.
                     % targetRect=round([a b c d]*o.targetHeightPix/o.targetCheckPix),
                     % where a b c and d depend on the font.
                     x=(targetRect(1)+targetRect(3))/2; % horizontal middle
                     y=targetRect(4)-o.targetRectLocal(4); % baseline
                     % DrawText draws from left, so shift left by half letter width, to center letter at desired draw
                     % position.
                     bounds=Screen('TextBounds',scratchWindow,signal(i).letter,x,y,1);
                     if o.printTargetBounds
                        fprintf('%c bounds [%4.0f %4.0f %4.0f %4.0f]\n',signal(i).letter,bounds);
                     end
                     width=bounds(3);
                     x=x-width/2;
                  end
                  if o.printTargetBounds
                     fprintf('%c %4.0f, %4.0f\n',signal(i).letter,x,y);
                  end
                  Screen('DrawText',scratchWindow,signal(i).letter,x,y,black0,white1,1);
                  Screen('DrawingFinished',scratchWindow,[],1); % Might make GetImage more reliable. Suggested by Mario Kleiner.
%                   WaitSecs(0.1); % Might make GetImage more reliable. Suggested by Mario Kleiner.
                  letter=Screen('GetImage',scratchWindow,targetRect,'drawBuffer');
                  
                  % The scrambling sounds like something is going wrong in detiling of read
                  % back renderbuffer memory, maybe a race condition in the driver. Maybe
                  % something else, in any case not really fixable by us, although the "wait
                  % a bit and hope for the best" approach would the the most likely of all
                  % awful approaches to work around it. Maybe add a Screen('DrawingFinished',
                  % window, [], 1); before the 'getimage' and/or before the random wait.
                  %
                  % You could test a different machine, in case only one type of graphics
                  % card or vendor has the driver bug.
                  %
                  % Or you could completely switch to the software renderer via
                  % Screen('preference','Conservevram', 64). That would shutdown all hardware
                  % acceleration and render very slowly on the cpu in main memory. However,
                  % that renderer can't handle fullscreen windows afaik, and timing will also
                  % be screwed. And there might be various other limitations or bugs,
                  % including failure to work at all. If you! can live with that, worth a
                  % try. If you run into trouble don't bother even reporting it. I'm
                  % absolutely not interested.
                  %
                  % -mario (psychtoolbox forum december 13, 2015)
                  
                  Screen('FillRect',scratchWindow);
                  letter=letter(:,:,1);
                  signal(i).image=letter < (white1+black0)/2;
                  % We have now drawn letter(i) into signal(i).image. The target
                  % size is always given by o.targetRectLocal. This is a square
                  % [0 0 1 1]*o.targetHeightPix/o.targetCheckPix only if
                  % o.allowAnyFont=false. In general, it need not be square. Any code
                  % that needs a bounding rect for the target should use
                  % o.targetRectLocal, not o.targetHeightPix. In the letter
                  % generation, targetHeightPix is used solely to set the nominal
                  % font size ("points"), in pixels.
               end
               %             Screen('TextFont',scratchWindow,oldFont);
               %             Screen('TextSize',scratchWindow,oldSize);
               %             Screen('TextStyle',scratchWindow,oldStyle);
               Screen('Close',scratchWindow);
               scratchWindow=-1;
            case 'gabor'
               % o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
               % o.targetGaborSpaceConstantCycles=1.5; % The 1/e space constant of the gaussian envelope in periods of the sinewave.
               % o.targetGaborCycles=3; % cycles of the sinewave.
               % o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
               % o.targetGaborNames='VH';
               targetRect=round([0 0 o.targetHeightPix o.targetHeightPix]/o.targetCheckPix);
               o.targetRectLocal=targetRect;
               widthChecks=RectWidth(targetRect)-1;
               axisValues=-widthChecks/2:widthChecks/2; % axisValues is used in creating the meshgrid.
               [x, y]=meshgrid(axisValues,axisValues);
               spaceConstantChecks=o.targetGaborSpaceConstantCycles*(o.targetHeightPix/o.targetCheckPix)/o.targetGaborCycles;
               cyclesPerCheck=o.targetGaborCycles/(o.targetHeightPix/o.targetCheckPix);
               for i=1:o.alternatives
                  a=cos(o.targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                  b=sin(o.targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                  signal(i).image=sin(a*x+b*y+o.targetGaborPhaseDeg*pi/180).*exp(-(x.^2+y.^2)/spaceConstantChecks^2);
               end
            otherwise
               error('Unknown o.targetKind');
         end
         if o.printCrossCorrelation
            ffprintf(ff,'Cross-correlation of the letters.\n');
            for i=1:o.alternatives
               clear corr
               for j=1:i
                  cii=sum(signal(i).image(:).*signal(i).image(:));
                  cjj=sum(signal(j).image(:).*signal(j).image(:));
                  cij=sum(signal(i).image(:).*signal(j).image(:));
                  corr(j)=cij/sqrt(cjj*cii);
               end
               ffprintf(ff,'%c: ',o.alphabet(i));
               ffprintf(ff,'%4.2f ',corr);
               ffprintf(ff,'\n');
            end
            ffprintf(ff,'    ');
            ffprintf(ff,'%c    ',o.alphabet(1:o.alternatives));
            ffprintf(ff,'\n');
         end
         if o.allowAnyFont
            targetRect=CenterRect(o.targetRectLocal,o.stimulusRect);
         else
            targetRect=[0, 0, o.targetWidthPix, o.targetHeightPix];
            targetRect=CenterRect(targetRect,o.stimulusRect);
         end
         boundsRect=CenterRect(targetRect,[o.targetXYPix o.targetXYPix]);
         % targetRect not used. boundsRect used solely for the snapshot.
   end % switch o.task
   Screen('Preference','TextAntiAliasing',1);
   
   % Compute hard-edged annular noise mask
   annularNoiseMask=zeros(o.canvasSize); % initialize with 0
   rect=RectOfMatrix(annularNoiseMask);
   r=[0 0 o.annularNoiseBigSize(1) o.annularNoiseBigSize(2)];
   r=round(CenterRect(r,rect));
   annularNoiseMask=FillRectInMatrix(1,r,annularNoiseMask); % fill big radius with 1
   r=[0 0 o.annularNoiseSmallSize(1) o.annularNoiseSmallSize(2)];
   r=round(CenterRect(r,rect));
   annularNoiseMask=FillRectInMatrix(0,r,annularNoiseMask); % fill small radius with 0
   annularNoiseMask=logical(annularNoiseMask);
   
   % Compute hard-edged central noise mask
   centralNoiseMask=zeros(o.canvasSize); % initialize with 0
   rect=RectOfMatrix(centralNoiseMask);
   r=CenterRect([0 0 o.noiseSize]*o.noiseCheckPix/o.targetCheckPix,rect);
   r=round(r);
   centralNoiseMask=FillRectInMatrix(1,r,centralNoiseMask); % fill radius with 1
   centralNoiseMask=logical(centralNoiseMask);
   
   if isfinite(o.noiseEnvelopeSpaceConstantDeg) && o.noiseRaisedCosineEdgeThicknessDeg > 0
      error('Sorry. Please set o.noiseEnvelopeSpaceConstantDeg=inf or set o.noiseRaisedCosineEdgeThicknessDeg=0.');
   end
   
   if isfinite(o.noiseEnvelopeSpaceConstantDeg)
      % Compute Gaussian noise envelope, which will be central or annular,
      % depending on whether o.annularNoiseEnvelopeRadiusDeg is zero or
      % greater than zero.
      [x,y]=meshgrid(1:o.canvasSize(1),1:o.canvasSize(2));
      x=x-mean(x(:));
      y=y-mean(y(:));
      radius=sqrt(x.^2+y.^2);
      sigma=o.noiseEnvelopeSpaceConstantDeg*o.pixPerDeg/o.targetCheckPix;
      assert(isfinite(o.annularNoiseEnvelopeRadiusDeg));
      assert(o.annularNoiseEnvelopeRadiusDeg >= 0);
      if o.annularNoiseEnvelopeRadiusDeg > 0
         noiseEnvelopeRadiusPix=o.annularNoiseEnvelopeRadiusDeg*o.pixPerDeg/o.targetCheckPix;
         distance=abs(radius-noiseEnvelopeRadiusPix);
      else
         distance=radius;
      end
      centralNoiseEnvelope=exp(-(distance.^2)/sigma^2);
   elseif o.noiseRaisedCosineEdgeThicknessDeg > 0
      % Compute central noise envelope with raised-cosine border.
      [x, y]=meshgrid(1:o.canvasSize(1),1:o.canvasSize(2));
      x=x-mean(x(:));
      y=y-mean(y(:));
      thickness=o.noiseRaisedCosineEdgeThicknessDeg*o.pixPerDeg/o.targetCheckPix;
      radius=o.noiseRadiusDeg*o.pixPerDeg/o.targetCheckPix;
      a=90+180*(sqrt(x.^2+y.^2)-radius)/thickness;
      a=min(180,a);
      a=max(0,a);
      centralNoiseEnvelope=0.5+0.5*cosd(a);
   else
      centralNoiseEnvelope=ones(o.canvasSize);
   end
   o.centralNoiseEnvelopeE1DegDeg=sum(centralNoiseEnvelope(:).^2*o.noiseCheckPix/o.pixPerDeg^2);
   
   %% o.E1 is energy at unit contrast.
   power=1:length(signal);
   for i=1:length(power)
      power(i)=sum(signal(i).image(:).^2);
      if streq(o.targetKind,'letter')
         ok=ismember(unique(signal(i).image(:)),[0 1]);
         assert(all(ok));
      end
   end
   o.E1=mean(power)*(o.targetCheckPix/o.pixPerDeg)^2;
   ffprintf(ff,'log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',log10(o.E1));
   if ismember(o.observer,algorithmicObservers)
      Screen('CloseAll');
      window=-1;
      LMin=0;
      LMax=200;
      LMean=100;
   end
   o.LMean=LMean; % Save in our struct for later reference to trial data.
   % We are now done with the signal font (e.g. Sloan or Bookman), since we've saved our signals as images.
   if window ~= -1
      Screen('TextFont',window,textFont);
      Screen('TextSize',window,o.textSize);
      Screen('TextStyle',window,textStyle);
      if ~o.useFractionOfScreen
         HideCursor;
      end
   end
   frameRect=InsetRect(boundsRect,-1,-1);
   if o.saveSnapshot
      o.gray1=gray;
   end
   
   %% START NEW RUN, DISPLAYING STIMULI ON SCREEN
   if ~ismember(o.observer,algorithmicObservers) && ~o.assessBitDepth %&& ~o.saveSnapshot;
      Screen('FillRect',window,o.gray1);
      Screen('FillRect',window,gray,o.stimulusRect);
      fprintf('o.gray1*o.maxEntry %.1f, gray*o.maxEntry %.1f, o.maxEntry %.0f\n',o.gray1*o.maxEntry,gray*o.maxEntry,o.maxEntry);
      if o.showCropMarks
         TrimMarks(window,frameRect);
      end
      if ~isempty(fixationLines)
         Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
      end
      Screen('Flip',window,0,1); % Show gray screen at LMean with fixation and crop marks. Don't clear buffer.
      
      msg='Starting new run. ';
      if o.markTargetLocation
         msg=[msg 'The X indicates target center. '];
      end
      if streq(o.eyes,'both')
         eyeOrEyes='eyes';
      else
         eyeOrEyes='eye';
      end
      if o.useFixation
         if o.fixationIsOffscreen
            msg=sprintf('%sPlease fix your %s on your offscreen fixation mark, ',msg,eyeOrEyes);
         else
            xyCm=(XYPixOfXYDeg(o,[0 0])-XYPixOfXYDeg(o,o.eccentricityXYDeg))/o.pixPerCm;
            msg=sprintf('%sPlease fix your %s the center of the fixation cross +, ',msg,eyeOrEyes);
         end
         word='and';
      else
         word='Please';
      end
      switch o.task
         case '4afc'
            msg=[msg word ' click when ready to begin.'];
            fprintf('Please click when ready to begin.\n');
         case 'identify'
            msg=[msg word ' press the SPACE bar when ready to begin.'];
            fprintf('Please press the space bar when ready to begin.\n');
      end
      Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
      DrawFormattedText(window,msg,0.5*o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
      Screen('Flip',window,0,1); % "Starting new run ..."
      if o.speakInstructions
         if ismac
            msg=strrep(msg,'fix','fixh');
            msg=strrep(msg,'space bar','spasebar');
         end
         Speak(msg);
      end
      switch o.task
         case '4afc'
            GetClicks;
         case 'identify'
            fprintf('*Waiting for SPACE key to start first trial.\n');
            response=GetKeypress([spaceKeyCode escapeKeyCode graveAccentKeyCode]);
            % This keypress serves mainly to start the first trial, but we
            % quit if the user hits escape.
            if ismember(response,[escapeChar,graveAccentChar])
               if o.speakInstructions
                  Speak('Quitting.');
               end
               o.quitRun=true;
               o.quitSession=true;
               sca;
               ListenChar;
               return
            end
      end
   end
   
   %% SET PARAMETERS FOR QUEST
   if isempty(o.lapse) || isnan(o.lapse)
      o.lapse=0.02;
   end
   if isempty(o.guess) || ~isfinite(o.guess)
      switch o.task
         case '4afc'
            o.guess=1/4;
         case 'identify'
            o.guess=1/o.alternatives;
      end
   end
   if streq(o.targetModulates,'luminance')
      tGuess=-0.5;
      tGuessSd=2;
   else
      tGuess=0;
      tGuessSd=4;
   end
   rDeg=sqrt(sum(o.eccentricityXYDeg.^2));
   switch o.thresholdParameter
      case 'spacing'
         nominalCriticalSpacingDeg=0.3*(rDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
         tGuess=log10(2*nominalCriticalSpacingDeg);
      case 'size'
         nominalAcuityDeg=0.029*(rDeg+2.72); % Eq. 13 from Song, Levi, and Pelli (2014).
         tGuess=log10(2*nominalAcuityDeg);
      case 'contrast'
         o.thresholdPolarity=sign(o.contrast);
      case 'flankerContrast'
         assert(o.useFlankers);
         o.thresholdPolarity=sign(o.flankerContrast);
      otherwise
         error('Unknown o.thresholdParameter "%s".',o.thresholdParameter);
   end
   if isfinite(o.tGuess)
      tGuess=o.tGuess;
   end
   if isfinite(o.tGuessSd)
      tGuessSd=o.tGuessSd;
   end
   ffprintf(ff,['Log guess %.2f',plusMinusChar,'%.2f\n'],tGuess,tGuessSd);

   %% Set parameters for QUESTPlus
   if o.questPlusEnable
      steepnesses=o.questPlusSteepnesses;
      guessingRates=o.questPlusGuessingRates;
      lapseRates=o.questPlusLapseRates;
      contrastDB=20*o.questPlusLogContrasts;
      if streq(o.thresholdParameter,'flankerContrast')
         psychometricFunction=@qpPFCrowding;
      else
         psychometricFunction=@qpPFWeibull;
      end
      questPlusData=qpParams('stimParamsDomainList', {contrastDB},...,
         'psiParamsDomainList',{contrastDB, steepnesses, guessingRates, lapseRates},'qpPF',psychometricFunction);
      questPlusData=qpInitialize(questPlusData);
   end
   
   %% DO A RUN
   o.data=[];
   if isfield(o,'transcript')
      o=rmfield(o,'transcript');
   end
   o.transcript.intensity=[];
   o.transcript.isRight=[];
   o.transcript.response=[];
   o.transcript.target=[];
   if o.useFlankers
      o.transcript.flankers={};
   end
   if streq(o.thresholdParameter,'flankerContrast')
      % Falling psychometric function for crowding of target as a function
      % of flanker contrast. We assume that the observer makes a random
      % finger error on fraction delta of the trials, and gets proportion
      % gamma of those trials right. On the rest of the trials (no finger
      % error) he gets it wrong only if he fails to guess it (prob. gamma)
      % and fails to detect it (prob. exp...).
      q=QuestCreate(tGuess,tGuessSd,o.pThreshold,o.steepness,0,0); % Prob of detecting flanker.
      q.p2=o.lapse*o.guess+(1-o.lapse)*(1-(1-o.guess)*q.p2); % Prob of identifying target.
      q.s2=fliplr([1-q.p2;q.p2]);
      %    figure;
      %    plot(q.x2,q.p2);
   else
      q=QuestCreate(tGuess,tGuessSd,o.pThreshold,o.steepness,o.lapse,o.guess);
   end
   q.normalizePdf=true; % Prevent underflow of pdf.
   wrongRight={'wrong', 'right'};
   timeZero=GetSecs;
   trialsRight=0;
   rWarningCount=0;
   runStart=GetSecs;
   for trial=1:o.trialsPerRun
      [~,neworder]=sort(lower(fieldnames(o)));
      o=orderfields(o,neworder);
      
      %% SET TARGET LOG CONTRAST: tTest
      if o.questPlusEnable
         tTest=qpQuery(questPlusData)/20; % Convert dB to log contrast.
      else
         tTest=QuestQuantile(q);
      end
      if o.useMethodOfConstantStimuli
         % thresholdParameterValueList is used solely within this if block.
         if trial==1
            assert(size(o.constantStimuli,1)==1)
            o.thresholdParameterValueList=...
               repmat(o.constantStimuli,1,ceil(o.trialsPerRun/length(o.constantStimuli)));
            o.thresholdParameterValueList=Shuffle(o.thresholdParameterValueList);
         end
         c=o.thresholdParameterValueList(trial);
         o.thresholdPolarity=sign(c);
         tTest=log10(abs(c));
      end
      if ~isfinite(tTest)
         ffprintf(ff,'WARNING: trial %d: tTest %f not finite. Setting to QuestMean.\n',trial,tTest);
         tTest=QuestMean(q);
      end
      if o.saveSnapshot
         tTest=o.tSnapshot;
      end
      switch o.thresholdParameter
         case 'spacing'
            spacingDeg=10^tTest;
            flankerSpacingPix=spacingDeg*o.pixPerDeg;
            flankerSpacingPix=max(flankerSpacingPix,1.2*o.targetHeightPix);
            fprintf('flankerSpacingPix %d\n',flankerSpacingPix);
         case 'size'
            targetSizeDeg=10^tTest;
            o.targetHeightPix=targetSizeDeg*o.pixPerDeg;
            o.targetWidthPix=o.targetHeightPix;
         case 'contrast'
            if streq(o.targetModulates,'luminance')
               r=1;
               o.contrast=o.thresholdPolarity*10^tTest; % negative contrast, dark letters
               if o.saveSnapshot && isfinite(o.snapshotContrast)
                  o.contrast=-o.snapshotContrast;
               end
            else
               r=1+10^tTest;
               o.contrast=0;
            end
         case 'flankerContrast'
            assert(streq(o.targetModulates,'luminance'))
            o.flankerContrast=o.thresholdPolarity*10^tTest;
            if o.saveSnapshot && isfinite(o.snapshotContrast)
               o.flankerContrast=-o.snapshotContrast;
            end
      end
      a=(1-LMin/LMean)*o.noiseListSd/o.noiseListBound;
      if o.noiseSD > a
         ffprintf(ff,'WARNING: Reducing o.noiseSD of %s noise to %.2f to avoid overflow.\n',o.noiseType,a);
         o.noiseSD=a;
      end
      if isfinite(o.annularNoiseSD) && o.annularNoiseSD > a
         ffprintf(ff,'WARNING: Reducing o.annularNoiseSD of %s noise to %.2f to avoid overflow.\n',o.noiseType,a);
         o.annularNoiseSD=a;
      end
      %% RESTRICT tTest TO PHYSICALLY POSSIBLE RANGE
      switch o.targetModulates
         case 'noise'
            a=(1-LMin/LMean)/(o.noiseListBound*o.noiseSD/o.noiseListSd);
            if r > a
               r=a;
               if ~exist('rWarningCount','var') || rWarningCount == 0
                  ffprintf(ff,'WARNING: Limiting r ratio of %s noises to upper bound %.2f to stay within luminance range.\n',o.noiseType,r);
               end
               rWarningCount=rWarningCount+1;
            end
            tTest=log10(r-1);
         case 'luminance'
            % min negative contrast
            a=(min(cal.old.L)-LMean)/LMean;
            a=a+o.noiseListBound*o.noiseSD/o.noiseListSd;
            assert(a<0,'Need range for signal.');
            if o.contrast < a
               o.contrast=a;
            end
            if o.flankerContrast < a
               o.flankerContrast=a;
            end
            a=-a; % max contrast
            assert(a>0,'Need range for signal.');
            if o.contrast > a
               o.contrast=a;
            end
            if o.flankerContrast > a
               o.flankerContrast=a;
            end
            switch o.thresholdParameter
               case 'flankerContrast'
                  tTest=log10(abs(o.flankerContrast));
               case 'contrast'
                  tTest=log10(abs(o.contrast));
            end
         case 'entropy'
            a=128/o.backgroundEntropyLevels;
            if r > a
               r=a;
               if ~exist('rWarningCount','var') || rWarningCount == 0
                  ffprintf(ff,'WARNING: Limiting entropy of %s noise to upper bound %.1f bits.\n',o.noiseType,log2(r*o.backgroundEntropyLevels));
               end
               rWarningCount=rWarningCount+1;
            end
            signalEntropyLevels=round(r*o.backgroundEntropyLevels);
            r=signalEntropyLevels/o.backgroundEntropyLevels; % define r as ratio of number of levels
            tTest=log10(r-1);
         otherwise
            error('Unknown o.targetModulates "%s"',o.targetModulates);
      end % switch o.targetModulates
      
      if o.noiseFrozenInRun
         if trial == 1
            if o.noiseFrozenInRunSeed
               assert(o.noiseFrozenInRunSeed > 0 && isinteger(o.noiseFrozenInRunSeed))
               o.noiseListSeed=o.noiseFrozenInRunSeed;
            else
               rng('shuffle'); % Use time to seed the random number generator.
               generator=rng;
               o.noiseListSeed=generator.Seed;
            end
         end
         rng(o.noiseListSeed);
      end % if o.noiseFrozenInRun
      
      %% RESTRICT tTest TO LEGAL VALUE IN QUESTPLUS
      if o.questPlusEnable
         i=knnsearch(contrastDB'/20,tTest);
         tTest=contrastDB(i)/20;
      end
      
      %% COMPUTE MOVIE IMAGES
      movieImage={};
      movieSaveWhich=[];
      movieFrameComputeStartSec=GetSecs;
      
      for iMovieFrame=1:o.movieFrames
         % On each new frame, retain the (static) signal and regenerate the (dynamic) noise.
         switch o.task % add noise to signal
            case '4afc'
               canvasRect=[0 0 o.canvasSize(2) o.canvasSize(1)];
               sRect=RectOfMatrix(signal(1).image);
               sRect=round(CenterRect(sRect,canvasRect));
               assert(IsRectInRect(sRect,canvasRect));
               signalImageIndex=logical(FillRectInMatrix(true,sRect,zeros(o.canvasSize)));
               locations=4;
               rng('shuffle');
               if iMovieFrame == 1
                  signalLocation=randi(locations);
                  movieSaveWhich=signalLocation;
               else
                  signalLocation=movieSaveWhich;
               end
               for i=1:locations
                  if o.noiseFrozenInTrial
                     if i == 1
                        generator=rng;
                        o.noiseListSeed=generator.Seed;
                     end
                     rng(o.noiseListSeed);
                  end
                  noise=PsychRandSample(noiseList,o.canvasSize*o.targetCheckPix/o.noiseCheckPix);
                  noise=Expand(noise,o.noiseCheckPix/o.targetCheckPix);
                  if o.noiseIsFiltered
                     if any(mtf(:) ~= 1)
                        if any(mtf(:) ~= 0)
                           % filtering 50x50 takes 200 ms on PowerMac 7500/100
                           ft=mtf.*fftshift(fft2(noise));
                           noise=real(ifft2(ifftshift(ft)));
                           clear ft
                        else
                           noise=zeros(size(noise));
                        end
                     end
                  end
                  if i == signalLocation
                     switch o.targetModulates
                        case 'noise'
                           location(i).image=1+r*(o.noiseSD/o.noiseListSd)*noise;
                        case 'luminance'
                           location(i).image=1+(o.noiseSD/o.noiseListSd)*noise+o.contrast;
                        case 'entropy'
                           q.noiseList=(0.5+floor(noiseList*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                           q.sd=std(q.noiseList);
                           location(i).image=1+(o.noiseSD/q.sd)*(0.5+floor(noise*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                     end
                  else
                     switch o.targetModulates
                        case 'entropy'
                           q.noiseList=(0.5+floor(noiseList*0.499999*o.backgroundEntropyLevels))/(0.5*o.backgroundEntropyLevels);
                           q.sd=std(q.noiseList);
                           location(i).image=1+(o.noiseSD/q.sd)*(0.5+floor(noise*0.499999*o.backgroundEntropyLevels))/(0.5*o.backgroundEntropyLevels);
                        otherwise
                           location(i).image=1+(o.noiseSD/o.noiseListSd)*noise;
                     end
                  end
               end
            case 'identify'
               locations=1;
               rng('shuffle');
               if iMovieFrame == 1
                  whichSignal=randi(o.alternatives);
                  movieSaveWhich=whichSignal;
                  if o.measureContrast
                     WaitSecs(0.3);
                     if o.speakInstructions
                        Speak(o.alphabet(whichSignal));
                     end
                  end
               else
                  whichSignal=movieSaveWhich;
               end
               if o.noiseFrozenInRun
                  rng(o.noiseListSeed);
               end
               noise=PsychRandSample(noiseList,o.canvasSize*o.targetCheckPix/o.noiseCheckPix);
               noise=Expand(noise,o.noiseCheckPix/o.targetCheckPix);
               noise(~centralNoiseMask & ~annularNoiseMask)=0;
               noise(centralNoiseMask)=centralNoiseEnvelope(centralNoiseMask).*noise(centralNoiseMask);
               canvasRect=RectOfMatrix(noise);
               sRect=RectOfMatrix(signal(1).image);
               sRect=round(CenterRect(sRect,canvasRect));
               if ~IsRectInRect(sRect,canvasRect)
                  ffprintf(ff,'sRect [%d %d %d %d] exceeds canvasRect [%d %d %d %d].\n',sRect,canvasRect);
               end
               assert(IsRectInRect(sRect,canvasRect));
               signalImageIndex=logical(FillRectInMatrix(true,sRect,zeros(o.canvasSize)));
               % figure(1);imshow(signalImageIndex);
               signalImage=zeros(o.canvasSize);
               if (iMovieFrame > o.moviePreFrames ...
                     && iMovieFrame <= o.moviePreFrames+o.movieSignalFrames)
                  % Add in signal only during the signal interval.
                  signalImage(signalImageIndex)=signal(whichSignal).image(:);
               end
               % figure(2);imshow(signalImage);
               signalMask=logical(signalImage);
               switch o.targetModulates
                  case 'luminance'
                     location(1).image=ones(o.canvasSize);
                     location(1).image(centralNoiseMask)=1+(o.noiseSD/o.noiseListSd)*noise(centralNoiseMask);
                     location(1).image(annularNoiseMask)=1+(o.annularNoiseSD/o.noiseListSd)*noise(annularNoiseMask);
                     location(1).image=location(1).image+o.contrast*signalImage; % NOTE: noise and signal added here
                  case 'noise'
                     noise(signalMask)=r*noise(signalMask);
                     location(1).image=ones(o.canvasSize);
                     location(1).image(centralNoiseMask)=1+(o.noiseSD/o.noiseListSd)*noise(centralNoiseMask);
                     location(1).image(annularNoiseMask)=1+(o.annularNoiseSD/o.noiseListSd)*noise(annularNoiseMask);
                  case 'entropy'
                     noise(~centralNoiseMask)=0;
                     noise(signalMask)=(0.5+floor(noise(signalMask)*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                     noise(~signalMask)=(0.5+floor(noise(~signalMask)*0.499999*o.backgroundEntropyLevels))/(0.5*o.backgroundEntropyLevels);
                     location(1).image=1+(o.noiseSD/o.noiseListSd)*noise;
               end
               %% ADD FOUR FLANKERS, EACH A RANDOM LETTER LIKE THE TARGET
               if o.useFlankers && streq(o.targetModulates,'luminance')
                  if isfinite(o.flankerContrast)
                     c=o.flankerContrast;
                  else
                     c=o.contrast; % Same contrast as target.
                  end
                  for j=1:4
                     theta=j*90;
                     if iMovieFrame==1
                        whichFlanker(j)=randi(o.alternatives);
                     end
                     r=RectOfMatrix(signal(whichFlanker(j)).image);
                     r=CenterRect(r,canvasRect);
                     offset=round(flankerSpacingPix/o.targetCheckPix);
                     r=OffsetRect(r,cosd(theta)*offset,sind(theta)*offset);
                     assert(IsRectInRect(r,canvasRect));
                     flankerImageIndex=logical(FillRectInMatrix(true,r,zeros(o.canvasSize)));
                     flankerImage=zeros(o.canvasSize);
                     if (iMovieFrame > o.moviePreFrames ...
                           && iMovieFrame <= o.moviePreFrames+o.movieSignalFrames)
                        % Add in flanker only during the signal interval.
                        flankerImage(flankerImageIndex)=signal(whichFlanker(j)).image(:);
                     end
                     location(1).image=location(1).image+c*flankerImage; % Add flanker.
                  end % for j=1:4
                  o.transcript.flankers{trial}=whichFlanker; % Save the whole array of 4 flankers.
               end % if o.useFlankers
            otherwise
               error('Unknown o.task "%s"',o.task);
         end % switch o.task
         movieImage{iMovieFrame}=location;
      end % for iMovieFrame=1:o.movieFrames
      
      if o.measureContrast
         fprintf('%d: unique(signalImage(:)) ',MFileLineNr);
         fprintf('%g ',unique(signalImage(:)));
         fprintf('\n');
      end
      
      %% COMPUTE CLUT
      if ~ismember(o.observer,algorithmicObservers)
         if trial==1
            % Clear screen for first trial. After the first trial, the
            % screen is already ready for next trial.
            Screen('FillRect',window,o.gray1);
            Screen('FillRect',window,gray,o.stimulusRect);
         end
         if ~isempty(fixationLines)
            Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
         end
         rect=[0 0 1 1]*2*o.annularNoiseBigRadiusDeg*o.pixPerDeg/o.noiseCheckPix;
         if o.newClutForEachImage % Usually enabled.
            % Compute CLUT for all possible noises and the given signal and
            % contrast. Note: The gray screen in the non-stimulus areas is
            % drawn with CLUT index n=1.
            
            % Noise
            % Set up luminance range that allows for superposition of noise
            % on target and on flanker. If the noise in fact does not
            % superimpose target or flanker then this range may be broader
            % than strictly necessary.
            cal.LFirst=LMean*(1-o.noiseListBound*r*o.noiseSD/o.noiseListSd);
            cal.LLast=LMean*(1+o.noiseListBound*r*o.noiseSD/o.noiseListSd);
            if ~o.useFlankers
               o.flankerContrast=0;
            end
            if streq(o.targetModulates,'luminance')
               cal.LFirst=cal.LFirst+LMean*min([0 o.contrast o.flankerContrast]);
               cal.LLast=cal.LLast+LMean*max([0 o.contrast o.flankerContrast]);
            end
            if o.annularNoiseBigRadiusDeg > o.annularNoiseSmallRadiusDeg
               cal.LFirst=min(cal.LFirst,LMean*(1-o.noiseListBound*r*o.annularNoiseSD/o.noiseListSd));
               cal.LLast=max(cal.LLast,LMean*(1+o.noiseListBound*r*o.annularNoiseSD/o.noiseListSd));
            end
            % Range is centered on LMean and includes LFirst and LLast.
            % Having a fixed index for "gray" (LMean) assures us that
            % the gray areas (most of the screen) won't change when the
            % CLUT is updated.
            LRange=2*max(abs([cal.LLast-LMean LMean-cal.LFirst]));
            LRange=min(LRange,o.maxLRange);
            cal.LFirst=LMean-LRange/2;
            cal.LLast=LMean+LRange/2;
            cal.nFirst=firstGrayClutEntry;
            cal.nLast=lastGrayClutEntry;
            if o.saveSnapshot
               cal.LFirst=min(cal.old.L);
               cal.LLast=max(cal.old.L);
               cal.nFirst=1;
               cal.nLast=o.maxEntry;
            end
            if false % Compute clut for the specific image
               L=[];
               for i=1:locations
                  L=[L location(i).image(:)*LMean];
               end
               cal.LFirst=min(L);
               cal.LLast=max(L);
            end
            cal=LinearizeClut(cal);
            grayCheck=IndexOfLuminance(cal,LMean)/o.maxEntry;
            if ~o.saveSnapshot && abs(grayCheck-gray)>0.001
               ffprintf(ff,'The estimated gray index is %.4f (%.1f cd/m^2), not %.4f (%.1f cd/m^2).\n',...
                  grayCheck,LuminanceOfIndex(cal,grayCheck*o.maxEntry),gray,LuminanceOfIndex(cal,gray*o.maxEntry));
               warning('The gray index changed!');
            end
            assert(isfinite(gray));
         end % if o.newClutForEachImage
         if o.assessContrast
            AssessContrast(o);
         end
         if o.measureContrast
            % fprintf('gray*o.maxEntry %d gamma %.3f, o.gray1*o.maxEntry %d gamma %.3f\n',gray*o.maxEntry,cal.gamma(gray*o.maxEntry+1,2),o.gray1*o.maxEntry,cal.gamma(o.gray1*o.maxEntry+1,2));
            Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
            Screen('Flip',window,0,1);
            o=MeasureContrast(o,MFileLineNr);
         end
         if o.assessBitDepth
            assessBitDepth(o);
            break;
         end
         if o.showCropMarks
            TrimMarks(window,frameRect); % This should be moved down, to be drawn AFTER the noise.
         end
         if o.saveSnapshot && o.snapshotShowsFixationBefore && ~isempty(fixationLines)
            Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
         end
      end % if ~ismember(o.observer,algorithmicObservers)
      
      if o.measureContrast
         location=movieImage{1};
         fprintf('%d: luminance/LMean',MFileLineNr);
         fprintf(' %.4f',unique(location(1).image(:)));
         fprintf('\n');
         img=IndexOfLuminance(cal,location(1).image*LMean)/o.maxEntry;
         index=unique(img(:));
         LL=LuminanceOfIndex(cal,index*o.maxEntry);
         fprintf('%d: index',MFileLineNr);
         fprintf(' %.4f',index);
         fprintf(', G');
         fprintf(' %.4f',cal.gamma(round(1+index*o.maxEntry),2));
         fprintf(', luminance');
         fprintf(' %.1f',LL);
         if o.contrast<0
            c=(LL(1)-LL(2))/LL(2);
         else
            c=(LL(2)-LL(1))/LL(1);
         end
         fprintf(', contrast %.4f\n',c);
         movieTexture(iMovieFrame)=Screen('MakeTexture',window,img,0,0,1);
         rect=Screen('Rect',movieTexture(iMovieFrame));
         img=Screen('GetImage',movieTexture(iMovieFrame),rect,'frontBuffer',1);
         index=unique(img(:));
         LL=LuminanceOfIndex(cal,index*o.maxEntry);
         fprintf('%d: texture index',MFileLineNr);
         fprintf(' %.4f',index);
         fprintf(', G');
         fprintf(' %.4f',cal.gamma(round(1+index*o.maxEntry),2));
         fprintf(', luminance');
         fprintf(' %.1f',LL);
         if o.contrast<0
            c=(LL(1)-LL(2))/LL(2);
         else
            c=(LL(2)-LL(1))/LL(1);
         end
         fprintf(', contrast %.4f\n',c);
      end
      
      %% CONVERT IMAGE MOVIE TO TEXTURE MOVIE
      if ~ismember(o.observer,algorithmicObservers)
         for iMovieFrame=1:o.movieFrames
            location=movieImage{iMovieFrame};
            switch o.task
               case 'identify'
                  locations=1;
                  % Convert to pixel values.
                  % PREPARE IMAGE DATA
                  img=location(1).image;
                  % ffprintf(ff,'signal rect height %.1f, image height %.0f, dst rect %d %d %d %d\n',RectHeight(rect),size(img,1),rect);
                  img=IndexOfLuminance(cal,img*LMean)/o.maxEntry;
                  img=Expand(img,o.targetCheckPix);
                  if o.assessLinearity
                     AssessLinearity(o);
                  end
                  rect=RectOfMatrix(img);
                  rect=CenterRect(rect,[o.targetXYPix o.targetXYPix]);
                  rect=round(rect); % rect that will receive the stimulus (target and noises)
                  location(1).rect=rect;
                  movieTexture(iMovieFrame)=Screen('MakeTexture',window,img,0,0,1); % SAVE MOVIE FRAME
                  srcRect=RectOfMatrix(img);
                  dstRect=rect;
                  offset=dstRect(1:2)-srcRect(1:2);
                  dstRect=ClipRect(dstRect,o.stimulusRect);
                  srcRect=OffsetRect(dstRect,-offset(1),-offset(2));
                  eraseRect=dstRect;
                  rect=CenterRect([0 0 o.targetHeightPix o.targetWidthPix],rect);
                  rect=round(rect); % target rect
               case '4afc'
                  rect=[0 0 o.targetHeightPix o.targetWidthPix];
                  location(1).rect=AlignRect(rect,boundsRect,'left','top');
                  location(2).rect=AlignRect(rect,boundsRect,'right','top');
                  location(3).rect=AlignRect(rect,boundsRect,'left','bottom');
                  location(4).rect=AlignRect(rect,boundsRect,'right','bottom');
                  eraseRect=location(1).rect;
                  for i=1:locations
                     img=location(i).image;
                     img=IndexOfLuminance(cal,img*LMean);
                     img=Expand(img,o.targetCheckPix);
                     texture=Screen('MakeTexture',window,img/o.maxEntry,0,0,1); % FIXME: use one texture instead of 4
                     
                     eraseRect=UnionRect(eraseRect,location(i).rect);
                  end
                  if o.showResponseNumbers
                     % Label the o.alternatives 1 to 4. They are
                     % placed to one side of the quadrant, centered
                     % vertically, with a one-space gap. Or half a
                     % letter space horizontally and vertically away
                     % from each corner. Currently the response
                     % numbers are treated as non-essential. We
                     % don't reserve space for them by limiting the
                     % letter size. And they are clipped if they
                     % fall outside o.stimulusRect. The assumption
                     % is that experienced observers know the
                     % quadrant numbering and can function perfectly
                     % well without seeing the numbers on
                     % each trial.
                     if o.responseNumbersInCorners
                        % in corners
                        r=[0 0 o.textSize 1.4*o.textSize];
                        labelBounds=InsetRect(boundsRect,-1.1*o.textSize,-o.lineSpacing*o.textSize);
                     else
                        % on sides
                        r=[0 0 o.textSize o.targetHeightPix];
                        labelBounds=InsetRect(boundsRect,-2*o.textSize,0);
                     end
                     location(1).labelRect=AlignRect(r,labelBounds,'left','top');
                     location(2).labelRect=AlignRect(r,labelBounds,'right','top');
                     location(3).labelRect=AlignRect(r,labelBounds,'left','bottom');
                     location(4).labelRect=AlignRect(r,labelBounds,'right','bottom');
                     for i=1:locations
                        [x, y]=RectCenter(location(i).labelRect);
                        Screen('DrawText',window,sprintf('%d',i),x-o.textSize/2,y+0.4*o.textSize,black,o.gray1,1);
                     end
                  end
            end % switch o.task
         end % for iMovieFrame=1:o.movieFrames
      end % if ~ismember(o.observer,algorithmicObservers)
      if o.measureContrast
         rect=Screen('Rect',movieTexture(1));
         img=Screen('GetImage',movieTexture(1),rect,'frontBuffer',1); % 1 for float, not int, colors.
         img=img(:,:,2);
         img=unique(img(:));
         G=cal.gamma(round(1+img*o.maxEntry),2);
         LL=LuminanceOfIndex(cal,img*o.maxEntry);
         fprintf('%d: texture index',MFileLineNr);
         fprintf(' %.4f',img);
         fprintf(', G');
         fprintf(' %.4f',G);
         fprintf(', luminance');
         fprintf(' %.1f',LL);
         if o.contrast<0
            c=(LL(1)-LL(2))/LL(2);
         else
            c=(LL(2)-LL(1))/LL(1);
         end
         fprintf(', contrast %.4f\n',c);
         % Compare hardware CLUT with identity.
         gammaRead=Screen('ReadNormalizedGammaTable',window);
         maxEntry=size(gammaRead,1)-1;
         gamma=repmat(((0:maxEntry)/maxEntry)',1,3);
         delta=gammaRead(:,2)-gamma(:,2);
         ffprintf(ff,'Difference between identity and read-back of hardware CLUT (%dx%d): mean %.9f, sd %.9f\n',...
            size(gammaRead),mean(delta),std(delta));
      end
      
      %% PLAY MOVIE
      Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
      if ~ismember(o.observer,algorithmicObservers)
         Snd('Play',purr); % Pre-announce that image is up, awaiting response.
         o.movieFrameFlipSec(1:o.movieFrames+1,trial)=nan;
         for iMovieFrame=1:o.movieFrames
            Screen('DrawTexture',window,movieTexture(iMovieFrame),srcRect,dstRect);
            if o.showBlackAnnulus
               radius=round(o.blackAnnulusSmallRadiusDeg*o.pixPerDeg);
               o.blackAnnulusSmallRadiusDeg=radius/o.pixPerDeg;
               annulusRect=[0 0 2*radius 2*radius];
               annulusRect=CenterRect(annulusRect,[o.targetXYPix o.targetXYPix]);
               thickness=max(1,round(o.blackAnnulusThicknessDeg*o.pixPerDeg));
               o.blackAnnulusThicknessDeg=thickness/o.pixPerDeg;
               if o.blackAnnulusContrast == -1
                  color=0;
               else
                  luminance=(1+o.blackAnnulusContrast)*LMean;
                  luminance=max(min(luminance,cal.LLast),cal.LFirst);
                  color=IndexOfLuminance(cal,luminance);
                  o.blackAnnulusContrast=LuminanceOfIndex(cal,color)/LMean-1;
               end
               Screen('FrameRect',window,color,annulusRect,thickness);
            end % if o.showBlackAnnulus
            if o.saveStimulus && iMovieFrame == o.moviePreFrames+1
               o.savedStimulus=Screen('GetImage',window,o.stimulusRect,'drawBuffer');
               fprintf('o.savedStimulus at contrast %.3f, flankerContrast %.3f\n',o.contrast,o.flankerContrast);
               Screen('DrawText',window,sprintf('o.contrast %.3f, flankerContrast %.3f',o.contrast,o.flankerContrast),20,150);
               o.newCal=cal;
               if o.saveSnapshot
                  snapshotTexture=Screen('OpenOffscreenWindow',movieTexture(iMovieFrame));
                  Screen('CopyWindow',movieTexture(iMovieFrame),snapshotTexture);
               end
            end
            Screen('Flip',window,0,1); % Display movie frame. Don't clear back buffer.
            o.movieFrameFlipSec(iMovieFrame,trial)=GetSecs;
         end % for iMovieFrame=1:o.movieFrames
         if o.saveSnapshot
            SaveSnapshot(o); % Closes window when done.
            return
         end
         if o.assessTargetLuminance
            % Reading from the buffer, the image has already been converted
            % from index to RGB. We use our calibration to estimate
            % luminance from G.
            rect=CenterRect(o.targetCheckPix*o.targetRectLocal,o.stimulusRect);
            o.actualStimulus=Screen('GetImage',window,rect,'frontBuffer',1);
            % Get the mode and mode of rest.
            p=o.actualStimulus(:,:,2);
            p=p(:);
            pp=mode(p);
            pp(2)=mode(p(p~=pp));
            pp=sort(pp);
            imageLuminance=interp1(cal.old.G,cal.old.L,pp,'pchip');
            ffprintf(ff,'%d: assessTargetLuminance: G',MFileLineNr);
            ffprintf(ff,' %.4f',pp);
            ffprintf(ff,', luminance');
            ffprintf(ff,' %.1f',LL);
            if o.contrast<0
               c=(LL(1)-LL(2))/LL(2);
            else
               c=(LL(2)-LL(1))/LL(1);
            end
            ffprintf(ff,', contrast %.4f\n',c);
            ffprintf(ff,'\n');
            %             print stimulus as table of numbers
            %             dx=round(size(o.actualStimulus,2)/10);
            %             dy=round(dx*0.7);
            %             o.actualStimulus(1:dy:end,1:dx:end,2)
         end
         if isfinite(o.targetDurationSec) % End the movie
            Screen('FillRect',window,gray,dstRect); % Erase only the movie, sparing the rest of the screen.
            if o.useDynamicNoiseMovie
               Screen('Flip',window,0,1); % Clear stimulus at next frame.
            else
               % Clear stimulus at next frame after specified duration.
               Screen('Flip',window,o.movieFrameFlipSec(1,trial)+o.targetDurationSec-0.5/frameRate,1);
            end
            o.movieFrameFlipSec(iMovieFrame+1,trial)=GetSecs;
            if ~o.fixationCrossBlankedNearTarget
               WaitSecs(o.fixationCrossBlankedUntilSecAfterTarget);
            end
            if ~isempty(fixationLines)
               Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,black); % fixation
            end
            % After o.fixationCrossBlankedUntilSecAfterTarget, display new fixation.
            Screen('Flip',window,o.movieFrameFlipSec(iMovieFrame+1,trial)+0.3,1);
         end % if isfinite(o.targetDurationSec)
         for iMovieFrame=1:o.movieFrames
            Screen('Close',movieTexture(iMovieFrame));
         end
         eraseRect=ClipRect(eraseRect,o.stimulusRect);
         eraseRect=dstRect; % Erase only the movie, sparing the rest of the screen
         % Print instruction in upper left corner.
         Screen('FillRect',window,o.gray1,topCaptionRect);
         message=sprintf('Trial %d of %d. Run %d of %d.',trial,o.trialsPerRun,o.runNumber,o.runsDesired);
         Screen('DrawText',window,message,o.textSize/2,o.textSize/2,black,o.gray1);
         
         % Print instructions in lower left corner.
         textRect=[0, 0, o.textSize, 1.2*o.textSize];
         textRect=AlignRect(textRect,screenRect,'left','bottom');
         textRect=OffsetRect(textRect,o.textSize/2,-o.textSize/2); % inset from screen edges
         textRect=round(textRect);
         switch o.task
            case '4afc'
               message='Please click 1 to 4 times for location 1 to 4, or more clicks to quit.';
            case 'identify'
               message=sprintf('Please type the letter: %s, or ESCAPE to quit.',o.alphabet(1:o.alternatives));
         end
         bounds=Screen('TextBounds',window,message);
         ratio=RectWidth(bounds)/(0.93*RectWidth(screenRect));
         if ratio > 1
            Screen('TextSize',window,floor(o.textSize/ratio));
         end
         Screen('FillRect',window,o.gray1,bottomCaptionRect);
         Screen('DrawText',window,message,textRect(1),textRect(4),black,o.gray1,1);
         Screen('TextSize',window,o.textSize);
         
         %% DISPLAY RESPONSE ALTERNATIVES
         switch o.task
            case '4afc'
               leftEdgeOfResponse=screenRect(3);
            case 'identify'
               % Draw the response o.alternatives
               rect=[0 0 o.targetWidthPix o.targetHeightPix]/o.targetCheckPix; % size of signal(1).image
               switch o.alphabetPlacement
                  case 'right'
                     desiredLengthPix=RectHeight(screenRect);
                     targetChecks=RectHeight(rect);
                  case 'top'
                     desiredLengthPix=0.5*RectWidth(screenRect);
                     targetChecks=RectWidth(rect);
               end
               switch o.targetKind
                  case 'letter'
                     spacingFraction=0.25;
                  case 'gabor'
                     spacingFraction=0;
               end
               if o.alternatives < 6
                  desiredLengthPix=desiredLengthPix*o.alternatives/6;
               end
               alphaSpaces=o.alternatives+spacingFraction*(o.alternatives+1);
               alphaPix=desiredLengthPix/alphaSpaces;
               %                         alphaCheckPix=alphaPix/(targetChecks/o.targetCheckPix);
               alphaCheckPix=alphaPix/targetChecks;
               alphaGapPixCeil=(desiredLengthPix-o.alternatives*ceil(alphaCheckPix)*targetChecks)/(o.alternatives+1);
               alphaGapPixFloor=(desiredLengthPix-o.alternatives*floor(alphaCheckPix)*targetChecks)/(o.alternatives+1);
               ceilError=log(alphaGapPixCeil/(ceil(alphaCheckPix)*targetChecks))-log(spacingFraction);
               floorError=log(alphaGapPixFloor/(floor(alphaCheckPix)*targetChecks))-log(spacingFraction);
               if min(abs(ceilError),abs(floorError)) < log(3)
                  if abs(floorError) < abs(ceilError)
                     alphaCheckPix=floor(alphaCheckPix);
                  else
                     alphaCheckPix=ceil(alphaCheckPix);
                  end
               end
               alphaGapPix=(desiredLengthPix-o.alternatives*targetChecks*alphaCheckPix)/(o.alternatives+1);
               useExpand=alphaCheckPix == round(alphaCheckPix);
               rect=[0 0 o.targetWidthPix o.targetHeightPix]/o.targetCheckPix; % size of signal(1).image
               rect=round(rect*alphaCheckPix);
               rect=AlignRect(rect,screenRect,RectRight,RectTop);
               rect=OffsetRect(rect,-alphaGapPix,alphaGapPix); % spacing
               rect=round(rect);
               switch o.alphabetPlacement
                  case 'right'
                     step=[0 RectHeight(rect)+alphaGapPix];
                  case 'top'
                     step=[RectWidth(rect)+alphaGapPix 0];
                     rect=OffsetRect(rect,-(o.alternatives-1)*step(1),0);
               end
               for i=1:o.alternatives
                  if useExpand
                     img=Expand(signal(i).image,alphaCheckPix);
                  else
                     if useImresize
                        img=imresize(signal(i).image,[RectHeight(rect), RectWidth(rect)]);
                     else
                        img=signal(i).image;
                        % If the imresize function (in Image
                        % Processing Toolbox) is not available
                        % the image resizing will then be done
                        % by the DrawTexture command below.
                     end
                  end
                  % NOTE: alphabet placement on top right
                  texture=Screen('MakeTexture',window,(1-img)*gray,0,0,1);
                  Screen('DrawTexture',window,texture,RectOfMatrix(img),rect);
                  Screen('Close',texture);
                  if o.labelAlternatives
                     Screen('TextSize',window,o.textSize);
                     textRect=AlignRect([0 0 o.textSize o.textSize],rect,'center','top');
                     Screen('DrawText',window,o.alphabet(i),textRect(1),textRect(4),black,o.gray1,1);
                  end
                  rect=OffsetRect(rect,step(1),step(2));
               end
               leftEdgeOfResponse=rect(1);
         end % switch o.task
         if o.assessLoadGamma
            ffprintf(ff,'Line %d: o.contrast %.3f, LoadNormalizedGammaTable 0.5*range/mean=%.3f\n', ...
               MFileLineNr,o.contrast,(cal.LLast-cal.LFirst)/(cal.LLast+cal.LFirst));
         end
         if o.assessGray
            pp=Screen('GetImage',window,[20 20 21 21]);
            ffprintf(ff,'Line %d: Gray index is %d (%.1f cd/m^2). Corner is %d.\n',...
               MFileLineNr,gray*o.maxEntry,LuminanceOfIndex(cal,gray*o.maxEntry),pp(1));
         end
         if trial == 1
            WaitSecs(1); % First time is slow. Mario suggested a work around, explained at beginning of this file.
         end
         Screen('Flip',window,0,1); % Display instructions.
         
         %% COLLECT RESPONSE
         switch o.task
            case '4afc'
               global ptb_mouseclick_timeout
               ptb_mouseclick_timeout=0.8;
               clicks=GetClicks;
               if ~ismember(clicks,1:locations)
                  ffprintf(ff,'*** %d clicks. Run terminated.\n',clicks);
                  if o.speakInstructions
                     Speak('Run terminated.');
                  end
                  trial=trial-1;
                  o.quitRun=true;
                  break;
               end
               response=clicks;
            case 'identify'
               response=0;
               while ~ismember(lower(response),lower(1:o.alternatives))
                  o.quitRun=false;
                  response=GetKeypress;
                  if ismember(response,[escapeChar,graveAccentChar])
                     ffprintf(ff,'User typed ESCAPE. Run terminated.\n',response);
                     if o.speakInstructions
                        Speak('Run terminated.');
                     end
                     o.quitRun=true;
                     trial=trial-1;
                     break;
                  end
                  if length(response) > 1
                     % GetKeypress might return a multi-character string,
                     % but our code assumes the response is a scalar, not a
                     % matrix. So we replace the string by 0.
                     response=0;
                  end
                  [ok,response]=ismember(lower(response),lower(o.alphabet));
                  if ~ok
                     if o.speakInstructions
                        Speak('Try again. Or hit ESCAPE to quit.');
                     end
                  end
               end % while ~ismember
         end % switch o.task
         if ~o.quitRun
            if ~isfinite(o.targetDurationSec)
               % Signal persists until response, so we measure response time.
               o.movieFrameFlipSec(iMovieFrame+1,trial)=GetSecs;
            end
            % CHECK DURATION
            if o.useDynamicNoiseMovie
               movieFirstSignalFrame=o.moviePreFrames+1;
               movieLastSignalFrame=o.movieFrames-o.moviePostFrames;
            else
               movieFirstSignalFrame=1;
               movieLastSignalFrame=1;
            end
            o.measuredTargetDurationSec(trial)=o.movieFrameFlipSec(movieLastSignalFrame+1,trial)-...
               o.movieFrameFlipSec(movieFirstSignalFrame,trial);
            o.likelyTargetDurationSec(trial)=round(o.measuredTargetDurationSec(trial)*frameRate)/frameRate;
            s=sprintf('Signal duration requested %.3f s, measured %.3f s, and likely %.3f s, an excess of %.0f frames.\n', ...
               o.targetDurationSec,o.measuredTargetDurationSec(trial),o.likelyTargetDurationSec(trial), ...
               (o.likelyTargetDurationSec(trial)-o.targetDurationSec)*frameRate);
            if abs(o.measuredTargetDurationSec(trial)-o.targetDurationSec) > 0.010
               ffprintf(ff,'WARNING: %s',s);
            else
               if o.printDurations
                  ffprintf(ff,'%s',s);
               end
            end
         end
      else
         response=ModelObserver(o);
      end % if ~ismember(o.observer,algorithmicObservers)
      if o.quitRun
         break;
      end
      switch o.task % score as right or wrong
         case '4afc'
            isRight=response == signalLocation;
            o.transcript.target(trial)=signalLocation;
         case 'identify'
            isRight=response == whichSignal;
            o.transcript.target(trial)=whichSignal;
     end
      if ~ismember(o.observer,algorithmicObservers)
         if isRight
            Snd('Play',rightBeep);
         else
            Snd('Play',wrongBeep);
         end
      end
      switch o.thresholdParameter
         case 'spacing'
            spacingDeg=flankerSpacingPix/o.pixPerDeg;
            tTest=log10(spacingDeg);
         case 'size'
            targetSizeDeg=o.targetHeightPix/o.pixPerDeg;
            tTest=log10(targetSizeDeg);
         case 'contrast'
         case 'flankerContrast'
      end
      trialsRight=trialsRight+isRight;
      q=QuestUpdate(q,tTest,isRight); % Add the new datum (actual test intensity and observer isRight) to the database.
      if o.questPlusEnable
         stim=20*tTest;
         outcome=isRight+1;
         questPlusData=qpUpdate(questPlusData,stim,outcome);
      end
      o.data(trial,1:2)=[tTest isRight];
      o.transcript.response(trial)=response;
      o.transcript.intensity(trial)=tTest;
      o.transcript.isRight(trial)=isRight;
      if cal.ScreenConfigureDisplayBrightnessWorks
         %          Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
         cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
         %          Brightness(cal.screen,cal.brightnessSetting);
         %          cal.brightnessReading=Brightness(cal.screen);
         if abs(cal.brightnessSetting-cal.brightnessReading) > 0.01
            string=sprintf('Screen brightness was set to %.0f%%, but reads as %.0f%%.\n',100*cal.brightnessSetting,100*cal.brightnessReading);
            ffprintf(ff,string);
            error(string);
         end
      end
   end % for trial=1:o.trialsPerRun
   
   o.quitSession=OfferToQuitSession(window,o,instructionalMarginPix,screenRect);
   
   
   %% DONE. REPORT THRESHOLD FOR THIS RUN.
   if ~isempty(o.data)
      psych.t=unique(o.data(:,1));
      psych.r=1+10.^psych.t;
      for i=1:length(psych.t)
         dataAtT=o.data(:,1) == psych.t(i);
         psych.trials(i)=sum(dataAtT);
         psych.right(i)=sum(o.data(dataAtT,2));
      end
   else
      psych=[];
   end
   o.psych=psych;
   o.questMean=QuestMean(q);
   o.questSd=QuestSd(q);
   t=QuestMean(q); % Used in printouts below.
   sd=QuestSd(q); % Used in printouts below.
   approxRequiredN=64/10^((o.questMean-idealT64)/0.55);
   o.p=trialsRight/trial;
   o.trials=trial;
   rDeg=sqrt(sum(o.eccentricityXYDeg.^2));
   switch o.thresholdParameter
      case 'spacing'
         ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',o.observer,100*o.p,targetSizeDeg,rDeg,10^o.questMean);
      case 'size'
         ffprintf(ff,'%s: p %.0f%%, ecc. %.1f deg, threshold size %.3f deg.\n',o.observer,100*o.p,rDeg,10^o.questMean);
      case 'contrast'
         o.contrast=o.thresholdPolarity*10^o.questMean;
      case 'flankerContrast'
         o.flankerContrast=o.thresholdPolarity*10^o.questMean;
   end
   o.EOverN=o.contrast^2*o.E1/o.N;
   o.efficiency=o.idealEOverNThreshold/o.EOverN;
   
   %% QUESTPlus: Estimate steepness and threshold contrast.
   if o.questPlusEnable && isfield(questPlusData,'trialData')
      psiParamsIndex=qpListMaxArg(questPlusData.posterior);
      psiParamsBayesian=questPlusData.psiParamsDomain(psiParamsIndex,:);
      if o.questPlusPrint
         ffprintf(ff,'Quest: Max posterior est. of threshold: log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
            o.questMean,o.steepness,o.guess,o.lapse);
         %          ffprintf(ff,'QuestPlus: Max posterior estimate:      log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
         %             psiParamsBayesian(1)/20,psiParamsBayesian(2),psiParamsBayesian(3),psiParamsBayesian(4));
      end
      psiParamsFit=qpFit(questPlusData.trialData,questPlusData.qpPF,psiParamsBayesian,questPlusData.nOutcomes,...,
         'lowerBounds', [min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],...
         'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
      if o.questPlusPrint
         ffprintf(ff,'QuestPlus: Max likelihood estimate:     log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
            psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
      end
      o.qpContrast=o.thresholdPolarity*10^(psiParamsFit(1)/20);	% threshold contrast
      switch o.thresholdParameter
         case 'contrast'
            o.contrast=o.qpContrast;
         case 'flankerContrast'
            o.flankerContrast=o.qpContrast;
      end
      o.qpSteepness=psiParamsFit(2);          % steepness
      o.qpGuessing=psiParamsFit(3);
      o.qpLapse=psiParamsFit(4);
      %% Plot trial data with maximum likelihood fit
      if o.questPlusPlot
         figure('Name',[o.experiment ':' o.conditionName],'NumberTitle','off');
         title(o.conditionName,'FontSize',14);
         hold on
         stimCounts=qpCounts(qpData(questPlusData.trialData),questPlusData.nOutcomes);
         stim=[stimCounts.stim];
         stimFine=linspace(-40,0,100)';
         plotProportionsFit=qpPFWeibull(stimFine,psiParamsFit);
         for cc=1:length(stimCounts)
            nTrials(cc)=sum(stimCounts(cc).outcomeCounts);
            pCorrect(cc)=stimCounts(cc).outcomeCounts(2)/nTrials(cc);
         end
         legendString=sprintf('%.2f %s',o.noiseSD,o.observer);
         semilogx(10.^(stimFine/20),plotProportionsFit(:,2),'-','Color',[0 0 0],'LineWidth',3,'DisplayName',legendString);
         scatter(10.^(stim/20),pCorrect,100,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',...
            [0 0 0],'MarkerEdgeAlpha',.1,'MarkerFaceAlpha',.1,'DisplayName',legendString);
         set(gca,'xscale','log');
         set(gca,'XTickLabel',{'0.01' '0.1' '1'});
         xlabel('Contrast');
         ylabel('Proportion correct');
         xlim([0.01 1]); ylim([0 1]);
         set(gca,'FontSize',12);
         o.targetCyclesPerDeg=o.targetGaborCycles/o.targetHeightDeg;
         noteString{1}=sprintf('%s: %s %.1f c/deg, ecc %.0f deg, %.1f s\n%.0f cd/m^2, eyes %s, trials %d',...
            o.conditionName,o.targetKind,o.targetCyclesPerDeg,o.eccentricityXYDeg(1),o.targetDurationSec,o.LMean,o.eyes,o.trials);
         noteString{2}=sprintf('%8s %7s %5s %9s %8s %5s','observer','noiseSD','log c','steepness','guessing','lapse');
         noteString{end+1}=sprintf('%-8s %7.2f %5.2f %9.1f %8.2f %5.2f', ...
            o.observer,o.noiseSD,log10(o.qpContrast),o.qpSteepness,o.qpGuessing,o.qpLapse);
         text(0.4,0.4,'noiseSD observer');
         legend('show','Location','southeast');
         legend('boxoff');
         annotation('textbox',[0.14 0.11 .5 .2],'String',noteString,...
            'FitBoxToText','on','LineStyle','none',...
            'FontName','Monospaced','FontSize',9);
         drawnow;
      end % if o.questPlusPlot
   end % if o.questPlusEnable
   
   o.targetDurationSecMean=mean(o.likelyTargetDurationSec,'omitnan');
   o.targetDurationSecSD=std(o.likelyTargetDurationSec,'omitnan');
   ffprintf(ff,['Mean target duration %.3f',plusMinusChar,'%.3f s (sd over %d trials).\n'],o.targetDurationSecMean,o.targetDurationSecSD,length(o.likelyTargetDurationSec));
   ffprintf(ff,'Mean luminance %.1f cd/m^2, which filter reduces to %.2f cd/m^2.\n',LMean,o.luminance);
   
   o.E=10^(2*o.questMean)*o.E1;
   if streq(o.targetModulates,'luminance')
      ffprintf(ff,['Run %4d of %d.  %d trials. %.0f%% right. %.3f s/trial. '...
         'Threshold',plusMinusChar,'sd log contrast %.2f',plusMinusChar,'%.2f, contrast %.4f, log E/N %.2f, efficiency %.5f\n'],...
         o.runNumber,o.runsDesired,trial,100*trialsRight/trial,(GetSecs-runStart)/trial,t,sd,o.thresholdPolarity*10^t,log10(o.EOverN),o.efficiency);
   else
      ffprintf(ff,['Run %4d of %d.  %d trials. %.0f%% right. %.3f s/trial. '...
         'Threshold',plusMinusChar,'sd log(r-1) %.2f',plusMinusChar,'%.2f, approx required n %.0f\n'],...
         o.runNumber,o.runsDesired,trial,100*trialsRight/trial,(GetSecs-runStart)/trial,t,sd,approxRequiredN);
   end
   if abs(trialsRight/trial-o.pThreshold) > 0.1
      ffprintf(ff,'WARNING: Proportion correct is far from threshold criterion. Threshold estimate unreliable.\n');
   end
   % end
   
   %     t=mean(tSample);
   %     tse=std(tSample)/sqrt(length(tSample));
   %     switch o.targetModulates
   %         case 'luminance',
   %         ffprintf(ff,['SUMMARY: %s %d runs mean',plusMinusChar,'se: log(contrast) %.2f',plusMinusChar,'%.2f, contrast %.3f\n'],...
   %             o.observer,length(tSample),mean(tSample),tse,10^mean(tSample));
   %         %         efficiency=(o.idealEOverNThreshold^2) / (10^(2*t));
   %         %         ffprintf(ff,'Efficiency=%f\n', efficiency);
   %         %o.EOverN=10^mean(2*tSample)*o.E1/o.N;
   %         ffprintf(ff,['Threshold log E/N %.2f',plusMinusChar,'%.2f, E/N %.1f\n'],mean(log10(o.EOverN)),std(log10(o.EOverN))/sqrt(length(o.EOverN)),o.EOverN);
   %         %o.efficiency=o.idealEOverNThreshold/o.EOverN;
   %         ffprintf(ff,'User-provided ideal threshold E/N log E/N %.2f, E/N %.1f\n',log10(o.idealEOverNThreshold),o.idealEOverNThreshold);
   %         ffprintf(ff,['Efficiency log %.2f',plusMinusChar,'%.2f, %.4f %%\n'],mean(log10(o.efficiency)),std(log10(o.efficiency))/sqrt(length(o.efficiency)),100*10^mean(log10(o.efficiency)));
   %         corr=zeros(length(signal));
   %         for i=1:length(signal)
   %             for j=1:i
   %                 cii=sum(signal(i).image(:).*signal(i).image(:));
   %                 cjj=sum(signal(j).image(:).*signal(j).image(:));
   %                 cij=sum(signal(i).image(:).*signal(j).image(:));
   %                 corr(i,j)=cij/sqrt(cjj*cii);
   %                 corr(j,i)=corr(i,j);
   %             end
   %         end
   %         [iGrid,jGrid]=meshgrid(1:length(signal),1:length(signal));
   %         offDiagonal=iGrid~=jGrid;
   %         o.signalCorrelation=mean(corr(offDiagonal));
   %         ffprintf(ff,'Average cross-correlation %.2f\n',o.signalCorrelation);
   %         approximateIdealEOverN=(-1.189+4.757*log10(length(signal)))/(1-o.signalCorrelation);
   %         %         err=0.0372;
   %         %         minEst=(-1.189+4.757*log10(length(signal)-err))/(1-o.signalCorrelation);
   %         %         maxEst=(-1.189+4.757*log10(length(signal)+err))/(1-o.signalCorrelation);
   %         %         logErr=log10(max(maxEst/estimatedIdealEOverN,estimatedIdealEOverN/minEst));
   %         ffprintf(ff,'Approximation, assuming pThreshold=0.64, predicts ideal threshold is about log E/N %.2f, E/N %.1f\n',log10(approximateIdealEOverN),approximateIdealEOverN);
   %         ffprintf(ff,'The approximation is Eq. A.24 of Pelli et al. (2006) Vision Research 46:4646-4674.\n');
   switch o.targetModulates
      case 'noise'
         t=o.questMean;
         o.r=10^t+1;
         o.approxRequiredNumber=64./10.^((t-idealT64)/0.55);
         o.logApproxRequiredNumber=log10(o.approxRequiredNumber);
         ffprintf(ff,'r %.3f, approx required number %.0f\n',o.r,o.approxRequiredNumber);
         %              logNse=std(logApproxRequiredNumber)/sqrt(length(tSample));
         %              ffprintf(ff,['SUMMARY: %s %d runs mean',plusMinusChar,'se: log(r-1) %.2f',plusMinusChar,'%.2f, log(approx required n) %.2f',plusMinusChar,'%.2f\n'],...
         % o.observer,length(tSample),mean(tSample),tse,logApproxRequiredNumber,logNse);
      case 'entropy'
         t=o.questMean;
         o.r=10^t+1;
         signalEntropyLevels=o.r*o.backgroundEntropyLevels;
         ffprintf(ff,'Entropy levels: r %.2f, background levels %d, signal levels %.1f\n',o.r,o.backgroundEntropyLevels,signalEntropyLevels);
   end
   switch o.targetModulates
      case 'entropy'
         if ~isempty(o.psych)
            ffprintf(ff,'t\tr\tlevels\tbits\tright\ttrials\t%%\n');
            o.psych.levels=o.psych.r*o.backgroundEntropyLevels;
            for i=1:length(o.psych.t)
               ffprintf(ff,'%.2f\t%.2f\t%.0f\t%.1f\t%d\t%d\t%.0f\n',o.psych.t(i),o.psych.r(i),o.psych.levels(i),log2(o.psych.levels(i)),o.psych.right(i),o.psych.trials(i),100*o.psych.right(i)/o.psych.trials(i));
            end
         end
   end
   if o.speakInstructions
      if o.quitSession && ~ismember(o.observer,algorithmicObservers)
         Speak('QUITTING now. Done.');
      else
         if ~o.quitRun && o.runNumber == o.runsDesired && o.congratulateWhenDone && ~ismember(o.observer,algorithmicObservers)
            Speak('Congratulations. End of run.');
         end
      end
   end
   if Screen(window,'WindowKind') == 1
      % Screen takes many seconds to close. This gives us a white screen
      % while we wait.
      Screen('FillRect',window);
      Screen('Flip',window); % White screen
   end
   ListenChar(0); % flush
   ListenChar;
   sca; % Screen('CloseAll'); ShowCursor;
   % This applescript "activate" command provokes a screen refresh (by
   % selecting MATLAB). My computers each have only one display, upon which
   % my MATLAB programs open a Psychtoolbox window. This applescript
   % eliminates an annoyingly long pause at the end of my Psychtoolbox
   % programs running under MATLAB 2014a, when returning to the MATLAB
   % command window after twice opening and closing Screen windows. Without
   % this command, when I return to MATLAB, the whole screen remains blank
   % for a long time, maybe 30 s, or until I click something, so I can't
   % tell that I'm back in MATLAB. This applescript command provokes a
   % screen refresh, so the MATLAB editor appears immediately. Among
   % several computers, the problem is always present in MATLAB 2014a and
   % never in MATLAB 2015a. (All computers are running Mavericks.)
   % denis.pelli@nyu.edu, June 18, 2015
   if ismac
      status=system('osascript -e ''tell application "MATLAB" to activate''');
   end
   RestoreCluts;
   if ismac
      AutoBrightness(cal.screen,1); % Restore autobrightness.
   end
   if window >= 0
      Screen('Preference','VisualDebugLevel',oldVisualDebugLevel);
      Screen('Preference','SuppressAllWarnings',oldSupressAllWarnings);
   end
   fclose(dataFid); dataFid=-1;
   o.signal=signal; % worth saving
   %     o.q=q; % not worth saving
   o.newCal=cal;
   [~,neworder]=sort(lower(fieldnames(o)));
   o=orderfields(o,neworder);
   save(fullfile(o.dataFolder,[o.dataFilename '.mat']),'o','cal');
   try % save to .json file
      if exist('jsonencode','builtin')
         json=jsonencode(o);
      else
         addpath(fullfile(fileparts(mfilename('fullpath')),'lib/jsonlab')); 
         json=savejson('',o);
      end
      fid=fopen(fullfile(o.dataFolder,[o.dataFilename '.json']),'w');
      fprintf(fid,'%s',json);
      fclose(fid);
   catch e
      warning('Failed to save .json file.');
      e.stack(end)
      warning(e.message);
   end % save to .json file
   try % save to .csv file
      transcript=o.transcript;
      f=fieldnames(transcript);
      for i=1:length(f)
         % turn row into column
         transcript.(f{i})=transcript.(f{i})';
      end
      t=struct2table(transcript,'AsArray',false);
      writetable(t,fullfile(o.dataFolder,[o.dataFilename '.transcript.csv']));
   catch e
      warning('Failed to save .transcript.csv file.');
      o.transcript
      e.stack(end)
      warning(e.message);
   end % save to .csv fil
   fprintf('Results saved in %s with extensions .txt, .mat, .json, and .transcript.csv \nin folder %s\n',o.dataFilename,o.dataFolder);
   Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
   oOld=o;
   oOld.secs=GetSecs; % Date for staleness.
catch e
   %% MATLAB catch
   ListenChar;
   sca; % screen close all
   if exist('cal','var') && isfield(cal,'old') && isfield(cal.old,'gamma')
      Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
   end
   AutoBrightness(cal.screen,1); % Restore autobrightness.
   if dataFid>-1
      fclose(dataFid);
      dataFid=-1;
   end
   [~,neworder]=sort(lower(fieldnames(o)));
   o=orderfields(o,neworder);
   rethrow(e);
end
end % function o=NoiseDiscrimination(o)
%% FUNCTION SaveSnapshot
function SaveSnapshot(o)
global window fixationLines fixationCrossWeightPix labelBounds location screenRect ...
   tTest idealT64 leftEdgeOfResponse checks img cal ff whichSignal dataFid
% Hasn't been tested since it became a subroutine. It may need more of its
% variables to be declared "global". A more elegant solution, more
% transparent that "global" would be to put all the currently global
% variables into a new struct called "my". It would be received as an
% argument and might need to be returned as an output. Note that if "o" is
% modified here, it too may need to be returned as an output argument, or
% made global.
if o.snapshotShowsFixationAfter && ~isempty(fixationLines)
   Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
end
if o.cropSnapshot
   if o.showResponseNumbers
      cropRect=labelBounds;
   else
      cropRect=location(1).rect;
      if streq(o.task,'4afc')
         for i=2:4
            cropRect=UnionRect(cropRect,location(i).rect);
         end
      end
   end
else
   cropRect=screenRect;
end
approxRequiredN=64/10^((tTest-idealT64)/0.55);
rect=Screen('TextBounds',window,'approx required n 0000');
r=screenRect;
r(3)=leftEdgeOfResponse;
r=InsetRect(r,o.textSize/2,o.textSize/2);
rect=AlignRect(rect,r,RectRight,RectBottom);
if streq(o.task,'4afc')
   clear x
   for i=1:4
      img=location(i).image;
      x(i).mean=mean(img(:));
      x(i).sd=std(img(:));
      x(i).max=max(img(:));
      x(i).min=min(img(:));
      x(i).L=unique(img(:));
      x(i).p=x(i).L;
      total=length(img(:));
      for j=1:length(x(i).L)
         x(i).p(j)=length(find(img(:) == x(i).L(j)))/total;
      end
      x(i).entropy=sum(-x(i).p.*log2(x(i).p));
   end
   saveSize=Screen('TextSize',window,round(o.textSize*.4));
   saveFont=Screen('TextFont',window,'Courier');
   for i=1:4
      s=[sprintf('L%d',i) sprintf(' %4.2f',x(i).L)];
      Screen('DrawText',window,s,rect(1),rect(2)-360-(5-i)*30);
   end
   for i=1:4
      s=[sprintf('p%d',i) sprintf(' %4.2f',x(i).p)];
      Screen('DrawText',window,s,rect(1),rect(2)-240-(5-i)*30);
   end
   Screen('TextSize',window,round(o.textSize*.8));
   Screen('DrawText',window,sprintf('Mean %4.2f %4.2f %4.2f %4.2f',x(:).mean),rect(1),rect(2)-240);
   Screen('DrawText',window,sprintf('Sd   %4.2f %4.2f %4.2f %4.2f',x(:).sd),rect(1),rect(2)-210);
   Screen('DrawText',window,sprintf('Max  %4.2f %4.2f %4.2f %4.2f',x(:).max),rect(1),rect(2)-180);
   Screen('DrawText',window,sprintf('Min  %4.2f %4.2f %4.2f %4.2f',x(:).min),rect(1),rect(2)-150);
   Screen('DrawText',window,sprintf('Bits %4.2f %4.2f %4.2f %4.2f',x(:).entropy),rect(1),rect(2)-120);
   Screen('TextSize',window,saveSize);
   Screen('TextFont',window,saveFont);
end
o.snapshotCaptionTextSize=ceil(o.snapshotCaptionTextSizeDeg*o.pixPerDeg);
saveSize=Screen('TextSize',window,o.snapshotCaptionTextSize);
saveFont=Screen('TextFont',window,'Courier');
caption={''};
switch o.targetModulates
   case 'luminance'
      caption{1}=sprintf('signal %.3f',o.thresholdPolarity*10^tTest);
      caption{2}=sprintf('noise sd %.3f',o.noiseSD);
   case 'noise'
      caption{1}=sprintf('noise sd %.3f',o.noiseSD);
      caption{end+1}=sprintf('n %.0f',checks);
   case 'entropy'
      caption{1}=sprintf('ratio # lum. %.3f',1+10^tTest);
      caption{2}=sprintf('noise sd %.3f',o.noiseSD);
      caption{end+1}=sprintf('n %.0f',checks);
   otherwise
      caption{1}=sprintf('sd ratio %.3f',1+10^tTest);
      caption{2}=sprintf('approx required n %.0f',approxRequiredN);
end
switch o.task
   case '4afc'
      answer=signalLocation;
      answerString=sprintf('%d',answer);
      caption{end+1}=sprintf('xyz%s',lower(answerString));
   case 'identify'
      answer=whichSignal;
      answerString=o.alphabet(answer);
      caption{end+1}=sprintf('xyz%s',lower(answerString));
end
rect=OffsetRect(o.stimulusRect,-o.snapshotCaptionTextSize/2,0);
for i=length(caption):- 1:1
   r=Screen('TextBounds',window,caption{i});
   r=AlignRect(r,rect,RectRight,RectBottom);
   Screen('DrawText',window,caption{i},r(1),r(2));
   rect=OffsetRect(r,0,-o.snapshotCaptionTextSize);
end
Screen('TextSize',window,saveSize);
Screen('TextFont',window,saveFont);
Screen('Flip',window,0,1); % Save image for snapshot. Show target, instructions, and fixation.
img=Screen('GetImage',window,cropRect);
%                         grayPixels=img==gray;
%                         img(grayPixels)=128;
freezing='';
if o.noiseFrozenInTrial
   freezing='_frozenInTrial';
end
if o.noiseFrozenInRun
   freezing=[freezing '_frozenInRun'];
end
switch o.targetModulates
   case 'entropy'
      signalDescription=sprintf('%s_%dv%dlevels',o.targetModulates,signalEntropyLevels,o.backgroundEntropyLevels);
   otherwise
      signalDescription=sprintf('%s',o.targetModulates);
end
switch o.targetModulates
   case 'luminance'
      filename=sprintf('%s_%s_%s%s_%.3fc_%.0fpix_%s',signalDescription,o.task,o.noiseType,freezing,o.thresholdPolarity*10^tTest,checks,answerString);
   case {'noise', 'entropy'}
      filename=sprintf('%s_%s_%s%s_%.3fr_%.0fpix_%.0freq_%s',signalDescription,o.task,o.noiseType,freezing,1+10^tTest,checks,approxRequiredN,answerString);
end
mypath=fileparts(mfilename('fullpath'));
saveSnapshotFid=fopen(fullfile(mypath,[filename '.png']),'rt');
if saveSnapshotFid ~= -1
   for suffix='a':'z'
      saveSnapshotFid=fopen(fullfile(mypath,[filename suffix '.png']),'rt');
      if saveSnapshotFid == -1
         filename=[filename suffix];
         break
      end
   end
   if saveSnapshotFid ~= -1
      error('Can''t save file. Already 26 files with that name plus a-z');
   end
end
filename=[filename '.png'];
imwrite(img,fullfile(mypath,filename),'png');
ffprintf(ff,'Saving image to file "%s" ',filename);
switch o.targetModulates
   case 'luminance'
      ffprintf(ff,'log(contrast) %.2f\n',tTest);
   case 'noise'
      ffprintf(ff,'approx required n %.0f, sd ratio r %.3f, log(r-1) %.2f\n',approxRequiredN,1+10^tTest,tTest);
   case 'entropy'
      ffprintf(ff,'ratio r=signalLevels/backgroundLevels %.3f, log(r-1) %.2f\n',1+10^tTest,tTest);
end
o.trialsPerRun=1;
o.runsDesired=1;
ffprintf(ff,'SUCCESS: o.saveSnapshot is done. Image saved, now returning.\n');
fclose(dataFid);
dataFid=-1;
sca; % screen close all
ListenChar;
AutoBrightness(cal.screen,1); % Restore autobrightness.
return;
end % function SaveSnapshot
%% FUNCTION assessBitDepth
function assessBitDepth(o)
% Display a linear luminance ramp. Alternate at 1 Hz, with something that
% is bit-limited. Hasn't been tested since it became a subroutine. It may
% need more of its variables to be declared "global". A more elegant
% solution, more transparent than "global", would be to put all the
% currently global variables into a new struct called "my". It would be
% received as an argument and might need to be returned as an output. Note
% that if "o" is modified here, it too may need to be returned as an output
% argument, or made global.
% n=o.assessBitDepth.
global cal
LMin=min(cal.old.L);
LMax=max(cal.old.L);
LMean=(LMax+LMin)/2;
cal.LFirst=LMin;
cal.LLast=LMean+(LMean-LMin); % Symmetric about LMean.
cal.nFirst=firstGrayClutEntry;
cal.nLast=lastGrayClutEntry;
cal=LinearizeClut(cal);
img=cal.nFirst:cal.nLast;
n=floor(RectWidth(screenRect)/length(img));
r=[0 0 n*length(img) RectHeight(screenRect)];
Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
if o.assessLoadGamma
   ffprintf(ff,'Line %d: o.contrast %.3f, LoadNormalizedGammaTable 0.5*range/mean=%.3f\n', ...
      MFileLineNr,o.contrast,(cal.LLast-cal.LFirst)/(cal.LLast+cal.LFirst));
end
Screen('TextFont',window,'Verdana');
Screen('TextSize',window,24);
for bits=1:11
   % WARNING: Mario advises against using PutImage, which is retained in
   % Psychtoolbox solely for backward compatibility. As of May 31, 2017,
   % it's not compatible with high-res color, but that may be fixed in the
   % next release.
   Screen('PutImage',window,img,r);
   %               msg=sprintf('o.assessBitDepth: Now alternating with quantization to %d bits. Hit SPACE bar to continue.',bits);
   %               newGamma=floor(cal.gamma*(2^bits-1))/(2^bits-1);
   msg=sprintf(' Now alternately clearing video DAC bit %d. Hit SPACE bar to continue. ',bits);
   newGamma=bitset(round(cal.gamma*(2^17-1)),17-bits,0)/(2^17-1);
   Screen('DrawText',window,' o.assessBitDepth: Testing bits 1 to 11. ',100,100,0,1,1);
   Screen('DrawText',window,msg,100,136,0,1,1);
   Screen('Flip',window);
   ListenChar(0); % Flush. May not be needed.
   ListenChar(2); % No echo. Needed.
   while CharAvail
      GetChar;
   end
   while ~CharAvail
      Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
      Screen('Flip',window);
      WaitSecs(0.2);
      Screen('LoadNormalizedGammaTable',window,newGamma,loadOnNextFlip);
      Screen('Flip',window);
      WaitSecs(0.2);
   end
   Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
   GetChar;
   ListenChar; % Back to normal. Needed.
end
if o.speakInstructions
   Speak('Done');
end
end % function assessBitDepth
%% FUNCTION MeasureContrast
function oOut=MeasureContrast(o,line)
global window cal ff trial
LMean=(cal.LLast+cal.LFirst)/2;
fprintf('%d: LFirst %.1f, LMean %.1f, LLast %.1f cd/m^2\n',line,cal.LFirst,LMean,cal.LLast);
% Measure signal luminance L
index=IndexOfLuminance(cal,(1+o.contrast)*LMean);
Screen('FillRect',window,index/o.maxEntry,o.stimulusRect);
Screen('Flip',window,0,1);
if o.usePhotometer
   L=GetLuminance;
else
   L=LMean*2*round(o.maxEntry*(1+o.contrast)/2)/o.maxEntry;
end
% Measure background luminance L0
index0=IndexOfLuminance(cal,LMean);
Screen('FillRect',window,index0/o.maxEntry,o.stimulusRect);
Screen('Flip',window,0,1);
if o.usePhotometer
   L0=GetLuminance;
else
   L0=LMean;
end
% Compute contrast
actualContrast=(L-L0)/L0;
estimatedContrast=(LuminanceOfIndex(cal,index)-LuminanceOfIndex(cal,index0))/LuminanceOfIndex(cal,index0);
ffprintf(ff,'%d: Contrast nominal %.4f, est. %.4f, actual %.4f; Luminance %.2f %.2f; G %.4f %.4f\n',...
   line,o.contrast,estimatedContrast,actualContrast,L,L0,cal.gamma(round(index)+1,2),cal.gamma(round(index0)+1,2));
o.nominalContrast(trial)=o.contrast;
o.actualContrast(trial)=actualContrast;
oOut=o;
end % MeasureContrast
%% FUNCTION AssessContrast
function AssessContrast(o)
% Estimate actual contrast on screen.
% Reports by ffprintf. Returns nothing.
global img cal ff
LMean=(cal.LFirst+cal.LLast)/2;
img=IndexOfLuminance(cal,LMean);
img=img:o.maxEntry;
L=EstimateLuminance(cal,img);
dL=diff(L);
i=find(dL,1); % index of first non-zero element in dL
if isfinite(i)
   contrastEstimate=dL(i)/L(i); % contrast of minimal increase near LMean
else
   contrastEstimate=nan;
end
switch o.targetModulates
   case 'luminance'
      img=[1 1+o.contrast];
   otherwise
      noise=PsychRandSample(noiseList,o.canvasSize*o.targetCheckPix/o.noiseCheckPix);
      noise=Expand(noise,o.noiseCheckPix/o.targetCheckPix);
      img=1+noise*o.noiseSD/o.noiseListSd;
end
index=IndexOfLuminance(cal,img*LMean);
imgEstimate=EstimateLuminance(cal,index)/LMean;
rmsContrastError=rms(img(:)-imgEstimate(:));
% ffprintf(ff,'Assess contrast: At LMean, the minimum contrast step is %.4f, with rmsContrastError %.3f\n',contrastEstimate,rmsContrastError);
switch o.targetModulates
   case 'luminance'
      img=[1, 1+o.contrast];
      img=IndexOfLuminance(cal,img*LMean);
      L=EstimateLuminance(cal,img);
      ffprintf(ff,'Assess contrast: Desired o.contrast of %.3f will be rendered as %.3f (estimated).\n',o.contrast,diff(L)/L(1));
   otherwise
      noiseSDEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:));
      img=1+r*(o.noiseSD/o.noiseListSd)*noise;
      img=IndexOfLuminance(cal,img*LMean);
      imgEstimate=EstimateLuminance(cal,img)/LMean;
      rEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:))/noiseSDEstimate;
      ffprintf(ff,'noiseSDEstimate %.3f (nom. %.3f), rEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,rEstimate,r);
      if abs(log10([noiseSDEstimate/o.noiseSD rEstimate/r])) > 0.5*log10(2)
         ffprintf(ff,'WARNING: PLEASE TELL DENIS: noiseSDEstimate %.3f (nom. %.3f), rEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,rEstimate,r);
      end
end
end % function AssessContrast
%% FUNCTION AssessLinearity
function AssessLinearity(o)
% Hasn't been tested since it became a subroutine. It may need more of its
% variables to be declared "global". A more elegant solution, more
% transparent that "global" would be to put all the currently global
% variables into a new struct called "my". It would be received as an
% argument and might need to be returned as an output. Note that if "o" is
% modified here, it too may need to be returned as an output argument, or
% made global.fprintf('Assess linearity.\n');
gratingL=LMean*repmat([0.2 1.8],400,200); % 400x400 grating
gratingImg=IndexOfLuminance(cal,gratingL);
texture=Screen('MakeTexture',window,gratingImg/o.maxEntry,0,0,1);
r=RectOfMatrix(gratingImg);
r=CenterRect(r,o.stimulusRect);
Screen('DrawTexture',window,texture,RectOfMatrix(gratingImg),r);
peekImg=Screen('GetImage',window,r,'drawBuffer');
Screen('Close',texture);
peekImg=peekImg(:,:,2);
figure(1);
subplot(2,2,1); imshow(uint8(gratingImg)); title('image written');
subplot(2,2,2); imshow(peekImg); title('image read');
subplot(2,2,3); imshow(uint8(gratingImg(1:4,1:4))); title('4x4 of image written')
subplot(2,2,4); imshow(peekImg(1:4,1:4)); title('4x4 of image read');
fprintf('desired normalized luminance: %.1f %.1f\n',gratingL(1,1:2)/LMean);
fprintf('grating written: %.1f %.1f\n',gratingImg(1,1:2));
fprintf('grating read: %.1f %.1f\n',peekImg(1,1:2));
fprintf('normalized luminance: %.1f %.1f\n',LuminanceOfIndex(cal,peekImg(1,1:2))/LMean);
end % function AssessLinearity(o)
%% FUNCTION ModelObserver
function response=ModelObserver(o)
% Hasn't been tested since it became a subroutine. It may need more of its
% variables to be declared "global". A more elegant solution, more
% transparent that "global", would be to put all the currently global
% variables into a new struct called "my". It would be received as an
% argument and might need to be returned as an output. Note that if "o" is
% modified here, it too may need to be returned as an output argument, or
% made global.
switch o.observer
   case 'ideal'
      clear likely
      switch o.task
         case '4afc'
            switch o.targetModulates
               case 'luminance'
                  % pick darkest
                  for i=1:locations
                     im=location(i).image(signalImageIndex);
                     likely(i)=-sum((im(:)-1));
                  end
               otherwise
                  % The maximum likelihood choice is the one with
                  % greatest power.
                  for i=1:locations
                     im=location(i).image(signalImageIndex);
                     likely(i)=sum((im(:)-1).^2);
                     if o.printLikelihood
                        im=im(:)-1;
                        im
                     end
                  end
                  if o.printLikelihood
                     likely
                     signalLocation
                  end
            end
         case 'identify'
            switch o.targetModulates
               case 'luminance'
                  for i=1:o.alternatives
                     im=zeros(size(signal(i).image));
                     im(:)=location(1).image(signalImageIndex); % here be the signal
                     d=im-1-o.contrast*signal(i).image;
                     likely(i)=-sum(d(:).^2);
                  end
               otherwise
                  % calculate log likelihood of each possible letter
                  sdPaper=o.noiseSD;
                  sdInk=r*o.noiseSD;
                  for i=1:o.alternatives
                     signalMask=signal(i).image;
                     im=zeros(size(signal(i).image));
                     im(:)=location(1).image(signalImageIndex);
                     ink=im(signalMask)-1;
                     paper=im(~signalMask)-1;
                     likely(i)=-length(ink)*log(sdInk*sqrt(2*pi))-sum(0.5*(ink/sdInk).^2);
                     likely(i)=likely(i)-length(paper)*log(sdPaper*sqrt(2*pi))-sum(0.5*(paper/sdPaper).^2);
                     save buggy
                  end
            end
      end % switch o.task
      [~, response]=max(likely);
      if o.printLikelihood
         response
      end
   case 'brightnessSeeker'
      clear likely
      switch o.task
         case '4afc'
            % Rank by brightness.
            % Assume brightness is
            % (image-1)+o.observerQuadratic*(image-1)^2
            % Pelli ms on irradiation defines the
            % nonlinearity S(C), where C=image-1.
            % S'=1+o.observerQuadratic*2*(image-1)
            % S"=o.observerQuadratic*2
            % S'(0)=1; S"(0)=o.observerQuadratic*2;
            % The paper defines
            % k=(-1/4) S"(0)/S'(0)
            % =-0.25*o.observerQuadratic*2
            %   =-0.5*o.observerQuadratic
            % So
            % o.observerQuadratic=-2*k.
            % The paper finds k=0.6, so
            % o.observerQuadratic=-1.2
            for i=1:locations
               im=location(i).image(signalImageIndex);
               im=im(:)-1;
               brightness=im+o.observerQuadratic*im.^2;
               likely(i)=sign(o.observerQuadratic)*mean(brightness(:));
            end
         case 'identify'
            % Rank hypotheses by brightness contrast of
            % supposed letter to background.
            for i=1:o.alternatives
               signalMask=signal(i).image;
               im=location(1).image(signalImageIndex);
               im=im(:)-1;
               % Set o.observerQuadratic  to 0 for linear. 1 for square law. 0.2 for
               % 0.8 linear and 0.2 square.
               brightness=im+o.observerQuadratic*im.^2;
               ink=brightness(signalMask);
               paper=brightness(~signalMask);
               likely(i)=sign(o.observerQuadratic)*(mean(ink(:))-mean(paper(:)));
            end
      end
      [~, response]=max(likely);
   case 'blackshot'
      clear likely
      % Michelle Qiu digitized Fig. 6, observer CC, of Chubb et al. (2004).
      % c is the contrast, defined as luminance minus mean luminance
      % divided by mean luminance. b is the response of the blackshot
      % mechanism.
      c=[-1 -0.878 -0.748 -0.637 -0.508 -0.366 -0.248 -0.141 0.0992 0.214 0.324 0.412 0.523 0.634 0.767 0.878 1];
      b=[0.102 0.749 0.944 0.945 0.921 0.909 0.91 0.907 0.905 0.905 0.906 0.915 0.912 0.906 0.886 0.868 0.932];
      switch o.task
         case '4afc'
            % Rank by blackshot mechanism defined by Chubb et al. (2004).
            for i=1:locations
               im=location(i).image(signalImageIndex);
               assert(all(im(:) >= 0) && all(im(:) <= 2))
               im=im(:)-1;
               blackshot=interp1(c,b,im);
               likely(i)=-mean(blackshot(:));
               if o.printLikelihood
                  im
                  blackshot
               end
            end
            if o.printLikelihood
               likely
               signalLocation
            end
         case 'identify'
            % Rank hypotheses by blackshot contrast of
            % supposed letter to background.
            for i=1:o.alternatives
               signalMask=signal(i).image;
               im=location(1).image(signalImageIndex);
               assert(all(im(:) >= 0) && all(im(:) <= 2))
               im=im(:)-1;
               blackshot=interp1(c,b,im);
               ink=blackshot(signalMask);
               paper=blackshot(~signalMask);
               likely(i)=-mean(ink(:))+mean(paper(:));
            end
      end
      [~, response]=max(likely);
      if o.printLikelihood
         response
      end
   case 'maximum'
      clear likely
      switch o.task
         case '4afc'
            % Rank by maximum pixel.
            for i=1:locations
               im=location(i).image(signalImageIndex);
               im=im(:)-1;
               likely(i)=max(im(:));
            end
         case 'identify'
            error('maximum o.observer not yet implemented for "identify" task');
            % Rank hypotheses by contrast of supposed letter to
            % background.
            for i=1:o.alternatives
               signalMask=signal(i).image;
               im=zeros(size(signal(i).image));
               im(:)=location(1).image(signalImageIndex);
               im=im(:)-1;
               % Set o.observerQuadratic to 0 for linear; 1 for square
               % law; 0.2 for 0.8 linear+0.2 square.
               brightness=im+o.observerQuadratic*im.^2;
               ink=brightness(signalMask);
               paper=brightness(~signalMask);
               likely(i)=sign(o.observerQuadratic)*(mean(ink(:))-mean(paper(:)));
            end
      end
      [~,response]=max(likely);
   otherwise % human o.observer
      % Only human observers requires stimulus presentation.
end % switch
end % function ModelObserver(o)

function xyPix=XYPixOfXYDeg(o,xyDeg)
% Convert position from deg (relative to fixation) to (x,y) coordinate in
% o.stimulusRect. Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. "location" refers to the near point. We typically put the target
% there, but that is not assumed in this routine.
xyDeg=xyDeg-o.nearPointXYDeg;
rDeg=sqrt(sum(xyDeg.^2));
rPix=o.pixPerCm*o.viewingDistanceCm*tand(rDeg);
if rDeg>0
   xyPix=xyDeg*rPix/rDeg;
   xyPix(2)=-xyPix(2); % Apple y goes down.
else
   xyPix=[0 0];
end
xyPix=xyPix+o.nearPointXYPix;
end

% THIS FUNCTION IS CURRENTLY UNUSED.
function xyDeg=XYDegOfXYPix(o,xyPix)
% Convert position from (x,y) coordinate in o.stimulusRect to deg (relative
% to fixation). Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. We typically put the target at the near point, but that is not
% assumed in this routine.
xyPix=xyPix-o.nearPointXYPix;
rPix=sqrt(sum(xyPix.^2));
rDeg=atan2d(rPix/o.pixPerCm,o.viewingDistanceCm);
if rPix>0
   xyPix(2)=-xyPix(2); % Apple y goes down.
   xyDeg=xyPix*rDeg/rPix;
else
   xyDeg=[0 0];
end
xyDeg=xyDeg+o.nearPointXYDeg;
end

function isTrue=IsXYInRect(xy,rect)
if nargin~=2
   error('Need two args for function isTrue=IsXYInRect(xy,rect)');
end
if ~all(size(xy)==[1 2])
   error('First arg to IsXYInRect(xy,rect) must be [x y] pair.');
end
isTrue=IsInRect(xy(1),xy(2),rect);
end

function xy=LimitXYToRect(xy,rect)
% Restrict x and y to lie inside rect.
assert(all(rect(1:2)<=rect(3:4)));
xy=max(xy,rect(1:2));
xy=min(xy,rect(3:4));
end

%% SET UP NEAR POINT at correct slant and viewing distance.
function o=SetUpNearPoint(window,o)
black=0; % Retrieves the CLUT color code for black.
white=1; % Retrieves the CLUT color code for white.
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
if ~all(isfinite(o.eccentricityXYDeg))
   error('o.eccentricityXYDeg (%.1f %.1f) must be finite. o.useFixation %s is optional.',...
      o.eccentricityXYDeg,mat2str(o.useFixation));
end
if ~IsXYInRect(o.nearPointXYInUnitSquare,[0 0 1 1])
   error('o.nearPointXYInUnitSquare (%.2f %.2f) must be in unit square [0 0 1 1].',o.nearPointXYInUnitSquare);
end
xy=o.nearPointXYInUnitSquare;
xy(2)=1-xy(2); % Move origin from lower left to upper left.
o.nearPointXYPix=xy.*[RectWidth(o.stimulusRect) RectHeight(o.stimulusRect)];
o.nearPointXYPix=o.nearPointXYPix+o.stimulusRect(1:2);
% o.nearPointXYPix is screen coordinate.
% Require margin between target and edge of stimulusRect.
r=InsetRect(o.stimulusRect,(0.5+o.targetMargin)*o.targetHeightDeg*o.pixPerDeg,0.6*o.targetHeightDeg*o.pixPerDeg);
if ~all(r(1:2)<=r(3:4))
   error('%.1f o.targetHeightDeg too big to fit (with %.2f o.targetMargin) in %.1f x %.1f deg screen. Reduce viewing distance or target size.',...
      o.targetHeightDeg,o.targetMargin,[RectWidth(o.stimulusRect) RectHeight(o.stimulusRect)]/o.pixPerDeg);
end
if ~IsXYInRect(o.nearPointXYPix,r)
   % Adjust position of near point so target fits on screen.
   o.nearPointXYPix=LimitXYToRect(o.nearPointXYPix,r);
   % Update o.nearPointXYInUnitSquare.
   xy=o.nearPointXYPix;
   xy=xy-o.stimulusRect(1:2);
   xy=xy./[RectWidth(o.stimulusRect) RectHeight(o.stimulusRect)];
   xy(2)=1-xy(2);
   ffprintf(ff,'NOTE: Adjusting o.nearPointXYInUnitSquare from [%.2f %.2f] to [%.2f %.2f] to fit %.1f deg target (with %.2f o.targetMargin) on screen.',...
      o.nearPointXYInUnitSquare,xy,o.targetHeightDeg,o.targetMargin);
   o.nearPointXYInUnitSquare=xy;
end
string=sprintf('Please adjust the viewing distance so the cross is %.1f cm from the observer''s eye. ',o.viewingDistanceCm);
string=[string 'Tilt and swivel the display so the cross is orthogonal to the line of sight. Then hit RETURN to continue.\n'];
Screen('TextSize',window,o.textSize);
Screen('TextFont',window,'Verdana');
Screen('FillRect',window,o.gray1);
Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
DrawFormattedText(window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
x=o.nearPointXYPix(1);
y=o.nearPointXYPix(2);
a=0.1*RectHeight(o.stimulusRect);
Screen('DrawLine',window,black,x-a,y,x+a,y,a/20);
Screen('DrawLine',window,black,x,y-a,x,y+a,a/20);
Screen('Flip',window); % Display request.
if o.speakInstructions
   string=strrep(string,'.0','');
   string=strrep(string,'\n','');
   Speak(string);
end
response=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode]);
if ismember(response,[escapeChar,graveAccentChar])
   if o.speakInstructions
      Speak('Quitting.');
   end
   o.quitRun=true;
   o.quitSession=true;
   sca;
   ListenChar;
   return
end
Screen('FillRect',window,o.gray1);
Screen('Flip',window); % Blank, to acknowledge response.
end

%% SET UP FIXATION
function o=SetUpFixation(window,o,ff)
black=BlackIndex(window); % Retrieves the CLUT color code for black.
white=WhiteIndex(window); % Retrieves the CLUT color code for white.
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
o.fixationXYPix=round(XYPixOfXYDeg(o,[0 0]));
if ~o.useFixation
   o.fixationIsOffscreen=false;
else
   if ~IsXYInRect(o.fixationXYPix,o.stimulusRect)
      o.fixationIsOffscreen=true;
      % o.fixationXYPix is in plane of display. Off-screen fixation is
      % not! It is the same distance from the eye as the near point.
      % fixationOffsetXYCm is vector from near point to fixation.
      rDeg=sqrt(sum(o.nearPointXYDeg.^2));
      ori=atan2d(-o.nearPointXYDeg(2),-o.nearPointXYDeg(1));
      rCm=2*sind(0.5*rDeg)*o.viewingDistanceCm;
      fixationOffsetXYCm=[cosd(ori) sind(ori)]*rCm;
      if true
         % check
         oriCheck=atan2d(fixationOffsetXYCm(2),fixationOffsetXYCm(1));
         rCmCheck=sqrt(sum(fixationOffsetXYCm.^2));
         rDegCheck=2*asind(0.5*rCm/o.viewingDistanceCm);
         xyDegCheck=[cosd(ori) sind(ori)]*rDeg;
         fprintf('OFFSCREEN GEOMETRY: ori %.1f %.1f; rCm %.1f %.1f; rDeg %.1f %.1f; xyDeg [%.1f %.1f] [%.1f %.1f]\n',...
            ori,oriCheck,rCm,rCmCheck,rDeg,rDegCheck,-o.nearPointXYDeg,xyDegCheck);
      end
      fixationOffsetXYCm(2)=-fixationOffsetXYCm(2); % Make y increase upward.
      
      string='Please set up a fixation mark';
      if fixationOffsetXYCm(1)~=0
         if fixationOffsetXYCm(1) < 0
            string=sprintf('%s %.1f cm to the left of',string,-fixationOffsetXYCm(1));
         else
            string=sprintf('%s %.1f cm to the right of',string,fixationOffsetXYCm(1));
         end
      end
      if fixationOffsetXYCm(1)~=0 && fixationOffsetXYCm(2)~=0
         string=[string 'and'];
      end
      if fixationOffsetXYCm(2)~=0
         if fixationOffsetXYCm(2) < 0
            string=sprintf('%s %.1f cm higher than',string,-fixationOffsetXYCm(2));
         else
            string=sprintf('%s %.1f cm lower than',string,fixationOffsetXYCm(2));
         end
      end
      string=[string ' the cross +.'];
      string=sprintf('%s Adjust the viewing distances so both your fixation mark and the cross + below are %.1f cm from the observer''s eye.',...
         string,o.viewingDistanceCm);
      string=[string ' Tilt and swivel the display so that the cross is orthogonal to the observer''s line of sight. '...
         'Then hit RETURN to proceed, or ESCAPE to quit. '];
      Screen('TextSize',window,o.textSize);
      Screen('TextFont',window,'Verdana');
      Screen('FillRect',window,o.gray1);
      Screen('DrawText',window,' ',0,0,1,o.gray1,1); % Set background color.
      DrawFormattedText(window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
      x=o.nearPointXYPix(1);
      y=o.nearPointXYPix(2);
      a=0.1*RectHeight(o.stimulusRect);
      Screen('DrawLine',window,black,x-a,y,x+a,y,a/20);
      Screen('DrawLine',window,black,x,y-a,x,y+a,a/20);
      Screen('Flip',window); % Display question.
      if o.speakInstructions
         Speak(string);
      end
      answer=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode]);
      Screen('FillRect',window,white);
      Screen('Flip',window); % Blank, to acknowledge response.
      if ismember(answer,returnChar)
         o.fixationIsOffscreen=true;
         ffprintf(ff,'Offscreen fixation mark (%.1f,%.1f) cm from near point of display.\n',fixationOffsetXYCm);
      else
         o.fixationIsOffscreen=false;
         error('User refused off-screen fixation. Please reduce viewing distance (%.1f cm) or o.eccentricityXYDeg (%.1f %.1f).',...
            o.viewingDistanceCm,o.eccentricityXYDeg);
      end
   else
      o.fixationIsOffscreen=false;
   end
end
o.targetXYPix=XYPixOfXYDeg(o,o.eccentricityXYDeg);
if o.fixationCrossBlankedNearTarget
   ffprintf(ff,'Fixation cross is blanked near target. No delay in showing fixation after target.\n');
else
   ffprintf(ff,'Fixation cross is blanked during and until %.2f s after target. No selective blanking near target. \n',o.fixationCrossBlankedUntilSecAfterTarget);
end
end