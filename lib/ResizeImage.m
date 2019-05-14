function oNew=ResizeImage(o,si,desiredTargetHeightChecks)
% o=ResizeImage(oo(oi),desiredTargetHeightChecks);
% Scale o.signal(si).image to size specified by desiredTargetHeightChecks.
% For speed, we rescale only that image, selected by the index si.
% denis.pelli@nyu.edu, March, 2019
if desiredTargetHeightChecks<1
    error('desiredTargetHeightChecks %.1f too small.',desiredTargetHeightChecks);
end
sRectChecks=RectOfMatrix(o.signal(si).image); % units of targetChecks
ratio=desiredTargetHeightChecks/RectHeight(sRectChecks);
targetRectChecks=round(ratio*sRectChecks);
if RectWidth(targetRectChecks)~=RectWidth(o.targetRectChecks)
    % We use the 'bilinear' method to make sure that all new pixel values
    % are within the old range. That's important because we set up the CLUT
    % with that range. Any pixels outside that range could have arbitrary
    % color and brightness.
    %% Scale to desired size.
    sz=[RectHeight(targetRectChecks) RectWidth(targetRectChecks)];
    o.signal(si).image=imresize(o.signal(si).image,sz,'bilinear');
    o.signal(si).bounds=ImageBounds(o.signal(si).image,1);
    sRectChecks=RectOfMatrix(o.signal(si).image); % units of targetChecks
end
o.targetRectChecks=sRectChecks;
o.targetHeightOverWidth=RectHeight(sRectChecks)/RectWidth(sRectChecks);
o.targetHeightPix=RectHeight(sRectChecks)*o.targetCheckPix;
oNew=o;
end