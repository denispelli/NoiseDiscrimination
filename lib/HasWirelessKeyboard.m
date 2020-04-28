function [hasWirelessKeyboard,keyboardNameAndTransport]=HasWirelessKeyboard
% [hasWirelessKeyboard,keyboardNameAndTransport]=HasWirelessKeyboard;
%
% Forces new enumeration of devices and returns a logical value reporting
% whether there is an active wireless keyboard.
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
% See also: RequestWirelessKeyboard.
%
% denis.pelli@nyu.edu, May, 2019.
if IsWin
    hasWirelessKeyboard=[]; % Impossible to find out on Windows.
    keyboardNameAndTransport={};
    return
end
% Force new enumeration of devices to detect newly attached external
% keyboard.
clear PsychHID; 
% Clear cache of keyboard devices.
clear KbCheck; 
[~,~,devices]=GetKeyboardIndices;
for i=1:length(devices)
    keyboardNameAndTransport{i}=sprintf('%s (%s)',devices{i}.product,devices{i}.transport);
end
hasWirelessKeyboard=length(GetKeyboardIndices)>=2 ...
    || contains(lower(keyboardNameAndTransport{1}),'wireless') ...
    || contains(lower(keyboardNameAndTransport{1}),'bluetooth');
end
