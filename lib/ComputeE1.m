function oo=ComputeE1(ooIn)
% oo=ComputeE1(oo);
persistent scratchWindow
oo=ooIn;
[oo.window]=deal([]);
% oo must include the following fields:
% targetWidthPix targetHeightPix targetCheckPix targetKind getAlphabetFromDisk screenRect
% allowAnyFont targetFont words alternatives scratchRect canvasSize gapFraction4afc

%% COMPUTE oo(oi).signal(i).image
ff=1;
white1=1;
black0=0;
gapPix=round(oo(1).gapFraction4afc*oo(1).targetHeightPix);

Screen('Preference','TextAntiAliasing',0);
for oi=1:length(oo)
    switch oo(oi).task % Compute masks and envelopes
        case '4afc'
            % boundsRect contains all 4 positions.
            %
            % gapPix is NOT rounded to a multiple of o.targetCheckPix
            % because I think that each of the four alternatives is
            % drawn independently, so the gap could be a fraction of a
            % targetCheck.
            boundsRect=[-oo(oi).targetWidthPix, -oo(oi).targetHeightPix, oo(oi).targetWidthPix+gapPix, oo(oi).targetHeightPix+gapPix];
            boundsRect=CenterRect(boundsRect,[oo(oi).targetXYPix oo(oi).targetXYPix]);
            targetRect=round([0 0 oo(oi).targetHeightPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix);
            oo(oi).signal(1).image=ones(targetRect(3:4));
        case {'identify' 'identifyAll' 'rate'}
            switch oo(oi).targetKind
                case {'letter' 'word'}
                    if ~oo(oi).getAlphabetFromDisk
                        if isempty(oo(1).window) && isempty(temporaryWindow)
                            % Some window must already be open before
                            % we call OpenOffscreenWindow.
                            ffprintf(ff,'%d: Opening temporaryWindow. ... ',MFileLineNr);
                            s=GetSecs;
                            n1=length(Screen('Windows'));
                            temporaryWindow=Screen('OpenWindow',0,1,[0 0 100 100]);
                            n2=length(Screen('Windows'));
                            ffprintf(ff,'Done (%.1f s).\n',GetSecs-s); % Opening temporaryWindow
                            ffprintf(ff,'%d: Open temporaryWindow. %d windows before, %d after.\n',MFileLineNr,n1,n2);
                        end
                        if isempty(scratchWindow)
                            if false
                                % Make it big enough for this signal.
                                % Should be closed and reopened for
                                % each condition.
                                scratchHeight=round(3*oo(oi).targetHeightPix/oo(oi).targetCheckPix);
                                switch oo(oi).targetKind
                                    case 'letter'
                                        wordLength=1;
                                    case 'word'
                                        % Currently all words have same length.
                                        wordLength=length(oo(oi).words{1});
                                end
                                scratchWidth=round((2+wordLength)*oo(oi).targetHeightPix/oo(oi).targetCheckPix);
                            else
                                % Make it big enough for any signal.
                                % Can be opened once and remain open
                                % until we call CloseWindowsAndCleanup.
                                scratchWidth=oo(1).screenRect(3);
                                scratchHeight=oo(1).screenRect(4);
                            end
                            % ffprintf(ff,'%d: Opening scratchWindow. ... ',oi); s=GetSecs; % Takes less than 0.1 s.
                            [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',-1,[],[0 0 scratchWidth scratchHeight],8);
                            % ffprintf(ff,'Done (%.1f s).\n',GetSecs-s); % Opening scratchWindow
                        end
                        if ~streq(oo(oi).targetFont,'Sloan') && ~oo(oi).allowAnyFont
                            warning('You should set o.allowAnyFont=true unless o.targetFont=''Sloan''.');
                        end
                        oldFont=Screen('TextFont',scratchWindow,oo(oi).targetFont);
                        Screen('DrawText',scratchWindow,double(oo(oi).alternatives(1)),0,scratchRect(4)); % Must draw first to learn actual font in use.
                        font=Screen('TextFont',scratchWindow);
                        if ~streq(font,oo(oi).targetFont)
                            error('Font missing! Requested font "%s", but got "%s". Please install the missing font.\n',oo(oi).targetFont,font);
                        end
                        oldSize=Screen('TextSize',scratchWindow,round(oo(oi).targetHeightPix/oo(oi).targetCheckPix));
                        oldStyle=Screen('TextStyle',scratchWindow,0);
                        canvasRect=[0 0 oo(oi).canvasSize(2) oo(oi).canvasSize(1)]; % o.canvasSize =[height width] in units of targetCheck;
                        if isempty(oo(oi).alternatives) || oo(oi).alternatives==0
                            error('Please set oo(oi).alternatives.');
                        end
                        if oo(oi).allowAnyFont
                            clear letters
                            for i=1:oo(oi).alternatives
                                % The "letter" is a word if
                                % o.targetKind='word'.
                                letters{i}=oo(oi).signal(i).letter;
                            end
                            % Measure bounds of this alphabet.
                            oo(oi).targetRectChecks=TextCenteredBounds(scratchWindow,letters,1);
                        else
                            oo(oi).targetRectChecks=round([0 0 oo(oi).targetHeightPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix);
                        end
                        assert(~isempty(oo(oi).targetRectChecks));
                        r=TextBounds2(scratchWindow,'x',1);
                        oo(oi).xHeightPix=RectHeight(r)*oo(oi).targetCheckPix;
                        oo(oi).xHeightDeg=oo(oi).xHeightPix/oo(oi).pixPerDeg;
                        r=TextBounds2(scratchWindow,'H',1);
                        oo(oi).HHeightPix=RectHeight(r)*oo(oi).targetCheckPix;
                        oo(oi).HHeightDeg=oo(oi).HHeightPix/oo(oi).pixPerDeg;
                        ffprintf(ff,'%d: o.xHeightDeg %.2f deg (traditional typographer''s x-height)\n',oi,oo(oi).xHeightDeg);
                        ffprintf(ff,'%d: o.HHeightDeg %.2f deg (capital H ascender height)\n',oi,oo(oi).HHeightDeg);
                        alphabetHeightPix=RectHeight(oo(oi).targetRectChecks)*oo(oi).targetCheckPix;
                        oo(oi).alphabetHeightDeg=alphabetHeightPix/oo(oi).pixPerDeg;
                        ffprintf(ff,'%d: o.alphabetHeightDeg %.2f deg (bounding box for letters used, including any ascenders and descenders)\n',...
                            oi,oo(oi).alphabetHeightDeg);
                        if oo(oi).printTargetBounds
                            fprintf('%d: o.targetRectChecks [%d %d %d %d]\n',...
                                MFileLineNr,oo(oi).targetRectChecks);
                        end
                        for i=1:oo(oi).alternatives
                            Screen('FillRect',scratchWindow,white1);
                            rect=CenterRect(canvasRect,scratchRect);
                            targetRect=CenterRect(oo(oi).targetRectChecks,rect);
                            if ~oo(oi).allowAnyFont
                                % Draw position is left at baseline
                                % targetRect is just big enough to hold any Sloan letter.
                                % targetRect=round([0 0 1 1]*oo(oi).targetHeightPix/oo(oi).targetCheckPix),
                                x=targetRect(1);
                                y=targetRect(4);
                            else
                                % Desired draw position is horizontal
                                % middle at baseline. targetRect is
                                % just big enough to hold any letter.
                                % targetRect allows for descenders and
                                % extension in any direction.
                                % targetRect=round([a b c d]*oo(oi).targetHeightPix/oo(oi).targetCheckPix),
                                % where a b c and d depend on the font.
                                x=(targetRect(1)+targetRect(3))/2; % horizontal middle
                                y=targetRect(4)-oo(oi).targetRectChecks(4); % baseline
                                % DrawText draws from left, so shift
                                % left by half letter width, to center
                                % letter at desired draw position.
                                % String must be cast as double to
                                % support unicode.
                                bounds=Screen('TextBounds',scratchWindow,double(oo(oi).signal(i).letter),x,y,1);
                                if oo(oi).printTargetBounds
                                    fprintf('%s bounds [%4.0f %4.0f %4.0f %4.0f]\n',oo(oi).signal(i).letter,bounds);
                                end
                                width=bounds(3);
                                x=x-width/2;
                            end
                            if oo(oi).printTargetBounds
                                fprintf('%s %4.0f, %4.0f\n',oo(oi).signal(i).letter,x,y);
                            end
                            Screen('DrawText',scratchWindow,double(oo(oi).signal(i).letter),x,y,black0,white1,1);
                            Screen('DrawingFinished',scratchWindow,[],1); % This delay makes GetImage more reliable. Suggested by Mario Kleiner.
                            letter=Screen('GetImage',scratchWindow,targetRect,'drawBuffer');
                            
                            % In 2015-7 we occasionally got scrambled
                            % letters, which I tracked down to
                            % malfunction of 'GetImage', above. Mario
                            % Kleiner suggested various things to try.
                            % Using the 'DrawingFinished' delay seemed
                            % to solve it. I don't know if the issue
                            % still persists today in 2018 (Mojave).
                            % --denis pelli
                            
                            Screen('FillRect',scratchWindow);
                            letter=letter(:,:,1);
                            oo(oi).signal(i).image=letter < (white1+black0)/2;
                            % We have now drawn letter(i) into
                            % oo(oi).signal(i).image, using binary
                            % pixels. The target size is given by
                            % oo(oi).targetRectChecks. If
                            % o.allowAnyFont=false then this a square
                            % [0 0 1 1]*o.targetHeightPix/o.targetCheckPix.
                            % In general, it need not be square. Any
                            % code that needs a bounding rect for the
                            % target should use o.targetRectChecks, not
                            % o.targetHeightPix. In the letter
                            % generation, targetHeightPix is used
                            % solely to set the nominal font size
                            % ("points"), in pixels.
                        end
                        % As of May 2019, the scratchWindow remains
                        % open until CloseWindowsAndCleanup closes it.
                        % ffprintf(ff,'%d: Closing scratchWindow. ... ',oi); s=GetSecs; % Takes less than 0.1 s.
                        % Screen('Close',scratchWindow);
                        % ffprintf(ff,'Done (%.1f s).\n',GetSecs-s); % Closing scratchWindo
                        % scratchWindow=[];
                    end
                case {'gabor' 'gaborCos' 'gaborCosCos'}
                    % o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
                    % o.targetGaborSpaceConstantCycles=1.5; % The 1/e space constant of the gaussian envelope in periods of the sinewave.
                    % o.targetGaborCycles=3; % cycles of the sinewave.
                    % o.targetGaborOrientationsDeg=[0 90]; % Orientations relative to vertical.
                    % o.responseLabels='VH';
                    targetRect=round([0 0 oo(oi).targetHeightPix oo(oi).targetHeightPix]/oo(oi).targetCheckPix);
                    oo(oi).targetRectChecks=targetRect;
                    widthChecks=RectWidth(targetRect)-1;
                    axisValues=-widthChecks/2:widthChecks/2; % axisValues is used in creating the meshgrid.
                    [x,y]=meshgrid(axisValues,axisValues);
                    r=sqrt(x.^2 + y.^2);
                    spaceConstantChecks=oo(oi).targetGaborSpaceConstantCycles*(oo(oi).targetHeightPix/oo(oi).targetCheckPix)/oo(oi).targetGaborCycles;
                    cyclesPerCheck=oo(oi).targetGaborCycles/(oo(oi).targetHeightPix/oo(oi).targetCheckPix);
                    switch oo(oi).targetKind
                        case 'gabor'
                            envelope=exp(-r.^2/spaceConstantChecks^2);
                        case 'gaborCos'
                            % Half cosine. Full extent is o.targetHeightPix.
                            envelope=cos(0.5*pi*r/(oo(oi).targetHeightPix/2));
                            ok=r/(oo(oi).targetHeightPix/2)<1;
                            envelope(~ok)=0;
                        case 'gaborCosCos'
                            % Half cosine. Full extent is o.targetHeightPix.
                            envelope=cos(0.5*pi*x/(oo(oi).targetHeightPix/2)) .* ...
                                cos(0.5*pi*y/(oo(oi).targetHeightPix/2));
                            ok=abs(x/(oo(oi).targetHeightPix/2))<1 & ...
                                abs(y/(oo(oi).targetHeightPix/2))<1;
                            envelope(~ok)=0;
                    end
                    for i=1:oo(oi).alternatives
                        a=cos(oo(oi).targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                        b=sin(oo(oi).targetGaborOrientationsDeg(i)*pi/180)*2*pi*cyclesPerCheck;
                        oo(oi).signal(i).image=sin(a*x+b*y+oo(oi).targetGaborPhaseDeg*pi/180).*envelope;
                    end
                case 'image'
                    % Allow color images.
                    % Scale to range -1 (black) to 1 (white).
                    Screen('TextBackgroundColor',oo(1).window,oo(1).gray1); % Set background.
                    string=sprintf('Reading images from disk. ... ');
                    DrawFormattedText(oo(1).window,string,...
                        2*oo(oi).textSize,2.5*oo(oi).textSize,black,...
                        oo(oi).textLineLength,[],[],1.3);
                    DrawCounter(oo(oi)); % 70 ms**
                    Screen('Flip',oo(1).window); % Display request.
                    oo(oi).targetPix=round(oo(oi).targetHeightDeg/oo(oi).noiseCheckDeg);
                    oo(oi).targetFont=oo(oi).targetFont;
                    oo(oi).showLineOfLetters=true;
                    oo(oi).useCache=false;
                    if oi>1 && ~isempty(oo(oi).signalImagesCacheCode)
                        for oiCache=1:oi-1
                            if oo(oiCache).signalImagesCacheCode==oo(oi).signalImagesCacheCode
                                oo(oi).useCache=true;
                                break;
                            end
                        end
                    end
                    if oo(oi).useCache
                        oo(oi).targetRectChecks=oo(oiCache).targetRectChecks;
                        oo(oi).signal=oo(oiCache).signal;
                    else
                        [signalStruct,bounds]=LoadSignalImages(oo(oi));
                        oo(oi).targetRectChecks=bounds;
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
                            % imshow(uint8(m));
                            oo(oi).signal(i).image=double(m)./whiteImage-1;
                            % imshow((oo(oi).signal(i).image+1));
                        end
                    end % if oo(oi).useCache
                    assert(~isempty(oo(oi).targetRectChecks));
                otherwise
                    error('Unknown o.targetKind "%s".',oo(oi).targetKind);
            end % switch oo(oi).targetKind
            assert(~isempty(oo(oi).targetRectChecks)); % FAILS HERE
            
            assert(~isempty(oo(oi).targetRectChecks));
            if oo(oi).allowAnyFont
                targetRect=CenterRect(oo(oi).targetRectChecks,oo(oi).stimulusRect);
            else
                targetRect=[0, 0, oo(oi).targetWidthPix, oo(oi).targetHeightPix];
                targetRect=CenterRect(targetRect,oo(oi).stimulusRect);
            end
            targetRect=round(targetRect);
            boundsRect=CenterRect(targetRect,[oo(oi).targetXYPix oo(oi).targetXYPix]);
            % targetRect not used. boundsRect used solely for the snapshot.
    end % switch oo(oi).task
%     ffprintf(ff,'%d: Prepare the %d signals, each %dx%d. ... Done (%.1f s).\n',...
%         oi,oo(oi).alternatives,size(oo(oi).signal(1).image,1),size(oo(oi).signal(1).image,2),toc);
    
    % Compute o.signalIsBinary, o.signalMin, o.signalMax.
    % Image will be (1+o.contrast*o.signal)*o.LBackground.
    v=[];
    for i=1:oo(oi).alternatives
        img=oo(oi).signal(i).image;
        v=unique([v img(:)']); % Combine all components, R,G,B, regardless.
    end
    oo(oi).signalIsBinary=all(ismember(v,[0 1]));
    oo(oi).signalMin=min(v);
    oo(oi).signalMax=max(v);
    
    Screen('Preference','TextAntiAliasing',1);
    
    %% o.E1 is energy at unit contrast.
    power=1:length(oo(oi).signal);
    for i=1:length(oo(oi).signal)
        m=oo(oi).signal(i).image;
        if size(m,3)==3
            m=0.2989*m(:,:,1)+0.5870*m(:,:,2)+0.1140*m(:,:,3);
        end
        power(i)=sum(m(:).^2);
        if ismember(oo(oi).targetKind,{'letter' 'word'})
            err=rms(oo(oi).signal(i).image(:)-round(oo(oi).signal(i).image(:)));
            if err>0.3
                warning(['Large %.2f rms deviation from 0 and 1 '...
                    'in letter(s) ''%s'' of font ''%s''.'], ...
                    err,oo(oi).signal(i).letter,oo(oi).targetFont);
            end
        end
    end
    %     if oo(oi).isNoiseDynamic
    %         ffprintf(ff,'%d: OLD log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',oi,log10(oo(oi).E1));
    %     else
    %         ffprintf(ff,'%d: OLD log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',oi,log10(oo(oi).E1));
    %     end
    oldE1=oo(oi).E1;
    oo(oi).E1=mean(power)*(oo(oi).targetCheckPix/oo(oi).pixPerDeg)^2;
    if oo(oi).isNoiseDynamic
        newStaticE1=oo(oi).E1;
        oo(oi).E1=oo(oi).E1*oo(oi).targetDurationSecs;
        % ffprintf(ff,'%d: log E1/(s deg^2) %.2f, where E1 is energy at unit contrast.\n',oi,log10(oo(oi).E1));
        ffprintf(ff,'dynamic E1:\tnew static/old\t%.1f\tnew/old\t%.1f\t%s\n',newStaticE1/oldE1,oo(oi).E1/oldE1,oo(oi).date);
    else
        % ffprintf(ff,'%d: log E1/deg^2 %.2f, where E1 is energy at unit contrast.\n',oi,log10(oo(oi).E1));
        ffprintf(ff,'static E1:\tnew/old\t%.1f\t\t\t%s\n',oo(oi).E1/oldE1,oo(oi).date);
    end
    % We are now done with the oo(oi).signal font (e.g. Sloan or Bookman), since we've saved our signals as images.
    if ~isempty(oo(1).window)
        Screen('TextFont',oo(1).window,textFont);
        Screen('TextSize',oo(1).window,oo(oi).textSize);
        Screen('TextStyle',oo(1).window,textStyle);
    end
end % for oi=1:conditions

