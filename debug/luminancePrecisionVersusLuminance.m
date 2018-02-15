% Plot dL vs L, assuming 13-bit DAC
cal=OurScreenCalibrations(0);
slope=diff(cal.old.L)./diff(cal.old.G);
dL=2^-13*slope;
figure
subplot(3,2,1)
plot(cal.old.G,cal.old.L);
xlabel('DAC code','FontSize',14);
ylabel('Luminance (cd/m^2)','FontSize',14);
title('MacBook Pro (15" mid 2015)');
subplot(3,2,3)
plot(cal.old.G(2:end),dL);
xlabel('DAC code','FontSize',14);
ylabel('Step (cd/m^2)','FontSize',14);
subplot(3,2,2)
plot(cal.old.L(2:end),dL);
xlabel('Luminance (cd/m^2)','FontSize',14);
ylabel('Luminance step (cd/m^2)','FontSize',14);
title('Assume 13-bit DAC');
subplot(3,2,4)
plot(cal.old.L(2:end),dL./cal.old.L(2:end));
xlabel('Luminance (cd/m^2)','FontSize',14);
ylabel('Step contrast','FontSize',14);
subplot(3,2,6)
plot(cal.old.L(2:end),-log2(dL./cal.old.L(2:end)));
xlabel('Luminance (cd/m^2)','FontSize',14);
ylabel('Bits','FontSize',14);
subplot(3,2,5)
semilogx(cal.old.L(2:end),-log2(dL./cal.old.L(2:end)));
xlim([1 300]);
xlabel('Luminance (cd/m^2)','FontSize',14);
ylabel('Bits','FontSize',14);
% legend('ideal','actual');
% legend boxoff
% text(-.35,5.95,sprintf('dL/L=%.4f,  %.1f bits',dL/L,-log2(dL/L)),'FontSize',10);
% title('Luminance precision','FontSize',14);
% msg=sprintf('1%% contrast, 6 cd/m^2, 2017 MacBook Pro');
% annotation('textbox',[.5 .1 .3 .1],'String',msg,'FitBoxToText','on','FontSize',10,'LineStyle','none');
name='LuminancePrecision';
print(gcf,'-dpng',[name,'.png']); % Save figure as png file.
