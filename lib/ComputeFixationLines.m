function fixationLines=ComputeFixationLines(fix)
%ComputeFixationLines returns an array fixationLines so that calling
% Screen('DrawLines',window,fixationLines); 
% will draw fixation cross and mark target location as specified by the
% parameters in the struct argument "fix".
% fix.x=50;                             % x location of fixation on screen.
% fix.y=screenHeight/2;                 % y location of fixation on screen.
% fix.targetXYPix=o.targetXYPix;        % Target position on screen.
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
%                                       % target height. That's a good
%                                       % value for letters, which are
%                                       % strong right up to the edge of
%                                       % the target height. For gabors,
%                                       % which are greatly diminished
%                                       % there, I recommend a value of
%                                       % 0.5.
% fix.targetHeightOverWidth=1;          % 1 for Sloan. 5 for Pelli font.
% fix.targetHeightPix=targetHeightPix;  % Blanking radius is proportional
%                                       % to specified target height.
% fix.isTargetLocationMarked=true;          % Draw vertical line indicating
%                                       % target location.
% fixationLines=ComputeFixationLines(fix);
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with fixation or target being
% off screen.
% April 18, 2017. Enhanced to accept targetXYPix instead of
% eccentricityPix. It will correctly mark any target location. The
% computation of blanking of the fixation lines naively assumes target is
% on horizontal midline. So blanking will be wrong for targets off the
% midline. I should fix that if we start collecting a lot of data off the
% midline. FUTURE ENHANCEMENT: Allow for target anywhere. Compute line
% assuming target at (eccentricity,0), and then rotate coordinates about
% fixation.

if ~isfield(fix,'bouma') || ~isfinite(fix.bouma)
    fix.bouma=0.5;
end
if ~isfield(fix,'isTargetLocationMarked')
    fix.isTargetLocationMarked=false; % Default is no vertical line indicating target location.
end
if ~isfield(fix,'fixationCrossBlankedNearTarget')
    fix.fixationCrossBlankedNearTarget=1; % Default is yes.
end
if ~isfield(fix,'blankingRadiusReTargetHeight')
    fix.blankingRadiusReTargetHeight=1.5; % Blank a radius of 1.5 times target height.
end
blankingRadiusPix=fix.blankingRadiusReTargetHeight*fix.targetHeightPix;

% We initially take only the length of the eccentricity vector, and compute
% our lines as though fixation were at (0,0) and the eccentricity were
% positive and horizontal. At the end, we adjust for the direction of
% eccentricity and the actual location of fixation (fix.x,fix.y).

fix.eccentricityPix = sqrt(sum((fix.targetXYPix-[fix.x fix.y]).^2));

% Shift clipping rect to our new coordinate system in which fixation is
% at (0,0).
r=OffsetRect(fix.clipRect,-fix.x,-fix.y);

% Horizontal line indicating fixation 
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
xy=fix.targetXYPix;
if fix.isTargetLocationMarked && IsInRect(xy(1),xy(2),fix.clipRect);
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
    elseif lineStart < -blankingRadiusPix
        % blank breaks the line
        fixationLinesV(1:2,1:2)=[0 0; lineStart -blankingRadiusPix];
        fixationLinesV(1:2,3:4)=[0 0; blankingRadiusPix lineEnd];
    else
        % whole line is blanked
        fixationLinesV=[0 0;0 0];
    end
    xy=fix.targetXYPix-[fix.x fix.y];
    fixationLinesV(1,:)=fixationLinesV(1,:)+xy(1); % target eccentricity
    fixationLinesV(2,:)=fixationLinesV(2,:)+xy(2); % target eccentricity
    fixationLines=[fixationLines fixationLinesV];
end

% Shift everything to desired location of fixation.
fixationLines(1,:)=fixationLines(1,:)+fix.x;
fixationLines(2,:)=fixationLines(2,:)+fix.y;
end