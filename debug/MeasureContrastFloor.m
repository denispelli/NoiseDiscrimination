clear o
% o.observer='denis'; % use your name
% o.distanceCm=60; % viewing distance
% o.durationSec=0.5; % signal duration. [0.05, 0.5] for 50 ms and 500 ms
% o.trialsDesired=40;

% NOISE
o.isNoiseDynamic = 1; % 0 for static noise
o.moviePreSec = 0; % ignored for static noise
o.moviePostSec = 0; % ignored for static noise

% o.showCropMarks=1; % mark the bounding box of the target
o.observer='denis'; % use your name
% o.observer='Chen';
o.weightIdealWithNoise=0;
o.distanceCm=70; % viewing distance
o.durationSec=0.2; % [0.05, 0.5] for 50 ms and 500 ms
o.trialsDesired=40;
o.assessContrast=0;
o.assessLoadGamma=0;

o.targetFont='Sloan';
o.alphabet = 'DHKNORSVZ';
% o.targetFont='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet
o.targetHeightDeg=7.64; % Target size, range 0 to inf. If you ask for too much, it gives you the max possible.
% o.targetHeightDeg=7.64*2;

o.noiseType='binary'; % 'gaussian' or 'uniform' or 'binary'
% o.noiseType='gaussian';
o.noiseSpectrum='white'; % pink or white
o.noiseCheckDeg=0.092;

o.noiseSD=0; % max is 0.16 for gaussian, 0.5 for binary.

% o.noiseCheckDeg=0.09*8;
% o.noiseSD=0; % noise contrast [0 0.16]
o.eccentricityDeg=0; % eccentricity [0 8 16 32]

o.noiseEnvelopeSpaceConstantDeg=128; % always Inf for hard edge top-hat noise
o.noiseRadiusDeg=inf; % noise decay radius [1 1.7 3 5.2 9 Inf]
% For noise with Gaussian envelope (soft)
% o.noiseRadiusDeg=inf;
% noiseEnvelopeSpaceConstantDeg: 1
%
% For noise with tophat envelope (sharp cut off beyond disk with radius 1)
% o.noiseRadiusDeg=1;
% noiseEnvelopeSpaceConstantDeg: Inf

% LETTER
% o.targetHeightDeg=7.64; % Target size, range 0 to inf.
% o.eccentricityDeg=0; % eccentricity [0 8 16 32]
% o.targetKind='letter';
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet

% TO REPLICATE MANOJ
% o.targetFont='ITC Bookman Std';
% o.alphabet='abcdefghijklmnopqrstuvwxyz';
% o.alternatives=length(o.alphabet); % number of letters to use from o.alphabet
% o.targetHeightDeg=2*7.64; % Manoj used xHeight of 7.64 deg.

% FIXATION & USER INTERFACE
o.targetCross=1;
o.fixationCrossWeightDeg = 0.05; % target line thickness
% o.fixationCrossBlankedNearTarget=0; % always present fixation
% o.isWin=0; % use the Windows code even if we're on a Mac
% o.noiseRaisedCosineEdgeThicknessDeg=0; % midpoint of raised cosine is at o.noiseRadiusDeg.
% o.durationSec=inf; % Typically 0.2 or inf (wait indefinitely for response).
% o.tGuess=log10(0.2); % Optionally tell Quest the initial log contrast on first trial.
o.alphabetPlacement='top'; % show possible answers on 'top' or 'right' for letters and gabors.
% o.fixationCrossWeightDeg=0.05; % target line thickness
o.isKbLegacy=0; % Uses KbWait, KbCheck, KbStrokeWait functions, instead of GetChar, for Linux compatibility.

% SNAPSHOT
o.saveSnapshot=0; % 0 or 1.  If true (1), take snapshot for public presentation.
o.saveStimulus=0;
o.snapshotLetterContrast=0.2; % nan to request program default. If set, this determines o.tSnapshot.
o.cropSnapshot=1; % If true (1), show only the target and noise, without unnecessary gray background.
o.snapshotCaptionTextSizeDeg=0.5;
o.snapshotShowsFixationBefore=1;
o.snapshotShowsFixationAfter=0;
o.speakInstructions=0;

% DEBUGGING
o.useFractionOfScreen=0; % 0: normal, 0.5: small for debugging.
o.flipClick=0;
o.assessContrast=0;
o.assessLoadGamma=0;
% o.showCropMarks=1; % mark the bounding box of the target
o.printDurations=0;
o.measureContrast=1;
o.assessTargetLuminance=1;
o.usePhotometer=1; 
running_trials = 1;
o = NoiseDiscrimination(o);
if isfield(o,'nominalContrast') && length(o.nominalContrast)>1
    folder=fileparts(mfilename('fullpath'));
    [nominal,i]=sort(o.nominalContrast);
    actual=o.actualContrast(i);
    change=actual-nominal;
    fprintf('nominal\tactual\tdiff\n');
    for i=1:length(actual)
       fprintf('%.4f\t%.4f\t%.4f\n',nominal(i),actual(i),change(i));
    end
    ii=abs(nominal)<0.1;
    fprintf('%d contrasts <0.1; diff mean %.4f, sd %.4f\n',sum(ii),mean(change(ii)),std(change(ii)));
    step=unique(sort(abs(actual)));
    step=step(2);
    
    figure(1);
    clf
    nominalRange=-10.^(-3:0.001:0);
    model=round(nominalRange/step)*step;
    model=min(model,-0.0003);
    loglog(-nominal,-actual,'o',-nominalRange,-model,'r-');
    xlim([0.001 1]);
    ylim([0.001 1]);
    DecadesEqual(gca);
    hold on
    loglog([.001 1],[.001 1],'-g');
    xlabel('Nominal contrast');
    ylabel('Actual contrast');
    s1=sprintf('Red line is %.4f*round(contrast/%.4f)',step,step);
    x=0.0011;
    y=0.7;
    text(x,y,s1);    
    xlabel('Pixel value');
    ylabel('Luminance (cd/m^2)');
    computer=Screen('Computer');
    s2=[computer.machineName ', '];
    yLim=ylim;
    yMul=0.8;
    y=y*yMul;
    y=y*yMul;
    text(x,y,s2);
    s3='';
    if o.ditherCLUT
        s3=sprintf('%sdither %d, ',s3,o.ditherCLUT);
    end
    if o.useNative10Bit
        s3=[s3 'useNative10Bit, '];
    end
    y=y*yMul;
    text(x,y,s3);
    s4=sprintf('CLUTMapLength=%d, ',o.CLUTMapLength);
    if ~o.usePhotometer
        s4=[s4 'simulating 8 bits, '];
    end
    y=y*yMul;
    text(x,y,s4);
    name='';
    name=[o.cal.machineName 'loglog' 'ContrastFloor'];
    name=strrep(name,'''',''); % Remove quote marks.
    name=strrep(name,' ',''); % Remove spaces.
    savefig(fullfile(folder,name));
    hold off

    figure(2)
    clf;
    plot(-nominal,-actual,'o',-nominalRange,-model,'-');
    xlim([0 0.02]);
    ylim([0 0.02]);
    daspect([1 1 1]);
    hold on
    plot([0 1],[0 1],'-g');
    xlabel('Nominal contrast');
    ylabel('Actual contrast');
    x=0.0005;
    y=0.019;
    text(x,y,s1);
    y=y-0.0007;
    y=y-0.0007;
    text(x,y,s2);
    y=y-0.0007;
    text(x,y,s3);
    y=y-0.0007;
    text(x,y,s4);
    hold off
    savefig(fullfile(folder,[o.cal.machineName 'ContrastFloor']));
    save(fullfile(folder,[o.cal.machineName 'ContrastFloor']),'o');
end