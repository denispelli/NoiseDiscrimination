function gamma = computeGammaTable()
cal = OurScreenCalibrations();
firstGrayClutEntry=2;
lastGrayClutEntry=254;

gray=mean([firstGrayClutEntry lastGrayClutEntry]);  % Will be a CLUT color code for gray.
LMin=min(cal.old.L);
LMax=max(cal.old.L);
LMean=mean([LMin,LMax]); % Desired background luminance.

cal.LFirst=LMin;
cal.LLast=LMean+(LMean-LMin); % Symmetric about LMean.
cal.nFirst=firstGrayClutEntry;
cal.nLast=lastGrayClutEntry;
cal.screen = max(Screen('Screens'));
cal=LinearizeClut(cal);
end