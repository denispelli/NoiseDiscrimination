fitNoiseIntegrationModel <- function(userThresholds,userRadii){
#set offset to the threshold contrast for the first decay radius (0)
offset = userThresholds(1);

intRadii <- seq(0,4,by=.1)	#integration radii to test
scalars <- seq(0,1,by=.01)	#scale factors to test
#initializing variables
contrastFit <- matrix(0,length(userThresholds),length(intRadii))
contrast <- matrix(0,length(userThresholds),length(scalars));
fitParameters <- matrix(0,2,length(intRadii));
#test a range of integration radii. for each radius tested, find the
#optimal scale factor. save as a pair.
for (index in 1:length(intRadii)){
  contrastFit[,index] <- computeContrast(intRadii(index),userRadii);
  SE <- zeros(length(scalars),1);
  for (index2 in 1:length(scalars)){
    contrast(,index2) <- offset + scalars(index2)*contrastFit(:,index);
    SE(index2) <- sum((userThresholds(:) - contrast(:,index2)).^2);
  }

  [minVal,indexOfMin] <- min(SE);
  fitParameters(1,index) <- scalars(indexOfMin);
  fitParameters(2,index) <- intRadii(index);
}

#Given pairs of (scale,integration radius), find the pair that
#minimizes squared-error when compared against user input data.
SE2 = zeros(length(intRadii),1);
for index = 1:length(intRadii)
finalContrast(:,index) = offset + fitParameters(1,index)*contrastFit(:,index);
SE2(index) = sum((userThresholds(:) - finalContrast(:,index)).^2);
end
[minVal,indexOfMin] = min(SE2);

#Return the best-fit parameters
scale = fitParameters(1,indexOfMin);
integrationRadius = fitParameters(2,indexOfMin);


return (offset,scale,integrationRadius)
}