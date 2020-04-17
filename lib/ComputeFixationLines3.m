function [fixationLines,markTargetLocation]=ComputeFixationLines3(fix)
% [fixationLines,markTargetLocation]=ComputeFixationLines3(fix);
%
% Now enhanced to support many targets at once. Thus eccentricityXYPix and
% targetHeightPix have one row per target. All targets are blanked by the
% same rules. For n targets, 
% Must have n rows: eccentricityXYPix targetHeightPix
% Must have 1 or n rows: targetMarkPix markTargetLocation
% Must have 1 row: the rest.
% The need for this arises from randomly interleaving various conditions
% with different targets. The fixation mark should not reveal which
% condition this trial is, so any marking of target locations and blanking
% near target locations must consider all possible target locations across
% the conditions being interleaved, without regard to which condition this
% trial is. Here we merely accept and process multiple target locations.
%
% ComputeFixationLines3 returns an array "fixationLines" suitable for
% Screen('Drawlines',window,fixationLines) to draw a cross at fixation and
% (optionally) an X at each target location, as specified by the parameters
% in the struct argument "fix". It also optionally blanks a square area
% centered on each target. The blanking radius can depend on target size
% and eccentricity, to avoid masking and crowding of the targets by the
% fixation marks.
%
% "fixationLines" has two rows, x and y. Each column is a point. Each pair
% of columns specifies a line.
%% ONE FIXATION CROSS
% fix.xy=XYPixOfXYDeg(oo(1),[0 0]);         % screen location of fixation
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Diameter of fixation mark. 0 for none.
%% ONE X AND BLANKING PER TARGET. EACH ARRAY HAS ONE ROW PER TARGET.
% for oi=1:length(oo)
%     fix.eccentricityXYPix(oi,1:2)=oo(oi).eccentricityXYPix;  % xy offset of target from fixation.
%     fix.targetHeightPix(oi)=oo(oi).targetHeightPix;
% end
%% PROVIDE JUST ONE ROW (FOR ALL TARGETS) OR ONE ROW PER TARGET. RETURNS ONE ROW PER TARGET.
% fix.markTargetLocation=true;          % false or true.
% fix.targetMarkPix=targetMarkPix;      % Diameter of target mark X
%% THE blankingRadiusPix FOR EACH TARGET DEPENDS ON THESE. JUST ONE FOR ALL TARGETS.
% fix.fixationCrossBlankedNearTarget=true; 
% fix.blankingRadiusReEccentricity=0.5; % This is the default value.
% fix.blankingRadiusReTargetHeight=1; % This is the default value.
%% CALL IT.
% fixationLines=ComputeFixationLines2(fix);
%% DRAW IT AND SHOW IT.
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
% Screen('Flip',window);
%
% The many calls to round() don't noticeably affect the display. They are
% just to make the values easier to print, while debugging.
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with off-screen fixation or target.
% March 14, 2016. Completely rewritten for arbitrary location of fixation
% and target, using my new ClipLineSegment and ErasePartOfLineSegment
% routines.
% June 28, 2017. The new code is general, and works correctly for any
% locations of fixation and target. The target mark is now an X, to
% distinguish it from the fixation cross.
% February 18, 2020. Now support the logical flag 
% fix.fixationCrossBlankedNearTarget.
% April 12, 2020. Now accept more than one target, and blank for each. The
% main use of this is for randomly interleaving conditions with different
% targets, where we must use the same fixation marks for all, so that
% fixation does not reveal which condition is coming. Thus we blank
% fixation near all the possible targets (not just the one for the current
% condition), and thus the fixation mark may evolve through the block as
% target properties (e.g. size) vary within a condition, but the fixation
% mark still won't reveal which condition this trial will pesent.
if isempty(fix.eccentricityXYPix)
    error('fix.eccentricityXYPix is empty.');
end
%% NUMBER OF TARGETS
n=size(fix.eccentricityXYPix,1); % One row per target.
%% JUST ONE
if ~isfield(fix,'fixationCrossBlankedNearTarget')
    % Default is yes.
    fix.fixationCrossBlankedNearTarget=true;
end
if ~fix.fixationCrossBlankedNearTarget
    % A request for no blanking.
    fix.blankingRadiusReTargetHeight=0;
    fix.blankingRadiusReEccentricity=0;
    fix.blankingRadiusPix=zeros(n,1);
end
if ~isfield(fix,'blankingRadiusReEccentricity')
    % Default ratio. This is what I usually want.
    o.blankingRadiusReEccentricity=0.5;
end
if ~isfield(fix,'blankingRadiusReTargetHeight')
    % Default ratio. This is what I usually want.
    o.blankingRadiusReTargetHeight=1;
end
%% fixationCrossPix
if ~isfield(fix,'fixationCrossPix') || isempty(fix.fixationCrossPix)
   fix.fixationCrossPix=100; 
end
switch length(fix.fixationCrossPix)
    case 1
        % ok
    otherwise
    error('fix.fixationCrossPix must be a scalar.');
end
if ~isfield(fix,'targetHeightPix')
    o.targetHeightPix=zeros(n,1);
end
if length(fix.targetHeightPix)~=n
    error('fix.targetHeightPix should have %d rows, but has %d.',n,size(fix.targetHeightPix,1));
end
if ~isfield(fix,'markTargetLocation')
    % Default is no mark indicating target location.
   fix.markTargetLocation=false([n 1]); 
end
switch length(fix.markTargetLocation)
    case 1
        for i=2:n
            fix.markTargetLocation(i)=fix.markTargetLocation(1);
        end
    case n
        % Ok
    otherwise
    error('fix.markTargetLocation should have 1 or %d rows, but has %d.',n,size(fix.markTargetLocation,1));
end
if ~isfield(fix,'targetMarkPix')
    % Default size.
   fix.targetMarkPix=100; 
end
switch length(fix.targetMarkPix)
    case 1
        for i=2:n
            fix.targetMarkPix(i)=fix.targetMarkPix(1);
        end
    case n
        % Ok
    otherwise
    error('fix.targetMarkPix should have 1 or %d rows, but has %d.',n,size(fix.targetMarkPix,1));
end
if ~isfield(fix,'blankingRadiusPix')
   % Default is max of specified blanking re target height and blanking re
   % eccentricity. Separately for each of n targets. This is what I usually
   % want.
   fix.blankingRadiusPix=zeros(n,1);
   for i=1:n
       eccentricityPix=norm(fix.eccentricityXYPix(i,1:2));
       fix.blankingRadiusPix(i)=fix.blankingRadiusReEccentricity*eccentricityPix; % 0 for no blanking.
       fix.blankingRadiusPix(i)=max(fix.blankingRadiusPix(i),fix.blankingRadiusReTargetHeight*fix.targetHeightPix(i));
   end
end
if size(fix.blankingRadiusPix,1)~=n
    error('fix.blankingRadiusPix should have %d rows, but has %d.',n,size(fix.blankingRadiusPix,1));
end
% Compute a list of 2+2*n lines to draw a cross at fixation and an X at
% each of the n target locations. We clip with the (screen) clipRect. We
% then define a blanking rect around each target and use it to
% ErasePartOfLineSegment for all the lines in the list. This may increase
% or decrease the list length.
fix.xy=round(fix.xy); % Printout is more readable for integers.
x0=fix.xy(1); % fixation
y0=fix.xy(2);
% Two lines create a cross at fixation.
x=[x0-fix.fixationCrossPix/2 x0+fix.fixationCrossPix/2 x0 x0];
y=[y0 y0 y0-fix.fixationCrossPix/2 y0+fix.fixationCrossPix/2];
for i=1:n
    % Mark each of n target locations.
    tXY=fix.xy+fix.eccentricityXYPix(i,1:2);
    tX=tXY(1);
    tY=tXY(2);
    % Skip if this "X" is completely blanked.
    if 2*fix.blankingRadiusPix(i)>=fix.targetMarkPix(i) % 2* converts radius to diameter.
        fix.markTargetLocation(i)=false;
        continue
    end
    assert(isfinite(fix.blankingRadiusPix(i)));
    if fix.markTargetLocation
        % Add two lines to mark target location.
        r=0.5*fix.targetMarkPix(i)/2^0.5;
        r=min(r,1e8); % Need finite value to draw tilted lines.
        % Add the "X" to the lines already in x and y.
        x=[x tX-r tX+r tX-r tX+r]; % Make an X.
        y=[y tY-r tY+r tY+r tY-r];
    end
end
%    'Fixation, and marks (at fixation and target), before clipping'
%    x0,y0
%    x
%    y
% Clip to active part of screen.
[x,y]=ClipLineSegment(x,y,fix.clipRect);
x=round(x);
y=round(y);
for i=1:n
    % Blank each target location.
    if ~isempty(x) && fix.blankingRadiusPix(i)>0
        % Blank near target.
        tXY=fix.xy+fix.eccentricityXYPix(i,1:2);
        tX=tXY(1);
        tY=tXY(2);
        blankingRect=[-1 -1 1 1]*fix.blankingRadiusPix(i);
        blankingRect=OffsetRect(blankingRect,tX,tY);
        blankingRect=round(blankingRect);
        %    'fixation cross pix'
        %    fix.fixationCrossPix
        %    'Fixation, and marks (at fixation and target), before blanking'
        %    x0,y0
        %    x
        %    y
        [x,y]=ErasePartOfLineSegment(x,y,blankingRect);
        %    'Marks, after blanking'
        %    x
        %    y
        %    blankingRect
    end
end
fixationLines=[x;y];
markTargetLocation=fix.markTargetLocation;
return
