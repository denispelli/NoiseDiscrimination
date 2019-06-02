clear all
o.speakInstructions=1;
o.speakMute=0;
%Script to test effects of outside noise vs. inside noise. 
o.block=0;
% o.blocksDesired = 14;
o.blocksDesired = 1;
saveData = 1;
maskType = 'Crowding'; %choose from 'GeneralMask', 'OverlapMask', 'Crowding';
for run=1:o.blocksDesired
%     for noiseContrast = Shuffle([0 0 .01 .01 .02 .02 .04 .04 .08 .08 .16 .16 .32 .32])
        for noiseContrast = Shuffle([.2])

        o.noiseSD=noiseContrast;
        o.targetHeightDeg=2;
        o.eccentricityDeg=8;
%         o.eccentricityDeg=20;
        acuityDeg = .029*(o.eccentricityDeg + 2.72);
        criticalSpacingDeg = .3*(o.eccentricityDeg + .45);

        o.block= o.block + 1;
        o.useTinyWindow = 0;
        o.measureBeta = 0;
        o.beta = 1.7;
        o.distanceCm=50; % viewing distance
        o.signalKind='luminance'; % display a luminance decrement instead of a noise increment.
        o.showCropMarks=0;
        o.durationSec=inf;
        o.noiseType='gaussian';
        o.noiseCheckDeg=(1/10)*o.targetHeightDeg;
%         o.trialsInBlock =70 ; 
        o.trialsInBlock =50; 
        o.useFlankers=0;

        switch maskType
            case 'GeneralMask'
                noiseRadiusDeg=0;
                o.noiseHoleToTargetRatio=0;
                o.noiseToTargetRatio=1;
            case 'OverlapMask'
                o.noiseHoleToTargetRatio=1;
                noiseRadiusDeg = .5*acuityDeg; 
                o.noiseToTargetRatio = (2*noiseRadiusDeg+o.targetHeightDeg)/(o.targetHeightDeg);
            case 'Crowding'
                o.noiseHoleToTargetRatio = 1 + (acuityDeg)/o.targetHeightDeg;
                noiseRadiusDeg = 2;
                o.noiseToTargetRatio = o.noiseHoleToTargetRatio+ 2*noiseRadiusDeg/o.targetHeightDeg;
        end


        switch o.targetHeightDeg
            case .5
                o.idealEOverNThreshold = 14.5;
            case {2,1}
                o.idealEOverNThreshold = 13.4;
            case 4
                o.idealEOverNThreshold = 13.0;
            case  8
                o.idealEOverNThreshold = 10.3;
            otherwise
                o.idealEOverNThreshold = nan;
        end

        if ~isfinite(o.idealEOverNThreshold)
            o.observer='ideal';
            o.trials=1000;
            o.runs=1;
            o=NoiseDiscrimination(o);
            o.idealEOverNThreshold=o.EOverN;
        end
        o.observer='QiZhang';
        %o.observer = 'ideal';
        o.congratulateWhenDone=1; % You can turn this off, and Speak your own progress report in your main program.
        o=NoiseDiscrimination(o);
        if o.runAborted || ~saveData
            delete(strcat(o.datafilename,'.txt'));
            delete(strcat(o.datafilename,'.mat'));
        end
        if ~o.runAborted && saveData
            movefile(strcat(o.datafilename,'.txt'),'E1ContrastResponse/runs');
            movefile(strcat(o.datafilename,'.mat'),'E1ContrastResponse/runs');
            %%%change fileName below to your needs. 
            fileName = strcat('E1ContrastResponse/',o.observer,'-size',num2str(o.targetHeightDeg),'deg-ECC',num2str(o.eccentricityDeg),'deg-',maskType);
            myFid=fopen(fileName,'a');
            fprintf(myFid,'%f\t%f\n',o.noiseSD,abs(o.contrast));
            fclose(myFid);
        end
        if o.quitNow
            break
        end
    end
end