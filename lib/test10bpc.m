function test10bpc()
  % Test 10 bit per channel display for AMD Radeon graphics cards
  %
  % Copyright 2017, Hormet Yiltiz <hyiltiz@gmail.com>
  % Released under GNU GPLv3+.
  using11bpc = false;
  usingTexture = true;
  usingGradient = true;
  usingScreenshots = false;
  if usingGradient; usingTexture = true; end

  try
    AssertOpenGL;
    screenNumber = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    if using11bpc; PsychImaging('AddTask', 'General', 'EnableNative11BitFramebuffer'); % 11 bpc via Bit-stealing
    else PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');end
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

    [w, wRect]=PsychImaging('OpenWindow', screenNumber, 0.5, []);
    if using11bpc;Screen('ConfigureDisplay', 'Dithering', screenNumber, 61696);end % 11 bpc via Bit-stealing
    PsychColorCorrection('SetEncodingGamma', w, 1 / 2.4);
    nBits = 10;
    if using11bpc; nBits = 11; end
    Screen('Flip', w);

    if ~usingGradient
      im = ones(wRect(4), wRect(4));
    else
      im = repmat(reshape(repmat(1:floor(wRect(3)/10), [10 1]), 1,[]), [wRect(4) 1]);
    end
    colorRange = 0:1/2^nBits:1;
    for iColor=1:numel(colorRange)
      if usingTexture
        tex=Screen('MakeTexture', w, colorRange(iColor+im), [], [], 2);
        Screen('DrawTexture', w, tex);
      else
        Screen('FillRect', w, colorRange(iColor), CenterRect([0 0 wRect(4) wRect(4)], wRect));
      end

      Screen('Flip', w);
      [~,keyCode] = KbStrokeWait();
      if usingScreenshots; imwrite(Screen('GetImage', w, [], [], 1), ['test10bpc' datestr(now, 'YYYYmmDDHHMMSS') '.png']); end
      if strcmpi(KbName(keyCode), 'ESCAPE'); break; end
    end

    sca; % closes windows and textures
  catch %#ok<*CTCH>
    ShowCursor(screenNumber);
    sca; % closes windows and textures
    psychrethrow(psychlasterror);
  end %try..catch..
  RestoreCluts;
end

