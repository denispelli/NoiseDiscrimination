clear all
%% Last Google Doc page 1:1, MAX:1

%Script to test effects of outside noise vs. inside noise. 
o.block=0;
% o.blocksDesired = 14;
o.blocksDesired = 1;
saveData = 1;
maskType = 'GeneralMask'; %choose from 'GeneralMask', 'OverlapMask', 'Crowding';
for run=1:o.blocksDesired
%     for noiseContrast = Shuffle([0 0 .01 .01 .02 .02 .04 .04 .08 .08 .16 .16 .32 .32])
        for noiseContrast = Shuffle([.16])

        o.noiseSD=noiseContrast;
        o.targetHeightDeg=2;
%         o.eccentricityXYDeg=[8 0];
        o.eccentricityXYDeg=[20 0];
        acuityDeg = .029*(o.eccentricityXYDeg(1) + 2.72);
        criticalSpacingDeg = .3*(o.eccentricityXYDeg(1) + .15);

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
%         o.trialsDesired =70 ; 
        o.trialsDesired =50; 
        o.useFlankers=0;

                noiseRadiusDeg=0;
                o.noiseHoleToTargetRatio=0;
                o.noiseToTargetRatio=1;
%                 o.noiseToTargetRatio=20;



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
            fileName = strcat('E1ContrastResponse/',o.observer,'-size',num2str(o.targetHeightDeg),'deg-ECC',num2str(o.eccentricityXYDeg(1)),'deg-',maskType);
            myFid=fopen(fileName,'a');
            fprintf(myFid,'%f\t%f\n',o.noiseSD,abs(o.contrast));
            fclose(myFid);
        end
        if o.quitNow
            break
        end
    end
end


%% Google Docs: page 1, general, overlap and crowding
