%Script for testing/studying effects of noise in Object Recognition project.
%Author: Shivam Verma.

letterSizeDeg = 2; %ld
noiseContrast = [0.1,0.35,0]; %nc
noiseDecayRadius = [0.5,2,8,inf]; %ndr
eccentricityDeg = [0,2,8,32]; %ecc

%enumerate all possible 48 cases here
[ld,nc,ndr,ecc]=meshgrid(letterSizeDeg,noiseContrast,noiseDecayRadius,eccentricityDeg);
grid48=[ld(:) nc(:) ndr(:) ecc(:)]; %grid of all possible data enumerations.
grid96 = [grid48; grid48]; %each data point to be measured twice.
gridSize = size(grid96);
numIter = gridSize(1);

%do random sampling (without replacement) from 96 of these enumerations.
grid96 = grid96(randperm(numIter),:);

%may add functionality for pause/save/resume experiment.

%initialize object type 'o'
ob=funcNoiseParam(grid96(1,1),grid96(1,2),grid96(1,3),grid96(1,4));
ob=NoiseDiscrimination(ob);

%array of objects storing
objArray(numIter) = struct(ob);

%inside loop:
for i=1:numIter
    clear o;
    o=funcNoiseParam(grid96(i,1),grid96(i,2),grid96(i,3),grid96(i,4)); %funcNoiseParam(ld,nc,ndr,ecc);
    o=NoiseDiscrimination(o);
    objArray(i)=o;
    sca;
end

%output array has objects of type 'o' for all 96 data points.

%export array/data to .xls format for plotting. (TBD once know more about graph).