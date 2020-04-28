function hasWirelessKeyboard=RequestWirelessKeyboard
% hasWirelessKeyboard=RequestWirelessKeyboard; 
%
% Uses Command Window and keyboard to ask user to provide a wireless
% keyboard. The user can say yes or no (y or <return> for yes, n for no;
% all other keys are ignored), and after saying yes, can still escape to
% say no and continue without it. Returns a logical variable which is true
% if a wireless keyboard is attached and false otherwise. We use
% ListenChar(2)/ListenChar to prevent MATLAB from receiving the typed
% responses.
%
% If there already is a wireless keyboard then we return without comment.
% Logically you might be requesting a further wireless keyboard, but this
% routine and the HasWirelessKeyboard routine would need to be enhanced to
% distinguish multiple wireless keyboards all attached at once.
%
% A WIRELESS OR LONG-CABLE KEYBOARD is highly desirable because a normally
% sighted observer viewing foveally has excellent vision and must be many
% meters away from the screen in order for us to measure her acuity limit.
% At this distance she can't reach the built-in keyboard attached
% to the screen. If you must use the built-in keyboard, then have the
% experimenter type the observer's verbal answers. Instead, I like the
% Logitech K760 solar-powered wireless keyboard, because its batteries
% never run out. It's no longer made, but still available on Amazon, New
% Egg, and eBay (below). To "pair" the keyboard with your computer's blue
% tooth, press the tiny button on the back of the keyboard.
%
% Logitech Wireless Solar Keyboard K760 for Mac/iPad/iPhone
% http://www.amazon.com/gp/product/B007VL8Y2C
% https://www.newegg.com/logitech-wireless-solar-keyboard-k760-bluetooth-wireless/p/N82E16823126283?Item=9SIA4RE7ZV9401
% https://www.ebay.com/sch/i.html?_from=R40&_trksid=m570.l1313&_nkw=Logitech+K760+Wireless+Solar+Keyboard+&_sacat=0
% https://www.logitech.com/assets/44407/wireless-solar-keyboard-k760-quickstart-guide.pdf
%
% See also: HasWirelessKeyboard.
%
% denis.pelli@nyu.edu April 27, 2020.
[hasWirelessKeyboard,keyboardNameAndTransport]=HasWirelessKeyboard;
if hasWirelessKeyboard
        fprintf('Your wireless keyboard "%s" is connected and ready for use.\n',...
            keyboardNameAndTransport{end});
    return
end
deviceIndex=-3; % -3 for all keyboard/keypad devices.
% escapeChar=char(27);
% graveAccentChar='`';
returnChar=char(13);
KbName('UnifyKeyNames');
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
% returnKeyCode=KbName('return');
FlushEvents('keyDown');
fprintf('<strong>Would you like to attach a wireless keyboard now?</strong> (y/n):');
ListenChar(2);
response=GetKeypress(KbName({'y' 'n' 'return'}),deviceIndex);
ListenChar;
FlushEvents('keyDown');
fprintf('\n');
waitForAttachment=ismember(response,['y' returnChar]);
fprintf(['\n'...
    '<strong>HOW TO CONNECT YOUR WIRELESS KEYBOARD</strong>\n'...
    'Ok. There are many possible computers and keyboards. Here follow \n'...
    '"pairing" instructions for macOS and the Logitech K760 Solar Wireless \n'...
    'Keyboard. Turn the keyboard upside down and find the tiny white \n'...
    'bluetooth button about 2 inches from the bottom and 1 inch \n'...
    'from the right edge. Click that button to tell the the keyboard to \n'...
    'pair with your computer. On macOS click Apple Menu (in upper left \n'...
    'of screen) select System Preferences: Bluetooth. Your Logitech 760 \n'...
    'keyboard should appear in the list of Devices. Click its "Connect" \n'...
    'button. Your computer and Logitech keyboard should now connect. \n'...
    'This is called Bluetooth "pairing". Pairing is persistent. Next time \n'...
    'it may connect automaticaly when you turn it on, or if not, it may be \n'...
    'enough to just hit one of the three bluetooth buttons next to the \n'...
    'escape key in the top row of keys in the Logitech keyboard. \n\n'...
    ]);
printNow=GetSecs;
ListenChar(2);
while waitForAttachment
    [keyIsDown,~,keyCode]=KbCheck(deviceIndex);
    if keyIsDown && any(ismember(find(keyCode),[escapeKeyCode graveAccentKeyCode]))
        FlushEvents('keyDown');
        break
    end
    if GetSecs>printNow
        fprintf('Waiting for wireless keyboard. (ESC to continue without it.)...\n');
        printNow=GetSecs+10;
    end
    WaitSecs(0.1);
    [hasWirelessKeyboard,keyboardNameAndTransport]=HasWirelessKeyboard;
    if hasWirelessKeyboard
        fprintf('<strong>Great! Your wireless keyboard "%s" is now connected and ready for use.</strong>\n',...
            keyboardNameAndTransport{end});
        break;
    end
end
ListenChar;
end