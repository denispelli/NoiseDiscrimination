% TestCalibrationBrightness.m
% May 10, 2020
% Ran CalibrateScreenLuminance at several values of brightness:
% 0 0.01 0.03 0.1 0.25 0.5 0.75 0.87 1
% Tried to fit simple models to the data.
% To a good approximation at high brightness, 
% log gain = -2.66*(1-brightness)
% Thus reducing brightness is like introducing a neutral density filter.
% The deviation appear significant only at low luminances. I won't use my
% model. I'll just pick several brightnesses corresponding to the mean
% luminances that I need. To look at effect of luminance, I want 1, 0.1,
% and 0.01. Alexander and Darshan report that observers find 250 cd/m^2
% background uncomfortable, but they are comfortable at half that. So I'm
% adding a brightness of 0.5. I will make a separate calibration for each
% of the brightnesses: 1, 0.5, 0.1, 0.01, and select the desired one at
% runtime.
%
% What I don't know is what bit depth I get when running at low brightness.
% I'm hoping that bit depth is independent of the brightness setting.
% That's what I expect if brightness is controlling the light source
% independent of the LCD that attentuates it, but that might be wrong. If
% the brightness is combined digitally with the DAC numbers and drive a
% high-precision DAC, then precision at low brightness may be terrible.


close all
b=[0 0.01 0.03 0.1 .25 .5 .75  .87 1];
for i=1:length(b)
    cal(i)=OurScreenCalibrations(0,b(i));
end
for i=1:length(cal)
    LMin(i)=cal(i).old.L(1);
    b(i)=cal(i).settings.brightness;
end

fg=figure(1);
fg.Name='L vs Number';
fg.Position=[10 10 500 900];
for k=1:3
    subplot(3,1,k)
    for i=length(cal):-1:1
        switch k
            case 1
                plot(cal(i).old.n,cal(i).old.L,...
                    'LineWidth',2,...
                    'DisplayName',sprintf('b=%.2f',cal(i).settings.brightness));
                ax=gca;
                ax.XLim=[0 255];
            case 2
                semilogy(cal(i).old.n,cal(i).old.L-LMin(i),...
                    'LineWidth',2,...
                    'DisplayName',sprintf('b=%.2f',cal(i).settings.brightness));
                ax=gca;
                ax.XLim=[0 255];
            case 3
                loglog(cal(i).old.n(2:end),cal(i).old.L(2:end)-LMin(i),...
                    'LineWidth',2,...
                    'DisplayName',sprintf('b=%.2f',cal(i).settings.brightness));
                ax=gca;
                ax.XLim=[2 255];
        end
        hold on
    end
    lgd=legend('Location','northwest','Box','off');
    lgd.FontName='Monaco';
    lgd.FontSize=10;
    title('L vs N','fontsize',18)
    xlabel('Number','fontsize',18);
    ylabel('Luminance (cd/m^2)','fontsize',18);
    % set(findall(gcf,'-property','FontSize'),'FontSize',12)
end

% figureHandle(iFigure)=figure('Name',[experiment ' Contrast'],'NumberTitle','off','pos',[10 10 500 900]);
fg=figure(2);
fg.Name='L vs Number';
fg.Position=[10 10 500 900];
for i=1:length(cal)
    r=(cal(i).old.L-LMin(i)) ./(cal(end).old.L-LMin(end));
    g(i)=mean(r(12:end));
    b(i)=cal(i).settings.brightness;
end
for k=1:3
    subplot(3,1,k)
    for i=length(cal):-1:1
        switch k
            case 1
                plot(cal(i).old.n,(cal(i).old.L-LMin(i)) ./(cal(end).old.L-LMin(end)) ,...
                    'LineWidth',2,...
                    'DisplayName',sprintf('b=%.2f',cal(i).settings.brightness));
            case 2
                semilogy(cal(i).old.n,(cal(i).old.L-LMin(i)) ./(cal(end).old.L-LMin(end)) ,...
                    'LineWidth',2,...
                    'DisplayName',sprintf('b=%.2f',cal(i).settings.brightness));
            case 3
                if b(i)>0
                    plot(cal(i).old.n,(cal(i).old.L-LMin(i)) ./(cal(end).old.L-LMin(end))/g(i) ,...
                        'LineWidth',2,...
                        'DisplayName',sprintf('b=%.2f',cal(i).settings.brightness));
                end
        end
        hold on
    end
    lgd=legend('Location','southeast','Box','off');
    %title(lgd,'noiseSD, luminance, observer');
    lgd.FontName='Monaco';
    title('L vs N','fontsize',18)
    xlabel('Number','fontsize',18);
    ylabel('Luminance re Unit Brightness','fontsize',18);
    % set(findall(gcf,'-property','FontSize'),'FontSize',12)
    lgd.FontSize=10;
    ax=gca;
    ax.XLim=[0 255];
end

% GAIN vs BRIGHTNESS
for i=1:length(cal)
    r=cal(i).old.L ./cal(end).old.L;
    g(i)=mean(r(12:end));
    b(i)=cal(i).settings.brightness;
end
fg=figure(3);
fg.Name='Gain vs. Brightness';
clf;
semilogy(b,g,'kx','LineWidth',2,'DisplayName','Measured');
hold on
xlabel('Brightness','fontsize',18);
ylabel('Gain re unit brightness','fontsize',18);
G=log10(g);
Y=G(3:end)';
n=length(G);
X=[ones([n-2 1]) b(3:end)'];
B=X\Y;
X=[ones([n 1]) b'];
YCalc = X*B;
% log(gain)=B(1)+B(2)*brightness
% =-2.1699+2.1627*brightness
% ~ -2.166*(1-brightness)
B=[-2.166 2.166]';
YCalc = X*B;
semilogy(b,10.^YCalc,'-k','LineWidth',2,'DisplayName',...
    sprintf('Linear regression:  log10 gain = %.3f*(1-brightness)',B(1)));
legend('Location','SouthWest','Box','Off')

% brightness=1-log(gain)/-2.166 
% G=-2.166*(1-brightness);
G=[0 log10(.5) -1 -2];
brightness=1-G/-2.166;
g=10.^G;
semilogy(brightness,g,'ro','DisplayName','Calibrate for experiment');
% g = [1.0000    0.5000    0.1000    0.0100];
% G = [  0   -0.3010   -1.0000   -2.0000];
% brightness= [1.0000 0.861   0.5383    0.0766];



%% log Gain vs Brightness, regression
figure(4)
fg.Name='log Gain vs. Brightness, regression';
hold off
x=cal(i).old.n;
y=cal(i).old.L;
degree=4;
[p,S,mu] = polyfitZero(x,y,degree);
[yest,derr] = polyval(p,x,S,mu); % fit to data, calculate error
plot(x,y,'o'),hold('all')
x=0:255;
yModel=polyval(p,x,S,mu);
plot(x,yModel,'-');
% errorbar(x,yest,derr),title('Polynomial fit forcing y through origin.')
xlabel('Number','fontsize',18),ylabel('Luminance (cd/m^2)','fontsize',18)
ax=gca;
ax.XLim=[0 255];
legend('data','fit','Location','NorthWest','Box','Off')


% Max & Min luminance
fg=figure(5);
fg.Name='Max and Min luminance vs. Brightness';
for i=1:length(cal)
    LMax(i)=cal(i).old.L(end);
    LMin(i)=cal(i).old.L(1);
    b(i)=cal(i).settings.brightness;
end
% Max luminance
% fg=figure(6);
% fg.Name='Max luminance vs. Brightness';
semilogy(b,LMax,'b-o','DisplayName','Max luminance');
hold on
% xlabel('Brightness','fontsize',18);
% ylabel('luminance (cd/m^2)','fontsize',18);
ax=gca;
ax.XLim=[0.01 1];
ax.YLim=[1e-3 max(LMax)];
semilogy(b,LMin,'k-x','DisplayName','Min luminance');
hold on
xlabel('Brightness','fontsize',18);
ylabel('Luminance (cd/m^2)','fontsize',18);
ax=gca;
% ax.XLim=[0.05 1];
% ax.YLim=[1e-3 max(LMin)];
lgd=legend('Location','northwest','Box','off');
lgd.FontName='Monaco';
lgd.FontSize=10;

