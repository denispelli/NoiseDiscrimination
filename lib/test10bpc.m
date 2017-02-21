function test10bpc(nBits, usingGradient, usingTexture)
  % Test 10 bit per channel display for AMD Radeon graphics cards
  %
  % Copyright 2017, Hormet Yiltiz <hyiltiz@gmail.com>
  % Released under GNU GPLv3+.
  if nargin < 3
    nBits = 11; % supported values: 8, 10, 11, 12
    usingTexture = true;
    usingGradient = true;
  end
  usingScreenshots = false;
  if usingGradient; usingTexture = true; end % gradients require textures

  try
    AssertOpenGL;
    screenNumber = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    switch nBits
      case 8;; % do nothing
      case 10; PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
      case 11; PsychImaging('AddTask', 'General', 'EnableNative11BitFramebuffer');
      case 12; PsychImaging('AddTask', 'General', 'EnableNative16BitFramebuffer');
    end

    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

    % uncomment this line when using 11 bpc for the first time
    % delete([PsychtoolboxConfigDir 'rgb111110remaplut.mat']); % clear cache

    [w, wRect]=PsychImaging('OpenWindow', screenNumber, 0.5, []);
    if nBits>=11;Screen('ConfigureDisplay', 'Dithering', screenNumber, 61696);end % 11 bpc via Bit-stealing
    PsychColorCorrection('SetEncodingGamma', w, 1/2.50); % your display might have a different gamma
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
      if usingTexture; Screen('Close', tex); end % prevents memory overload
    end

    sca; % closes windows and textures
  catch %#ok<*CTCH>
    ShowCursor(screenNumber);
    sca; % closes windows and textures
    psychrethrow(psychlasterror);
  end %try..catch..
  RestoreCluts;
end

