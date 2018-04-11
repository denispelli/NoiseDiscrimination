% Test RestrictKeysForKbCheck
KbName('UnifyKeyNames');
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
numberKeyCodes=[KbName('0)') KbName('1!') KbName('2@') KbName('3#') KbName('4$') ...
    KbName('5%') KbName('6^') KbName('7&') KbName('8*') KbName('9(') ...
    KbName('0') KbName('1') KbName('2') KbName('3') KbName('4') ...
    KbName('5') KbName('6') KbName('7') KbName('8') KbName('9')  ];
oldEnableKeys=RestrictKeysForKbCheck([KbName('a') numberKeyCodes spaceKeyCode returnKeyCode escapeKeyCode]);
deviceIndex=[];
while KbCheck; end
[~,keyCode] = KbStrokeWait(deviceIndex);
response = KbName(keyCode);
RestrictKeysForKbCheck(oldEnableKeys);
fprintf('Response: %d, "%s"\n',find(keyCode),response);

