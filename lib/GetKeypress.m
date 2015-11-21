function response = GetKeypress(isKbLegacy)
% Wait for keypress, and return the lowercase character, e.g. 'a' or '4',
% or key name, e.g. 'left_shift'.
%
% Originally called "checkResponse" written by Hörmet Yiltiz, October 2015.
% Renamed "GetKeypress" by Denis Pelli, November 2015.
    if nargin == 0
        isKbLegacy = 0;
    end
    while KbCheck
    end
    response=0;
    if isKbLegacy
        ListenChar(0); % flush
        ListenChar(2); % no echo
        response=GetChar;
        ListenChar(0); % flush
        ListenChar; % normal
    else
        % use modern Kb* functions
        [secs, keyCode] = KbStrokeWait(); % we only need keyCode
        response = KbName(keyCode);
        %disp(sprintf('0:==>%s<==', response));
        
        % KbName, used by checkResponse, returns 2 characters, e.g. '0)',
        % when you press a number key. So we use only the first character
        % of the string returned by checkResponse. This ignores the state
        % of the shift key, assuming no shift. We intentionally do not
        % distinguish between a number key on a number pad and a number key
        % on the main keyboard.
        if length(response)==2
            response=response(1);
        end

        if ismember(response, {'period', '.>', '.'}); response = '.'; end
        %disp(sprintf('1:==>%s<==', response));

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
