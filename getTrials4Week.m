function grid1b = getTrials4Week(WeekNumber)
    if nargin < 1
        error('Please provide a number for Week. See:\n https://github.com/hyiltiz/NoiseDiscrimination/wiki/How-to-collect-data');
    end

    switch WeekNumber
        case 1
            letterSize              = 2; %fixed letter degree
            noiseDecayRadius        = [0.5,2,8,inf]; %noise decay radius
            eccentricity            = [0,2,8,32]; %eccentricity
            noiseContrast           = [0.1,0.35,0]; %noise contrast takes values.
            repeatPerCondition      = 2;

        case 2
            letterSize              = 2; %fixed letter degree
            noiseDecayRadius        = [2,sqrt(2*16),16]; %noise decay radius
            eccentricity            = [32]; %eccentricity
            noiseContrast           = [0.2]; %noise contrast takes values.
            repeatPerCondition      = 2;

        case 3
            letterSize              = [2,2*sqrt(3),6];
            noiseDecayRadius        = [1,sqrt(3),3,3*sqrt(3),9,Inf]; %noise decay radius
            eccentricity            = [0,32]; %eccentricity
            noiseContrast           = [0.16]; %noise contrast takes values.
            repeatPerCondition      = 2;

        case 4.1
          % please only use this set of parameters if and only if you
          % are sure to have collected the rest of the data required in
          % your previous weeks
          % Make sure to read the wiki on data collection first
            o.noiseSpectrum='pink'; % pink or white
            o.noiseType='uniform'; % 'gaussian' and 'uniform'
            o.targetCross=1;
            letterSize              = [2];
            noiseDecayRadius        = [1,sqrt(3),3,3*sqrt(3),9,Inf]; %noise decay radius
            eccentricity            = [32]; %eccentricity
            noiseContrast           = [0.16]; %noise contrast takes values.
            repeatPerCondition      = 2;

        case 4.2
          % please only use this set of parameters if and only if you
          % are sure to have collected the rest of the data required in
          % your previous weeks
          % Make sure to read the wiki on data collection first
            o.noiseSpectrum='pink'; % pink or white
            o.noiseType='uniform'; % 'gaussian' or 'uniform' or 'binary'
            letterSize              = [2];
            noiseDecayRadius        = [1]; %noise decay radius
            eccentricity            = [0]; %eccentricity
            noiseContrast           = [0.16]; %noise contrast takes values.
            repeatPerCondition      = 2;

        otherwise
            error('Invalid week number %d', WeekNumber);

    end

    [ld2, ndr2, ecc2, nc2]=BalanceFactors(repeatPerCondition,true, letterSize, noiseDecayRadius, eccentricity, noiseContrast);
    grid1b=[nc2 ndr2 ecc2 ld2]; %creates 16x3 grid of parameters
    disp('`grid1b` is generated in workspace');
    disp('');

end
