function o=NoiseDiscrimination(oIn) 
% o=NoiseDiscrimination(o);
% Pass all your parameters in the "o" struct, which will be returned with
% all the results as additional fields. NoiseDiscrimination may adjust some
% of your parameters to satisfy physical constraints. Constraints include
% the screen size and the maximum possible contrast.
%
% You should write a short script that loads up all your parameters into an
% "o" struct and calls o=NoiseDiscrimination(o). I recommend beginning your
% script with "clear o" to make sure that you don't carry over any values
% from the last run as defaults for the new run.
%
% OFF THE NYU CAMPUS: If you have an NYU netid and you're using the NYU
% MATLAB license server then you can work from off campus if you install
% NYU's free VPN software on your computer:
% http://www.nyu.edu/its/nyunet/offcampus/vpn/#services
%
% SNAPSHOT: It is useful to take snapshots of the stimulus produced by
% NoiseDiscrimination. Such snapshots can be used in papers and talks to
% show our stimuli. If you request a snapshot then NoiseDiscrimination
% saves the first stimulus to a PNG image file and then quits with a fake
% error. To help you keep track of how you made each stimulus image file,
% some information about the condition is contained in the file name and in
% a caption on the figure. The caption may not be included if you enable
% cropping. Here are the parameters that you can control:
% o.saveSnapshot=1; % If true (1), take snapshot for public presentation.
% o.snapshotLetterContrast=0.2; % nan to request program default.
% o.cropSnapshot=0; % If true (1), crop to include only target and noise, plus response numbers, if displayed.
% o.snapshotCaptionTextSizeDeg=0.5;
%
% Standard condition for counting V1 neurons: o.noiseCheckPix=13;
% height=30*o.noiseCheckPix; o.distanceCm=45; SD=0.2, o.durationSec=0.2 s.
%
% Observer 'brightnessSeeker' is a model of the human observer with a
% saturation of brightness, based on an old research project of mine. As
% the noise gets stronger, this artificial o.observer "sees" it as dimmer
% and will identify the dim letter or choose the dimmest square. The
% strength of the saturation is set by "o.observerQuadratic=-1.2;" There's
% no need to adjust that. If we make that number big, like -10, this
% o.observer performs much like the ideal. If the number is zero, it'll be
% just guessing. I'm pretty sure -1.2 is the right setting.
%
% It wasn't easy to get the instructional text to image well. It's black,
% on a gray background, but the antialiasing in the font rendering
% surrounded each letter with with intermediate levels of gray. The
% intermediate values were problematic. In my CLUT the intermediate values
% between gray (128) and black (0) were much closer in luminance to the
% gray, making the letter seem too thin. Worse, I am computing a new color
% table (CLUT) for each trial, so this made the halo around the
% instructions flicker every time the CLUT changed. Eventually I realized
% that black is zero and that by making the gray background have an index
% of 1, the letters are indeed binary, since the font rendering software
% emits only integers and there are no integers between 0 and 1. This
% leaves me free to do whatever I want with the rest of the color table.
% The letters are imaged well, because the antialiasing software is
% allowed to do its best with the binary gamut.
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

% MIRRORING. PutImage does not respect mirroring. Mario Kleiner, July 13,
% 2014, explains why: Screen('PutImage') is implemented via
% glDrawPixels(). It doesn't respond to geometric transformations and
% 'PutImage' by itself is very inflexible, restricted and inefficient. I
% keep it intentionally so, so we have some very primitive way to put
% pixels on the screen, mostly for debugging of the more complex functions.
% Using it in any new code is not recommended.
% The most easy thing is to use DrawFormattedText() instead of
% Screen('DrawText') directly. DrawFormattedText() has optional parameters
% to mirror text left-right / upside-down, center it onscreen or in a
% selectable rect etc.
% For mirroring of images with glScale you can use
% Screen('MakeTexture/DrawTexture') or for online created content
% 'OpenOffscreenWindow' + 'DrawTexture'.
% texture=Screen('MakeTexture',window,imageMatrix);
% Screen('DrawTexture',window,texture,sourceRect,destinationRect);
% Screen('Close',texture);
% If you want to mirror the whole stimulus display, the PsychImaging()
% function has subtasks to ask for automatic mirroring of all the window
% content.
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask','General','FlipHorizontal');
% You can use the RemapMouse() function to correct GetMouse() positions
% for potential geometric distortions introduced by this function.
%
% FIXATION CROSS. The fixation cross is quite flexible. You specify its
% size (full width) and stroke thickness in deg. If you request
% o.fixationCrossBlankedNearTarget=1 then it maintains a blank margin (with
% no fixation line) around the target that is at least a target width (to
% avoid overlap masking) and at least half the eccentricity (to avoid
% crowding). Otherwise the fixation cross is blanked during target
% presentation and until o.fixationCrossBlankedUntilSecsAfterTarget.
%
% Annular Gaussian noise envelope.
% Use these three parameters to specify an annular gaussian envelope. 
% The amplitude is a Gaussian of R-Ra where R is the distance from letter
% center and Ra is o.annularNoiseEnvelopeRadiusDeg. When Ra is zero, this reduces to a
% normal gaussian centered on the letter. The code now computes a new
% summary of the "area" of the envelope: o.centralNoiseEnvelopeE1degdeg
% We should equate this when we compare hard edge annulus with gaussian
% envelope.
% 
addpath(fullfile(fileparts(mfilename('fullpath')),'AutoBrightness')); % folder in same directory as this file
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this file
%echo_executing_commands(2, 'local');
%diary ./diary.log
if 0
    % Copy this to produce a Gaussian annulus:
    o.noiseRadiusDeg=inf;
    o.annularNoiseEnvelopeRadiusDeg=2;
    o.noiseEnvelopeSpaceConstantDeg=1.1;
    o.annularNoiseBigRadiusDeg=inf;
    o.annularNoiseSmallRadiusDeg=inf;
    % Returns: o.centralNoiseEnvelopeE1degdeg
end
if 0
    % Copy this to produce a hard-edge annulus:
    o.noiseSD=0; % Usually in the range 0 to 0.4. Typically 0.2.
    o.noiseRadiusDeg=0;
    o.annularNoiseEnvelopeRadiusDeg=0;
    o.noiseEnvelopeSpaceConstantDeg=inf;
    o.annularNoiseSD=0.2; % Typically nan (i.e. use o.noiseSD) or 0.2.
    o.annularNoiseBigRadiusDeg=3; % Noise extent re target. Typically 1 or inf.
    o.annularNoiseSmallRadiusDeg=1; % Typically 1 or 0 (no hole).
    % Returns: o.centralNoiseEnvelopeE1degdeg
end
% For a "fair" contest of hard and soft annuli, we should:
%
% 1. make the central radius of the soft one
% o.annularNoiseEnvelopeRadiusDeg match the central radius of the hard one:
% (o.annularNoiseSmallRadiusDeg+o.annularNoiseBigRadiusDeg)/2
% 
% 2. adjust the annulus thickness of the hard annulus
% o.annularNoiseSmallRadiusDeg-o.annularNoiseBigRadiusDeg to achieve the
% same "area" as the Gaussian annulus. This "area" is reported in a new
% variable: o.centralNoiseEnvelopeE1degdeg

% clear all

rng('default');
if ismac && ~ScriptingOkShowPermission
    error('Please give MATLAB permission to control the computer. You''ll need admin privileges to do this.');
end
if nargin<1 || ~exist('oIn','var')
    oIn.noInputArgument=1;
end
o=[];
% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.
o.EnableCLUTMapping=0; % Broken. Screws up gamma correction.
o.testBitDepth=0;
o.useFractionOfScreen=0; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
o.distanceCm=50; % viewing distance
o.flipScreenHorizontally=0; % Use this when viewing the display in a mirror.
o.screen=0; % 0 for main screen
o.observer='junk'; % Name of person or existing algorithm.
% o.observer='denis'; o.observer='michelle'; o.observer='martin';
% o.observer='tiffany'; o.observer='irene'; o.observer='joy';
% o.observer='jacob'; o.observer='jacobaltholz';
% o.observer='brightnessSeeker'; % Existing algorithm instead of person.
% o.observer='blackshot'; % Existing algorithm instead of person.
% o.observer='maximum'; % Existing algorithm instead of person.
% o.observer='ideal'; % Existing algorithm instead of person.
algorithmicObservers={'ideal','brightnessSeeker','blackshot','maximum'};
o.trialsPerRun=40; % Typically 40.
o.runNumber=1; % For display only, indicate the run number. When o.runNumber==runsDesired this program says "Congratulations" before returning.
o.runsDesired=1; % How many runs you to plan to do, used solely for display (and congratulations).
o.speakInstructions=1;
o.congratulateWhenDone=1; % 0 or 1. Spoken after last run (i.e. when o.runNumber==o.runsDesired). You can turn this off.
o.runAborted=0; % 0 or 1. Returned value is 1 if the user aborts this run (i.e. threshold).
o.quitNow=0; % 0 or 1. Returned value is 1 if the observer wants to quit now; no more runs.
% o.targetModulates='noise';  % Display a noise increment.
o.targetKind='letter';
% o.targetKind='gabor'; % one cycle within targetSize
o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
o.targetGaborNames='VH';
o.targetModulates='luminance'; % Display a luminance decrement.
% o.targetModulates='entropy'; % Display an entropy increment.
o.task='identify'; % 'identify' or '4afc'
% o.thresholdParameter='size';
% o.thresholdParameter='spacing';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast','size', or 'spacing'.
% WARNING: size and spacing are not yet fully implemented.
o.alternatives=9; % The number of letters to use from o.alphabet.
o.tGuess=nan; % Specify a finite value for Quest, or nan for default.
o.tGuessSd=nan; % Specify a finite value for Quest, or nan for default.
o.pThreshold=0.75;
o.beta=nan; % Typically 1.7, 3.5, or Nan. Nan asks NoiseDiscrimination to set this at runtime.
o.measureBeta=0;
o.eccentricityDeg=0; % + for right, - for left, "nan" for no fixation.
o.targetHeightDeg=2; % Target size, range 0 to inf. If you ask for too much, it gives you the max possible.
% o.targetHeightDeg=30*o.noiseCheckDeg; % standard for counting neurons project
o.minimumTargetHeightChecks=8; % Minimum target resolution, in units of the check size.
o.durationSec=0.2; % Typically 0.2 or inf (wait indefinitely for response).
o.useFlankers=0; % 0 or 1. Enable for crowding experiments.
o.flankerContrast=-0.85; % Negative for dark letters.
o.flankerContrast=nan; % Nan requests that flanker contrast always equal signal contrast.
o.flankerSpacingDeg=4;
% o.flankerSpacingDeg=1.4*o.targetHeightDeg; % Put this in your code, if
% you like. It won't work here.
o.noiseSD=0.2; % Usually in the range 0 to 0.4. Typically 0.2.
% o.noiseSD=0; % Usually in the range 0 to 0.4. Typically 0.2.
o.annularNoiseSD=nan; % Typically nan (i.e. use o.noiseSD) or 0.2.
o.noiseCheckDeg=0.05; % Typically 0.05 or 0.2.
o.noiseRadiusDeg=1; % When o.task=4afc, the program will set o.noiseRadiusDeg=o.targetHeightDeg/2;
o.noiseEnvelopeSpaceConstantDeg=inf;
o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at noiseRadiusDeg.
o.noiseSpectrum='white'; % pink or white
o.showBlackAnnulus=0;
o.blackAnnulusContrast=-1; % (LBlack-LMean)/LMean. -1 for black line. >-1 for gray line.
o.blackAnnulusSmallRadiusDeg=2;
o.blackAnnulusThicknessDeg=0.1;
o.annularNoiseBigRadiusDeg=inf; % Noise extent in deg, or inf.
o.annularNoiseSmallRadiusDeg=inf; % Hole extent or 0 (no hole).
o.yellowAnnulusSmallRadiusDeg=inf; % Typically 1, or 2, or inf (for no yellow);
o.yellowAnnulusBigRadiusDeg=inf; % Typically inf.
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
o.noiseFrozenInTrial=0; % 0 or 1.  If true (1), use same noise at all locations
o.noiseFrozenInRun=0; % 0 or 1.  If true (1), use same noise on every trial
o.noiseFrozenInRunSeed=0; % 0 or positive integer. If o.noiseFrozenInRun, then any nonzero positive integer will be used as the seed for the run.
o.targetCross=0; % No vertical line indicating target location.
o.fixationCrossDeg=inf; % Typically 1 or inf. Make this at least 4 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationCrossWeightDeg=0.03; % Typically 0.03. Make it much thicker for scotopic testing.
o.fixationCrossBlankedNearTarget=1; % 0 or 1.
o.fixationCrossBlankedUntilSecsAfterTarget=0.6; % Pause after stimulus before display of fixation. Skipped when fixationCrossBlankedNearTarget. Not needed when eccentricity is bigger than the target.
o.textSizeDeg=0.6;
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
o.tSnapshot=nan; % nan to request program defaults.
o.cropSnapshot=0; % If true (1), show only the target and noise, without unnecessary gray background.
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
o.saveStimulus=0; % saves to o.savedStimulus
% o.eccentricityDeg=inf; % Requests no fixation, e.g. on snapshot.
o.gapFraction4afc=0.03; % Typically 0, 0.03, or 0.2. Gap, as a fraction of o.targetHeightDeg, between the four squares in 4afc task, ignored in identify task.
o.showCropMarks=0; % mark the bounding box of the target
o.showResponseNumbers=1;
o.responseNumbersInCorners=0;
o.printGammaLoadings=0; % print a log of these calls.
o.printSignalDuration=0; % print out actual duration of each trial.
o.printCrossCorrelation=0;
o.printLikelihood=0;
o.assessLinearity=0;
o.assessContrast=0; % diagnostic information
o.assessLowLuminance=0;
o.flipClick=0; % For debugging, speak and wait for click before and after each flip.
o.isKbLegacy=0; % collect response via 1:ListenChar+GetChar; 0:KbCheck
assessGray=0; % For debugging. Diagnostic printout when we load gamma table.
% o.observerQuadratic=-1.2; % estimated from old second harmonic data
o.observerQuadratic=-0.7; % adjusted to fit noise letter data.
o.backgroundEntropyLevels=2; % Value used only if o.targetModulates is 'entropy'
o.idealEOverNThreshold=nan; % You can run the ideal first, and then provide its threshold as a reference when testing human observers.
o.screen=0;
% o.screen=max(Screen('Screens'));
o.alphabet='DHKNORSVZ';
o.alphabetPlacement='top'; % 'top' or 'right';
o.replicatePelli2006=0;
o.isWin=IsWin; % override this to simulate Windows on a Mac.

[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
screenBufferRect=Screen('Rect',o.screen);
screenRect=Screen('Rect',o.screen,1);
resolution=Screen('Resolution',o.screen);

if o.useFractionOfScreen
    screenRect=round(o.useFractionOfScreen*screenRect);
end

if o.replicatePelli2006 || isfield(oIn,'replicatePelli2006') && oIn.replicatePelli2006
    % Set parameter defaults to match conditions of Pelli et al. (2006). Their
    % Table A (p. 4668) reports that ideal log E is -2.59 for Sloan, and
    % that log N is -3.60. Thus they reported ideal log E/N 1.01. This
    % script recreates their conditions and gets the same ideal threshold
    % E/N. Phew!
    % Pelli, D. G., Burns, C. W., Farell, B., & Moore-Page, D. C. (2006)
    % Feature detection and letter identification. Vision Research, 46(28),
    % 4646-4674.
    % https://psych.nyu.edu/pelli/pubs/pelli2006letters.pdf
    % https://psych.nyu.edu/pelli/papers.html
    o.idealEOverNThreshold=10^(-2.59 - -3.60); % from Table A of Pelli et al. 2006
    o.observer='ideal';
    o.trialsPerRun=1000;
    o.alphabet='CDHKNORSVZ'; % As in Pelli et al. (2006)
    o.alternatives=10; % As in Pelli et al. (2006).
    o.pThreshold=0.64; % As in Pelli et al. (2006).
    o.noiseType='gaussian';
    o.noiseSD=0.25;
    o.noiseCheckDeg=0.063;
    o.targetHeightDeg=29*o.noiseCheckDeg;
    pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
    o.pixPerDeg=2/0.0633; % As in Pelli et al. (2006).
    degPerCm=pixPerCm/o.pixPerDeg;
    o.distanceCm=57/degPerCm;
end
o.newClutForEachImage=1;

% All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
fields=fieldnames(oIn);
for i=1:length(fields)
    field=fields{i};
    o.(field)=oIn.(field);
end

if isnan(o.annularNoiseSD)
    o.annularNoiseSD=o.noiseSD;
end

if o.saveSnapshot
    if isfinite(o.snapshotLetterContrast) && streq(o.targetModulates,'luminance')
        o.tSnapshot=log10(o.snapshotLetterContrast);
    end
    if ~isfinite(o.tSnapshot)
        switch o.targetModulates
            case 'luminance',
                o.tSnapshot= -0.0; % log10(contrast)
            case 'noise',
                o.tSnapshot= .3; % log10(r-1)
            case 'entropy',
                o.tSnapshot= 0; % log10(r-1)
            otherwise
                error('Unknown o.targetModulates "%s".',o.targetModulates);
        end
    end
end
if streq(o.targetKind,'gabor')
    assert(length(o.targetGaborNames)>=length(o.targetGaborOrientationsDeg))
    o.alternatives=length(o.targetGaborOrientationsDeg);
    o.alphabet=o.targetGaborNames(1:o.alternatives);
end
if ~isfield(o,'labelAlternatives')
    switch o.targetKind
        case 'gabor'
            o.labelAlternatives=1;
        case 'letter'
            o.labelAlternatives=0;
            
    end
end
o.beginningTime=now;
t=datevec(o.beginningTime);
stack=dbstack;
if length(stack)==1;
    o.functionNames=stack.name;
else
    o.functionNames=[stack(2).name '-' stack(1).name];
end
if exist('data', 'dir') ~= 7
    mkdir('data');
end
o.datafilename=sprintf('%s-%s.%d.%d.%d.%d.%d.%d',o.functionNames,o.observer,round(t));
o.datafullfilename=fullfile(fileparts(mfilename('fullpath')),'data',o.datafilename);
dataFolder=fileparts(o.datafullfilename);
if ~exist(dataFolder,'dir')
   success=mkdir(dataFolder);
   if ~success
       error('Failed attempt to create "data" folder.');
   end
end
dataFid=fopen(fullfile(dataFolder,[o.datafilename '.txt']),'rt');
if dataFid~=-1
    error('Oops. There''s already a file called "%s.txt". Try again.',o.datafilename);
end
[dataFid,msg]=fopen([o.datafilename '.txt'],'wt');
if dataFid==-1
    error('%s. Could not create data file: %s',msg,[o.datafilename '.txt']);
end

assert(dataFid>-1);
ff=[1 dataFid];
fprintf('\nSaving results in:\n');
ffprintf(ff,'%s\n',o.datafilename);
ffprintf(ff,'%s %s\n',o.functionNames,datestr(now));
ffprintf(ff,'observer %s, task %s, alternatives %d,  beta %.1f,\n',o.observer,o.task,o.alternatives,o.beta);

useImresize=exist('imresize','file'); % Requires the Image Processing Toolbox.
cal.screen=o.screen;
if cal.screen>0
    fprintf('Using external monitor.\n');
end
cal=OurScreenCalibrations(cal.screen);

o.cal=cal;
if ~isfield(cal,'old') || ~isfield(cal.old,'L')
    fprintf('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
    error('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
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
pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
degPerCm=57/o.distanceCm;
o.pixPerDeg=pixPerCm/degPerCm;
textSize=round(o.textSizeDeg*o.pixPerDeg);
o.textSizeDeg=textSize/o.pixPerDeg;
o.lineSpacing =1.5;
o.stimulusRect=InsetRect(screenRect,0,o.lineSpacing*1.2*textSize);
o.noiseCheckPix=round(o.noiseCheckDeg*o.pixPerDeg);
switch o.task
    case 'identify',
        o.noiseCheckPix=min(o.noiseCheckPix,RectHeight(o.stimulusRect));
    case '4afc',
        o.noiseCheckPix=min(o.noiseCheckPix,floor(RectHeight(o.stimulusRect)/(2+o.gapFraction4afc)));
        o.noiseRadiusDeg=o.targetHeightDeg/2;
end
o.noiseCheckPix=max(o.noiseCheckPix,1);
o.noiseCheckDeg=o.noiseCheckPix/o.pixPerDeg;
BackupCluts(o.screen);
LMean=(max(cal.old.L)+min(cal.old.L))/2;
o.maxLRange=2*min(max(cal.old.L)-LMean,LMean-min(cal.old.L));
if IsOSX
    firstGrayClutEntry=10; % Used to be 2, but now need 10 in Mac OSX 10.11.1
    lastGrayClutEntry=254;
else
    firstGrayCLUTEntry=2;
    lastGrayClutEntry=254;
end
if o.isWin
    LRange=o.maxLRange;
    o.minLRange=inf;
    for i=1:100
        try
            cal.LFirst=LMean-LRange/2;
            cal.LLast=LMean+LRange/2;
            cal.nFirst=firstGrayClutEntry;
            cal.nLast=lastGrayClutEntry;
            cal=LinearizeClut(cal);
            cal.gamma(2,:)=0.5*(cal.gamma(1,:)+cal.gamma(3,:)); % for Windows
            assert(all(all(diff(cal.gamma)>=0))); % monotonic for Windows
            if o.printGammaLoadings; ffprintf(ff,'LoadNormalizedGammaTable %d, LRange/LMean=%.2f\n',MFileLineNr,LRange/LMean); end
            Screen('LoadNormalizedGammaTable',o.screen,cal.gamma); % might fail
            % Success!
            o.minLRange=LRange;
            LRange=LRange*0.9;
        catch
            % Failed.
            break;
        end
    end
    RestoreCluts;
    if ~isfinite(o.minLRange)
        error('Couldn''t fix the gamma table. Alas. LRange/LMean=%.2f',LRange/LMean);
    end
    fprintf('o.minLRange %.1f cd/m^2, 0.minLRange/LMean %.3f\n',o.minLRange,o.minLRange/LMean);
else
    o.minLRange=0;
end % if o.isWin


Screen('Preference','TextAntiAliasing',0);
textFont='Verdana';
if streq(o.task,'identify')
    o.showResponseNumbers=0; % Inappropriate so suppress.
    switch o.alphabetPlacement
        case 'right',
            o.stimulusRect(3)=o.stimulusRect(3)-RectHeight(screenRect)/max(6,o.alternatives);
        case 'top',
            o.stimulusRect(2)=max(o.stimulusRect(2),screenRect(2)+0.5*RectWidth(screenRect)/max(6,o.alternatives));
        otherwise
            error('Unknown alphabetPlacement "%d".\n',o.alphabetPlacement);
    end
end
o.stimulusRect=2*round(o.stimulusRect/2);
if streq(o.task,'identify')
    o.targetHeightPix=2*round(0.5*o.targetHeightDeg/o.noiseCheckDeg)*o.noiseCheckPix; % even round multiple of check size
    if o.targetHeightPix<o.minimumTargetHeightChecks*o.noiseCheckPix
        ffprintf(ff,'Increasing requested targetHeight checks from %d to %d, the minimum.\n',o.targetHeightPix/o.noiseCheckPix,o.minimumTargetHeightChecks);
        o.targetHeightPix=2*ceil(0.5*o.minimumTargetHeightChecks)*o.noiseCheckPix;
    end
else
    o.targetHeightPix=round(o.targetHeightDeg/o.noiseCheckDeg)*o.noiseCheckPix; % round multiple of check size
end
switch o.task
    case 'identify'
        maxTargetHeight=RectHeight(o.stimulusRect);
    case '4afc'
        maxTargetHeight=RectHeight(o.stimulusRect)/(2+o.gapFraction4afc);
        maxTargetHeight=floor(maxTargetHeight);
    otherwise
        error('Unknown o.task "%s".',o.task);
end
if o.targetHeightPix>maxTargetHeight
    ffprintf(ff,'Reducing requested o.targetHeightDeg (%.1f deg) to %.1f deg, the max possible.\n',o.targetHeightDeg,maxTargetHeight/o.pixPerDeg);
    o.targetHeightPix=maxTargetHeight;
end
o.targetHeightDeg=o.targetHeightPix/o.pixPerDeg;
if o.noiseRadiusDeg>maxTargetHeight/o.pixPerDeg
    ffprintf(ff,'Reducing requested o.noiseRadiusDeg (%.1f deg) to %.1f deg, the max possible.\n',o.noiseRadiusDeg,maxTargetHeight/o.pixPerDeg);
    o.noiseRadiusDeg=maxTargetHeight/o.pixPerDeg;
end
if o.useFlankers
    flankerSpacingPix=round(o.flankerSpacingDeg*o.pixPerDeg);
end
% The actual clipping is done using o.stimulusRect. This restriction of
% noiseRadius and annularNoiseBigRadius is merely to save time (and
% excessive texture size) by not computing pixels that won't be seen. The
% actual clipping is done using o.stimulusRect.
o.noiseRadiusDeg=max(o.noiseRadiusDeg,0);
o.noiseRadiusDeg=min(o.noiseRadiusDeg,RectWidth(screenRect)/o.pixPerDeg);
o.noiseRaisedCosineEdgeThicknessDeg=max(0,o.noiseRaisedCosineEdgeThicknessDeg);
o.noiseRaisedCosineEdgeThicknessDeg=min(o.noiseRaisedCosineEdgeThicknessDeg,2*o.noiseRadiusDeg);
o.annularNoiseSmallRadiusDeg=max(o.noiseRadiusDeg,o.annularNoiseSmallRadiusDeg); % "noise" and annularNoise cannot overlap.
o.annularNoiseBigRadiusDeg=max(o.annularNoiseBigRadiusDeg,o.annularNoiseSmallRadiusDeg); % Big radius is at least as big as small radius.
o.annularNoiseBigRadiusDeg=min(o.annularNoiseBigRadiusDeg,RectWidth(screenRect)/o.pixPerDeg);
o.annularNoiseSmallRadiusDeg=min(o.annularNoiseBigRadiusDeg,o.annularNoiseSmallRadiusDeg); % Big radius is at least as big as small radius.
o.yellowAnnulusSmallRadiusDeg=max(o.yellowAnnulusSmallRadiusDeg,0);
o.yellowAnnulusBigRadiusDeg=max(o.yellowAnnulusBigRadiusDeg,0);
o.yellowAnnulusBigRadiusDeg=min(o.yellowAnnulusBigRadiusDeg,RectWidth(screenRect)/o.pixPerDeg);
o.yellowAnnulusSmallRadiusDeg=min(o.yellowAnnulusSmallRadiusDeg,RectWidth(screenRect)/o.pixPerDeg);
o.yellowAnnulusBigRadiusDeg=max(o.yellowAnnulusBigRadiusDeg,o.yellowAnnulusSmallRadiusDeg);
if ~isfield(o,'blankingRadiusReTargetHeight')
    switch o.targetKind
        case 'letter';
            o.blankingRadiusReTargetHeight=1.5; % Make blanking radius 1.5 times
            %                                       % target height. That's a good
            %                                       % value for letters, which are
            %                                       % strong right up to the edge of
            %                                       % the target height. 
        case 'gabor';
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
maxOnscreenFixationOffsetPix=round(RectWidth(o.stimulusRect)/2-20*fixationCrossWeightPix); % max possible fixation offset, with 20 linewidth margin.
maxTargetOffsetPix=RectWidth(o.stimulusRect)/2-o.targetHeightPix/2; % max possible target offset for eccentric viewing.
if o.useFlankers
    maxTargetOffsetPix=maxTargetOffsetPix-o.flankerSpacingDeg*o.pixPerDeg;
end
maxTargetOffsetPix=floor(maxTargetOffsetPix-max(o.targetHeightPix/4,0.2*o.pixPerDeg));
assert(maxTargetOffsetPix>=0);
% The entire screen is is screenRect. The stimulus is in stimulusRect,
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
window=nan;
switch o.task
    case '4afc'
        idealT64=-.90;
    case 'identify'
        idealT64=-0.30;
end
offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
switch o.observer
    case algorithmicObservers
        if ~isfield(o,'beta') || ~isfinite(o.beta)
            o.beta=1.7;
        end
        if ~isfield(o,'trialsPerRun') || ~isfinite(o.trialsPerRun)
            o.trialsPerRun=1000;
        end
        if ~isfield(o,'runsDesired') || ~isfinite(o.runsDesired)
            o.runsDesired=10;
        end
        %         degPerCm=57/o.distanceCm;
        %         pixPerCm=45; % for MacBook at native resolution.
        %         o.pixPerDeg=pixPerCm/degPerCm;
    otherwise
        if o.measureBeta
            o.trialsPerRun=max(200,o.trialsPerRun);
        end
        if ~isfield(o,'beta') || ~isfinite(o.beta)
            switch o.targetModulates
                case 'luminance',
                    o.beta=3.5;
                case {'noise','entropy'}
                    o.beta=1.7;
            end
        end
end
if streq(o.task,'4afc')
    o.alternatives=1;
end
clear signal

if o.alternatives>length(o.alphabet)
    Speak('Too many o.alternatives');
    error('Too many o.alternatives');
end
for i=1:o.alternatives
    signal(i).letter=o.alphabet(i);
end
%onCleanupInstance=onCleanup(@()listenchar;sca); % clears screen when function terminated.

if streq(o.observer,'brightnessSeeker')
    ffprintf(ff,'observerQuadratic %.2f\n',o.observerQuadratic);
end
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',cal.screen);
cal.screenWidthCm=screenWidthMm/10;
ffprintf(ff,'Computer %s, %s, screen %d, %dx%d, %.1fx%.1f cm\n',cal.machineName,cal.macModelName,cal.screen,RectWidth(screenRect),RectHeight(screenRect),screenWidthMm/10,screenHeightMm/10);
assert(cal.screenWidthCm==screenWidthMm/10);
ffprintf(ff,'Computer account %s.\n',cal.processUserLongName);
[savedGamma,dacBits]=Screen('ReadNormalizedGammaTable',cal.screen); % Restored when program terminates.
ffprintf(ff,'%s %s calibrated by %s on %s.\n',cal.machineName,cal.macModelName,cal.calibratedBy,cal.datestr);
ffprintf(ff,'%s\n',cal.notes);
ffprintf(ff,'cal.ScreenConfigureDisplayBrightnessWorks=%.0f;\n',cal.ScreenConfigureDisplayBrightnessWorks);
BackupCluts;
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
if cal.ScreenConfigureDisplayBrightnessWorks
    AutoBrightness(cal.screen,0);
    ffprintf(ff,'Turning autobrightness off. Setting "brightness" to %.2f, on a scale of 0.0 to 1.0;\n',cal.brightnessSetting);
end
Screen('Preference','SkipSyncTests',1);
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel',0);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings',1);
if cal.ScreenConfigureDisplayBrightnessWorks
    % Psychtoolbox Bug. Screen ConfigureDisplay? claims that this will
    % silently do nothing if not supported. But when I used it on my video
    % projector, Screen gave a fatal error. That's ok, but how do I figure
    % out when it's safe to use?
    Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
end

try
    if ~o.isKbLegacy
        % we can safely use this mode AND collect kb responses without worrying
        % about writing to MATLAB console/editor
        ListenChar(2); % no echo
    end
    KbName('UnifyKeyNames');


    if ~ismember(o.observer,algorithmicObservers) || streq(o.task,'identify')

        % If o.observer is human, We need an open window for the whole
        % experiment, in which to display stimuli. If o.observer is machine,
        % we need a screen only briefly, to create the letters to be
        % identified.
        if o.useFractionOfScreen
            ffprintf(ff,'Using tiny window for debugging.\n');
        end
        if o.flipClick; Speak(['before OpenWindow ' num2str(MFileLineNr)]);GetClicks; end
        if 1
            PsychImaging('PrepareConfiguration');
            if o.flipScreenHorizontally
                PsychImaging('AddTask','AllViews','FlipHorizontal');
            end
            if cal.hiDPIMultiple~=1
                PsychImaging('AddTask','General','UseRetinaResolution');
            end
            if o.EnableCLUTMapping
                % Mario says this is the ONLY way to get reasonable color
                % mapping behavior.
                PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize, high res
            end
            if ~o.useFractionOfScreen
                [window,r]=PsychImaging('OpenWindow',cal.screen,255);
            else
                [window,r]=PsychImaging('OpenWindow',cal.screen,255,round(o.useFractionOfScreen*screenBufferRect));
            end
            %[windowPtr,rect]=Screen('OpenWindow',windowPtrOrScreenNumber [,color] [,rect][,pixelSize][,numberOfBuffers][,stereomode][,multisample][,imagingmode][,specialFlags][,clientRect]);
        else
            [window,r]=Screen('OpenWindow',cal.screen,255,screenRect);
        end
        if o.EnableCLUTMapping
            gamma=Screen('ReadNormalizedGammaTable',window);
            gamma=interp1(gamma,1:(size(gamma,1)-1)/255:size(gamma,1),'pchip'); % Down sample to 256.
            % PsychImaging EnableCLUTMapping does not initialize the color
            % table, so we do it here.
            Screen('LoadNormalizedGammaTable',window,gamma,2);
            Screen('Flip',window);
        end
        assert(all(r==screenRect));
        
        if o.flipClick; Speak(['after OpenWindow ' num2str(MFileLineNr)]);GetClicks; end
        if exist('cal')
            gray=mean([firstGrayClutEntry lastGrayClutEntry]);  % Will be a CLUT color code for gray.
            LMin=min(cal.old.L);
            LMax=max(cal.old.L);
            LMean=mean([LMin,LMax]); % Desired background luminance.
            if o.assessLowLuminance
                LMean=0.8*LMin+0.2*LMax;
            end
            cal.LFirst=LMin;
            cal.LLast=LMean+(LMean-LMin); % Symmetric about LMean.
            cal.nFirst=firstGrayClutEntry;
            cal.nLast=lastGrayClutEntry;
            cal=LinearizeClut(cal);
            if o.isWin
                % Windows insists on a monotonic CLUT. So we linearize
                % practically the whole CLUT, and use the middle entry for
                % gray. We spare entries 0 and 255, which are used by the
                % OS for black and white. Thus any screens using only those
                % colors won't be affected by our clut changes. We don't
                % explicitly use clut entry 1. Both firstGrayClutEntry and
                % lastGrayClutEntry are even, so the range
                % firstGrayClutEntry to lastGrayClutEntry is odd in length,
                % so it will have a middle entry, which we use for a stable
                % gray, across trials.
                gray1=gray;
                % We don't use entry 1, but Windows insists on a monotonic
                % clut. Set entry 1 to be average of entries 0 and 2.
                cal.gamma(2,:)=(cal.gamma(1,:)+cal.gamma(3,:))/2;
                assert(all(all(diff(cal.gamma)>=0))); % monotonic for Windows
            else
                % Otherwise we have two grays, one (gray) in the middle of
                % the CLUT and one at entry 1 (gray1). The benefit of
                % having gray1==1 is that we get better blending of letters
                % written (as black=0) on that background.
                gray1=1;
                if IsOSX
                    cal.LFirst=LMean*1.17; % Correct for OSX 10.11.1 bug
                    cal.LLast=LMean*1.17; % Correct for OSX 10.11.1 bug
                else
                    cal.LFirst=LMean;
                    cal.LLast=LMean;
                end
                cal.nFirst=firstGrayClutEntry-1; % Ought to be 1, but need 9 in Mac OSX 10.11.1
                cal.nLast=firstGrayClutEntry-1; % Ought to be 1, but need 9 in Mac OSX 10.11.1
                cal=LinearizeClut(cal);
            end %if o.isWin
            if o.printGammaLoadings; fprintf('LoadNormalizedGammaTable %d; LRange/Lmean=%.2f\n',MFileLineNr,(cal.LLast-LMean)/LMean); end
            Screen('LoadNormalizedGammaTable',window,cal.gamma,1); % load during flip
            Screen('FillRect',window,gray1);
            Screen('FillRect',window,gray,o.stimulusRect);
        else
            Screen('FillRect',window);
        end % if cal
        if o.flipClick; Speak(['before Flip ' num2str(MFileLineNr)]);GetClicks; end
        Screen('Flip',window);
        if o.flipClick; Speak(['after Flip ' num2str(MFileLineNr)]);GetClicks; end
        if ~isfinite(window) || window==0
            fprintf('error\n');
            error('Screen OpenWindow failed. Please try again.');
        end
        black = BlackIndex(window);  % Retrieves the CLUT color code for black.
        white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
        gray=mean([firstGrayClutEntry lastGrayClutEntry]);  % Will be a CLUT color code for gray.
        Screen('FillRect',window,gray1);
        Screen('FillRect',window,gray,o.stimulusRect);
        if o.flipClick; Speak(['before Flip ' num2str(MFileLineNr)]);GetClicks; end
        Screen('Flip',window); % Screen is now all gray, at LMean.
        if o.flipClick; Speak(['after Flip ' num2str(MFileLineNr)]);GetClicks; end
    else
        window=-1;
    end
    if window >= 0
        screenRect=Screen('Rect',window,1);
        screenWidthPix=RectWidth(screenRect);
    else
        screenWidthPix=1280;
    end
    pixPerCm=screenWidthPix/cal.screenWidthCm;
    degPerCm=57/o.distanceCm;
    o.pixPerDeg=pixPerCm/degPerCm;
    eccentricityPix=round(pixPerCm*o.distanceCm*tand(o.eccentricityDeg));
    if ~isfinite(o.eccentricityDeg)
        fixationOffscreenCm=0;
        fixationIsOffscreen=0;
        fixationOffsetPix=inf;
        targetOffsetPix=0;
    else
        if abs(eccentricityPix) > maxOnscreenFixationOffsetPix+maxTargetOffsetPix
            fixationOffscreenCm=round((abs(eccentricityPix)-RectWidth(o.stimulusRect)/2)/pixPerCm);
            fixationOffscreenCm=-sign(eccentricityPix)*max(fixationOffscreenCm,4); % ?4 cm, to avoid collision with the display.
            if fixationOffscreenCm<0
                question1=sprintf('Please set up a fixation mark %.0f cm to the left of the edge of this bright patch. ',-fixationOffscreenCm);
            else
                question1=sprintf('Please set up a fixation mark %.0f cm to the right of the edge of this bright patch. ',fixationOffscreenCm);
            end
            question2='Then hit <return>.  ';
            question3='Or hit <escape>, to keep fixation on the screen at reduced eccentricity.';
            Screen('TextSize',window,textSize);
            Screen('TextFont',window,'Verdana');
            Screen('FillRect',window,black);
            Screen('FillRect',window,white,o.stimulusRect);
            Screen('DrawText',window,question1,10,RectHeight(screenRect)/2-48,black,white,1);
            Screen('DrawText',window,question2,10,RectHeight(screenRect)/2,black,white,1);
            Screen('DrawText',window,question3,10,RectHeight(screenRect)/2+48,black,white,1);
            if o.flipClick; Speak(['before Flip ' num2str(MFileLineNr)]);GetClicks; end
            Screen('Flip',window);
            if o.flipClick; Speak(['after Flip ' num2str(MFileLineNr)]);GetClicks; end
            question=[question1 question2 question3];
            if o.speakInstructions
                Speak(question);
            end
            if o.isKbLegacy
              answer=questdlg(question,'Fixation','Ok','Cancel','Ok');
            else
              ListenChar(0); % get ready for the quesdlg
              answer=questdlg(question,'Fixation','Ok','Cancel','Ok');
              ListenChar(2); % go back to orig status; no echo
            end

            switch answer
              case 'Ok',
                    fixationIsOffscreen=1;
                    if fixationOffscreenCm<0
                        ffprintf(ff,'Offscreen fixation mark is %.0f cm left of the left edge of the stimulusRect.\n',-fixationOffscreenCm);
                    else
                        ffprintf(ff,'Offscreen fixation mark is %.0f cm right of the right edge of the stimulusRect.\n',fixationOffscreenCm);
                    end
                    fixationOffsetPix=sign(fixationOffscreenCm)*(abs(fixationOffscreenCm)*pixPerCm+RectWidth(o.stimulusRect)/2);
                otherwise,
                    fixationIsOffscreen=0;
                    fixationOffscreenCm=0;
                    oldEcc=o.eccentricityDeg;
                    fixationOffsetPix=-sign(eccentricityPix)*maxOnscreenFixationOffsetPix;
                    targetOffsetPix=sign(eccentricityPix)*maxTargetOffsetPix;
                    eccentricityPix=targetOffsetPix-fixationOffsetPix;
                    o.eccentricityDeg=atand(eccentricityPix/pixPerCm/o.distanceCm);
                    ffprintf(ff,'WARNING: User refused offscreen fixation. Requested eccentricity %.1f deg reduced to %.1f deg, to allow on-screen fixation.\n',oldEcc,o.eccentricityDeg);
                    warning('WARNING: User refused offscreen fixation. Requested eccentricity %.1f deg reduced to %.1f deg, to allow on-screen fixation.\n',oldEcc,o.eccentricityDeg);
            end
        else
            fixationOffscreenCm=0;
            fixationIsOffscreen=0;
            fixationOffsetPix=-sign(eccentricityPix)*min(abs(eccentricityPix),maxOnscreenFixationOffsetPix);
        end
        targetOffsetPix=eccentricityPix+fixationOffsetPix;
        assert(abs(targetOffsetPix)<=maxTargetOffsetPix);
    end

    if o.fixationCrossBlankedNearTarget
        ffprintf(ff,'Fixation cross is blanked near target. No delay in showing fixation after target.\n');
    else
        ffprintf(ff,'Fixation cross is blanked during and until %.2f s after target. No selective blanking near target. \n',o.fixationCrossBlankedUntilSecsAfterTarget);
    end
    gap=o.gapFraction4afc*o.targetHeightPix;
    o.targetWidthPix=o.targetHeightPix;
    o.targetHeightPix=o.noiseCheckPix*round(o.targetHeightPix/o.noiseCheckPix);
    o.targetWidthPix=o.noiseCheckPix*round(o.targetWidthPix/o.noiseCheckPix);
    if window~=-1
        frameRate=1/Screen('GetFlipInterval',window);
    else
        frameRate=60;
    end
    ffprintf(ff,'Frame rate %.1f Hz.\n',frameRate);
    ffprintf(ff,'o.pixPerDeg %.1f, o.distanceCm %.1f\n',o.pixPerDeg,o.distanceCm);
    if streq(o.task,'identify')
        ffprintf(ff,'Minimum letter resolution is %.0f checks.\n',o.minimumTargetHeightChecks);
    end
    %     ffprintf(ff,'%s font\n',targetFont);
    ffprintf(ff,'o.targetHeightPix %.0f, o.noiseCheckPix %.0f, o.durationSec %.2f s\n',o.targetHeightPix,o.noiseCheckPix,o.durationSec);
    ffprintf(ff,'o.targetModulates %s\n',o.targetModulates);
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
    o.noiseSize=2*o.noiseRadiusDeg*[1,1]*o.pixPerDeg/o.noiseCheckPix;
    switch o.task
        case 'identify',
        o.noiseSize=2*round(o.noiseSize/2); % Even numbers, so we can center it on letter.
        case '4afc',
        o.noiseSize=round(o.noiseSize);
    end
    o.noiseRadiusDeg=0.5*o.noiseSize(1)*o.noiseCheckPix/o.pixPerDeg;
    noiseBorder=ceil(0.5*o.noiseRaisedCosineEdgeThicknessDeg*o.pixPerDeg/o.noiseCheckPix);
    o.noiseSize=o.noiseSize+2*noiseBorder;
    o.annularNoiseSmallSize=2*o.annularNoiseSmallRadiusDeg*[1,1]*o.pixPerDeg/o.noiseCheckPix;
    o.annularNoiseSmallSize(2)=min(o.annularNoiseSmallSize(2),RectHeight(o.stimulusRect)/o.noiseCheckPix);
    o.annularNoiseSmallSize=2*round(o.annularNoiseSmallSize/2); % An even number, so we can center it on center of letter.
    o.annularNoiseSmallRadiusDeg = 0.5*o.annularNoiseSmallSize(1)/(o.pixPerDeg/o.noiseCheckPix);
    o.annularNoiseBigSize=2*o.annularNoiseBigRadiusDeg*[1,1]*o.pixPerDeg/o.noiseCheckPix;
    o.annularNoiseBigSize(2)=min(o.annularNoiseBigSize(2),RectHeight(o.stimulusRect)/o.noiseCheckPix);
    o.annularNoiseBigSize=2*round(o.annularNoiseBigSize/2); % An even number, so we can center it on center of letter.
    o.annularNoiseBigRadiusDeg = 0.5*o.annularNoiseBigSize(1)/(o.pixPerDeg/o.noiseCheckPix);
    o.yellowAnnulusSmallSize=2*o.yellowAnnulusSmallRadiusDeg*[1,1]*o.pixPerDeg/o.noiseCheckPix;
    o.yellowAnnulusSmallSize(2)=min(o.yellowAnnulusSmallSize(2),RectHeight(o.stimulusRect)/o.noiseCheckPix);
    o.yellowAnnulusSmallSize=2*round(o.yellowAnnulusSmallSize/2); % An even number, so we can center it on center of letter.
    o.yellowAnnulusSmallRadiusDeg= 0.5*o.yellowAnnulusSmallSize(1)/(o.pixPerDeg/o.noiseCheckPix);
    o.yellowAnnulusBigSize=2*o.yellowAnnulusBigRadiusDeg*[1,1]*o.pixPerDeg/o.noiseCheckPix;
    o.yellowAnnulusBigSize(2)=min(o.yellowAnnulusBigSize(2),RectHeight(o.stimulusRect)/o.noiseCheckPix);
    o.yellowAnnulusBigSize=2*round(o.yellowAnnulusBigSize/2); % An even number, so we can center it on center of letter.
    o.yellowAnnulusBigRadiusDeg= 0.5*o.yellowAnnulusBigSize(1)/(o.pixPerDeg/o.noiseCheckPix);

    % Make o.canvasSize to hold the biggest thing we're showing, signal or
    % noise. We limit o.canvasSize to fit in o.stimulusRect.
    o.canvasSize=[o.targetHeightPix o.targetWidthPix]/o.noiseCheckPix;
    o.canvasSize=max(o.canvasSize,o.noiseSize);
    if o.annularNoiseBigRadiusDeg>o.annularNoiseSmallRadiusDeg
        o.canvasSize=max(o.canvasSize,2*o.annularNoiseBigRadiusDeg*[1,1]*o.pixPerDeg/o.noiseCheckPix);
    end
    if o.yellowAnnulusBigRadiusDeg>o.yellowAnnulusSmallRadiusDeg
        o.canvasSize=max(o.canvasSize,[1,1]*2*o.yellowAnnulusBigRadiusDeg*o.pixPerDeg/o.noiseCheckPix);
    end
    switch o.task,
        case 'identify',
            o.canvasSize=min(o.canvasSize,floor(RectHeight(o.stimulusRect)/o.noiseCheckPix));
            o.canvasSize=2*round(o.canvasSize/2); % Even number of checks, so we can center it on letter.
        case '4afc',
            o.canvasSize=min(o.canvasSize,floor(maxTargetHeight/o.noiseCheckPix));
            o.canvasSize=round(o.canvasSize);
    end
    ffprintf(ff,'Noise height %.2f deg. Noise hole %.2f deg. Height is %.2fT and hole is %.2fT, where T is target height.\n',...
        o.annularNoiseBigRadiusDeg*o.targetHeightDeg,o.annularNoiseSmallRadiusDeg*o.targetHeightDeg,o.annularNoiseBigRadiusDeg,o.annularNoiseSmallRadiusDeg);
    if o.assessLowLuminance
        ffprintf(ff,'o.assessLowLuminance %d %% check out DAC limits at low end.\n',o.assessLowLuminance);
    end
    if o.useFlankers
        ffprintf(ff,'Adding four flankers at center spacing of %.0f pix = %.1f deg = %.1fx letter height. Dark contrast %.3f (nan means same as target).\n',flankerSpacingPix,flankerSpacingPix/o.pixPerDeg,flankerSpacingPix/o.targetHeightPix,o.flankerContrast);
    end
    [x,y]=RectCenter(o.stimulusRect);
%     if isfinite(o.eccentricityDeg)
fix.blankingRadiusReTargetHeight=o.blankingRadiusReTargetHeight;
fix.targetCross=o.targetCross;
fix.x=x+targetOffsetPix-eccentricityPix; % x location of fixation
fix.y=y; % y location of fixation
fix.eccentricityPix=eccentricityPix;
fix.clipRect=o.stimulusRect;
fix.fixationCrossPix=fixationCrossPix;
fix.fixationCrossBlankedNearTarget=o.fixationCrossBlankedNearTarget;
fix.targetHeightPix=o.targetHeightPix;
fixationLines=ComputeFixationLines(fix);
%     end
    if window~=-1 && ~isempty(fixationLines)
        Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,black); % fixation
    end
    clear tSample
    switch o.noiseType
        case 'gaussian',
            o.noiseListBound=2;
            temp=randn([1,20000]);
            noiseList=find(sign(temp.^2-o.noiseListBound^2)-1);
            noiseList=temp(noiseList);
            clear temp;
        case 'uniform',
            o.noiseListBound=1;
            noiseList=-1:1/1024:1;
        case 'binary',
            o.noiseListBound=1;
            noiseList=[-1 1];
        otherwise,
            error('Unknown noiseType "%s"',o.noiseType);
    end

    % Compute mtf to filter the noise
    fNyquist=0.5/o.noiseCheckDeg;
    fLow = 0;
    fHigh = fNyquist;
    switch o.noiseSpectrum
        case 'pink'
            o.noiseSpectrumExponent=-1;
            if all(o.noiseSize>0)
                mtf=MtfPowerLaw(o.noiseSize,o.noiseSpectrumExponent,fLow/fNyquist,fHigh/fNyquist);
            else
                mtf=[];
            end
            o.noiseIsFiltered=1;
        case 'white'
            mtf=ones(o.noiseSize);
            o.noiseIsFiltered=0;
    end
    if o.noiseSD==0
        mtf=0;
    end

    o.noiseListSd=std(noiseList);
    a=0.9*o.noiseListSd/o.noiseListBound;
    if o.noiseSD>a
        ffprintf(ff,'WARNING: Requested o.noiseSD %.2f too high. Reduced to %.2f\n',o.noiseSD,a);
        o.noiseSD=a;
    end
    if isfinite(o.annularNoiseSD) && o.annularNoiseSD>a
        ffprintf(ff,'WARNING: Requested o.annularNoiseSD %.2f too high. Reduced to %.2f\n',o.annularNoiseSD,a);
        o.annularNoiseSD=a;
    end
    %ffprintf(ff,'OBSOLETE: noiseContrast %.2f\n',o.noiseSD/o.noiseListSd);
    rightBeep = MakeBeep(2000,0.05);
    rightBeep(end)=0;
    wrongBeep = MakeBeep(500,0.5);
    wrongBeep(end)=0;
    temp=zeros(size(wrongBeep));
    temp(1:length(rightBeep))=rightBeep;
    rightBeep=temp; % extend rightBeep with silence to same length as wrongBeep
    purr = MakeBeep(200,0.6);
    purr(end)=0;
    Snd('Open');
    switch o.task
        case '4afc'
            object='Square';
        case 'identify'
            object='Letter';
        otherwise
            error('Unknown task %d',o.task);
    end
    checks=(o.targetHeightPix/o.noiseCheckPix);
    ffprintf(ff,'Target height is %.1f checks, %.1f deg.\n',checks,o.targetHeightDeg);
    ffprintf(ff,'%s size %.2f deg, central check size %.3f deg.\n',object,2*atand(0.5*o.targetHeightPix/o.pixPerDeg*pi/180),2*atand(0.5*o.noiseCheckPix/o.pixPerDeg*pi/180));
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
    if isfinite(o.eccentricityDeg)
        ffprintf(ff,'Eccentricity %.1f deg. Using fixation mark. Target offset %.2f of screen width.\n',o.eccentricityDeg,targetOffsetPix/RectWidth(screenRect));
    else
        ffprintf(ff,'Eccentricity %.1f deg. No fixation mark.\n',0);
    end
    N=o.noiseCheckPix^2*o.pixPerDeg^-2*o.noiseSD^2;
    o.N = N;
    ffprintf(ff,'log N/deg^2 %.2f, where N is power spectral density\n',log10(N));
    ffprintf(ff,'pThreshold %.2f, beta %.1f\n',o.pThreshold,o.beta);
    ffprintf(ff,'Your (log) guess is %.2f ± %.2f\n',o.tGuess,o.tGuessSd);
    ffprintf(ff,'o.trialsPerRun %.0f\n',o.trialsPerRun);
    white1=1;
    black0=0;
    switch o.task % compute masks and envelopes
        case '4afc'
            % boundsRect contans all 4 positions.
            boundsRect=[-o.targetWidthPix,-o.targetHeightPix,o.targetWidthPix+gap,o.targetHeightPix+gap];
            boundsRect=CenterRect(boundsRect,o.stimulusRect);
            boundsRect=OffsetRect(boundsRect,targetOffsetPix,0);
            targetRect=round([0 0 o.targetHeightPix o.targetHeightPix]/o.noiseCheckPix);
            signal(1).image=ones(targetRect(3:4));
        case 'identify',
            switch o.targetKind
                case 'letter',
                    [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',-1 ,[],[0 0 400 400],8);
                    oldFont=Screen('TextFont',scratchWindow,'Sloan');
                    font=Screen('TextFont',scratchWindow);
                    assert(streq(font,'Sloan'));
                    oldSize=Screen('TextSize',scratchWindow,round(o.targetHeightPix/o.noiseCheckPix));
                    oldStyle=Screen('TextStyle',scratchWindow,0);
                    canvasRect=[0 0 o.canvasSize];
                    for i=1:o.alternatives
                        Screen('FillRect',scratchWindow,white1);
                        rect=CenterRect(canvasRect,scratchRect);
                        targetRect=round([0 0 o.targetHeightPix o.targetHeightPix]/o.noiseCheckPix);
                        targetRect=CenterRect(targetRect,rect);
                        Screen('DrawText',scratchWindow,signal(i).letter,targetRect(1),targetRect(4),black0,white1,1);
                        letter=Screen('GetImage',scratchWindow,targetRect,'drawBuffer');
                        Screen('FillRect',scratchWindow);
                        letter=letter(:,:,1);
                        signal(i).image=letter<(white1+black0)/2;
                    end
                    %             Screen('TextFont',scratchWindow,oldFont);
                    %             Screen('TextSize',scratchWindow,oldSize);
                    %             Screen('TextStyle',scratchWindow,oldStyle);
                    Screen('Close',scratchWindow);
                    scratchWindow=-1;
                case 'gabor',
                    % o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
                    % o.targetGaborSpaceConstantCycles=1.5; % The 1/e space constant of the gaussian envelope in periods of the sinewave.
                    % o.targetGaborCycles=3; % cycles of the sinewave.
                    % o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
                    % o.targetGaborNames='VH';
                    targetRect=round([0 0 o.targetHeightPix o.targetHeightPix]/o.noiseCheckPix);
                    widthChecks = RectWidth(targetRect)-1;
                    axisValues = -widthChecks/2 : widthChecks/2;  % axisValues is used in creating the meshgrid.
                    [x,y] = meshgrid(axisValues,axisValues);
                    spaceConstantChecks=o.targetGaborSpaceConstantCycles*(o.targetHeightPix/o.noiseCheckPix)/o.targetGaborCycles;
                    cyclesPerCheck=o.targetGaborCycles/(o.targetHeightPix/o.noiseCheckPix);
                    for i=1:o.alternatives
                        a=cos(o.targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck; 
                        b=sin(o.targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                        signal(i).image=sin(a*x+b*y+o.targetGaborPhaseDeg*pi/180).*exp(-(x.^2 + y.^2)/spaceConstantChecks^2);
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
            targetRect=[0,0,o.targetWidthPix,o.targetHeightPix];
            targetRect=CenterRect(targetRect,o.stimulusRect);
            boundsRect=OffsetRect(targetRect,targetOffsetPix,0);
            % targetRect not used. boundsRect used solely for the snapshot.
    end % switch o.task

    % Compute annular noise mask
    annularNoiseMask=zeros(o.canvasSize); % initialize with 0
    rect=RectOfMatrix(annularNoiseMask);
    r=[0 0 o.annularNoiseBigSize(1) o.annularNoiseBigSize(2)];
    r=round(CenterRect(r,rect));
    annularNoiseMask=FillRectInMatrix(1,r,annularNoiseMask); % fill big radius with 1
    r=[0 0 o.annularNoiseSmallSize(1) o.annularNoiseSmallSize(2)];
    r=round(CenterRect(r,rect));
    annularNoiseMask=FillRectInMatrix(0,r,annularNoiseMask); % fill small radius with 0
    annularNoiseMask=logical(annularNoiseMask);

    % Compute central noise mask
    centralNoiseMask=zeros(o.canvasSize); % initialize with 0
    rect=RectOfMatrix(centralNoiseMask);
    r=CenterRect([0 0 o.noiseSize],rect);
    r=round(r);
    centralNoiseMask=FillRectInMatrix(1,r,centralNoiseMask); % fill radius with 1
    centralNoiseMask=logical(centralNoiseMask);

    if isfinite(o.noiseEnvelopeSpaceConstantDeg) && o.noiseRaisedCosineEdgeThicknessDeg>0
        error('Sorry. Please set o.noiseEnvelopeSpaceConstantDeg=inf or set o.noiseRaisedCosineEdgeThicknessDeg=0.');
    end

    if isfinite(o.noiseEnvelopeSpaceConstantDeg)
        % Compute Gaussian central noise envelope
        [x,y]=meshgrid(1:o.canvasSize(1),1:o.canvasSize(2));
        x=x-mean(x(:));
        y=y-mean(y(:));
        radius=sqrt(x.^2+y.^2);
        sigma=o.noiseEnvelopeSpaceConstantDeg*o.pixPerDeg/o.noiseCheckPix;
        if ~isfield(o,'annularNoiseEnvelopeRadiusDeg')
            o.annularNoiseEnvelopeRadiusDeg=0;
        end
        assert(isfinite(o.annularNoiseEnvelopeRadiusDeg));
        assert(o.annularNoiseEnvelopeRadiusDeg>=0);
        if o.annularNoiseEnvelopeRadiusDeg>0
            noiseEnvelopeRadiusPix=o.annularNoiseEnvelopeRadiusDeg*o.pixPerDeg/o.noiseCheckPix;
            distance=radius-noiseEnvelopeRadiusPix;
        else
            distance=radius;
        end
        centralNoiseEnvelope=exp(-(distance.^2)/sigma^2);
    elseif o.noiseRaisedCosineEdgeThicknessDeg>0
        % Compute central noise envelope with raised-cosine border
        [x,y]=meshgrid(1:o.canvasSize(1),1:o.canvasSize(2));
        x=x-mean(x(:));
        y=y-mean(y(:));
        thickness=o.noiseRaisedCosineEdgeThicknessDeg*o.pixPerDeg/o.noiseCheckPix;
        radius=o.noiseRadiusDeg*o.pixPerDeg/o.noiseCheckPix;
        a=90+180*(sqrt(x.^2+y.^2)-radius)/thickness;
        a=min(180,a);
        a=max(0,a);
        centralNoiseEnvelope=0.5+0.5*cosd(a);
    else
        centralNoiseEnvelope=ones(o.canvasSize);
    end
    o.centralNoiseEnvelopeE1degdeg=sum(centralNoiseEnvelope(:).^2*o.noiseCheckPix/o.pixPerDeg^2);
    if o.yellowAnnulusBigRadiusDeg>o.yellowAnnulusSmallRadiusDeg
        % Compute yellow mask, with small and large radii.
        yellowMask=zeros(o.canvasSize);
        r=[0 0 o.yellowAnnulusBigSize];
        r=round(CenterRect(r,rect));
        yellowMask=FillRectInMatrix(1,r,yellowMask);
        r=[0 0 o.yellowAnnulusSmallSize];
        r=round(CenterRect(r,rect));
        yellowMask=FillRectInMatrix(0,r,yellowMask);
        yellowMask=logical(yellowMask);
    end

    
    % o.E1 is energy at unit contrast.
    power=1:length(signal);
    for i=1:length(power)
        power(i)=sum(signal(i).image(:).^2);
        if streq(o.targetKind,'letter')
            ok=ismember(unique(signal(i).image(:)),[0 1]);
            assert(all(ok));
        end
    end
    o.E1=mean(power)*(o.noiseCheckPix/o.pixPerDeg)^2;
    ffprintf(ff,'log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',log10(o.E1));

    if ismember(o.observer,algorithmicObservers);
        Screen('CloseAll');
        window=-1;
        LMin=0;
        LMax=200;
        LMean=100;
    end
    % We are now done with Sloan, since we've saved our signals as images.
    if window~=-1
        Screen('TextFont',window,textFont);
        Screen('TextSize',window,textSize);
        Screen('TextStyle',window,textStyle);
        if ~o.useFractionOfScreen
            HideCursor;
        end
    end
    frameRect=InsetRect(boundsRect,-1,-1);
    if o.saveSnapshot
        gray1=gray;
    end
    if ~ismember(o.observer,algorithmicObservers) && ~o.testBitDepth %&& ~o.saveSnapshot;
        Screen('FillRect',window,gray1);
        Screen('FillRect',window,gray,o.stimulusRect);
        if o.showCropMarks
            TrimMarks(window,frameRect);
        end
        Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
        if o.flipClick; Speak(['before LoadNormalizedGammaTable delayed ' num2str(MFileLineNr)]);GetClicks; end
        if o.isWin; assert(all(all(diff(cal.gamma)>=0))); end; % monotonic for Windows
        if o.printGammaLoadings; fprintf('LoadNormalizedGammaTable %d; LRange/LMean=%.2f\n',930,2*(cal.LLast-LMean)/LMean); end
        Screen('LoadNormalizedGammaTable',window,cal.gamma,1); % Wait for Flip.
        if assessGray; pp=Screen('GetImage',window,[20 20 21 21]);ffprintf(ff,'line 712: Gray index is %d (%.1f cd/m^2). Corner is %d.\n',gray,LuminanceOfIndex(cal,gray),pp(1)); end
        if o.flipClick; Speak(['before Flip ' num2str(MFileLineNr)]);GetClicks; end
        Screen('Flip', window,0,1); % Show gray screen at LMean with fixation and crop marks. Don't clear buffer.
        if o.flipClick; Speak(['after Flip ' num2str(MFileLineNr)]);GetClicks; end

        Screen('DrawText',window,'Starting new run. ',0.5*textSize,o.lineSpacing*textSize,black0,gray1,1);
        if isfinite(o.eccentricityDeg)
            if fixationIsOffscreen
                speech{1}='Please fihx your eyes on your offscreen fixation mark,';
                msg='Please fix your eyes on your offscreen fixation mark, ';
            else
                if ismac
                    speech{1}='Please fihx your eyes on the center of the cross,';
                else
                    speech{1}='Please fix your eyes on the center of the cross,';
                end
                msg='Please fix your eyes on the center of the cross, ';
            end
            word='and';
        else
            word='Please';
        end
        Screen('DrawText',window,msg,0.5*textSize,2*o.lineSpacing*textSize,black0,gray1,1);
        switch o.task
            case '4afc',
                speech{2}=[word ' click when ready to begin'];
                Screen('DrawText',window,[word ' click when ready to begin.'],0.5*textSize,3*o.lineSpacing*textSize,black0,gray1,1);
                fprintf('Please click when ready to begin.\n');
            case 'identify',
                if ismac
                    speech{2}=[word ' press  the  spasebar  when ready to begin'];
                else
                    speech{2}=[word ' press  the  space bar  when ready to begin'];
                end
                Screen('DrawText',window,[word ' press the space bar when ready to begin.'],0.5*textSize,3*o.lineSpacing*textSize,black0,gray1,1);
                fprintf('Please press the space bar when ready to begin.\n');
        end
        Screen('Flip',window);
        if o.speakInstructions
            Speak('Starting new run. ');
            Speak(speech{1});
            Speak(speech{2});
        end
        switch o.task
            case '4afc',
                GetClicks;
            case 'identify',
                if o.isKbLegacy
                    if ~o.isWin
                        % Strangely this line fails on Hormet's Think Pad, even
                        % though the same call works in most other contexts on
                        % his Think Pad.
                        FlushEvents; % flush. May not be needed.
                    end
                    ListenChar(0); % flush. May not be needed.
                    ListenChar(2); % no echo. Needed.
                    GetChar;
                    ListenChar; % normal. Needed.
                else
                    KbWait;
                end
        end
    end

    delta=0.02;
    switch o.task
        case '4afc',
            gamma=1/4;
        case 'identify',
            gamma=1/o.alternatives;
    end

    % Default values for tGuess and tGuessSd
    if streq(o.targetModulates,'luminance')
        tGuess=-0.5;
        tGuessSd=2;
    else
        tGuess=0;
        tGuessSd=4;
    end
    switch o.thresholdParameter
        case 'spacing',
            nominalCriticalSpacingDeg=0.3*(o.eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
            tGuess=log10(2*nominalCriticalSpacingDeg);
        case 'size',
            nominalAcuityDeg=0.029*(o.eccentricityDeg+2.72); % Eq. 13 from Song, Levi, and Pelli (2014).
            tGuess=log10(2*nominalAcuityDeg);
        case 'contrast',
        otherwise
            error('Unknown o.thresholdParameter "%s".',o.thresholdParameter);
    end
    if isfinite(o.tGuess)
        tGuess=o.tGuess;
    end
    if isfinite(o.tGuessSd)
        tGuessSd=o.tGuessSd;
    end

    o.data=[];
    q=QuestCreate(tGuess,tGuessSd,o.pThreshold,o.beta,delta,gamma);
    q.normalizePdf=1; % adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    wrongRight={'wrong','right'};
    timeZero=GetSecs;
    trialsRight=0;
    rWarningCount=0;
    runStart=GetSecs;
    for trial=1:o.trialsPerRun
        tTest=QuestQuantile(q);
        if o.measureBeta
            offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
            tTest=tTest+offsetToMeasureBeta(1);
        end
        if ~isfinite(tTest)
            ffprintf(ff,'WARNING: trial %d: tTest %f not finite. Setting to QuestMean.\n',trial,tTest);
            tTest=QuestMean(q);
        end
        if o.saveSnapshot
            tTest=o.tSnapshot;
        end
        switch o.thresholdParameter
            case 'spacing',
                spacingDeg=10^tTest;
                flankerSpacingPix=spacingDeg*o.pixPerDeg;
                flankerSpacingPix=max(flankerSpacingPix,1.2*o.targetHeightPix);
                fprintf('flankerSpacingPix %d\n',flankerSpacingPix);
            case 'size',
                targetSizeDeg=10^tTest;
                o.targetHeightPix=targetSizeDeg*o.pixPerDeg;
                o.targetWidthPix=o.targetHeightPix;
            case 'contrast',
                if streq(o.targetModulates,'luminance')
                    r=1;
                    o.contrast=-10^tTest; % negative contrast, dark letters
                    if o.saveSnapshot && isfinite(o.snapshotLetterContrast)
                        o.contrast=-o.snapshotLetterContrast;
                    end
                else
                    r=1+10^tTest;
                    o.contrast=0;
                end
        end
        a=(1-LMin/LMean)*o.noiseListSd/o.noiseListBound;
        if o.noiseSD>a
            ffprintf(ff,'WARNING: Reducing o.noiseSD of %s noise to %.2f to avoid overflow.\n',o.noiseType,a);
            o.noiseSD=a;
        end
        if isfinite(o.annularNoiseSD) && o.annularNoiseSD>a
            ffprintf(ff,'WARNING: Reducing o.annularNoiseSD of %s noise to %.2f to avoid overflow.\n',o.noiseType,a);
            o.annularNoiseSD=a;
        end
        switch o.targetModulates
            case 'noise',
                a=(1-LMin/LMean)/(o.noiseListBound*o.noiseSD/o.noiseListSd);
                if r>a
                    r=a;
                    if ~exist('rWarningCount','var') || rWarningCount==0
                        ffprintf(ff,'WARNING: Limiting r ratio of %s noises to upper bound %.2f to stay within luminance range.\n',o.noiseType,r);
                    end
                    rWarningCount=rWarningCount+1;
                end
                tTest=log10(r-1);
            case 'luminance',
                a=(min(cal.old.L)-LMean)/LMean;
                a=a+o.noiseListBound*o.noiseSD/o.noiseListSd;
                assert(a<0,'Need range for signal.');
                if o.contrast<a
                    o.contrast=a;
                end
                tTest=log10(-o.contrast);
            case 'entropy',
                a=128/o.backgroundEntropyLevels;
                if r>a
                    r=a;
                    if ~exist('rWarningCount','var') || rWarningCount==0
                        ffprintf(ff,'WARNING: Limiting entropy of %s noise to upper bound %.1f bits.\n',o.noiseType,log2(r*o.backgroundEntropyLevels));
                    end
                    rWarningCount=rWarningCount+1;
                end
                signalEntropyLevels=round(r*o.backgroundEntropyLevels);
                r=signalEntropyLevels/o.backgroundEntropyLevels; % define r as ratio of number of levels
                tTest=log10(r-1);
            otherwise
                error('Unknown o.targetModulates "%s"',o.targetModulates);
        end
        if o.noiseFrozenInRun
            if trial==1
                if o.noiseFrozenInRunSeed
                    assert(o.noiseFrozenInRunSeed>0 && isinteger(o.noiseFrozenInRunSeed))
                    o.noiseListSeed=o.noiseFrozenInRunSeed;
                else
                    rng('shuffle'); % use time to seed the generator
                    generator=rng;
                    o.noiseListSeed=generator.Seed;
                end
            end
            rng(o.noiseListSeed);
        end
        switch o.task
            case '4afc'
                canvasRect=[0 0 o.canvasSize(2) o.canvasSize(1)];
                sRect=RectOfMatrix(signal(1).image);
                sRect=round(CenterRect(sRect,canvasRect));
                assert(IsRectInRect(sRect,canvasRect));
                signalImageIndex=logical(FillRectInMatrix(true,sRect,zeros(o.canvasSize)));
                locations=4;
                rng('shuffle');
                signalLocation=randi(locations);
                for i=1:locations
                    if o.noiseFrozenInTrial
                        if i==1
                            generator=rng;
                            o.noiseListSeed=generator.Seed;
                        end
                        rng(o.noiseListSeed);
                    end
                    noise=PsychRandSample(noiseList,o.canvasSize);
                    if o.noiseIsFiltered
                            if any(mtf(:)~=1)
                                if any(mtf(:)~=0)
                                    % filtering 50x50 takes 200 ms on PowerMac 7500/100
                                    ft=mtf.*fftshift(fft2(noise));
                                    noise=real(ifft2(ifftshift(ft)));
                                    clear ft
                                else
                                    noise=zeros(size(noise));
                                end
                            end
                    end
                    if i==signalLocation
                        switch o.targetModulates
                            case 'noise',
                                location(i).image=1+r*(o.noiseSD/o.noiseListSd)*noise;
                            case 'luminance',
                                location(i).image=1+(o.noiseSD/o.noiseListSd)*noise+o.contrast;
                            case 'entropy',
                                q.noiseList=(0.5+floor(noiseList*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                                q.sd=std(q.noiseList);
                                location(i).image=1+(o.noiseSD/q.sd)*(0.5+floor(noise*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                        end
                    else
                        switch o.targetModulates
                            case 'entropy',
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
                whichSignal=randi(o.alternatives);
                if o.noiseFrozenInRun
                    rng(o.noiseListSeed);
                end
                noise=PsychRandSample(noiseList,o.canvasSize);
                noise(~centralNoiseMask & ~annularNoiseMask)=0;
                noise(centralNoiseMask)=centralNoiseEnvelope(centralNoiseMask).*noise(centralNoiseMask);
                canvasRect=RectOfMatrix(noise);
                sRect=RectOfMatrix(signal(1).image);
                sRect=round(CenterRect(sRect,canvasRect));
                assert(IsRectInRect(sRect,canvasRect));
                signalImageIndex=logical(FillRectInMatrix(true,sRect,zeros(o.canvasSize)));
%                 figure(1);imshow(signalImageIndex);
                signalImage=zeros(o.canvasSize);
                signalImage(signalImageIndex)=signal(whichSignal).image(:);
%                 figure(2);imshow(signalImage);
                signalMask=logical(signalImage);
                switch o.targetModulates
                    case 'luminance',
                        location(1).image=ones(o.canvasSize);
                        location(1).image(centralNoiseMask)=1+(o.noiseSD/o.noiseListSd)*noise(centralNoiseMask);
                        location(1).image(annularNoiseMask)=1+(o.annularNoiseSD/o.noiseListSd)*noise(annularNoiseMask);
                        location(1).image=location(1).image+o.contrast*signalImage;
                    case 'noise'
                        noise(signalMask)=r*noise(signalMask);
                        location(1).image=ones(o.canvasSize);
                        location(1).image(centralNoiseMask)=1+(o.noiseSD/o.noiseListSd)*noise(centralNoiseMask);
                        location(1).image(annularNoiseMask)=1+(o.annularNoiseSD/o.noiseListSd)*noise(annularNoiseMask);
                    case 'entropy',
                        noise(~centralNoiseMask)=0;
                        noise(signalMask)=(0.5+floor(noise(signalMask)*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                        noise(~signalMask)=(0.5+floor(noise(~signalMask)*0.499999*o.backgroundEntropyLevels))/(0.5*o.backgroundEntropyLevels);
                        location(1).image=1+(o.noiseSD/o.noiseListSd)*noise;
                end
            otherwise
                error('Unknown o.task "%s"',o.task);
        end
        switch o.observer
            case 'ideal'
                clear likely
                switch o.task
                    case '4afc',
                        switch o.targetModulates
                            case 'luminance',
                                % pick darkest
                                for i=1:locations
                                    im=location(i).image(signalImageIndex);
                                    likely(i)=-sum((im(:)-1));
                                end
                            otherwise
                                % the maximum likelihood choice is the one with
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
                    case 'identify',
                        switch o.targetModulates
                            case 'luminance',
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
                                end
                        end
                end % switch o.task
                [junk,response]=max(likely);
                if o.printLikelihood
                    response
                end
            case 'brightnessSeeker'
                clear likely
                switch o.task
                    case '4afc',
                        % Rank by brightness.
                        % Assume brightness is
                        % (image-1)+o.observerQuadratic*(image-1)^2
                        % Pelli ms on irradiation defines the
                        % nonlinearity S(C), where C=image-1.
                        % S'=1+o.observerQuadratic*2*(image-1)
                        % S"=o.observerQuadratic*2
                        % S'(0)=1; S"(0)=o.observerQuadratic*2;
                        % The paper defines
                        % k = (-1/4) S"(0)/S'(0)
                        %   = -0.25*o.observerQuadratic*2
                        %    =-0.5*o.observerQuadratic
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
                    case 'identify',
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
                [junk,response]=max(likely);
           case 'blackshot'
                clear likely
                % Michelle Qiu digitized Fig. 6, observer CC, of Chubb et
                % al. (2004). c is the contrast, defined as luminance
                % minus mean luminance divided by mean luminance. b is the
                % response of the blackshot mechanism.
                c=[-1 -0.878 -0.748 -0.637 -0.508 -0.366 -0.248 -0.141 0.0992 0.214 0.324 0.412 0.523 0.634 0.767 0.878 1];
                b=[0.102 0.749 0.944 0.945 0.921 0.909 0.91 0.907 0.905 0.905 0.906 0.915 0.912 0.906 0.886 0.868 0.932];
                switch o.task
                    case '4afc',
                        % Rank by blackshot mechanism defined by Chubb et al. (2004).
                        for i=1:locations
                            im=location(i).image(signalImageIndex);
                            assert(all(im(:)>=0) && all(im(:)<=2))
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
                    case 'identify',
                        % Rank hypotheses by blackshot contrast of
                        % supposed letter to background.
                        for i=1:o.alternatives
                            signalMask=signal(i).image;
                            im=location(1).image(signalImageIndex);
                            assert(all(im(:)>=0) && all(im(:)<=2))
                            im=im(:)-1;
                            blackshot=interp1(c,b,im);
                            ink=blackshot(signalMask);
                            paper=blackshot(~signalMask);
                            likely(i)=-mean(ink(:))+mean(paper(:));
                        end
                end
                [junk,response]=max(likely);
                if o.printLikelihood
                    response
                end
            case 'maximum'
                clear likely
                switch o.task
                    case '4afc',
                        % Rank by maximum pixel.
                        for i=1:locations
                            im=location(i).image(signalImageIndex);
                            im=im(:)-1;
                            likely(i)=max(im(:));
                        end
                    case 'identify',
                        error('maximum o.observer not yet implemented for "identify" task');
                        % Rank hypotheses by contrast of
                        % supposed letter to background.
                        for i=1:o.alternatives
                            signalMask=signal(i).image;
                            im=zeros(size(signal(i).image));
                            im(:)=location(1).image(signalImageIndex);
                            im=im(:)-1;
                            % Set o.observerQuadratic  to 0 for linear. 1 for square law. 0.2 for
                            % 0.8 linear and 0.2 square.
                            brightness=im+o.observerQuadratic*im.^2;
                            ink=brightness(signalMask);
                            paper=brightness(~signalMask);
                            likely(i)=sign(o.observerQuadratic)*(mean(ink(:))-mean(paper(:)));
                        end
                end
                [junk,response]=max(likely);
            otherwise % human o.observer
                % imshow(location(1).image);
                % ffprintf(ff,'location(1).image size %dx%d\n',size(location(1).image));
                %  ffprintf(ff,'o.canvasSize %d %d\n',o.canvasSize);
                Screen('FillRect',window,gray1);
                Screen('FillRect',window,gray,o.stimulusRect);
                if o.yellowAnnulusBigRadiusDeg>o.yellowAnnulusSmallRadiusDeg
                    r=[0 0 o.yellowAnnulusBigSize]*o.noiseCheckPix;
                    r=CenterRect(r,o.stimulusRect);
                    r=OffsetRect(r,targetOffsetPix,0);
                    Screen('FillRect',window,[gray gray 0],r);
                    r=[0 0 o.yellowAnnulusSmallSize]*o.noiseCheckPix;
                    r=CenterRect(r,o.stimulusRect);
                    r=OffsetRect(r,targetOffsetPix,0);
                    Screen('FillRect',window,gray,r);
                end
                Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
                rect=[0,0,1,1]*2*o.annularNoiseBigRadiusDeg*o.pixPerDeg/o.noiseCheckPix;
                if o.newClutForEachImage
                    if 0 % Compute clut for the image
                        L=[];
                        for i=1:locations
                            L=[L location(i).image(:)*LMean];
                        end
                        cal.LFirst=min(L);
                        cal.LLast=max(L);
                    end
                    % Compute clut for all possible images. Note: Except
                    % under Windows, the gray screen in the non-stimulus
                    % areas is drawn with CLUT index n=1.
                    %
                    % Noise
                    cal.LFirst=LMean*(1-o.noiseListBound*r*o.noiseSD/o.noiseListSd);
                    cal.LLast=LMean*(1+o.noiseListBound*r*o.noiseSD/o.noiseListSd);
                    if streq(o.targetModulates,'luminance')
                        cal.LFirst=cal.LFirst+min(0,LMean*o.contrast);
                        cal.LLast=cal.LLast+max(0,LMean*o.contrast);
                    end
                    if o.useFlankers && isfinite(o.flankerContrast)
                        cal.LFirst=min(cal.LFirst,LMean*(1+o.flankerContrast));
                        cal.LLast=max(cal.LLast,LMean*(1+o.flankerContrast));
                    end
                    if o.annularNoiseBigRadiusDeg>o.annularNoiseSmallRadiusDeg
                        cal.LFirst=min(cal.LFirst,LMean*(1-o.noiseListBound*r*o.annularNoiseSD/o.noiseListSd));
                        cal.LLast=max(cal.LLast,LMean*(1+o.noiseListBound*r*o.annularNoiseSD/o.noiseListSd));
                    end
                    % Range is centered on LMean and includes LFirst and
                    % LLast. Having a fixed index for "gray" (LMean) means
                    % that the gray areas won't change when the CLUT is
                    % updated.
                    LRange=2*max(cal.LLast-LMean,LMean-cal.LFirst);
                    LRange=max(LRange,o.minLRange); % Needed for Windows.
                    LRange=min(LRange,o.maxLRange);
                    cal.LFirst=LMean-LRange/2;
                    cal.LLast=LMean+LRange/2;
                    cal.nFirst=firstGrayClutEntry;
                    cal.nLast=lastGrayClutEntry;
                    if o.saveSnapshot
                        cal.LFirst=min(cal.old.L);
                        cal.LLast=max(cal.old.L);
                        cal.nFirst=1;
                        cal.nLast=255;
                    end
                    cal=LinearizeClut(cal);
                    grayCheck=IndexOfLuminance(cal,LMean);
                    if ~o.saveSnapshot && grayCheck~=gray
                        ffprintf(ff,'The estimated gray index is %d (%.1f cd/m^2), not %d (%.1f cd/m^2).\n',grayCheck,LuminanceOfIndex(cal,grayCheck),gray,LuminanceOfIndex(cal,gray));
                        warning('The gray index changed!');
                    end
                    assert(isfinite(gray));
                end % if o.newClutForEachImage
                if o.assessContrast
                    % Estimate actual contrast on screen.
                    img=IndexOfLuminance(cal,LMean);
                    img=img:255;
                    L=EstimateLuminance(cal,img);
                    dL=diff(L);
                    i=find(dL,1);
                    if isfinite(i)
                        contrastEstimate=dL(i)/L(i);
                    else
                        contrastEstimate=nan;
                    end
                    switch o.targetModulates
                        case 'luminance',
                            img=[1 1+o.contrast];
                        otherwise
                            noise=PsychRandSample(noiseList,o.canvasSize);
                            img=1+noise*o.noiseSD/o.noiseListSd;
                    end
                    index=IndexOfLuminance(cal,img*LMean);
                    imgEstimate=EstimateLuminance(cal,index)/LMean;
                    rmsContrastError=rms(img(:)-imgEstimate(:));
                    ffprintf(ff,'Assess contrast: At LMean, the minimum contrast step is %.4f, with rmsContrastError %.3f\n',contrastEstimate,rmsContrastError);
                    switch o.targetModulates
                        case 'luminance',
                            img=[1,1+o.contrast];
                            img=IndexOfLuminance(cal,img*LMean);
                            L=EstimateLuminance(cal,img);
                            ffprintf(ff,'Assess contrast: Desired o.contrast of %.3f will be rendered as %.3f (estimated)\n',o.contrast,diff(L)/L(1));
                        otherwise
                            noiseSDEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:));
                            img=1+r*(o.noiseSD/o.noiseListSd)*noise;
                            img=IndexOfLuminance(cal,img*LMean);
                            imgEstimate=EstimateLuminance(cal,img)/LMean;
                            rEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:))/noiseSDEstimate;
                            ffprintf(ff,'noiseSDEstimate %.3f (nom. %.3f), rEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,rEstimate,r);
                            if abs(log10([noiseSDEstimate/o.noiseSD rEstimate/r]))>0.5*log10(2)
                                ffprintf(ff,'WARNING: PLEASE TELL DENIS: noiseSDEstimate %.3f (nom. %.3f), rEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,rEstimate,r);
                            end
                    end
                end % assess contrast
                if o.testBitDepth
                    % display a ramp. on/off at 1 Hz, add one part in n bits, where
                    % n=o.testBitDepth.
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
                    Screen('PutImage',window,img,r);
                    Screen('LoadNormalizedGammaTable',window,cal.gamma);
                    Screen('Flip',window);
                    for bits=2:11
                        msg=sprintf('bit %d, hit space bar to continue',bits);
                        Speak(msg);
                        newGamma=floor(cal.gamma*(2^bits-1))/(2^bits-1);
                        ListenChar(0); % flush. May not be needed.
                        ListenChar(2); % no echo. Needed.
                        while CharAvail
                            GetChar;
                        end
                        while ~CharAvail
                            Screen('LoadNormalizedGammaTable',window,cal.gamma);
                            WaitSecs(0.11);
                            Screen('LoadNormalizedGammaTable',window,newGamma);
                            WaitSecs(0.11);
                        end
                        Screen('LoadNormalizedGammaTable',window,cal.gamma);
                        GetChar;
                        ListenChar; % Back to normal. Needed.
                    end
                    Speak('Done');
                    break;
                end % o.textBitDepth
                if o.showCropMarks
                    TrimMarks(window,frameRect); % This should be moved down, to be drawn AFTER the noise.
                end
                if o.saveSnapshot && o.snapshotShowsFixationBefore
                    Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,0); % fixation
                end
                switch o.task
                    case 'identify'
                        locations=1;
                        % Convert to integer pixels.
                        img=location(1).image;
                        % ffprintf(ff,'signal rect height %.1f, image height %.0f, dst rect %d %d %d %d\n',RectHeight(rect),size(img,1),rect);
                        if o.printGammaLoadings
                            ffprintf(ff,'o.noiseSD %.1f, contrast %.2f, image min %.2f, max %.2f, clut min %.2f, max %.2f\n',o.noiseSD,o.contrast,min(img(:)),max(img(:)),cal.LFirst/LMean,cal.LLast/LMean);
                        end
                        img=IndexOfLuminance(cal,img*LMean);
                        if o.yellowAnnulusBigRadiusDeg>o.yellowAnnulusSmallRadiusDeg
                            m=img;
                            a=zeros(size(m,1),size(m,2),3);
                            a(:,:,1)=m;
                            a(:,:,2)=m;
                            m(yellowMask)=0;
                            a(:,:,3)=m;
                            img=a;
                        end
                        img=Expand(img,o.noiseCheckPix);
                        if o.assessLinearity
                            fprintf('Assess linearity.\n');
                            gratingL=LMean*repmat([0.2 1.8],400,200); % 400x400 grating
                            gratingImg=IndexOfLuminance(cal,gratingL);
                            texture=Screen('MakeTexture',window,uint8(gratingImg));
                            r=RectOfMatrix(gratingImg);
                            r=CenterRect(r,o.stimulusRect);
                            Screen('DrawTexture',window,texture,RectOfMatrix(gratingImg),r);
                            peekImg=Screen('GetImage',window,r,'drawBuffer');
                            Screen('Close',texture);
                            peekImg=peekImg(:,:,2);
                            figure(1);
                            subplot(2,2,1);imshow(uint8(gratingImg));title('image written');
                            subplot(2,2,2);imshow(peekImg);title('image read');
                            subplot(2,2,3);imshow(uint8(gratingImg(1:4,1:4)));title('4x4 of image written')
                            subplot(2,2,4);imshow(peekImg(1:4,1:4));title('4x4 of image read');
                            fprintf('desired normalized luminance: %.1f %.1f\n',gratingL(1,1:2)/LMean);
                            fprintf('grating written: %.1f %.1f\n',gratingImg(1,1:2));
                            fprintf('grating read: %.1f %.1f\n',peekImg(1,1:2));
                            fprintf('normalized luminance: %.1f %.1f\n',LuminanceOfIndex(cal,peekImg(1,1:2))/LMean);
                        end
                        rect=RectOfMatrix(img);
                        rect=CenterRect(rect,o.stimulusRect);
                        rect=OffsetRect(rect,targetOffsetPix,0);
                        rect=round(rect); % rect that will receive the stimulus (target and noises)
                        location(1).rect=rect;
                        texture=Screen('MakeTexture',window,uint8(img));
                        srcRect=RectOfMatrix(img);
                        dstRect=rect;
                        offset=dstRect(1:2)-srcRect(1:2);
                        dstRect=ClipRect(dstRect,o.stimulusRect);
                        srcRect=OffsetRect(dstRect,-offset(1),-offset(2));
                        Screen('DrawTexture',window,texture,srcRect,dstRect);
                        % peekImg=Screen('GetImage',window,InsetRect(rect,-1,-1),'drawBuffer');
                        % imshow(peekImg);
                        eraseRect=dstRect;
                        Screen('Close',texture);
                        rect=CenterRect([0 0 o.targetHeightPix o.targetWidthPix],rect);
                        rect=round(rect); % target rect
                        if o.useFlankers
                            flankerOffset=[-1 0;1 0;0 -1;0 1]*flankerSpacingPix;
                            flankerBoundsRect=[];
                            for j=1:4
                                dx=flankerOffset(j,1);
                                dy=flankerOffset(j,2);
                                r=OffsetRect(rect,dx,dy);
                                i=randi(o.alternatives);
                                if isfinite(o.flankerContrast)
                                    img=1+o.flankerContrast*signal(i).image;
                                else
                                    img=1+o.contrast*signal(i).image;
                                end
                                img=Expand(img,o.noiseCheckPix);
                                buffer=Screen('GetImage',window,r,'drawBuffer');
                                blanks= buffer==1;
                                buffer(blanks)=IndexOfLuminance(cal,LMean);
                                bufferL=LuminanceOfIndex(cal,buffer(:,:,1));
                                bufferTest=IndexOfLuminance(cal,bufferL);
                                img=IndexOfLuminance(cal,bufferL+img*LMean-LMean);
                                texture=Screen('MakeTexture',window,uint8(img));
                                srcRect=RectOfMatrix(img);
                                dstRect=r;
                                offset=dstRect(1:2)-srcRect(1:2);
                                dstRect=ClipRect(dstRect,o.stimulusRect);
                                srcRect=OffsetRect(dstRect,-offset(1),-offset(2));
                                Screen('DrawTexture',window,texture,srcRect,dstRect);
                                Screen('Close',texture);
                                eraseRect=UnionRect(eraseRect,r);
                            end
                        end % if o.userFlankers
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
                            img=Expand(img,o.noiseCheckPix);
                            texture=Screen('MakeTexture',window,uint8(img));
                            Screen('DrawTexture',window,texture,RectOfMatrix(img),location(i).rect);
                            Screen('Close',texture);
                            eraseRect=UnionRect(eraseRect,location(i).rect);
                        end
                        if o.showResponseNumbers
                            % Label the o.alternatives 1 to 4. They are
                            % places to one side of the quadrant, centered
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
                                r=[0 0 textSize 1.4*textSize];
                                labelBounds=InsetRect(boundsRect,-1.1*textSize,-o.lineSpacing*textSize);
                            else
                                % on sides
                                r=[0 0 textSize o.targetHeightPix];
                                labelBounds=InsetRect(boundsRect,-2*textSize,0);
                            end
                            location(1).labelRect=AlignRect(r,labelBounds,'left','top');
                            location(2).labelRect=AlignRect(r,labelBounds,'right','top');
                            location(3).labelRect=AlignRect(r,labelBounds,'left','bottom');
                            location(4).labelRect=AlignRect(r,labelBounds,'right','bottom');
                            for i=1:locations
                                [x,y]=RectCenter(location(i).labelRect);
                                Screen('DrawText',window,sprintf('%d',i),x-textSize/2,y+0.4*textSize,black,0,1);
                            end
                        end
                end % switch o.task
                eraseRect=ClipRect(eraseRect,o.stimulusRect);

                % Print instruction in upper left corner.
                Screen('FillRect',window,gray1,topCaptionRect);
                message=sprintf('Trial %d of %d. Run %d of %d.',trial,o.trialsPerRun,o.runNumber,o.runsDesired);
                Screen('DrawText',window,message,textSize/2,textSize/2,black,gray1);

                % Print instructions in lower left corner.
                textRect=[0,0,textSize,1.2*textSize];
                textRect=AlignRect(textRect,screenRect,'left','bottom');
                textRect=OffsetRect(textRect,textSize/2,-textSize/2); % inset from screen edges
                textRect=round(textRect);
                switch o.task
                    case '4afc',
                        message='Please click 1 to 4 times for location 1 to 4, or more clicks to quit.';
                    case 'identify',
                        message=sprintf('Please type the letter: %s, or period ''.'' to quit.',o.alphabet(1:o.alternatives));
                end
                bounds=Screen('TextBounds',window,message);
                ratio=RectWidth(bounds)/(0.93*RectWidth(screenRect));
                if ratio>1
                    Screen('TextSize',window,floor(textSize/ratio));
                end
                Screen('FillRect',window,gray1,bottomCaptionRect);
                Screen('DrawText',window,message,textRect(1),textRect(4),black,gray1,1);
                Screen('TextSize',window,textSize);

                % Display response alternatives.
                switch o.task
                    case '4afc',
                        leftEdgeOfResponse=screenRect(3);
                    case 'identify'
                        % Draw the response o.alternatives
                        rect=[0 0 o.targetWidthPix o.targetHeightPix]/o.noiseCheckPix; % size of signal(1).image
                        switch o.alphabetPlacement
                            case 'right',
                                desiredLengthPix=RectHeight(screenRect);
                                signalChecks=RectHeight(rect);
                            case 'top',
                                desiredLengthPix=0.5*RectWidth(screenRect);
                                signalChecks=RectWidth(rect);
                        end
                        switch o.targetKind
                            case 'letter',
                                spacingFraction=0.25;
                            case 'gabor'
                                spacingFraction=0;
                        end
                        if o.alternatives<6
                            desiredLengthPix=desiredLengthPix*o.alternatives/6;
                        end
                        alphaSpaces=o.alternatives+spacingFraction*(o.alternatives+1);
                        alphaPix=desiredLengthPix/alphaSpaces;
%                         alphaCheckPix=alphaPix/(signalChecks/o.noiseCheckPix);
                        alphaCheckPix=alphaPix/signalChecks;
                        alphaGapPixCeil=(desiredLengthPix-o.alternatives*ceil(alphaCheckPix)*signalChecks)/(o.alternatives+1);
                        alphaGapPixFloor=(desiredLengthPix-o.alternatives*floor(alphaCheckPix)*signalChecks)/(o.alternatives+1);
                        ceilError=log(alphaGapPixCeil/(ceil(alphaCheckPix)*signalChecks))-log(spacingFraction);
                        floorError=log(alphaGapPixFloor/(floor(alphaCheckPix)*signalChecks))-log(spacingFraction);
                        if min(abs(ceilError),abs(floorError))<log(3)
                            if abs(floorError)<abs(ceilError)
                                alphaCheckPix=floor(alphaCheckPix);
                            else
                                alphaCheckPix=ceil(alphaCheckPix);
                            end
                        end
                        alphaGapPix=(desiredLengthPix-o.alternatives*signalChecks*alphaCheckPix)/(o.alternatives+1);
                        useExpand = alphaCheckPix==round(alphaCheckPix);
                        rect=[0 0 o.targetWidthPix o.targetHeightPix]/o.noiseCheckPix; % size of signal(1).image
                        rect=round(rect*alphaCheckPix);
                        rect=AlignRect(rect,screenRect,RectRight,RectTop);
                        rect=OffsetRect(rect,-alphaGapPix,alphaGapPix); % spacing
                        rect=round(rect);
                        switch o.alphabetPlacement
                            case 'right',
                                step=[0 RectHeight(rect)+alphaGapPix];
                            case 'top',
                                step=[RectWidth(rect)+alphaGapPix 0];
                                rect=OffsetRect(rect,-(o.alternatives-1)*step(1),0);
                        end
                        for i=1:o.alternatives
                            if useExpand
                                img=Expand(signal(i).image,alphaCheckPix);
                            else
                                if useImresize
                                    img=imresize(signal(i).image,[RectHeight(rect),RectWidth(rect)]);
                                else
                                    img=signal(i).image;
                                    % If the imresize function (in Image
                                    % Processing Toolbox) is not available
                                    % the image resizing will then be done
                                    % by the DrawTexture command below.
                                end
                            end
                            texture=Screen('MakeTexture',window,(1-img)*gray);
                            Screen('DrawTexture',window,texture,RectOfMatrix(img),rect);
                            Screen('Close',texture);
                            if o.labelAlternatives
                                Screen('TextSize',window,textSize);
                                textRect=AlignRect([0 0 textSize textSize],rect,'center','top');
                                Screen('DrawText',window,o.alphabet(i),textRect(1),textRect(4),black,gray1,1);
                            end
                            rect=OffsetRect(rect,step(1),step(2));
                        end
                        leftEdgeOfResponse=rect(1);
                end % switch o.task
                if o.flipClick; Speak(['before LoadNormalizedGammaTable ' num2str(MFileLineNr)]);GetClicks; end
                if o.printGammaLoadings;ffprintf(ff,'LoadNormalizedGammaTable %d, LRange/LMean=%.2f\n',1597,(cal.LLast-LMean)/LMean); end
                Screen('LoadNormalizedGammaTable',window,cal.gamma);
                if assessGray; pp=Screen('GetImage',window,[20 20 21 21]);ffprintf(ff,'line 1264: Gray index is %d (%.1f cd/m^2). Corner is %d.\n',gray,LuminanceOfIndex(cal,gray),pp(1)); end
                if trial==1
                    WaitSecs(1); % First time is slow. Mario suggested a work around, explained at beginning of this file.
                end
                if o.flipClick; Speak(['before Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                Snd('Play',purr); % Announce that image is up, awaiting response.
                if o.showBlackAnnulus
                    radius=round(o.blackAnnulusSmallRadiusDeg*o.pixPerDeg);
                    o.blackAnnulusSmallRadiusDeg=radius/o.pixPerDeg;
                    annulusRect=[0 0 2*radius 2*radius];
                    annulusRect=CenterRect(annulusRect,o.stimulusRect);
                    annulusRect=OffsetRect(annulusRect,targetOffsetPix,0);
                    thickness=max(1,round(o.blackAnnulusThicknessDeg*o.pixPerDeg));
                    o.blackAnnulusThicknessDeg=thickness/o.pixPerDeg;
                    if o.blackAnnulusContrast==-1
                        color=0;
                    else
                        luminance=(1+o.blackAnnulusContrast)*LMean;
                        luminance=max(min(luminance,cal.LLast),cal.LFirst);
                        color=IndexOfLuminance(cal,luminance);
                        o.blackAnnulusContrast=LuminanceOfIndex(cal,color)/LMean-1;
                    end
                    Screen('FrameRect',window,color,annulusRect,thickness);
                end
                if o.saveStimulus
                    o.savedStimulus=Screen('GetImage',window,o.stimulusRect,'drawBuffer');
                end
                Screen('Flip',window,0,1); % Show target with instructions. Don't clear buffer.
                signalOnset=GetSecs;
                if o.flipClick; Speak(['after Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                if o.saveSnapshot
                    if o.snapshotShowsFixationAfter
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
                    r=InsetRect(r,textSize/2,textSize/2);
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
                                x(i).p(j)=length(find(img(:)==x(i).L(j)))/total;
                            end
                            x(i).entropy=sum(-x(i).p .* log2(x(i).p));
                        end
                        saveSize=Screen('TextSize',window,round(textSize*.4));
                        saveFont=Screen('TextFont',window,'Courier');
                        for i=1:4
                            s=[sprintf('L%d',i) sprintf(' %4.2f',x(i).L)];
                            Screen('DrawText',window,s,rect(1),rect(2)-360-(5-i)*30);
                        end
                        for i=1:4
                            s=[sprintf('p%d',i) sprintf(' %4.2f',x(i).p)];
                            Screen('DrawText',window,s,rect(1),rect(2)-240-(5-i)*30);
                        end
                        Screen('TextSize',window,round(textSize*.8));
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
                        case 'luminance',
                            caption{1}=sprintf('signal %.3f',10^tTest);
                            caption{2}=sprintf('noise sd %.3f',o.noiseSD);
                        case 'noise',
                            caption{1}=sprintf('noise sd %.3f',o.noiseSD);
                            caption{end+1}=sprintf('n %.0f',checks);
                        case 'entropy',
                            caption{1}=sprintf('ratio # lum. %.3f',1+10^tTest);
                            caption{2}=sprintf('noise sd %.3f',o.noiseSD);
                            caption{end+1}=sprintf('n %.0f',checks);
                        otherwise
                            caption{1}=sprintf('sd ratio %.3f',1+10^tTest);
                            caption{2}=sprintf('approx required n %.0f',approxRequiredN);
                    end
                    switch o.task
                        case '4afc',
                            answer=signalLocation;
                            answerString=sprintf('%d',answer);
                            caption{end+1}=sprintf('xyz%s',lower(answerString));
                        case 'identify',
                            answer=whichSignal;
                            answerString=o.alphabet(answer);
                            caption{end+1}=sprintf('xyz%s',lower(answerString));
                    end
                    rect=OffsetRect(o.stimulusRect,-o.snapshotCaptionTextSize/2,0);
                    for i=length(caption):-1:1
                        r=Screen('TextBounds',window,caption{i});
                        r=AlignRect(r,rect,RectRight,RectBottom);
                        Screen('DrawText',window,caption{i},r(1),r(2));
                        rect=OffsetRect(r,0,-o.snapshotCaptionTextSize);
                    end
                    Screen('TextSize',window,saveSize);
                    Screen('TextFont',window,saveFont);
                    if o.flipClick; Speak(['before Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                    Screen('Flip', window,0,1); % Save image for snapshot. Show target, instructions, and fixation.
                    if o.flipClick; Speak(['after Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
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
                        case 'luminance',
                            filename=sprintf('%s_%s_%s%s_%.3fc_%.0fpix_%s',signalDescription,o.task,o.noiseType,freezing,10^tTest,checks,answerString);
                        case {'noise','entropy'},
                            filename=sprintf('%s_%s_%s%s_%.3fr_%.0fpix_%.0freq_%s',signalDescription,o.task,o.noiseType,freezing,1+10^tTest,checks,approxRequiredN,answerString);
                    end
                    mypath=fileparts(mfilename('fullpath'));
                    saveSnapshotFid=fopen(fullfile(mypath,[filename '.png']),'rt');
                    if saveSnapshotFid~=-1
                        for suffix='a':'z'
                            saveSnapshotFid=fopen(fullfile(mypath,[filename suffix '.png']),'rt');
                            if saveSnapshotFid==-1
                                filename=[filename suffix];
                                break
                            end
                        end
                        if saveSnapshotFid~=-1
                            error('Can''t save file. Already 26 files with that name plus a-z');
                        end
                    end
                    filename=[filename '.png'];
                    imwrite(img,fullfile(mypath,filename),'png');
                    ffprintf(ff,'Saving image to file "%s" ',filename);
                    switch o.targetModulates
                        case 'luminance',
                            ffprintf(ff,'log(contrast) %.2f\n',tTest);
                        case 'noise',
                            ffprintf(ff,'approx required n %.0f, sd ratio r %.3f, log(r-1) %.2f\n',approxRequiredN,1+10^tTest,tTest);
                        case 'entropy',
                            ffprintf(ff,'ratio r=signalLevels/backgroundLevels %.3f, log(r-1) %.2f\n',1+10^tTest,tTest);
                    end
                    o.trialsPerRun=1;
                    o.runsDesired=1;
                    ffprintf(ff,'SUCCESS: o.saveSnapshot is done. Image saved, now returning.\n');
                    sca; % screen close all
                    AutoBrightness(cal.screen,1); % Restore autobrightness.
                    fclose(dataFid);
                    return;
                end % if o.saveSnapshot
                if isfinite(o.durationSec)
                    Screen('FillRect',window,gray,o.stimulusRect);
                    if o.yellowAnnulusBigRadiusDeg>o.yellowAnnulusSmallRadiusDeg
                        r=CenterRect([0 0 o.yellowAnnulusBigSize]*o.noiseCheckPix,o.stimulusRect);
                        r=OffsetRect(r,targetOffsetPix,0);
                        Screen('FillRect',window,[gray gray 0],r);
                        r=CenterRect([0 0 o.yellowAnnulusSmallSize]*o.noiseCheckPix,o.stimulusRect);
                        r=OffsetRect(r,targetOffsetPix,0);
                        Screen('FillRect',window,gray,r);
                    end
                    if o.flipClick; Speak(['before Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                    Screen('Flip',window,signalOnset+o.durationSec-1/frameRate,1); % Duration is over. Erase target.
                    if o.flipClick; Speak(['after Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                    signalOffset=GetSecs;
                    actualDuration=GetSecs-signalOnset;
                    if abs(actualDuration-o.durationSec)>0.05
                        ffprintf(ff,'WARNING: Duration requested %.2f, actual %.2f\n',o.durationSec,actualDuration);
                    else
                        if o.printSignalDuration
                            ffprintf(ff,'Duration requested %.2f, actual %.2f\n',o.durationSec,actualDuration);
                        end
                    end
                    if ~o.fixationCrossBlankedNearTarget
                        WaitSecs(o.fixationCrossBlankedUntilSecsAfterTarget);
                    end
                    Screen('DrawLines',window,fixationLines,fixationCrossWeightPix,black); % fixation
                    if o.flipClick; Speak(['before Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                    Screen('Flip',window,signalOffset+0.3,1,1); % After o.fixationCrossBlankedUntilSecsAfterTarget, display new fixation.
                    if o.flipClick; Speak(['after Flip dontclear ' num2str(MFileLineNr)]);GetClicks; end
                end
                switch o.task
                    case '4afc',
                        global ptb_mouseclick_timeout
                        ptb_mouseclick_timeout=0.8;
                        clicks=GetClicks;
                        if ~ismember(clicks,1:locations)
                            ffprintf(ff,'*** %d clicks. Run terminated.\n',clicks);
                            Speak('Run terminated.');
                            trial=trial-1;
                            o.runAborted=1;
                            break;
                        end
                        response=clicks;
                    case 'identify'
                        response=0;
                        while ~ismember(response,1:o.alternatives)
                            o.runAborted=0;
                            response = GetKeypress(o.isKbLegacy);
                            %disp(sprintf('2:==>%s<==', response));
                            if response=='.'
                                ffprintf(ff,'*** ''%c'' response. Run terminated.\n',response);
                                Speak('Run terminated.');
                                o.runAborted=1;
                                trial=trial-1;
                                break;
                            end
                            [ok,response]=ismember(upper(response),o.alphabet);  
                            if ~ok
                                Speak('Try again. Type period to quit.');
                            end
                        end
                        if o.runAborted
                            break;
                        end
                end
        end
        switch o.task
            % score as right or wrong
            case '4afc',
                response=response==signalLocation;
            case 'identify',
                response=response==whichSignal;
        end
        if ~ismember(o.observer,algorithmicObservers)
            if response
                Snd('Play',rightBeep);
            else
                Snd('Play',wrongBeep);
            end
        end
        switch o.thresholdParameter
            case 'spacing',
                %                     results(n,1)=spacingDeg;
                %                     results(n,2)=response;
                %                     n=n+1;
                spacingDeg=flankerSpacingPix/o.pixPerDeg;
                tTest=log10(spacingDeg);
            case 'size'
                %                     results(n,1)=targetSizeDeg;
                %                     results(n,2)=response;
                %                     n=n+1;
                targetSizeDeg=o.targetHeightPix/o.pixPerDeg;
                tTest=log10(targetSizeDeg);
            case 'contrast'
                %                     results(n,1)=10^tTest;
                %                     results(n,2)=response;
                %                     n=n+1;
        end
        trialsRight=trialsRight+response;
        q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and o.observer response) to the database.
        o.data(trial,1:2)=[tTest response];
        if cal.ScreenConfigureDisplayBrightnessWorks
            %Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
            cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
            if abs(cal.brightnessSetting-cal.brightnessReading)>0.01
                ffprintf(ff,'Screen brightness was set to %.0f%%, but now reads as %.0f%%.\n',100*cal.brightnessSetting,100*cal.brightnessReading);
                sca;
                Speak('Error. The screen brightness changed. In System Preferences Displays please turn off "Automatically adjust brightness".');
                error('Screen brighness changed. Please disable System Preferences:Displays:"Automatically adjust brightness".');
            end
        end
    end % for trial=1:o.trialsPerRun
    if length(o.data)>0
        psych.t=unique(o.data(:,1));
        psych.r=1+10.^psych.t;
        for i=1:length(psych.t)
            dataAtT=o.data(:,1)==psych.t(i);
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
    switch o.thresholdParameter
        case 'spacing',
            ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',o.observer,100*o.p,targetSizeDeg,o.eccentricityDeg,10^QuestMean(q));
        case 'size',
            ffprintf(ff,'%s: p %.0f%%, ecc. %.1f deg, threshold size %.3f deg.\n',o.observer,100*o.p,o.eccentricityDeg,10^QuestMean(q));
        case 'contrast',
    end
    o.contrast=-10^o.questMean;
    o.EOverN=10^(2*o.questMean)*o.E1/N;
    o.efficiency = o.idealEOverNThreshold/o.EOverN;
    o.E = 10^(2*o.questMean)*o.E1;
    if streq(o.targetModulates,'luminance')
        ffprintf(ff,'Run %4d of %d.  %d trials. %.0f%% right. %.3f s/trial. Threshold±sd log(contrast) %.2f±%.2f, contrast %.5f, log E/N %.2f, efficiency %.5f\n',o.runNumber,o.runsDesired,trial,100*trialsRight/trial,(GetSecs-runStart)/trial,t,sd,10^t,log10(o.EOverN),o.efficiency);
    else
        ffprintf(ff,'Run %4d of %d.  %d trials. %.0f%% right. %.3f s/trial. Threshold±sd log(r-1) %.2f±%.2f, approx required n %.0f\n',o.runNumber,o.runsDesired,trial,100*trialsRight/trial,(GetSecs-runStart)/trial,t,sd,approxRequiredN);
    end
    if abs(trialsRight/trial-o.pThreshold)>0.1
        ffprintf(ff,'WARNING: Proportion correct is far from threshold criterion. Threshold estimate unreliable.\n');
    end
    if o.measureBeta
        % reanalyze the data with beta as a free parameter.
        ffprintf(ff,'o.measureBeta, offsetToMeasureBeta %.1f to %.1f\n',min(offsetToMeasureBeta),max(offsetToMeasureBeta));
        bestBeta=QuestBetaAnalysis(q);
        qq=q;
        qq.beta=bestBeta;
        qq=QuestRecompute(qq);
        ffprintf(ff,'dt    P\n');
        tt=QuestMean(qq);
        for offset=sort(offsetToMeasureBeta)
            t=tt+offset;
            ffprintf(ff,'%5.2f %.2f\n',offset,QuestP(qq,offset));
        end
    end
    % end

    %     t=mean(tSample);
    %     tse=std(tSample)/sqrt(length(tSample));
    %     switch o.targetModulates
    %         case 'luminance',
    %         ffprintf(ff,'SUMMARY: %s %d runs mean±se: log(contrast) %.2f±%.2f, contrast %.3f\n',o.observer,length(tSample),mean(tSample),tse,10^mean(tSample));
    %         %         efficiency = (o.idealEOverNThreshold^2) / (10^(2*t));
    %         %         ffprintf(ff,'Efficiency = %f\n', efficiency);
    %         %o.EOverN=10^mean(2*tSample)*o.E1/N;
    %         ffprintf(ff,'Threshold log E/N %.2f±%.2f, E/N %.1f\n',mean(log10(o.EOverN)),std(log10(o.EOverN))/sqrt(length(o.EOverN)),o.EOverN);
    %         %o.efficiency=o.idealEOverNThreshold/o.EOverN;
    %         ffprintf(ff,'User-provided ideal threshold E/N log E/N %.2f, E/N %.1f\n',log10(o.idealEOverNThreshold),o.idealEOverNThreshold);
    %         ffprintf(ff,'Efficiency log %.2f±%.2f, %.4f %%\n',mean(log10(o.efficiency)),std(log10(o.efficiency))/sqrt(length(o.efficiency)),100*10^mean(log10(o.efficiency)));
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
        case 'noise',
            t=o.questMean;
            o.r=10^t+1;
            o.approxRequiredNumber=64./10.^((t-idealT64)/0.55);
            o.logApproxRequiredNumber=log10(o.approxRequiredNumber);
            ffprintf(ff,'r %.3f, approx required number %.0f\n',o.r,o.approxRequiredNumber);
            %              logNse=std(logApproxRequiredNumber)/sqrt(length(tSample));
            %              ffprintf(ff,'SUMMARY: %s %d runs mean±se: log(r-1) %.2f±%.2f, log(approx required n) %.2f±%.2f\n',o.observer,length(tSample),mean(tSample),tse,logApproxRequiredNumber,logNse);
       case 'entropy',
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
    if o.runAborted && o.runNumber<o.runsDesired
        Speak('Please type period to skip the rest and quit now, or space to continue with next run.');
        response=0;
        while 1
            response = GetKeypress(o.isKbLegacy);
            switch response
                case '.',
                    ffprintf(ff,'*** ''.'' response. Quitting now.\n');
                    Speak('Quitting now.');
                    o.quitNow=1;
                    break;
                case ' ',
                    Speak('Continuing.');
                    o.quitNow=0;
                    break;
                otherwise
                    Speak('Try again. Type space to continue, or period to quit.');
            end
        end
    end
    if o.runNumber==o.runsDesired && o.congratulateWhenDone && ~ismember(o.observer,algorithmicObservers)
        Speak('Congratulations. You are done.');
    end
    if Screen(window,'WindowKind')==1
        % Screen takes many seconds to close. This gives us a white screen
        % while we wait.
        Screen('FillRect',window);
        Screen('Flip',window); % White screen
    end
    ListenChar(0); % flush
    ListenChar;
    sca; % Screen('CloseAll'); ShowCursor;
    % This applescript command provokes a screen refresh (by selecting
    % MATLAB). My computers each have only one display, upon which my
    % MATLAB programs open a Psychtoolbox window. This applescript
    % eliminates an annoyingly long pause at the end of my Psychtoolbox
    % programs running under MATLAB 2014a, when returning to the MATLAB
    % command window after twice opening and closing Screen windows.
    % Without this command, when I return to MATLAB, the whole screen
    % remains blank for a long time, maybe 30 s, or until I click
    % something, so I can't tell that I'm back in MATLAB. This applescript
    % command provokes a screen refresh, so the MATLAB editor appears
    % immediately. Among several computers, the problem is always present
    % in MATLAB 2014a and never in MATLAB 2015a. (All computers are running
    % Mavericks.) denis.pelli@nyu.edu, June 18, 2015
    if ismac
        status=system('osascript -e ''tell application "MATLAB" to activate''');
    end
    RestoreCluts;
    if ismac
        AutoBrightness(cal.screen,1); % Restore autobrightness.
    end
    if window>=0
        Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
        Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    end
    fclose(dataFid); dataFid=-1;
    o.signal=signal;
    o.q=q;
    save([datafullfilename '.mat'],'o','cal');
    fprintf('Results saved in %s with extensions .txt and .mat\nin folder %s\n',o.datafilename,fileparts(datafullfilename));
catch
    sca; % screen close all
    AutoBrightness(cal.screen,1); % Restore autobrightness.
    fclose(dataFid);
    dataFid=-1;
    psychrethrow(psychlasterror);
end
return
