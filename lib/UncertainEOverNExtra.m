% UncertainEOverNExtra
%% READ IN FONT FROM DISK
        % letterStruct(i).letter % char
        % letterStruct(i).image % image
        % letterStruct(i).rect % rect of that image
        % letterStruct(i).texture % Screen texture containing the image
        % letterStruct(i).bounds % the bounds of black ink in the rect
        % alphabetBounds % union of bounds for all letters.
        psych.getAlphabetFromDisk=true;
        psych.font='Sloan';
        screen=0;
        window=[];
        assert(o.getAlphabetFromDisk);
        % Read in font from disk.
        o.targetSizeIsHeight=true;
        o.targetPix=o.targetHeightPix/o.targetCheckPix;
        o.targetHeightOverWidth=1;
        o.targetFontHeightOverNominal=1;
        % o.alphabet is already defined.
        o.borderLetter='';
        o.showLineOfLetters=true;
        o.contrast=-1;
        if isempty(window)
            % This is a quick hack to allow the 'ideal observer' to use
            % getAlphabetFromDisk, which seems to need this call to
            % CreateLetterTextures, which needs at least a scratch window
            % in order to create textures.
            % We never explicitly close this window, so many will
            % accumulate if you call this routine many times before all
            % windows are closed when the application terminates.
            r=round(0.5*screenBufferRect);
            r=AlignRect(r,screenBufferRect,'right','bottom');
            [window,o.screenRect]=Screen('OpenWindow',screen,1.0,r);
        end
        [letterStruct,alphabetBounds]=CreateLetterTextures(1,o,window);
        % Normalize intensity to be 0 to 1.
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
            o.signal(i).image=letterStruct(j).image;
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
            % We use the 'bilinear' method to make sure that all new
            % pixel values are within the old range. That's important
            % because we set up the CLUT with that range.
            for i=1:length(o.signal)
                %% Scale to desired size.
                sz=[RectHeight(o.targetRectChecks) RectWidth(o.targetRectChecks)];
                o.signal(i).image=imresize(o.signal(i).image,...
                    sz,'bilinear');
                o.signal(i).bounds=ImageBounds(o.signal(i).image,1);
            end
            sRect=RectOfMatrix(o.signal(1).image); % units of targetChecks
        end
        o.targetRectChecks=sRect;
        o.targetHeightOverWidth=RectHeight(sRect)/RectWidth(sRect);
        o.targetHeightPix=RectHeight(sRect)*o.targetCheckPix;
