% Auxillary file for e04wd_demo.m (and other minimization examples), 
% which handles the control button on the graphics window.

% NAG Copyright 2009.

function my_button_handler(hObject, eventData)
label = get(hObject, 'String');
if strcmp(label, 'Close')
   close;
elseif strcmp(label, 'Pause')
   set(hObject, 'String', 'Resume');
   uiwait;
elseif strcmp(label, 'Start') || strcmp(label, 'Resume')
   set(hObject, 'String', 'Pause');
   uiresume;
elseif strcmp(label, 'Next')
   uiresume;
end
