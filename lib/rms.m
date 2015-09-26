function r = rms(a)
%RMS This function is included in MATLAB 2015a, but it was undefined in
% Nick's copy of MATLAB. Not sure why, but it's easy to include it here.
% Denis Pelli, June 1, 2015
    r=sqrt(mean(a.^2));
return
end

