%Author: Nick Blauch; Last edited: 10/18/2015
%This function uses the computeContrast function to solve for a power-integration model of
%threshold contrast, in the form: 
%threshold contrast = offset + scale*(sqrt(integrated noise power))
%sqrt(integrated noise power) is proportional to noise contrast and
%can be computed by the computeContrast function.
%This function returns the best-fit offset and scale.


function [offset,scale] = fitNoiseIntegrationGivenRadius(userThresholds,userRadii,integrationRadius)
    %set offset to the threshold contrast for the first decay radius (0)
    offset = userThresholds(1);
    
    thresholdFit = computeContrast(integrationRadius,userRadii);
    
    %find best scale factor
    counter = 0;
    contrast = zeros(length(userThresholds),length(0:.01:5));
    SE = zeros(length(0:.01:5),1);
    for scalar = 0:.01:5
        counter = counter + 1;
        contrast(:,counter) = offset + scalar*thresholdFit;
        SE(counter) = sum((userThresholds(:) - contrast(:,counter)).^2);
    end
    [minVal,indexOfMin] = min(SE);
    scalar = 0:.01:5;
    scale = scalar(indexOfMin);

end

