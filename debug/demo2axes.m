% From Mathworks, showing how to arrange multiple plots in one figure,
% compactly, without the limitations of TILEDLAYOUT.
% June 15, 2020

f = figure();
ax1 = axes(f);
ax2 = axes(f);
ax1.Units = 'centimeters';
ax2.Units = 'centimeters';

axHeight = 2.5; % this can be adjusted to the required value

ax1.Position(4) = axHeight;
ax2.Position(4) = axHeight;

spacing = 0.3; %change this value to have compact spacing as required

% position ax2 above ax1 with some spacing. using TightInset will account for any axes labels.
ax2.Position(2) = ax1.Position(2) + ax1.Position(4) + ax1.TightInset(4) + ax2.TightInset(2) + spacing ;

plot(ax1,1:10,1:10);
plot(ax2,1:10,1:10);