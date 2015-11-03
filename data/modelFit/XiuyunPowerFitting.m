clear all
load xiuyunconditions.mat
%some preprocessing
xiuyunconditions.noise_decay_radius(xiuyunconditions.noise_decay_radius >32) = 32;
xiuyunconditions([16,18],:) = [];
radius_relative_to_letter_radius = xiuyunconditions.noise_decay_radius./(xiuyunconditions.letter_size/2);
xiuyunconditions = [xiuyunconditions table(radius_relative_to_letter_radius)];


[contrastFit,offset,scale,integrationRadius] = fitNoiseIntegrationModel(xiuyunconditions.mean_threshold,xiuyunconditions.radius_relative_to_letter_radius,xiuyunconditions.noise_contrast);
xiuyunconditionsWithFit = [xiuyunconditions table(contrastFit)];
%keep only data corresponding to noiseSD=.16
xiuyunconditionsWithFit = xiuyunconditionsWithFit(xiuyunconditionsWithFit.noise_contrast == .16,:);
%sort for clean presentation 
xiuyunconditionsWithFit = sortrows(xiuyunconditionsWithFit,'radius_relative_to_letter_radius','ascend');


xiuyunECC32degconditions = xiuyunconditions(xiuyunconditions.eccentricity==32,:);
xiuyunECC0degconditions = xiuyunconditions(xiuyunconditions.eccentricity==0,:);

[contrastFit,offset,scale,integrationRadius32deg] = fitNoiseIntegrationModel(xiuyunECC32degconditions.mean_threshold,xiuyunECC32degconditions.radius_relative_to_letter_radius,xiuyunECC32degconditions.noise_contrast);
xiuyunECC32degconditionsWithFit = [xiuyunECC32degconditions table(contrastFit)];
%keep only data corresponding to noiseSD=.16
xiuyunECC32degconditionsWithFit = xiuyunECC32degconditionsWithFit(xiuyunECC32degconditionsWithFit.noise_contrast == .16,:);
%sort for clean presentation 
xiuyunECC32degconditionsWithFit = sortrows(xiuyunECC32degconditionsWithFit,'radius_relative_to_letter_radius','ascend');

[contrastFit,offset,scale,integrationRadius0deg] = fitNoiseIntegrationModel(xiuyunECC0degconditions.mean_threshold,xiuyunECC0degconditions.radius_relative_to_letter_radius,xiuyunECC0degconditions.noise_contrast);
xiuyunECC0degconditionsWithFit = [xiuyunECC0degconditions table(contrastFit)];
%keep only data corresponding to noiseSD=.16
xiuyunECC0degconditionsWithFit = xiuyunECC0degconditionsWithFit(xiuyunECC0degconditionsWithFit.noise_contrast == .16,:);
%sort for clean presentation 
xiuyunECC0degconditionsWithFit = sortrows(xiuyunECC0degconditionsWithFit,'radius_relative_to_letter_radius','ascend');

%linear-linear plot
figure
hold on
plot(xiuyunECC32degconditionsWithFit.radius_relative_to_letter_radius, xiuyunECC32degconditionsWithFit.contrastFit);
s1 = 'Power integration fit for ecc = 32 deg: radius of 1.6*letter radius';
plot(xiuyunECC32degconditionsWithFit.radius_relative_to_letter_radius, xiuyunECC32degconditionsWithFit.mean_threshold,'o');
s2 = 'Xiuyun ecc = 32 deg';
plot(xiuyunECC0degconditionsWithFit.radius_relative_to_letter_radius, xiuyunECC0degconditionsWithFit.contrastFit);
s3 = 'Power integration fit for ecc = 0 deg: radius of 1.4*letter radius';
plot(xiuyunECC0degconditionsWithFit.radius_relative_to_letter_radius, xiuyunECC0degconditionsWithFit.mean_threshold,'o');
s4 = 'Xiuyun ecc = 0 deg';
legend(s1,s2,s3,s4);
title('Xiuyun data, noiseSD = .16, all letter sizes');
xlabel('Relative decay radius (decay radius/letter radius)');
ylabel('Threshold contrast');
axis([.1 100 .1 .7])

hold off

%log-log plot
figure
hold on
plot(xiuyunconditionsWithFit.radius_relative_to_letter_radius, xiuyunconditionsWithFit.contrastFit);
s1 = 'Power integration fit: radius of 1.6*letter radius';
plot(xiuyunECC32degconditionsWithFit.radius_relative_to_letter_radius, xiuyunECC32degconditionsWithFit.mean_threshold,'o');
s2 = 'Xiuyun ecc = 32 deg';
plot(xiuyunECC0degconditionsWithFit.radius_relative_to_letter_radius, xiuyunECC0degconditionsWithFit.mean_threshold,'o');
s3 = 'Xiuyun ecc = 0 deg';
legend(s1,s2,s3);
title('Xiuyun data, noiseSD = .16, all letter sizes');
xlabel('Relative decay radius (decay radius/letter radius)');
ylabel('Threshold contrast');
set( gca,'xscale','log')
set( gca,'yscale','log')
hold off


