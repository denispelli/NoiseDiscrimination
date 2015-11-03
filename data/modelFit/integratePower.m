%Author: Nick Blauch; Last edited: 11/02/2015
%This function computes the integrated noise power of a gaussian 
%envelope of noise. This value is calculated for an integrationRadius, set of radii, and set of
%noiseSD specified by the input. This function is used for modeling threshold contrast in
%terms of noise-power integration. 

function integratedPower = integratePower(integrationRadius,userRadii,noiseSD)
    decayRadii = userRadii;
    integratedPower = zeros(length(decayRadii),1);
    relativeNoiseCheckSize = .1; %relative to letter size
    checkSites = -integrationRadius:relativeNoiseCheckSize:integrationRadius;
    [x,y] = meshgrid(checkSites,checkSites);
    for i = 1:length(decayRadii)
            gaussian = exp(-2*(x.^2 + y.^2)./(decayRadii(i).^2));
            power =(noiseSD(i).^2)*gaussian.^2;
            integratedPower(i) = trapezoidal_rule_double_integral(checkSites,checkSites,power);
    end    
end