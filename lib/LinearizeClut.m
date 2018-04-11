function newCal=LinearizeClut(cal)
% cal=LinearizeClut(cal);
% LINEARCLUT uses existing luminance measurements (made by
% CalibrateLuminance.m) to compute a CLUT "cal.gamma" that will linearize
% the display's luminance for a specified range of image pixel values. It's
% important to know each display has a hardware CLUT, and optionally, a
% software CLUT. When both are present your pixel value passes first
% through the software CLUT and then through the harware CLUT. You should
% load identity into the hardware CLUT and load the returned cal.gamma into
% the software CLUT. Your request the software CLUT by requesting
% EnableCLUTMapping when you open your window, and setting loadOnNextFlip=2
% in your request to LoadNormalizedGammaTable, to indicate that you're
% loading the software CLUT:
% Screen('LoadNormalizedGammaTable',screen,cal.gamma,loadOnNextFlip) In
% using the computed CLUT cal.gamma, you should not try to load it directly
% into your hardward CLUT, because most driver enforce smoothness of the
% hardware CLUT. (They save only the parameters of a smooth function fit to
% the CLUT table you provide). Instead you should load identity (which is
% smooth) into the hardware CLUT and load cal.gamma into the the software
% CLUT.
% Denis Pelli, NYU, July 5, 2014; February 21, 2017, April 2, 2017.
%
% INPUT FIELDS
% cal.clutMapLength is the desired length of the gamma table. This will
% typically be 1024 or 4096, to allow 10- or 12-bit precision.
% cal.old.gamma is the gamma table (i.e. color lookup table or CLUT, also
%      called color profile) when the luminance was calibrated.
% cal.old.G is the green DAC value used for luminance calibration
% cal.old.L is the luminance measured at that green DAC value.
% cal.nFirst is the first pixel value to be linearized.
% cal.nLast is the last. We insist that nLast>=nFirst.
% cal.LFirst is the desired luminance for pixel value nFirst.
% cal.LLast is the desired luminance for pixel value nLast.
% The only constraint on LFirst and LLast is that both must be in the
% measured range min(cal.old.L) to max(cal.old.L).
%
% Attempting to load a non-smooth function into the hardware CLUT is not
% recommended because the resulting CLUT table will be a smooth function,
% even if your request isn't. Our new approach is set the hardware CLUT to
% identify, and load cal.gamma into the software CLUT, which has no such
% restriction.
%
% OUTPUT FIELDS, IN ADDITION TO THE INPUT FIELDS
% cal.n are the pixel values, nFirst:nLast, for which new gamma table
% entries were created.
% cal.L is the linear sequence of luminances from LFirst to LLast.
% cal.gamma is the new gamma table ready for loading into the CLUT. It is
% created by copying cal.old.gamma and overwriting the n.L entries. If
% necessary, we try to force the calibration to be monotonic. This is a
% quick hack. It will convert monotone data to strictly monotone with
% hardly any change in value. It will replace a rogue low value with
% something reasonable, but, alas, it will propagate a rogue high value. I
% once wrote a simple program that makes a non-parametric monotone fit, and
% that would be a better solution, but careful calibrations are usually
% monotone, so this seems to be good enough. It may be better to remeasure
% than fix up a non-monotone calibration.
%
% See also CalibrateScreenLuminance, OurScreenCalibrations,
% testLuminanceCalibration, testGammaNull, IndexOfLuminance,
% LuminanceOfIndex.

checkLuminance=0; % optional diagnostic print out
checkLinearization=0; % optional diagnostic print out
if isfield(cal,'gamma')
   assert(size(cal.gamma,1)==cal.clutMapLength)
end
% If not strictly monotonic.
if ~all(diff(cal.old.L)>0)
   L=cal.old.L;
   % Try to make it strictly monotonic.
   for i=1:length(L)-1
      if L(i)>=L(i+1)
         L(i+1)=L(i)+100*eps;
      end
   end
   if ~all(diff(L)>0)
      fprintf('\nERROR. Your display''s calibration data saved as cal.old.L in\n');
      fprintf('OurScreenCalibrations.m are not strictly monotonic.\n');
      fprintf('This must be fixed, either by manual editing or by recalibrating\n');
      fprintf('with CalibrateScreenLuminance.\n');
      error('cal.old.L must be strictly monotonic. Couldn''t fix it. Sorry.');
   end
   cal.old.L=L;
end
if ~isfield(cal.old,'G') || ~isfield(cal.old,'gamma')
   error('Obsolete screen calibration. Run the latest CalibrateScreenLuminance.');
end
% If green channel of old gamma table is not strictly monotonic.
if ~all(diff(cal.old.gamma(:,2))>0)
   % If necessary, force monotonicity of the green channel of the old gamma table.
   g=cal.old.gamma(:,2);
   oldG=g;
   % Make it strictly monotonic
   for i=1:length(g)-1
      if g(i)>=g(i+1)
         g(i+1)=g(i)+100*eps;
      end
   end
   if ~all(diff(g)>0)
      fprintf('LinearizeClut: Nonmonotonic gamma table. Probably this is not an Apple profile.\n');
      fprintf('We suggest that you use Apple:System preferences:Displays:Color:Display profile:\n');
      fprintf('to select another profile and then reselect the profile you want.\n');
      error('Old gamma table not strictly monotonic. Couldn''t fix it. Sorry.\n');
   end
   cal.old.gamma(:,2)=g;
end
% In Apple's gamma table the RGB values are all gray. We stick to those
% gray RGB triplets that drive the video DAC. RGB are voltages in a video
% monitor. We analyze in terms of G channel, and then use the original RGB
% triplet corresponding to each G value.
%
% First make sure everything's reasonable.
assert(all(cal.old.G<=1) && all(cal.old.G>=0))
assert(length(cal.old.L)==length(cal.old.G))
assert(cal.nFirst<=cal.nLast);
assert(rem(cal.nFirst,1)==0 && rem(cal.nLast,1)==0);
assert(cal.nFirst<=cal.nLast);
cal.n=cal.nFirst:cal.nLast; % nFirst:nLast
cal.LFirst=min(cal.LFirst,max(cal.old.L));
if cal.LFirst-min(cal.old.L)<-0.1 % Ignore clipping of less than 0.1 cd/m^2 
    warning('Requested cal.LFirst %.1f clipped to %.1f cd/m^2.',cal.LFirst,min(cal.old.L));
end
cal.LFirst=max(cal.LFirst,min(cal.old.L));
if cal.LLast-max(cal.old.L)>0.1 % Ignore clipping of less than 0.1 cd/m^2 
    warning('Requested cal.LLast %.1f clipped to %.1f cd/m^2.',cal.LFirst,max(cal.old.L));
end
cal.LLast=min(cal.LLast,max(cal.old.L));
cal.LLast=max(cal.LLast,min(cal.old.L));
if cal.nLast==cal.nFirst
   cal.L=(cal.LFirst+cal.LLast)/2;
else
   cal.L=cal.LFirst+(cal.LLast-cal.LFirst)*(cal.n-cal.nFirst)/(cal.nLast-cal.nFirst); % linear series, cal.LFirst to cal.LLast
end
% Use G and L calibration data to compute the G channel, in one call to interp1.
cal.G=interp1(cal.old.L,cal.old.G,cal.L,'pchip'); % (takes 100 ms) interpolate green dac value G at luminance L
if any(isnan(cal.G))
   warning('Cubic interpolation failed. Switching to linear.');
   cal.G=interp1(cal.old.L,cal.old.G,cal.L); % the green dac value G at luminance cal.L
   if any(~isfinite(cal.G))
      error('Linear interpolation failed.');
   end
end
if checkLuminance
   % Use calibration data cal.old to compute the luminances produced by new gamma table.
   L=interp1(cal.old.G,cal.old.L,cal.G,'pchip');
   err=rms(cal.L-L);
   fprintf('Luminance %.3f to %.3f cd/m^2. rms error %.3f. ',cal.L([1,end]),err);
   dL=diff(L);
   fprintf('Luminance increment mean±sd %.4f±%.4f\n',mean(dL),std(dL));
end
% Interpolate index into cal.old.gamma of the green value G
index=interp1(cal.old.gamma(:,2),1:length(cal.old.gamma),cal.G,'pchip'); % (takes few ms)
% Interpolate RGB color (a white triplet) at the index of the luminance we want.
linearizedGamma=interp1(cal.old.gamma,index,'pchip'); % (takes few ms)
linearizedGamma=min(linearizedGamma,1);
linearizedGamma=max(linearizedGamma,0);
if ~isfield(cal,'gamma')
   % If new gamma not provided, take old gamma table as default,
   % interpolated to cal.clutMapLength entries. This mapping conserves
   % black (first) and white (last), and interpolates the rest. It can be
   % done quickly, using ROUND, or precisely, using INTERP1, which takes a
   % few ms.
   if ~isfield(cal,'clutMapLength')
      % If not specified, copied from old gamma table.
      cal.clutMapLength=size(cal.old.gamma,1);
   end
   cal.gamma=ones(cal.clutMapLength,3);
   oldMaxIndex=size(cal.old.gamma,1)-1;
   maxIndex=cal.clutMapLength-1;
   cal.gamma=cal.old.gamma(round(1+oldMaxIndex*(0:maxIndex)/maxIndex),1:3);
   %     cal.gamma=interp1(cal.old.gamma,1+oldMaxIndex*(0:maxIndex)/maxIndex),'pchip');
end
cal.gamma(1+cal.n,1:3)=linearizedGamma;
newCal=cal;
if checkLinearization
   err=rms(linearizedGamma(:,2)'-cal.G);
   fprintf('linearizedGamma range %.3f to %.3f with rms error %.3f\n',cal.G(1),cal.G(end),err);
   err=rms(cal.gamma(1+cal.n,2)'-cal.G);
   fprintf('gamma-G rms error %.3f\n',err);
   err=rms(cal.gamma(1+cal.n,2)'-cal.G);
   fprintf('cal.gamma-G %.3f to %.3f. rms error %.3f\n',cal.gamma(1+cal.n([1,end])),err);
   G=cal.gamma(1+cal.n,2)';
   err=rms(G-cal.G);
   fprintf('DAC value %.3f to %.3f. rms error %.3f\n',cal.G(1),cal.G(end),err);
   L=interp1(cal.old.G,cal.old.L,G,'pchip');
   err=rms(cal.L-L);
   fprintf('L %.3f to %.3f cd/m^2. rms error %.3f\n',cal.L([1,end]),err);
   dL=diff(L);
   fprintf('dL mean±sd %.4f±%.4f\n',mean(dL),std(dL));
end