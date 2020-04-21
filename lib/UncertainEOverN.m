function [EOverN,psych]=UncertainEOverN(MM,psych)
% [EOverN,psych]=UncertainEOverN(M,psych);
% Measures threshold E/N for ideal detection or identification of a signal
% in white noise at one of M locations. This extends the results of Pelli
% (1985). We handle three cases, specified by psych.targetKind:
%
%% 'gabor'
% Identification of one of two possible signals that are orthogonal and
% equal energy (e.g. two gabors, one vertical and the other horizontal).
% This is equivalent to a 2-interval forced choice where the signal appears
% at one of M locations, randomly on one of two intervals, and the observer
% must report which interval. The E/N result is general to two equal-energy
% orthogonal signals, not specific to gabors. E/N = 1.3156 8.3335 for two
% orthogonal gabors with M=1 104.
%
%% 'letter'
% Here we assume the signal is a letter from a known alphabet. The letters
% are typically of unequal energy and not orthogonal. This E/N result is
% specific to the particular font and alphabet tested. 
% E/N = 16.1859 20.0291 for 9 Sloan letters with M=1 104.
% Threshold criterion P=75% correct.
% E/N = 9.85 for 10 Sloan letter, M=1, P=64%.
% REFERENCE. For M=1, Pelli et al. (2006) report an ideal threshold of log
% E=-2.59 at log N=-3.60, i.e. E/N=10^0.91=8.12 for the 10-letter Sloan
% alphabet, 64% correct identification.
%
%% 'orthogonalLetter'
% Provides orthonormal signals to the letter code to confirm that it
% performs identically with the Gabor code. Currently the threshold
% contrast thresholds agree to within 0.01 log unit.
%
% INPUT ARGUMENTS:
% "MM" is an array of one or more degrees of uncertainty M, each a positive
% integer.
% "psych" is a struct specifying Quest's psychophysical parameters,
% including the threshold criterion pThreshold. See QuestDemo.m in the
% Psychtoolbox. psych.noiseType allows you to specify the shape of the
% noise distribution: 'gaussian','uniform','binary','ternary'. All are zero
% mean and symmetric about zero.
%
% OUTPUT ARGUMENT:
% EOverN is the threshold energy E divided by the noise
% power spectral density N.
%
% denis.pelli@nyu.edu, December, 2019.
%
% REFERENCES:
%
% Pelli, D. G. (1985) Uncertainty explains many aspects of visual contrast
% detection and discrimination. Journal of the Optical Society of America A
% 2, 1508-1532.
% https://psych.nyu.edu/pelli/pubs/pelli1985uncertainty.pdf
%
% Needs the QUEST software package, which is included in the Psychtoolbox.
% http://psychtoolbox.org
% Watson, A. B. & Pelli, D. G. (1983) QUEST: a Bayesian adaptive
% psychometric method. Percept Psychophys, 33 (2), 113-20.
% https://psych.nyu.edu/pelli/pubs/watson1983quest.pdf
%
% For E and N notation, look at Pelli & Farell (1999).
% Pelli, D. G. & Farell, B. (1999) Why use noise? Journal of the Optical
% Society of America A, 16, 647-653.
% https://psych.nyu.edu/pelli/pubs/pelli1999noise.pdf
%
% Pelli, D. G., Burns, C. W., Farell, B., & Moore-Page, D. C. (2006)
% Feature detection and letter identification. Vision Research, 46(28),
% 4646-4674
% https://psych.nyu.edu/pelli/pubs/pelli2006letters.pdf

plusMinus=char(177); % 16-bit unicode.
micro=char(181); % 16-bit unicode.
wrongRight={'wrong','right'};
timeZero=GetSecs;
window=[];
if nargin<1
    MM=[100 1];
end
EOverN=zeros(size(MM));
if nargin<2
    % The rest of the code assumes that the "psych" struct exists so, if
    % necessary, we create it here.
    psych.targetKind='gabor'; % Orthonormal signals. n=length(alphabet)
    %     psych.targetKind='letter';           % Non-orthonormal letters.
    %     psych.targetKind='orthogonalLetter'; % Orthonormal letters.
    psych.noiseSD=1;
end
if ~isfield(psych,'alphabet')
    switch psych.targetKind
        case 'gabor'
            psych.alphabet='ab';
        case 'letter'
            psych.alphabet='DKHNORSVZ';
        case 'orthogonalLetter'
            psych.alphabet='ab';
    end
end
if ~isfield(psych,'noiseSD')
    psych.noiseSD=0.17;
end
if ~isfield(psych,'trialsDesired')
    psych.trialsDesired=100;
end
if ~isfield(psych,'reps')
    psych.reps=100;
end
if ~isfield(psych,'tGuess')
    psych.tGuess=0;
end
if ~isfield(psych,'tGuessSd')
    psych.tGuessSd=2;
end
if ~isfield(psych,'pThreshold')
    psych.pThreshold=0.75;
end
if ~isfield(psych,'beta')
    psych.beta=3.5;
end
if ~isfield(psych,'delta')
    psych.delta=0.01;
end
if ~isfield(psych,'gamma')
    psych.gamma=1/length(psych.alphabet);
end
if ~isfield(psych,'noiseType')
    psych.noiseType='gaussian';
end
if ~isfield(psych,'targetKind')
    error('You must specify psych.targetKind: ''gabor'', ''letter'', or ''orthogonalLetter''.');
end
if ~isfield(psych,'targetFont')
    psych.targetFont='Sloan';
end

psych.screen=0;
o=psych;
switch psych.targetKind
    case 'orthogonalLetter'
        o.signal=struct([]);
        % Create orthonormal signals, one per letter in alphabet. 
        for i=1:length(o.alphabet)
            o.signal(i).image=zeros([1 length(o.alphabet)]);
            o.signal(i).image(i)=1;
        end
        % Compute o.E1 with units of checkArea.
        E=zeros(size(o.alphabet));
        for i=1:length(o.alphabet)
            E(i)=sum(sum(o.signal(i).image.^2));
        end
        o.E1=mean(E);
    case 'letter'
        % Compute signal images, one per letter.
        window=[];
        if isempty(window)
            % getAlphabetFromDisk needs a scratch window in order to create
            % textures. We close this window at the end.
            windows=Screen('Windows');
            for i=1:length(windows)
                if Screen('WindowKind',windows(i))==1
                    window=windows(i);
                    break;
                end
            end
            if isempty(window)
                screenBufferRect=Screen('Rect',o.screen);
                r=round(0.2*screenBufferRect);
                r=AlignRect(r,screenBufferRect,'right','bottom');
                [window,o.screenRect]=Screen('OpenWindow',o.screen,1.0,r);
            end
        end
        o.noiseSD=0.5;
        o.N=o.noiseSD^2;
        if ~ismember({psych.targetFont},{'Sloan'})
            error(...
                ['UncertainEOverN: Currently, when psych.targetKind=''letter'', '...
                'psych.targetFont must be ''Sloan'', not ''%s''.'],...
                psych.targetFont);
            EOverN=nan;
            return
        end
        o.targetHeightOverWidth=1;
        o.targetFontHeightOverNominal=1;
        o.targetFont=psych.targetFont;
        o.targetFontNumber=[];
        o.targetSizeIsHeight=true;
        o.targetPix=64;
        o.targetHeightPix=o.targetPix;
        o.minimumTargetHeightChecks=8;
        o.targetCheckPix=1;
        o.borderLetter='';
        if ~isfield(o,'getAlphabetFromDisk')
            o.getAlphabetFromDisk=true;
        end
        o.showLineOfLetters=false;
        o.printSizeAndSpacing=false;
        o.contrast=1; % Typically 1 or -1. Negative for black letters.
        [letterStruct,alphabetBounds]=CreateLetterTextures(1,o,window);
        % Each image has range 0 to 255, which we normalize to 0 to 1, and
        % contrast reverse, so paper is 0 and ink is 1.
        for i=1:length(letterStruct)
            letterStruct(i).image=1-double(letterStruct(i).image)/255;
        end
        % Copy from letterStruct().image to o.signal().image
        for i=1:length(o.alphabet)
            [~,j]=ismember(o.alphabet(i),[letterStruct.letter]);
            assert(length(j)==1);
            if j==0
                error('%2: letter ''%c'' not in ''%s'' alphabet ''%s''.\n',...
                    o.alphabet(i),o.targetFont,[letterStruct.letter]);
            end
            if true
                % "true" ought to make things faster. Haven't checked.
                % I expected no effect on E/N, but in fact I get E/N=7.16
                % when false, and 7.41 when true.
                ratio=o.targetPix/size(letterStruct(j).image,2);
                if ratio<1
                    o.signal(i).image=imresize(letterStruct(j).image,ratio,'bilinear');
                else
                    o.signal(i).image=letterStruct(j).image;
                end
            end
        end
        DestroyLetterTextures(letterStruct);
        clear letterStruct
        % Scale to size specified by o.targetHeightPix.
        sRect=RectOfMatrix(o.signal(1).image); % units of targetChecks
        if o.targetHeightPix/o.targetCheckPix<o.minimumTargetHeightChecks
            warning('Enforcing o.minimumTargetHeightChecks %.0f.',o.minimumTargetHeightChecks);
            o.targetHeightPix=o.minimumTargetHeightChecks*o.targetCheckPix;
        end
        % "r" is the scale factor from signal pixels to target checks.
        r=round(o.targetHeightPix/o.targetCheckPix)/RectHeight(sRect);
        o.targetRectChecks=round(r*sRect);
        if r~=1
            % We use the 'bilinear' method to make sure that all new pixel
            % values are within the old range. That's important because we
            % set up the CLUT with that range.
            for i=1:length(o.signal)
                %% Scale to desired size.
                sz=[RectHeight(o.targetRectChecks) RectWidth(o.targetRectChecks)];
                o.signal(i).image=imresize(o.signal(i).image,...
                    sz,'bilinear');
                % Bounds for all the ink pixels. Paper is 0.
                o.signal(i).bounds=ImageBounds(o.signal(i).image,0);
            end
            sRect=RectOfMatrix(o.signal(1).image); % units of targetChecks
        end
        o.targetRectChecks=sRect;
        o.targetHeightOverWidth=RectHeight(sRect)/RectWidth(sRect);
        o.targetHeightPix=RectHeight(sRect)*o.targetCheckPix;
        if false
            % Flip contrast.
            for i=1:length(o.signal)
                o.signal(i).image=1-o.signal(i).image;
            end
        end
        % Compute o.E1 with units of checkArea.
        E=zeros(size(o.alphabet));
        for i=1:length(o.alphabet)
            E(i)=sum(sum(o.signal(i).image.^2));
        end
        o.E1=mean(E);
end % switch o.targetKind
for m=1:length(MM)
    M=MM(m);
    t=zeros([1 psych.reps]);
    for rep=1:psych.reps
        q=QuestCreate(psych.tGuess,psych.tGuessSd,...
            psych.pThreshold,psych.beta,psych.delta,psych.gamma);
        q.normalizePdf=1;
        for k=1:psych.trialsDesired
            % Run one trial. "response" is true if correct, otherwise false.
            switch psych.targetKind
                case 'gabor'
                    % We assume the alternatives are orthogonal.
                    tTest=QuestQuantile(q);
                    % x is the stimulus. The signal is one number. There
                    % are two columns, and the observer must choose which
                    % column holds the signal. There are M rows. The noise
                    % is independent in all 2*M elements of x. The observer
                    % chooses whichever column has greater max. That's a
                    % maximum likelihood choice for a signal in Gaussian
                    % white noise.
                    n=length(o.alphabet);
                    % nIFC, with M locations.
                    dims=[M n];
                    x=MakeNoise(psych.noiseType,dims);
                    % Assuming all objects orthogonal.
                    whichObject=randi(n);
                    whichSpot=randi(M);
                    o.noiseSD=1;
                    o.E1=1;
                    c=10^tTest;
                    % Add whichObject at contrast c to whichSpot.
                    x(whichSpot,whichObject)=x(whichSpot,whichObject)+c;
                    if false
                        % Shortcut using max.
                        if M>1
                            % pLetter is max of each column of x. Each
                            % column has height M.
                            pObject=max(x);
                        else
                            pObject=x;
                        end
                    else
                        % Implement ideal (max likelihood classifier) for
                        % one of n known signals in gaussian noise.
                        sd=psych.noiseSD;
                        energySpotObject=(x(:,1:n)-c).^2  ...
                            +sum(sum(x(:,1:n).^2)) - x(:,1:n).^2;
                        if M>1
                            energySpotObject=energySpotObject-10-min(energySpotObject(:));
                            pSpotObject=exp(-energySpotObject/(2*sd^2));
                            pObject=sum(pSpotObject);
                        else
                            pObject=-energySpotObject;
                        end
                    end
                    [~,choice]=max(pObject);
                    response = choice==whichObject; % Correct if we choose the signal.
                    % fprintf('Trial %3d at %5.2f is %s\n',k,tTest,char(wrongRight(response+1)));
                    q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
                case {'letter' 'orthogonalLetter'}
                    % The alteratives are usually not orthogonal.
                    tTest=QuestQuantile(q);
                    % The signal is a letter, randomly drawn from
                    % psych.alphabet, which has length n. The signal is
                    % presented, randomly, at one of M locations. The task
                    % is to identify the letter. We create M images one for
                    % each location. All have white noise. To one image we
                    % also add a letter at contrast 10^tTest. Considering
                    % just one noise image, the likelihood of a given
                    % letter there is monotonically related to the rms
                    % error of the image minus the letter (at known
                    % contrast). In our task, the hypothesis of a letter in
                    % a spot (at known contrast) includes no letters at the
                    % other spots. The likelihood that a given letter was
                    % shown anywhere considers M spots where it might have
                    % appeared. The final choice is the likeliest letter.
                    n=length(o.alphabet);
                    whichObject=randi(n);
                    whichSpot=randi(M);
                    % Three dimensional matrix: rows * columns * M. Fill
                    % with Gaussian noise with zero mean and o.noiseSD.
                    dims=[size(o.signal(1).image) M];
                    x=MakeNoise(psych.noiseType,dims);
                    img=o.noiseSD*x;
                    % Add object whichObject with contrast c to spot
                    % whichSpot.
                    c=10^tTest;
                    img(:,:,whichSpot)=img(:,:,whichSpot)+c*o.signal(whichObject).image;
                    spotEnergy=zeros([1 M]);
                    for spot=1:M
                        spotEnergy(spot)=sum(sum(img(:,:,spot).^2));
                    end
                    energy=sum(spotEnergy);
                    energySpotObject=zeros([M n]);
                    for spot=1:M
                        for object=1:n
                            % "energySpotObject" is the total squared error
                            % of the hypothesis that we showed the given
                            % "object" at the given "spot". Each row
                            % corresponds to a spot, and each column
                            % corresponds to an object. If the noise is
                            % Gaussian, then the likelihood is
                            % monotonically related to the square error of
                            % the hypothesis. "energySpotObject" is the
                            % total squared error of the hypothesis of the
                            % given "object" at "spot". The sum evaluates
                            % the error at "spot", and the term
                            % "energy-spotEnergy(spot)" computes the total
                            % squared error at the rest of the spots, which
                            % are hypothesized to be blank.
                            energySpotObject(spot,object)=...
                                sum(sum((img(:,:,spot)-c*o.signal(object).image).^2))...
                                +energy-spotEnergy(spot);
                        end
                    end
                    % Compute likelihood of each letter. For each letter,
                    % there are M hypotheses for which spot it occupies,
                    % with the remaining M-1 spots being blank. We compute
                    % the rms error of each hypothesis (ie M*n combinations
                    % of position and object). The likelihood of an object
                    % is the sum of the likelihood of the object at each of
                    % the M positions. The probability density we're
                    % computing corresponds to M*pix pixels, where pix is
                    % the number of pixels in each "spot". The standard
                    % deviation for each pixel is noiseSD. The noise at all
                    % pixels is independent, so the variances add. The
                    % total variance is M*pix*noiseSD.
                    % p=product(for i=1:M*pix) sqrt(2*pi*sd^2)*exp(-sqEr(i)/(2*sd^2))
                    % =sqrt(2*pi*sd^2)^(M*pix)*exp(-sum(sqEr)/(2*sd^2))
                    pix=length(o.signal(1).image(:)); % Pixels in image.
                    % We use the pdf of the normal distribution to convert
                    % the summed squared error (from pix*n pixels) into a
                    % probability density. Then we sum the probability
                    % densities across possible spots for the object, since
                    % they are exclusive possibilities.
                    sd=psych.noiseSD;
                    if true
                        % Ideal: Sum probability across locations.
                        if M>1
                            % "pSpotObject" is the probability of the
                            % hypothesis that "object" was shown at "spot".
                            % "pObject" is the probability that "object"
                            % was shown, anywhere. We choose an offset
                            % carefully to avoid producing inf values in
                            % the call to exp(). Adding the same offset to
                            % all the energies is equivalent to multiplying
                            % all the pSpotObject values by the positive
                            % constant exp(-offset/(2*sd^2)). Multiplying
                            % all the pSpotObject values by the same
                            % positive constant is equivalent to
                            % multiplying the pObject values by the same
                            % constant, and thus will not affect which is
                            % biggest.
                            offset=-(10+min(energySpotObject(:)));
                            pSpotObject=exp(-(energySpotObject+offset)/(2*sd^2));
                            pObject=sum(pSpotObject);
                        else
                            pSpotObject=-energySpotObject;
                            pObject=pSpotObject;
                        end
                    else
                        % Shortcut: Use max across locations.
                        if M>1
                            % Shortcut: estimate likelihood of each object
                            % by its likelihood at the spot at which its
                            % likelihood is highest.
                            pObject=max(-energySpotObject);
                        else
                            pObject=-energySpotObject;
                        end
                    end
                    [~,choice]=max(pObject);
                    % Correct if we choose the signal.
                    response = whichObject==choice;
                    if false
                        % Show true signal, noisy stimulus, and ideal
                        % choice.
                        figure(1)
                        subplot(1,3,1)
                        imshow((1+o.signal(whichObject).image)/2,[0 1],'InitialMagnification','fit','Border','tight');
                        xlabel('signal');
                        title(sprintf('%.0f',pObject(whichObject)));
                        subplot(1,3,2)
                        theImage=img(:,:,whichSpot);
                        imshow((1+theImage)/2,[0 1],'InitialMagnification','fit','Border','tight');
                        xlabel('signal+noise');
                        subplot(1,3,3)
                        imshow((1+o.signal(choice).image)/2,[0 1],'InitialMagnification','fit','Border','tight');
                        xlabel('choice');
                        title(sprintf('%.0f',pObject(choice)));
                        figure(1);
                    end
                    % fprintf('Trial %3d at %5.2f is %s, which %s, choice %s\n',...
                    %    k,tTest,char(wrongRight(response+1)),o.alphabet(whichLetter),o.alphabet(choice));
                    q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
                otherwise
                    error('Sorry. targetKind ''%s'' is not supported.',psych.targetKind);
            end
        end
        t(rep)=QuestMean(q);
        % fprintf('run %d, %5.2f\n',rep,t(rep));
    end
    logC=mean(t);
    E=o.E1*10^(2*logC); % signal energy
    N=o.noiseSD^2;      % noise power spectral density
    EOverN(m)=E/N;
    if ~isfield(o,'conditionName')
        o.conditionName='';
    end
    if true
        psych=o;
        % Print targetFont only when it's used.
        switch psych.targetKind
            case 'letter'
                targetFont=psych.targetFont;
            otherwise
                targetFont='';
        end
        fprintf(['%-29s signals %d, %s, pThreshold %.2f, M %7.0f, E/N %6.3f, c %6.3f, log c %5.3f ' plusMinus ' %.3f\n'],...
            [psych.conditionName ', ' psych.targetKind ', ' targetFont ','],length(psych.alphabet),psych.noiseType,psych.pThreshold,M,EOverN(m),10^logC,logC,std(t)/sqrt(length(t)));
    end
end
% fprintf('%.0f ms/trial\n',1000*(GetSecs-timeZero)/(psych.reps*4*psych.trialsDesired));
if false
    % Optionally, reanalyze the data with psych.beta as a free parameter.
    fprintf('\nBETA. Many people ask, so here''s how to analyze the data with psych.beta as a free\n');
    fprintf('parameter. However, we don''t recommend it as a daily practice. The data\n');
    fprintf('collected to estimate threshold are typically concentrated at one\n');
    fprintf('contrast and don''t constrain psych.beta. To estimate psych.beta, it is better to use\n');
    fprintf('100 trials per intensity (typically log contrast) at several uniformly\n');
    fprintf('spaced intensities. We recommend using such data to estimate psych.beta once,\n');
    fprintf('and then using that psych.beta in your daily threshold measurements. With\n');
    fprintf('that disclaimer, here''s the analysis with psych.beta as a free parameter.\n');
    QuestBetaAnalysis(q); % optional
    fprintf('Parameters of QUEST fit:\n');
    fprintf('psych.beta	psych.gamma\n');
    fprintf('%4.1f	%5.2f\n',q.psych.beta,q.psych.gamma);
end
if ~isempty(window)
    Screen('Close',window);
end
