function newCal=LinearizeClut(cal)
% LINEARCLUT use existing luminance measurements to linearize the display's
% luminance relative to the pixel values in the image array.
% Denis Pelli, NYU, July 5, 2014
%
% INPUT FIELDS
% cal.old.gamma is the gamma table (i.e. color lookup table or CLUT) when the luminance was calibrated.
% If this field does not exist, it is initialized with old.gamma. 
% cal.old.n is the pixel values used for luminance calibration
% cal.old.L is the luminance measured at pixel value cal.old.n
% cal.nFirst is the first pixel value to be linearized, i.e. set gamma to yield LFirst.
% cal.nLast is the last. We insist that nLast>=nFirst.
% cal.LFirst is the desired luminance for pixel value nFirst.
% cal.LLast is the desired luminance for pixel value nLast. May be less than,
% equal to, or greater than cal.LFirst. Both LFirst and LLast are bounded
% to the interval min(cal.old.L) to max(cal.old.L).
%
% OUTPUT FIELDS, IN ADDITION TO THE INPUT FIELDS
% cal.n are the pixel values, nFirst:nLast, for which new gamma table
% entries were created.
% cal.L is the linear sequence of luminances from LFirst to LLast.
% cal.gamma is the new gamma table ready for loading into the CLUT. It is
% created by copying cal.old.gamma and overwriting the n.L entries.
% If necessary, try to force the calibration to be monotonic.
% This is a quick hack. It will convert monotone data to strictly monotone
% with hardly any change in value. It will replace a rogue low value with
% something reasonable, but it will propagate a rogue high value.
% I once wrote a simple program that makes a non-parametric monotone fit,
% and that would be a better solution, but careful calibrations are usually
% monotone, so this seems to be good enough. It may be better to remeasure
% than fix up a non-monotone calibration.
if ~all(diff(cal.old.L)>0)
    L=cal.old.L;
    % try to make it strictly monotonic
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
checkLuminance=0;
checkLinearization=0;
if ~isfield(cal.old,'gamma')
    cal.old.gamma=Screen('ReadNormalizedGammaTable',cal.screen); 
end
if ~all(diff(cal.old.gamma(:,2))>0)
    % If necessary, force monotonicity of the green channel of the old gamma table.
    g=cal.old.gamma(:,2);
    oldG=g;
    % make it strictly monotonic
    for i=1:length(g)-1
        if g(i)>=g(i+1)
            %g(i)=mean(g(i:i+1));
            g(i+1)=g(i)+100*eps;
        end
    end
    if ~all(diff(g)>0)
        fprintf('LinearizeClut: Nonmonotonic gamma table. Probably this is not an Apple profile.\n');
        fprintf('I suggest that you use Apple:System preferences:Displays:Color:Display profile:\n');
        fprintf('to select another profile and then reselect the profile you want.\n');
        error('Old gamma table not strictly monotonic. Couldn''t fix it. Sorry.\n');
    end
    cal.old.gamma(:,2)=g;
end
gammaMax=length(cal.old.gamma)-1; % index into gamma table is 0..gammaMax. 1023 on modern cards, 255 on old cards
% In apple's gamma table the RGB values are all gray. We stick to those
% gray RGB triplets that drive the video DAC. RGB are voltages in a video
% monitor. We analyze in terms of G channel, and then use the original RGB
% triplet corresponding to each G value.
assert(all(cal.old.n<=255) && all(cal.old.n>=0))
cal.old.vG=cal.old.gamma(round(1+cal.old.n*gammaMax/255),2); % green voltage of each pixel value.
assert(cal.nFirst<=cal.nLast);
assert(rem(cal.nFirst,1)==0 && rem(cal.nLast,1)==0);
cal.n=cal.nFirst:cal.nLast; % nFirst:nLast
cal.LFirst=min(cal.LFirst,max(cal.old.L));
cal.LFirst=max(cal.LFirst,min(cal.old.L));
cal.LLast=min(cal.LLast,max(cal.old.L));
cal.LLast=max(cal.LLast,min(cal.old.L));
if cal.nLast==cal.nFirst
    cal.L=(cal.LFirst+cal.LLast)/2;
else
    cal.L=cal.LFirst+(cal.LLast-cal.LFirst)*(cal.n-cal.nFirst)/(cal.nLast-cal.nFirst); % linear series, cal.LFirst to cal.LLast
end
cal.vG=interp1(cal.old.L,cal.old.vG,cal.L,'pchip'); % (takes 100 ms) interpolate green voltage vG at luminance L
if any(isnan(cal.vG))
    warning('Cubic interpolation failed. Switching to linear.');
    cal.vG=interp1(cal.old.L,cal.old.vG,cal.L); % the green voltage vG at luminance cal.L
    if any(~isfinite(cal.vG))
        error('Linear interpolation failed.');
    end
end
if checkLuminance
    L=interp1(cal.old.vG,cal.old.L,cal.vG,'pchip');
    err=rms(cal.L-L);
    fprintf('Luminance %.3f to %.3f cd/m^2. rms error %.3f. ',cal.L([1,end]),err);
    dL=diff(L);
    fprintf('Step mean±sd %.4f±%.4f\n',mean(dL),std(dL));
end
index=interp1(cal.old.gamma(:,2),1:length(cal.old.gamma),cal.vG,'pchip'); % (takes few ms) interpolate index in cal.old.gamma of the green voltage vG
linearizedGamma=interp1(cal.old.gamma,index,'pchip'); % (takes few ms) interpolate RGB voltages at the green voltage
linearizedGamma=min(linearizedGamma,1);
linearizedGamma=max(linearizedGamma,0);
if ~isfield(cal,'gamma')
    % if new gamma not provided, take old gamma table as default, scrunched
    % down to 256 entries.
    cal.gamma=ones(256,3);
    cal.gamma=cal.old.gamma(round(1+gammaMax*(0:255)/255),1:3);
end
cal.gamma(1+cal.n,1:3)=linearizedGamma;
newCal=cal;
if checkLinearization
    err=rms(linearizedGamma(:,2)'-cal.vG);
    fprintf('linearizedGamma-vG %.3f to %.3f. rms error %.3f\n',cal.vG(1),cal.vG(end),err);
    err=rms(cal.gamma(1+cal.n,2)'-cal.vG);
    fprintf('gamma-vG %.3f to %.3f. rms error %.3f\n',cal.vG(1),cal.vG(end),err);
    if 0
        % Consult actual gamma table.
        Screen('LoadNormalizedGammaTable',cal.screen,cal.gamma);
        gamma=Screen('ReadNormalizedGammaTable',cal.screen);
    else
        % consult the gamma table we made
        gamma=cal.gamma;
    end
    err=rms(cal.gamma(1+cal.n,2)'-cal.vG);
    fprintf('cal.gamma-vG %.3f to %.3f. rms error %.3f\n',cal.gamma(1+cal.n([1,end])),err);
    gamma8=cal.gamma(1+round((length(cal.gamma)-1)*(0:255)/255),2);
    err=rms(cal.gamma(1+cal.n,2)-gamma8(1+cal.n));
    fprintf('gamma %.3f to %.3f. rms error %.3f\n',cal.gamma(1+cal.n([1,end])),err);
    vG=gamma8(1+cal.n)';
    err=rms(vG-cal.vG);
    fprintf('Voltage %.3f to %.3f. rms error %.3f\n',cal.vG(1),cal.vG(end),err);
    L=interp1(cal.old.vG,cal.old.L,vG,'pchip');
    err=rms(cal.L-L);
    fprintf('L %.3f to %.3f cd/m^2. rms error %.3f\n',cal.L([1,end]),err);
    dL=diff(L);
    fprintf('dL mean±sd %.4f±%.4f\n',mean(dL),std(dL));
end