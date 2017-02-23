% Test my linearization software and luminance calibration by displaying a
% 3 c/deg grating made up alternating stripes. One stripe has alternating
% pixels of white and black. The other stripe is a uniform gray selected,
% from prior photometry, to have a luminance equal to the average of white
% and black.
% Denis Pelli, July 2015.
try
    distanceCm=50;
    screen=0;
    spatialFrequencyCyclesPerDeg=3; % for best contrast sensitivity
    BackupCluts;
    Screen('Preference', 'SkipSyncTests', 1);
    AutoBrightness(screen,0);
    Screen('ConfigureDisplay','Brightness',screen,[],1);
    [screenWidthMm,screenHeightMm]=Screen('DisplaySize',screen);
    screenRect=Screen('Rect',screen,1);
    pixPerCm=RectWidth(screenRect)/(0.1*screenWidthMm);
    degPerCm=57/distanceCm;
    pixPerDeg=pixPerCm/degPerCm;
    periodPix=pixPerDeg/spatialFrequencyCyclesPerDeg;
    periodPix=2*round(periodPix/2);
    cal=OurScreenCalibrations(0);
    cal.nFirst=3;
    cal.nLast=253;
    cal.LFirst=min(cal.old.L);
    cal.LLast=max(cal.old.L);
    cal.margin=1; % CLUT margin to work around CLUT smoothing.
    cal=LinearizeClut(cal);
    Screen('LoadNormalizedGammaTable',0,cal.gamma);
    WaitSecs(0.1);
    [cal.loadedGamma,dacBits,realLUTSize] = Screen('ReadNormalizedGammaTable',0);
    LMean=(cal.LFirst+cal.LLast)/2;
    width=RectWidth(screenRect);
    height=RectHeight(screenRect);
    imageL=[cal.LFirst cal.LLast;LMean LMean]
    imageI=IndexOfLuminance(cal,imageL)
    imageEstimate=EstimateLuminance(cal,imageI)
    image=repmat(imageI,ceil(height/2/periodPix),ceil(width/2));
    image=Expand(image,1,periodPix);
    image=image(1:height,1:width);
    [w,screenRect]=Screen('OpenWindow',screen,255,[],[],[],[],[],kPsychNeedRetinaResolution);
    texture=Screen('MakeTexture',w,image);
    Screen('DrawTexture',w,texture);
    Screen('Close',texture);
    nSteps = 8;
    rampHeight = ceil(height*2/3);
    rampL = linspace(cal.LFirst,cal.LLast,nSteps);
    ramp = reshape(repmat(rampL, [width/nSteps 1]), 1, []);
    ramp = repmat(ramp, [rampHeight 1]);
    ramp = IndexOfLuminance(cal, ramp);
    texture=Screen('MakeTexture',w,ramp);
    rampRect = screenRect;
    rampRect(2) = rampRect(4)-rampHeight;
    Screen('DrawTexture',w,texture,RectOfMatrix(ramp),rampRect);
    Screen('Close',texture);
    for i=1:nSteps
        if i==1
            color=255;
        else
            color=0;
        end
        Screen('DrawText',w,sprintf('%.1f cd/m^2',rampL(i)),(-0.8+i)*width/nSteps, height-40,color);
    end
    Screen('Flip',w);
    Speak('Click to quit');
    GetClicks;
    sca;
catch
    sca
    psychrethrow(psychlasterror);
end