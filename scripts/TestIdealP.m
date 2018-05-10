% TestIdealP
% Written by Denis Pelli June 24, 205 to confirm that IdealP is working
% properly. Looks fine.
clear all
o.block=0;
o.blocksDesired=1;
for height=2
    o.block=o.block+1;
    o.signalKind='luminance'; % display a luminance decrement instead of a noise increment.
    o.noiseSD=.2;
    o.noiseType='gaussian';
    o.targetHeightDeg=height;
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
    o.observer='ideal';
    o.trialsPerBlock=1000;
    o.replicatePelli2006=1;
    o=NoiseDiscrimination(o);
    if 0
        % Check computation of E/N.
        E1=zeros(1,length(o.signal));
        for i=1:length(o.signal)
            s=double(o.signal(i).image(:));
            E1(i)=dot(s,s);
        end
        E1=mean(E1);
        E=E1*o.contrast^2; % Measuring area in checks.
        N=o.noiseSD^2; % Measuring area in checks.
        EOverN=E/N;
        fprintf('log EOverN %.2f received %.2f derived. They should agree.\n',log10(o.EOverN),log10(EOverN));
    end
    [idealP,err]=IdealP(o.signal,o.contrast,o.noiseSD);
    if 0
        % Measure effect of requested tolerance.
        for tol=[1e-3 1e-4 1e-5]
            options.TolFun=tol;
            [idealP,err]=IdealP(o.signal,o.contrast,o.noiseSD,options);
            fprintf('tol %g, p %.6f, err %.6f\n',tol,idealP,err);
        end
    end
    fprintf('Threshold log(EOverN) %.2f at pThreshold %.3f. (p %.3f) Ideal p is %.3f at that EOverN.\n',log10(o.EOverN),o.pThreshold,o.p,idealP);
end
