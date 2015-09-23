function state = rng(x, generator)
% used for octave compatibility with MATLAB

% Hörmet Yiltiz, hyiltiz@gmail.com 
% Copyright, 2015 
% Distributed under GPLv3+.
%

if IsOctave
    if nargin > 0
        if ischar(x)
            switch lower(x)
                case {'default'}
                    rand('seed', 0);
                case {'shuffle'}
                    rand('seed', time);
                otherwise
                    error('rng:char', 'Unknown method `%s` is specified', x);
            end
        end

        if nargin > 1
            % the generator is also specified
            if ~strcmpi(generator, 'twister')
                % this is implemented and default in octave
                warning('rng:generator', 'Only Mersenne Twister method is implemented!');
            end
        end

        if isnumeric(x)
            % set the random number Seed
            rand('seed', x);
        end
    end

    if nargout > 0
        state = rand('state');
    end

else
    % do nothing for MATLAB
    % we could actually use this function for MATLAB legacy compatibility
end
end
