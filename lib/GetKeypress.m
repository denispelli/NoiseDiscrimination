function response = GetKeypress(isKbLegacy,enableKeys)
% Wait for keypress, and return the lowercase character, e.g. 'a' or '4',
% or the key name, e.g. 'left_shift' or 'escape'. We do not distinguish
% between pressing a number key on the main or separate numeric keyboard;
% we just return the one-digit number as a character.
%
% On June 18, 2017, I'm seeing inconsistent capitalization from KbName.
% It's my impression that earlier tonight the escape character was reported
% as 'escape' but now it's reported as 'ESCAPE'. Current RETURN is reported
% as 'Return'. My fix is to force everything to lowercase.
%
% Originally called "checkResponse" written by Hörmet Yiltiz, October 2015.
% Renamed "GetKeypress" by Denis Pelli, November 2015.
if nargin == 0
   isKbLegacy = 0;
end
restrictKeys=nargin>=2;
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
   if restrictKeys
      oldEnablekeys = RestrictKeysForKbCheck(enableKeys);
   end
   [~, keyCode] = KbStrokeWait();
   if restrictKeys
      RestrictKeysForKbCheck(oldEnablekeys);
   end
   response = KbName(keyCode);
   response=lower(response);
   % fprintf('GETKEYPRESS: KbName ''%s''\n',response);
   
   % KbName, used by checkResponse, returns 2 characters, e.g. '0)',
   % when you press a number key on the main keyboard. So when KbName
   % returns two characters, we use only the first. This ignores the
   % state of the shift key, assuming no shift. Thus we do not
   % distinguish between a number key on a number pad and a number key
   % on the main keyboard.
   if length(response)==2
      response=response(1);
   end
end
end
