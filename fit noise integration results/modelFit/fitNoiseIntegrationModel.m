%Author: Nick Blauch; Last edited: 11/02/2015
%This function uses the integratePower function to solve for a power-integration model of
%threshold contrast, in the form: 
%threshold contrast.^2 = offset + scale*integrated noise power
%This function returns the best-fit threshold contrast values, as well
% as the offset, scale, and integration radius used in calculation.
function [thresholdContrastFit,offset,scale,integrationRadius] = fitNoiseIntegrationModel(userThresholds,userRadii,noiseSD)
    %set offset to the average of all cases in which there is no noise
    Sum = 0;
    count = 0;
    for i = 1:length(userThresholds)
        if noiseSD(i) ==0 
            Sum = Sum + userThresholds(i).^2;
            count = count + 1;
        end
    end
    offset = Sum/count;
    
    intRadii = 0:.1:3; %integration radii to test
    scalars = 0:.01:10; %scale factors to test
    %initializing variables
    integratedPower = zeros(length(userThresholds),length(intRadii));
    squaredContrast = zeros(length(userThresholds),length(scalars));
    fitParameters = zeros(2,length(intRadii));
    %test a range of integration radii. for each radius tested, find the
    %optimal scale factor. save as a pair.
    for index=1:length(intRadii)
        integratedPower(:,index) = integratePower(intRadii(index),userRadii,noiseSD);
        SE = zeros(length(scalars),1);
        for index2 = 1:length(scalars)
            squaredContrast(:,index2) = offset + scalars(index2).*integratedPower(:,index);
            SE(index2,1) = sum((log10(userThresholds(:).^2) - log10(squaredContrast(:,index2))).^2);
        end
        
        [minVal,indexOfMin] = min(SE);
        fitParameters(1,index) = scalars(indexOfMin);
        fitParameters(2,index) = intRadii(index);
    end
    
    %Given pairs of (scale,integration radius), find the pair that
    %minimizes squared-error when compared against user input data.
    SE2 = zeros(length(intRadii),1);
    for index = 1:length(intRadii)
        finalSquaredContrast(:,index) = offset + fitParameters(1,index).*integratedPower(:,index);
        SE2(index) = sum((log10(userThresholds(:).^2) - log10(finalSquaredContrast(:,index))).^2);
    end
    [minVal,indexOfMin] = min(SE2);
    
    %Return the best-fit parameters
    scale = fitParameters(1,indexOfMin);
    integrationRadius = fitParameters(2,indexOfMin);
    thresholdContrastFit = sqrt(offset + scale*integratePower(integrationRadius,userRadii,noiseSD));
    SE = minVal;

end

