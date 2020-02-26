function [noise,range]=MakeNoise(noiseType,dims)
% [noise,range,noiseList]=MakeNoise(noiseType,dims)
% Quickly produce independent random samples of specified type and array
% shape. All samples have zero mean and unit variance.

% Hormet Yiltiz contributed to the gaussian code.
% denis.pelli@nyu.edu, February 2020.

switch noiseType
    case {'binary' 'ternary'}
        switch noiseType
            case 'binary'
                list=[-1 1];
            case 'ternary'
                list=[-1 0 1];
        end
        sd=std(list,1); % Over all samples.
        list=list/sd; % Normalize so SD is 1.
        range=[list(1) list(end)]/sd;
        noise=PsychRandSample(list,dims);
    case 'uniform'
        noise=rand(dims)-0.5; % Zero mean, uniform distribution.
        sd=0.2887; % accurate to 4 decimal places.
        noise=noise/sd;
        range=[-0.5 0.5]/sd;
    case 'gaussian'
        n=prod(dims);
        noise=[];
        while numel(noise)<n
            % We discard the 10% that are out of range, so we ask for more
            % samples than we need, so that we usually get enough in the
            % first request.
            m=10+round(1.5*(n-numel(noise)));
            new=randn([1 m]);
            select = -2<new & new<2;
            noise=[noise new(select)];
        end
        % Use only what we need.
        noise=reshape(noise(1:n),dims);
        sd=0.8796; % accurate to 4 decimal places.
        noise=noise/sd;
        range=[-2 2]/sd;
end
