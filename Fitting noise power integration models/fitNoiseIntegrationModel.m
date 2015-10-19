%Author: Nick Blauch; Last edited: 10/18/2015
%This function uses the computeContrast function to solve for a power-integration model of
%threshold contrast, in the form: 
%threshold contrast = offset + scale*(sqrt(integrated noise power))
%sqrt(integrated noise power) is proportional to noise contrast and
%can be computed by the computeContrast function.
%This function returns the best-fit offset, scale, and integration radius


function [offset,scale,integrationRadius] = fitNoiseIntegrationModel(userThresholds,userRadii)
    %set offset to the threshold contrast for the first decay radius (0)
    offset = userThresholds(1);

    intRadii = 0:.1:4; %integration radii to test
    scalars = 0:.01:1; %scale factors to test
    %initializing variables
    contrastFit = zeros(length(userThresholds),length(intRadii));
    contrast = zeros(length(userThresholds),length(scalars));
    fitParameters = zeros(2,length(intRadii));
    %test a range of integration radii. for each radius tested, find the
    %optimal scale factor. save as a pair.
    for index=1:length(intRadii)
        contrastFit(:,index) = computeContrast(intRadii(index),userRadii);
        SE = zeros(length(scalars),1);
        for index2 = 1:length(scalars)
            contrast(:,index2) = offset + scalars(index2)*contrastFit(:,index);
            SE(index2) = sum((userThresholds(:) - contrast(:,index2)).^2);
        end
        
        [minVal,indexOfMin] = min(SE);
        fitParameters(1,index) = scalars(indexOfMin);
        fitParameters(2,index) = intRadii(index);
    end
    
    %Given pairs of (scale,integration radius), find the pair that
    %minimizes squared-error when compared against user input data.
    SE2 = zeros(length(intRadii),1);
    for index = 1:length(intRadii)
        finalContrast(:,index) = offset + fitParameters(1,index)*contrastFit(:,index);
        SE2(index) = sum((userThresholds(:) - finalContrast(:,index)).^2);
    end
    [minVal,indexOfMin] = min(SE2);
    
    %Return the best-fit parameters
    scale = fitParameters(1,indexOfMin);
    integrationRadius = fitParameters(2,indexOfMin);
    

end
