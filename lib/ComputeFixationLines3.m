function [fixationLines,fixationDots,isTargetLocationMarked]=ComputeFixationLines3(fix)
% [fixationLines,fixationDots,isTargetLocationMarked]=ComputeFixationLines3(fix);
%
% Now enhanced to support many targets at once. Thus eccentricityXYPix and
% targetHeightPix have one row per target. All targets are blanked by the
% same rules. For n targets:
% Must have n rows: eccentricityXYPix targetHeightPix
% Must have 1 or n rows: targetMarkPix isTargetLocationMarked
% Must have 1 row: the rest.
% The need for coping with many targets arises from randomly interleaving
% various conditions with different targets, and the use of
% o.uncertaintParameter to allow multiple values of o.eccentricityXYDeg
% within each condition. The fixation mark should not reveal which
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
%
% April, 2020. Added random dots (to aid accomodation) which receive the
% same blanking as the lines.
%% ONE FIXATION CROSS
% fix.xy=XYPixOfXYDeg(oo(1),[0 0]);     % screen location of fixation
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Diameter of fixation mark. 0 for none.
% fix.useFixationDots=oo(oi).useFixationDots;
% fix.fixationDotsNumber=oo(oi).fixationDotsNumber;
% fix.fixationDotsWithinRadiusPix=oo(oi).fixationDotsWithinRadiusDeg*oo(oi).pixPerDeg;
%% ONE X AND BLANKING PER TARGET. EACH ARRAY HAS ONE ROW PER TARGET.
% for oi=1:length(oo)
%     fix.eccentricityXYPix(oi,1:2)=oo(oi).eccentricityXYPix;  % xy offset of target from fixation.
%     fix.targetHeightPix(oi)=oo(oi).targetHeightPix;
% end
%% PROVIDE JUST ONE ROW (FOR ALL TARGETS) OR ONE ROW PER TARGET. RETURNS ONE ROW PER TARGET.
% fix.isTargetLocationMarked=true;      % false or true.
% fix.targetMarkPix=targetMarkPix;      % Diameter of target mark X
%% THE blankingRadiusPix FOR EACH TARGET DEPENDS ON THESE. EACH APPLIES TO ALL TARGETS.
% fix.fixationCrossBlankedNearTarget=true; 
% fix.blankingRadiusReEccentricity=0.5; % Default value.
% fix.blankingRadiusReTargetHeight=1; % Default value.
%% CALL IT.
% fixationLines=ComputeFixationLines3(fix);
%% DRAW IT AND SHOW IT.
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
% Screen('Flip',window);
%
% The many calls to round() don't noticeably affect the display. They are
% just to make the values easier to print while debugging.
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
% April 17.2020. Add 100 random dots (to aid accomodation) within a square
% area in which the fixation cross is inscribed.
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
if ~isfield(fix,'isTargetLocationMarked')
    % Default is no mark indicating target location.
   fix.isTargetLocationMarked=false([n 1]); 
end
switch length(fix.isTargetLocationMarked)
    case 1
        for i=2:n
            fix.isTargetLocationMarked(i)=fix.isTargetLocationMarked(1);
        end
    case n
        % Ok
    otherwise
    error('fix.isTargetLocationMarked should have 1 or %d rows, but has %d.',n,size(fix.isTargetLocationMarked,1));
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
fix.xy=round(fix.xy); % Printout is more readable for integers.
%% FIXATION
x0=fix.xy(1);
y0=fix.xy(2);

%% SCATTER RANDOM DOTS TO HELP OBSERVER FOCUS ON SCREEN.
if fix.useFixationDots
    if fix.fixationDotsNumber~=round(fix.fixationDotsNumber) || fix.fixationDotsNumber<0
        error('fix.fixationDots must be a positive integer.');
    end
    % Rect r is the requested dot region, which might extend far beyond
    % screen.
    r=fix.fixationDotsWithinRadiusPix*[-1 -1 1 1];
    r=OffsetRect(r,x0,y0); % Center on fixation.
    % Clip to allowed area (typically full screen).
    r=ClipRect(r,fix.clipRect);
    % Size of dot region rect.
    [rSizeXY(1),rSizeXY(2)]=RectSize(r);
    % Uniform samples, range 0 to 1.
    fixationDots=rand([2 fix.fixationDotsNumber]);
    % Scale and shift, so dots are uniformly scattered over rect.
    fixationDots=fixationDots .* rSizeXY'+r(1:2)';
    fixationDots=round(fixationDots); % Easier to view integers when debugging.
else
    fixationDots=[];
end

% Compute a list of 2+2*n lines to draw a cross at fixation and an X at
% each of the n target locations. We clip with the (screen) clipRect. We
% then define a blanking rect around each target and use it to
% ErasePartOfLineSegment for all the lines in the line list (and all the
% dots in the dot list). This may increase or decrease the list length.
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
        fix.isTargetLocationMarked(i)=false;
        continue
    end
    assert(isfinite(fix.blankingRadiusPix(i)));
    if fix.isTargetLocationMarked
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
    if fix.blankingRadiusPix(i)>0
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
        if ~isempty(x)
            [x,y]=ErasePartOfLineSegment(x,y,blankingRect);
        end
        %    'Marks, after blanking'
        %    x
        %    y
        %    blankingRect
        
        %% BLANK THE DOTS
        for iDot=size(fixationDots,2):-1:1
            if IsInRect(fixationDots(1,iDot),fixationDots(2,iDot),blankingRect)
                % Delete this point because it's in blankingRect.
                fixationDots(:,iDot)=[];
            end
        end
    end
end
fixationLines=[x;y];
% fixationDots; 
isTargetLocationMarked=fix.isTargetLocationMarked;
return
