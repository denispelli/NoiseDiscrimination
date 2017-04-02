o.useFractionOfScreen=0.2;
o.desiredClutMargin=1;
loadOnNextFlip = 2; % REQUIRED for reliable LoadNormalizedGammaTable.
cal.screen = o.screen;
if cal.screen > 0
    fprintf('Using external monitor.\n');
end
cal = OurScreenCalibrations(cal.screen);
screenBufferRect = Screen('Rect',o.screen);
screenRect = Screen('Rect',o.screen,1);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseRetinaResolution');
PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize, high res
if ~o.useFractionOfScreen
   [window, r] = PsychImaging('OpenWindow',cal.screen,255);
else
   [window, r] = PsychImaging('OpenWindow',cal.screen,255,round(o.useFractionOfScreen*screenBufferRect));
end
LMin = min(cal.old.L);
LMax = max(cal.old.L);
LMean = mean([LMin, LMax]); % Desired background luminance.
cal.LFirst = LMin;
cal.LLast = LMean+(LMean-LMin); % Symmetric about LMean.
firstGrayClutEntry=4;
lastGrayClutEntry=252;
cal.nFirst = firstGrayClutEntry;
cal.nLast = lastGrayClutEntry;
cal.clutMargin = o.desiredClutMargin;
cal = LinearizeClut(cal);
Screen('LoadNormalizedGammaTable',window,cal.gamma,loadOnNextFlip);
iTest=1;
test=[];
for iPix=cal.nFirst:cal.nLast
   Screen('FillRect',window,iPix);
   Screen('Flip',window);
   test(iTest).i=iPix;
   test(iTest).G=cal.gamma(iPix,2);
   WaitSecs(0.01);
   test(iTest).LNominal=EstimateLuminance(cal,iPix);
   test(iTest).L=test(iTest).LNominal; % Read photometer
   iTest=iTest+1;
end
Screen('Close',window);
plot([test.G],[test.L]);

