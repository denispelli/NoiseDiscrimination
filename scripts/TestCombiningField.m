% TestCombiningField
% Saving and reusing of the ideal E/N threshold was Nick Bauch's idea.
% We run the ideal in advance, and then provide it as a reference when
% testing human observers. It doesn't take long to run, so you might wish
% to run it before each human session.
clear all
eccentricities=[0 4 8 16 32];
o.blockNumber=0;
o.blocksDesired=length(eccentricities);
for eccentricity=Shuffle(eccentricities)
    o.blockNumber=o.blockNumber+1;
    o.eccentricityDeg=eccentricity;
    o.distanceCm=50; % viewing distance
    o.signalKind='luminance'; % display a luminance decrement instead of a noise increment.
    o.durationSec=0.2;
    %     o.durationSec=inf;
    o.noiseSD=0;
    o.noiseType='gaussian';
    o.targetHeightDeg=2;
    o.noiseCheckDeg=0.1*o.targetHeightDeg;
    o.useFlankers=0;
    switch o.targetHeightDeg
        % These values are for using 9 letters of the Sloan font.
        % In general, ideal threshold depends on the number of letters and the font.
        case {2,1}
            o.idealEOverNThreshold = 13.4;
        case 4
            o.idealEOverNThreshold = 13.0;
        case  8
            o.idealEOverNThreshold = 14.8;
        otherwise
            o.idealEOverNThreshold = nan;
    end
    if ~isfield(o,'idealEOverNThreshold') || ~isfinite(o.idealEOverNThreshold)
        o.observer='ideal';
        o.trialsPerBlock=1000;
        o=NoiseDiscrimination(o);
        o.idealEOverNThreshold=o.EOverN;
    end
    o.trialsPerBlock=40;
    o.observer='jacob';
    o.observer='nick';
    o.observer='junk';
    o=NoiseDiscrimination(o);
    if ~o.runAborted
        % By Nick Bauch
        % Save stats for easy viewing
        fileName = strcat(o.observer,'-targetHeightDeg',num2str(o.targetHeightDeg,1),'Ratio',num2str(o.noiseToTargetRatio));
        myFid=fopen(fileName,'a');
        % The E/N value is always valid. The efficiency will be NaN when we
        % fail to provide the ideal threshold.
        fprintf(myFid,'%f\t%f\t%f\t%f\n',o.eccentricityDeg, 10^mean(log10(o.EOverN)), mean(o.efficiency),std(o.efficiency)/sqrt(length(o.efficiency)));
        fclose(myFid);
    end
    if o.quitNow
        break
    end
end
