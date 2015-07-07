function o=NoiseDiscrimination(oIn)
% o=NoiseDiscrimination(o);
% Pass all your parameters in the "o" struct, which will be returned with
% all the results as additional fields. NoiseDiscrimination may adjust some
% of your parameters to satisfy physical constraints. Constraints include
% the screen size and the maximum possible contrast.
%
% OFF THE NYU CAMPUS: If you have an NYU netid and you're using the NYU
% MATLAB license server then you can work from off campus if you install
% NYU's free VPN software on your computer:
% http://www.nyu.edu/its/nyunet/offcampus/vpn/#services
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
% on a gray background, but the antialiasing surrounded each letter with
% with intermediate levels of gray. The intermediate values were
% problematic. In my CLUT the intermediate values between gray (128) and
% black (0) were much closer to the gray, making the letter seem too thin.
% Worse, I am computing a new color table (CLUT) for each trial, so this
% made the halo around the instructions flicker every time the CLUT
% changed. Eventually I realized that black is zero and that by making the
% gray background have an index of 1, the letters are indeed binary, since
% the font rendering software emits only integers and there are no integers
% between 0 and 1. This leaves me free to do whatever I want with the rest
% of the color table. The letters are imaged well, because the antialiasing
% software is still allowed to work in a more or less normal way.
%
% Similarly, it wasn't easy to put the signal on the screen without getting
% a dark halo on the MacBookPro Retina display. That display, like other
% high-resolution displays, insists on interpolating around the edge.
% Pasting a grayscale image (128) on a background set to 1 resulted in
% intermediate pixel values which were all darker than the background gray.
% I fixed this by making the background be 128. Thus the background is
% always gray LMean, but it's produced by a color index of 128 inside
% stimulusRect, and a color index of 1 outside it. This is easily drawn by
% calling FillRect with 1 for the whole screen, and again with 128 for the
% stimulusRect.

% MIRRORING. PutImage does not respect mirroring. (Mario Kleiner, July 13,
% 2014, explains why.) Screen('PutImage') is implemented via
% glDrawPixels(). It doesn't respond to geometric transformations and
% 'PutImage' by itself is very inflexible, restricted and inefficient. I
% keep it intentionally so, so we have some very primitive way to put
% pixels on the screen, mostly for debugging of the more complex functions.
% Using it in any new code is not recommended.
%
% The most easy thing is to use DrawFormattedText() instead of
% Screen('DrawText') directly. DrawFormattedText() has optional parameters
% to mirror text left-right / upside-down, center it onscreen or in a
% selectable rect etc.
%
% For mirroring of images with glScale you can use
% Screen('MakeTexture/DrawTexture') or for online created content
% 'OpenOffscreenWindow' + 'DrawTexture'.
%
% texture=Screen('MakeTexture',window,imageMatrix);
% Screen('DrawTexture',window,texture,sourceRect,destinationRect);
% Screen('Close',texture);
%
% If you want to mirror the whole stimulus display, the PsychImaging()
% function has subtasks to ask for automatic mirroring of all the window
% content.
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask','General','FlipHorizontal');
%
% You can use the RemapMouse() function to correct GetMouse() positions
% for potential geometric distortions introduced by this function.
%

% clear all

clear PsychHID
if ismac && ~ScriptingOkShowPermission
    error('Please give MATLAB permission to control the computer. You''ll need admin privileges to do this.');
end
if nargin<1 || ~exist('oIn','var')
    oIn.noInputArgument=1;
end
o=[];
% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.
o.useFractionOfScreen=0; % 0 and 1 give normal screen. Just for debugging. Keeps cursor visible.
o.distanceCm=50; % viewing distance
o.flipScreenHorizontally=0; % Use this when viewing the display in a mirror.
o.screen=0; % 0 for main screen
o.observer='junk'; % Name of person or existing algorithm.
% o.observer='denis'; o.observer='michelle'; o.observer='martin';
% o.observer='tiffany'; o.observer='irene'; o.observer='joy';
% o.observer='jacob'; o.observer='jacobaltholz';
% o.observer='brightnessSeeker'; % Existing algorithm instead of person.
% o.observer='maximum'; % Existing algorithm instead of person.
% o.observer='ideal'; % Existing algorithm instead of person.
o.trialsPerRun=40; % Typically 40.
o.runNumber=1; % For display only, indicate the run number. When o.runNumber==runsDesired this program says "Congratulations" before returning.
o.runsDesired=1; % How many runs you to plan to do, used solely for display (and congratulations).
o.congratulateWhenDone=1; % 0 or 1. Spoken after last run (i.e. when o.runNumber==0.runsDesired). You can turn this off.
o.runAborted=0; % 0 or 1. Returned value is 1 if the user aborts this run (i.e. threshold).
o.quitNow=0; % 0 or 1. Returned value is 1 if the observer wants to quit now; no more runs.
% o.signalKind='noise';  % Display a noise increment.
o.signalKind='luminance'; % Display a luminance decrement.
% o.signalKind='entropy'; % Display an entropy increment.
o.task='identify'; % 'identify' or '4afc'
% o.thresholdParameter='size';
% o.thresholdParameter='spacing';
o.thresholdParameter='contrast'; % Use Quest to measure threshold 'contrast','size', or 'spacing'.
% WARNING: size and spacing are not yet fully implemented.
o.alternatives=9; % The number of letters to use from o.alphabet.
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
o.distanceCm=50; % viewing distance
o.flipScreenHorizontally=0; % Use this when viewing display in a mirror.
o.screen=0; % use main screen
o.noiseSD=0.2; % Usually in the range 0 to 0.3. Typically 0.2.
o.outerNoiseSD=nan; % Typically nan (i.e. use o.noiseSD) or 0.2. For noise beyond the hole.
o.noiseCheckDeg=0.2; % Typically 0.05 or 0.2.
o.noiseToTargetRatio=inf; % Noise extent re target. Typically 1 or inf.
o.noiseHoleToTargetRatio=0; % Typically 1 or 0 (no hole).
o.noiseHoleSparesTargetArea=0; % 0 (no sparing) or 1 (put noise on the target, despite any hole).
o.noiseType='gaussian'; % 'gaussian' or 'uniform' or 'binary'
o.noiseFrozenInTrial=0; % 0 or 1.  If true (1), use same noise at all locations
o.noiseFrozenInRun=0; % 0 or 1.  If true (1), use same noise on every trial
o.fixationWidthDeg=inf; % Typically 1 or inf. Make this at least 2 deg for scotopic testing, since the fovea is blind scotopically.
o.fixationLineWeightDeg=0.05; % Typically 0.05. This should be much thicker for scotopic testing.
o.fixationBlankedNearTarget=1; % 0 or 1.
o.postStimulusPauseSecs=0.6; % Pause after stimulus before display of fixation. Skipped when fixationBlankedNearTarget. Not needed when eccentricity is bigger than the target.
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.gapFraction4afc=0.03; % Typically 0, 0.03, or 0.2. Gap, as a fraction of o.targetHeightDeg, between the four squares in 4afc task, ignored in identify task.
o.showCropMarks=0;
o.showResponseNumbers=1;
o.printSignalDuration=0; % print out actual duration of each trial.
o.printCrossCorrelation=0;
o.assessLinearity=0;
o.assessContrast=0; % diagnostic information
o.assessLowLuminance=0;
o.flipClick=0; % For debugging, speak and wait for click before and after each flip.
assessGray=0; % For debugging. Diagnostic printout when we load gamma table.
% o.observerQuadratic=-1.2; % estimated from old second harmonic data
o.observerQuadratic=-0.7; % adjusted to fit noise letter data.
o.backgroundEntropyLevels=2; % Value used only if o.signalKind is 'entropy'
o.idealEOverNThreshold=nan; % You can run the ideal first, and then provide it as a reference when testing human observers.
o.screen=0;
% o.screen=max(Screen('Screens'));
o.alphabet='DHKNORSVZ';
o.alphabetPlacement='top'; % 'top' or 'right';
o.replicatePelli2006=0;
o.isWin=IsWin; % override this to simulate Windows on a Mac.
if isfield(oIn,'snapshot') && oIn.saveSnapshot
    % These are defaults when you enable saveSnapshot.
    o.cropOneImage=0; % Show only the target and noise, without unnecessary gray background.
    o.showCropMarks=0;
    o.eccentricityDeg=inf;
    switch o.signalKind
        case 'luminance',
            tSaveOneImage= -0.0; % log10(sd-1)
            o.noiseSD=0.2;
        case 'noise',
            tSaveOneImage= .3; % log10(sd-1)
            o.noiseSD=0.2;
        case 'entropy',
            tSaveOneImage= 0; % log10(sd-1)
            o.noiseSD=0.5;
            o.noiseSD=0.2;
    end
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
    [screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
    screenRect=Screen('Rect',o.screen); % CAUTION: Gives wrong result on Retina display in HiDPI mode
    if o.useFractionOfScreen
        screenRect=round(o.useFractionOfScreen*screenRect);
    end
    pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
    pixPerDeg=2/0.0633; % As in Pelli et al. (2006).
    degPerCm=pixPerCm/pixPerDeg;
    o.distanceCm=57/degPerCm;
end

% All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
fields=fieldnames(oIn);
for i=1:length(fields)
    field=fields{i};
    o.(field)=oIn.(field);
end

useImresize=exist('imresize','file'); % Requires the Image Processing Toolbox.
cal.screen=o.screen;
if ismac && streq(MacModelName,'MacBookPro12,1')
    cal.dualResRetinaDisplay=1;
else
    cal.dualResRetinaDisplay=0;
end
if cal.screen>0
    fprintf('Using external monitor.\n');
end
if ismac
    cal.macModelName=MacModelName;
else
    cal.macModelName='Not a mac';
end
cal=OurScreenCalibrations(cal);
if ~isfield(cal,'old') || ~isfield(cal.old,'L')
    fprintf('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
    error('This screen has not yet been calibrated. Please use CalibrateScreenLuminance to calibrate it.\n');
end
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',cal.screen);
screenRect=Screen('Rect',cal.screen); % CAUTION: Gives wrong result on Retina display in HiDPI mode
% That's ok here only because we later quit if in HiDPI mode.
if o.useFractionOfScreen
    screenRect=round(o.useFractionOfScreen*screenRect);
end
pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
degPerCm=57/o.distanceCm;
cal.pixPerDeg=pixPerCm/degPerCm;
o.noiseCheckPix=round(o.noiseCheckDeg*cal.pixPerDeg);
o.noiseCheckDeg=o.noiseCheckPix/cal.pixPerDeg;
targetHeightPix=round(o.targetHeightDeg/o.noiseCheckDeg)*o.noiseCheckPix; % round multiple of check size
if o.useFlankers
    flankerSpacingPix=round(o.flankerSpacingDeg*cal.pixPerDeg);
end
% The actual clipping is done using o.stimulusRect. This restriction of
% noiseToTargetRatio is merely to save time (and excessive texture size) by
% not computing pixels that won't be seen. The actual clipping is done
% using o.stimulusRect.
o.noiseToTargetRatio=min(o.noiseToTargetRatio,2*RectWidth(screenRect)/targetHeightPix);
Screen('Preference','TextAntiAliasing',0);
textFont='Verdana';
textSize=round(0.6*cal.pixPerDeg); % 0.6 deg high
o.stimulusRect=InsetRect(screenRect,0,1.5*1.2*textSize);
if streq(o.task,'identify')
    switch o.alphabetPlacement
        case 'right',
            o.stimulusRect(3)=o.stimulusRect(3)-RectHeight(screenRect)/o.alternatives;
        case 'top',
            o.stimulusRect(2)=max(o.stimulusRect(2),screenRect(2)+0.5*RectWidth(screenRect)/o.alternatives);
        otherwise
            warning('Unknown alphabetPlacement "%d".\n',o.alphabetPlacement);
    end
end
o.stimulusRect=round(o.stimulusRect);
fixationWidthPix=round(o.fixationWidthDeg*cal.pixPerDeg);
fixationLineWeightPix=round(o.fixationLineWeightDeg*cal.pixPerDeg);
fixationLineWeightPix=max(1,fixationLineWeightPix);
o.fixationLineWeightDeg=fixationLineWeightPix/cal.pixPerDeg
maxOnscreenFixationOffsetPix=round(RectWidth(o.stimulusRect)/2-20*fixationLineWeightPix); % allowable fixation offset, with 20 linewidth margin.
maxTargetOffsetPix=RectWidth(o.stimulusRect)/2-targetHeightPix/2; % allowable target offset for eccentric viewing.
if o.useFlankers
    maxTargetOffsetPix=maxTargetOffsetPix-o.flankerSpacingDeg*cal.pixPerDeg;
end
maxTargetOffsetPix=floor(maxTargetOffsetPix-max(targetHeightPix/4,0.2*cal.pixPerDeg));
assert(maxTargetOffsetPix>=0);
% The entire screen is is screenRect. The stimulus is in stimulusRect,
% which is contained in screenRect. Every pixel not in stimulusRect is in
% one or more of the caption rects, which form a border on three sides of
% the screen. The caption rects overlap each other.
topCaptionRect=screenRect;
topCaptionRect(4)=o.stimulusRect(2); % top caption (trial number)
bottomCaptionRect=screenRect;
bottomCaptionRect(2)=o.stimulusRect(4); % bottom caption (instructions)
rightCaptionRect=screenRect;
rightCaptionRect(1)=o.stimulusRect(3); % right caption
leftCaptionRect=screenRect;
leftCaptionRect(3)=o.stimulusRect(1); % left caption
% The caption rects are hardly used. It turns out that I typically do a
% FillRect of screenRect with the caption background, and then a
% smaller FillRect of stimulusRect with the stimulus background.

textStyle=0; % plain
newClutForEachImage=1;
window=nan;
switch o.task
    case '4afc'
        idealT64=-.90;
    case 'identify'
        idealT64=-0.30;
end
offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
switch o.observer
    case {'ideal','brightnessSeeker','maximum'}
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
        %         cal.pixPerDeg=pixPerCm/degPerCm;
    otherwise
        if o.measureBeta
            o.trialsPerRun=max(200,o.trialsPerRun);
        end
        if ~isfield(o,'beta') || ~isfinite(o.beta)
            switch o.signalKind
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
%onCleanupInstance=onCleanup(@()sca); % clears screen when function terminated.

o.beginningTime=now;
t=datevec(o.beginningTime);
stack=dbstack;
if length(stack)==1;
    o.functionNames=stack.name;
else
    o.functionNames=[stack(2).name '-' stack(1).name];
end
o.datafilename=sprintf('%s-%s.%d.%d.%d.%d.%d.%d',o.functionNames,o.observer,round(t));
datafullfilename=fullfile(fileparts(mfilename('fullpath')),o.datafilename);
dataFid=fopen([datafullfilename '.txt'],'rt');
if dataFid~=-1
    error('Oops. There''s already a file called "%s.txt". Try again.',datafullfilename);
end
dataFid=fopen([datafullfilename '.txt'],'wt');
assert(dataFid>-1);
ff=[1 dataFid];
fprintf('\nSaving results in:\n');
ffprintf(ff,'%s\n',o.datafilename);
ffprintf(ff,'%s %s\n',o.functionNames,datestr(now));
ffprintf(ff,'observer %s, task %s, alternatives %d,  beta %.1f,\n',o.observer,o.task,o.alternatives,o.beta);
if streq(o.observer,'brightnessSeeker')
    ffprintf(ff,'observerQuadratic %.2f\n',o.observerQuadratic);
end
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',cal.screen);
cal.screenWidthCm=screenWidthMm/10;
screenRect=Screen('Rect',cal.screen);
if o.useFractionOfScreen
    screenRect=round(o.useFractionOfScreen*screenRect);
end
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
    if ~ismember(o.observer,{'ideal','brightnessSeeker','maximum'}) || streq(o.task,'identify')
        % If o.observer is human, We need an open window for the whole
        % experiment, in which to display stimuli. If o.observer is machine,
        % we need a screen only briefly, to create the letters to be
        % identified.
        if o.useFractionOfScreen
            ffprintf(ff,'Using tiny window for debugging.\n');
        end
        if o.flipScreenHorizontally
            PsychImaging('PrepareConfiguration');
            if o.flipScreenHorizontally
                PsychImaging('AddTask','AllViews','FlipHorizontal');
            end
            window=PsychImaging('OpenWindow',cal.screen,255,screenRect,[],[],[],0);
            %[windowPtr,rect]=Screen('OpenWindow',windowPtrOrScreenNumber [,color] [,rect][,pixelSize][,numberOfBuffers][,stereomode][,multisample][,imagingmode][,specialFlags][,clientRect]);
        else
            if o.flipClick; Speak('before OpenWindow 443');GetClicks; end
            window=Screen('OpenWindow',cal.screen,255,screenRect);
            if o.flipClick; Speak('after OpenWindow 443');GetClicks; end
        end
        if exist('cal')
            gray=mean([2 254]);  % Will be a CLUT color code for gray.
            LMin=min(cal.old.L);
            LMax=max(cal.old.L);
            LMean=mean([LMin,LMax]); % Desired background luminance.
            if o.assessLowLuminance
                LMean=0.8*LMin+0.2*LMax;
            end
            if o.isWin
                % Windows insists on a monotonic CLUT. So we linearize
                % practically the whole CLUT, and use the middle entry
                % for gray.
                gray1=gray;
                cal.LFirst=LMin;
                cal.LLast=LMean+(LMean-LMin); % Symmetric about LMean.
                cal.nFirst=2;
                cal.nLast=254;
                cal=LinearizeClut(cal);
                % Set entry 1 to be average of entries 0 and 2.
                cal.gamma(2,:)=(cal.gamma(1,:)+cal.gamma(3,:))/2;
                assert(all(all(diff(cal.gamma)>=0))); % monotonic for Windows
            else
                % Otherwise we have two grays, one in the middle of the
                % CLUT (gray) and one at entry 1 (gray1). The benefit of
                % having gray1==1 is that we get better blending of letters
                % written (as black=0) on that background.
                gray1=1;
                cal.LFirst=LMean;
                cal.LLast=LMean;
                cal.nFirst=gray1;
                cal.nLast=gray1;
                cal=LinearizeClut(cal);
                cal.nFirst=gray;
                cal.nLast=gray;
                cal=LinearizeClut(cal);
            end
%             if o.isWin; assert(all(all(diff(cal.gamma)>=0))); end % monotonic for Windows
            fprintf('LoadNormalizedGammaTable delayed %d\n',484); % just for debugging.
            Screen('LoadNormalizedGammaTable',window,cal.gamma,1); % load during flip
            Screen('FillRect',window,gray1);
            Screen('FillRect',window,gray,o.stimulusRect);
        else
            Screen('FillRect',window);
        end % if cal
        if o.flipClick; Speak('before Flip 481');GetClicks; end
        Screen('Flip',window);
        if o.flipClick; Speak('after Flip 481');GetClicks; end
        if ~isfinite(window) || window==0
            fprintf('error\n');
            error('Screen OpenWindow failed. Please try again.');
        end
        % Detect HiDPI mode (probably occurs on Retina display)
        displayImage=Screen('GetImage',window);
        displayRect=RectOfMatrix(displayImage);
        cal.hiDPIMultiple=RectWidth(displayRect)/RectWidth(screenRect);
        if cal.hiDPIMultiple~=1
            ffprintf(ff,'Your (Retina?) display is in dual-resolution HiDPI mode. Display resolution is %.2fx buffer resolution.\n',cal.hiDPIMultiple);
            ffprintf(ff,'Draw buffer is [%d %d %d %d].\n',screenRect);
            ffprintf(ff,'Display is [%d %d %d %d].\n',displayRect);
            ffprintf(ff,'You can use Switch Res X (http://www.madrau.com/) to select a pure resolution, not HiDPI.');
        end
        black = BlackIndex(window);  % Retrieves the CLUT color code for black.
        white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
        gray=mean([2 254]);  % Will be a CLUT color code for gray.
        Screen('FillRect',window,gray1);
        Screen('FillRect',window,gray,o.stimulusRect);
        if o.flipClick; Speak('before Flip 506');GetClicks; end
        Screen('Flip',window); % Screen is now all gray, at LMean.
        if o.flipClick; Speak('after Flip 506.');GetClicks; end
    else
        window=-1;
    end
    if window >= 0
        screenRect=Screen('Rect',window);
        screenWidthPix=RectWidth(screenRect);
    else
        screenWidthPix=1280;
    end
    pixPerCm=screenWidthPix/cal.screenWidthCm;
    degPerCm=57/o.distanceCm;
    cal.pixPerDeg=pixPerCm/degPerCm;
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
            if o.flipClick; Speak('before Flip 542');GetClicks; end
            Screen('Flip',window);
            if o.flipClick; Speak('after Flip 542');GetClicks; end
            question=[question1 question2 question3];
            Speak(question);
            answer=questdlg(question,'Fixation','Ok','Cancel','Ok');
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
    
    if o.fixationBlankedNearTarget
        ffprintf(ff,'Fixation is blanked near target. No delay in showing fixation after stimulus.\n');
    else
        ffprintf(ff,'Fixation is delayed %.2f s after stimulus. No blanking of fixation lines.\n',o.postStimulusPauseSecs);
    end
    switch o.task
        case 'identify'
            maxHeight=RectHeight(o.stimulusRect);
        case '4afc'
            maxHeight=RectHeight(o.stimulusRect)/(2+o.gapFraction4afc);
            maxHeight=round(maxHeight);
    end
    if targetHeightPix<o.minimumTargetHeightChecks*o.noiseCheckPix
        ffprintf(ff,'Increasing requested targetHeightPix (%d) to %d pix, the minimum.\n',targetHeightPix,o.minimumTargetHeightChecks*o.noiseCheckPix);
        targetHeightPix=o.minimumTargetHeightChecks*o.noiseCheckPix;
    end
    if targetHeightPix>maxHeight
        ffprintf(ff,'Reducing requested targetHeightPix (%d) to %d pix, the max possible.\n',targetHeightPix,maxHeight);
        targetHeightPix=maxHeight;
    end
    gap=o.gapFraction4afc*targetHeightPix;
    targetWidthPix=targetHeightPix;
    targetHeightPix=o.noiseCheckPix*round(targetHeightPix/o.noiseCheckPix);
    targetWidthPix=o.noiseCheckPix*round(targetWidthPix/o.noiseCheckPix);
    if window~=-1
        frameRate=1/Screen('GetFlipInterval',window);
    else
        frameRate=60;
    end
    ffprintf(ff,'Frame rate %.1f Hz.\n',frameRate);
    ffprintf(ff,'pixPerDeg %.1f, o.distanceCm %.1f\n',cal.pixPerDeg,o.distanceCm);
    ffprintf(ff,'Minimum letter resolution is %.0f checks.\n',o.minimumTargetHeightChecks);
    %     ffprintf(ff,'%s font\n',targetFont);
    targetHeightPix=max(targetHeightPix,o.minimumTargetHeightChecks*o.noiseCheckPix);
    ffprintf(ff,'targetHeightPix %.0f, o.noiseCheckPix %.0f, o.durationSec %.2f s\n',targetHeightPix,o.noiseCheckPix,o.durationSec);
    ffprintf(ff,'o.signalKind %s\n',o.signalKind);
    if streq(o.signalKind,'entropy')
        o.noiseType='uniform';
        ffprintf(ff,'o.backgroundEntropyLevels %d\n',o.backgroundEntropyLevels);
    end
    ffprintf(ff,'o.noiseType %s, o.noiseSD %.3f',o.noiseType,o.noiseSD);
    if isfinite(o.outerNoiseSD)
        ffprintf(ff,'o.outerNoiseSD %.3f',o.outerNoiseSD);
    end
    if o.noiseFrozenInTrial
        ffprintf(ff,', frozenInTrial');
    end
    if o.noiseFrozenInRun
        ffprintf(ff,', frozenInRun');
    end
    ffprintf(ff,'\n');
    % We currently limit o.noiseToTargetRatio, to not waste resources on
    % pixels that won't be seen. We could instead limit o.noiseSize. The
    % end result is the same.
    o.noiseSize=o.noiseToTargetRatio*[targetHeightPix/o.noiseCheckPix,targetWidthPix/o.noiseCheckPix];
    o.noiseSize=round(o.noiseSize);
    o.noiseToTargetRatio = o.noiseSize(1)/(targetHeightPix/o.noiseCheckPix);
    %ffprintf(ff,'Ratio of height of noise to that of target is %.2f\n',o.noiseToTargetRatio);
    o.noiseHoleSize=o.noiseHoleToTargetRatio*[targetHeightPix/o.noiseCheckPix,targetWidthPix/o.noiseCheckPix];
    o.noiseHoleSize=round(o.noiseHoleSize);
    o.noiseHoleToTargetRatio = o.noiseHoleSize(1)/(targetHeightPix/o.noiseCheckPix);
    %ffprintf(ff,'Ratio of height of hole in noise to that of target is %.2f\n',o.noiseHoleToTargetRatio);
    ffprintf(ff,'Noise height %.2f deg. Noise hole %.2f deg. Height is %.2f and hole is %.2f of target height.\n',...
        o.noiseToTargetRatio*o.targetHeightDeg,o.noiseHoleToTargetRatio*o.targetHeightDeg,o.noiseToTargetRatio,o.noiseHoleToTargetRatio);
    if o.assessLowLuminance
        ffprintf(ff,'o.assessLowLuminance %d %% check out DAC limits at low end.\n',o.assessLowLuminance);
    end
    if o.useFlankers
        ffprintf(ff,'Adding four flankers at center spacing of %.0f pix = %.1f deg = %.1fx letter height. Dark contrast %.3f (nan means same as target).\n',flankerSpacingPix,flankerSpacingPix/cal.pixPerDeg,flankerSpacingPix/targetHeightPix,o.flankerContrast);
    end
    [x,y]=RectCenter(o.stimulusRect);
    if isfinite(o.eccentricityDeg)
        fixationXY=[x+targetOffsetPix-eccentricityPix,y];
        % clip to o.stimulusRect
        r=OffsetRect(o.stimulusRect,-fixationXY(1),-fixationXY(2));
        
        % horizontal line
        lineStart=-fixationWidthPix/2;
        lineEnd=fixationWidthPix/2;
        lineStart=max(lineStart,r(1)); % clip to o.stimulusRect
        lineEnd=min(lineEnd,r(3)); % clip to o.stimulusRect
        if o.fixationBlankedNearTarget
            blankStart=min(abs(eccentricityPix)*0.5,abs(eccentricityPix)-targetHeightPix);
            blankEnd=max(abs(eccentricityPix)*1.5,abs(eccentricityPix)+targetHeightPix);
        else
            blankStart=lineStart-1;
            blankEnd=blankStart;
        end
        fixationLines=[];
        if blankStart>=lineEnd || blankEnd<=lineStart
            % no overlap of line and blank
            fixationLines(1:2,1:2)=[lineStart lineEnd ;0 0];
        elseif blankStart>lineStart && blankEnd<lineEnd
            % blank breaks the line
            fixationLines(1:2,1:2)=[lineStart blankStart ;0 0];
            fixationLines(1:2,3:4)=[blankEnd lineEnd;0 0];
        elseif blankStart<=lineStart && blankEnd>=lineEnd
            % whole line is blanked
            fixationLines=[0 0;0 0];
        elseif blankStart<=lineStart && blankEnd<lineEnd
            % end of line is not blanked
            fixationLines(1:2,1:2)=[blankEnd lineEnd ;0 0];
        elseif blankStart>lineStart && blankEnd>=lineEnd
            % beginning of line is not blanked
            fixationLines(1:2,1:2)=[lineStart blankStart ;0 0];
        else
            error('impossible fixation line result. line %d %d; blank %d %d',lineStart,lineEnd,blankStart,blankEnd);
        end
        if eccentricityPix<0
            fixationLines=-fixationLines;
        end
        
        % vertical line
        lineStart=-fixationWidthPix/2;
        lineEnd=fixationWidthPix/2;
        lineStart=max(lineStart,r(2)); % clip to o.stimulusRect
        lineEnd=min(lineEnd,r(4)); % clip to o.stimulusRect
        fixationLinesV=[];
        if ~o.fixationBlankedNearTarget || abs(eccentricityPix)>targetHeightPix
            % no blanking of line
            fixationLinesV(1:2,1:2)=[0 0;lineStart lineEnd];
        elseif lineStart<-targetHeightPix
            % blank breaks the line
            fixationLinesV(1:2,1:2)=[0 0; lineStart -targetHeightPix];
            fixationLinesV(1:2,3:4)=[0 0; targetHeightPix lineEnd];
        else
            % whole line is blanked
            fixationLinesV=[0 0;0 0];
        end
        fixationLines=[fixationLines fixationLinesV];
    end
    if window~=-1 && ~isempty(fixationLines)
        Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black,fixationXY); % fixation
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
            clear screen; ShowCursor;
            error('Unknown noiseType ''%s''',o.noiseType);
    end
    
    o.noiseListSd=std(noiseList);
    a=0.9*o.noiseListSd/o.noiseListBound;
    if o.noiseSD>a
        ffprintf(ff,'WARNING: Requested o.noiseSD %.2f too high. Reduced to %.2f\n',o.noiseSD,a);
        o.noiseSD=a;
    end
    if isfinite(o.outerNoiseSD) && o.outerNoiseSD>a
        ffprintf(ff,'WARNING: Requested o.outerNoiseSD %.2f too high. Reduced to %.2f\n',o.outerNoiseSD,a);
        o.outerNoiseSD=a;
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
    checks=(targetHeightPix/o.noiseCheckPix);
    ffprintf(ff,'Target height in checks %.1f\n',checks);
    ffprintf(ff,'%s size %.2f deg, central check size %.3f deg\n',object,2*atand(0.5*targetHeightPix/cal.pixPerDeg*pi/180),2*atand(0.5*o.noiseCheckPix/cal.pixPerDeg*pi/180));
    if streq(o.task,'4afc')
        ffprintf(ff,'o.gapFraction4afc %.2f, gap %.2f deg\n',o.gapFraction4afc,gap/cal.pixPerDeg);
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
    N=o.noiseCheckPix^2*cal.pixPerDeg^-2*o.noiseSD^2;
    ffprintf(ff,'log N/deg^2 %.2f, where N is power spectral density\n',log10(N));
    ffprintf(ff,'pThreshold %.2f, beta %.1f\n',o.pThreshold,o.beta);
    if streq(o.signalKind,'luminance')
        tGuess=-0.5;
        tGuessSd=2;
    else
        tGuess=0;
        tGuessSd=4;
    end
    ffprintf(ff,'Your (log) guess is %.2f ± %.2f\n',tGuess,tGuessSd);
    ffprintf(ff,'o.trialsPerRun %.0f\n',o.trialsPerRun);
    
    switch o.task
        case '4afc'
            boundsRect=[-targetWidthPix,-targetHeightPix,targetWidthPix+gap,targetHeightPix+gap];
            boundsRect=CenterRect(boundsRect,scratchRect);
            boundsRect=OffsetRect(boundsRect,targetOffsetPix,0);
        case 'identify',
            [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window,[],[0 0 400 400]);
            oldFont=Screen('TextFont',scratchWindow,'Sloan');
            font=Screen('TextFont',scratchWindow);
            assert(streq(font,'Sloan'));
            oldSize=Screen('TextSize',scratchWindow,round(targetHeightPix/o.noiseCheckPix));
            oldStyle=Screen('TextStyle',scratchWindow,0);
            for i=1:o.alternatives
                white1=1;
                black0=0;
                Screen('FillRect',scratchWindow,white1);
                rect=[0 0 o.noiseSize(1) o.noiseSize(2)];
                rect=CenterRect(rect,scratchRect);
                targetRect=round(rect/o.noiseToTargetRatio);
                targetRect=CenterRect(targetRect,rect);
                Screen('DrawText',scratchWindow,signal(i).letter,targetRect(1),targetRect(4),black0,white1,1);
                letter=Screen('GetImage',scratchWindow,targetRect,'drawBuffer');
                Screen('FillRect',scratchWindow);
                letter=letter(:,:,1);
                if o.flipScreenHorizontally
                    letter=fliplr(letter);
                end
                signal(i).image=letter<(white1+black0)/2;
            end
            %             Screen('TextFont',scratchWindow,oldFont);
            %             Screen('TextSize',scratchWindow,oldSize);
            %             Screen('TextStyle',scratchWindow,oldStyle);
            Screen('Close',scratchWindow);
            scratchWindow=-1;
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
            rect=[0,0,targetWidthPix,targetHeightPix];
            rect=CenterRect(rect,scratchRect);
            targetRect=rect;
            rect=OffsetRect(rect,targetOffsetPix,0);
            boundsRect=rect;
            
            % Compute noise hole mask
            noiseHoleMask=zeros(o.noiseSize);
            rect=RectOfMatrix(noiseHoleMask);
            holeRect=[0 0 o.noiseHoleSize(1) o.noiseHoleSize(2)];
            holeRect=round(CenterRect(holeRect,rect));
            noiseHoleMask=FillRectInMatrix(1,holeRect,noiseHoleMask);
            if o.noiseHoleSparesTargetArea
                r=CenterRect(targetRect/o.noiseCheckPix,rect);
                noiseHoleMask=FillRectInMatrix(0,r,noiseHoleMask);
            end
            noiseHoleMask=logical(noiseHoleMask);
            
            % Compute outer noise mask (all the noise beyond the hole).
            outerNoiseMask=ones(o.noiseSize);
            outerNoiseMask=FillRectInMatrix(0,holeRect,outerNoiseMask);
            outerNoiseMask=logical(outerNoiseMask);
    end
    
    power=1:length(signal);
    for i=1:length(power)
        power(i)=sum(signal(i).image(:));
        ok=ismember(unique(signal(i).image(:)),[0 1]);
        assert(all(ok));
    end
    E1=mean(power)*(o.noiseCheckPix/cal.pixPerDeg)^2;
    ffprintf(ff,'log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',log10(E1));
    if ismember(o.observer,{'ideal','brightnessSeeker','maximum'});
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
    % for o.runNumber=1:o.runsDesired
    if ~ismember(o.observer,{'ideal','brightnessSeeker','maximum'}) && ~o.saveSnapshot;
        Screen('FillRect',window,gray1);
        Screen('FillRect',window,gray,o.stimulusRect);
        if o.showCropMarks
            TrimMarks(window,frameRect);
        end
        Screen('DrawLines',window,fixationLines,fixationLineWeightPix,0,fixationXY); % fixation
        if o.flipClick; Speak('before LoadNormalizedGammaTable delayed 911');GetClicks; end
        if o.isWin; assert(all(all(diff(cal.gamma)>=0))); end; % monotonic for Windows
        fprintf('LoadNormalizedGammaTable delayed %d\n',916); % just for debugging.
        Screen('LoadNormalizedGammaTable',window,cal.gamma,1); % Wait for Flip.
        if assessGray; pp=Screen('GetImage',window,[20 20 21 21]);ffprintf(ff,'line 712: Gray index is %d (%.1f cd/m^2). Corner is %d.\n',gray,LuminanceOfIndex(cal,gray),pp(1)); end
        if o.flipClick; Speak('before Flip 911');GetClicks; end
        Screen('Flip', window); % Show gray screen at LMean with fixation and crop marks.
        if o.flipClick; Speak('after Flip 911');GetClicks; end
        
        Speak('Starting new run. ');
        if isfinite(o.eccentricityDeg)
            if fixationIsOffscreen
                Speak('Please fihx your eyes on your offscreen fixation mark,');
            else
                if ismac
                    Speak('Please fihx your eyes on the center of the cross,');
                else
                    Speak('Please fix your eyes on the center of the cross,');
                end
            end
            word='and';
        else
            word='Please';
        end
        switch o.task
            case '4afc',
                Speak([word ' click when ready to begin']);
            case 'identify',
                if ismac
                    Speak([word ' press  the  spasebar  when ready to begin']);
                else
                    Speak([word ' press  the  space bar  when ready to begin']);
                end
        end
        switch o.task
            case '4afc',
                GetClicks;
            case 'identify',
                FlushEvents; % flush. May not be needed.
                ListenChar(0); % flush. May not be needed.
                ListenChar(2); % no echo. Needed.
                GetChar;
                ListenChar; % normal. Needed.
        end
    end
    delta=0.01;
    switch o.task
        case '4afc',
            gamma=1/4;
        case 'identify',
            gamma=1/o.alternatives;
    end
    switch o.thresholdParameter
        case 'spacing'
            tGuess=log10(o.eccentricityDeg/2);
        case 'size'
            tGuess=log10(0.2);
        case 'contrast'
    end
    q=QuestCreate(tGuess,tGuessSd,o.pThreshold,o.beta,delta,gamma);
    q.normalizePdf=1; % adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    wrongRight={'wrong','right'};
    timeZero=GetSecs;
    trialsRight=0;
    sigmaWarningCount=0;
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
        switch o.thresholdParameter
            case 'spacing',
                spacingDeg=10^tTest;
                flankerSpacingPix=spacingDeg*cal.pixPerDeg;
                flankerSpacingPix=max(flankerSpacingPix,1.2*targetHeightPix);
                fprintf('flankerSpacingPix %d\n',flankerSpacingPix);
            case 'size',
                targetSizeDeg=10^tTest;
                targetHeightPix=targetSizeDeg*cal.pixPerDeg;
                targetWidthPix=targetHeightPix;
            case 'contrast',
                if streq(o.signalKind,'luminance')
                    sigma=1;
                    o.contrast=-10^tTest; % negative contrast, dark letters
                else
                    sigma=1+10^tTest;
                    o.contrast=0;
                end
        end
        if o.saveSnapshot
            tTest=tSaveOneImage;
        end
        a=(1-LMin/LMean)*o.noiseListSd/o.noiseListBound;
        if o.noiseSD>a
            ffprintf(ff,'WARNING: Reducing o.noiseSD of %s noise to %.2f to avoid overflow.\n',o.noiseType,a);
            o.noiseSD=a;
        end
        if isfinite(o.outerNoiseSD) && o.outerNoiseSD>a
            ffprintf(ff,'WARNING: Reducing o.outerNoiseSD of %s noise to %.2f to avoid overflow.\n',o.noiseType,a);
            o.outerNoiseSD=a;
        end
        switch o.signalKind
            case 'noise',
                a=(1-LMin/LMean)/(o.noiseListBound*o.noiseSD/o.noiseListSd);
                if sigma>a
                    sigma=a;
                    if ~exist('sigmaWarningCount','var') || sigmaWarningCount==0
                        ffprintf(ff,'WARNING: Limiting sigma ratio of %s noises to upper bound %.2f to stay within luminance range.\n',o.noiseType,sigma);
                    end
                    sigmaWarningCount=sigmaWarningCount+1;
                end
                tTest=log10(sigma-1);
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
                if sigma>a
                    sigma=a;
                    if ~exist('sigmaWarningCount','var') || sigmaWarningCount==0
                        ffprintf(ff,'WARNING: Limiting entropy of %s noise to upper bound %.1f bits.\n',o.noiseType,log2(sigma));
                    end
                    sigmaWarningCount=sigmaWarningCount+1;
                end
                signalEntropyLevels=round(sigma*o.backgroundEntropyLevels);
                sigma=signalEntropyLevels/o.backgroundEntropyLevels; % define sigma as ratio of number of levels
                tTest=log10(sigma-1);
        end
        if o.noiseFrozenInRun
            if trial==1
                generator=rng;
                o.noiseListSeed=generator.Seed;
            end
            rng(o.noiseListSeed);
        end
        switch o.task
            case '4afc'
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
                    noise=PsychRandSample(noiseList,o.noiseSize);
                    if o.noiseHoleToTargetRatio>0
                        noise(noiseHoleMask)=0;
                    end
                    if i==signalLocation
                        switch o.signalKind
                            case 'noise',
                                location(i).image=1+sigma*(o.noiseSD/o.noiseListSd)*noise;
                            case 'luminance',
                                location(i).image=1+(o.noiseSD/o.noiseListSd)*noise+o.contrast;
                            case 'entropy',
                                q.noiseList=(0.5+floor(noiseList*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                                q.sd=std(q.noiseList);
                                location(i).image=1+(o.noiseSD/q.sd)*(0.5+floor(noise*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                        end
                    else
                        switch o.signalKind
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
                noise=PsychRandSample(noiseList,o.noiseSize);
                if o.noiseHoleToTargetRatio>0
                    noise(noiseHoleMask)=0;
                end
                signalImage=zeros(size(noise));
                nRect=RectOfMatrix(noise);
                sRect=RectOfMatrix(signal(1).image);
                r=CenterRect(sRect,nRect);
                signalImageIndex=logical(zeros(size(noise)));
                signalImageIndex(1+r(2):r(4),1+r(1):r(3))=true;
                signalImage(signalImageIndex)=signal(whichSignal).image;
                mask=logical(signalImage);
                switch o.signalKind
                    case 'noise'
                        noise(mask)=sigma*noise(mask);
                        location(1).image=1+(o.noiseSD/o.noiseListSd)*noise;
                    case 'luminance',
                        location(1).image=1+(o.noiseSD/o.noiseListSd)*noise;
                        if isfinite(o.outerNoiseSD)
                            location(1).image(outerNoiseMask)=1+(o.outerNoiseSD/o.noiseListSd)*noise(outerNoiseMask);
                        end
                        location(1).image=location(1).image+o.contrast*signalImage;
                    case 'entropy',
                        noise(mask)=(0.5+floor(noise(mask)*0.499999*signalEntropyLevels))/(0.5*signalEntropyLevels);
                        noise(~mask)=(0.5+floor(noise(~mask)*0.499999*o.backgroundEntropyLevels))/(0.5*o.backgroundEntropyLevels);
                        location(1).image=1+(o.noiseSD/o.noiseListSd)*noise;
                end
        end
        switch o.observer
            case 'ideal'
                clear likely
                switch o.task
                    case '4afc',
                        switch o.signalKind
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
                                end
                        end
                    case 'identify',
                        switch o.signalKind
                            case 'luminance',
                                for i=1:o.alternatives
                                    im=zeros(size(signal(i).image));
                                    im(:)=location(1).image(signalImageIndex);
                                    d=im-1-o.contrast*signal(i).image;
                                    likely(i)=-sum(d(:).^2);
                                end
                            otherwise
                                % calculate log likelihood of each possible letter
                                sdPaper=o.noiseSD;
                                sdInk=sigma*o.noiseSD;
                                for i=1:o.alternatives
                                    mask=signal(i).image;
                                    im=zeros(size(signal(i).image));
                                    im(:)=location(1).image(signalImageIndex);
                                    ink=im(mask)-1;
                                    paper=im(~mask)-1;
                                    likely(i)=-length(ink)*log(sdInk*sqrt(2*pi))-sum(0.5*(ink/sdInk).^2);
                                    likely(i)=likely(i)-length(paper)*log(sdPaper*sqrt(2*pi))-sum(0.5*(paper/sdPaper).^2);
                                end
                        end
                end
                [junk,response]=max(likely);
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
                            mask=signal(i).image;
                            im=location(1).image(signalImageIndex);
                            im=im(:)-1;
                            % Set o.observerQuadratic  to 0 for linear. 1 for square law. 0.2 for
                            % 0.8 linear and 0.2 square.
                            brightness=im+o.observerQuadratic*im.^2;
                            ink=brightness(mask);
                            paper=brightness(~mask);
                            likely(i)=sign(o.observerQuadratic)*(mean(ink(:))-mean(paper(:)));
                        end
                end
                [junk,response]=max(likely);
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
                        % Rank hypotheses by brightness contrast of
                        % supposed letter to background.
                        for i=1:o.alternatives
                            mask=signal(i).image;
                            im=zeros(size(signal(i).image));
                            im(:)=location(1).image(signalImageIndex);
                            im=im(:)-1;
                            % Set o.observerQuadratic  to 0 for linear. 1 for square law. 0.2 for
                            % 0.8 linear and 0.2 square.
                            brightness=im+o.observerQuadratic*im.^2;
                            ink=brightness(mask);
                            paper=brightness(~mask);
                            likely(i)=sign(o.observerQuadratic)*(mean(ink(:))-mean(paper(:)));
                        end
                end
                [junk,response]=max(likely);
            otherwise % human o.observer
                Screen('FillRect',window,gray1);
                Screen('FillRect',window,gray,o.stimulusRect);
                Screen('DrawLines',window,fixationLines,fixationLineWeightPix,0,fixationXY); % fixation
                rect=[0,0,targetWidthPix,targetHeightPix]*o.noiseToTargetRatio;
                if newClutForEachImage
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
                    cal.LFirst=LMean*(1-o.noiseListBound*sigma*o.noiseSD/o.noiseListSd);
                    cal.LLast=LMean*(1+o.noiseListBound*sigma*o.noiseSD/o.noiseListSd);
                    if streq(o.signalKind,'luminance')
                        cal.LFirst=cal.LFirst+min(0,LMean*o.contrast);
                        cal.LLast=cal.LLast+max(0,LMean*o.contrast);
                    end
                    if o.useFlankers && isfinite(o.flankerContrast)
                        cal.LFirst=min(cal.LFirst,LMean*(1+o.flankerContrast));
                        cal.LLast=max(cal.LLast,LMean*(1+o.flankerContrast));
                    end
                    % Center the range on LMean.
                    delta=max(cal.LLast-LMean,LMean-cal.LFirst);
                    maxDelta=min(max(cal.old.L)-LMean,LMean-min(cal.old.L));
                    cal.LFirst=LMean-delta;
                    cal.LLast=LMean+delta;
                    if o.saveSnapshot
                        cal.LFirst=min(cal.old.L);
                        cal.LLast=max(cal.old.L);
                    end
                    cal.nFirst=2;
                    cal.nLast=254;
                    cal=LinearizeClut(cal);
                    if o.isWin
                        ok=0;
                        while ~ok
                            try
                                cal.gamma(2,:)=0.5*(cal.gamma(1,:)+cal.gamma(3,:));
                                assert(all(all(diff(cal.gamma)>=0))); % monotonic for Windows
                                fprintf('LoadNormalizedGammaTable test %d\n',1294); % just for debugging.
                                Screen('LoadNormalizedGammaTable',window,cal.gamma); % might fail
                                ok=1;
                            catch
                                if delta==maxDelta
                                    error('Couldn''t fix the gamma table. Alas. delta=%.1f cd/m^2',delta);
                                end
                                delta=min(maxDelta,delta+LMean*0.02);
                                cal.LFirst=LMean-delta;
                                cal.LLast=LMean+delta;
                                cal=LinearizeClut(cal);
                            end
                        end
                    end
                    grayCheck=IndexOfLuminance(cal,LMean);
                    if ~o.saveSnapshot && grayCheck~=gray
                        ffprintf(ff,'The estimated gray index is %d (%.1f cd/m^2), not %d (%.1f cd/m^2).\n',grayCheck,LuminanceOfIndex(cal,grayCheck),gray,LuminanceOfIndex(cal,gray));
                        warning('The gray index changed!');
                    end
                    assert(isfinite(gray));
                end
                if o.assessContrast
                    % Estimate actual contrast on screen.
                    img=1;
                    img=IndexOfLuminance(cal,img*LMean);
                    img=img:255;
                    L=EstimateLuminance(cal,img);
                    dL=diff(L);
                    i=find(dL,1);
                    if isfinite(i)
                        contrastEstimate=dL(i)/L(i);
                    else
                        contrastEstimate=nan;
                    end
                    switch o.signalKind
                        case 'luminance',
                            img=[1 1+o.contrast];
                        otherwise
                            noise=PsychRandSample(noiseList,o.noiseSize);
                            img=1+noise*o.noiseSD/o.noiseListSd;
                    end
                    index=IndexOfLuminance(cal,img*LMean);
                    imgEstimate=EstimateLuminance(cal,index)/LMean;
                    rmsContrastError=rms(img(:)-imgEstimate(:));
                    ffprintf(ff,'Min contrast %.4f, rmsContrastError %.3f, ',contrastEstimate,rmsContrastError);
                    switch o.signalKind
                        case 'luminance',
                            img=[1,1+o.contrast];
                            img=IndexOfLuminance(cal,img*LMean);
                            L=EstimateLuminance(cal,img);
                            ffprintf(ff,'contrastEstimate %.3f (nom. %.3f)\n', diff(L)/L(1),o.contrast);
                        otherwise
                            noiseSDEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:));
                            img=1+sigma*(o.noiseSD/o.noiseListSd)*noise;
                            img=IndexOfLuminance(cal,img*LMean);
                            imgEstimate=EstimateLuminance(cal,img)/LMean;
                            sigmaEstimate=std(imgEstimate(:))*o.noiseListSd/std(noise(:))/noiseSDEstimate;
                            ffprintf(ff,'noiseSDEstimate %.3f (nom. %.3f), sigmaEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,sigmaEstimate,sigma);
                            if abs(log10([noiseSDEstimate/o.noiseSD sigmaEstimate/sigma]))>0.5*log10(2)
                                ffprintf(ff,'WARNING: PLEASE TELL DENIS: noiseSDEstimate %.3f (nom. %.3f), sigmaEstimate %.3f (nom. %.3f)\n',noiseSDEstimate,o.noiseSD,sigmaEstimate,sigma);
                            end
                    end
                end
                if o.showCropMarks
                    TrimMarks(window,frameRect); % this should be moved down, to be drawn AFTER the noise.
                end
                switch o.task
                    case 'identify'
                        locations=1;
                        rect=CenterRect(rect,o.stimulusRect);
                        rect=OffsetRect(rect,targetOffsetPix,0);
                        rect=round(rect);
                        location(1).rect=rect;
                        % Convert to integer pixels.
                        img=location(1).image;
                        % ffprintf(ff,'o.noiseSD %.1f, contrast %.2f, image max %.2f, min %.2f, clut min %.2f, max %.2f\n',o.noiseSD,o.contrast,max(img(:)),min(img(:)),cal.LFirst/LMean,cal.LLast/LMean);
                        img=IndexOfLuminance(cal,img*LMean);
                        img=Expand(img,o.noiseCheckPix);
                        if o.assessLinearity
                            gratingL=LMean*repmat([0.2 1.8],400,200);
                            gratingImg=IndexOfLuminance(cal,gratingL);
                            texture=Screen('MakeTexture',window,uint8(gratingImg));
                            r=RectOfMatrix(gratingImg);
                            r=CenterRect(r,rect);
                            Screen('DrawTexture',window,texture,RectOfMatrix(gratingImg),r);
                            peekImg=Screen('GetImage',window,InsetRect(r,-1,-1),'drawBuffer');
                            peekImg=peekImg(:,:,2);
                            figure(1);
                            subplot(2,2,1);imshow(uint8(gratingImg));
                            subplot(2,2,2);imshow(peekImg);
                            subplot(2,2,3);imshow(uint8(gratingImg(1:4,1:4)));
                            subplot(2,2,4);imshow(peekImg(1:4,1:4));
                            Screen('Close',texture);
                            gratingImg(1:4,1:4)
                            peekImg(1:4,1:4)
                            LuminanceOfIndex(cal,peekImg(1:4,1:4))
                        end
                        texture=Screen('MakeTexture',window,uint8(img));
                        srcRect=RectOfMatrix(img);
                        dstRect=rect;
                        offset=dstRect(1:2)-srcRect(1:2);
                        dstRect=ClipRect(dstRect,o.stimulusRect);
                        srcRect=OffsetRect(dstRect,-offset(1),-offset(2));
                        Screen('DrawTexture',window,texture,srcRect,dstRect);
                        %                             peekImg=Screen('GetImage',window,InsetRect(rect,-1,-1),'drawBuffer');
                        %                             imshow(peekImg);
                        eraseRect=dstRect;
                        Screen('Close',texture);
                        rect=CenterRect(rect/o.noiseToTargetRatio,rect);
                        rect=round(rect);
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
                        end
                    case '4afc'
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
                            % Label the o.alternatives 1 to 4.
                            r=[0 0 6 targetHeightPix];
                            labelBounds=InsetRect(boundsRect,-1.5*textSize,-3.1*textSize);
                            location(1).labelRect=AlignRect(r,labelBounds,'left','top');
                            location(2).labelRect=AlignRect(r,labelBounds,'right','top');
                            location(3).labelRect=AlignRect(r,labelBounds,'left','bottom');
                            location(4).labelRect=AlignRect(r,labelBounds,'right','bottom');
                            for i=1:locations
                                [x,y]=RectCenter(location(i).labelRect);
                                Screen('DrawText',window,sprintf('%d',i),x-10,y+10,black,0,1);
                            end
                        end
                end
                eraseRect=ClipRect(eraseRect,o.stimulusRect);
                Screen('FillRect',window,gray1,topCaptionRect);
                message=sprintf('Trial %d of %d. Run %d of %d.',trial,o.trialsPerRun,o.runNumber,o.runsDesired);
                Screen('DrawText',window,message,textSize/2,textSize/2,black);
                
                % Print instructions in lower left corner.
                textRect=[0,0,100,1.2*textSize];
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
                Screen('DrawText',window,message,textRect(1),textRect(4),black,0,1);
                Screen('TextSize',window,textSize);
                
                % Display response alternatives.
                switch o.task
                    case '4afc',
                        leftEdgeOfResponse=screenRect(3);
                    case 'identify'
                        % Draw the response o.alternatives
                        switch o.alphabetPlacement
                            case 'right',
                                desiredLengthPix=RectHeight(screenRect);
                                signalPix=RectHeight(rect);
                            case 'top',
                                desiredLengthPix=0.5*RectWidth(screenRect);
                                signalPix=RectWidth(rect);
                        end
                        rect=[0 0 targetWidthPix targetHeightPix]/o.noiseCheckPix; % size of signal(1).image
                        spacingFraction=0.25;
                        alphaSpaces=o.alternatives+spacingFraction*(o.alternatives+1);
                        alphaPix=desiredLengthPix/alphaSpaces;
                        alphaCheckPix=alphaPix/(signalPix/o.noiseCheckPix);
                        alphaGapPixCeil=(desiredLengthPix-o.alternatives*ceil(alphaCheckPix)*signalPix/o.noiseCheckPix)/(o.alternatives+1);
                        alphaGapPixFloor=(desiredLengthPix-o.alternatives*floor(alphaCheckPix)*signalPix/o.noiseCheckPix)/(o.alternatives+1);
                        ceilError=log(alphaGapPixCeil/(ceil(alphaCheckPix)*signalPix/o.noiseCheckPix))-log(spacingFraction);
                        floorError=log(alphaGapPixFloor/(floor(alphaCheckPix)*signalPix/o.noiseCheckPix))-log(spacingFraction);
                        if min(abs(ceilError),abs(floorError))<log(3)
                            if abs(floorError)<abs(ceilError)
                                alphaCheckPix=floor(alphaCheckPix);
                            else
                                alphaCheckPix=ceil(alphaCheckPix);
                            end
                        end
                        alphaGapPix=(desiredLengthPix-o.alternatives*signalPix*alphaCheckPix/o.noiseCheckPix)/(o.alternatives+1);
                        useExpand = alphaCheckPix==round(alphaCheckPix);
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
                                    % we don't need it, because the image
                                    % resizing can be done by the
                                    % DrawTexture command below.
                                end
                            end
                            texture=Screen('MakeTexture',window,(1-img)*gray);
                            Screen('DrawTexture',window,texture,RectOfMatrix(img),rect);
                            Screen('Close',texture);
                            rect=OffsetRect(rect,step(1),step(2));
                        end
                        leftEdgeOfResponse=rect(1);
                end
                if o.isWin
%                     cal.gamma(2,:)=0.5*(cal.gamma(1,:)+cal.gamma(3,:));
%                     cal.gamma(255,:)=0.5*(cal.gamma(254,:)+cal.gamma(256,:));
%                     assert(all(all(diff(cal.gamma)>0))); % monotonic for Windows
%                     fprintf('cal.gamma=[');
%                     fprintf('%g ',cal.gamma(:,1)); fprintf(';');
%                     fprintf('%g ',cal.gamma(:,2)); fprintf(';');
%                     fprintf('%g ',cal.gamma(:,3)); fprintf(']'';');
%                     cal.gamma=[0:255;0:255;0:255]'/255;
                end
                if o.flipClick; Speak('before LoadNormalizedGammaTable 1538');GetClicks; end
                fprintf('LoadNormalizedGammaTable %d\n',1564); % just for debugging.
                Screen('LoadNormalizedGammaTable',window,cal.gamma);
                if assessGray; pp=Screen('GetImage',window,[20 20 21 21]);ffprintf(ff,'line 1264: Gray index is %d (%.1f cd/m^2). Corner is %d.\n',gray,LuminanceOfIndex(cal,gray),pp(1)); end
                if trial==1
                    WaitSecs(1); % First time is slow. Mario suggested a work around, explained at beginning of this file.
                end
                if o.flipClick; Speak('before Flip dontclear 1545');GetClicks; end
                Snd('Play',purr); % Announce that image is up, awaiting response.
                Screen('Flip',window,0,1); % Show target with instructions.
                signalOnset=GetSecs;
                if o.flipClick; Speak('after Flip dontclear 1545');GetClicks; end
                if o.saveSnapshot
                    if o.cropOneImage
                        cropRect=location(1).rect;
                        if streq(o.task,'4afc')
                            for i=2:4
                                cropRect=UnionRect(cropRect,location(i).rect);
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
                        saveSize=Screen('TextSize',window,textSize*.4);
                        saveFont=Screen('TextFont',window,'Courier');
                        for i=1:4
                            s=[sprintf('L%d',i) sprintf(' %4.2f',x(i).L)];
                            Screen('DrawText',window,s,rect(1),rect(2)-360-(5-i)*30);
                        end
                        for i=1:4
                            s=[sprintf('p%d',i) sprintf(' %4.2f',x(i).p)];
                            Screen('DrawText',window,s,rect(1),rect(2)-240-(5-i)*30);
                        end
                        Screen('TextSize',window,textSize*.8);
                        Screen('DrawText',window,sprintf('Mean %4.2f %4.2f %4.2f %4.2f',x(:).mean),rect(1),rect(2)-240);
                        Screen('DrawText',window,sprintf('Sd   %4.2f %4.2f %4.2f %4.2f',x(:).sd),rect(1),rect(2)-210);
                        Screen('DrawText',window,sprintf('Max  %4.2f %4.2f %4.2f %4.2f',x(:).max),rect(1),rect(2)-180);
                        Screen('DrawText',window,sprintf('Min  %4.2f %4.2f %4.2f %4.2f',x(:).min),rect(1),rect(2)-150);
                        Screen('DrawText',window,sprintf('Bits %4.2f %4.2f %4.2f %4.2f',x(:).entropy),rect(1),rect(2)-120);
                        Screen('TextSize',window,saveSize);
                        Screen('TextFont',window,saveFont);
                    end
                    switch o.signalKind
                        case 'luminance',
                            Screen('DrawText',window,sprintf('signal %.3f',10^tTest),rect(1),rect(2)-90);
                            Screen('DrawText',window,sprintf('noise sd %.3f',o.noiseSD),rect(1),rect(2)-60);
                        case 'entropy',
                            Screen('DrawText',window,sprintf('ratio # lum. %.3f',1+10^tTest),rect(1),rect(2)-90);
                            Screen('DrawText',window,sprintf('noise sd %.3f',o.noiseSD),rect(1),rect(2)-60);
                        otherwise
                            Screen('DrawText',window,sprintf('sd ratio %.3f',1+10^tTest),rect(1),rect(2)-90);
                            Screen('DrawText',window,sprintf('approx required n %.0f',approxRequiredN),rect(1),rect(2)-60);
                    end
                    Screen('DrawText',window,sprintf('n %.0f',checks),rect(1),rect(2)-30);
                    switch o.task
                        case '4afc',
                            answer=signalLocation;
                            answerString=sprintf('%d',answer);
                        case 'identify',
                            answer=whichSignal;
                            answerString=o.alphabet(answer);
                    end
                    Screen('DrawText',window,sprintf('xyz%s',lower(answerString)),rect(1),rect(2)+0);
                    Screen('DrawLines',window,fixationLines,fixationLineWeightPix,0,fixationXY); % fixation
                    Screen('Flip', window,0,1); % Save image for snapshot. Show target, instructions, and fixation.
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
                    switch o.signalKind
                        case 'entropy'
                            signalDescription=sprintf('%s_%dv%dlevels',o.signalKind,signalEntropyLevels,o.backgroundEntropyLevels);
                        otherwise
                            signalDescription=sprintf('%s',o.signalKind);
                    end
                    filename=sprintf('%s_%s_%s%s_%.3fsigma_%.0fpix_%.0freq_%s',signalDescription,o.task,o.noiseType,freezing,1+10^tTest,checks,approxRequiredN,answerString);
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
                    ffprintf(ff,'approx required n %.0f, sd ratio %.3f, log(sd-1) %.2f\n',approxRequiredN,1+10^tTest,tTest);
                    o.trialsPerRun=1;
                    o.runsDesired=1;
                    throw(MException('o.saveSnapshot:Done','SUCCESS: Image saved, now returning.'));
                end
                if isfinite(o.durationSec)
                    Screen('FillRect',window,gray,eraseRect);
                    if o.flipClick; Speak('before Flip dontclear 1665');GetClicks; end
                    Screen('Flip',window,signalOnset+o.durationSec-1/frameRate,1); % Duration is over. Erase target.
                    if o.flipClick; Speak('after Flip dontclear 1665');GetClicks; end
                    signalOffset=GetSecs;
                    actualDuration=GetSecs-signalOnset;
                    if abs(actualDuration-o.durationSec)>0.05
                        ffprintf(ff,'WARNING: Duration requested %.2f, actual %.2f\n',o.durationSec,actualDuration);
                    else
                        if o.printSignalDuration
                            ffprintf(ff,'Duration requested %.2f, actual %.2f\n',o.durationSec,actualDuration);
                        end
                    end
                    if ~o.fixationBlankedNearTarget
                        WaitSecs(o.postStimulusPauseSecs);
                    end
                    Screen('DrawLines',window,fixationLines,fixationLineWeightPix,0,fixationXY); % fixation
                    if o.flipClick; Speak('before Flip dontclear 1681');GetClicks; end
                    Screen('Flip',window,signalOffset+0.3,1,1); % After o.postStimulusPauseSecs, display new fixation.
                    if o.flipClick; Speak('after Flip dontclear 1681');GetClicks; end
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
                        FlushEvents('keyDown');
                        response=0;
                        while ~ismember(response,1:o.alternatives)
                            o.runAborted=0;
                            ListenChar(0); % flush
                            ListenChar(2); % no echo
                            response=GetChar;
                            ListenChar(0); % flush
                            ListenChar; % normal
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
        if ~ismember(o.observer,{'ideal','brightnessSeeker','maximum'})
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
                spacingDeg=flankerSpacingPix/cal.pixPerDeg;
                tTest=log10(spacingDeg);
            case 'size'
                %                     results(n,1)=targetSizeDeg;
                %                     results(n,2)=response;
                %                     n=n+1;
                targetSizeDeg=targetHeightPix/cal.pixPerDeg;
                tTest=log10(targetSizeDeg);
            case 'contrast'
                %                     results(n,1)=10^tTest;
                %                     results(n,2)=response;
                %                     n=n+1;
        end
        trialsRight=trialsRight+response;
        q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and o.observer response) to the database.
        if cal.ScreenConfigureDisplayBrightnessWorks
            %Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
            cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
            if abs(cal.brightnessSetting-cal.brightnessReading)>0.01
                fprintf('Screen brightness was set to %.0f%%, but now reads as %.0f%%.\n',100*cal.brightnessSetting,100*cal.brightnessReading);
                sca;
                Speak('Error. The screen brightness changed. In System Preferences Displays please turn off "Automatically adjust brightness".');
                error('Screen brighness changed. Please disable System Preferences:Displays:"Automatically adjust brightness".');
            end
        end
    end
    o.questMean=QuestMean(q);
    o.questSd=QuestSd(q);
    t=QuestMean(q); % Used in printouts below.
    sd=QuestSd(q); % Used in printouts below.
    approxRequiredN=64/10^((o.questMean-idealT64)/0.55);
    o.p=trialsRight/trial;
    o.trials=trial;
    switch o.thresholdParameter
        case 'spacing',
            fprintf('%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',o.observer,100*o.p,targetSizeDeg,o.eccentricityDeg,10^QuestMean(q));
        case 'size',
            fprintf('%s: p %.0f%%, ecc. %.1f deg, threshold size %.3f deg.\n',o.observer,100*o.p,o.eccentricityDeg,10^QuestMean(q));
        case 'contrast',
    end
    o.contrast=-10^o.questMean;
    o.EOverN=10^(2*o.questMean)*E1/N;
    o.efficiency = o.idealEOverNThreshold/o.EOverN;
    if streq(o.signalKind,'luminance')
        ffprintf(ff,'Run %4d of %d.  %d trials. %.0f%% right. %.3f s/trial. Threshold±sd log(contrast) %.2f±%.2f, contrast %.5f, log E/N %.2f, efficiency %.5f\n',o.runNumber,o.runsDesired,trial,100*trialsRight/trial,(GetSecs-runStart)/trial,t,sd,10^t,log10(o.EOverN),o.efficiency);
    else
        ffprintf(ff,'Run %4d of %d.  %d trials. %.0f%% right. %.3f s/trial. Threshold±sd log(sigma-1) %.2f±%.2f, approx required n %.0f\n',o.runNumber,o.runsDesired,trial,100*trialsRight/trial,(GetSecs-runStart)/trial,t,sd,approxRequiredN);
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
        fprintf('dt    P\n');
        tt=QuestMean(qq);
        for offset=sort(offsetToMeasureBeta)
            t=tt+offset;
            fprintf('%5.2f %.2f\n',offset,QuestP(qq,offset));
        end
    end
    % end
    
    %     t=mean(tSample);
    %     tse=std(tSample)/sqrt(length(tSample));
    %     switch o.signalKind
    %         case 'luminance',
    %         ffprintf(ff,'SUMMARY: %s %d runs mean±se: log(contrast) %.2f±%.2f, contrast %.3f\n',o.observer,length(tSample),mean(tSample),tse,10^mean(tSample));
    %         %         efficiency = (o.idealEOverNThreshold^2) / (10^(2*t));
    %         %         ffprintf(ff,'Efficiency = %f\n', efficiency);
    %         %o.EOverN=10^mean(2*tSample)*E1/N;
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
    switch o.signalKind
        case 'noise',
            t=o.questMean;
            o.sigma=10^t+1;
            o.approxRequiredNumber=64./10.^((t-idealT64)/0.55);
            o.logApproxRequiredNumber=log10(o.approxRequiredNumber);
            ffprintf(ff,'sigma %.3f, approx required number %.0f\n',o.sigma,o.approxRequiredNumber);
            %              logNse=std(logApproxRequiredNumber)/sqrt(length(tSample));
            %              ffprintf(ff,'SUMMARY: %s %d runs mean±se: log(sigma-1) %.2f±%.2f, log(approx required n) %.2f±%.2f\n',o.observer,length(tSample),mean(tSample),tse,logApproxRequiredNumber,logNse);
    end
    if o.runAborted && o.runNumber<o.runsDesired
        Speak('Please type period to skip the rest and quit now, or space to continue with next run.');
        FlushEvents('keyDown');
        response=0;
        while 1
            ListenChar(0); % flush
            ListenChar(2); % no echo
            response=GetChar;
            ListenChar(0); % flush
            ListenChar; % normal
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
    if o.runNumber==o.runsDesired && o.congratulateWhenDone && ~ismember(o.observer,{'ideal','brightnessSeeker','maximum'})
        Speak('Congratulations. You are done.');
    end
    if Screen(window,'WindowKind')==1;
        % Screen takes many seconds to close. This gives us a white screen
        % while we wait.
        Screen('FillRect',window);
        Screen('Flip',window); % White screen
    end
    FlushEvents('KeyDown');
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
    save([datafullfilename '.mat'],'o','cal');
    fprintf('Results saved in %s with extensions .txt and .mat\nin folder %s\n',o.datafilename,fileparts(datafullfilename));
    o.signal=signal;
catch
    sca; % screen close all
    AutoBrightness(cal.screen,1); % Restore autobrightness.
    fclose(dataFid);
    dataFid=-1;
    psychrethrow(psychlasterror);
end
return
