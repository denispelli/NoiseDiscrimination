Screen('Preference', 'SkipSyncTests', 1)
screenRect=Screen('Rect',0)
Screen('Resolution',0)
window=Screen('OpenWindow',0);
displayImage=Screen('GetImage',window);
size(displayImage)
sca;

o.screen=0;
screenRect=Screen('Rect',o.screen); % CAUTION: refers to write buffer, not display, on Retina display in HiDPI mode
% Detect HiDPI mode (probably occurs on Retina display)
res=Screen('Resolution',o.screen);
cal.hiDPIMultiple=res.width/RectWidth(screenRect);
if cal.hiDPIMultiple~=1
    fprintf('Your (Retina?) display is in dual-resolution HiDPI mode. Display resolution is %.2fx buffer resolution.\n',cal.hiDPIMultiple);
    fprintf('Draw buffer is %d x %d.\n',screenRect(3:4));
    fprintf('Display is %d x %d.\n',res.width,res.height);
    fprintf('You can use Switch Res X (http://www.madrau.com/) to select a pure resolution, not HiDPI.\n');
end
