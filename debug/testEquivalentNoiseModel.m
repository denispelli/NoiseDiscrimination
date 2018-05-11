a0=1.02*1e-4;
b0=7.35*1e-4;
k0=1e-7;
L0=206.5;
T0=0.200;

params.a = a0;
params.b = b0;
params.k = k0;
params.L = L0;   % cd/m^2
params.T = T0;   % seconds
params.height = 8;
params.eyes = 2;
params.field = 'whole';
params.ecc=logspace(-2,2);
params.component='photon'; NeqPhoton=equivalentNoise(params);
