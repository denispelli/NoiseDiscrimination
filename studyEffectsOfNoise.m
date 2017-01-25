% function o = studyEffectsOfNoise(isIdealPlus)
%#### Adjust values within this block #####################
clear o
useBackupSessions=1;
% o.observer='junk';
% o.observer='ideal';
o.observer='Ning'; % use your name
o.weightIdealWithNoise=0;
o.distanceCm=60; % viewing distance
o.durationSec=0.2;
o.trialsPerRun=40;


%For noise with Gaussian envelope (soft)
%o.noiseRadiusDeg=inf;
%noiseEnvelopeSpaceConstantDeg: 1

%For noise with tophat envelope (sharp cut off beyond disk with radius 1)
%o.noiseRadiusDeg=1;
%noiseEnvelopeSpaceConstantDeg: Inf

% ############# we test target size x ecc w/o noise #######
% o.targetHeightDeg=6; % OLD: letter or gabor size [2 3.5 6];
o.targetHeightDeg=16; % letter/gabor size [2 4 8].
o.eccentricityDeg=8; % eccentricity [0 8 16 32]
o.noiseSD=0.16; % noise contrast [0 0.16]
% We want to compare these:
o.noiseCheckDeg=o.targetHeightDeg/20;
%o.noiseCheckDeg=o.targetHeightDeg/40;
% #########################################################

% ############# We plan to test these soon #######
% Also size 16 at [0 32] ecc. Also sizes [0.5 1] at 0 deg ecc. Also size 1 at 16 ecc.
% #########################################################

% ############## Below is constant for this week ##########
o.targetKind='letter';

%o.targetKind='gabor'; % a grating patch
% These two sets of orientation produce the same gabors, they differ only
% in the order in which they appear on the response screen. The first set
% begins at 0 vertical. The second set begins at horizontal. Use whichever
% you prefer.
%o.targetGaborOrientationsDeg=[0 30 60 90 120 150]; % Orientations relative to vertical.
%o.targetGaborOrientationsDeg=[-90 -60 -30 0 30 60]; % Orientations relative to vertical.
%o.targetGaborNames='123456'; % Observer types 1 for 0 deg, 2 for 30 deg, etc.
%##########################################################

% o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
% o.targetGaborNames='VH'; % Observer types V for vertical or H for horizontal.


%## Fixed values, for all current testing. Do not adjust. #####
% Gaussian noise envelope: soft cut off
% o.noiseRadiusDeg=inf;
% noiseEnvelopeSpaceConstantDeg: 1

o.noiseEnvelopeSpaceConstantDeg=128; % always Inf for hard edge top-hat noise
% o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]
o.noiseRadiusDeg=inf;

o.noiseType='gaussian'; % ALWAYS use gaussian
o.noiseSpectrum='white'; % pink or white
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
% o.fixationCrossBlankedNearTarget=0; % always present fixation

o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.


% o.targetKind='letter'; % use letter target
%##################################################################
%o.targetKind='gabor'; % use gabor target. one cycle within targetSize
%o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
%o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
%o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
%o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
%o.targetGaborNames='VH'; % "V" for vertical, and "H" for horizontal.
% When plotting the gabor data, use either spatial frequency f in c/deg, or
% period size A in deg.
% f = o.targetGaborCycles/o.targetSizeDeg;
% A = 1/f;
% We should test the same values of o.targetHeightDeg for gabors as for
% letters.
%#########################################


%o.noiseCheckDeg=o.targetHeightDeg/20;
% o.isWin=0; % use the Windows code even if we're on a Mac
%o.targetGaborPhaseDeg=90; % Phase offset of sinewave in deg at center of gabor.
%o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
%o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
%o.targetModulates='luminance'; % Display a luminance decrement.
% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
o.cropSnapshot=1; % If true (1), show only the target and noise, without unnecessary gray background.
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.speakInstructions=0;
o.isKbLegacy = 0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.
% o.useFractionOfScreen=0.3; % 0: normal, 0.5: small for debugging.


if useBackupSessions % auto-generate full sequence of experiments for "Winter" data collection
    
    % ecc    targetSize
    tableCell = ...
        {0 ,   [0.5, 1, 2, 4, 8, 16];
        8 ,   [1,   2, 4, 8, 16   ];
        16,   [1,   2, 4, 8, 16   ];
        32,   [2,   4, 8, 16      ];}
    
    NoiseDecayRaiusOverLetterRadius = [0.33, 0.58, 1.00, 1.75, 3.00, 32];
    
    iCounter = 1;
    clear oo;
    ooNo = o;
    for iEcc = 1:size(tableCell,1)
        for iTargetSize=1:numel(tableCell{iEcc,2})
            for iRatio=0:numel(NoiseDecayRaiusOverLetterRadius)
                oo(iCounter) = o;
                oo(iCounter).eccentricityDeg = tableCell{iEcc,1};
                oo(iCounter).targetHeightDeg = tableCell{iEcc,2}(iTargetSize);
                
                if iRatio==0
                    % no noise
                    oo(iCounter).noiseSD = 0; %override previously specified noiseSD
                    oo(iCounter).noiseEnvelopeSpaceConstantDeg = NaN;
                    %           iCounter = iCounter + 1;
                    
                else
                    % high noise; noise decay radius (noiseSD is already specified above as 0.16)
                    oo(iCounter).noiseEnvelopeSpaceConstantDeg = ...
                        NoiseDecayRaiusOverLetterRadius(iRatio).*oo(iCounter).targetHeightDeg/2;
                    oo(iCounter).noiseCheckDeg=oo(iCounter).targetHeightDeg/20;
                end
                
                iCounter = iCounter + 1;
            end
        end
    end
    
    % now shuffle
    oo = Shuffle([oo oo]); % repeat twice
    
    assert(numel(oo)/2==iCounter-1);
    disp([num2str(iCounter) ' shuffled conditions at all eccentricies and letter sizes with noise at required decay radii and without noise have been generated in total!']);
    disp('See https://github.com/hyiltiz/NoiseDiscrimination/wiki/How-to-collect-data#winter')
    
    session.matFileName=['session_' datestr(now,'yyyymmddHHMMSS') '.mat'];
    session.progressTrialNO=1;
    if strcmp(lower(input(sprintf('\nYou will have to create new session file normally when you change to a new observer.\nCreate a new session file with the full data structure above?  (y/n)\n'), 's')),'y');
        save(session.matFileName, 'oo', 'session');
    else
        disp('Did not create a new session file');
        disp('We can use previously created ones');
    end
    
    
    % now start running the experiments
    sessionFiles = dir('session_*.mat');
    if numel(sessionFiles)>1;error('More than 1 session files are found! Please backup all, then only place one under current directory.');end
    
    sessionFile = sessionFiles(1).name;
    save(['backup_' datestr(now,'yyyymmddHHMMSS') '.mat']);
    disp('A backup file is created for your current workspace. You can safely delete it if the previous experiment was successful. If not, then keep that backup.')
    
    load(sessionFile); % WARNING: this overrides session and oo struct! Good we always backup before loading, so no data is lost
    
    progressTrialNO=session.progressTrialNO;
    for iProgressTrialNO=progressTrialNO:numel(oo) % pick up from where we left off
%         if ~oo(iProgressTrialNO).noiseSD==0; 
        ooWithData{iProgressTrialNO}=NoiseDiscrimination(oo(iProgressTrialNO))%;end
        sca;
        if ooWithData{iProgressTrialNO}.runAborted
            break;
            fprintf('Your previous run was not successful! \nNot saving the results into session. \nRun this file again when ready for future data collection.\n\n');
        else
            session.progressTrialNO=session.progressTrialNO+1;
        end
        save(session.matFileName, 'oo', 'session');
        if ~strcmp(lower(input('Continue into next run? (y/n)\n', 's')),'y');break;end
    end
    
else
    o=NoiseDiscrimination(o);
    sca;
end
% end
