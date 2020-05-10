function [nativeResolution,confidence]=NativeResolution(screen)
% [nativeResolution,confidence]=NativeResolution(screen)
%
% You optionally specify the screen number (default 0 the main screen), and
% it returns "nativeResolution" which is a two-vector [width height] plus
% an integer rating of confidence, from 1 (low) to 3 (high).
%
% Modern LCD screens are built out of hardware pixels. Native resolution
% specifies how many. Modern drivers allow you specify other resolutions
% and it remaps. The Psychtoolbox Screen('Resolutions') command allows you
% to discover what resolutions are available, and switch to any of them.
% Best performance in terms of image quality and timing is often attained
% by running the experiment at native resolution. And any attempt to
% estimate the effect of the hardware resolution on image quality will be
% based on an estimate of the native resolution. Alas, there is currently
% no way, through software, to find out what a display's native resolution
% is. This routine is an effort toward filling that void. The brute force
% approach of listing model numbers is tedious, but still practical.
% Perhaps someone will discover a better way to determine native resolution
% through software. I wonder if one might look at the list of offered
% resolutons and deduce from the ratios within the list which one is native.
%
%% Estimating the screen's native resolution.
% First, we take the highest resolution in the device's list as an estimate
% of the native resolution. Alas, Mario Kleiner warns that this rule of
% thumb is not reliable, and I confirm that, finding that among the
% resolutions offered by Screen('Resolutions') for my 15" MacBook Pro is a
% resolution that is larger than the native resolution. Thus I consulted
% the apple documents and made an exhaustive table for 15" MacBook Pros
% with Retina display and 27" iMac. When possible, the table overrides the
% rule of thumb.

if nargin<1
    screen=0;
end
confidence=0;
if screen==0 && ismac
    %% LOOK UP NATIVE RES, IF TABULATED.
    switch MacModelName
        case {'iMac15,1' 'iMac17,1' 'iMac18,3' 'iMac19,1'}
            % iMac (Retina 5K, 27-inch, Mid 2015)
            % iMac (Retina 5K, 27-inch, Late 2015)
            % iMac (Retina 5K, 27-inch, 2017)
            % iMac (Retina 5K, 27-inch, 2019)
            % 27" iMac
            nativeResolution=[5120 2880];
        case {'MacBookPro10,1' 'MacBookPro11,2' 'MacBookPro11,3' ...
                'MacBookPro11,4' 'MacBookPro11,5' 'MacBookPro13,3' ...
                'MacBookPro14,3' 'MacBookPro15,1' 'MacBookPro15,3'}
            % 15" MacBook Pro
            nativeResolution=[2880 1800];
        case 'MacBookPro16,1'
            % 16" MacBook Pro
            nativeResolution=[3072 1920];
    end
    confidence=3; % Based on Apple's official specs. Reliable.
end
if confidence<1
    %% FIND MAX RES, AS ESTIMATE OF NATIVE RES.
    res=Screen('Resolutions',screen);
    nativeResolution=[0 0];
    for i=1:length(res)
        if res(i).width>nativeResolution(1)
            nativeResolution=[res(i).width res(i).height];
        end
    end
    confidence=1; % A rule of thumb, known to be slightly wrong in some cases.
end

