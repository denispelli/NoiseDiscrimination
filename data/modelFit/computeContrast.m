%Author: Nick Blauch; Last edited: 10/19/2015
%This function computes the square-root of the integrated noise power of a gaussian 
%envelope. This value is calculated for an integrationRadius and set of radii specified
%by the input. This function is used for modeling threshold contrast in
%terms of noise-power integration. 
%A typical model is of the form a + b*contrastFit, where contrastFit is the
%output of this function. 

function contrastFit = computeContrast(integrationRadius,userRadii)
    decayRadii = userRadii;
    gaussianIntegral = zeros(length(decayRadii),1);
    increment = .1;
    bounds = -integrationRadius:increment:integrationRadius;
    [x,y] = meshgrid(bounds,bounds);
    for i = 2:length(decayRadii)
            gaussian = exp(-2*(x.^2 + y.^2)./(decayRadii(i).^2));
            gaussianIntegral(i) = trapezoidal_rule_double_integral(bounds,bounds,gaussian);
    end
    contrastFit = (gaussianIntegral).^.5;
    
end