%Script for testing/studying effects of noise in Object Recognition project.
%Author: Shivam Verma.

letterSizeDeg = 2; %ld
noiseContrast = [0.1,0.35,0]; %nc
noiseDecayRadius = [0.5,2,8,inf]; %ndr
eccentricityDeg = 0;%[0,2,8,32]; %ecc
loop=0; %loop = 0 (no looping) or 1 (full loop). To be added - 0.5 means semi/pausable-looping.

%enumerate all possible 48 cases here
% ld=letterSizeDeg;
% [nc,ndr,ecc]=meshgrid(noiseContrast,noiseDecayRadius,eccentricityDeg);
% grid=[ld(:) nc(:) ndr(:) ecc(:)]; %grid of all possible data enumerations.
% grid2 = [grid; grid]; %each data point to be measured twice.
% gridSize = size(grid2);
% numIter = gridSize(1);

%do random sampling (without replacement) from 96 of these enumerations.
% grid2 = grid2(randperm(numIter),:);
% grid3 = grid2;
%may add functionality for pause/save/resume experiment.

if loop==1
    %initialize object type 'o'
    ob=funcNoiseParam(grid2(1,1),grid2(1,2),grid2(1,3),grid2(1,4));
    ob=NoiseDiscrimination(ob);

    %array of objects storing
    objArray(numIter) = struct(ob);

    %inside loop:
    for i=1:numIter
        clear o;
        o=funcNoiseParam(grid2(i,1),grid2(i,2),grid2(i,3),grid2(i,4)); %funcNoiseParam(ld,nc,ndr,ecc);
        o=NoiseDiscrimination(o);
        objArray(i)=o;
        sca;
    end
elseif loop==0
    clear o;
    %currIter=1;
    %o = funcNoiseParam(grid3(currIter,1),grid3(currIter,2),grid3(currIter,3),grid3(currIter,4));
    o = funcNoiseParam(2,0.1,2,32);
    o = NoiseDiscrimination(o);
end
    
%output array has objects of type 'o' for all 96 data points.

%export array/data to .xls format for plotting. (TBD once know more about graph).