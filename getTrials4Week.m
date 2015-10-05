function grid1b = getTrials4Week(WeekNumber)
    if nargin < 1
        error('Please provide a number for Week. See:\n https://github.com/hyiltiz/NoiseDiscrimination/wiki/How-to-collect-data');
    end

    switch WeekNumber
        case 1
            letterSize              = 2; %fixed letter degree
            noiseDecayRadius        = [0.5,2,8,inf]; %noise decay radius
            eccentricity            = [0,2,8,32]; %eccentricity
            noiseContrast           = [0.1,0.35,0]; %noise contrast takes values . 
            repeatPerCondition      = 2;

        case 2
            letterSize              = 2; %fixed letter degree
            noiseDecayRadius        = [2,sqrt(2*16),16]; %noise decay radius
            eccentricity            = [32]; %eccentricity
            noiseContrast           = [0.2]; %noise contrast takes values . 
            repeatPerCondition      = 2;

        otherwise
            error('Invalid week number %d', WeekNumber);

    end

    [ld2, ndr2, ecc2, nc2]=BalanceFactors(repeatPerCondition,true, letterSize, noiseDecayRadius, eccentricity, noiseContrast);
    grid1b=[nc2 ndr2 ecc2 ld2]; %creates 16x3 grid of parameters
    disp('`grid1b` is generated in workspace');
    disp('');

end
