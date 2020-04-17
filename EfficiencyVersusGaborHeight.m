% February 25, 2020
% Plotted runNoiseTest.m data from Ashley and Gus to understand why we got
% low efficiency for large gabors, and worse on smaller screen.

figure(1)
x=[32/39.4	32/44.8 8/20. 2/20 0.5/20];
y= [0.003 0.02  0.06 0.12 0.12];
loglog(x,y)
xlabel('Gabor height re screen');
ylabel('Efficiency');
title('Efficiency drops as gabor height approachs screen height');
ax=gca;
ax.TickLength=[0.01 0.025]*2;
ax.FontSize=12;
% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data','EfficiencyVsSize.eps']);
saveas(gcf,graphFile,'epsc');
