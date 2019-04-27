function Test11BitImaging
% Based on GratingDemo. denis.pelli@nyu.edu
% Check 11-bit imaging.
useFractionOfScreen=0.3;
tiltInDegrees = 7; % The tilt of the grating in degrees.
tiltInRadians = tiltInDegrees * pi / 180; % The tilt of the grating in radians.
pixelsPerPeriod = useFractionOfScreen*33; % How many pixels will each period/cycle occupy?
spatialFrequency = 1 / pixelsPerPeriod; % How many periods/cycles are there in a pixel?
radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)
periodsCoveredByOneStandardDeviation = 1.5;
gaussianSpaceConstant = periodsCoveredByOneStandardDeviation  * pixelsPerPeriod;
widthOfGrid = 400*useFractionOfScreen;
halfWidthOfGrid = widthOfGrid / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.
try
    Screen('Preference', 'SkipSyncTests', 1);
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    whichScreen = max(Screen('Screens'));
    % Shortcut: Check for Mac models that probably have AMD drivers.
    % This list is incomplete and hasn't been double checked. E.g. I
    % omitted the Mac Pro. This also misses any non-Mac computer with
    % high luminance precision. E.g. my hp linux computer.
    using11bpc=ismac && ismember(MacModelName,{'iMac14,1','iMac15,1',...
        'iMac17,1','iMac18,3','MacBookPro9,2','MacBookPro11,5',...
        'MacBookPro13,3','','MacBookPro14,3'});
    usePsychImaging=1;
    screenBufferRect = Screen('Rect',0);
    if useFractionOfScreen>0
        r=round(useFractionOfScreen*screenBufferRect);
        r=AlignRect(r,screenBufferRect,'right','bottom');
    else
        r=screenBufferRect;
    end
    if usePsychImaging
            PsychImaging('PrepareConfiguration');
            if using11bpc
                PsychImaging('AddTask','General','EnableNative11BitFramebuffer');
            end
            PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
            window=PsychImaging('OpenWindow',whichScreen,0,r);
    else
            window=Screen('OpenWindow',whichScreen,0,r);
    end
    black = BlackIndex(window);  % Retrieves the CLUT color code for black.
    white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
    gray = (black + white) / 2;  % Computes the CLUT color code for gray.
    absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
    [x,y] = meshgrid(widthArray, widthArray);
    a=cos(tiltInRadians)*radiansPerPixel;
    b=sin(tiltInRadians)*radiansPerPixel;
    gratingMatrix = sin(a*x+b*y);
    circularGaussianMaskMatrix = exp(-((x .^ 2) + (y .^ 2)) / (gaussianSpaceConstant ^ 2));
    imageMatrix = gratingMatrix .* circularGaussianMaskMatrix;
    grayscaleImageMatrix = gray + absoluteDifferenceBetweenWhiteAndGray * imageMatrix;
    Screen('FillRect', window, gray);
    Screen('PutImage', window, grayscaleImageMatrix);
    currentTextRow = 0;
    Screen('DrawText', window, sprintf('black = %d, white = %d', black, white), 0, currentTextRow, black);
    currentTextRow = currentTextRow + 20;
    Screen('DrawText', window, 'Press any key to exit.', 0, currentTextRow, black);
    Screen('Flip', window);
    KbWait;
    sca;
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
catch e
    sca;
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    rethrow(e);
end
