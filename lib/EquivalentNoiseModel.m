% Calculates equivalent noise at given eccentricities and a given letter height,
% luminance, visual field, duration, and number of eyes.
% The input parameter structure should have values for the follwing fields:
% a, b, k, L, T, field, ecc, height, eyes, component. Only ecc can be a vector.

% a0=1.02*1e-4;
% b0=7.35*1e-4;
% k0=1e-7;
% L0=206.5;
% T0=0.200;
% 
% params.a = a0;
% params.b = b0;
% params.k = k0;
% params.L = L0;   % cd/m^2
% params.T = T0;   % seconds
% params.height = 8;
% params.eyes = 2;
% params.field = 'whole';
% params.ecc=logspace(-2,2);
% params.component='photon'; NeqPhoton=equivalentNoise(params);

function Neq=equivalentNoise(s)
    % Constants from Watson, 2014 
    ak = [0.9851 0.9935 0.9729 0.996];
    r2k = [1.058 1.035 1.084 0.9932];
    rek = [22.14, 16.35 7.633 12.13];
    d = 33163.2;
    
    % Anonymous function for Ganglion cell density in a particular visual 
    % field
    density=@(f) d*(ak(f)*(1+s.ecc./r2k(f)).^-2 +...
                (1-ak(f))*exp(-s.ecc./rek(f)));
    
    % Selecting the proper constants
    if strcmp(s.field,'temporal')
        field=1;
    elseif strcmp(s.field,'superior')
        field=2;
    elseif strcmp(s.field,'nasal')
        field=3;
    elseif strcmp(s.field,'inferior')
        field=4;
    elseif strcmp(s.field,'whole')
        field=5;
    end
    
    % Calculating photon noise based on luminance
    photonNoise=s.a/(s.L*s.eyes);
    
    % Calculating cortical noise based on letter height
    corticalNoise=s.k*s.T*s.height^2;
    
    % Calculating RGC density and RGC noise based on visual field
    if field~=5
        D=density(field);
        rgcNoise=s.b./(D*s.eyes);
    else
        D=density(1)+density(3);
        rgcNoise=2*s.b./(D*s.eyes);
    end
    
    % Summing it up
    if strcmp(s.component,'sum')
        Neq=photonNoise+corticalNoise+rgcNoise;
    elseif strcmp(s.component,'photon')
        Neq=photonNoise*ones(1,length(s.ecc));
    elseif strcmp(s.component,'cortical')
        Neq=corticalNoise*ones(1,length(s.ecc));
    elseif strcmp(s.component,'rgc')
        Neq=rgcNoise;
    end
end
