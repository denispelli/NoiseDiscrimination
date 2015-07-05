clear all
Screen('Preference', 'SkipSyncTests', 1);
screen=0;
[window,screenRect]=Screen('OpenWindow',screen,[],[],[],[],[],0);
img=Screen('GetImage',window);
getRect=RectOfMatrix(img);
putRect=Screen('Rect',window);
screenScalar=RectWidth(getRect)/RectWidth(putRect);
if screenScalar~=1
    fprintf('Retina display? Unequal get/put resolutions, with ratio %.2f\n',screenScalar);
    fprintf('putRect of screen is [%d %d %d %d]\n',putRect);
    fprintf('getRect of screen is [%d %d %d %d]\n',getRect);
end
img=repmat([0 50 100 150 200 250],6,1);
rect=RectOfMatrix(img);
rect=CenterRect(rect,screenRect);
texture=Screen('MakeTexture',window,uint8(img));
Screen('DrawTexture',window,texture,RectOfMatrix(img),rect);
peekBuffer=Screen('GetImage',window,rect,'drawBuffer');
peekDisplay=Screen('GetImage',window,2*rect,'drawBuffer');
figure(1);
subplot(3,1,1);imshow(uint8(img));
subplot(3,1,2);imshow(peekBuffer);
subplot(3,1,3);imshow(peekDisplay);
fprintf('wrote, read drawBuffer, read scaled\n');
img(5,:)
peekBuffer(5,:,1)
peekDisplay(5,:,1)
Screen('Flip',window);
peekBuffer=Screen('GetImage',window,rr);
peekDisplay=Screen('GetImage',window,screenScalar*rr);
WaitSecs(2);
Screen('CloseAll');
figure(2);
subplot(3,1,1);imshow(uint8(img));
subplot(3,1,2);imshow(peekBuffer);
subplot(3,1,3);imshow(peekDisplay);
fprintf('wrote, read after flip, read scaled\n');
img(5,:)
peekBuffer(5,:,1)
peekDisplay(5,:,1)

