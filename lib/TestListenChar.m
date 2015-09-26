% ListenChar(0); % flush
ListenChar(2); % no echo
response=GetChar;
ListenChar; % normal
fprintf('"%s"\n',response);