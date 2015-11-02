function fixationLines=ComputeFixationLines(fix)
%ComputeFixationLines returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target cross specified by the parameters in
% the struct argument "fix".
% fix.x=50;                             % x location of fixation on screen.
% fix.y=screenHeight/2;                 % y location of fixation on screen.
% fix.eccentricityPix=eccentricityPix;  % Positive or negative horizontal
%                                       % offset of target from fixation.
%                                       % +inf or -inf is ok for offscreen
%                                       % fixation.
% fix.bouma=0.5;                        % Critical spacing multiple of
%                                       % eccentricity.
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Full width & height of fixation
%                                       % cross.
% fix.fixationCrossBlankedNearTarget=1; % 0 or 1. Blank the fixation line
%                                       % near the target. We blank within
%                                       % one critical spacing of the
%                                       % target location, left and right,
%                                       % i.e. from (1-bouma)*ecc to
%                                       % (1+bouma)*ecc, where ecc is
%                                       % target eccentricity. We also
%                                       % blank a radius proportional to
%                                       % target radius.
% fix.blankingRadiusReTargetHeight=1.5; % Make blanking radius 1.5 times
%                                       % target height.
% fix.targetHeightPix=targetHeightPix;  % Blanking radius is proportional
%                                       % to specified target height.
% fix.targetCross=1;                    % Draw vertical line indicating
%                                       % target location.
% fixationLines=ComputeFixationLines(fix);
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with fixation or target being
% off screen.
if ~isfield(fix,'bouma') || ~isfinite(fix.bouma)
    fix.bouma=0.5;
end
if ~isfield(fix,'targetCross')
    fix.targetCross=0; % Default is no vertical line indicating target location.
end
if ~isfield(fix,'fixationCrossBlankedNearTarget')
    fix.fixationCrossBlankedNearTarget=1; % Default is yes.
end
if ~isfield(fix,'blankingRadiusReTargetRadius')
    fix.blankingRadiusReTargetHeight=1.5; % Blank a radius of 1.5 times target height.
end
blankingRadiusPix=fix.blankingRadiusReTargetHeight*fix.targetHeightPix;

% We initially use abs(eccentricity) and assume fixation is at (0,0). At
% the end, we adjust for polarity of eccentricity and the actual location
% of fixation (fix.x,fix.y).

% Shift clipping rect to our new coordinate system in which fixation is
% at (0,0).
r=OffsetRect(fix.clipRect,-fix.x,-fix.y);

% Horizontal line
lineStart=-fix.fixationCrossPix/2;
lineEnd=fix.fixationCrossPix/2;
lineStart=max(lineStart,r(1)); % clip to fix.clipRect
lineEnd=min(lineEnd,r(3)); % clip to fix.clipRect
if fix.fixationCrossBlankedNearTarget
    blankStart=min(abs(fix.eccentricityPix)*(1-fix.bouma),abs(fix.eccentricityPix)-blankingRadiusPix);
    blankEnd=max(abs(fix.eccentricityPix)*(1+fix.bouma),abs(fix.eccentricityPix)+blankingRadiusPix);
else
    blankStart=lineStart-1;
    blankEnd=blankStart;
end
fixationLines=[];
if blankStart>=lineEnd || blankEnd<=lineStart
    % no overlap of line and blank
    fixationLines(1:2,1:2)=[lineStart lineEnd ;0 0];
elseif blankStart>lineStart && blankEnd<lineEnd
    % blank breaks the line
    fixationLines(1:2,1:2)=[lineStart blankStart ;0 0];
    fixationLines(1:2,3:4)=[blankEnd lineEnd;0 0];
elseif blankStart<=lineStart && blankEnd>=lineEnd
    % whole line is blanked
    fixationLines=[0 0;0 0];
elseif blankStart<=lineStart && blankEnd<lineEnd
    % end of line is not blanked
    fixationLines(1:2,1:2)=[blankEnd lineEnd ;0 0];
elseif blankStart>lineStart && blankEnd>=lineEnd
    % beginning of line is not blanked
    fixationLines(1:2,1:2)=[lineStart blankStart ;0 0];
else
    error('Impossible fixation line result. line %d %d; blank %d %d',lineStart,lineEnd,blankStart,blankEnd);
end
if fix.eccentricityPix<0
    fixationLines=-fixationLines;
end

% Vertical fixation line
if 0>=r(1) && 0<=r(3) % Fixation is on screen.
    lineStart=-fix.fixationCrossPix/2;
    lineEnd=fix.fixationCrossPix/2;
    lineStart=max(lineStart,r(2)); % clip to fix.clipRect
    lineEnd=min(lineEnd,r(4)); % clip to fix.clipRect
    fixationLinesV=[];
    if ~fix.fixationCrossBlankedNearTarget || abs(fix.eccentricityPix)>blankingRadiusPix
        % no blanking of line
        fixationLinesV(1:2,1:2)=[0 0;lineStart lineEnd];
    elseif lineStart<-blankingRadiusPix
        % blank breaks the line
        fixationLinesV(1:2,1:2)=[0 0; lineStart -blankingRadiusPix];
        fixationLinesV(1:2,3:4)=[0 0; blankingRadiusPix lineEnd];
    else
        % whole line is blanked
        fixationLinesV=[0 0;0 0];
    end
    fixationLines=[fixationLines fixationLinesV];
end

% Vertical target line
if fix.targetCross && fix.eccentricityPix>=r(1) && fix.eccentricityPix<=r(3)
    % Compute at eccentricity zero, and then offset to desired target
    % eccentricity.
    lineStart=-fix.fixationCrossPix/2;
    lineEnd=fix.fixationCrossPix/2;
    lineStart=max(lineStart,r(2)); % vertical clip to fix.clipRect
    lineEnd=min(lineEnd,r(4)); % vertical clip to fix.clipRect
    fixationLinesV=[];
    if ~fix.fixationCrossBlankedNearTarget
        % no blanking of line
        fixationLinesV(1:2,1:2)=[0 0;lineStart lineEnd];
    elseif lineStart<-blankingRadiusPix
        % blank breaks the line
        fixationLinesV(1:2,1:2)=[0 0; lineStart -blankingRadiusPix];
        fixationLinesV(1:2,3:4)=[0 0; blankingRadiusPix lineEnd];
    else
        % whole line is blanked
        fixationLinesV=[0 0;0 0];
    end
    fixationLinesV(1,:)=fixationLinesV(1,:)+fix.eccentricityPix; % target eccentricity
    fixationLines=[fixationLines fixationLinesV];
end

% Shift everything to desired location of fixation.
fixationLines(1,:)=fixationLines(1,:)+fix.x;
fixationLines(2,:)=fixationLines(2,:)+fix.y;
end