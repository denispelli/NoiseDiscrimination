figure(6)
clf
logx=0:0.1:1;
x=10.^logx;
y=x.^2;
useTiledLayout=false;
if useTiledLayout
    tile=tiledlayout(2,1);
    % tile.TileSpacing='compact'; % 'none'
    % tile.Padding='compact';
    nexttile(2);
else
    subplot(2,1,2);
end
loglog(x,y)
ax=gca;
ax.Units='centimeters';
% The following assignment requests setting of the Y axis length so that
% each log unit is 2 cm long. That's very important in my work, as I
% publish many graphs with log scales, and I need a consistent length for
% the log unit. (This length is off by a factor of 2 on my Retina Display,
% but that's easy to correct for.) Aside from that, it works perfectly with
% the old SUBPLOT command. However, I'm very disappointed to discover that
% the assignment is disallowed using the TILEDLAYOUT command, issuing a
% warning instead. 
% Warning: Unable to set 'Position', 'InnerPosition', 'OuterPosition', or 'ActivePositionProperty' for objects in a TiledChartLayout 
% I need arrays of loglog plots (offered by SUBPLOT and TILEDLAYOUT). I
% need tight spacing (offered only by TILEDLAYOUT). And I need to control
% the length of a log unit (allowed only by SUBPLOT). Is there a way to
% achieve what I need?
ax.Position(4)=2*diff(log10(ax.YLim));
