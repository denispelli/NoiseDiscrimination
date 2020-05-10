% PsychRandSample2 calls randi to create large arrays of noise, with millions
% of pixels. It's 3 or 4 times faster to use the generator 'simdTwister"
% than the default 'Twister'. 'simdTwister' is faster than the rest of the
% alternatives.

for g={'twister' 'simdTwister' 'combRecursive' 'philox' 'threefry' ...
        'multFibonacci' 'v5uniform' 'v5normal' 'v4'}
    rng(111,g{1});
    t=GetSecs;
    for i=1:10
        x=randi(3,[1000 1000]);
    end
    fprintf('%6.0f ms %s.\n',1000*(GetSecs-t), g{1});
end

% TestRandomSpeed
%     95 ms twister.
%     37 ms simdTwister.
%    153 ms combRecursive.
%    154 ms philox.
%     96 ms threefry.
%     55 ms multFibonacci.
%    113 ms v5uniform.
%     43 ms v5normal.
%     79 ms v4.