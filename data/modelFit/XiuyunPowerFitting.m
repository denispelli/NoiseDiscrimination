clear all
load XiuyunFiltered 
[contrastFit,offset,scale,integrationRadius] = fitNoiseIntegrationModel(XiuyunFiltered.mean_threshold,XiuyunFiltered.RadiusRelative2letter_size,XiuyunFiltered.noise_contrast);

XiuyunFilteredWithFit = [XiuyunFiltered table(contrastFit)];
%keep only NC of .16
XiuyunFilteredWithFit(1:4,:) = [];
XiuyunFilteredWithFit(21:end,:) = [];

figure
hold on
plot(XiuyunFilteredWithFit.RadiusRelative2letter_size, XiuyunFilteredWithFit.contrastFit);
plot(XiuyunFilteredWithFit.RadiusRelative2letter_size, XiuyunFilteredWithFit.mean_threshold,'o');
legend('Power integration fit: radius of 1.2*letter size','Xiuyun data');
title('Xiuyun data, noiseSD = .16, all letter sizes, eccentricity = 32 deg');
xlabel('Relative decay radius (decay radius/letter size)');
ylabel('Threshold contrast');
hold off

figure
hold on
plot(XiuyunFilteredWithFit.RadiusRelative2letter_size, XiuyunFilteredWithFit.contrastFit-XiuyunFilteredWithFit.mean_threshold,'x');
title('Xiuyun data, noiseSD = .16, all letter sizes, eccentricity = 32 deg');
xlabel('Relative decay radius (decay radius/letter size)');
ylabel('Threshold contrast residual');
hold off