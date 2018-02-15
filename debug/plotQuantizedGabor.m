% Plot % contrast Gabor imaged with n-bit luminance precision.
% n=-log2(dL/L);
b=9.4;
L=6; % cd/m^2
dL=L/2^b;
o.targetGaborPhaseDeg=0; % Phase offset of sinewave in deg at center of gabor.
o.targetGaborSpaceConstantCycles=0.75; % The 1/e space constant of the gaussian envelope in cycles of the sinewave.
o.targetGaborCycles=3; % cycles of the sinewave in targetHeight
o.targetCyclesPerDeg=4;
x=(-0.5:.01:.5)*o.targetGaborCycles/o.targetCyclesPerDeg;
g=sin(2*pi.*x.*o.targetCyclesPerDeg).*exp(-(x.*o.targetCyclesPerDeg./o.targetGaborSpaceConstantCycles).^2);
im=L*(1+0.01*g);
q=dL*round(im/dL);
plot(x,im,x,q);
xlabel('x (deg)','FontSize',14);
ylabel('Luminance (cd/m^2)','FontSize',14);
legend('ideal','actual');
legend boxoff
text(-.35,5.95,sprintf('dL/L=%.4f,  %.1f bits',dL/L,-log2(dL/L)),'FontSize',10);
title('Quantized 1%-contrast Gabor at 6 cd/m^2','FontSize',14);
msg=sprintf('1%% contrast, 6 cd/m^2, 2017 MacBook Pro');
annotation('textbox',[.5 .1 .3 .1],'String',msg,'FitBoxToText','on','FontSize',10,'LineStyle','none');
name='quantizedGaborAtLuminance6';
print(gcf,'-dpng',[name,'.png']); % Save figure as png file.
