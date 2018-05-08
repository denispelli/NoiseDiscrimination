function oo=NoiseDiscrimination2(ooIn)
% oo=NoiseDiscrimination2(oo);
%
% You can now pass an array of stucts, one struct per condition, and it
% will run them all interleaved.
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
% you don't carry over any values from a prior experiment.
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
% RESUME. There's a new feature to allow resuming a partially completed
% experiment. It has not been thoroughly tested. This only arises if an
% observer has previously used ESCAPE ESCAPE to get out of an experiment
% before completion. The saved MAT file has "-partial" in the file name. If
% you run the same experiment on the same computer, the program will notice
% the old file (based solely on o.experiment and computer name) and offer
% to resume it, instead of starting a new experiment. [IMPORTANT: This
% question is presented in the MATLAB command window, not a Psychtoolbox
% window.] The software doesn't yet know the observer's name, so it will
% offer files by any observer. You can say "yes", to resume the old
% experiment. Or hit DELETE to delete the old partial experiment. Or hit
% RETURN to ignore the file and proceed with your new experiment. If you
% resume the old experiment it eventually produces a new experiment file. I
% haven't yet added code to automatically delete the obsolete partial file.
% This new feature will not appear if your observers always finish their
% experiments. It's a convenience for the experimenter because it allows
% you to design long experiments, with many blocks, that the observer can
% complete over multiple sessions.
%
% Ragahavan & Pelli: Photon noise is NPhoton = phi^-1 q^-1 L^-1, where phi
% is the transduction efficiency of (fraction of light required to account
% for) the photon noise, qL is luminance expressed as a quantal flux of
% 555-nm photon deg-2 s-1, q = 1.26e6 deg^-2 s^-1 td^-1 is the conversion
% factor, and L is retinal illuminance in td.
% q=1.26e6;
% NPhoton=1/(phi*q*td);

% SNAPSHOT. It is useful to take snapshots of the stimulus produced by
% NoiseDiscrimination. Such snapshots can be used in papers and talks to
% show our stimuli. If you request a snapshot then NoiseDiscrimination
% saves the first stimulus to a PNG image file and then quits with a fake
% error. To help you keep track of how you made each stimulus image file,
% some information about the condition is contained in the file name and in
% a caption on the figure. The caption may not be included if you enable
% cropping. Here are the parameters that you can control:
%
% o.saveSnapshot=true;    % If true, take snapshot for public presentation. 
% o.snapshotContrast=0.2; % nan to request program default.
% o.cropSnapshot=false;   % If true, crop to include only target and noise,
%                         % plus response numbers, if displayed.
% o.snapshotCaptionTextSizeDeg=0.5;
%
% Standard condition for counting V1 neurons: o.noiseCheckPix=13;
% height=30*o.noiseCheckPix; o.viewingDistanceCm=45; SD=0.2, o.targetDurationSecs=0.2 s.
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
% always gray o.LBackground, but it's produced by a color index of 128 inside
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
% presentation and until o.fixationCrossBlankedUntilSecsAfterTarget.
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

%% CURRENT ISSUES/BUGS
% 1. Would like to add illustrations to the question screens, so you can
% get the idea even without reading.
% 2. It would be nice to make more use of AskQuestion, since its page is
% easier to read than most of my current question pages. 
% 3. I'm unsure whether the question pages should be dim, like the
% experiment, to maintain dark adaptation, or bright for readability.
% 4. There seems to be a bug in MATLAB. When I declare "signal" global,
% this is ignored. It is assigned a struct array in the main program, but
% when I access it in a subrouting, it's empty or undefined (i don't
% remember), even though it's declared as global in both. Several other
% variables are also declared global and work as expected.
% 5. ModelObserver works fine for luminance and noise. 


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
% (NoiseAfterSecs=NoiseBeforeSecs)
%
% Manoj, years ago
% ITC Bookman Light, xHeightDeg 7.37
% binary, noiseCheckDeg 0.091, checkSecs 0.013, noiseSD 0.5, noiseBeforeSecs 0.5
% N 2.69E-05
% Luminance 112 cd/m^2, pupilDiameterMm 3.5
%
% Hormet, December, 2016
% Sloan, xHeightDeg 7.34
% gaussian, noiseCheckDeg 0.368, checkSecs 0.017, noiseSD 0.16, noiseBeforeSecs 0.2
% N 5.89e-05
% Luminance 212 cd/m^2, pupilDiameterMm 3.5
%
% Ning, February 24, 2017
% ITC Bookman Light, xHeightDeg 3.7
% binary, noiseCheckDeg 0.092, checkSecs 0.013, noiseSD 0.5, noiseBeforeSecs 0.2
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
if exist('oIn','var') && isfield(oIn,'quitExperiment') && oIn.quitExperiment
    % If the user wants to quit the experiment, then return immediately.
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

%% PERSISTENT
persistent window % Retain pointer to open window when this function exits and is called again.
persistent oOld % Saved from previous block to skip prompts that were already answered in the previous block.

%% GLOBALS, FILES
global fixationLines fixationCrossWeightPix labelBounds ...
     tTest leftEdgeOfResponse cal ...
    ff whichSignal logFid ...
     signalImageIndex signalMask % for function ModelObserver
% This list of global variables is shared only with the several subroutines
% at the end of this file. The list may be incomplete as the new routines
% haven't yet been tested as subroutines, and some of their formerly
% locally variables need to either be made global or become fields of the o
% struct.
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'AutoBrightness')); % Folder in same directory as this M file. .
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
% echo_executing_commands(2, 'local');
% diary ./diary.log
% [~, vStruct]=PsychtoolboxVersion;
% if IsOSX && vStruct.major*1000+vStruct.minor*100+vStruct.point < 3013
%    error('Your Mac OSX Psychtoolbox is too old. We need at least Version 3.0.13. Please run: UpdatePsychtoolbox');
% end
rng('shuffle'); % Use time to seed the random number generator. TAKES 0.01 s.
plusMinusChar=char(177); % Use this instead of literal plus minus sign to prevent corruption of this non-ASCII character.
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
% Keycodes are used when we call GetKeypress or any other function based on
% KbCheck. We use these keycode lists in preparing a list of keys to
% enable. For some characters, e.g. "1", there may be several ways to type
% it (main keyboard or numeric keypad), and several corresponding keyCodes.
KbName('UnifyKeyNames');
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
numberKeyCodes=KbName({'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ...
    '0)' '1!' '2@' '3#' '4$' '5%' '6^' '7&' '8*' '9(' ...
    });
letterKeyCodes=KbName({'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm'...
    'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'});
letterNumberKeyCodes=[letterKeyCodes numberKeyCodes];
letterNumberChars=KbName(letterNumberKeyCodes);
letterNumberCharString='';
for i=1:length(letterNumberChars)
    % Take only the first character of each key name.
    letterNumberCharString(i)=letterNumberChars{i}(1);
end

ff=1; % Once we open a data file, ff will print to both screen and data file.

%% DEFAULT VALUE FOR EVERY "o" PARAMETER
% They are overridden by what you provide in each argument struct ooIn(i).
if nargin < 1 || ~exist('oIn','var')
    oIn.noInputArgument=true;
end
o=[];
% I added these here May 6, 2018,  to guarantee that they'll be defined
% when I pull them into a table in EvsNRun2.m
o.condition=[];
o.experiment=[];
o.conditionName=[];
o.useFilter=false;
o.luminanceAtEye=[];
o.eccentricityXYDeg=[];
o.targetDurationSecs=[];
o.targetCyclesPerDeg=[];
o.targetHeightDeg=[];
o.targetGaborCycles=[];
o.noiseCheckFrames=1;
o.noiseSD=[];
o.N=[];
o.E=[];
o.dataFilename='';
o.dataFolder='';
% End of recent addition.

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
o.ditherClut=61696; % Use this only on Denis's PowerBook Pro and iMac 5k.
o.ditherClut=false; % As of June 28, 2017, there is no measurable effect of this dither control.
o.enableClutMapping=true; % Required. Using software CLUT.
o.assessBitDepth=false;
o.useFractionOfScreen=false; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
o.viewingDistanceCm=50; % viewing distance
o.flipScreenHorizontally=false; % Use this when viewing the display in a mirror.
o.observer=''; % Name of person or algorithm.
% o.observer='brightnessSeeker'; % Existing algorithm instead of person.
% o.observer='blackshot'; % Existing algorithm instead of person.
% o.observer='maximum'; % Existing algorithm instead of person.
% o.observer='ideal'; % Existing algorithm instead of person.
o.algorithmicObservers={'ideal', 'brightnessSeeker', 'blackshot', 'maximum'};
o.experimenter='';
o.eyes='both'; % 'left', 'right', 'both', or 'one', which asks user to specify at runtime.
o.trialsPerBlock=40; % Typically 40.
o.trials=0; % Initialize trial counter so it's defined even if user quits early.
o.blockNumber=1; % For display only, indicate the block number. When o.blockNumber==blocksDesired this program says "Congratulations" before returning.
o.blocksDesired=1; % How many blocks you to plan to run? Used solely for display and congratulations and keeping o.window open until last block.
o.experiment='';
o.conditionName='';
o.condition=1;
o.speakInstructions=false;
o.congratulateWhenDone=true; % true or false. Speak after final block (i.e. when o.blockNumber==o.blocksDesired). 
o.quitBlock=false; % Returned value is true if the user aborts this block.
o.quitExperiment=false; % Returned value is true if the observer wants to quit whole experiment now; no more blocks.
o.targetKind='letter';
% o.targetKind='gabor'; % one cycle within targetSize
% o.targetKind='image'; % read from folder of images
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
o.targetModulates='luminance'; % Display a luminance difference.
% o.targetModulates='entropy'; % Display an entropy difference.
% o.targetModulates='noise';  % Display a noise-sd difference.
o.task='identify'; % 'identify', 'identifyAll' or '4afc' or 'rate'
% o.thresholdParameter='size';
% o.thresholdParameter='spacing';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast','size', 'spacing', or 'flankerContrast'.
o.thresholdResponseTo='target'; % 'target' 'flankers'
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
o.targetMargin=0.25; % Minimum gap from edge of target to edge of o.stimulusRect, as fraction of o.targetHeightDeg.
o.targetDurationSecs=0.2; % Typically 0.2 or inf (wait indefinitely for response).
o.contrast=1; % Default is positive contrast.
o.useFlankers=false; % Enable for crowding experiments.
o.flankerContrast=-0.85; % Negative for dark letters.
o.flankerContrast=nan; % Nan requests that flanker contrast always equal target contrast.
o.flankerSpacingDeg=4;
% o.flankerSpacingDeg=1.4*o.targetHeightDeg; % You can put this in your code, but it won't work here.
o.flankerArrangement='radial'; % or 'tangential' or 'radialAndTangential;
o.noiseSD=0.2; % Usually in the range 0 to 0.4. Typically 0.2.
% o.noiseSD=0; % Usually in the range 0 to 0.4. Typically 0.2.
o.annularNoiseSD=0; % Typically nan (i.e. use o.noiseSD) or 0.2.
o.noiseCheckDeg=0.05; % Typically 0.05 or 0.2.
o.noiseCheckFrames=1;
o.noiseCheckSecs=[];
o.noiseRadiusDeg=inf; % When o.task=4afc, the program will set o.noiseRadiusDeg=o.targetHeightDeg/2;
o.noiseEnvelopeSpaceConstantDeg=inf;
o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at noiseRadiusDeg.
o.noiseSpectrum='white'; % 'pink' or 'white'
o.showBlackAnnulus=false;
o.blackAnnulusContrast=-1; % (LBlack-o.LBackground)/o.LBackground. -1 for black line. >-1 for gray line.
o.blackAnnulusSmallRadiusDeg=2;
o.blackAnnulusThicknessDeg=0.1;
o.annularNoiseBigRadiusDeg=inf; % Noise extent in deg, or inf.
o.annularNoiseSmallRadiusDeg=inf; % Hole extent or 0 (no hole).
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
o.noiseFrozenInTrial=false; % 0 or 1.  If true (1), use same noise at all locations
o.noiseFrozenInBlock=false; % 0 or 1.  If true (1), use same noise on every trial
o.noiseFrozenInBlockSeed=0; % 0 or positive integer. If o.noiseFrozenInBlock, then any nonzero positive integer will be used as the seed for the block.
o.markTargetLocation=false; % Is there a mark designating target position?
o.targetMarkDeg=1;
o.useFixation=true;
o.fixationIsOffscreen=false;
o.fixationCrossDeg=3; % Typically 3 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=true;
o.fixationCrossBlankedUntilSecsAfterTarget=0.6; % Pause after stimulus before display of fixation. Skipped when fixationCrossBlankedNearTarget. Not needed when eccentricity is bigger than the target.
o.fixationCrossDrawnOnStimulus=false;
o.blankingRadiusReTargetHeight= nan;
o.blankingRadiusReEccentricity= 0.5;
o.textSizeDeg=0.6;
o.saveSnapshot=false; % 0 or 1.  If true (1), take snapshot for public presentation.;
o.snapshotContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.;
o.tSnapshot=nan; % log intensity, nan to request program defaults.;
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
o.printGrayLuminance=false;
o.assessLoadGamma=false; % diagnostic information
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
o.movieFrameFlipSecs=[]; % flip times (useful to calculate frame drops)
o.useDynamicNoiseMovie=false; % false for static noise
o.moviePreSecs=0;
o.moviePostSecs=0;
o.likelyTargetDurationSecs=[];
o.measuredTargetDurationSecs=[];
o.movieFrameFlipSecs=[];
o.printDurations=false;
o.newClutForEachImage=true;
o.minScreenWidthDeg=nan;
o.maxViewingDistanceCm=nan;
o.useFilter=false;
o.filterTransmission=0.115; % Less than one for dark glasses or neutral density filter. 0.115 for our dark glasses.
o.desiredRetinalIlluminanceTd=[];
o.desiredLuminanceAtEye=[];
o.desiredLuminanceFactor=1; % Ratio of screen luminance LBackground to LStandard, middle of physically possible range.
o.luminanceFactor=1; % For max brightness, set this to 1.9, and o.symmetricLuminanceRange=false;
o.LBackground = []; % Will be set to o.luminanceFactor*mean([LMin LMax]);
o.symmetricLuminanceRange=true; % For max brightness set this false and o.LuminanceFactor=1.9.
o.luminanceAtEye=[];
o.retinalIlluminanceTd=[];
o.pupilDiameterMm=[];
o.pupilKnown=false;
o.annularNoiseEnvelopeRadiusDeg=0;
o.labelAlternatives=[];
o.trialsPerBlock=40;
o.blocksDesired=1;
o.eyes='both';
o.readAlphabetFromDisk=false;
o.borderLetter=[];
o.seed=[];
o.targetHeightOverWidth=nan;
o.printSignalImages=false;
o.signalImagesFolder='';
o.signalImagesAreGammaCorrected=true;
o.convertSignalImageToGray=false;
o.skipTrial=0;
o.trialsSkipped=0;
o.responseScreenAbsoluteContrast=0.99; % Set to [] to maximize possible contrast using CLUT for o.contrast.
o.transcript.responseTimeSecs=[]; % Time of response re o.transcript.stimulusOnsetSecs, for each trial.
o.transcript.stimulusOnsetSecs=[]; % Value of GetSecs at stimulus onset, for each trial.
o.transcript.condition=[];
o.printImageStatistics=false;
o.localHostName=''; % Copy this from cal.localHostName
o.dataFilename='';
o.dataFolder='';
o.textMarginPix=0;
o.ratingThreshold=4*ones(1,10); % One value per element of o.alphabet.
o.ignoreOverlyLongTrials=true;
o.ignoreTrial=false;
o.targetDurationListSecs=[];
o.conditionList=1; % An array of integer condition numbers.
o.signalImagesCacheCode=[];
o.age=20;

o.deviceIndex=-1; % -1 for all keyboards.
o.deviceIndex=-3; % -3 for all keyboard/keypad devices.
% o.deviceIndex=3; % for my built-in keyboard, according to PsychHIDTest
% o.deviceIndex=6; % for my bluetooth wireless keyboard, according to PsychHIDTest
o.deviceIndex=[]; % Default. This runs MUCH more reliably. Not sure why.
% April, 2018. KbCheck([]) succeeds, but I'm experiencing a fatal error
% when I call KbCheck(deviceIndex) with deviceIndex -1 or -3 or the
% positive device index (2) of my built-in keyboard. The suprising error
% message issued by PsychHID.mex is:
%
% Error in function KbCheck: 	Usage error
% Specified device number is not a suitable keyboard type input device.
%
% With the not-empty deviceIndex, KbCheck(deviceIndex) fails. In that case
% KbCheck calls PsychHID('KbCheck', i, ptb_kbcheck_enabledKeys); where i is
% a list of one or more device indices of keyboards or keypads. KbCheck([])
% succeeds. It calls PsychHID('KbCheck', [], ptb_kbcheck_enabledKeys);
%
% My temporary work-around is to call KbCheck([]), but this won't support
% my wireless keyboards.

% "In my experience the special negative device indexes have been flaky on
% OS X for years. For example, when using an external Bluetooth keyboard, a
% device index of -1 does not detect the external keyboard. Rather than
% relying on the merged modes, I always interrogate the full device
% structure at runtime to determine exactly which keyboard to use, based
% upon the usageName, transport, and product info for each available
% device." microfish@fishmonkey.com.au to [PSYCHTOOLBOX] Mar 29, 2018
% d=PsychHID('Devices');
% iKeyboards=ismember([d(:).usageValue],[6]); % Keyboard
% dk=d(iKeyboards);
% [dk.index] % Vector of indices of the keyboards.

% The user can only set fields that are initialized above. This is meant to
% catch any mistakes where the user tries to set a field that isn't used
% below. We ignore input fields that are known output fields. Any field in
% the input argument o that is neither already initialized (immediately
% above) or a known output field is flagged as a fatal error, so it gets
% fixed immediately. Typically the unrecognized input field is a typo, so
% ignoring it would unhelpfully run a condition different from what the
% experimenter wanted.

%% READ USER-SUPPLIED oo PARAMETERS
conditions=length(ooIn);
for oi=1:conditions
    oo(oi)=o;
end
if false
    % ACCEPT ALL o FIELDS.
    % All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
    for oi=1:conditions
        fields=fieldnames(ooIn(oi));
        for i=1:length(fields)
            field=fields{i};
            oo(oi).(field)=ooIn(oi).(field);
        end
    end
else
    % ACCEPT ONLY KNOWN o FIELDS.
    % For each condition, all fields in the user-supplied "oIn" overwrite
    % corresponding fields in "o". We ignore any field in oIn that is not
    % already defined in o. If the ignored field is a known output field,
    % then we ignore it silently. We warn of unknown fields because they
    % might be typos for input fields.
    initializedFields=fieldnames(o);
    knownOutputFields={'labelAlternatives' 'beginningTime' ...
        'functionNames' 'cal' 'pixPerDeg' ...
        'lineSpacing' 'stimulusRect' 'noiseCheckPix' ...
        'minLRange' 'targetHeightPix' ...
        'contrast' 'targetWidthPix' 'checkSecs' 'moviePreFrames'...
        'movieSignalFrames' 'moviePostFrames' 'movieFrames' 'noiseSize'...
        'annularNoiseSmallSize' 'annularNoiseBigSize' 'canvasSize'...
        'noiseListMin' 'noiseListMax' 'noiseIsFiltered' 'noiseListSd' 'N' 'NUnits' ...
        'targetRectLocal' 'xHeightPix' 'xHeightDeg' 'HHeightPix' ...
        'HHeightDeg' 'alphabetHeightDeg' 'annularNoiseEnvelopeRadiusDeg' ...
        'centralNoiseEnvelopeE1DegDeg' 'E1' 'data' 'psych' 'questMean'...
        'questSd' 'p' 'trials' 'EOverN' 'efficiency' 'targetDurationSecsMean'...
        'targetDurationSecsSD' 'E' 'signal' 'newCal'...
        'beamPositionQueriesAvailable' ...
        'drawTextPlugin' 'fixationXYPix' 'maxEntry' 'nearPointXYDeg'...
        'nearPointXYPix' 'pixPerCm' 'psychtoolboxKernelDriverLoaded'...
        'targetXYPix' 'textLineLength' 'textSize' 'unknownFields'...
        'speakEachLetter' 'targetCheckDeg' 'targetCheckPix'...
        'textFont'  'LBackground' 'targetCyclesPerDeg' 'contrast' ...
        'thresholdParameterValueList' 'noInputArgument' ...
        'firstGrayClutEntry' 'lastGrayClutEntry' 'gray' 'r' 'transcript'...
        'signalIsBinary' 'targetXYInUnitSquare'...
        'gray1' 'resumeExperiment' 'script' 'scriptName' ...
        'showLineOfLetters' 'signalMax' 'signalMin' ...
        'targetFont' 'targetPix' 'useSpeech'...
        'approxRequiredNumber' 'logApproxRequiredNumber'... % for the noise-discrimination project
        'idealT64' 'q' 'rWarningCount' 'trialsRight' 'window'...
        };
    unknownFields={};
    for oi=1:conditions
        inputFields=fieldnames(ooIn(oi));
        oo(oi).unknownFields={};
        for i=1:length(inputFields)
            if ismember(inputFields{i},initializedFields)
                % We accept only the parameters that we initialized above.
                % Overwrite initial value.
                oo(oi).(inputFields{i})=ooIn(oi).(inputFields{i});
            elseif ~ismember(inputFields{i},knownOutputFields)
                % Record unknown field, and issue error below, with a
                % complete list of unknown fields in the input struct.
                oo(oi).unknownFields{end+1}=inputFields{i};
            end
        end
        oo(oi).unknownFields=unique(oo(oi).unknownFields);
        unknownFields=unique([unknownFields oo(oi).unknownFields]);
    end % for oi=1:conditions
    if ~isempty(unknownFields)
        error(['Unknown field(s) in input struct:' sprintf(' o.%s',unknownFields{:}) '.']);
    end
end


%% SCREEN PARAMETERS
o=oo(1);
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
screenBufferRect=Screen('Rect',o.screen);
o.screenrect=Screen('Rect',o.screen,1);
resolution=Screen('Resolution',o.screen);
if o.useFractionOfScreen
    o.screenrect=round(o.useFractionOfScreen*o.screenrect);
end
[oo.screenrect]=deal(o.screenrect);

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
%     o.trialsPerBlock=1000;
%     o.alphabet='CDHKNORSVZ'; % As in Pelli et al. (2006)
%     o.alternatives=10; % As in Pelli et al. (2006).
%     o.pThreshold=0.64; % As in Pelli et al. (2006).
%     o.noiseType='gaussian';
%     o.noiseSD=0.25;
%     o.noiseCheckDeg=0.063;
%     o.targetHeightDeg=29*o.noiseCheckDeg;
%     o.pixPerCm=RectWidth(o.screenrect)/(0.1*screenWidthMm);
%     o.pixPerDeg=2/0.0633; % As in Pelli et al. (2006).
%     degPerCm=o.pixPerCm/o.pixPerDeg;
%     o.viewingDistanceCm=57/degPerCm;
% end

%% SET UP MISCELLANEOUS
%onCleanupInstance=onCleanup(@()ListenChar;sca;window=[];[oo.window]=deal([]);); % clears screen and restores keyboard when function terminated.
for oi=1:conditions
    o=oo(oi);
    if ~ismember(o.observer,o.algorithmicObservers) && ismac && ~ScriptingOkShowPermission
        error(['Please give MATLAB permission to control the computer. '...
            'Use System Preferences:Security and Privacy:Privacy:Accessibility. '...
            'You''ll need admin privileges to do this.']);
    end
    useImresize=exist('imresize','file'); % Requires the Image Processing Toolbox.
    if isnan(o.annularNoiseSD)
        o.annularNoiseSD=o.noiseSD;
    end
    if o.saveSnapshot
        if isfinite(o.snapshotContrast) && streq(o.targetModulates,'luminance')
            oo(oi).tSnapshot=log10(abs(o.snapshotContrast));
        end
        if ~isfinite(o.tSnapshot)
            switch o.targetModulates
                case 'luminance'
                    oo(oi).tSnapshot=-0.0; % log10(contrast)
                case 'noise'
                    oo(oi).tSnapshot=.3; % log10(o.r-1)
                case 'entropy'
                    oo(oi).tSnapshot=0; % log10(o.r-1)
                otherwise
                    error('Unknown o.targetModulates "%s".',o.targetModulates);
            end
        end
    end
    if streq(o.targetKind,'gabor')
        assert(length(o.targetGaborNames) >= length(o.targetGaborOrientationsDeg))
        oo(oi).alternatives=length(o.targetGaborOrientationsDeg);
        oo(oi).alphabet=o.targetGaborNames(1:o.alternatives);
    end
    if isempty(o.labelAlternatives)
        switch o.targetKind
            case 'gabor'
                oo(oi).labelAlternatives=true;
            case 'letter'
                oo(oi).labelAlternatives=false;
            case 'image'
                oo(oi).labelAlternatives=true;
            otherwise
                error('Unknown o.targetKind "%s".',o.targetKind);
        end
    end
end % for oi=1:conditions
%% GET SCREEN CALIBRATION cal
o=oo(1);
cal.screen=o.screen;
cal=OurScreenCalibrations(cal.screen);
if isfield(cal,'gamma')
    cal=rmfield(cal,'gamma');
end
if cal.screen > 0
    fprintf('Using external monitor.\n');
end
cal.clutMapLength=o.clutMapLength;
for oi=1:conditions
    oo(oi).maxEntry=oo(oi).clutMapLength-1; % copied here on April. 8, 2018
    oo(oi).cal=cal;
    if ~isfield(cal,'old') || ~isfield(cal.old,'L')
        fprintf('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
        error('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
    end
    % Check the persistent "window" pointer and discard it unless it's valid.
    if Screen(window,'WindowKind')~=1
        window=[];
    end
    % From here on, assume that a nonempty window is valid.
    oo(oi).window=window;
end % for oi=1:conditions
%% Only call Brightness while no window is open.
o=oo(1);
if isempty(o.window) && ~ismember(o.observer,o.algorithmicObservers)
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
end % if isempty(o.window)

%% TRY-CATCH BLOCK CONTAINS ALL CODE IN WHICH THE WINDOW IS OPEN
try
    o=oo(1);
    %% OPEN WINDOW
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference','TextAntiAliasing',1);
    if o.useFractionOfScreen
        ffprintf(ff,'Using tiny window for debugging.\n');
    end
    if isempty(o.window) && ~ismember(o.observer,o.algorithmicObservers)
        % If the observer is human, we need an open window.
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
        if o.enableClutMapping
            PsychImaging('AddTask','AllViews','EnableClutMapping',o.clutMapLength,1); % clutSize, high res
        else
            warning('You need EnableClutMapping to control contrast.');
        end
        if ~o.useFractionOfScreen
            [window,o.screenrect]=PsychImaging('OpenWindow',cal.screen,1.0);
        else
            r=round(o.useFractionOfScreen*screenBufferRect);
            r=AlignRect(r,screenBufferRect,'right','bottom');
            [window,o.screenrect]=PsychImaging('OpenWindow',cal.screen,1.0,r);
        end
        [oo.window]=deal(window);
        [oo.screenrect]=deal(o.screenrect);
        % if cal.hiDPIMultiple~=1
        %     ffprintf(ff,'HiDPI: It doesn''t matter, but you might be curious to know.\n');
        %     if ismac
        %         str='Your Retina display';
        %     else
        %         str='Your display';
        %     end
        %     ffprintf(ff,'%s is in dual-resolution HiDPI mode. Display resolution is %.2fx buffer resolution.\n',str,cal.hiDPIMultiple);
        %     ffprintf(ff,'Draw buffer is %d x %d. ',screenBufferRect(3:4));
        %     ffprintf(ff,'Display is %d x %d.\n',o.screenrect(3:4));
        %     ffprintf(ff,'We are using it in its native %d x %d resolution.\n',resolution.width,resolution.height);
        %     ffprintf(ff,'You can use Switch Res X (http://www.madrau.com/) to select a pure resolution, not HiDPI.\n');
        % end
    end
    % We assume that all conditions specify the same screen parameters. It
    % would be good to confirm that and flag and error if they differ.
    o=oo(1);
    if ~isempty(o.window)
        if o.enableClutMapping
            [oo.maxEntry]=deal(o.clutMapLength-1);
            cal.gamma=repmat((0:o.maxEntry)'/o.maxEntry,1,3); % Identity.
            % Set hardware CLUT to identity, without assuming we know the
            % size. On Windows, the only allowed gamma table size is 256.
            gamma=Screen('ReadNormalizedGammaTable',cal.screen);
            maxEntry=length(gamma)-1;
            gamma(:,1:3)=repmat((0:maxEntry)'/maxEntry,1,3);
            Screen('LoadNormalizedGammaTable',cal.screen,gamma,0);
        end
        if o.enableClutMapping % How we use LoadNormalizedGammaTable
            loadOnNextFlip=2; % Load software CLUT at flip.
        else
            loadOnNextFlip=true; % Load hardware CLUT: 0. now; 1. on flip.
        end
    end
    o.screenrect=Screen('Rect',cal.screen,1); % screen rect in UseRetinaResolution mode
    if o.useFractionOfScreen
        o.screenrect=round(o.useFractionOfScreen*o.screenrect);
    end
    [oo.screenrect]=deal(o.screenrect);

    %% ASK EXPERIMENTER NAME
    [oo.textMarginPix]=deal(round(0.08*min(RectWidth(o.screenrect),RectHeight(o.screenrect))));
    [oo.textSize]=deal(39);
    [oo.textFont]=deal('Verdana');
    black=0; % The CLUT color code for black.
    white=1; % Retrieves the CLUT color code for white.
    [oo.gray1]=deal(white); % Temporary, until we LinearizeClut.
    [oo.speakEachLetter]=deal(false);
    [oo.useSpeech]=deal(false);
    if isempty(o.experimenter)
        text.big={'Hello,' 'Please slowly type the experimenter''s name followed by RETURN.'};
        text.small='I''ll remember your answers, and skip these questions on the next block.';
        text.fine='NoiseDiscrimination Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.';
        text.question='Experimenter name:';
        text.setTextSizeToMakeThisLineFit='Standard line of text xx xxxxx xxxxxxxx xx XXXXXX. xxxx.....xx';
        fprintf('*Waiting for experimenter name.\n');
        [reply,o]=AskQuestion(oo,text);
        if o.quitBlock
            ListenChar;
            ShowCursor;
            sca;
            window=[];
            [oo.window]=deal([]);
            return
        end
        [oo.experimenter]=deal(reply);
    end
    
    %% ASK OBSERVER NAME
    o=oo(oi);
    if isempty(o.observer)
        text.big={'Hello Observer,' 'Please slowly type your name followed by RETURN.'};
        text.small='I''ll remember your answers, and skip these questions on the next block.';
        text.fine='NoiseDiscrimination Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.';
        text.question='Observer name:';
        text.setTextSizeToMakeThisLineFit='Standard line of text xx xxxxx xxxxxxxx xx XXXXXX. xxxx.....xx';
        fprintf('*Waiting for observer name.\n');
        [reply,o]=AskQuestion(oo,text);
        if o.quitBlock
            ListenChar;
            ShowCursor;
            sca;
            window=[];
            [oo.window]=deal([]);
            return
        end
        [oo.observer]=deal(reply);
    end
    
    %% ASK FILTER TRANSMISSION
    o=oo(1);
    persistent previousBlockUsedFilter
    if ~all([oo.useFilter]) && any([oo.useFilter])
        error('o.useFilter must have the same true/false value for all interleaved conditions.');
    end
    if ~o.useFilter
        o.filterTransmission=1;
        if previousBlockUsedFilter
            % If the preceding block had a filter, and this block does not, we ask
            % the observer to remove the filter or sunglasses.
            text.big={'Please remove any filter or sunglasses. Hit RETURN to continue.'};
            text.small='';
            text.fine='';
            text.question='';
            text.setTextSizeToMakeThisLineFit='Standard line of text xx xxxxx xxxxxxxx xx XXXXXX. xxxx.....xx';
            fprintf('*Waiting for observer to remove sunglasses.\n');
            [~,o]=AskQuestion(oo,text);
        end
    else % if ~o.useFilter
        text.big={'Please use a filter or sunglasses to reduce the luminance.' '(Our lab sunglasses transmit 0.115)' 'Please slowly type its transmission (between 0.000 and 1.000)' 'followed by RETURN.'};
        if isempty(o.filterTransmission)
            text.big{end}='followed by RETURN.';
        else
            text.big{end}=sprintf('followed by RETURN. Or just hit RETURN to say: %.3f',o.filterTransmission);
        end
        text.small='';
        text.fine='';
        text.question='Filter transmission:';
        text.setTextSizeToMakeThisLineFit='Standard line of text xx xxxxx xxxxxxxx xx XXXXXX. xxxx.....xx';
        [reply,o]=AskQuestion(oo,text);
        if ~o.quitBlock
            if ~isempty(reply)
                o.filterTransmission=str2num(reply);
            end
            if isempty(o.filterTransmission)
                error('Sorry. You must specify the filter transmission.');
            end
        end
    end % if ~o.useFilter
    [oo.filterTransmission]=deal(o.filterTransmission);
    if o.quitBlock
        ListenChar;
        ShowCursor;
        sca;
        window=[];
        [oo.window]=deal([]);
        return
    end
    if ~isempty(o.window)
        Screen('FillRect',o.window,o.gray1);
        % Keep the temporary window open until we open the main one, so
        % observer knows program is running.
    end
    previousBlockUsedFilter=o.useFilter;
    
    %% PUPIL SIZE
    % Measured December 2017 by Darshan.
    % Monocular right eye viewing of 250 cd/m^2 screen.
    if isempty(o.pupilDiameterMm)
        switch lower(o.observer)
            case 'hortense'
                mm=3.3;
            case 'katerina'
                mm=5.0;
            case 'shenghao'
                mm=5.3;
            case 'yichen'
                mm=4.4;
            case 'darshan'
                mm=4.9;
            otherwise
                mm=[];
        end
        [oo.pupilDiameterMm]=deal(mm);
    end
    
    %% LUMINANCE
    % LStandard is the highest o.LBackground luminance at which we can
    % display a sinusoid at a contrast of nearly 100%. I have done most
    % of my experiments at that luminance. NoiseDiscrimination2 FORCES ALL
    % INTERLEAVED CONDITIONS TO HAVE THE SAME LUMINANCE AND ASSUMES THEY
    % HAVE SAME LUMINANCE SETTINGS, e.g. o.desiredLuminanceFactor,
    % o.desiredLuminanceAtEye, and o.desiredRetinalIlluminanceTd.
    if ~all([oo.desiredLuminanceFactor]) && any([oo.desiredLuminanceFactor])...
       || ~all([oo.desiredLuminanceAtEye]) && any([oo.desiredLuminanceAtEye])...
       || ~all([oo.desiredRetinalIlluminanceTd]) && any([oo.desiredRetinalIlluminanceTd])
        error('All conditions must have the same luminance settings.');
    end
    o=oo(1);
    if exist('cal','var')
        % The physical limits of the calibrated display.
        LMin=min(cal.old.L);
        LMax=max(cal.old.L);
    else
        % This is arbitrary, for computational observers. We don't display
        % this.
        LMin=0;
        LMax=200;
    end
    LStandard=mean([LMin LMax]);
    if 1 ~= ~isempty(o.desiredRetinalIlluminanceTd)+~isempty(o.desiredLuminanceAtEye)+~isempty(o.desiredLuminanceFactor)
        error(['You must specify one and only one of o.desiredLuminanceFactor, '...
            'o.desiredLuminanceAtEye, and o.desiredRetinalIlluminanceTd. The rest should be empty []. '...
            'The default is o.desiredLuminanceFactor=1']);
    end
    if ~isempty(o.desiredLuminanceAtEye)
        o.luminanceFactor=o.desiredLuminanceAtEye/(LStandard*o.filterTransmission);
    end
    if ~isempty(o.desiredLuminanceFactor)
        o.luminanceFactor=o.desiredLuminanceFactor;
    end
    if ~isempty(o.desiredRetinalIlluminanceTd)
        if isempty(o.pupilDiameterMm)
            % Actually, I could compute an inverse to PupilDiameter(L), to
            % solve for what luminance is required to attain the desired
            % retinal illuminance. The caveat is that the formula is merely
            % a population average, and individual observers may deviate
            % from it.
            error(['When you request o.desiredRetinalIlluminanceTd, ' ...
                'you must also specify o.pupilDiameterMm or an observer with known pupil size.']);
        end
        % o.filterTransmission refers to an optical neutral density filter
        % or sunglasses.
        % o.luminanceFactor refers to software attenuation of luminance
        % from the standard middle of attainable range.
        td=o.filterTransmission*LStandard*pi*o.pupilDiameterMm^2/4;
        o.luminanceFactor=o.desiredRetinalIlluminanceTd/td;
    end
    o.luminanceFactor=min([LMax/LStandard o.luminanceFactor]); % upper bound
    [oo.luminanceFactor]=deal(o.luminanceFactor);
    o.LBackground=o.luminanceFactor*LStandard; 
    [oo.LBackground]=deal(o.LBackground);
    % Need screen geometry to compute screen area in deg^2, so we
    % call ComputeNPhoton after we set the near point.
    % Need to update all reports of luminance to include effect of filter.
    
    %% OPEN OUTPUT FILES
    o=oo(1);
    stack=dbstack;
    switch length(stack)
        case 1
        o.functionNames=stack.name;
        case 2
        o.functionNames=[stack(2).name '-' stack(1).name];
        case 3
            if ismember(stack(2).name,{'RunExperiment' 'RunExperiment2'})
                o.functionNames=[stack(3).name '-' stack(1).name]; % Omit 'RunExperiment'
            else
                o.functionNames=[stack(3).name '-' stack(2).name '-' stack(1).name];
            end
    end
    o.dataFolder=fullfile(myPath,'data');
    if ~exist(o.dataFolder,'dir')
        success=mkdir(o.dataFolder);
        if ~success
            error('Failed attempt to create data folder: %s',o.dataFolder);
        end
    end
    [oo.functionNames]=deal(o.functionNames);
    [oo.dataFolder]=deal(o.dataFolder);
    o.beginningTime=now;
    while 1
        % Find a unique time code, not already in use. Computers run trials
        % quickly, and can generate a threshold in less than a second.
        % Starting from the present time, keep incrementing by 1 sec until
        % we find an unused time code.
        t=datevec(o.beginningTime);
        oldFiles=dir(fullfile(o.dataFolder,sprintf('*NoiseDiscrimination*.%d.%d.%d.%d.%d.%d*',round(t))));
        if isempty(oldFiles)
            break;
        end
        o.beginningTime=o.beginningTime+1/24/60/60;
    end
    [oo.beginningTime]=deal(o.beginningTime);
    if conditions>1
        for oi=1:conditions
            oo(oi).dataFilename=sprintf('%s-%s-%s.%d.%d.%d.%d.%d.%d-%d',o.functionNames,o.observer,oo(oi).conditionName,round(t),oi);
            % We have one common log for all the conditions.
            oo(oi).logFilename=sprintf('%s-%s.%d.%d.%d.%d.%d.%d-%d',o.functionNames,o.observer,round(t),oi);
        end
    else
        oo(1).dataFilename=sprintf('%s-%s-%s.%d.%d.%d.%d.%d.%d',o.functionNames,o.observer,oo(oi).conditionName,round(t));
        oo(1).logFilename=oo(1).dataFilename;
    end
    o=oo(1);
    st=dbstack('-completenames',1);
    if ~isempty(st)
       for i=1:2
          o.scriptName=st(i).name; % Save name of calling script.
          o.script=fileread(st(i).file); % Save a copy of the calling script.
          if ~ismember(o.scriptName,{'RunExperiment.m' 'RunExperiment2.m'})
             break
          end
       end
    else
        o.scriptName='';
        o.script='';
    end
    [oo.scriptName]=deal(o.scriptName);
    [oo.script]=deal(o.script);
    logFid=fopen(fullfile(o.dataFolder,[o.logFilename '.txt']),'rt');
    if logFid ~= -1
        error('Oops. There''s already a file called "%s.txt". Please tell Denis.',o.logFilename);
    end
    [logFid,msg]=fopen(fullfile(o.dataFolder,[o.logFilename '.txt']),'wt');
    if logFid == -1
        error('%s. Could not create log file: %s',msg,[o.logFilename '.txt']);
    end
    assert(logFid > -1);
    ff=[1 logFid];
    fprintf('\nSaving results in log and data files:\n');
    ffprintf(ff,'%s\n',o.dataFilename);
    ffprintf(ff,'observer %s, task %s, alternatives %d,  steepness %.1f,\n',o.observer,o.task,o.alternatives,o.steepness);
    ffprintf(ff,'Experiment: %s. ',o.experiment);
    ffprintf(ff,'%d conditions: ',conditions);
    for oi=1:conditions
        ffprintf(ff,'%s, ',oo(oi).conditionName);
    end
    ffprintf(ff,'\n');
    
    %% STIMULUS PARAMETERS
    for oi=1:conditions
        oo(oi).pixPerCm=RectWidth(o.screenrect)/(0.1*screenWidthMm);
        degPerCm=57/oo(oi).viewingDistanceCm;
        oo(oi).pixPerDeg=oo(oi).pixPerCm/degPerCm;
        oo(oi).textSize=round(oo(oi).textSizeDeg*oo(oi).pixPerDeg);
        oo(oi).textSizeDeg=oo(oi).textSize/oo(oi).pixPerDeg;
        oo(oi).textLineLength=floor(1.9*RectWidth(o.screenrect)/oo(oi).textSize);
        oo(oi).lineSpacing=1.5;
        oo(oi).stimulusRect=InsetRect(o.screenrect,0,oo(oi).lineSpacing*1.2*oo(oi).textSize); % Allow room for captions at top and bottom of screen.
        if streq(oo(oi).task,'identifyAll')
            oo(oi).stimulusRect(4)=oo(oi).stimulusRect(4)-oo(oi).lineSpacing*0.8*oo(oi).textSize; % Allow extra room for this 2-line bottom caption.
        end
        oo(oi).noiseCheckPix=round(oo(oi).noiseCheckDeg*oo(oi).pixPerDeg);
        switch oo(oi).task
            case {'identify' 'identifyAll' 'rate'}
                oo(oi).noiseCheckPix=min(oo(oi).noiseCheckPix,RectHeight(oo(oi).stimulusRect));
            case '4afc'
                oo(oi).noiseCheckPix=min(oo(oi).noiseCheckPix,floor(RectHeight(oo(oi).stimulusRect)/(2+oo(oi).gapFraction4afc)));
                oo(oi).noiseRadiusDeg=oo(oi).targetHeightDeg/2;
        end
        oo(oi).noiseCheckPix=max(oo(oi).noiseCheckPix,1);
        oo(oi).noiseCheckDeg=oo(oi).noiseCheckPix/oo(oi).pixPerDeg;
        if oo(oi).fullResolutionTarget
            oo(oi).targetCheckPix=1;
        else
            oo(oi).targetCheckPix=oo(oi).noiseCheckPix;
        end
        oo(oi).targetCheckDeg=oo(oi).targetCheckPix/oo(oi).pixPerDeg;
        % We use nearly the whole clut (entries 2 to 254) for stimulus generation.
        % We reserve first and last (0 and o.maxEntry), for black and white.
        oo(oi).firstGrayClutEntry=2;
        oo(oi).lastGrayClutEntry=oo(oi).clutMapLength-2;
        assert(oo(oi).lastGrayClutEntry<oo(oi).maxEntry);
        assert(oo(oi).firstGrayClutEntry>1);
        assert(mod(oo(oi).firstGrayClutEntry+oo(oi).lastGrayClutEntry,2) == 0) % Must be even, so middle is an integer.
        oo(oi).minLRange=0;
    end % for oi=1:conditions
    BackupCluts(oo(1).screen);

    %% SET SIZES OF SCREEN ELEMENTS: text, stimulusRect, etc.
    for oi=1:conditions
        textFont='Verdana';
        if ismember(oo(oi).task,{'identify' 'identifyAll'})
            oo(oi).showResponseNumbers=false; % Inappropriate so suppress.
            switch oo(oi).alphabetPlacement
                case 'right'
                    oo(oi).stimulusRect(3)=oo(oi).stimulusRect(3)-RectHeight(o.screenrect)/max(6,oo(oi).alternatives);
                case 'top'
                    oo(oi).stimulusRect(2)=max(oo(oi).stimulusRect(2),o.screenrect(2)+0.5*RectWidth(o.screenrect)/max(6,oo(oi).alternatives));
                otherwise
                    error('Unknown alphabetPlacement "%d".\n',oo(oi).alphabetPlacement);
            end
        end
        oo(oi).stimulusRect=2*round(oo(oi).stimulusRect/2);
        switch oo(oi).task
            case {'identify' 'identifyAll' 'rate'}
                oo(oi).targetHeightPix=2*round(0.5*oo(oi).targetHeightDeg/oo(oi).targetCheckDeg)*oo(oi).targetCheckPix; % even round multiple of check size
                if oo(oi).targetHeightPix < oo(oi).minimumTargetHeightChecks*oo(oi).targetCheckPix
                    msg=sprintf('Increasing requested targetHeight checks from %d to %d, the minimum.\n',oo(oi).targetHeightPix/oo(oi).targetCheckPix,oo(oi).minimumTargetHeightChecks);
                    warning(msg);
                    fprintf(ff(end),msg);
                    oo(oi).targetHeightPix=2*ceil(0.5*oo(oi).minimumTargetHeightChecks)*oo(oi).targetCheckPix;
                end
            otherwise
                oo(oi).targetHeightPix=round(oo(oi).targetHeightDeg/oo(oi).targetCheckDeg)*oo(oi).targetCheckPix; % round multiple of check size
        end
        switch oo(oi).task
            case {'identify' 'identifyAll' 'rate'}
                maxStimulusHeight=RectHeight(oo(oi).stimulusRect);
                maxStimulusWidth=RectWidth(oo(oi).stimulusRect);
            case '4afc'
                maxStimulusHeight=floor(RectHeight(oo(oi).stimulusRect)/(2+oo(oi).gapFraction4afc));
                maxStimulusWidth=floor(RectWidth(oo(oi).stimulusRect)/(2+oo(oi).gapFraction4afc));
            otherwise
                error('Unknown o.task "%s".',oo(oi).task);
        end
        oo(oi).targetHeightDeg=oo(oi).targetHeightPix/oo(oi).pixPerDeg;
        if oo(oi).noiseRadiusDeg > maxStimulusHeight/oo(oi).pixPerDeg
            ffprintf(ff,'Reducing requested o.noiseRadiusDeg (%.1f deg) to %.1f deg, the max possible.\n',...
                oo(oi).noiseRadiusDeg,maxStimulusHeight/oo(oi).pixPerDeg);
            oo(oi).noiseRadiusDeg=maxStimulusHeight/oo(oi).pixPerDeg;
        end
        if oo(oi).useFlankers
            flankerSpacingPix=round(oo(oi).flankerSpacingDeg*oo(oi).pixPerDeg);
        end
        % The actual clipping is done using o.stimulusRect. This restriction of
        % noiseRadius and annularNoiseBigRadius is merely to save time (and
        % excessive texture size) by not computing pixels that won't be seen.
        % The actual clipping is done using o.stimulusRect.
        oo(oi).noiseRadiusDeg=max(oo(oi).noiseRadiusDeg,0);
        oo(oi).noiseRadiusDeg=min(oo(oi).noiseRadiusDeg,RectWidth(o.screenrect)/oo(oi).pixPerDeg);
        oo(oi).noiseRaisedCosineEdgeThicknessDeg=max(0,oo(oi).noiseRaisedCosineEdgeThicknessDeg);
        oo(oi).noiseRaisedCosineEdgeThicknessDeg=min(oo(oi).noiseRaisedCosineEdgeThicknessDeg,2*oo(oi).noiseRadiusDeg);
        oo(oi).annularNoiseSmallRadiusDeg=max(oo(oi).noiseRadiusDeg,oo(oi).annularNoiseSmallRadiusDeg); % "noise" and annularNoise cannot overlap.
        oo(oi).annularNoiseBigRadiusDeg=max(oo(oi).annularNoiseBigRadiusDeg,oo(oi).annularNoiseSmallRadiusDeg); % Big radius is at least as big as small radius.
        oo(oi).annularNoiseBigRadiusDeg=min(oo(oi).annularNoiseBigRadiusDeg,RectWidth(o.screenrect)/oo(oi).pixPerDeg);
        oo(oi).annularNoiseSmallRadiusDeg=min(oo(oi).annularNoiseBigRadiusDeg,oo(oi).annularNoiseSmallRadiusDeg); % Big radius is at least as big as small radius.
        if isnan(oo(oi).blankingRadiusReTargetHeight)
            switch oo(oi).targetKind
                case 'letter'
                    oo(oi).blankingRadiusReTargetHeight=1.5; % Make blanking radius 1.5 times
                    %                                       % target height. That's a good
                    %                                       % value for letters, which are
                    %                                       % strong right up to the edge of
                    %                                       % the target height.
                case 'gabor'
                    oo(oi).blankingRadiusReTargetHeight=0.5; % Make blanking radius 0.5 times
                    %                                       % target height. That's good for gabors,
                    %                                       % which are greatly diminished
                    %                                       % at their edge.
                case 'image'
                    oo(oi).blankingRadiusReTargetHeight=1.5; % Make blanking radius 1.5 times
                    %                                       % target height. That's a good
                    %                                       % value for images, which are
                    %                                       % strong right up to the edge of
                    %                                       % the target height.
            end
        end
        if ~isempty(oo(1).window)
            fixationCrossPix=round(oo(oi).fixationCrossDeg*oo(oi).pixPerDeg);
            fixationCrossWeightPix=round(oo(oi).fixationCrossWeightDeg*oo(oi).pixPerDeg);
            [~,~,lineWidthMinMaxPix(1),lineWidthMinMaxPix(2)]=Screen('DrawLines',oo(oi).window);
            fixationCrossWeightPix=round(max([min([fixationCrossWeightPix lineWidthMinMaxPix(2)]) lineWidthMinMaxPix(1)]));
            oo(oi).fixationCrossWeightDeg=fixationCrossWeightPix/oo(oi).pixPerDeg;
        else
            oo(oi).useFixation=false;
        end
        % BEWARE: The caption rects may differ between conditions and ought
        % to be stored in the condition, e.g. oo.topCaptionRect. The entire
        % screen is in o.screenrect. The stimulus is in stimulusRect, which
        % is within o.screenrect. Every pixel not in stimulusRect is in one
        % or more of the caption rects, which form a border on three sides
        % of the screen. The caption rects overlap at the corners of the
        % screen.
        topCaptionRect=o.screenrect;
        topCaptionRect(4)=oo(oi).stimulusRect(2); % top caption (trial number)
        bottomCaptionRect=o.screenrect;
        bottomCaptionRect(2)=oo(oi).stimulusRect(4); % bottom caption (instructions)
        rightCaptionRect=o.screenrect;
        rightCaptionRect(1)=oo(oi).stimulusRect(3); % right caption
        leftCaptionRect=o.screenrect;
        leftCaptionRect(3)=oo(oi).stimulusRect(1); % left caption
        % The caption rects are hardly used. It turns out that I typically
        % do a FillRect of screenRect with the caption background (1), and
        % then a smaller FillRect of stimulusRect with the stimulus
        % background (128).
        textStyle=0; % plain
    end % for oi=1:conditions
    
    %% PARAMETERS RELATED TO THRESHOLD
    for oi=1:conditions
        o=oo(oi);
        switch o.task
            case '4afc'
                oo(oi).idealT64=-.90;
            case {'identify' 'identifyAll' 'rate'}
                oo(oi).idealT64=-0.30;
        end
        switch o.observer
            case o.algorithmicObservers
                if isempty(oo(oi).steepness) || ~isfinite(oo(oi).steepness)
                    oo(oi).steepness=1.7;
                end
                if isempty(oo(oi).trialsPerBlock) || ~isfinite(oo(oi).trialsPerBlock)
                    oo(oi).trialsPerBlock=1000;
                end
                if isempty(oo(oi).blocksDesired) || ~isfinite(oo(oi).blocksDesired)
                    oo(oi).blocksDesired=10;
                end
                %         degPerCm=57/oo(oi).viewingDistanceCm;
                %         oo(oi).pixPerCm=45; % for MacBook at native resolution.
                %         oo(oi).pixPerDeg=oo(oi).pixPerCm/degPerCm;
            otherwise
                if isempty(oo(oi).steepness) || ~isfinite(oo(oi).steepness)
                    switch o.targetModulates
                        case 'luminance'
                            oo(oi).steepness=3.5;
                        case {'noise', 'entropy'}
                            oo(oi).steepness=1.7;
                    end
                end
        end
        if streq(o.task,'4afc')
            oo(oi).alternatives=1;
        end
        
        %% NUMBER OF POSSIBLE SIGNALS
        if oo(oi).alternatives > length(oo(oi).alphabet)
            error('Too many o.alternatives');
        end
        oo(oi).signal=[];
        for i=1:oo(oi).alternatives
            oo(oi).signal(i).letter=oo(oi).alphabet(i);
        end
    end % for oi=1:conditions
    
    %% REPORT CONFIGURATION
    [screenWidthMm, screenHeightMm]=Screen('DisplaySize',cal.screen);
    cal.screenWidthCm=screenWidthMm/10;
    ffprintf(ff,'Computer %s, %s, screen %d, %dx%d, %.1fx%.1f cm\n',cal.localHostName,cal.macModelName,cal.screen,RectWidth(o.screenrect),RectHeight(o.screenrect),screenWidthMm/10,screenHeightMm/10);
    assert(cal.screenWidthCm == screenWidthMm/10);
    ffprintf(ff,'Computer account %s.\n',cal.processUserLongName);
    ffprintf(ff,'%s %s calibrated by %s on %s.\n',cal.localHostName,cal.macModelName,cal.calibratedBy,cal.datestr);
    ffprintf(ff,'%s\n',cal.notes);
    ffprintf(ff,'cal.ScreenConfigureDisplayBrightnessWorks=%.0f;\n',cal.ScreenConfigureDisplayBrightnessWorks);
    if ~all(ismember([oo.observer],o.algorithmicObservers)) && ismac && isfield(cal,'profile')
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
    for oi=1:conditions
        if streq(oo(oi).observer,'brightnessSeeker')
            ffprintf(ff,'Condition %d: o.observerQuadratic %.2f\n',oi,oo(oi).observerQuadratic);
        end
    end

    %% GET DETAILS OF THE OPEN WINDOW
    o=oo(1);
    if ~isempty(o.window)
        % ListenChar(2) sets no-echo mode that allows us to collect
        % keyboard responses without any danger of inadvertenly writing to
        % the MATLAB command window or the program's text.
        ListenChar(2); % no echo
        % If o.observer is human, we need an open window for the whole
        % experiment, in which to display stimuli. If o.observer is machine,
        % we need a screen only briefly, to create the targets to be
        % identified.
        if false
            % This code to enable dithering is what Mario suggested, but it
            % makes no difference at all. I get dithering on my MacBook Pro
            % and iMac if and only if I EnableNative10BitFramebuffer, above. I
            % haven't tested whether this dithering-control code affects my
            % MacBook Air, but that's irrelevant since its screen is too
            % viewing-angle dependent for use in measuring threshold, which is
            % why I need dithering.
            windowInfo=Screen('GetWindowInfo',o.window);
            [oo.displayCoreId]=deal(windowInfo.DisplayCoreId);
            switch(o.displayCoreId)
                case 'AMD'
                    [oo.displayEngineVersion]=deal(windowInfo.GPUMinorType/10);
                    switch(round(o.displayEngineVersion))
                        case 6
                            [oo.displayGPUFamily]=deal('Southern Islands');
                            % Examples:
                            % AMD Radeon R9 M290X in MacBook Pro (Retina, 15-inch, Mid 2015)
                            % AMD Radeon R9 M370X in iMac (Retina 5K, 27-inch, Late 2014)
                            o.ditherClut=61696;
                        case 8
                            [oo.displayGPUFamily]=deal('Sea Islands');
                            % Used in hp Z Book laptop.
                            o.ditherClut=59648; % Untested.
                            % MARIO: Another number you could try is 59648. This
                            % would enable dithering for a native 8 bit panel, which
                            % is the wrong thing to do for the laptops 10 bit panel,
                            % assuming the driver docs are correct. But then, who
                            % knows?
                    end
            end
            Screen('ConfigureDisplay','Dithering',cal.screen,o.ditherClut);
        end % if false
        
        % Recommended by Mario Kleiner, July 2017.
        % The first 'DrawText' call triggers loading of the plugin, but may fail.
        Screen('DrawText',o.window,' ',0,0,0,1,1);
        o.drawTextPlugin=Screen('Preference','TextRenderer')>0;
        if ~o.drawTextPlugin
            warning('The DrawText plugin failed to load. See warning above.');
        end
        ffprintf(ff,'o.drawTextPlugin %s %% Need true for accurate text rendering.\n',mat2str(o.drawTextPlugin));
        [oo.drawTextPlugin]=deal(o.drawTextPlugin);

        % Recommended by Mario Kleiner, July 2017.
        winfo=Screen('GetWindowInfo', o.window);
        o.beamPositionQueriesAvailable= winfo.Beamposition ~= -1 && winfo.VBLEndline ~= -1;
        ffprintf(ff,'o.beamPositionQueries %s %% true for best timing.\n',mat2str(o.beamPositionQueriesAvailable));
        [oo.beamPositionQueriesAvailable]=deal(o.beamPositionQueriesAvailable);
        if ismac
            % Rec by microfish@fishmonkey.com.au, July 22, 2017
            o.psychtoolboxKernelDriverLoaded=~system('kextstat -l -k | grep PsychtoolboxKernelDriver > /dev/null');
            ffprintf(ff,'o.psychtoolboxKernelDriverLoaded %s %% true for best timing.\n',mat2str(o.psychtoolboxKernelDriverLoaded));
        else
            o.psychtoolboxKernelDriverLoaded=false;
        end
        [oo.psychtoolboxKernelDriverLoaded]=deal(o.psychtoolboxKernelDriverLoaded);
        
        % Compare hardware CLUT with identity.
        gammaRead=Screen('ReadNormalizedGammaTable',o.window);
        maxEntry=size(gammaRead,1)-1;
        gamma=repmat(((0:maxEntry)/maxEntry)',1,3);
        delta=gammaRead(:,2)-gamma(:,2);
        ffprintf(ff,'RMS difference between identity and read-back of hardware CLUT (%dx%d): %.9f\n',...
            size(gammaRead),rms(delta));
        
        % Load a linear CLUT. 
        if exist('cal','var')
            LMin=min(cal.old.L);
            LMax=max(cal.old.L);
            % o.LBackground=o.luminanceFactor*mean([LMin LMax]); % Already set above.
            % o.LBackground=o.LBackground*(1+(rand-0.5)/32); % Tiny jitter, ±1.5%
            % First entry is black.
            cal.gamma(1,1:3)=0; % Black.
            % Second entry (CLUT entry 1) is o.gray1. We have two clut
            % entries that produce the same gray. One (o.gray) is in the
            % middle of the CLUT and the other is at a low entry, near
            % black. The benefit of having small o.gray1 is that we get
            % better blending of letters written (as black=0) on that
            % background by Screen DrawText.
            o.gray1=1/o.maxEntry;
            [oo.gray1]=deal(o.gray1);
            assert(o.gray1*o.maxEntry <= o.firstGrayClutEntry-1);
            % o.gray1 is between black and the darkest stimulus luminance.
            cal.LFirst=o.LBackground;
            cal.LLast=o.LBackground;
            cal.nFirst=o.gray1*o.maxEntry;
            cal.nLast=o.gray1*o.maxEntry;
            cal=LinearizeClut(cal);
            L1=LuminanceOfIndex(cal,o.gray1*o.maxEntry);
            ffprintf(ff,'%d: o.gray1*o.maxEntry= %.0f, LBackground %.0f, LFirst %.0f, LLast %.0f, nFirst %.0f, nLast %.0f\n',...
                MFileLineNr,o.gray1*o.maxEntry,o.LBackground,cal.LFirst,cal.LLast,cal.nFirst,cal.nLast);
            fprintf('o.gray1*o.maxEntry %.1f yields %.1f cd/m^2 vs. LBackground %.1f cd/m^2.\n',...
                o.gray1*o.maxEntry,o.LBackground,L1);
            if false
                % Can't use ComputeClut yet, because o.noiseListMin is not
                % yet defined.
                [cal,o]=ComputeClut(cal,o);
            else
                % Devote most of the CLUT entries to the stimulus. This is
                % a crummy CLUT for temporary use, before testing. It's
                % linear, but it spans the display's entire range instead
                % of optimizing resolution by spanning of the luminance
                % range we need. We use it merely to show the right gray
                % level as we ask the observer questions. This allows some
                % light adaptation before the testing begins.
                cal.LFirst=LMin;
                if o.symmetricLuminanceRange
                    cal.LLast=o.LBackground+(o.LBackground-LMin); % Symmetric about o.LBackground.
                else
                    cal.LLast=LMax;
                end
                cal.nFirst=o.firstGrayClutEntry;
                cal.nLast=o.lastGrayClutEntry;
                cal=LinearizeClut(cal);
            end
            ffprintf(ff,'Size of cal.gamma %d %d\n',size(cal.gamma));
            if o.symmetricLuminanceRange
                % Choose "gray" in middle of CLUT.
                oo(1).gray=round(mean([o.firstGrayClutEntry o.lastGrayClutEntry]))/o.maxEntry; % CLUT color code for gray.
            else
                if isfield(oo(1),'gray')
                    oldGray=oo(1).gray;
                else
                    oldGray=[];
                end
                oo(1).gray=IndexOfLuminance(cal,o.LBackground)/o.maxEntry;
                if o.printGrayLuminance
                    ffprintf(ff,'%d: o.gray old vs new %.2f %.2f\n',MFileLineNr,oldGray,o.gray);
                    ffprintf(ff,'o.contrast %.2f, o.LBackground %.0f cd/m^2, cal.old.L(end) %.0f cd/m^2\n',o.contrast,o.LBackground,cal.old.L(end));
                    ffprintf(ff,'o.LBackground %.0f cd/m^2, cal.old.L(end) %.0f cd/m^2\n',o.LBackground,cal.old.L(end));
                    ffprintf(ff,'o.luminanceAtEye %.2f cd/m^2, o.filterTransmission %.3f, o.luminanceFactor %.2f\n',...
                        o.luminanceAtEye,o.filterTransmission,o.luminanceFactor);
                    ffprintf(ff,'%d: o.maxEntry*[o.gray1 o.gray]=[%.1f %.1f]\n',...
                        MFileLineNr,o.maxEntry*[o.gray1 o.gray]);
                    disp('cal.gamma(1+[o.gray1 o.gray]*o.maxEntry,:)');
                    disp(cal.gamma(1+[o.gray1 o.gray]*o.maxEntry,:));
                    disp('Luminance');
                    g=cal.gamma(1+[o.gray1 o.gray]*o.maxEntry,:);
                    disp(interp1(cal.old.G,cal.old.L,g,'pchip'));
                end
            end
            [oo.gray]=deal(oo(1).gray);
            o=oo(1);
            Screen('LoadNormalizedGammaTable',o.window,cal.gamma,loadOnNextFlip);
            if o.assessLoadGamma
                fffprintf(ff,ff,'Line %d: o.contrast %.3f, LoadNormalizedGammaTable 0.5*range/mean=%.3f\n', ...
                    MFileLineNr,o.contrast,(cal.LLast-cal.LFirst)/(cal.LLast+cal.LFirst));
            end
            Screen('FillRect',o.window,o.gray1);
            Screen('FillRect',o.window,o.gray,o.stimulusRect);
        else
            Screen('FillRect',o.window);
            oo(1).gray=0.5;
        end % if exist('cal','var')
        Screen('Flip',o.window); % Load gamma table
        if ~isfinite(o.window) || o.window == 0
            ffprintf(ff,'error\n');
            error('Screen OpenWindow failed. Please try again.');
        end
        black=0; % CLUT color code for black.
        white=1; % CLUT color code for white.
        Screen('FillRect',o.window,o.gray1);
        Screen('FillRect',o.window,o.gray,o.stimulusRect);
        Screen('Flip',o.window); % Screen is now all gray, at o.LBackground.
        o.screenrect=Screen('Rect',o.window,1);
        screenWidthPix=RectWidth(o.screenrect);
        o.pixPerCm=screenWidthPix/cal.screenWidthCm;
    else
        o.screenrect=[0 0 1280 800];
        screenWidthPix=RectWidth(o.screenrect);
        o.pixPerCm=screenWidthPix/33.1;
    end % if ~isempty(o.window)
    [oo.screenrect]=deal(o.screenrect);
    degPerCm=57/o.viewingDistanceCm;
    o.pixPerDeg=o.pixPerCm/degPerCm;
    
    if false
        %% CONFIRM OLD ANSWERS IF STALE OR OBSERVER CHANGED
        if ~isempty(o.window)
            if ~isempty(oOld) && (GetSecs-oOld.secs>10*60 || ~streq(oOld.observer,o.observer))
                Screen('Preference','TextAntiAliasing',1);
                % o.textSize=TextSizeToFit(o.window); % Nicer size, but text would
                % need wrapping.
                Screen('TextSize',o.window,o.textSize);
                Screen('TextFont',o.window,'Verdana');
                Screen('FillRect',o.window,o.gray1);
                string=sprintf('Confirm experimenter "%s" and observer "%s"?',o.experimenter,o.observer);
                if o.useFilter
                    string=sprintf('%s With filter transmission %.3f?',string,o.filterTransmission);
                end
                string=sprintf('%s Right?\nHit RETURN to continue, or ESCAPE to quit.',string);
                Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
                DrawFormattedText(o.window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
                Screen('Flip',o.window); % Display request.
                if o.speakInstructions
                    Speak(sprintf('Observer %s, right? If ok, hit RETURN to continue, otherwise hit ESCAPE to quit.',o.observer));
                end
                fprintf('*Confirming observer name.\n');
                response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode],o.deviceIndex);
                if ismember(response,[escapeChar,graveAccentChar])
                    if o.speakInstructions
                        Speak('Quitting.');
                    end
                    o.quitBlock=true;
                    o.quitExperiment=true;
                    oo(1).quitExperiment=true;
                    ListenChar;
                    ShowCursor;
                    sca;
                    window=[];
                    [oo.window]=deal([]);
                    return
                end
            end
        end
    end % if false
    
    %% MONOCULAR?
    for oi=1:conditions
        if ~streq(oo(oi).eyes,oo(1).eyes)
            error('All conditions must use same o.eyes.');
        end
    end
    if ~ismember(o.eyes,{'left','right','both'})
        error('o.eyes==''%s'' is not allowed. It must be ''left'',''right'', or ''both''.',o.eyes);
    end
    if ~isempty(o.window)
        if ~isfield(oOld,'eyes') || GetSecs-oOld.secs>5*60 || ~streq(oOld.eyes,o.eyes)
            Screen('TextSize',o.window,o.textSize);
            Screen('TextFont',o.window,'Verdana');
            Screen('FillRect',o.window,o.gray1);
            switch o.eyes
                case 'both'
                    Screen('Preference','TextAntiAliasing',1);
                    string='Please use both eyes.\nHit RETURN to continue, or ESCAPE to quit.';
                    Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
                    DrawFormattedText(o.window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
                    Screen('Flip',o.window); % Display request.
                    if o.speakInstructions
                        Speak('Please use both eyes. Hit RETURN to continue, or ESCAPE to quit.');
                    end
                    fprintf('*Asking which eye(s).\n');
                    response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode],o.deviceIndex);
                    if ismember(response,[escapeChar,graveAccentChar])
                        if o.speakInstructions
                            Speak('Quitting.');
                        end
                        o.quitBlock=true;
                        o.quitExperiment=true;
                        oo(1).quitExperiment=true;
                        ListenChar;
                        ShowCursor;
                        sca;
                        window=[];
                        [oo.window]=deal([]);
                        return
                    end
                case {'left','right'}
                    Screen('Preference','TextAntiAliasing',1);
                    string=sprintf('Please use just your %s eye. Cover your other eye.\nHit RETURN to continue, or ESCAPE to quit.',o.eyes);
                    Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
                    DrawFormattedText(o.window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
                    Screen('Flip',o.window); % Display request.
                    if o.speakInstructions
                        string=sprintf('Please use just your %s eye. Cover your other eye. Hit RETURN to continue, or ESCAPE to quit.',o.eyes);
                        Speak(string);
                    end
                    fprintf('*Telling observer which eye(s) to use.\n');
                    response=GetKeypress([escapeKeyCode graveAccentKeyCode returnKeyCode],o.deviceIndex);
                    if ismember(response,[escapeChar,graveAccentChar])
                        if o.speakInstructions
                            Speak('Quitting.');
                        end
                        o.quitBlock=true;
                        o.quitExperiment=true;
                        oo(1).quitExperiment=true;
                        ListenChar;
                        ShowCursor;
                        sca;
                        window=[];
                        [oo.window]=deal([]);
                        return
                    end
            end
            string='';
            while streq(o.eyes,'one')
                Screen('Preference','TextAntiAliasing',1);
                string=[string 'Which eye will you use, left or right? Please type L or R:'];
                Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
                DrawFormattedText(o.window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
                Screen('Flip',o.window); % Display request.
                if o.speakInstructions
                    Speak(string);
                end
                fprintf('*Asking observer which eye(s).\n');
                response=GetKeypress([KbName('L') KbName('R') escapeKeyCode graveAccentKeyCode],o.deviceIndex);
                if ismember(response,[escapeChar,graveAccentChar])
                    if o.speakInstructions
                        Speak('Quitting.');
                    end
                    o.quitBlock=true;
                    o.quitExperiment=true;
                    oo(1).quitExperiment=true;
                    ListenChar;
                    ShowCursor;
                    sca;
                    window=[];
                    [oo.window]=deal([]);
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
            Screen('FillRect',o.window,o.gray1);
            Screen('Flip',o.window); % Blank to acknowledge response.
        end
        switch o.eyes
            case 'both'
                ffprintf(ff,'Observer is using %s eyes.\n',o.eyes);
            case {'left' 'right'}
                ffprintf(ff,'Observer is using %s eye.\n',o.eyes);
        end
    end

    %% LOCATE FIXATION AND NEAR-POINT OF DISPLAY
    % VIEWING GEOMETRY: DISPLAY NEAR POINT
    % o.nearPointXYInUnitSquare % Usually the desired target location in o.stimulusRect re lower-left corner.
    % o.nearPointXYPix % Near-point screen coordinate. 
    % o.viewingDistanceCm % Distance from eye to near point.
    % o.nearPointXYDeg % (x,y) eccentricity of near point.
    % 1. Assign target ecc. to display near point. 
    % 2. Pick a good (x,y) on the screen for the display near point.
    % 3. Ask viewer to adjust display to adjust display distance from
    % viewer's eye so (x,y) is at desired viewing distance and orthogonal
    % to line of sight from eye to (x,y).
    % 4. If using off-screen fixation, put it at same distance (as near
    % point) from eye, and compute its position, left or right of (x,y) to
    % put (x,y) at desired ecc.
    
    % THE CANVAS: o.canvasSize & canvasRect. The arrays that hold the noise
    % and the stimulus all have size o.canvasSize. canvasRect is just [0 0
    % canvasSize(2) canvasSize(1)]. o.canvasSize is clipped (if necessary)
    % to fit in o.stimulusRect. Each pixel represents a targetCheck (each
    % with size [o.targetCheckPix o.targetCheckPix]).  The target is
    % centered in the canvasRect-sized array. I think (not sure) the
    % canvasRect-sized array is centered in o.stimulusRect. If true, that
    % seems an obsolete strategy, now that we designate an arbitrary point
    % on the screen as the near point. It seems more appropiate to center
    % the canvasRect on the target position, o.eccentricityXYDeg.
    % denis.pelli@nyu.edu April 4, 2018.
    
    % PLACE TARGET AT NEAR POINT
    % Imaging is best (highest resolution) at the near point, so it's a
    % good idea to place the target at or near the near point. However, I
    % believe none of this program assumes any particular relation between
    % the two, other that the statement immediately below that locates the
    % target at the near point.
    oo(1).nearPointXYDeg=o.eccentricityXYDeg; 
    
    fprintf('*Waiting for observer to set viewing distance.\n');
    o=SetUpNearPoint(oo(1));
    [oo.nearPointXYPix]=deal(o.nearPointXYPix);
    [oo.nearPointXYInUnitSquare]=deal(o.nearPointXYInUnitSquare);
    if o.quitExperiment
        oo(1).quitExperiment=true;
        ListenChar;
        ShowCursor;
        sca;
        window=[];
        [oo.window]=deal([]);
        return
    end
    
    fprintf('*Waiting for observer to set up fixation.\n');
    o=SetUpFixation(oo(1),ff);
    [oo.fixationIsOffscreen]=deal(o.fixationIsOffscreen);
    [oo.targetXYPix]=deal(o.targetXYPix);
    [oo.fixationXYPix]=deal(o.fixationXYPix);
    [oo.fixationIsOffscreen]=deal(oo.fixationIsOffscreen);

    if oo(1).quitExperiment
        ListenChar;
        ShowCursor;
        sca;
        window=[];
        [oo.window]=deal([]);
       return
    end
    
    [oo.nearPointXYDeg]=deal(o.nearPointXYDeg);
    gapPix=round(o.gapFraction4afc*o.targetHeightPix);
    
    %% Compute NPhoton
    oo=ComputeNPhoton(oo);
  
    %% SET NOISE PARAMETERS
    for oi=1:conditions
        oo(oi).targetWidthPix=oo(oi).targetHeightPix;
        oo(oi).targetHeightPix=oo(oi).targetCheckPix*round(oo(oi).targetHeightPix/oo(oi).targetCheckPix);
        oo(oi).targetWidthPix=oo(oi).targetCheckPix*round(oo(oi).targetWidthPix/oo(oi).targetCheckPix);
        
        MAX_FRAMES=100; % Better to limit than crash the GPU.
        if ~isempty(o.window)
            displayFrameRate=1/Screen('GetFlipInterval',o.window);
        else
            displayFrameRate=60;
        end
        if isfinite(oo(oi).noiseCheckSecs)
            % Rely on o.noiseCheckSecs if specified.
            oo(oi).noiseCheckFrames=round(oo(oi).noiseCheckSecs*displayFrameRate);
            % From here on, rely on o.noiseCheckFrames.
        end
        oo(oi).noiseCheckFrames=max(1,round(oo(oi).noiseCheckFrames));
        oo(oi).noiseCheckSecs=oo(oi).noiseCheckFrames/displayFrameRate;
        movieFrameRate=displayFrameRate/oo(oi).noiseCheckFrames;
        ffprintf(ff,'Display frame rate %.1f Hz. Movie frame rate %.1f Hz.\n',displayFrameRate,movieFrameRate);
        oo(oi).targetDurationSecs=max(1,round(oo(oi).targetDurationSecs*movieFrameRate))/movieFrameRate;
        oo(oi).targetDurationListSecs=max(1,round(oo(oi).targetDurationListSecs*movieFrameRate))/movieFrameRate;
        if ~oo(oi).useDynamicNoiseMovie
            oo(oi).moviePreFrames=0;
            oo(oi).movieSignalFrames=1;
            oo(oi).moviePostFrames=0;
        else
            oo(oi).moviePreFrames=round(oo(oi).moviePreSecs*movieFrameRate);
            oo(oi).movieSignalFrames=round(oo(oi).targetDurationSecs*movieFrameRate);
            if oo(oi).movieSignalFrames < 1
                oo(oi).movieSignalFrames=1;
            end
            oo(oi).moviePostFrames=round(oo(oi).moviePostSecs*movieFrameRate);
            if oo(oi).moviePreFrames+oo(oi).moviePostFrames>=MAX_FRAMES
                error('o.moviePreSecs+o.moviePostSecs=%.1f s too long for movie with MAX_FRAMES %d.\n',...
                    oo(oi).moviePreSecs+oo(oi).moviePostSecs,MAX_FRAMES);
            end
        end
        oo(oi).movieFrames=oo(oi).moviePreFrames+oo(oi).movieSignalFrames+oo(oi).moviePostFrames;
        if oo(oi).movieFrames>MAX_FRAMES
            oo(oi).movieFrames=MAX_FRAMES;
            oo(oi).movieSignalFrames=oo(oi).movieFrames-oo(oi).moviePreFrames-oo(oi).moviePostFrames;
            oo(oi).targetDurationSecs=oo(oi).movieSignalFrames/movieFrameRate;
            ffprintf(ff,'Constrained by MAX_FRAMES %d, reducing duration to %.3f s\n',MAX_FRAMES,oo(oi).targetDurationSecs);
        end
        
        ffprintf(ff,'o.pixPerDeg %.1f, o.viewingDistanceCm %.1f\n',oo(oi).pixPerDeg,oo(oi).viewingDistanceCm);
        switch o.task
            case {'identify' 'identifyAll' 'rate'}
                ffprintf(ff,'Minimum letter resolution is %.0f checks.\n',oo(oi).minimumTargetHeightChecks);
        end
        switch o.targetKind
            case {'letter' 'image'}
                ffprintf(ff,'o.font %s\n',oo(oi).font);
            case 'gabor'
                ffprintf(ff,'o.targetGaborSpaceConstantCycles %.1f\n',oo(oi).targetGaborSpaceConstantCycles);
                ffprintf(ff,'o.targetGaborCycles %.1f\n',oo(oi).targetGaborCycles);
                ffprintf(ff,'o.targetGaborOrientationsDeg [');
                ffprintf(ff,' %.0f',oo(oi).targetGaborOrientationsDeg);
                ffprintf(ff,']\n');
            otherwise
                error('Unknown o.targetKind "%s".',oo(oi).targetKind);
        end
        ffprintf(ff,'o.targetHeightPix %.0f, o.targetCheckPix %.0f, o.noiseCheckPix %.0f, o.targetDurationSecs %.2f s\n',...
            oo(oi).targetHeightPix,oo(oi).targetCheckPix,oo(oi).noiseCheckPix,oo(oi).targetDurationSecs);
        ffprintf(ff,'o.targetModulates %s\n',oo(oi).targetModulates);
        ffprintf(ff,'o.thresholdParameter %s\n',oo(oi).thresholdParameter);
        if streq(oo(oi).targetModulates,'entropy')
            oo(oi).noiseType='uniform';
            ffprintf(ff,'o.backgroundEntropyLevels %d\n',oo(oi).backgroundEntropyLevels);
        end
        ffprintf(ff,'o.noiseType %s, o.noiseSD %.3f',oo(oi).noiseType,oo(oi).noiseSD);
        if isfinite(oo(oi).annularNoiseSD)
            ffprintf(ff,', o.annularNoiseSD %.3f',oo(oi).annularNoiseSD);
        end
        if oo(oi).noiseFrozenInTrial
            ffprintf(ff,', frozenInTrial');
        end
        if oo(oi).noiseFrozenInBlock
            ffprintf(ff,', frozenInBlock');
        end
        ffprintf(ff,'\n');
        oo(oi).noiseSize=2*oo(oi).noiseRadiusDeg*[1, 1]*oo(oi).pixPerDeg/oo(oi).noiseCheckPix;
        switch o.task
            case {'identify' 'identifyAll' 'rate'}
                oo(oi).noiseSize=2*round(oo(oi).noiseSize/2); % Even numbers, so we can center it on letter.
            case '4afc'
                oo(oi).noiseSize=round(oo(oi).noiseSize);
        end
        oo(oi).noiseRadiusDeg=0.5*oo(oi).noiseSize(1)*oo(oi).noiseCheckPix/oo(oi).pixPerDeg;
        noiseBorder=ceil(0.5*oo(oi).noiseRaisedCosineEdgeThicknessDeg*oo(oi).pixPerDeg/oo(oi).noiseCheckPix);
        oo(oi).noiseSize=oo(oi).noiseSize+2*noiseBorder;
        oo(oi).annularNoiseSmallSize=2*oo(oi).annularNoiseSmallRadiusDeg*[1, 1]*oo(oi).pixPerDeg/oo(oi).noiseCheckPix;
        oo(oi).annularNoiseSmallSize(2)=min(oo(oi).annularNoiseSmallSize(2),RectHeight(oo(oi).stimulusRect)/oo(oi).noiseCheckPix);
        oo(oi).annularNoiseSmallSize=2*round(oo(oi).annularNoiseSmallSize/2); % An even number, so we can center it on center of letter.
        oo(oi).annularNoiseSmallRadiusDeg=0.5*oo(oi).annularNoiseSmallSize(1)/(oo(oi).pixPerDeg/oo(oi).noiseCheckPix);
        oo(oi).annularNoiseBigSize=2*oo(oi).annularNoiseBigRadiusDeg*[1, 1]*oo(oi).pixPerDeg/oo(oi).noiseCheckPix;
        oo(oi).annularNoiseBigSize(2)=min(oo(oi).annularNoiseBigSize(2),RectHeight(oo(oi).stimulusRect)/oo(oi).noiseCheckPix);
        oo(oi).annularNoiseBigSize=2*round(oo(oi).annularNoiseBigSize/2); % An even number, so we can center it on center of letter.
        oo(oi).annularNoiseBigRadiusDeg=0.5*oo(oi).annularNoiseBigSize(1)/(oo(oi).pixPerDeg/oo(oi).noiseCheckPix);
        
        % Make o.canvasSize just big enough to hold everything we're showing,
        % including signal, flankers, and noise. o.canvasSize is in units of
        % targetChecks. We limit o.canvasSize to fit in o.stimulusRect (after
        % converting targetChecks to pixels). Note that o.canvasSize is [height
        % width], a MATLAB convention, whereas canvasRect is [0 0 width
        % height], an Apple convention.
        oo(oi).canvasSize=[oo(oi).targetHeightPix oo(oi).targetWidthPix]/oo(oi).targetCheckPix;
        oo(oi).canvasSize=2*oo(oi).canvasSize; % Denis. For extended noise background.
        if oo(oi).useFlankers
            oo(oi).canvasSize=oo(oi).canvasSize+[3 3]*flankerSpacingPix/oo(oi).targetCheckPix;
        end
        oo(oi).canvasSize=max(oo(oi).canvasSize,oo(oi).noiseSize*oo(oi).noiseCheckPix/oo(oi).targetCheckPix);
        if oo(oi).annularNoiseBigRadiusDeg > oo(oi).annularNoiseSmallRadiusDeg
            % April 2018, Denis changed denominator to targetCheckPix.
            oo(oi).canvasSize=max(oo(oi).canvasSize,2*oo(oi).annularNoiseBigRadiusDeg*[1 1]*oo(oi).pixPerDeg/oo(oi).targetCheckPix);
        end
        switch o.task
            case {'identify' 'identifyAll' 'rate'}
                % Clip o.canvasSize to fit inside o.stimulusRect (after
                % converting targetChecks to pixels). The target will be
                % centered in the canvas, so the code below to constrain the
                % canvas size ought to assume it's centered on the target, but
                % instead it seems to assume that the canvas is centered in
                % o.stimulusRect. This is not currently causing problems, so
                % I'm letting this sleeping dog lie.
                oo(oi).canvasSize=min(oo(oi).canvasSize,floor([RectHeight(oo(oi).stimulusRect) RectWidth(oo(oi).stimulusRect)]/oo(oi).targetCheckPix));
                oo(oi).canvasSize=2*ceil(oo(oi).canvasSize/2); % Even number of checks, so we can center it on letter.
            case '4afc'
                oo(oi).canvasSize=min(oo(oi).canvasSize,floor([maxStimulusHeight maxStimulusWidth]/oo(oi).targetCheckPix));
                oo(oi).canvasSize=ceil(oo(oi).canvasSize);
        end
        oo(oi).canvasSize=(oo(oi).noiseCheckPix/oo(oi).targetCheckPix)*ceil(oo(oi).canvasSize*oo(oi).targetCheckPix/oo(oi).noiseCheckPix); % Make it a multiple of noiseCheckPix.
        ffprintf(ff,'Noise height %.2f deg. Noise hole %.2f deg. Height is %.2fT and hole is %.2fT, where T is target height.\n', ...
            oo(oi).annularNoiseBigRadiusDeg*oo(oi).targetHeightDeg,oo(oi).annularNoiseSmallRadiusDeg*oo(oi).targetHeightDeg,oo(oi).annularNoiseBigRadiusDeg,oo(oi).annularNoiseSmallRadiusDeg);
        if oo(oi).useFlankers
            ffprintf(ff,'Adding %s flankers with nominal spacing of %.0f pix=%.1f deg=%.1fx letter height. Dark contrast %.3f (nan means same as target).\n',...
                oo(oi).flankerArrangement,flankerSpacingPix,flankerSpacingPix/oo(oi).pixPerDeg,flankerSpacingPix/oo(oi).targetHeightPix,oo(oi).flankerContrast);
        end
        if oo(oi).useFixation
            fix.markTargetLocation=oo(oi).markTargetLocation;
            fixationXYPix=round(XYPixOfXYDeg(o,[0 0])); % location of fixation
            fix.xy=fixationXYPix;            %  location of fixation on screen.
            fix.eccentricityXYPix=oo(oi).targetXYPix-fixationXYPix;  % xy offset of target from fixation.
            fix.clipRect=oo(oi).stimulusRect;
            fix.fixationCrossPix=fixationCrossPix;% Width & height of fixation cross.
            fix.targetMarkPix=oo(oi).targetMarkDeg*oo(oi).pixPerDeg;
            fix.blankingRadiusReEccentricity=oo(oi).blankingRadiusReEccentricity;
            fix.blankingRadiusReTargetHeight=oo(oi).blankingRadiusReTargetHeight;
            fix.targetHeightPix=oo(oi).targetHeightPix;
            [fixationLines,oo(oi).markTargetLocation]=ComputeFixationLines2(fix);
        end
        if ~isempty(o.window) && ~isempty(fixationLines)
            Screen('DrawLines',o.window,fixationLines,fixationCrossWeightPix,black); % fixation
        end
        clear tSample
        
        % Compute noiseList
        switch oo(oi).noiseType % Fill noiseList with desired kind of noise.
            case 'gaussian'
                oo(oi).noiseListMin=-2;
                oo(oi).noiseListMax=2;
                temp=randn([1 20000]);
                ok=oo(oi).noiseListMin<=temp & temp<=oo(oi).noiseListMax;
                noiseList=temp(ok);
                clear temp;
            case 'uniform'
                oo(oi).noiseListMin=-1;
                oo(oi).noiseListMax=1;
                noiseList=-1:1/1024:1;
            case 'binary'
                oo(oi).noiseListMin=-1;
                oo(oi).noiseListMax=1;
                noiseList=[-1 1];
            otherwise
                error('Unknown noiseType "%s"',oo(oi).noiseType);
        end
        
        % Compute MTF to filter the noise.
        fNyquist=0.5/oo(oi).noiseCheckDeg;
        fLow=0;
        fHigh=fNyquist;
        switch oo(oi).noiseSpectrum
            case 'pink'
                oo(oi).noiseSpectrumExponent=-1;
                if all(oo(oi).noiseSize > 0)
                    mtf=MtfPowerLaw(oo(oi).noiseSize,oo(oi).noiseSpectrumExponent,fLow/fNyquist,fHigh/fNyquist);
                else
                    mtf=[];
                end
                oo(oi).noiseIsFiltered=true;
            case 'white'
                mtf=ones(oo(oi).noiseSize);
                oo(oi).noiseIsFiltered=false;
        end
        if oo(oi).noiseSD == 0
            mtf=0;
        end
        
        oo(oi).noiseListSd=std(noiseList);
        % This safety check should be updated to check more rigorously. As
        % set above, o.LBackground=o.luminanceFactor*mean([LMin LMax]).
        % This (old) bit of code, which is just a safety check of the noise
        % list, assumes that the luminanceFactor=1, but that is not always
        % true. E.g. when testing faces we use a luminanceFactor=2 to make
        % LBackground nearly equal to LMax, to maximize brightness, and to
        % test low luminances we sometimes set luminanceFactor=0.1 to
        % produce a dim display. Also this code currently uses the upper
        % bound o.noiseListMax, and ignores the lower bound o.noiseListMin.
        % That's ok for now because the three allowed noise types, at the
        % moment, have symmetric bounds. I think, but haven't
        % double-checked, that ComputeClut is more rigorous, and merely
        % assumes that the background does not exceed the max possible,
        % LBackground<=LMax.
        a=0.9*oo(oi).noiseListSd/oo(oi).noiseListMax; % Max possible noiseSD, leaving a bit of range for signal.
        if oo(oi).noiseSD > a
            ffprintf(ff,'WARNING: Requested o.noiseSD %.2f too high. Reduced to %.2f\n',oo(oi).noiseSD,a);
            oo(oi).noiseSD=a;
        end
        if isfinite(oo(oi).annularNoiseSD) && oo(oi).annularNoiseSD > a
            ffprintf(ff,'WARNING: Requested o.annularNoiseSD %.2f too high. Reduced to %.2f\n',oo(oi).annularNoiseSD,a);
            oo(oi).annularNoiseSD=a;
        end
    end % for oi=1:conditions
    % END OF NOISE COMPUTATION
    
    %% PREPARE SOUNDS
    rightBeep=MakeBeep(2000,0.05);
    rightBeep(end)=0;
    wrongBeep=MakeBeep(500,0.5);
    wrongBeep(end)=0;
    temp=zeros(size(wrongBeep));
    temp(1:length(rightBeep))=rightBeep;
    rightBeep=temp; % extend rightBeep with silence to same length as wrongBeep
    okBeep=[0.03*MakeBeep(1000,0.1) 0*MakeBeep(1000,0.3)];
    purr=MakeBeep(200,0.6);
    purr(end)=0;
    Snd('Open');
    
    %% PREPARE TARGET IMAGE (I.E. SIGNAL)
    for oi=1:conditions
        switch oo(oi).task
            case '4afc'
                object='Square';
            case {'identify' 'identifyAll' 'rate'}
                object='Letter';
            otherwise
                error('Unknown task %d',oo(oi).task);
        end
        ffprintf(ff,'Target height %.1f deg is %.1 targetChecks or %.1f noiseChecks.\n',...
            oo(oi).targetHeightDeg,oo(oi).targetHeightPix/oo(oi).targetCheckPix,oo(oi).targetHeightPix/oo(oi).noiseCheckPix);
        ffprintf(ff,'%s size %.1f deg, targetCheck %.3f deg, noiseCheck %.3f deg.\n',...
            object,oo(oi).targetHeightDeg,oo(oi).targetCheckDeg,oo(oi).noiseCheckDeg);
        if streq(object,'Letter')
            ffprintf(ff,'Nominal letter size is %.2f deg. See o.alphabetHeightDeg below for actual size. \n',oo(oi).targetHeightDeg);
        end
        if streq(oo(oi).task,'4afc')
            ffprintf(ff,'o.gapFraction4afc %.2f, gapPix %.1f %.2f deg\n',oo(oi).gapFraction4afc,gapPix,gapPix/oo(oi).pixPerDeg);
        end
        if oo(oi).showCropMarks
            ffprintf(ff,'Showing crop marks.\n');
        else
            ffprintf(ff,'No crop marks.\n');
        end
        if streq(oo(oi).task,'4afc')
            if oo(oi).showResponseNumbers
                ffprintf(ff,'Showing response numbers.\n');
            else
                ffprintf(ff,'No response numbers. Assuming o.observer already knows them.\n');
            end
        end
        oo(oi).targetXYInUnitSquare=(oo(oi).targetXYPix-oo(oi).stimulusRect(1:2))./[RectWidth(oo(oi).stimulusRect) RectHeight(oo(oi).stimulusRect)];
        oo(oi).targetXYInUnitSquare(2)=1-oo(oi).targetXYInUnitSquare(2);
        string=sprintf('Target is at (%.1f %.1f) deg, (%.2f %.2f) in unit square. ',...
            oo(oi).eccentricityXYDeg,oo(oi).targetXYInUnitSquare);
        if oo(oi).useFixation
            if oo(oi).fixationIsOffscreen
                string=[string 'Using off-screen fixation mark.'];
            else
                string=[string 'Using on-screen fixation mark.'];
            end
        else
            string=[string 'No fixation.'];
        end
        ffprintf(ff,'%s\n',string);
        oo(oi).N=oo(oi).noiseCheckPix^2*oo(oi).pixPerDeg^-2*oo(oi).noiseSD^2;
        if oo(oi).useDynamicNoiseMovie
            oo(oi).noiseCheckSecs=1/movieFrameRate;
            oo(oi).N=oo(oi).N*oo(oi).noiseCheckSecs;
            oo(oi).NUnits='s deg^2';
            temporal='Dynamic';
        else
            oo(oi).noiseCheckSecs=oo(oi).targetDurationSecs;
            oo(oi).NUnits='deg^2';
            temporal='Static';
        end
        ffprintf(ff,'%s noise power spectral density N %s log=%.2f\n', ...
            temporal,oo(oi).NUnits,log10(oo(oi).N));
        ffprintf(ff,'pThreshold %.2f, steepness %.1f\n',oo(oi).pThreshold,oo(oi).steepness);
        ffprintf(ff,'o.trialsPerBlock %.0f\n',oo(oi).trialsPerBlock);
        
        %% COMPUTE oo(oi).signal(i).image FOR ALL i.
        tic
        white1=1;
        black0=0;
        Screen('Preference','TextAntiAliasing',0);
        switch oo(oi).task % Compute masks and envelopes
            case '4afc'
                % boundsRect contains all 4 positions.
                %
                % gapPix is NOT rounded to a multiple of o.targetCheckPix
                % because I think that each of the four alternatives is drawn
                % independently, so the gap could be a fraction of a
                % targetCheck.
                boundsRect=[-oo(oi).targetWidthPix, -oo(oi).targetHeightPix, oo(oi).targetWidthPix+gapPix, oo(oi).targetHeightPix+gapPix];
                boundsRect=CenterRect(boundsRect,[oo(oi).targetXYPix oo(oi).targetXYPix]);
                targetRect=round([0 0 oo(oi).targetHeightPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix);
                oo(oi).signal(1).image=ones(targetRect(3:4));
            case {'identify' 'identifyAll' 'rate'}
                switch oo(oi).targetKind
                    case 'letter'
                        if isempty(oo(oi).window)
                            % Some window must already be open before we call
                            % OpenOffscreenWindow.
                            temporaryWindow=Screen('OpenWindow',0,1,[0 0 100 100]);
                        end
                        scratchHeight=round(3*oo(oi).targetHeightPix/oo(oi).targetCheckPix);
                        [scratchWindow, scratchRect]=Screen('OpenOffscreenWindow',-1,[],[0 0 scratchHeight scratchHeight],8);
                        if ~streq(oo(oi).font,'Sloan') && ~oo(oi).allowAnyFont
                            warning('You should set o.allowAnyFont=1 unless o.font=''Sloan''.');
                        end
                        oldFont=Screen('TextFont',scratchWindow,oo(oi).font);
                        Screen('DrawText',scratchWindow,oo(oi).alternatives(1),0,scratchRect(4)); % Must draw first to learn actual font used.
                        font=Screen('TextFont',scratchWindow);
                        if ~streq(font,oo(oi).font)
                            error('Font missing! Requested font "%s", but got "%s". Please install the missing font.\n',oo(oi).font,font);
                        end
                        oldSize=Screen('TextSize',scratchWindow,round(oo(oi).targetHeightPix/oo(oi).targetCheckPix));
                        oldStyle=Screen('TextStyle',scratchWindow,0);
                        canvasRect=[0 0 oo(oi).canvasSize(2) oo(oi).canvasSize(1)]; % o.canvasSize =[height width] in units of targetCheck;
                        if oo(oi).allowAnyFont
                            clear letters
                            for i=1:oo(oi).alternatives
                                letters{i}=oo(oi).signal(i).letter;
                            end
                            oo(oi).targetRectLocal=TextCenteredBounds(scratchWindow,letters,1);
                        else
                            oo(oi).targetRectLocal=round([0 0 oo(oi).targetHeightPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix);
                        end
                        r=TextBounds(scratchWindow,'x',1);
                        oo(oi).xHeightPix=RectHeight(r)*oo(oi).targetCheckPix;
                        oo(oi).xHeightDeg=oo(oi).xHeightPix/oo(oi).pixPerDeg;
                        r=TextBounds(scratchWindow,'H',1);
                        oo(oi).HHeightPix=RectHeight(r)*oo(oi).targetCheckPix;
                        oo(oi).HHeightDeg=oo(oi).HHeightPix/oo(oi).pixPerDeg;
                        ffprintf(ff,'o.xHeightDeg %.2f deg (traditional typographer''s x-height)\n',oo(oi).xHeightDeg);
                        ffprintf(ff,'o.HHeightDeg %.2f deg (capital H ascender height)\n',oo(oi).HHeightDeg);
                        alphabetHeightPix=RectHeight(oo(oi).targetRectLocal)*oo(oi).targetCheckPix;
                        oo(oi).alphabetHeightDeg=alphabetHeightPix/oo(oi).pixPerDeg;
                        ffprintf(ff,'o.alphabetHeightDeg %.2f deg (bounding box for letters used, including any ascenders and descenders)\n',oo(oi).alphabetHeightDeg);
                        if oo(oi).printTargetBounds
                            fprintf('o.targetRectLocal [%d %d %d %d]\n',oo(oi).targetRectLocal);
                        end
                        for i=1:oo(oi).alternatives
                            Screen('FillRect',scratchWindow,white1);
                            rect=CenterRect(canvasRect,scratchRect);
                            targetRect=CenterRect(oo(oi).targetRectLocal,rect);
                            if ~oo(oi).allowAnyFont
                                % Draw position is left at baseline
                                % targetRect is just big enough to hold any Sloan letter.
                                % targetRect=round([0 0 1 1]*oo(oi).targetHeightPix/oo(oi).targetCheckPix),
                                x=targetRect(1);
                                y=targetRect(4);
                            else
                                % Desired draw position is horizontal middle at baseline.
                                % targetRect is just big enough to hold any letter.
                                % targetRect allows for descenders and extension in any
                                % direction.
                                % targetRect=round([a b c d]*oo(oi).targetHeightPix/oo(oi).targetCheckPix),
                                % where a b c and d depend on the font.
                                x=(targetRect(1)+targetRect(3))/2; % horizontal middle
                                y=targetRect(4)-oo(oi).targetRectLocal(4); % baseline
                                % DrawText draws from left, so shift left by half letter width, to center letter at desired draw
                                % position.
                                bounds=Screen('TextBounds',scratchWindow,oo(oi).signal(i).letter,x,y,1);
                                if oo(oi).printTargetBounds
                                    fprintf('%c bounds [%4.0f %4.0f %4.0f %4.0f]\n',oo(oi).signal(i).letter,bounds);
                                end
                                width=bounds(3);
                                x=x-width/2;
                            end
                            if oo(oi).printTargetBounds
                                fprintf('%c %4.0f, %4.0f\n',oo(oi).signal(i).letter,x,y);
                            end
                            Screen('DrawText',scratchWindow,oo(oi).signal(i).letter,x,y,black0,white1,1);
                            Screen('DrawingFinished',scratchWindow,[],1); % Might make GetImage more reliable. Suggested by Mario Kleiner.
                            %                   WaitSecs(0.1); % Might make GetImage more reliable. Suggested by Mario Kleiner.
                            letter=Screen('GetImage',scratchWindow,targetRect,'drawBuffer');
                            
                            % The scrambling sounds like something is going wrong in detiling of read
                            % back renderbuffer memory, maybe a race condition in the driver. Maybe
                            % something else, in any case not really fixable by us, although the "wait
                            % a bit and hope for the best" approach would the the most likely of all
                            % awful approaches to work around it. Maybe add a Screen('DrawingFinished',
                            % o.window, [], 1); before the 'getimage' and/or before the random wait.
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
                            oo(oi).signal(i).image=letter < (white1+black0)/2;
                            % We have now drawn letter(i) into oo(oi).signal(i).image,
                            % using binary pixels. The target size is always
                            % given by o.targetRectLocal. This is a square [0 0
                            % 1 1]*o.targetHeightPix/o.targetCheckPix only if
                            % o.allowAnyFont=false. In general, it need not be
                            % square. Any code that needs a bounding rect for
                            % the target should use o.targetRectLocal, not
                            % o.targetHeightPix. In the letter generation,
                            % targetHeightPix is used solely to set the nominal
                            % font size ("points"), in pixels.
                        end
                        Screen('Close',scratchWindow);
                        scratchWindow=[];
                        if isempty(oo(oi).window)
                            Screen('Close',temporaryWindow);
                            temporaryWindow=[];
                        end
                    case 'gabor'
                        % o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
                        % o.targetGaborSpaceConstantCycles=1.5; % The 1/e space constant of the gaussian envelope in periods of the sinewave.
                        % o.targetGaborCycles=3; % cycles of the sinewave.
                        % o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
                        % o.targetGaborNames='VH';
                        targetRect=round([0 0 oo(oi).targetHeightPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix);
                        oo(oi).targetRectLocal=targetRect;
                        widthChecks=RectWidth(targetRect)-1;
                        axisValues=-widthChecks/2:widthChecks/2; % axisValues is used in creating the meshgrid.
                        [x, y]=meshgrid(axisValues,axisValues);
                        spaceConstantChecks=oo(oi).targetGaborSpaceConstantCycles*(oo(oi).targetHeightPix/oo(oi).targetCheckPix)/oo(oi).targetGaborCycles;
                        cyclesPerCheck=oo(oi).targetGaborCycles/(oo(oi).targetHeightPix/oo(oi).targetCheckPix);
                        for i=1:oo(oi).alternatives
                            a=cos(oo(oi).targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                            b=sin(oo(oi).targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                            oo(oi).signal(i).image=sin(a*x+b*y+oo(oi).targetGaborPhaseDeg*pi/180).*exp(-(x.^2+y.^2)/spaceConstantChecks^2);
                        end
                    case 'image'
                        % Allow for color images.
                        % Scale to range -1 (black) to 1 (white).
                        Screen('DrawText',oo(oi).window,' ',0,0,1,oo(oi).gray1,1); % Set background color.
                        string=sprintf('Reading images from disk ...');
                        DrawFormattedText(oo(oi).window,string,...
                            oo(oi).textSize,1.5*oo(oi).textSize,black,oo(oi).textLineLength,[],[],1.3);
                        Screen('Flip',oo(oi).window); % Display request.
                        oo(oi).targetPix=round(oo(oi).targetHeightDeg/oo(oi).noiseCheckDeg);
                        oo(oi).targetFont=oo(oi).font;
                        oo(oi).showLineOfLetters=true;
                        oo(oi).useCache=false;
                        if oi>1 && isfield(oo(oi),'signalImagesCacheCode') && ~isempty(oo(oi).signalImagesCacheCode)
                            for oiCache=1:oi-1
                                if oo(oiCache).signalImagesCacheCode==oo(oi).signalImagesCacheCode
                                    oo(oi).useCache=true;
                                    break;
                                end
                            end
                        end
                        if oo(oi).useCache
                            oo(oi).targetRectLocal=oo(oiCache).targetRectLocal;
                            oo(oi).signal=oo(oiCache).signal;
                        else
                            [signalStruct,bounds]=LoadSignalImages(oo(oi));
                            oo(oi).targetRectLocal=bounds;
                            sz=size(signalStruct(1).image);
                            white=signalStruct(1).image(1,1,:);
                            if oo(oi).convertSignalImageToGray
                                white=0.2989*white(1)+0.5870*white(2)+0.1140*white(3);
                            end
                            whiteImage=repmat(double(white),sz(1),sz(2));
                            for i=1:length(signalStruct)
                                if ~oo(oi).convertSignalImageToGray
                                    m=signalStruct(i).image;
                                else
                                    m=0.2989*signalStruct(i).image(:,:,1)+0.5870*signalStruct(i).image(:,:,2)+0.1140*signalStruct(i).image(:,:,3);
                                end
                                %                         imshow(uint8(m));
                                oo(oi).signal(i).image=double(m)./whiteImage-1;
                                %                         imshow((oo(oi).signal(i).image+1));
                            end
                        end % if oo(oi).useCache
                    otherwise
                        error('Unknown o.targetKind "%s".',oo(oi).targetKind);
                end % switch oo(oi).targetKind
                if oo(oi).printCrossCorrelation
                    ffprintf(ff,'Cross-correlation of the letters.\n');
                    for i=1:oo(oi).alternatives
                        clear corr
                        for j=1:i
                            cii=sum(oo(oi).signal(i).image(:).*oo(oi).signal(i).image(:));
                            cjj=sum(oo(oi).signal(j).image(:).*oo(oi).signal(j).image(:));
                            cij=sum(oo(oi).signal(i).image(:).*oo(oi).signal(j).image(:));
                            corr(j)=cij/sqrt(cjj*cii);
                        end
                        ffprintf(ff,'%c: ',oo(oi).alphabet(i));
                        ffprintf(ff,'%4.2f ',corr);
                        ffprintf(ff,'\n');
                    end
                    ffprintf(ff,'    ');
                    ffprintf(ff,'%c    ',oo(oi).alphabet(1:oo(oi).alternatives));
                    ffprintf(ff,'\n');
                end
                if oo(oi).allowAnyFont
                    targetRect=CenterRect(oo(oi).targetRectLocal,oo(oi).stimulusRect);
                else
                    targetRect=[0, 0, oo(oi).targetWidthPix, oo(oi).targetHeightPix];
                    targetRect=CenterRect(targetRect,oo(oi).stimulusRect);
                end
                targetRect=round(targetRect);
                boundsRect=CenterRect(targetRect,[oo(oi).targetXYPix oo(oi).targetXYPix]);
                % targetRect not used. boundsRect used solely for the snapshot.
        end % switch oo(oi).task
        fprintf('%d: Prepare the %d signals, each %dx%d. ',MFileLineNr,oo(oi).alternatives,size(oo(oi).signal(1).image,1),size(oo(oi).signal(1).image,2));
        toc
        
        % Compute o.signalIsBinary, o.signalMin, o.signalMax.
        % Image will be (o.contrast*o.signal+1)*o.LBackground.
        v=[];
        for i=1:oo(oi).alternatives
            img=oo(oi).signal(i).image;
            v=unique([v img(:)']); % Combine all components, R,G,B, regardless.
        end
        oo(oi).signalIsBinary=all(ismember(v,[0 1]));
        oo(oi).signalMin=min(v);
        oo(oi).signalMax=max(v);
        
        Screen('Preference','TextAntiAliasing',1);
        
        % Compute hard-edged annular noise mask
        annularNoiseMask=zeros(oo(oi).canvasSize); % initialize with 0
        rect=RectOfMatrix(annularNoiseMask);
        r=[0 0 oo(oi).annularNoiseBigSize(1) oo(oi).annularNoiseBigSize(2)];
        r=round(CenterRect(r,rect));
        annularNoiseMask=FillRectInMatrix(1,r,annularNoiseMask); % fill big radius with 1
        r=[0 0 oo(oi).annularNoiseSmallSize(1) oo(oi).annularNoiseSmallSize(2)];
        r=round(CenterRect(r,rect));
        annularNoiseMask=FillRectInMatrix(0,r,annularNoiseMask); % fill small radius with 0
        annularNoiseMask=logical(annularNoiseMask);
        
        % Compute hard-edged central noise mask
        centralNoiseMask=zeros(oo(oi).canvasSize); % initialize with 0
        rect=RectOfMatrix(centralNoiseMask);
        r=CenterRect([0 0 oo(oi).noiseSize]*oo(oi).noiseCheckPix/oo(oi).targetCheckPix,rect);
        r=round(r);
        centralNoiseMask=FillRectInMatrix(1,r,centralNoiseMask); % fill radius with 1
        centralNoiseMask=logical(centralNoiseMask);
        
        if isfinite(oo(oi).noiseEnvelopeSpaceConstantDeg) && oo(oi).noiseRaisedCosineEdgeThicknessDeg > 0
            error('Sorry. Please set o.noiseEnvelopeSpaceConstantDeg=inf or set o.noiseRaisedCosineEdgeThicknessDeg=0.');
        end
        
        if isfinite(oo(oi).noiseEnvelopeSpaceConstantDeg)
            % Compute Gaussian noise envelope, which will be central or annular,
            % depending on whether o.annularNoiseEnvelopeRadiusDeg is zero or
            % greater than zero.
            [x,y]=meshgrid(1:oo(oi).canvasSize(1),1:oo(oi).canvasSize(2));
            x=x-mean(x(:));
            y=y-mean(y(:));
            radius=sqrt(x.^2+y.^2);
            sigma=oo(oi).noiseEnvelopeSpaceConstantDeg*oo(oi).pixPerDeg/oo(oi).targetCheckPix;
            assert(isfinite(oo(oi).annularNoiseEnvelopeRadiusDeg));
            assert(oo(oi).annularNoiseEnvelopeRadiusDeg >= 0);
            if oo(oi).annularNoiseEnvelopeRadiusDeg > 0
                noiseEnvelopeRadiusPix=oo(oi).annularNoiseEnvelopeRadiusDeg*oo(oi).pixPerDeg/oo(oi).targetCheckPix;
                distance=abs(radius-noiseEnvelopeRadiusPix);
            else
                distance=radius;
            end
            centralNoiseEnvelope=exp(-(distance.^2)/sigma^2);
        elseif oo(oi).noiseRaisedCosineEdgeThicknessDeg > 0
            % Compute central noise envelope with raised-cosine border.
            [x, y]=meshgrid(1:oo(oi).canvasSize(1),1:oo(oi).canvasSize(2));
            x=x-mean(x(:));
            y=y-mean(y(:));
            thickness=oo(oi).noiseRaisedCosineEdgeThicknessDeg*oo(oi).pixPerDeg/oo(oi).targetCheckPix;
            radius=oo(oi).noiseRadiusDeg*oo(oi).pixPerDeg/oo(oi).targetCheckPix;
            a=90+180*(sqrt(x.^2+y.^2)-radius)/thickness;
            a=min(180,a);
            a=max(0,a);
            centralNoiseEnvelope=0.5+0.5*cosd(a);
        else
            centralNoiseEnvelope=ones(oo(oi).canvasSize);
        end
        oo(oi).centralNoiseEnvelopeE1DegDeg=sum(centralNoiseEnvelope(:).^2*oo(oi).noiseCheckPix/oo(oi).pixPerDeg^2);
        
        if streq(oo(oi).task,'rate')
            if length(oo(oi).ratingThreshold)~=length(oo(oi).alphabet)
                error('Length of o.ratingThreshold is %d, but should equal length of o.alphabet ''%s'', which is %d.\n',...
                    length(oo(oi).ratingThreshold),oo(oi).alphabet,length(oo(oi).alphabet));
            end
        end
        
        %% o.E1 is energy at unit contrast.
        power=1:length(oo(oi).signal);
        for i=1:length(oo(oi).signal)
            m=oo(oi).signal(i).image;
            if size(m,3)==3
                m=0.2989*m(:,:,1)+0.5870*m(:,:,2)+0.1140*m(:,:,3);
            end
            power(i)=sum(m(:).^2);
            if streq(oo(oi).targetKind,'letter')
                ok=ismember(unique(oo(oi).signal(i).image(:)),[0 1]);
                assert(all(ok));
            end
        end
        oo(oi).E1=mean(power)*(oo(oi).targetCheckPix/oo(oi).pixPerDeg)^2;
        ffprintf(ff,'log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',log10(oo(oi).E1));
        if ismember(oo(oi).observer,oo(oi).algorithmicObservers)
            Screen('CloseAll');
            window=[];
            [ooo(oi).window]=deal([]);
            LMin=0;
            LMax=200;
            oo(oi).LBackground=100;
        end
        % We are now done with the oo(oi).signal font (e.g. Sloan or Bookman), since we've saved our signals as images.
        if ~isempty(oo(oi).window)
            Screen('TextFont',oo(oi).window,textFont);
            Screen('TextSize',oo(oi).window,oo(oi).textSize);
            Screen('TextStyle',oo(oi).window,textStyle);
            if ~oo(oi).useFractionOfScreen
                HideCursor;
            end
        end
        frameRect=InsetRect(boundsRect,-1,-1);
        if oo(oi).saveSnapshot
            oo(oi).gray1=oo(oi).gray;
        end
    end % for oi=1:conditions
    
    %% SET PARAMETERS FOR QUEST
    for oi=1:conditions
        if isempty(oo(oi).lapse) || isnan(oo(oi).lapse)
            oo(oi).lapse=0.02;
        end
        if isempty(oo(oi).guess) || ~isfinite(oo(oi).guess)
            switch oo(oi).task
                case '4afc'
                    oo(oi).guess=1/4;
                case {'identify' 'identifyAll'}
                    oo(oi).guess=1/oo(oi).alternatives;
                case 'rate'
                    oo(oi).guess=0;
            end
        end
        if streq(oo(oi).targetModulates,'luminance')
            tGuess=-0.5;
            tGuessSd=2;
        else
            tGuess=0;
            tGuessSd=4;
        end
        rDeg=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
        switch oo(oi).thresholdParameter
            case 'spacing'
                nominalCriticalSpacingDeg=0.3*(rDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
                tGuess=log10(2*nominalCriticalSpacingDeg);
            case 'size'
                nominalAcuityDeg=0.029*(rDeg+2.72); % Eq. 13 from Song, Levi, and Pelli (2014).
                tGuess=log10(2*nominalAcuityDeg);
            case 'contrast'
                oo(oi).thresholdPolarity=sign(oo(oi).contrast);
                if isempty(oo(oi).thresholdPolarity) || ~isfinite(oo(oi).thresholdPolarity)
                    error('You must specify o.contrast to indicate + or - desired sign of contrast.');
                end
            case 'flankerContrast'
                assert(oo(oi).useFlankers);
                oo(oi).thresholdPolarity=sign(oo(oi).flankerContrast);
                if ~isfinite(oo(oi).thresholdPolarity)
                    error('You must specify o.flankerContrast to indicate + or - desired sign of contrast.');
                end
            otherwise
                error('Unknown o.thresholdParameter "%s".',oo(oi).thresholdParameter);
        end
        if ~isfinite(oo(oi).tGuess)
            oo(oi).tGuess=tGuess;
        end
        if ~isfinite(oo(oi).tGuessSd)
            oo(oi).tGuessSd=tGuessSd;
        end
        ffprintf(ff,['Log guess %.2f',plusMinusChar,'%.2f\n'],oo(oi).tGuess,oo(oi).tGuessSd);
        
        %% Set parameters for QUESTPlus
        if oo(oi).questPlusEnable
            steepnesses=oo(oi).questPlusSteepnesses;
            guessingRates=oo(oi).questPlusGuessingRates;
            lapseRates=oo(oi).questPlusLapseRates;
            contrastDB=20*oo(oi).questPlusLogContrasts;
            if streq(oo(oi).thresholdParameter,'flankerContrast')
                psychometricFunction=@qpPFCrowding;
            else
                psychometricFunction=@qpPFWeibull;
            end
            oo(oi).questPlusData=qpParams('stimParamsDomainList', {contrastDB},...,
                'psiParamsDomainList',{contrastDB, steepnesses, guessingRates, lapseRates},'qpPF',psychometricFunction);
            oo(oi).questPlusData=qpInitialize(oo(oi).questPlusData);
        end
    end % for oi=1:conditions
    
    %% SET UP conditionList
    oo(1).conditionList=repmat(1:conditions,1,oo(1).trialsPerBlock);
    oo(1).conditionList=Shuffle(oo(1).conditionList);

    %% GET READY TO DO A BLOCK OF INTERLEAVED CONDITIONS.
    [oo.data]=deal([]);
    for oi=1:conditions
        if isfield(oo(oi),'transcript')
            oo(oi).transcript=[];
        end
        oo(oi).transcript.intensity=[];
        oo(oi).transcript.isRight={}; % A cell because isRight may have length 1, 2, or 3.
        oo(oi).transcript.rawResponseString={};
        oo(oi).transcript.response={};
        oo(oi).transcript.target=[];
        if oo(oi).useFlankers
            oo(oi).transcript.flankers={};
        end
        if streq(oo(oi).task,'identifyAll')
            oo(oi).transcript.flankerResponse={};
            oo(oi).transcript.targetResponse={}; % Regardless of o.thresholdResponseTo.
        end
    end % for oi=1:conditions
    for oi=1:conditions
        if streq(oo(oi).thresholdParameter,'flankerContrast') && streq(oo(oi).thresholdResponseTo,'target')
            % Falling psychometric function for crowding of target as a function
            % of flanker contrast. We assume that the observer makes a random
            % finger error on fraction delta of the trials, and gets proportion
            % gamma of those trials right. On the rest of the trials (no finger
            % error) he gets it wrong only if he fails to guess it (prob. gamma)
            % and fails to detect it (prob. exp...).
            oo(oi).q=QuestCreate(oo(oi).tGuess,oo(oi).tGuessSd,oo(oi).pThreshold,oo(oi).steepness,0,0); % Prob of detecting flanker.
            oo(oi).q.p2=oo(oi).lapse*oo(oi).guess+(1-oo(oi).lapse)*(1-(1-oo(oi).guess)*oo(oi).q.p2); % Prob of identifying target.
            oo(oi).q.s2=fliplr([1-oo(oi).q.p2;oo(oi).q.p2]);
            % figure; plot(oo(oi).q.x2,oo(oi).q.p2);
        else
            oo(oi).q=QuestCreate(oo(oi).tGuess,oo(oi).tGuessSd,oo(oi).pThreshold,oo(oi).steepness,oo(oi).lapse,oo(oi).guess);
        end
        oo(oi).q.normalizePdf=true; % Prevent underflow of pdf.
    end % for oi=1:conditions
    wrongRight={'wrong', 'right'};
    timeZero=GetSecs;
    trialsRight=0;
    [oo.trialsRight]=deal(0);
    [oo.rWarningCount]=deal(0);
    [oo.skipTrial]=deal(false);
    [oo.trialsSkipped]=deal(0);
    [oo.trials]=deal(0);
    trial=0;
    waitMessage='Starting new block. ';
    blockStartSecs=GetSecs;
    o=oo(1);
    oi=oo(1).conditionList(1);
    
    %% DO A BLOCK OF TRIALS.
    while trial<length(oo(1).conditionList)
        waitForObserver=(trial==0 || o.skipTrial);
        if o.skipTrial || o.ignoreTrial
            % ignoreTrial is like skipTrial, without the wait. skipTrial is
            % requested by the observer. ignoreTrial is requested by the
            % software after a stimulus artifact (movie too long).
            assert(trial>=0,'Error: trial<0');
            assert(oo(oi).trials>=0,'Error: oo(oi).trials<0');
            oo(oi).trialsSkipped=oo(oi).trialsSkipped+1;
            o.skipTrial=false;
            o.ignoreTrial=false;
            oo(1).conditionList(trial+1:end)=Shuffle(oo(1).conditionList(trial+1:end));
        end
        trial=trial+1;
        oi=oo(1).conditionList(trial);
        oo(oi).trials=oo(oi).trials+1;
        assert(trial>0,'Error: trial<=0');
        assert(oo(oi).trials>0,'Error oo(oi).trials<=0');
        if waitForObserver && ~ismember(oo(oi).observer,oo(oi).algorithmicObservers) 
            o=WaitUntilObserverIsReady(o,oo,waitMessage);
            waitMessage='Continuing. ';
            if o.quitBlock
                break
            end
        end
        if o.skipTrial
            trial=trial-1;
            oo(oi).trials=oo(oi).trials-1;
            continue
        end
        [~,neworder]=sort(lower(fieldnames(oo(oi))));
        oo(oi)=orderfields(oo(oi),neworder);
                
        %% SET TARGET LOG CONTRAST: tTest
        if oo(oi).questPlusEnable
            % QuestPlus
            tTest=qpQuery(oo(oi).questPlusData)/20; % Convert dB to log contrast.
        else
            % Quest
            tTest=QuestQuantile(oo(oi).q);
        end
        if oo(oi).useMethodOfConstantStimuli
            % thresholdParameterValueList is used solely within this if block.
            if oo(oi).trials==1
                assert(size(oo(oi).constantStimuli,1)==1)
                oo(oi).thresholdParameterValueList=...
                    repmat(oo(oi).constantStimuli,1,ceil(oo(oi).trialsPerBlock/length(oo(oi).constantStimuli)));
                oo(oi).thresholdParameterValueList=Shuffle(oo(oi).thresholdParameterValueList);
            end
            c=oo(oi).thresholdParameterValueList(oo(oi).trials); 
            oo(oi).thresholdPolarity=sign(c);
            tTest=log10(abs(c));
        end
        if ~isfinite(tTest)
            ffprintf(ff,'WARNING: trial %d: tTest %f not finite. Setting to QuestMean %.2f.\n',trial,tTest,QuestMean(oo(oi).q));
            tTest=QuestMean(oo(oi).q);
        end
        if oo(oi).saveSnapshot
            tTest=oo(oi).tSnapshot;
        end
        switch oo(oi).thresholdParameter
            case 'spacing'
                spacingDeg=10^tTest;
                flankerSpacingPix=spacingDeg*oo(oi).pixPerDeg;
                flankerSpacingPix=max(flankerSpacingPix,1.2*oo(oi).targetHeightPix);
                fprintf('flankerSpacingPix %d\n',flankerSpacingPix);
            case 'size'
                targetSizeDeg=10^tTest;
                oo(oi).targetHeightPix=targetSizeDeg*oo(oi).pixPerDeg;
                oo(oi).targetWidthPix=oo(oi).targetHeightPix;
            case 'contrast'
                switch oo(oi).targetModulates
                    case 'luminance'
                        oo(oi).r=1;
                        oo(oi).contrast=oo(oi).thresholdPolarity*10^tTest; % Use negative contrast to get dark letters.
                        if oo(oi).saveSnapshot && isfinite(oo(oi).snapshotContrast)
                            oo(oi).contrast=-oo(oi).snapshotContrast;
                        end
                        if streq(oo(oi).targetKind,'image')
                            oo(oi).contrast=min([1 oo(oi).contrast]);
                        end
                    case {'noise', 'entropy'}
                        oo(oi).r=1+10^tTest;
                        oo(oi).contrast=0;
                end
            case 'flankerContrast'
                assert(streq(oo(oi).targetModulates,'luminance'),'The flanker software assumes o.targetModulates is ''luminance''.');
                oo(oi).r=1;
                oo(oi).flankerContrast=oo(oi).thresholdPolarity*10^tTest;
                if oo(oi).saveSnapshot && isfinite(oo(oi).snapshotContrast)
                    oo(oi).flankerContrast=-oo(oi).snapshotContrast;
                end
        end
        a=(1-LMin/oo(oi).LBackground)*oo(oi).noiseListSd/oo(oi).noiseListMax;
        if oo(oi).noiseSD > a
            ffprintf(ff,'WARNING: Reducing o.noiseSD of %s noise to %.2f to avoid overflow.\n',oo(oi).noiseType,a);
            oo(oi).noiseSD=a;
        end
        if isfinite(oo(oi).annularNoiseSD) && oo(oi).annularNoiseSD > a
            ffprintf(ff,'WARNING: Reducing o.annularNoiseSD of %s noise to %.2f to avoid overflow.\n',oo(oi).noiseType,a);
            oo(oi).annularNoiseSD=a;
        end
        
        %% RESTRICT tTest TO PHYSICALLY POSSIBLE RANGE
        switch oo(oi).targetModulates
            case 'noise'
                a=(1-LMin/oo(oi).LBackground)/(oo(oi).noiseListMax*oo(oi).noiseSD/oo(oi).noiseListSd);
                if oo(oi).r > a
                    if ~isfield(oo(oi),'rWarningCount') || oo(oi).rWarningCount == 0
                        ffprintf(ff,'WARNING: Reducing o.r ratio of %s noises from %.2f to upper bound %.2f to stay within luminance range.\n',oo(oi).noiseType,oo(oi).r,a);
                    end
                    oo(oi).r=a;
                    oo(oi).rWarningCount=oo(oi).rWarningCount+1;
                end
                tTest=log10(oo(oi).r-1);
            case 'luminance'
                % min negative contrast
                a=(min(cal.old.L)-oo(oi).LBackground)/oo(oi).LBackground;
                a=a+oo(oi).noiseListMax*oo(oi).noiseSD/oo(oi).noiseListSd;
                assert(a<0,'Need range for signal.');
                if oo(oi).contrast < a
                    oo(oi).contrast=a;
                end
                if oo(oi).flankerContrast < a
                    oo(oi).flankerContrast=a;
                end
                a=-a; % max contrast
                assert(a>0,'Need range for signal.');
                if oo(oi).contrast > a
                    oo(oi).contrast=a;
                end
                if oo(oi).flankerContrast > a
                    oo(oi).flankerContrast=a;
                end
                switch oo(oi).thresholdParameter
                    case 'flankerContrast'
                        tTest=log10(abs(oo(oi).flankerContrast));
                    case 'contrast'
                        tTest=log10(abs(oo(oi).contrast));
                end
            case 'entropy'
                a=128/oo(oi).backgroundEntropyLevels;
                if oo(oi).r > a
                    oo(oi).r=a;
                    if ~isfield(oo(oi),'rWarningCount') || oo(oi).rWarningCount == 0
                        ffprintf(ff,'WARNING: Limiting entropy of %s noise to upper bound %.1f bits.\n',oo(oi).noiseType,log2(oo(oi).r*oo(oi).backgroundEntropyLevels));
                    end
                    oo(oi).rWarningCount=oo(oi).rWarningCount+1;
                end
                signalEntropyLevels=round(oo(oi).r*oo(oi).backgroundEntropyLevels);
                oo(oi).r=signalEntropyLevels/oo(oi).backgroundEntropyLevels; % define o.r as ratio of number of levels
                tTest=log10(oo(oi).r-1);
            otherwise
                error('Unknown o.targetModulates "%s"',oo(oi).targetModulates);
        end % switch oo(oi).targetModulates
        
        if oo(oi).noiseFrozenInBlock
            if oo(oi).trials == 1
                if oo(oi).noiseFrozenInBlockSeed
                    assert(oo(oi).noiseFrozenInBlockSeed > 0 && isinteger(oo(oi).noiseFrozenInBlockSeed))
                    oo(oi).noiseListSeed=oo(oi).noiseFrozenInBlockSeed;
                else
                    rng('shuffle'); % Use time to seed the random number generator.
                    generator=rng;
                    oo(oi).noiseListSeed=generator.Seed;
                end
            end
            rng(oo(oi).noiseListSeed);
        end % if oo(oi).noiseFrozenInBlock
        
        %% RESTRICT tTest TO LEGAL VALUE IN QUESTPLUS
        if oo(oi).questPlusEnable
            i=knnsearch(contrastDB'/20,tTest);
            tTest=contrastDB(i)/20;
        end
        
        %% COMPUTE MOVIE IMAGES
        movieImage={};
        movieSaveWhich=[];
        movieFrameComputeStartSecs=GetSecs;
        for iMovieFrame=1:oo(oi).movieFrames
            % On each new frame, retain the (static) signal and regenerate the (dynamic) noise.
            switch oo(oi).task % add noise to signal
                case '4afc'
                    canvasRect=[0 0 oo(oi).canvasSize(2) oo(oi).canvasSize(1)];
                    sRect=RectOfMatrix(oo(oi).signal(1).image);
                    sRect=round(CenterRect(sRect,canvasRect));
                    assert(IsRectInRect(sRect,canvasRect),'There isn''t enough room for four targets. Reduce o.targetHeightDeg or o.viewingDistanceCm.');
                    signalImageIndex=logical(FillRectInMatrix(true,sRect,zeros(oo(oi).canvasSize)));
                    locations=4;
                    location=struct('image',{[] [] [] []});
%                     rng('shuffle'); TAKES 0.01 s.
                    if iMovieFrame == 1
                        signalLocation=randi(locations);
                        movieSaveWhich=signalLocation;
                    else
                        signalLocation=movieSaveWhich;
                    end
                    for loc=1:locations
                        if oo(oi).noiseFrozenInTrial
                            if loc == 1
                                generator=rng;
                                oo(oi).noiseListSeed=generator.Seed;
                            end
                            rng(oo(oi).noiseListSeed);
                        end
                        noise=PsychRandSample(noiseList,oo(oi).canvasSize*oo(oi).targetCheckPix/oo(oi).noiseCheckPix); % One number per noiseCheck.
                        noise=Expand(noise,oo(oi).noiseCheckPix/oo(oi).targetCheckPix); % One number per targetCheck.
                        if oo(oi).noiseIsFiltered
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
                        end % if oo(oi).noiseIsFiltered
                        if loc == signalLocation
                            switch oo(oi).targetModulates
                                case 'noise'
                                    location(loc).image=1+oo(oi).r*(oo(oi).noiseSD/oo(oi).noiseListSd)*noise;
                                case 'luminance'
                                    location(loc).image=1+(oo(oi).noiseSD/oo(oi).noiseListSd)*noise+oo(oi).contrast;
                                case 'entropy'
                                    oo(oi).q.noiseList=(0.5+floor(noiseList*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                                    oo(oi).q.sd=std(oo(oi).q.noiseList);
                                    location(loc).image=1+(oo(oi).noiseSD/oo(oi).q.sd)*(0.5+floor(noise*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                            end
                        else
                            switch oo(oi).targetModulates
                                case {'noise' 'luminance'}
                                    location(loc).image=1+(oo(oi).noiseSD/oo(oi).noiseListSd)*noise;
                                case 'entropy'
                                    oo(oi).q.noiseList=(0.5+floor(noiseList*0.499999*oo(oi).backgroundEntropyLevels))/(0.5*oo(oi).backgroundEntropyLevels);
                                    oo(oi).q.sd=std(oo(oi).q.noiseList);
                                    location(loc).image=1+(oo(oi).noiseSD/oo(oi).q.sd)*(0.5+floor(noise*0.499999*oo(oi).backgroundEntropyLevels))/(0.5*oo(oi).backgroundEntropyLevels);
                            end
                        end
                    end % for loc=1:locations
                    assert(length(location)==4,'length(location) should be 4.');
                case {'identify' 'identifyAll' 'rate'}
                    locations=1;
                    location=struct('image',[]);
%                     rng('shuffle'); % THIS CALL TAKES 3 ms.
                    if iMovieFrame == 1
                        whichSignal=randi(oo(oi).alternatives);
                        movieSaveWhich=whichSignal;
                        if oo(oi).measureContrast
                            WaitSecs(0.3);
                            if oo(oi).speakInstructions
                                Speak(oo(oi).alphabet(whichSignal));
                            end
                        end
                    else
                        whichSignal=movieSaveWhich;
                    end
                    if oo(oi).noiseFrozenInBlock
                        rng(oo(oi).noiseListSeed);
                    end
                    noise=PsychRandSample(noiseList,oo(oi).canvasSize*oo(oi).targetCheckPix/oo(oi).noiseCheckPix);% TAKES 3 ms. One number per noiseCheck.
                    noise=Expand(noise,oo(oi).noiseCheckPix/oo(oi).targetCheckPix); % One number per targetCheck.
                    % Each pixel in "noise" now represents a targetCheck.
                    noise(~centralNoiseMask & ~annularNoiseMask)=0;
                    noise(centralNoiseMask)=centralNoiseEnvelope(centralNoiseMask).*noise(centralNoiseMask); % TAKES 2 ms.
                    canvasRect=RectOfMatrix(noise); % units of targetChecks
                    assert(all(canvasRect==[0 0 oo(oi).canvasSize(2) oo(oi).canvasSize(1)]));
                    sRect=RectOfMatrix(oo(oi).signal(1).image); % units of targetChecks
                    % Center the target in canvasRect. 
                    sRect=CenterRect(sRect,canvasRect);
                    if ~IsRectInRect(sRect,canvasRect)
                        error('sRect [%d %d %d %d] exceeds canvasRect [%d %d %d %d].\n',sRect,canvasRect);
                    end
                    % signalImageIndex is true for every number in
                    % canvasRect that is in the centered signal rect.
                    signalImageIndex=logical(FillRectInMatrix(true,sRect,zeros(oo(oi).canvasSize))); % TAKES 0.5 ms
                    if size(oo(oi).signal(1).image,3)==3
                        signalImageIndex=repmat(signalImageIndex,1,1,3); % Support color.
                    end
                    % figure(1);imshow(signalImageIndex);
                    % signalImage embeds the signal in a background of
                    % zeros with size canvasRect.
                    signalImage=zeros(size(signalImageIndex)); % Support color.
                    if (iMovieFrame > oo(oi).moviePreFrames ...
                            && iMovieFrame <= oo(oi).moviePreFrames+oo(oi).movieSignalFrames)
                        % Add in signal only during the signal interval.
                        signalImage(signalImageIndex)=oo(oi).signal(whichSignal).image(:); % Support color.
                    end
                    % figure(2);imshow(signalImage);
                    signalMask=true(size(signalImage(:,:,1))); % TAKES 0.3 ms
                    if oo(oi).signalIsBinary
                        % signalMask is true where the signal is true.
                        signalMask=signalMask & signalImage;
                    else
                        % signalMask is true where the signal is not white.
                        for i=1:length(white) % support color
                            signalMask=signalMask & signalImage(:,:,i)~=white(i); % TAKES 0.3 ms
                        end
                    end
                    signalMask=repmat(signalMask,1,1,length(white)); % Support color.
%                     figure(1);subplot(1,3,1);imshow(signalImage);subplot(1,3,2);imshow(signalMask);
                    switch oo(oi).targetModulates
                        case 'luminance'
                            % location(1).image has size canvasSize. Each
                            % pixel represents one targetCheck. Target is
                            % centered in that image.
                            location(1).image=ones(size(signalImage(:,:,1))); % TAKES 0.3 ms.
                            location(1).image(centralNoiseMask)=1+(oo(oi).noiseSD/oo(oi).noiseListSd)*noise(centralNoiseMask); % TAKES 1 ms.
                            location(1).image(annularNoiseMask)=1+(oo(oi).annularNoiseSD/oo(oi).noiseListSd)*noise(annularNoiseMask);
                            location(1).image=repmat(location(1).image,1,1,length(white)); % Support color.
                            location(1).image=location(1).image+oo(oi).contrast*signalImage; % Add signal to noise.
                            PrintImageStatistics(MFileLineNr,oo(oi),i,'signalImage',signalImage);
                            PrintImageStatistics(MFileLineNr,oo(oi),i,'location(1).image',location(1).image)
                        case 'noise'
                            noise(signalMask)=oo(oi).r*noise(signalMask); % Signal modulates noise.
                            location(1).image=ones(oo(oi).canvasSize);
                            location(1).image(centralNoiseMask)=1+(oo(oi).noiseSD/oo(oi).noiseListSd)*noise(centralNoiseMask);
                            location(1).image(annularNoiseMask)=1+(oo(oi).annularNoiseSD/oo(oi).noiseListSd)*noise(annularNoiseMask);
%                             figure(1);subplot(1,3,3);imshow(location(1).image);
                        case 'entropy'
                            noise(~centralNoiseMask)=0;
                            noise(signalMask)=(0.5+floor(noise(signalMask)*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                            noise(~signalMask)=(0.5+floor(noise(~signalMask)*0.499999*oo(oi).backgroundEntropyLevels))/(0.5*oo(oi).backgroundEntropyLevels);
                            location(1).image=1+(oo(oi).noiseSD/oo(oi).noiseListSd)*noise;
                    end
                    PrintImageStatistics(MFileLineNr,oo(oi),i,'noise',noise);
                    
                    %% ADD FLANKERS, EACH A RANDOM LETTER LIKE THE TARGET
                    if oo(oi).useFlankers && streq(oo(oi).targetModulates,'luminance')
                        if isfinite(oo(oi).flankerContrast)
                            c=oo(oi).flankerContrast;
                        else
                            c=oo(oi).contrast; % Same contrast as target.
                        end
                        switch oo(oi).flankerArrangement
                            case 'radial'
                                angle=[180 0];
                            case 'tangential'
                                angle=[270 90];
                            case 'radialAndTangential'
                                angle=270:-90:0;
                        end
                        if iMovieFrame==1
                            oo(oi).whichFlanker=zeros(size(angle));
                            oo(oi).flankerXYDeg=cell(size(angle));
                        end
                        for j=1:length(angle)
                            if ~all(oo(oi).eccentricityXYDeg==0)
                                theta=atan2d(oo(oi).eccentricityXYDeg(2),oo(oi).eccentricityXYDeg(1)); % Direction of target from fixation.
                            else
                                theta=90; % For target at fixation, default direction is up, .
                            end
                            % "theta" is the angle of the vector from
                            % fixation to target.
                            % "angle" is the angle of the displacement from
                            % target to flanker, relative to theta.
                            theta=theta+angle(j); % Add "angle" to angle of direction from radius to target.
                            if iMovieFrame==1
                                oo(oi).whichFlanker(j)=randi(oo(oi).alternatives);
                            end
                            assert(oo(oi).flankerSpacingDeg>0);
                            spacingDeg=oo(oi).flankerSpacingDeg;
                            eccDeg=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
                            switch angle(j)
                                case 0
                                    % Outer radial flanker is at specified spacing.
                                case 180
                                    if eccDeg>0
                                        % Inner radial flanker position has same
                                        % difference in log eccentricity from target
                                        % as the outer radial flanker.
                                        spacingDeg=eccDeg-eccDeg^2/(eccDeg+spacingDeg);
                                    else
                                        % Inner radial flanker is at specified spacing.
                                    end
                                case {90 270}
                                    switch oo(oi).flankerArrangement
                                        case 'tangential'
                                            % Both tangential flankers are at specified
                                            % spacing.
                                        case 'radialAndTangential'
                                            % When both radial and tangential are
                                            % present, the tangential spacing equals
                                            % half the outer radial spacing.
                                            if eccDeg>0
                                                spacingDeg=eccDeg-eccDeg^2/(eccDeg+spacingDeg);
                                                spacingDeg=0.5*spacingDeg;
                                            end
                                        otherwise
                                            error('Illegal o.flankerArrangement ''%s''.',oo(oi).flankerArrangement);
                                    end
                                otherwise
                                    error('Illegal flanker angle %.0f re radial vector from fixation to target.',angle(j));
                            end
                            flankerOffsetXYDeg=spacingDeg*[cosd(theta) sind(theta)]; % x y offset deg
                            oo(oi).flankerXYDeg{j}=oo(oi).eccentricityXYDeg+flankerOffsetXYDeg; % x y location in deg
                            offsetXYPix=XYPixOfXYDeg(oo(oi),oo(oi).flankerXYDeg{j})-XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg);
                            offsetXYChecks=offsetXYPix/oo(oi).targetCheckPix; % flanker offset from target, in targetChecks
                            rect=RectOfMatrix(oo(oi).signal(oo(oi).whichFlanker(j)).image); % flanker rect
                            rect=CenterRect(rect,canvasRect); % This is target location.
                            rect=OffsetRect(rect,offsetXYChecks(1),offsetXYChecks(2)); % This is flanker location.
                            if ~IsRectInRect(rect,canvasRect)
                                error('Sorry, flanker rect [%d %d %d %d] does not fit in canvasRect [%d %d %d %d].',rect, canvasRect);
                            end
                            flankerImage=zeros(oo(oi).canvasSize);
                            flankerImageIndex=logical(FillRectInMatrix(true,rect,flankerImage));
                            if (iMovieFrame > oo(oi).moviePreFrames ...
                                    && iMovieFrame <= oo(oi).moviePreFrames+oo(oi).movieSignalFrames)
                                % Add in flanker only during the signal interval.
                                flankerImage(flankerImageIndex)=oo(oi).signal(oo(oi).whichFlanker(j)).image(:);
                            end
                            location(1).image=location(1).image+c*flankerImage; % Add flanker.
                        end % for j=1:length(angle)
                        oo(oi).transcript.flankers{oo(oi).trials}=oo(oi).whichFlanker; % The several flanker signal indices.
                        oo(oi).transcript.flankerXYDeg{oo(oi).trials}=oo(oi).flankerXYDeg; % The several flanker eccentricities.
                        oo(oi).transcript.eccentricityXYDeg{oo(oi).trials}=oo(oi).eccentricityXYDeg; % Target eccentricity.
                    end % if oo(oi).useFlankers
                otherwise
                    error('Unknown o.task "%s"',oo(oi).task);
            end % switch oo(oi).task
            movieImage{iMovieFrame}=location;
        end % for iMovieFrame=1:oo(oi).movieFrames
        
        if oo(oi).measureContrast
            fprintf('%d: unique(signalImage(:)) ',MFileLineNr);
            fprintf('%g ',unique(signalImage(:)));
            fprintf('\n');
        end
        
      %% COMPUTE CLUT
        if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
            if trial==1
                % Clear screen only before first trial. After the first
                % trial, the screen is already ready for next trial.
                Screen('FillRect',oo(oi).window,oo(oi).gray1);
                Screen('FillRect',oo(oi).window,oo(oi).gray,oo(oi).stimulusRect);
            end
            if ~isempty(fixationLines)
                Screen('DrawLines',oo(oi).window,fixationLines,fixationCrossWeightPix,0); % fixation
            end
            rect=[0 0 1 1]*2*oo(oi).annularNoiseBigRadiusDeg*oo(oi).pixPerDeg/oo(oi).noiseCheckPix;
            if oo(oi).newClutForEachImage % Usually enabled.
                % Compute CLUT for all possible noises and the given signal
                % and contrast. Note: The gray screen in the non-stimulus
                % areas is drawn with CLUT index 1.
                [cal,oo(oi)]=ComputeClut(cal,oo(oi));
            end % if oo(oi).newClutForEachImage
            if oo(oi).assessContrast
                AssessContrast(oo(oi));
            end
            if oo(oi).measureContrast
                % fprintf('oo(oi).gray*oo(oi).maxEntry %d gamma %.3f, oo(oi).gray1*oo(oi).maxEntry %d gamma %.3f\n',oo(oi).gray*oo(oi).maxEntry,cal.gamma(oo(oi).gray*oo(oi).maxEntry+1,2),oo(oi).gray1*oo(oi).maxEntry,cal.gamma(oo(oi).gray1*oo(oi).maxEntry+1,2));
                Screen('LoadNormalizedGammaTable',oo(oi).window,cal.gamma,loadOnNextFlip);
                Screen('Flip',oo(oi).window,0,1);
                oo(oi)=MeasureContrast(oo(oi),MFileLineNr);
            end
            if oo(oi).assessBitDepth
                assessBitDepth(oo(oi));
                break;
            end
            if oo(oi).showCropMarks
                TrimMarks(oo(oi).window,frameRect); % This should be moved down, to be drawn AFTER the noise.
            end
            if oo(oi).saveSnapshot && oo(oi).snapshotShowsFixationBefore && ~isempty(fixationLines)
                Screen('DrawLines',oo(oi).window,fixationLines,fixationCrossWeightPix,0); % fixation
            end
        end % if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
        
      %% MEASURE CONTRAST (TO CHECK THE PROGRAM)
        if oo(oi).measureContrast
            location=movieImage{1};
            fprintf('%d: luminance/oo(oi).LBackground',MFileLineNr);
            fprintf(' %.4f',unique(location(1).image(:)));
            fprintf('\n');
            img=IndexOfLuminance(cal,location(1).image*oo(oi).LBackground)/oo(oi).maxEntry;
            index=unique(img(:));
            LL=LuminanceOfIndex(cal,index*oo(oi).maxEntry);
            fprintf('%d: index',MFileLineNr);
            fprintf(' %.4f',index);
            fprintf(', G');
            fprintf(' %.4f',cal.gamma(round(1+index*oo(oi).maxEntry),2));
            fprintf(', luminance');
            fprintf(' %.1f',LL);
            if oo(oi).contrast<0
                c=(LL(1)-LL(2))/LL(2);
            else
                c=(LL(2)-LL(1))/LL(1);
            end
            fprintf(', contrast %.4f\n',c);
            movieTexture(iMovieFrame)=Screen('MakeTexture',oo(oi).window,img,0,0,1);
            rect=Screen('Rect',movieTexture(iMovieFrame));
            img=Screen('GetImage',movieTexture(iMovieFrame),rect,'frontBuffer',1);
            index=unique(img(:));
            LL=LuminanceOfIndex(cal,index*oo(oi).maxEntry);
            fprintf('%d: texture index',MFileLineNr);
            fprintf(' %.4f',index);
            fprintf(', G');
            fprintf(' %.4f',cal.gamma(round(1+index*oo(oi).maxEntry),2));
            fprintf(', luminance');
            fprintf(' %.1f',LL);
            if oo(oi).contrast<0
                c=(LL(1)-LL(2))/LL(2);
            else
                c=(LL(2)-LL(1))/LL(1);
            end
            fprintf(', contrast %.4f\n',c);
        end % if oo(oi).measureContrast
        
        %% CONVERT IMAGE MOVIE TO TEXTURE MOVIE
        if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
            for iMovieFrame=1:oo(oi).movieFrames
                location=movieImage{iMovieFrame};
                switch oo(oi).task
                    case {'identify' 'identifyAll' 'rate'}
                        locations=1;
                        assert(length(location)==1);
                        % Convert to pixel values.
                        % PREPARE IMAGE DATA
                        img=location(1).image;
                        PrintImageStatistics(MFileLineNr,oo(oi),i,'before IndexOfLuminance',img);
                        img=IndexOfLuminance(cal,img*oo(oi).LBackground)/oo(oi).maxEntry;
%                         im=LuminanceOfIndex(cal,img*oo(oi).maxEntry);
%                         PrintImageStatistics(MFileLineNr,oo(oi),i,'LuminanceOfIndex(IndexOfLuminance)',im);
                        img=Expand(img,oo(oi).targetCheckPix);
                        if oo(oi).assessLinearity
                            AssessLinearity(oo(oi));
                        end
                        rect=RectOfMatrix(img);
                        rect=CenterRect(rect,[oo(oi).targetXYPix oo(oi).targetXYPix]);
                        rect=round(rect); % rect that will receive the stimulus (target and noises)
                        location(1).rect=rect;
                        movieTexture(iMovieFrame)=Screen('MakeTexture',oo(oi).window,img,0,0,1); % SAVE MOVIE FRAME
                        srcRect=RectOfMatrix(img);
                        dstRect=rect;
                        offset=dstRect(1:2)-srcRect(1:2);
                        dstRect=ClipRect(dstRect,oo(oi).stimulusRect);
                        srcRect=OffsetRect(dstRect,-offset(1),-offset(2));
                        eraseRect=dstRect;
                        rect=CenterRect([0 0 oo(oi).targetHeightPix oo(oi).targetWidthPix],rect);
                        rect=round(rect); % target rect
                    case '4afc'
                        rect=[0 0 oo(oi).targetHeightPix oo(oi).targetWidthPix];
                        location(1).rect=AlignRect(rect,boundsRect,'left','top');
                        location(2).rect=AlignRect(rect,boundsRect,'right','top');
                        location(3).rect=AlignRect(rect,boundsRect,'left','bottom');
                        location(4).rect=AlignRect(rect,boundsRect,'right','bottom');
                        blankImage=oo(oi).gray*ones(RectHeight(boundsRect),RectWidth(boundsRect));
                        movieTexture(iMovieFrame)=Screen('MakeTexture',oo(oi).window,blankImage,0,0,1);
                        eraseRect=location(1).rect;
                        for i=1:locations
                            img=location(i).image;
                            img=IndexOfLuminance(cal,img*oo(oi).LBackground);
                            img=Expand(img,oo(oi).targetCheckPix);
                            texture=Screen('MakeTexture',oo(oi).window,img/oo(oi).maxEntry,0,0,1);
                            rect=OffsetRect(location(i).rect,-boundsRect(1),-boundsRect(2));
                            Screen('DrawTexture',movieTexture(iMovieFrame),texture,RectOfMatrix(img),rect);
                            Screen('Close',texture);
                            eraseRect=UnionRect(eraseRect,location(i).rect);
                        end
                        if any(any(boundsRect~=eraseRect))
                            warning('boundsRect ~= eraseRect');
                            boundsRect,eraseRect
                        end
                        % Screen coordinates.
                        srcRect=RectOfMatrix(blankImage);
                        dstRect=boundsRect;
                        if oo(oi).showResponseNumbers
                            % Label the alternatives 1 to 4. They are
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
                            if oo(oi).responseNumbersInCorners
                                % in corners
                                r=[0 0 oo(oi).textSize 1.4*oo(oi).textSize];
                                labelBounds=InsetRect(boundsRect,-1.1*oo(oi).textSize,-oo(oi).lineSpacing*oo(oi).textSize);
                            else
                                % on sides
                                r=[0 0 oo(oi).textSize oo(oi).targetHeightPix];
                                labelBounds=InsetRect(boundsRect,-2*oo(oi).textSize,0);
                            end
                            location(1).labelRect=AlignRect(r,labelBounds,'left','top');
                            location(2).labelRect=AlignRect(r,labelBounds,'right','top');
                            location(3).labelRect=AlignRect(r,labelBounds,'left','bottom');
                            location(4).labelRect=AlignRect(r,labelBounds,'right','bottom');
                            for i=1:locations
                                [x, y]=RectCenter(location(i).labelRect);
                                Screen('DrawText',oo(oi).window,sprintf('%d',i),x-oo(oi).textSize/2,y+0.4*oo(oi).textSize,black,oo(oi).gray1,1);
                            end
                        end
                end % switch oo(oi).task
            end % for iMovieFrame=1:oo(oi).movieFrames
        end % if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
        if oo(oi).measureContrast
            rect=Screen('Rect',movieTexture(1));
            img=Screen('GetImage',movieTexture(1),rect,'frontBuffer',1); % 1 for float, not int, colors.
            img=img(:,:,2);
            img=unique(img(:));
            G=cal.gamma(round(1+img*oo(oi).maxEntry),2);
            LL=LuminanceOfIndex(cal,img*oo(oi).maxEntry);
            fprintf('%d: texture index',MFileLineNr);
            fprintf(' %.4f',img);
            fprintf(', G');
            fprintf(' %.4f',G);
            fprintf(', luminance');
            fprintf(' %.1f',LL);
            if oo(oi).contrast<0
                c=(LL(1)-LL(2))/LL(2);
            else
                c=(LL(2)-LL(1))/LL(1);
            end
            fprintf(', contrast %.4f\n',c);
            % Compare hardware CLUT with identity.
            gammaRead=Screen('ReadNormalizedGammaTable',oo(oi).window);
            maxEntry=size(gammaRead,1)-1;
            gamma=repmat(((0:maxEntry)/maxEntry)',1,3);
            delta=gammaRead(:,2)-gamma(:,2);
            ffprintf(ff,'Difference between identity and read-back of hardware CLUT (%dx%d): mean %.9f, sd %.9f\n',...
                size(gammaRead),mean(delta),std(delta));
        end
        
        %% PLAY MOVIE
        if ~isempty(oo(oi).window)
            Screen('LoadNormalizedGammaTable',oo(oi).window,cal.gamma,loadOnNextFlip);
            if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
                Snd('Play',purr); % Pre-announce that image is up, awaiting response.
                assert(oo(oi).trials>0,'oo(oi).trials must be >0');
                oo(oi).movieFrameFlipSecs(1:oo(oi).movieFrames+1,oo(oi).trials)=nan;
                for iMovieFrame=1:oo(oi).movieFrames
                    Screen('DrawTexture',oo(oi).window,movieTexture(iMovieFrame),srcRect,dstRect);
                    if oo(oi).fixationCrossDrawnOnStimulus && ~isempty(fixationLines)
                        Screen('DrawLines',oo(oi).window,fixationLines,fixationCrossWeightPix,black); % fixation
                    end
                    if oo(oi).showBlackAnnulus
                        radius=round(oo(oi).blackAnnulusSmallRadiusDeg*oo(oi).pixPerDeg);
                        oo(oi).blackAnnulusSmallRadiusDeg=radius/oo(oi).pixPerDeg;
                        annulusRect=[0 0 2*radius 2*radius];
                        annulusRect=CenterRect(annulusRect,[oo(oi).targetXYPix oo(oi).targetXYPix]);
                        thickness=max(1,round(oo(oi).blackAnnulusThicknessDeg*oo(oi).pixPerDeg));
                        oo(oi).blackAnnulusThicknessDeg=thickness/oo(oi).pixPerDeg;
                        if oo(oi).blackAnnulusContrast == -1
                            color=0;
                        else
                            luminance=(1+oo(oi).blackAnnulusContrast)*oo(oi).LBackground;
                            luminance=max(min(luminance,cal.LLast),cal.LFirst);
                            color=IndexOfLuminance(cal,luminance);
                            oo(oi).blackAnnulusContrast=LuminanceOfIndex(cal,color)/oo(oi).LBackground-1;
                        end
                        Screen('FrameRect',oo(oi).window,color,annulusRect,thickness);
                    end % if oo(oi).showBlackAnnulus
                    if oo(oi).saveStimulus && iMovieFrame == oo(oi).moviePreFrames+1
                        oo(oi).savedStimulus=Screen('GetImage',oo(oi).window,oo(oi).stimulusRect,'drawBuffer');
                        fprintf('oo(oi).savedStimulus at contrast %.3f, flankerContrast %.3f\n',oo(oi).contrast,oo(oi).flankerContrast);
                        Screen('DrawText',oo(oi).window,sprintf('o.contrast %.3f, flankerContrast %.3f',oo(oi).contrast,oo(oi).flankerContrast),20,150);
                        oo(oi).newCal=cal;
                        if oo(oi).saveSnapshot
                            snapshotTexture=Screen('OpenOffscreenWindow',movieTexture(iMovieFrame));
                            Screen('CopyWindow',movieTexture(iMovieFrame),snapshotTexture);
                        end
                    end
                    for displayFrame=1:oo(oi).noiseCheckFrames
                        Screen('Flip',oo(oi).window,0,1); % Display this frame of the movie. Don't clear back buffer.
                    end
                    oo(oi).movieFrameFlipSecs(iMovieFrame,oo(oi).trials)=GetSecs;
                end % for iMovieFrame=1:oo(oi).movieFrames
                oo(oi).transcript.stimulusOnsetSecs(oo(oi).trials)=oo(oi).movieFrameFlipSecs(oo(oi).moviePreFrames+1,oo(oi).trials);
                if oo(oi).saveSnapshot
                    oo(oi)=SaveSnapshot(oo(oi)); % Closes oo(oi).window when done.
                    window=oo(oi).window;
                    return
                end
                if oo(oi).assessTargetLuminance
                    % Reading from the buffer, the image has already been converted
                    % from index to RGB. We use our calibration to estimate
                    % luminance from G.
                    rect=CenterRect(oo(oi).targetCheckPix*oo(oi).targetRectLocal,oo(oi).stimulusRect);
                    oo(oi).actualStimulus=Screen('GetImage',oo(oi).window,rect,'frontBuffer',1);
                    % Get first and second mode.
                    p=oo(oi).actualStimulus(:,:,2);
                    p=p(:);
                    pp=mode(p);
                    pp(2)=mode(p(p~=pp));
                    pp=sort(pp);
                    LL=interp1(cal.old.G,cal.old.L,pp,'pchip');
                    ffprintf(ff,'%d: assessTargetLuminance: two modal values: G',MFileLineNr);
                    ffprintf(ff,' %.4f',pp);
                    ffprintf(ff,', luminance');
                    ffprintf(ff,' %.1f',LL);
                    if oo(oi).contrast<0
                        c=(LL(1)-LL(2))/LL(2);
                    else
                        c=(LL(2)-LL(1))/LL(1);
                    end
                    ffprintf(ff,' cd/m^2, contrast %.4f, oo(oi).contrast %.4f\n',c,oo(oi).contrast);
                    ffprintf(ff,'\n');
                    %             Print stimulus as table of numbers.
                    %             dx=round(size(oo(oi).actualStimulus,2)/10);
                    %             dy=round(dx*0.7);
                    %             oo(oi).actualStimulus(1:dy:end,1:dx:end,2)
                end
                if isfinite(oo(oi).targetDurationSecs) % End the movie
                    Screen('FillRect',oo(oi).window,oo(oi).gray,dstRect); % Erase only the movie, sparing the rest of the screen.
                    if oo(oi).fixationCrossDrawnOnStimulus && ~isempty(fixationLines)
                        Screen('DrawLines',oo(oi).window,fixationLines,fixationCrossWeightPix,black); % fixation
                    end
                    if oo(oi).useDynamicNoiseMovie
                        Screen('Flip',oo(oi).window,0,1); % Clear stimulus at next display frame.
                    else
                        % Clear stimulus at next display frame after specified duration.
                        Screen('Flip',oo(oi).window,oo(oi).movieFrameFlipSecs(1,oo(oi).trials)+oo(oi).targetDurationSecs-0.5/displayFrameRate,1);
                    end
                    oo(oi).movieFrameFlipSecs(iMovieFrame+1,oo(oi).trials)=GetSecs;
                    if ~oo(oi).fixationCrossBlankedNearTarget
                        WaitSecs(oo(oi).fixationCrossBlankedUntilSecsAfterTarget);
                    end
                    if ~isempty(fixationLines)
                        Screen('DrawLines',oo(oi).window,fixationLines,fixationCrossWeightPix,black); % fixation
                    end
                    % After o.fixationCrossBlankedUntilSecsAfterTarget, display new fixation.
                    Screen('Flip',oo(oi).window,oo(oi).movieFrameFlipSecs(iMovieFrame+1,oo(oi).trials)+0.3,1);
                end % if isfinite(oo(oi).targetDurationSecs)
                for iMovieFrame=1:oo(oi).movieFrames
                    Screen('Close',movieTexture(iMovieFrame));
                end
                eraseRect=dstRect; % Erase only the movie, sparing the rest of the screen
                if ~isempty(oo(oi).responseScreenAbsoluteContrast)
                    % Set contrast of response screen.
                    saveContrast=oo(oi).contrast;
                    oo(oi).contrast=oo(oi).responseScreenAbsoluteContrast;
                    [cal,oo(oi)]=ComputeClut(cal,oo(oi));
                    oo(oi).contrast=saveContrast;
                end
                % Print instruction in upper left corner.
                Screen('FillRect',oo(oi).window,oo(oi).gray1,topCaptionRect);
                message=sprintf('Trial %d of %d. Block %d of %d.',trial,oo(oi).trialsPerBlock*conditions,oo(oi).blockNumber,oo(oi).blocksDesired);
                if isfield(oo(oi),'experiment')
                    message=[message ' Experiment "' oo(oi).experiment '".'];
                end
                Screen('DrawText',oo(oi).window,message,oo(oi).textSize/2,oo(oi).textSize/2,black,oo(oi).gray1);
                
                % Print instructions in lower left corner.
                factor=1;
                switch oo(oi).task
                    case '4afc'
                        message='Please click 1 to 4 times for location 1 to 4, or more clicks to escape.';
                    case 'identify'
                        message=sprintf('Please type the letter: %s, or ESCAPE to cancel a trial or quit.',oo(oi).alphabet(1:oo(oi).alternatives));
                    case 'identifyAll'
                        factor=1.3;
                        switch oo(oi).thresholdResponseTo
                            case 'target'
                                message=sprintf('[Ignore case. DELETE to backspace. ESCAPE to cancel a trial or quit. You''ll get feedback on the middle letter.]');
                            case 'flankers'
                                message=sprintf('[Ignore case. DELETE to backspace. ESCAPE to cancel a trial or quit. You''ll get feedback on the outer letters.]');
                        end
                    case 'rate'
                        message=sprintf('Please rate the beauty: 0 to 9, or ESCAPE to cancel a trial or quit.');
                end
                textRect=[0 0 oo(oi).textSize 1.2*oo(oi).textSize];
                textRect=AlignRect(textRect,bottomCaptionRect,'left','bottom');
                textRect=OffsetRect(textRect,oo(oi).textSize/2,-oo(oi).textSize/2); % inset from screen edges
                textRect=round(textRect);
                bounds=Screen('TextBounds',oo(oi).window,message);
                ratio=RectWidth(bounds)/(0.93*RectWidth(o.screenrect));
                Screen('TextSize',oo(oi).window,floor(oo(oi).textSize/max([ratio factor])));
                Screen('FillRect',oo(oi).window,oo(oi).gray1,bottomCaptionRect);
                Screen('DrawText',oo(oi).window,message,textRect(1),textRect(4),black,oo(oi).gray1,1);
                Screen('TextSize',oo(oi).window,oo(oi).textSize);
            end % if ~ismember(observer,algorithmicObservers);
            
            %% DISPLAY RESPONSE ALTERNATIVES
            if ~isempty(oo(oi).window)
                switch oo(oi).task
                    case '4afc'
                        leftEdgeOfResponse=o.screenrect(3);
                    case {'identify' 'identifyAll'}
                        % Draw the response alternatives.
                        sz=size(oo(oi).signal(1).image);
                        oo(oi).targetWidthPix=round(oo(oi).targetHeightPix*sz(2)/sz(1));
                        rect=[0 0 oo(oi).targetWidthPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix; % size of oo(oi).signal(1).image
                        switch oo(oi).alphabetPlacement
                            case 'right'
                                desiredLengthPix=RectHeight(o.screenrect);
                                targetChecks=RectHeight(rect);
                            case 'top'
                                desiredLengthPix=0.5*RectWidth(o.screenrect);
                                targetChecks=RectWidth(rect);
                        end
                        switch oo(oi).targetKind
                            case 'letter'
                                spacingFraction=0.25;
                            case 'gabor'
                                spacingFraction=0;
                            case 'image'
                                spacingFraction=0;
                        end
                        if oo(oi).alternatives < 6
                            desiredLengthPix=desiredLengthPix*oo(oi).alternatives/6;
                        end
                        alphaSpaces=oo(oi).alternatives+spacingFraction*(oo(oi).alternatives+1);
                        alphaPix=desiredLengthPix/alphaSpaces;
                        alphaCheckPix=alphaPix/targetChecks;
                        alphaGapPixCeil=(desiredLengthPix-oo(oi).alternatives*ceil(alphaCheckPix)*targetChecks)/(oo(oi).alternatives+1);
                        alphaGapPixFloor=(desiredLengthPix-oo(oi).alternatives*floor(alphaCheckPix)*targetChecks)/(oo(oi).alternatives+1);
                        ceilError=log(alphaGapPixCeil/(ceil(alphaCheckPix)*targetChecks))-log(spacingFraction);
                        floorError=log(alphaGapPixFloor/(floor(alphaCheckPix)*targetChecks))-log(spacingFraction);
                        if min(abs(ceilError),abs(floorError)) < log(3)
                            if abs(floorError) < abs(ceilError)
                                alphaCheckPix=floor(alphaCheckPix);
                            else
                                alphaCheckPix=ceil(alphaCheckPix);
                            end
                        end
                        alphaGapPix=(desiredLengthPix-oo(oi).alternatives*targetChecks*alphaCheckPix)/(oo(oi).alternatives+1);
                        useExpand=alphaCheckPix == round(alphaCheckPix);
                        rect=[0 0 oo(oi).targetWidthPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix; % size of oo(oi).signal(1).image
                        rect=round(rect*alphaCheckPix);
                        rect=AlignRect(rect,o.screenrect,RectRight,RectTop);
                        rect=OffsetRect(rect,-alphaGapPix,alphaGapPix); % spacing
                        rect=round(rect);
                        switch oo(oi).alphabetPlacement
                            case 'right'
                                step=[0 RectHeight(rect)+alphaGapPix];
                            case 'top'
                                step=[RectWidth(rect)+alphaGapPix 0];
                                rect=OffsetRect(rect,-(oo(oi).alternatives-1)*step(1),0);
                        end
                        for i=1:oo(oi).alternatives
                            img=oo(oi).signal(i).image;
%                             PrintImageStatistics(MFileLineNr,oo(oi),i,'before resize',img)
                            if useExpand
                                img=Expand(oo(oi).signal(i).image,alphaCheckPix);
                            else
                                if useImresize
                                    % We use 'bilinear' method to make sure that all
                                    % new values are within the old range. That's
                                    % important because we set up the CLUT with the old
                                    % range.
                                    img=imresize(oo(oi).signal(i).image,[RectHeight(rect), RectWidth(rect)],'bilinear');
                                else
                                    img=oo(oi).signal(i).image;
                                    % If the imresize function (in Image Processing
                                    % Toolbox) is not available then the image resizing
                                    % by the DrawTexture command below.
                                end
                            end % if useExpand
%                             PrintImageStatistics(MFileLineNr,oo(oi),i,'after resize',img)
                            if oo(oi).responseScreenAbsoluteContrast<0
                                error('o.responseScreenAbsoluteContrast %.2f must be positive. Sign will track o.contrast.',...
                                    oo(oi).responseScreenAbsoluteContrast);
                            end
                            % Note alphabet placement on top or right.
                            if oo(oi).signalIsBinary
                                if oo(oi).thresholdPolarity<0
                                    if ~isempty(oo(oi).responseScreenAbsoluteContrast) && ~ismember(oo(oi).responseScreenAbsoluteContrast,[0.99 1])
                                        ffprintf(ff,['Ignoring o.responseScreenAbsoluteContrast (%.2f). '...
                                            'Response screen for negative contrast binary signals is always nearly 100% contrast.\n'],...
                                            oo(oi).responseScreenAbsoluteContrast);
                                        error('Ignoring o.responseScreenAbsoluteContrast (%.2f). Please use default [].',oo(oi).responseScreenAbsoluteContrast);
                                    end
                                    texture=Screen('MakeTexture',oo(oi).window,~img*oo(oi).gray1,0,0,1); % Uses only two clut entries (0 1), nicely antialiased.
                                else
                                    if isempty(oo(oi).responseScreenAbsoluteContrast)
                                        c=(cal.LLast-oo(oi).LBackground)/oo(oi).LBackground; % Max possible contrast.
                                        c=min(c,1);
                                    else
                                        c=oo(oi).responseScreenAbsoluteContrast;
                                    end
                                    texture=Screen('MakeTexture',oo(oi).window,(c*img+1)*oo(oi).gray,0,0,1);
                                end
                            else
                                PrintImageStatistics(MFileLineNr,oo(oi),i,'after MakeTexture',img)
                                if isempty(oo(oi).responseScreenAbsoluteContrast)
                                    % Maximize absolute contrast.
                                    if oo(oi).thresholdPolarity>0
                                        c=(cal.LLast-oo(oi).LBackground)/oo(oi).LBackground; % Max possible contrast.
                                        c=min(c,1);
                                    else
                                        c=(cal.LFirst-oo(oi).LBackground)/oo(oi).LBackground; % Most negative possible contrast.
                                        c=max(c,-1);
                                    end
                                else
                                    c=oo(oi).responseScreenAbsoluteContrast;
                                end
                                im=1+c*img;
                                if oo(oi).printImageStatistics
                                    fprintf('%d: o.signalMin %.2f, o.signalMax %.2f\n',...
                                        MFileLineNr,oo(oi).signalMin,oo(oi).signalMax);
                                    fprintf('%d: c %.2f, 1+c*o.signalMin %.2f, 1+c*o.signalMax %.2f\n',...
                                        MFileLineNr,c,1+c*oo(oi).signalMin,1+c*oo(oi).signalMax);
                                    fprintf('%d: o.LBackground %.1f, LB*(1+c*o.signalMin) %.2f, LB*(1+c*o.signalMax) %.2f\n',...
                                        MFileLineNr,oo(oi).LBackground,oo(oi).LBackground*(1+c*[oo(oi).signalMin oo(oi).signalMax]));
                                    fprintf('%d: "1+signal  " im: size %dx%dx%d, mean %.2f, sd %.2f, min %.2f, max %.2f\n',...
                                        MFileLineNr,size(im,1),size(im,2),size(im,3),mean(im(:)),std(im(:)),min(im(:)),max(im(:)));
                                end
                                im=IndexOfLuminance(cal,im*oo(oi).LBackground)/oo(oi).maxEntry;
                                if oo(oi).printImageStatistics
                                    fprintf('%d: "index         " im: size %dx%dx%d, mean %.2f, sd %.2f, min %.2f, max %.2f\n',...
                                        MFileLineNr,size(im,1),size(im,2),size(im,3),mean(im(:)),std(im(:)),min(im(:)),max(im(:)));
                                end
                                texture=Screen('MakeTexture',oo(oi).window,im,0,0,1);
                            end
                            Screen('DrawTexture',oo(oi).window,texture,RectOfMatrix(img),rect);
                            Screen('Close',texture);
                            if oo(oi).labelAlternatives
                                Screen('TextSize',oo(oi).window,oo(oi).textSize);
                                if streq(oo(oi).targetKind,'gabor')
                                    textRect=AlignRect([0 0 oo(oi).textSize oo(oi).textSize],rect,'center','top');
                                else
                                    textRect=AlignRect([0 0 oo(oi).textSize oo(oi).textSize],rect,'left','top');
                                end
                                Screen('DrawText',oo(oi).window,oo(oi).alphabet(i),textRect(1),textRect(4),black,oo(oi).gray1,1);
                            end
                            rect=OffsetRect(rect,step(1),step(2));
                        end % for i=1:oo(oi).alternatives
                        leftEdgeOfResponse=rect(1);
                end % switch oo(oi).task
                if oo(oi).assessLoadGamma
                    ffprintf(ff,'Line %d: o.contrast %.3f, LoadNormalizedGammaTable 0.5*range/mean=%.3f\n', ...
                        MFileLineNr,oo(oi).contrast,(cal.LLast-cal.LFirst)/(cal.LLast+cal.LFirst));
                end
                if oo(oi).assessGray
                    pp=Screen('GetImage',oo(oi).window,[20 20 21 21]);
                    ffprintf(ff,'Line %d: Gray index is %d (%.1f cd/m^2). Corner is %d.\n',...
                        MFileLineNr,oo(oi).gray*oo(oi).maxEntry,LuminanceOfIndex(cal,oo(oi).gray*oo(oi).maxEntry),pp(1));
                end
                if trial == 1
                    WaitSecs(0.5); % First time is slow. Mario suggested a work around, explained at beginning of this file.
                end
                if isfinite(oo(oi).targetDurationSecs)
                    % If signal is over, then set CLUT to allow maximum
                    % contrast of the response screen, using newly computed
                    % cal.gamma. If signal is ongoing, then we leave the
                    % CLUT as it is.
                    Screen('LoadNormalizedGammaTable',oo(oi).window,cal.gamma,loadOnNextFlip);
                end
                Screen('Flip',oo(oi).window,0,1); % Display instructions.
            end
            
            %% COLLECT RESPONSE
            switch oo(oi).task
                case '4afc'
                    global ptb_mouseclick_timeout
                    ptb_mouseclick_timeout=0.8;
                    clicks=GetClicks;
                    if ~ismember(clicks,1:locations)
                        ffprintf(ff,'*** %d clicks. Escape.\n',clicks);
                        if oo(oi).speakInstructions
                            Speak('Escape.');
                        end
                        [o.quitExperiment,o.quitBlock,o.skipTrial]=OfferEscapeOptions(oo(oi).window,oo,oo(oi).textMarginPix);
                        trial=trial-1;
                        oo(oi).trials=oo(oi).trials-1;
                    end
                    if o.quitExperiment
                        oo(1).quitExperiment=true;
                       ffprintf(ff,'*** ESCAPE ESCAPE. Quitting experiment.\n');
                        if oo(oi).speakInstructions
                            Speak('Done.');
                        end
                        break;
                    end
                    if o.quitBlock
                        ffprintf(ff,'*** ESCAPE RETURN. Proceeding to next block.\n');
                        if oo(oi).speakInstructions
                            Speak('Proceeding to next block.');
                        end
                        break;
                    end
                    if o.skipTrial
                        ffprintf(ff,'*** ESCAPE SPACE. Proceeding to next trial.\n');
                        continue
                    end
                    oo(oi).transcript.responseTimeSecs(oo(oi).trials)=GetSecs-oo(oi).transcript.stimulusOnsetSecs(oo(oi).trials);
                    response=clicks;
                case 'identify'
                    o.quitBlock=false;
                    % Prepare list of keys to enable.
                    ok=ismember(lower(oo(oi).alphabet),letterNumberCharString);
                    if ~all(ok)
                        error('Oops. Not all the characters in o.alphabet "%s" are in the list of letterNumber keys: "%s".',oo(oi).alphabet,unique(letterNumberCharString));
                    end
                    enableKeyCodes=[escapeKeyCode graveAccentKeyCode];
                    for i=1:length(oo(oi).alphabet)
                        enableKeyCodes=[enableKeyCodes letterNumberKeyCodes(lower(oo(oi).alphabet(i))==letterNumberCharString)];
                    end
                    responseChar=GetKeypress(enableKeyCodes,oo(oi).deviceIndex);
                    if ismember(responseChar,[escapeChar,graveAccentChar])
                        [o.quitExperiment,o.quitBlock,o.skipTrial]=OfferEscapeOptions(oo(oi).window,oo,oo(oi).textMarginPix);
                        trial=trial-1;
                        oo(oi).trials=oo(oi).trials-1;
                    end
                    if o.quitExperiment
                        oo(1).quitExperiment=true;
                       ffprintf(ff,'*** User typed ESCAPE twice. Quitting experiment.\n');
                        if oo(oi).speakInstructions
                            Speak('Done.');
                        end
                        break;
                    end
                    if o.quitBlock
                        ffprintf(ff,'*** User typed ESCAPE. Proceeding to next block.\n');
                        if oo(oi).speakInstructions
                            Speak('Proceeding to next block.');
                        end
                        break;
                    end
                    if o.skipTrial
                        ffprintf(ff,'*** User typed ESCAPE. Proceeding to next trial.\n');
                        continue
                    end
                    oo(oi).transcript.responseTimeSecs(oo(oi).trials)=GetSecs-oo(oi).transcript.stimulusOnsetSecs(oo(oi).trials);
                    if length(responseChar) > 1
                        % GetKeypress might return a multi-character string,
                        % but our code assumes the response is a scalar, not a
                        % matrix. So we replace the string by 0.
                        responseChar=0;
                    end
                    [ok,response]=ismember(lower(responseChar),lower(oo(oi).alphabet));
                case 'identifyAll'
                    message=sprintf('Please type all three letters (%s) followed by RETURN:',oo(oi).alphabet(1:oo(oi).alternatives));
                    textRect=[0, 0, oo(oi).textSize, 1.2*oo(oi).textSize];
                    textRect=AlignRect(textRect,bottomCaptionRect,'left','bottom');
                    textRect=OffsetRect(textRect,oo(oi).textSize/2,-1.5*oo(oi).textSize); % Inset from screen edges
                    textRect=round(textRect);
                    bounds=Screen('TextBounds',oo(oi).window,message);
                    ratio=RectWidth(bounds)/(0.93*RectWidth(bottomCaptionRect));
                    if ratio > 1
                        Screen('TextSize',oo(oi).window,floor(oo(oi).textSize/ratio));
                    end
                    if all(oo(oi).alphabet==upper(oo(oi).alphabet))
                        [responseString,terminatorChar]=GetEchoStringUppercase(oo(oi).window,message,textRect(1),textRect(4)-oo(oi).textSize,black,oo(oi).gray,1,oo(oi).deviceIndex);
                    else
                        [responseString,terminatorChar]=GetEchoString(oo(oi).window,message,textRect(1),textRect(4)-oo(oi).textSize,black,oo(oi).gray,1,oo(oi).deviceIndex);
                    end
                    oo(oi).transcript.responseTimeSecs(oo(oi).trials)=GetSecs-oo(oi).transcript.stimulusOnsetSecs(oo(oi).trials);
                    %                Screen('FillRect',oo(oi).window,oo(oi).gray1,bottomCaptionRect);
                    Screen('TextSize',oo(oi).window,oo(oi).textSize);
                    if ismember(terminatorChar,[escapeChar,graveAccentChar])
                        [o.quitExperiment,o.quitBlock,o.skipTrial]=OfferEscapeOptions(oo(oi).window,oo,oo(oi).textMarginPix);
                        trial=trial-1;
                        oo(oi).trials=oo(oi).trials-1;
                   end
                    if o.quitExperiment
                        oo(1).quitExperiment=true;
                        ffprintf(ff,'*** User typed ESCAPE twice. Quitting experiment.\n');
                        if oo(oi).speakInstructions
                            Speak('Done.');
                        end
                        break;
                    end
                    if o.quitBlock
                        ffprintf(ff,'*** User typed ESCAPE. Proceeding to next block.\n');
                        if oo(oi).speakInstructions
                            Speak('Proceeding to next block.');
                        end
                        break;
                    end
                    if o.skipTrial
                        ffprintf(ff,'*** User typed ESCAPE. Proceeding to next trial.\n');
                        continue
                    end
                    [ok,responses]=ismember(lower(responseString),lower(oo(oi).alphabet));
                    if ~all(ok)
                        warning('Some letters ''%s'' are not in alphabet %s.',responseString,oo(oi).alphabet);
                    end
                    if length(responses)~=3
                        warning('Response must have 3 letters, not %d: "%s". Trial skipped.',length(responses),responseString);
                        waitMessage=sprintf('Sorry. You must type 3 letters, but you typed %d: "%s". Trial ignored. Continuing.\n',length(responses),responseString);
                        o.skipTrial=true;
                        trial=trial-1;
                        oo(oi).trials=oo(oi).trials-1;
                        continue
                    end
                    switch oo(oi).thresholdResponseTo
                        case 'target'
                            response=responses(2);
                        case 'flankers'
                            response=responses([1 3]);
                    end
                    oo(oi).transcript.rawResponseString{oo(oi).trials}=responseString;
                    oo(oi).transcript.flankerResponse{oo(oi).trials}=responses([1 3]);
                    [~,oo(oi).transcript.targetResponse{oo(oi).trials}]=ismember(oo(oi).transcript.rawResponseString{oo(oi).trials}(2),oo(oi).alphabet);
                    if length(oo(oi).transcript.flankerXYDeg{oo(oi).trials})>1 && oo(oi).transcript.flankerXYDeg{oo(oi).trials}{1}(1)>oo(oi).transcript.flankerXYDeg{oo(oi).trials}{2}(1)
                        % The flankers are created in order of increasing
                        % radial eccentricity. However, the observer
                        % responds in order of increasing X eccentricity,
                        % so here, if necessary, we flip the order of the
                        % flanker stimulus reports to match that of the
                        % observer's response.
                        oo(oi).transcript.flankers{oo(oi).trials}=fliplr(oo(oi).transcript.flankers{oo(oi).trials});
                        oo(oi).transcript.flankerXYDeg{oo(oi).trials}=fliplr(oo(oi).transcript.flankerXYDeg{oo(oi).trials});
                    end
                case 'rate'
                    ratings='0123456789';
                    o.quitBlock=false;
                    responseChar=GetKeypress([numberKeyCodes ...
                        escapeKeyCode graveAccentKeyCode],oo(oi).deviceIndex);
                    oo(oi).transcript.responseTimeSecs(oo(oi).trials)=GetSecs-oo(oi).transcript.stimulusOnsetSecs(oo(oi).trials);
                    if ismember(responseChar,[escapeChar,graveAccentChar])
                        [o.quitExperiment,o.quitBlock,o.skipTrial]=OfferEscapeOptions(oo(oi).window,oo,oo(oi).textMarginPix);
                        trial=trial-1;
                        oo(oi).trials=oo(oi).trials-1;
                    end
                    if o.quitExperiment
                        oo(1).quitExperiment=true;
                        ffprintf(ff,'*** User typed ESCAPE twice. Quitting experiment.\n');
                        if oo(oi).speakInstructions
                            Speak('Done.');
                        end
                        break;
                    end
                    if o.quitBlock
                        ffprintf(ff,'*** User typed ESCAPE. Proceeding to next block.\n');
                        if oo(oi).speakInstructions
                            Speak('Proceeding to next block.');
                        end
                        break;
                    end
                    if o.skipTrial
                        ffprintf(ff,'*** User typed ESCAPE. Proceeding to next trial.\n');
                        continue
                    end
                    if length(responseChar) > 1
                        % GetKeypress might return a multi-character string,
                        % but our code assumes the response is a scalar, not a
                        % matrix. So we replace the string by 0.
                        responseChar=0;
                    end
                    [~,response]=ismember(lower(responseChar),ratings);
                    response=response-1;
            end % switch oo(oi).task
            if ~o.quitBlock
                if ~isfinite(oo(oi).targetDurationSecs)
                    % Signal persists until response, so we measure response time.
                    oo(oi).movieFrameFlipSecs(iMovieFrame+1,oo(oi).trials)=GetSecs;
                end
                % CHECK DURATION
                if oo(oi).useDynamicNoiseMovie
                    movieFirstSignalFrame=oo(oi).moviePreFrames+1;
                    movieLastSignalFrame=oo(oi).movieFrames-oo(oi).moviePostFrames;
                else
                    movieFirstSignalFrame=1;
                    movieLastSignalFrame=1;
                end
                oo(oi).measuredTargetDurationSecs(oo(oi).trials)=oo(oi).movieFrameFlipSecs(movieLastSignalFrame+1,oo(oi).trials)-...
                    oo(oi).movieFrameFlipSecs(movieFirstSignalFrame,oo(oi).trials);
                oo(oi).likelyTargetDurationSecs(oo(oi).trials)=round(oo(oi).measuredTargetDurationSecs(oo(oi).trials)*movieFrameRate)/movieFrameRate;
                % Somewhat arbitrarily, we allow stimuli up to 30% too long.
                overlyLong=oo(oi).likelyTargetDurationSecs(oo(oi).trials)>1.3*oo(oi).targetDurationSecs;
                if oo(oi).ignoreOverlyLongTrials && overlyLong
                    s='Ignoring overly long trial. ';
                    oo(oi).ignoreTrial=true;
                else
                    s='';
                end
                s=sprintf('%sSignal duration requested %.3f s, measured %.3f s, and likely %.3f s, an excess of %.0f display frames.\n', ...
                    s,oo(oi).targetDurationSecs,oo(oi).measuredTargetDurationSecs(oo(oi).trials),oo(oi).likelyTargetDurationSecs(oo(oi).trials), ...
                    (oo(oi).likelyTargetDurationSecs(oo(oi).trials)-oo(oi).targetDurationSecs)*displayFrameRate);
                if overlyLong
                    ffprintf(ff,'WARNING: %s',s);
                elseif oo(oi).printDurations
                    ffprintf(ff,'%s',s);
                end
            end
        else
            response=ModelObserver(o,oo(oi).signal,movieImage{oo(oi).moviePreFrames+1});
        end % if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
        if o.quitBlock
            break;
        end
        switch oo(oi).task % score as right or wrong
            case '4afc'
                isRight=response == signalLocation;
                oo(oi).transcript.target(oo(oi).trials)=signalLocation;
            case {'identify' 'identifyAll'}
                oo(oi).transcript.target(oo(oi).trials)=whichSignal;
                switch oo(oi).thresholdResponseTo
                    case 'target'
                        isRight=response == whichSignal;
                    case 'flankers'
                        % There are two flankers, so, in this case,
                        % isRight, response, and flankers are all 1x2
                        % arrays.
                        isRight=response == oo(oi).transcript.flankers{oo(oi).trials};
                end
            case 'rate'
                isRight=response>=oo(oi).ratingThreshold(whichSignal);
                oo(oi).transcript.target(oo(oi).trials)=whichSignal;
        end
        if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
            switch oo(oi).task
                case 'rate'
                    Snd('Play',okBeep);
                otherwise
                    if any(isRight)
                        Snd('Play',rightBeep);
                    else
                        Snd('Play',wrongBeep);
                    end
            end
        end
        switch oo(oi).thresholdParameter
            case 'spacing'
                spacingDeg=flankerSpacingPix/oo(oi).pixPerDeg;
                tTest=log10(spacingDeg);
            case 'size'
                targetSizeDeg=oo(oi).targetHeightPix/oo(oi).pixPerDeg;
                tTest=log10(targetSizeDeg);
            case 'contrast'
            case 'flankerContrast'
        end
        trialsRight=trialsRight+sum(isRight);
        oo(oi).trialsRight=oo(oi).trialsRight+sum(isRight);
        for i=1:size(isRight)
            oo(oi).q=QuestUpdate(oo(oi).q,tTest,isRight(i)); % Add the new datum (actual test intensity and observer isRight) to the database.
            if oo(oi).questPlusEnable
                stim=20*tTest;
                outcome=isRight(i)+1;
                oo(oi).questPlusData=qpUpdate(oo(oi).questPlusData,stim,outcome);
            end
        end
        oo(oi).data(oo(oi).trials,1:1+length(isRight))=[tTest isRight];
        oo(oi).transcript.response{oo(oi).trials}=response;
        oo(oi).transcript.intensity(oo(oi).trials)=tTest;
        oo(oi).transcript.isRight{oo(oi).trials}=isRight;
        oo(oi).transcript.condition(oo(oi).trials)=oi;
        if cal.ScreenConfigureDisplayBrightnessWorks && ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
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
    end % while trial<oo(oi).trialsPerBlock
    
    %% DONE. REPORT THRESHOLD FOR THIS BLOCK.
    % This loop should be enhanced to separate the data for each conditions.
    if ~isempty(oo(oi).data)
        psych.t=unique(oo(oi).data(:,1));
        psych.r=1+10.^psych.t;
        for i=1:length(psych.t)
            dataAtT=oo(oi).data(:,1) == psych.t(i);
            psych.trials(i)=sum(dataAtT);
            psych.right(i)=sum(oo(oi).data(dataAtT,2));
        end
    else
        psych=[];
    end
    oo(oi).psych=psych;
    
    %% LOOP THROUGH ALL THE CONDITIONS, TO REPORT ONE THRESHOLD PER CONDITION.
    for oi=1:conditions
        oo(oi).questMean=QuestMean(oo(oi).q);
        oo(oi).questSd=QuestSd(oo(oi).q);
        t=QuestMean(oo(oi).q); % Used in printouts below.
        sd=QuestSd(oo(oi).q); % Used in printouts below.
        oo(oi).approxRequiredNumber=64/10^((oo(oi).questMean-oo(oi).idealT64)/0.55);
        oo(oi).p=oo(oi).trialsRight/oo(oi).trials;
        rDeg=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
        switch oo(oi).thresholdParameter
            case 'spacing'
                ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',oo(oi).observer,100*oo(oi).p,targetSizeDeg,rDeg,10^oo(oi).questMean);
            case 'size'
                ffprintf(ff,'%s: p %.0f%%, ecc. %.1f deg, threshold size %.3f deg.\n',oo(oi).observer,100*oo(oi).p,rDeg,10^oo(oi).questMean);
            case 'contrast'
                oo(oi).contrast=oo(oi).thresholdPolarity*10^oo(oi).questMean;
            case 'flankerContrast'
                oo(oi).flankerContrast=oo(oi).thresholdPolarity*10^oo(oi).questMean;
        end
        oo(oi).EOverN=oo(oi).contrast^2*oo(oi).E1/oo(oi).N;
        oo(oi).efficiency=oo(oi).idealEOverNThreshold/oo(oi).EOverN;
        
        %% QUESTPlus: Estimate steepness and threshold contrast.
        if oo(oi).questPlusEnable && isfield(oo(oi).questPlusData,'trialData')
            psiParamsIndex=qpListMaxArg(oo(oi).questPlusData.posterior);
            psiParamsBayesian=oo(oi).questPlusData.psiParamsDomain(psiParamsIndex,:);
            if oo(oi).questPlusPrint
                ffprintf(ff,'Quest: Max posterior est. of threshold: log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
                    oo(oi).questMean,oo(oi).steepness,oo(oi).guess,oo(oi).lapse);
                %          ffprintf(ff,'QuestPlus: Max posterior estimate:      log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
                %             psiParamsBayesian(1)/20,psiParamsBayesian(2),psiParamsBayesian(3),psiParamsBayesian(4));
            end
            psiParamsFit=qpFit(oo(oi).questPlusData.trialData,oo(oi).questPlusData.qpPF,psiParamsBayesian,oo(oi).questPlusData.nOutcomes,...,
                'lowerBounds', [min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],...
                'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
            if oo(oi).questPlusPrint
                ffprintf(ff,'QuestPlus: Max likelihood estimate:     log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
                    psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
            end
            oo(oi).qpContrast=oo(oi).thresholdPolarity*10^(psiParamsFit(1)/20);	% threshold contrast
            switch oo(oi).thresholdParameter
                case 'contrast'
                    oo(oi).contrast=oo(oi).qpContrast;
                case 'flankerContrast'
                    oo(oi).flankerContrast=oo(oi).qpContrast;
            end
            oo(oi).qpSteepness=psiParamsFit(2);          % steepness
            oo(oi).qpGuessing=psiParamsFit(3);
            oo(oi).qpLapse=psiParamsFit(4);
            %% Plot trial data with maximum likelihood fit
            if oo(oi).questPlusPlot
                figure('Name',[oo(oi).experiment ':' oo(oi).conditionName],'NumberTitle','off');
                title(oo(oi).conditionName,'FontSize',14);
                hold on
                stimCounts=qpCounts(qpData(oo(oi).questPlusData.trialData),oo(oi).questPlusData.nOutcomes);
                stim=[stimCounts.stim];
                stimFine=linspace(-40,0,100)';
                plotProportionsFit=qpPFWeibull(stimFine,psiParamsFit);
                for cc=1:length(stimCounts)
                    nTrials(cc)=sum(stimCounts(cc).outcomeCounts);
                    pCorrect(cc)=stimCounts(cc).outcomeCounts(2)/nTrials(cc);
                end
                legendString=sprintf('%.2f %s',oo(oi).noiseSD,oo(oi).observer);
                semilogx(10.^(stimFine/20),plotProportionsFit(:,2),'-','Color',[0 0 0],'LineWidth',3,'DisplayName',legendString);
                scatter(10.^(stim/20),pCorrect,100,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',...
                    [0 0 0],'MarkerEdgeAlpha',.1,'MarkerFaceAlpha',.1,'DisplayName',legendString);
                set(gca,'xscale','log');
                set(gca,'XTickLabel',{'0.01' '0.1' '1'});
                xlabel('Contrast');
                ylabel('Proportion correct');
                xlim([0.01 1]); ylim([0 1]);
                set(gca,'FontSize',12);
                oo(oi).targetCyclesPerDeg=oo(oi).targetGaborCycles/oo(oi).targetHeightDeg;
                noteString{1}=sprintf('%s: %s %.1f c/deg, ecc %.0f deg, %.1f s\n%.0f cd/m^2, eyes %s, trials %d',...
                    oo(oi).conditionName,oo(oi).targetKind,oo(oi).targetCyclesPerDeg,oo(oi).eccentricityXYDeg(1),oo(oi).targetDurationSecs,oo(oi).LBackground,oo(oi).eyes,oo(oi).trials);
                noteString{2}=sprintf('%8s %7s %5s %9s %8s %5s','observer','noiseSD','log c','steepness','guessing','lapse');
                noteString{end+1}=sprintf('%-8s %7.2f %5.2f %9.1f %8.2f %5.2f', ...
                    oo(oi).observer,oo(oi).noiseSD,log10(oo(oi).qpContrast),oo(oi).qpSteepness,oo(oi).qpGuessing,oo(oi).qpLapse);
                text(0.4,0.4,'noiseSD observer');
                legend('show','Location','southeast');
                legend('boxoff');
                annotation('textbox',[0.14 0.11 .5 .2],'String',noteString,...
                    'FitBoxToText','on','LineStyle','none',...
                    'FontName','Monospaced','FontSize',9);
                drawnow;
            end % if oo(oi).questPlusPlot
        end % if oo(oi).questPlusEnable
              
        %% LUMINANCE
        if oi==1
            if oo(oi).useFilter
                ffprintf(ff,'Background luminance %.1f cd/m^2, which filter reduced to %.2f cd/m^2. ',oo(oi).LBackground,oo(oi).luminanceAtEye);
            else
                ffprintf(ff,'Background luminance %.1f cd/m^2. ',oo(oi).LBackground);
            end
            % No new line, so next item continues on same line.
        end
        
        %% WORK FLOW TIMING
        if oi==1
            secs=(GetSecs-blockStartSecs)/trial;
            if secs>1
                ffprintf(ff,'%.0f s/trial, across all conditions.\n',secs);
            else
                ffprintf(ff,'%.0f ms/trial, across all conditions.\n',secs*1000);
            end
        end
        
       
        %% PRINT BOLD SUMMARY OF CONDITION oi
        oo(oi).E=10^(2*oo(oi).questMean)*oo(oi).E1;
        if oi==1
            ffprintf(ff,'\n');
        end
        msg=sprintf(['%d of %d. "%s". %d trials. %.0f%% right. '...
                    'Threshold log contrast %.2f',plusMinusChar,'%.2f (m',plusMinusChar,'sd),'],...
                    oi,length(oo),oo(oi).conditionName,oo(oi).trials,100*oo(oi).trialsRight/oo(oi).trials,t,sd);
        switch oo(oi).targetModulates
            case 'luminance'
                ffprintf(ff,'<strong>%s contrast %.4f, log E/N %.2f, efficiency %.5f</strong>\n',...
                    msg,oo(oi).thresholdPolarity*10^t,log10(oo(oi).EOverN),oo(oi).efficiency);
            case {'noise' 'entropy'}
                ffprintf(ff,'<strong>%s log(o.r-1) %.2f',plusMinusChar,'%.2f, approxRequiredNumber %.0f</strong>\n',...
                    msg,oo(oi).approxRequiredNumber);
        end
        if abs(oo(oi).trialsRight/oo(oi).trials-oo(oi).pThreshold) > 0.1
            ffprintf(ff,'WARNING: Proportion correct %.0f%% is far from threshold criterion %.0f%%, so don''t trust the estimated threshold.\n',...
                100*oo(oi).trialsRight/oo(oi).trials,100*oo(oi).pThreshold);
        end
%         switch oo(oi).targetModulates
%             case 'luminance',
%                 corr=zeros(length(oo(oi).signal));
%                 for i=1:length(oo(oi).signal)
%                     for j=1:i
%                         cii=sum(oo(oi).signal(i).image(:).*oo(oi).signal(i).image(:));
%                         cjj=sum(oo(oi).signal(j).image(:).*oo(oi).signal(j).image(:));
%                         cij=sum(oo(oi).signal(i).image(:).*oo(oi).signal(j).image(:));
%                         corr(i,j)=cij/sqrt(cjj*cii);
%                         corr(j,i)=corr(i,j);
%                     end
%                 end
%                 [iGrid,jGrid]=meshgrid(1:length(oo(oi).signal),1:length(oo(oi).signal));
%                 offDiagonal=iGrid~=jGrid;
%                 oo(oi).signalCorrelation=mean(corr(offDiagonal));
%                 ffprintf(ff,'Average cross-correlation %.2f\n',oo(oi).signalCorrelation);
%                 approximateIdealEOverN=(-1.189+4.757*log10(length(oo(oi).signal)))/(1-oo(oi).signalCorrelation);
%                 ffprintf(ff,'Approximation, assuming pThreshold=0.64, predicts ideal threshold is about log E/N %.2f, E/N %.1f\n',log10(approximateIdealEOverN),approximateIdealEOverN);
%                 ffprintf(ff,'The approximation is Eq. A.24 of Pelli et al. (2006) Vision Research 46:4646-4674.\n');
%         end
        switch oo(oi).targetModulates
            case 'noise'
                t=oo(oi).questMean;
                oo(oi).r=10^t+1;
                oo(oi).approxRequiredNumber=64./10.^((t-oo(oi).idealT64)/0.55);
                oo(oi).logApproxRequiredNumber=log10(oo(oi).approxRequiredNumber);
                ffprintf(ff,'o.r %.3f, o.approxRequiredNumber %.0f\n',oo(oi).r,oo(oi).approxRequiredNumber);
                %              logNse=std(logApproxRequiredNumber)/sqrt(length(tSample));
                %              ffprintf(ff,['SUMMARY: %s %d blocks mean',plusMinusChar,'se: log(o.r-1) %.2f',plusMinusChar,'%.2f, log(approxRequiredNumber) %.2f',plusMinusChar,'%.2f\n'],...
                % oo(oi).observer,length(tSample),mean(tSample),tse,logApproxRequiredNumber,logNse);
            case 'entropy'
                t=oo(oi).questMean;
                oo(oi).r=10^t+1;
                signalEntropyLevels=oo(oi).r*oo(oi).backgroundEntropyLevels;
                ffprintf(ff,'Entropy levels: o.r %.2f, background levels %d, signal levels %.1f\n',oo(oi).r,oo(oi).backgroundEntropyLevels,signalEntropyLevels);
                if ~isempty(oo(oi).psych)
                    ffprintf(ff,'t\tr\tlevels\tbits\tright\ttrials\t%%\n');
                    oo(oi).psych.levels=oo(oi).psych.r*oo(oi).backgroundEntropyLevels;
                    for i=1:length(oo(oi).psych.t)
                        ffprintf(ff,'%.2f\t%.2f\t%.0f\t%.1f\t%d\t%d\t%.0f\n',oo(oi).psych.t(i),oo(oi).psych.r(i),oo(oi).psych.levels(i),log2(oo(oi).psych.levels(i)),oo(oi).psych.right(i),oo(oi).psych.trials(i),100*oo(oi).psych.right(i)/oo(oi).psych.trials(i));
                    end
                end
        end % switch oo(oi).targetModulates

        %% STIMULUS TIMING
        oo(oi).targetDurationSecsMean=mean(oo(oi).likelyTargetDurationSecs,'omitnan');
        oo(oi).targetDurationSecsSD=std(oo(oi).likelyTargetDurationSecs,'omitnan');
        if ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
            ffprintf(ff,['"%s" Across %d trials, target duration %.3f',plusMinusChar,'%.3f s (m',plusMinusChar,'sd).\n'],...
                oo(oi).conditionName,length(oo(oi).likelyTargetDurationSecs),...
                oo(oi).targetDurationSecsMean,oo(oi).targetDurationSecsSD);
        end
  
        %% SAVE EACH THRESHOLD IN ITS OWN FILE, WITH A SUFFIX DESIGNATING THE CONDITION NUMBER.
        oo(oi).newCal=cal;
        [~,neworder]=sort(lower(fieldnames(oo(oi))));
        oo(oi)=orderfields(oo(oi),neworder);
        save(fullfile(oo(oi).dataFolder,[oo(oi).dataFilename '.mat']),'o','cal');
        try % save to .json file
            if streq(oo(oi).targetKind,'image')
                % json encoding of 12 faces takes 60 s, which is
                % unbearable, so we omit the signals from the json file.
                o1=rmfield(o,'signal');
            else
                o1=o;
            end
            if exist('jsonencode','builtin')
                json=jsonencode(o1);
            else
                addpath(fullfile(myPath,'lib/jsonlab'));
                json=savejson('',o1);
            end
            clear o1
            fid=fopen(fullfile(oo(oi).dataFolder,[oo(oi).dataFilename '.json']),'w');
            fprintf(fid,'%s',json);
            fclose(fid);
        catch e
            warning('Failed to save .json file.');
            warning(e.message);
        end % save to .json file
        try % save transcript to .json file
            if isempty(oo(oi).transcript.intensity)
                if oo(oi).trials>1
                    warning('oo(%d).transcript.intensity is empty.',oi);
                end
            else
                if exist('jsonencode','builtin')
                    json=jsonencode(oo(oi).transcript);
                else
                    addpath(fullfile(myPath,'lib/jsonlab'));
                    json=savejson('',oo(oi).transcript);
                end
                fid=fopen(fullfile(oo(oi).dataFolder,[oo(oi).dataFilename '.transcript.json']),'w');
                fprintf(fid,'%s',json);
                fclose(fid);
            end
        catch e
            warning('Failed to save .transcript.json file.');
            warning(e.message);
        end % save transcript to .json file
        fprintf('Results saved as %s with extensions .txt, .mat, and .json \nin the data folder: %s/\n\n',oo(oi).dataFilename,oo(oi).dataFolder);
    end % for oi=1:conditions

    %% GOODBYE
    if oo(oi).speakInstructions
        if o.quitExperiment && ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
            Speak('QUITTING now. Done.');
        else
            if ~o.quitBlock && oo(oi).blockNumber == oo(oi).blocksDesired && oo(oi).congratulateWhenDone && ~ismember(oo(oi).observer,oo(oi).algorithmicObservers)
                Speak('Congratulations. End of block.');
            end
        end
    end
    % RestoreCluts;
    if Screen(oo(oi).window,'WindowKind') == 1
        % Tell observer what's happening.
        Screen('LoadNormalizedGammaTable',oo(oi).window,cal.old.gamma,loadOnNextFlip);
        Screen('FillRect',oo(oi).window);
        Screen('DrawText',oo(oi).window,' ',0,0,1,1,1); % Set background color.
        string=sprintf('Saving results to disk ...');
        DrawFormattedText(oo(oi).window,string,...
            oo(oi).textSize,1.5*oo(oi).textSize,black,oo(oi).textLineLength,[],[],1.3);
        Screen('Flip',oo(oi).window); % Display message.
    end
    ListenChar(0); % flush
    ListenChar;
    if ~isempty(oo(oi).window) && (o.quitExperiment || oo(oi).blockNumber >= oo(oi).blocksDesired)
        sca; % Screen('CloseAll'); ShowCursor;
        if ismac
            AutoBrightness(cal.screen,1); % Restore autobrightness.
        end
        window=[];
        [oo.window]=deal([]);
    end
    if ismac && false
        % NOT IN USE: This applescript "activate" command provokes a screen
        % refresh (by selecting MATLAB). My computers each have only one
        % display, upon which my MATLAB programs open a Psychtoolbox
        % window. This applescript eliminates an annoyingly long pause at
        % the end of my Psychtoolbox programs running under MATLAB 2014a,
        % when returning to the MATLAB command window after twice opening
        % and closing Screen windows. Without this command, when I return
        % to MATLAB, the whole screen remains blank for a long time, maybe
        % 30 s, or until I click something, so I can't tell that I'm back
        % in MATLAB. This applescript command provokes a screen refresh, so
        % the MATLAB editor appears immediately. Among several computers,
        % the problem is always present in MATLAB 2014a and never in MATLAB
        % 2015a. (All computers are running Mavericks.)
        % denis.pelli@nyu.edu, June 18, 2015
        % I disabled this in April 2018 because it takes 0.1 s.
        status=system('osascript -e ''tell application "MATLAB" to activate''');
    end
    if ~isempty(oo(oi).window)
        Screen('Preference','VisualDebugLevel',oldVisualDebugLevel);
        Screen('Preference','SuppressAllWarnings',oldSupressAllWarnings);
    end
    fclose(logFid); logFid=-1;
    oOld.observer=oo(oi).observer;
    oOld.experimenter=oo(oi).experimenter;
    oOld.eyes=oo(oi).eyes;
    oOld.filterTransmission=oo(oi).filterTransmission;
    oOld.secs=GetSecs; % Date for staleness.
catch e
    %% MATLAB catch
    ListenChar;
    sca; % screen close all
    window=[];
    [oo.window]=deal([]);
    if exist('cal','var') && isfield(cal,'old') && isfield(cal.old,'gamma')
        Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
    end
    AutoBrightness(cal.screen,1); % Restore autobrightness.
    if logFid>-1
        fclose(logFid);
        logFid=-1;
    end
    % Sort field names.
    [~,neworder]=sort(lower(fieldnames(o)));
    o=orderfields(o,neworder);
    
    rethrow(e);
end % try
end % function o=NoiseDiscrimination(o)

%% FUNCTION SaveSnapshot
function o=SaveSnapshot(o)
global fixationLines fixationCrossWeightPix labelBounds location  ...
    tTest leftEdgeOfResponse cal ff whichSignal logFid
% Hasn't been tested since it became a subroutine. It may need more of its
% variables to be declared "global". A more elegant solution, more
% transparent that "global" would be to put all the currently global
% variables into a new struct called "my". It would be received as an
% argument and might need to be returned as an output. Note that if "o" is
% modified here, it too may need to be returned as an output argument, or
% made global.
if o.snapshotShowsFixationAfter && ~isempty(fixationLines)
    Screen('DrawLines',o.window,fixationLines,fixationCrossWeightPix,0); % fixation
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
    cropRect=o.screenrect;
end
o.approxRequiredNumber=64/10^((tTest-o.idealT64)/0.55);
rect=Screen('TextBounds',o.window,'approxRequiredNumber 0000');
r=o.screenrect;
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
    saveSize=Screen('TextSize',o.window,round(o.textSize*.4));
    saveFont=Screen('TextFont',o.window,'Courier');
    for i=1:4
        s=[sprintf('L%d',i) sprintf(' %4.2f',x(i).L)];
        Screen('DrawText',o.window,s,rect(1),rect(2)-360-(5-i)*30);
    end
    for i=1:4
        s=[sprintf('p%d',i) sprintf(' %4.2f',x(i).p)];
        Screen('DrawText',o.window,s,rect(1),rect(2)-240-(5-i)*30);
    end
    Screen('TextSize',o.window,round(o.textSize*.8));
    Screen('DrawText',o.window,sprintf('Mean %4.2f %4.2f %4.2f %4.2f',x(:).mean),rect(1),rect(2)-240);
    Screen('DrawText',o.window,sprintf('Sd   %4.2f %4.2f %4.2f %4.2f',x(:).sd),rect(1),rect(2)-210);
    Screen('DrawText',o.window,sprintf('Max  %4.2f %4.2f %4.2f %4.2f',x(:).max),rect(1),rect(2)-180);
    Screen('DrawText',o.window,sprintf('Min  %4.2f %4.2f %4.2f %4.2f',x(:).min),rect(1),rect(2)-150);
    Screen('DrawText',o.window,sprintf('Bits %4.2f %4.2f %4.2f %4.2f',x(:).entropy),rect(1),rect(2)-120);
    Screen('TextSize',o.window,saveSize);
    Screen('TextFont',o.window,saveFont);
end
o.snapshotCaptionTextSize=ceil(o.snapshotCaptionTextSizeDeg*o.pixPerDeg);
saveSize=Screen('TextSize',o.window,o.snapshotCaptionTextSize);
saveFont=Screen('TextFont',o.window,'Courier');
caption={''};
switch o.targetModulates
    case 'luminance'
        caption{1}=sprintf('signal %.3f',o.thresholdPolarity*10^tTest);
        caption{2}=sprintf('noise sd %.3f',o.noiseSD);
    case 'noise'
        caption{1}=sprintf('noise sd %.3f',o.noiseSD);
        caption{end+1}=sprintf('n %.0f',o.targetHeightPix/o.noiseCheckPix);
    case 'entropy'
        caption{1}=sprintf('ratio # lum. %.3f',1+10^tTest);
        caption{2}=sprintf('noise sd %.3f',o.noiseSD);
        caption{end+1}=sprintf('n %.0f',o.targetHeightPix/o.noiseCheckPix);
    otherwise
        caption{1}=sprintf('sd ratio %.3f',1+10^tTest);
        caption{2}=sprintf('approxRequiredNumber %.0f',o.approxRequiredNumber);
end
switch o.task
    case '4afc'
        answer=signalLocation;
        answerString=sprintf('%d',answer);
        caption{end+1}=sprintf('xyz%s',lower(answerString));
    case {'identify' 'rate'}
        answer=whichSignal;
        answerString=o.alphabet(answer);
        caption{end+1}=sprintf('xyz%s',lower(answerString));
end
rect=OffsetRect(o.stimulusRect,-o.snapshotCaptionTextSize/2,0);
for i=length(caption):- 1:1
    r=Screen('TextBounds',o.window,caption{i});
    r=AlignRect(r,rect,RectRight,RectBottom);
    Screen('DrawText',o.window,caption{i},r(1),r(2));
    rect=OffsetRect(r,0,-o.snapshotCaptionTextSize);
end
Screen('TextSize',o.window,saveSize);
Screen('TextFont',o.window,saveFont);
Screen('Flip',o.window,0,1); % Save image for snapshot. Show target, instructions, and fixation.
img=Screen('GetImage',o.window,cropRect);
%                         grayPixels=img==o.gray;
%                         img(grayPixels)=128;
freezing='';
if o.noiseFrozenInTrial
    freezing='_frozenInTrial';
end
if o.noiseFrozenInBlock
    freezing=[freezing '_frozenInBlock'];
end
switch o.targetModulates
    case 'entropy'
        signalDescription=sprintf('%s_%dv%dlevels',o.targetModulates,signalEntropyLevels,o.backgroundEntropyLevels);
    otherwise
        signalDescription=sprintf('%s',o.targetModulates);
end
switch o.targetModulates
    case 'luminance'
        filename=sprintf('%s_%s_%s%s_%.3fc_%.0fpix_%s',signalDescription,o.task,o.noiseType,freezing,o.thresholdPolarity*10^tTest,o.targetHeightPix/o.noiseCheckPix,answerString);
    case {'noise', 'entropy'}
        filename=sprintf('%s_%s_%s%s_%.3fr_%.0fpix_%.0freq_%s',signalDescription,o.task,o.noiseType,freezing,1+10^tTest,o.targetHeightPix/o.noiseCheckPix,o.approxRequiredNumber,answerString);
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
        ffprintf(ff,'approxRequiredNumber %.0f, sd ratio o.r %.3f, log(o.r-1) %.2f\n',o.approxRequiredNumber,1+10^tTest,tTest);
    case 'entropy'
        ffprintf(ff,'ratio o.r=signalLevels/backgroundLevels %.3f, log(o.r-1) %.2f\n',1+10^tTest,tTest);
end
o.trialsPerBlock=1;
o.blocksDesired=1;
ffprintf(ff,'SUCCESS: o.saveSnapshot is done. Image saved, now returning.\n');
fclose(logFid);
logFid=-1;
ListenChar;
ShowCursor;
sca; % screen close all
% window=[];
[oo.window]=deal([]); % NOTE: o is not returned by this function.
AutoBrightness(cal.screen,1); % Restore autobrightness.
return
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
o.LBackground=(LMax+LMin)/2;
cal.LFirst=LMin;
cal.LLast=o.LBackground+(o.LBackground-LMin); % Symmetric about o.LBackground.
cal.nFirst=o.firstGrayClutEntry;
cal.nLast=o.lastGrayClutEntry;
cal=LinearizeClut(cal);
img=cal.nFirst:cal.nLast;
n=floor(RectWidth(o.screenrect)/length(img));
r=[0 0 n*length(img) RectHeight(o.screenrect)];
Screen('LoadNormalizedGammaTable',o.window,cal.gamma,loadOnNextFlip);
if o.assessLoadGamma
    ffprintf(ff,'Line %d: o.contrast %.3f, LoadNormalizedGammaTable 0.5*range/mean=%.3f\n', ...
        MFileLineNr,o.contrast,(cal.LLast-cal.LFirst)/(cal.LLast+cal.LFirst));
end
Screen('TextFont',o.window,'Verdana');
Screen('TextSize',o.window,24);
for bits=1:11
    % WARNING: Mario advises against using PutImage, which is retained in
    % Psychtoolbox solely for backward compatibility. As of May 31, 2017,
    % it's not compatible with high-res color, but that may be fixed in the
    % next release.
    Screen('PutImage',o.window,img,r);
    msg=sprintf(' Now alternately clearing video DAC bit %d. Hit SPACE bar to continue. ',bits);
    newGamma=bitset(round(cal.gamma*(2^17-1)),17-bits,0)/(2^17-1);
    Screen('DrawText',o.window,' o.assessBitDepth: Testing bits 1 to 11. ',100,100,0,1,1);
    Screen('DrawText',o.window,msg,100,136,0,1,1);
    Screen('Flip',o.window);
    ListenChar(0); % Flush. May not be needed.
    ListenChar(2); % No echo. Needed.
    while CharAvail
        GetChar;
    end
    while ~CharAvail
        Screen('LoadNormalizedGammaTable',o.window,cal.gamma,loadOnNextFlip);
        Screen('Flip',o.window);
        WaitSecs(0.2);
        Screen('LoadNormalizedGammaTable',o.window,newGamma,loadOnNextFlip);
        Screen('Flip',o.window);
        WaitSecs(0.2);
    end
    Screen('LoadNormalizedGammaTable',o.window,cal.gamma,loadOnNextFlip);
    GetChar;
    ListenChar; % Back to normal. Needed.
end
if o.speakInstructions
    Speak('Done');
end
end % function assessBitDepth

%% FUNCTION MeasureContrast
function oOut=MeasureContrast(o,line)
global cal ff trial
LBackground=(cal.LLast+cal.LFirst)/2;
fprintf('%d: LFirst %.1f, LBackground %.1f, LLast %.1f cd/m^2\n',line,cal.LFirst,LBackground,cal.LLast);
% Measure signal luminance L
index=IndexOfLuminance(cal,(1+o.contrast)*LBackground);
Screen('FillRect',o.window,index/o.maxEntry,o.stimulusRect);
Screen('Flip',o.window,0,1);
if o.usePhotometer
    L=GetLuminance;
else
    L=LBackground*2*round(o.maxEntry*(1+o.contrast)/2)/o.maxEntry;
end
% Measure background luminance L0
index0=IndexOfLuminance(cal,LBackground);
Screen('FillRect',o.window,index0/o.maxEntry,o.stimulusRect);
Screen('Flip',o.window,0,1);
if o.usePhotometer
    L0=GetLuminance;
else
    L0=LBackground;
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
global cal ff
LBackground=(cal.LFirst+cal.LLast)/2;
img=IndexOfLuminance(cal,LBackground);
img=img:o.maxEntry;
L=EstimateLuminance(cal,img);
dL=diff(L);
i=find(dL,1); % index of first non-zero element in dL
if isfinite(i)
    contrastEstimate=dL(i)/L(i); % contrast of minimal increase near LBackground
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
index=IndexOfLuminance(cal,img*LBackground);
imgEstimate=EstimateLuminance(cal,index)/LBackground;
rmsContrastError=rms(img(:)-imgEstimate(:));
% ffprintf(ff,'Assess contrast: At LBackground, the minimum contrast step is %.4f, with rmsContrastError %.3f\n',contrastEstimate,rmsContrastError);
switch o.targetModulates
    case 'luminance'
        img=[1, 1+o.contrast];
        img=IndexOfLuminance(cal,img*LBackground);
        L=EstimateLuminance(cal,img);
        ffprintf(ff,'Assess contrast: Desired o.contrast of %.3f will be rendered as %.3f (estimated).\n',o.contrast,diff(L)/L(1));
    otherwise
        noiseSDEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:));
        img=1+o.r*(o.noiseSD/o.noiseListSd)*noise;
        img=IndexOfLuminance(cal,img*LBackground);
        imgEstimate=EstimateLuminance(cal,img)/LBackground;
        rEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:))/noiseSDEstimate;
        ffprintf(ff,'noiseSDEstimate %.3f (nom. %.3f), rEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,rEstimate,o.r);
        if abs(log10([noiseSDEstimate/o.noiseSD rEstimate/o.r])) > 0.5*log10(2)
            ffprintf(ff,'WARNING: PLEASE TELL DENIS: noiseSDEstimate %.3f (nom. %.3f), rEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,rEstimate,o.r);
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
gratingL=o.LBackground*repmat([0.2 1.8],400,200); % 400x400 grating
gratingImg=IndexOfLuminance(cal,gratingL);
texture=Screen('MakeTexture',o.window,gratingImg/o.maxEntry,0,0,1);
r=RectOfMatrix(gratingImg);
r=CenterRect(r,o.stimulusRect);
Screen('DrawTexture',o.window,texture,RectOfMatrix(gratingImg),r);
peekImg=Screen('GetImage',o.window,r,'drawBuffer');
Screen('Close',texture);
peekImg=peekImg(:,:,2);
figure(1);
subplot(2,2,1); imshow(uint8(gratingImg)); title('image written');
subplot(2,2,2); imshow(peekImg); title('image read');
subplot(2,2,3); imshow(uint8(gratingImg(1:4,1:4))); title('4x4 of image written')
subplot(2,2,4); imshow(peekImg(1:4,1:4)); title('4x4 of image read');
fprintf('desired normalized luminance: %.1f %.1f\n',gratingL(1,1:2)/o.LBackground);
fprintf('grating written: %.1f %.1f\n',gratingImg(1,1:2));
fprintf('grating read: %.1f %.1f\n',peekImg(1,1:2));
fprintf('normalized luminance: %.1f %.1f\n',LuminanceOfIndex(cal,peekImg(1,1:2))/o.LBackground);
end % function AssessLinearity(o)

%% FUNCTION ModelObserver
function response=ModelObserver(o,signal,location)
global signalImageIndex signalMask  
% ModelObserver now works for identifying a luminance/noise/entropy letter
% in noise. Hasn't yet been critically tested to see if its performance
% matches theoretical benchmarks. But the thresholds seem reasonable, and
% quest succesfully homes in on 75%. Instead of globals, we could put 
% the currently global variables into a new struct called "model".
switch o.observer
    case 'ideal'
        switch o.task
            case '4afc'
                assert(length(location)==4);
                likely=nan(1,length(location));
                switch o.targetModulates
                    case 'luminance'
                        % pick darkest
                        for i=1:length(location)
                            % signalImageIndex selects the pixels that
                            % contain the signal rect.
                            im=location(i).image(signalImageIndex);
                            likely(i)=-mean((im(:)-1));
                        end
                    case {'noise' 'entropy'}
                        % The maximum likelihood choice is the one with
                        % greatest power.
                        for i=1:length(location)
                            % signalImageIndex selects the pixels that
                            % contain the signal rect.
                            im=location(i).image(signalImageIndex);
                            likely(i)=mean((im(:)-1).^2);
                            if o.printLikelihood
                                im=im(:)-1;
                                im
                            end
                        end
                        if o.printLikelihood
                            likely
                            signalLocation
                        end
                    otherwise
                        error('Illegal o.targetModulates "%s".',o.targetModulates);
                end % switch o.targetModulates
            case {'identify' 'identifyAll'}
                assert(length(location)==1);
                likely=nan(1,o.alternatives);
                switch o.targetModulates
                    case 'luminance'
                        % THIS WORKS.
                        im=zeros(size(signal(1).image));
                        % signalImageIndex selects the pixels in the
                        % signal rect.
                        im(:)=location(1).image(signalImageIndex); % the signal
                        for i=1:o.alternatives
                            d=im-(1+o.contrast*signal(i).image);
                            likely(i)=-mean(d(:).^2);
                        end
                    case {'noise' 'entropy'}
                        % Calculate log likelihood of each possible letter.
                        % Use the binary signal template (hypothesis) to
                        % select "ink" pixels, and considers the rest
                        % "paper" pixels. It knows the sd that ink and
                        % paper are supposed to have.
                        %
                        % sdPaper and sdInk are scalars. im is 20x21
                        % pixels, a letter displayed as an increment in
                        % (gaussian) noise contrast. signalMask is 20x21
                        % binary pixels, 1 means ink, 0 means paper. ink is
                        % a vector, 238x1 for letter "S", the pixels in im
                        % hypothesized to be ink. paper is a vector, 182x1
                        % for letter "S", the pixels in im hypothesized to
                        % be paper. likely is a vector, 1x9, with a value
                        % for each possible letter.
                        sdPaper=o.noiseSD;
                        sdInk=o.r*o.noiseSD;
                        im=zeros(size(signal(1).image));
                        im(:)=location(1).image(signalImageIndex);
                        for i=1:o.alternatives
                            signalMask=signal(i).image;
                            ink=im(signalMask)-1;
                            paper=im(~signalMask)-1;
                            likely(i)=-length(ink)*log(sdInk*sqrt(2*pi))-sum(0.5*(ink/sdInk).^2)...
                                -length(paper)*log(sdPaper*sqrt(2*pi))-sum(0.5*(paper/sdPaper).^2);
                        end
                    otherwise
                        error('Illegal o.targetModulates "%s".',o.targetModulates);
                end % switch o.targetModulates
            otherwise
                error('Illegal o.task "%s".',o.task);
        end % switch o.task
        [~,response]=max(likely);
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
                for i=1:length(location)
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
                for i=1:length(location)
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
                for i=1:length(location)
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
end % function ModelObserver(o,signal,location)

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
function o=SetUpNearPoint(o)
global ff
black=0; % The CLUT color code for black.
white=1; % The CLUT color code for white.
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
r=InsetRect(o.stimulusRect,o.targetMargin*o.targetHeightDeg*o.pixPerDeg,o.targetMargin*o.targetHeightDeg*o.pixPerDeg);
if ~all(r(1:2)<=r(3:4))
    error(['%.1f o.targetHeightDeg too big to fit (with %.2f o.targetMargin) in %.1f x %.1f deg screen. '...
        'Reduce %.1f o.viewingDistanceCm or %.1f o.targetHeightDeg.'],...
        o.targetHeightDeg,o.targetMargin,...
        [RectWidth(o.stimulusRect) RectHeight(o.stimulusRect)]/o.pixPerDeg,...
        o.viewingDistanceCm,o.targetHeightDeg);
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
if isempty(o.window)
    return
end
string=sprintf('Please adjust the viewing distance so the X is %.1f cm from the observer''s eye. ',...
    o.viewingDistanceCm);
string=[string 'Tilt and swivel the display so the X is orthogonal to the observer''s line of sight. '...
    'Then hit RETURN to continue.\n'];
Screen('TextSize',o.window,o.textSize);
Screen('TextFont',o.window,'Verdana');
Screen('FillRect',o.window,o.gray1);
Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
DrawFormattedText(o.window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
x=o.nearPointXYPix(1);
y=o.nearPointXYPix(2);
a=0.05*RectHeight(o.stimulusRect);
[~,~,lineWidthMinMaxPix(1),lineWidthMinMaxPix(2)]=Screen('DrawLines',o.window);
widthPix=max([min([a/20 lineWidthMinMaxPix(2)]) lineWidthMinMaxPix(1)]);
Screen('DrawLine',o.window,black,x-a,y-a,x+a,y+a,widthPix);
Screen('DrawLine',o.window,black,x+a,y-a,x-a,y+a,widthPix);
Screen('Flip',o.window); % Display request.
if o.speakInstructions
    string=strrep(string,'.0','');
    string=strrep(string,'\n','');
    Speak(string);
end
response=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
if ismember(response,[escapeChar,graveAccentChar])
    if o.speakInstructions
        Speak('Quitting.');
    end
    o.quitBlock=true;
    o.quitExperiment=true;
    return
end
Screen('FillRect',o.window,o.gray1);
Screen('Flip',o.window); % Blank, to acknowledge response.
end % function SetUpNearPoint

%% SET UP FIXATION
function o=SetUpFixation(o,ff)
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
o.fixationXYPix=round(XYPixOfXYDeg(o,[0 0]));

if ~o.useFixation || isempty(o.window)
    o.fixationIsOffscreen=false;
else
    black=BlackIndex(o.window); % Retrieves the CLUT color code for black.
    white=WhiteIndex(o.window); % Retrieves the CLUT color code for white.
    if ~IsXYInRect(o.fixationXYPix,o.stimulusRect)
        o.fixationIsOffscreen=true;
        % o.fixationXYPix is in plane of display. Off-screen fixation is
        % not! It is the same distance from the eye as the near point.
        % fixationOffsetXYCm is the vector from near point to fixation.
        rDeg=sqrt(sum(o.nearPointXYDeg.^2));
        ori=atan2d(-o.nearPointXYDeg(2),-o.nearPointXYDeg(1));
        rCm=2*sind(0.5*rDeg)*o.viewingDistanceCm;
        fixationOffsetXYCm=[cosd(ori) sind(ori)]*rCm;
        if false
            % check
            oriCheck=atan2d(fixationOffsetXYCm(2),fixationOffsetXYCm(1));
            rCmCheck=sqrt(sum(fixationOffsetXYCm.^2));
            rDegCheck=2*asind(0.5*rCm/o.viewingDistanceCm);
            xyDegCheck=[cosd(ori) sind(ori)]*rDeg;
            fprintf('CHECK OFFSCREEN GEOMETRY: ori %.1f %.1f; rCm %.1f %.1f; rDeg %.1f %.1f; xyDeg [%.1f %.1f] [%.1f %.1f]\n',...
                ori,oriCheck,rCm,rCmCheck,rDeg,rDegCheck,-o.nearPointXYDeg,xyDegCheck);
        end
        fixationOffsetXYCm(2)=-fixationOffsetXYCm(2); % Make y increase upward.
        
        string='OFF-SCREEN FIXATION. As indicated by the green arrows, please set up a fixation mark';
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
        string=[string ' the X.'];
        string=sprintf('%s Adjust the viewing distances so both your fixation mark and the X below are %.1f cm from the observer''s eye.',...
            string,o.viewingDistanceCm);
        string=[string ' Tilt and swivel the display so that the X is orthogonal to the observer''s line of sight. '...
            'Then hit RETURN to proceed, or ESCAPE to quit. '];
        string=[string sprintf(['\n\nEXPERT NOTE: You might be able to bring fixation back on-screen '...
            'by quitting now and then '...
            'pushing the target location (o.nearPointXYInUnitSquare [%.2f %.2f]) away from fixation, '...
            'or reducing o.viewingDistanceCm (%.1f cm), or reducing the target''s o.eccentricityXYDeg [%.1f %.1f]).'],...
            o.nearPointXYInUnitSquare,o.viewingDistanceCm,o.eccentricityXYDeg)];
        Screen('TextSize',o.window,o.textSize);
        Screen('TextFont',o.window,'Verdana');
        Screen('FillRect',o.window,o.gray1);
        Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
        DrawFormattedText(o.window,string,o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
        x=o.nearPointXYPix(1);
        y=o.nearPointXYPix(2);
        a=0.1*RectHeight(o.stimulusRect);
        [~,~,lineWidthMinMaxPix(1),lineWidthMinMaxPix(2)]=Screen('DrawLines',o.window);
        widthPix=max([min([a/20 lineWidthMinMaxPix(2)]) lineWidthMinMaxPix(1)]);
        Screen('DrawLine',o.window,black,x-a,y-a,x+a,y+a,widthPix);
        Screen('DrawLine',o.window,black,x+a,y-a,x-a,y+a,widthPix);
        
        % Draw two green arrows to desired location of offscreen fixation mark.
        if o.fixationXYPix(2)>o.stimulusRect(4) || o.fixationXYPix(2)<o.stimulusRect(2) % Fixation below or above rect.
            delta=[1,0]*RectWidth(o.stimulusRect)/3;
        else
            delta=[0,1]*RectHeight(o.stimulusRect)/3;
        end
        for s=[-1 1]
            [x,y]=RectCenterd(o.stimulusRect);
            baseXY=[x y]+s*delta;
            tipXY=o.fixationXYPix;
            [baseXY,tipXY]=ClipLineSegment2(baseXY,tipXY,o.stimulusRect);
            Screen('DrawLine',o.window,[0 1 0],baseXY(1),baseXY(2),tipXY(1),tipXY(2),widthPix);
            % arrow head
            xy=baseXY-tipXY;
            angle=atan2d(xy(2),xy(1));
            length=0.5*o.fixationCrossDeg*o.pixPerDeg;
            for rotation=[-30 30]
                xy=tipXY+length*[cosd(angle+rotation) sind(angle+rotation)];
                Screen('DrawLine',o.window,[0 1 0],xy(1),xy(2),tipXY(1),tipXY(2),widthPix);
            end
        end
        
        Screen('Flip',o.window); % Display question.
        if o.speakInstructions
            Speak(string);
        end
        answer=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
        Screen('FillRect',o.window,white);
        Screen('Flip',o.window); % Blank, to acknowledge response.
        if ismember(answer,returnChar)
            o.fixationIsOffscreen=true;
            ffprintf(ff,'Offscreen fixation mark (%.1f,%.1f) cm from near point of display.\n',fixationOffsetXYCm);
        else
            o.fixationIsOffscreen=false;
            error('User refused off-screen fixation. Please push the target location o.nearPointXYInUnitSquare [%.2f %.2f] away from fixation, or reduce o.viewingDistanceCm (%.1f cm), or reduce the target''s o.eccentricityXYDeg (%.1f %.1f).',...
                o.nearPointXYInUnitSquare,o.viewingDistanceCm,o.eccentricityXYDeg);
        end
    else
        o.fixationIsOffscreen=false;
    end
end
o.targetXYPix=XYPixOfXYDeg(o,o.eccentricityXYDeg);
if o.fixationCrossBlankedNearTarget
    ffprintf(ff,'Fixation cross is blanked near target. No delay in showing fixation after target.\n');
else
    ffprintf(ff,'Fixation cross is blanked during and until %.2f s after target. No selective blanking near target. \n',o.fixationCrossBlankedUntilSecsAfterTarget);
end
end % function SetUpFixation

%% COMPUTE CLUT
function [cal,o]=ComputeClut(cal,o)
% Set up luminance range that maximizes CLUT resolution over the range we
% need, allowing for superposition of noise on target and on flanker. (We
% assume flanker does not overlap target.) If the noise in fact does not
% superimpose target or flanker then this range may be broader than
% strictly necessary.
% We assume that:
% o.noiseListMin<=0
% o.noiseListMax>=0
% o.r>=1
% o.noiseSD>=0
% o.noiseListSd>0;
% o.LBackground>0;
% LFirst and LLast are the min and max of the luminance range that the CLUT
% will support. We make this range just big enough to include all the
% luminances our signal in noise may need, using the known min and max of
% the signal and noise.
cal.LFirst=o.LBackground*(1+o.noiseListMin*o.r*o.noiseSD/o.noiseListSd);
cal.LLast=o.LBackground*(1+o.noiseListMax*o.r*o.noiseSD/o.noiseListSd);
if ~o.useFlankers
    o.flankerContrast=0;
end
if streq(o.targetModulates,'luminance')
    if streq(o.targetKind,'image')
        assert(o.contrast>=0);
        cal.LFirst=cal.LFirst+o.LBackground*o.contrast*o.signalMin;
        cal.LLast=cal.LLast+o.LBackground*o.contrast*o.signalMax;
    else
        cal.LFirst=cal.LFirst+o.LBackground*min([0 o.contrast o.flankerContrast]);
        cal.LLast=cal.LLast+o.LBackground*max([0 o.contrast o.flankerContrast]);
    end
end
if o.annularNoiseBigRadiusDeg > o.annularNoiseSmallRadiusDeg
    cal.LFirst=min(cal.LFirst,o.LBackground*(1-o.noiseListMax*o.r*o.annularNoiseSD/o.noiseListSd));
    cal.LLast=max(cal.LLast,o.LBackground*(1+o.noiseListMax*o.r*o.annularNoiseSD/o.noiseListSd));
end
if o.symmetricLuminanceRange
    % Use smallest range centered on o.LBackground that includes LFirst and
    % LLast. Having a fixed index for "gray" (o.LBackground) assures us
    % that the gray areas (most of the screen) won't change when the CLUT
    % is updated. I no longer think that's important.
    LRange=2*max(abs([cal.LLast-o.LBackground o.LBackground-cal.LFirst]));
    maxLRange=2*min(max(cal.old.L)-o.LBackground,o.LBackground-min(cal.old.L));
    LRange=min(LRange,maxLRange);
    cal.LFirst=o.LBackground-LRange/2;
    cal.LLast=o.LBackground+LRange/2;
end
cal.nFirst=o.firstGrayClutEntry;
cal.nLast=o.lastGrayClutEntry;
if o.saveSnapshot
    cal.LFirst=min(cal.old.L);
    cal.LLast=max(cal.old.L);
    cal.nFirst=1;
    cal.nLast=o.maxEntry;
end
if false
    % Compute CLUT for the specific noise.
    L=[];
    for i=1:length(location)
        L=[L location(i).image(:)*o.LBackground];
    end
    cal.LFirst=min(L);
    cal.LLast=max(L);
else
    % Compute clut for all possible instances of noise with the given
    % noiseSD and noiseKind.
end
cal=LinearizeClut(cal);
if o.symmetricLuminanceRange
    grayCheck=IndexOfLuminance(cal,o.LBackground)/o.maxEntry;
    if ~o.saveSnapshot && abs(grayCheck-o.gray)>0.001
        ffprintf(ff,'The estimated o.gray index is %.4f (%.1f cd/m^2), not %.4f (%.1f cd/m^2).\n',...
            grayCheck,LuminanceOfIndex(cal,grayCheck*o.maxEntry),o.gray,LuminanceOfIndex(cal,o.gray*o.maxEntry));
        warning('The o.gray index changed!');
    end
else
    oldGray=o.gray;
    oo(1).gray=IndexOfLuminance(cal,o.LBackground)/o.maxEntry;
    if o.printGrayLuminance
        disp('ComputeClut');
        fprintf('o.gray old vs new %.2f %.2f\n',oldGray,o.gray);
        fprintf('o.contrast %.2f, o.LBackground %.0f cd/m^2, cal.old.L(end) %.0f cd/m^2\n',o.contrast,o.LBackground,cal.old.L(end));
        fprintf('%d: o.maxEntry*[o.gray1 o.gray]=[%.1f %.1f]\n',...
            MFileLineNr,o.maxEntry*[o.gray1 o.gray]);
        disp('cal.gamma(1+[o.gray1 o.gray]*o.maxEntry,:)');
        disp(cal.gamma(1+[o.gray1 o.gray]*o.maxEntry,:));
        disp('Luminance');
        g=cal.gamma(1+[o.gray1 o.gray]*o.maxEntry,:);
        disp(interp1(cal.old.G,cal.old.L,g,'pchip'));
    end
end
assert(isfinite(o.gray));
end % function ComputeClut

function [reply,o]=AskQuestion(oo,text)
% "text" argument is a struct with several fields: text.big, text.small,
% text.fine, text.question, text.setTextSizeToMakeThisLineFit. We
% optionally return "o" which is  possibly modified from the input o in
% o.textSize o.quitExperiment o.quitBlock and o.skipTrial. If "text" has the
% field text.setTextSizeToMakeThisLineFit then o.textSize is adjusted to
% make the line fit horizontally within o.screenrect.
global  ff
o=oo(1);
if isempty(o.window)
    reply='';
    return
end
escapeChar=char(27);
graveAccentChar='`';
black=0;
o.textSize=TextSizeToFit(o.window);
ListenChar(2); % no echo
Screen('FillRect',o.window,o.gray1);
Screen('TextSize',o.window,o.textSize);
Screen('TextFont',o.window,o.textFont,0);
y=o.screenrect(4)/2-(1+2*length(text.big))*o.textSize;
for i=1:length(text.big)
    Screen('DrawText',o.window,text.big{i},o.textMarginPix,y,black,o.gray1);
    y=y+2*o.textSize;
end
y=y-0.5*o.textSize;
Screen('TextSize',o.window,round(0.6*o.textSize));
Screen('DrawText',o.window,text.small,o.textMarginPix,y,black,o.gray1);
Screen('TextSize',o.window,round(o.textSize*0.35));
Screen('DrawText',o.window,text.fine,o.textMarginPix,o.screenrect(4)-0.5*o.textMarginPix,black,o.gray1,1);
Screen('TextSize',o.window,o.textSize);
if IsWindows
    background=[];
else
    background=o.gray1;
end
% fprintf('%d: o.deviceIndex %.0f.\n',MFileLineNr,o.deviceIndex);
[reply,terminatorChar]=GetEchoString(o.window,text.question,o.textMarginPix,0.82*o.screenrect(4),black,background,1,o.deviceIndex);
if ismember(terminatorChar,[escapeChar graveAccentChar])
    [o.quitExperiment,o.quitBlock,o.skipTrial]=OfferEscapeOptions(o.window,oo,o.textMarginPix);
    if o.quitExperiment
        ffprintf(ff,'*** User typed ESCAPE twice. Experiment terminated.\n');
    elseif o.quitBlock
        ffprintf(ff,'*** User typed ESCAPE. Block terminated.\n');
    else
        ffprintf(ff,'*** User typed ESCAPE, but chose to continue.\n');
    end
end
Screen('FillRect',o.window,o.gray1);
Screen('Flip',o.window); % Flip screen, to let observer know her answer was accepted.
end % function AskQuestion

function o=WaitUntilObserverIsReady(o,oo,message)
global fixationLines fixationCrossWeightPix ff
escapeChar=char(27);
graveAccentChar='`';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
Screen('FillRect',o.window,o.gray1);
Screen('FillRect',o.window,o.gray1,o.stimulusRect);
% fprintf('o.gray1*o.maxEntry %.1f, o.gray*o.maxEntry %.1f, o.maxEntry %.0f\n',o.gray1*o.maxEntry,o.gray*o.maxEntry,o.maxEntry);
if o.showCropMarks
    TrimMarks(o.window,frameRect);
end
if ~isempty(fixationLines)
    Screen('DrawLines',o.window,fixationLines,fixationCrossWeightPix,0); % fixation
end
Screen('Flip',o.window,0,1); % Show gray screen at o.LBackground with fixation and crop marks. Don't clear buffer.
readyString='';
if o.markTargetLocation
    readyString=[readyString 'The X indicates target center. '];
end
if true % Create readyString.
    if streq(o.eyes,'both')
        eyeOrEyes='eyes';
    else
        eyeOrEyes='eye';
    end
    if o.useFixation
        if o.fixationIsOffscreen
            readyString=sprintf('%sPlease fix your %s on your offscreen fixation mark, ',readyString,eyeOrEyes);
        else
            readyString=sprintf('%sPlease fix your %s on the center of the fixation cross +, ',readyString,eyeOrEyes);
        end
        word='and';
    else
        word='Please';
    end
    switch o.task
        case '4afc'
            readyString=[readyString word ' CLICK when ready to proceed.'];
            fprintf('Please CLICK when ready to proceed.\n');
        case {'identify' 'identifyAll' 'rate'}
            readyString=[readyString word ' press the SPACE bar when ready to proceed.'];
            fprintf('Please press the SPACE bar when ready to proceed.\n');
            if IsOSX && ismember(MacModelName,{'MacBook10,1' 'MacBookAir6,2' 'MacBookPro11,5' ... % Mine, without touch bar, just to test this code.
                    'MacBookPro13,2' 'MacBookPro13,3' ... % 2016 with touch bar.
                    'MacBookPro14,1' 'MacBookPro14,2' 'MacBookPro14,3'}) % 2017 with touch bar.
                readyString=['[For your convenience, hitting the accent grave tilde key "`~" is equivalent to hitting the ESCAPE key immediately above it.]\n' readyString];
            end
    end
end
msg=[message readyString];
Screen('DrawText',o.window,' ',0,0,1,o.gray1,1); % Set background color.
black=0;
Screen(o.window,'TextSize',o.textSize);
DrawFormattedText(o.window,msg,0.5*o.textSize,1.5*o.textSize,black,o.textLineLength,[],[],1.3);
Screen('Flip',o.window,0,1); % Proceeding to the trial.
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
    case {'identify' 'identifyAll' 'rate'}
        fprintf('*Waiting for SPACE bar to begin next trial.\n');
        responseChar=GetKeypress([spaceKeyCode escapeKeyCode graveAccentKeyCode],o.deviceIndex);
        % This keypress serves mainly to start the first trial, but we
        % offer to quit if the user hits ESCAPE.
        if ismember(responseChar,[escapeChar,graveAccentChar])
            [o.quitExperiment,o.quitBlock,o.skipTrial]=OfferEscapeOptions(o.window,oo,o.textMarginPix);
            if o.quitBlock
                ffprintf(ff,'*** User typed ESCAPE. Quitting block.\n');
                if o.speakInstructions
                    Speak('Block terminated.');
                end
            end
        end
end
end % function WaitUntilObserverIsReady

function PrintImageStatistics(line,o,i,msg,img)
global cal
if o.printImageStatistics
    im=img(1:end,1);
    fprintf(['%d: trials %d, signal %d, IMAGE STATS %s: size %dx%dx%d, mean %.2f, ' ...
        'sd %.2f, min %.2f, max %.2f, LBackground %.0f, LFirst %.0f, LLast %.0f, '...
        'o.contrast %.2f, o.noiseSD %.2f, o.signalMin %.2f, o.signalMax %.2f\n'],...
        line,o.trials,i,msg,size(im,1),size(im,2),size(im,3),mean(im(:)),std(im(:)),...
        min(im(:)),max(im(:)),o.LBackground,cal.LFirst,cal.LLast,...
        o.contrast,o.noiseSD,o.signalMin,o.signalMax);
end
end