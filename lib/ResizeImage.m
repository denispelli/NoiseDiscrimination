function oNew=ResizeImage(o,i,desiredTargetHeightPix)
% o=ResizeImage(oo(oi),desiredTargetHeightPix);
% Scale just o.signal(i).image to size specified by desiredTargetHeightPix.
% For speed, we rescale only that image, selected by the index i.
% denis.pelli@nyu.edu, March, 2019
sRect=RectOfMatrix(o.signal(1).image); % units of targetChecks
ratio=desiredTargetHeightPix/o.targetHeightPix;
targetRectLocal=round(ratio*sRect);
if RectWidth(targetRectLocal)~=RectWidth(o.targetRectLocal)
    % We use the 'bilinear' method to make sure that all new
    % pixel values are within the old range. That's important
    % because we set up the CLUT with the old range.
    %% Scale to desired size.
    o.signal(i).image=imresize(o.signal(i).image,...
        [RectHeight(targetRectLocal) ...
        RectWidth(targetRectLocal)],'bilinear');
    o.signal(i).bounds=ImageBounds(o.signal(i).image,1);
    sRect=RectOfMatrix(o.signal(1).image); % units of targetChecks
end
o.targetRectLocal=sRect;
o.targetHeightOverWidth=RectHeight(sRect)/RectWidth(sRect);
o.targetHeightPix=RectHeight(sRect)*o.targetCheckPix;
oNew=o;
end