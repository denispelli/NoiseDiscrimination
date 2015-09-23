function response = checkResponse(isKbLegacy)
    while KbCheck;end
    response = 0;
    if nargin == 0
        isKbLegacy = 0;
    end

    if isKbLegacy
        ListenChar(0); % flush
        ListenChar(2); % no echo
        response=GetChar;
        ListenChar(0); % flush
        ListenChar; % normal
    else
        % use modern Kb* functions
        [secs, keyCode] = KbStrokeWait(); % we only need keyIsDown and keyCode
        response = KbName(keyCode);
        disp(sprintf('0:==>%s<==', response));

        if ismember(response, {'period', '.>', '.'}); response = '.'; end
        disp(sprintf('1:==>%s<==', response));

        if 0
            %[keyIsDown, secs, keyCode] = KbCheck(); % we only need keyIsDown and keyCode
            if keyIsDown
                % several keys pressed at once is ignored here for simplicity!
                whichKey = find(keyCode,1);
                if ~isempty(whichKey)
                    response = KbName(find(keyCode, 1));
                end
            end
            while KbCheck;end
        end

    end

end
