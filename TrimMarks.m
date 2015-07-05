function TrimMarks(window,frameRect);
for left=0:1
    for top=0:1
        if left
            h=[-1 0;-0.3 0];
            x=frameRect(1);
        else
            h=[1 0;0.3 0];
            x=frameRect(3);
        end
        if top
            v=[0 -1;0 -0.3];
            y=frameRect(2);
        else
            v=[0 1;0 0.3];
            y=frameRect(4);
        end
        xy=[h' v']*RectWidth(frameRect)*0.3;
        Screen('DrawLines',window,xy,1,0,[x,y]);
    end
end

            %Screen('FrameRect',window,0,frameRect);
            %ovalRect=CenterRect(1.3*frameRect,frameRect);
            %Screen('FillOval',window,gray,ovalRect);
