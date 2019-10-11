function DrawUncertainty(oo)
% DrawUncertainty(oo);
% Show observer all locations where target can appear.
% o.uncertainDisplayDotDeg specifies the dot diameter in degrees.
% o.uncertainDisplayColor specifies the RGB dot color.
% o.uncertainDisplayDotDeg=0.5; % Default in NoiseDiscrimination.
% October 2, 2019. Ziyi Zhang, polished by Denis Pelli.

% Quick hack to create a distinct color that has similar luminance to the
% grey background. We zero the blue, to change hue from gray to yellow with
% hardly any change in luminance.
for oi=1:length(oo)
    o=oo(oi);
%     if ismember(o.conditionName,{'Fixation check'})
%         % Ignore fixation check, when showing possible target locations.
%         continue
%     end
    o.uncertainDisplayColor=[o.gray o.gray 0];
    dotSizePix=round(o.uncertainDisplayDotDeg*o.pixPerDeg);
    % iMac driver only allows integer dotSizePix in range 1 to 64.
    dotSizePix=min(max(dotSizePix,1),64);
    hasSpatialUncertainty=false;
    for u=1:length(o.uncertainParameter)
        switch o.uncertainParameter{u}
            case 'eccentricityXYDeg'
                hasSpatialUncertainty=true;
                n=length(o.uncertainValues{u});
                xyDeg=[o.uncertainValues{u}{:}];
                assert(length(xyDeg)==2*n,...
                    sprintf(['Each cell of o.uncertainValues{%d}{:} '...
                    'must hold an [x, y] pair.'],u));
                xyDeg=reshape(xyDeg,2,n)';
        end
    end
    if ~hasSpatialUncertainty
        xyDeg=o.eccentricityXYDeg;
    end
    % XYPixOfXYDeg assumes one row per point.
    xy=XYPixOfXYDeg(o,xyDeg);
    % DrawDots assumes one column per point.
    Screen('DrawDots',o.window,xy',...
        dotSizePix,o.uncertainDisplayColor,[],2);
end
