% Test my linearization software and luminance calibration by displaying a
% 2 c/deg grating made up alternating stripes. One stripe has alternating
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
    cal.LFirst=min(cal.old.L);
    cal.LLast=max(cal.old.L);
    LMean=(cal.LFirst+cal.LLast)/2;
    cal.nFirst=2;
    cal.nLast=254;
    cal=LinearizeClut(cal);
    width=RectWidth(screenRect);
    imageL=cal.LFirst*ones(1,width);
    odd=rem(1:width,2)==1;
    imageL(odd)=cal.LLast;
    image=IndexOfLuminance(cal,imageL);
    imageEstimate=EstimateLuminance(cal,image);
    [w,screenRect]=Screen('OpenWindow',screen,255,[],[],[],[],[],kPsychNeedRetinaResolution);
    texture=Screen('MakeTexture',w,image);
    Screen('DrawTexture',w,texture,RectOfMatrix(image),screenRect);
    Screen('Close',texture);
    stripeRect=screenRect;
    stripeRect(4)=periodPix/2;
    m=IndexOfLuminance(cal,LMean);
    while ~IsEmptyRect(ClipRect(stripeRect,screenRect))
        Screen('FillRect',w,m,stripeRect);
        stripeRect=OffsetRect(stripeRect,0,2*RectHeight(stripeRect));
    end
    Screen('LoadNormalizedGammaTable',0,cal.gamma);
    Screen('Flip',w);
    Speak('Click to quit');
    GetClicks;
    sca;
catch
    sca
    psychrethrow(psychlasterror);
end