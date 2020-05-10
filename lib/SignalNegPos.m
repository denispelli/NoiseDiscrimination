function signalNegPos=SignalNegPos(o)
% function signalNegPos=SignalNegPos(o);
%
% Helper function to create the argument you need when calling MaxNoiseSD.
% maxNoise=MaxNoiseSD(oo(oi).noiseType,LMinMeanMax,SignalNegPos(oo(oi)));
% denis.pelli@nyu.edu May 4, 2020

switch o.targetKind
    case {'gabor' 'gaborCos' 'gaborCosCos'}
        signalNegPos=[-1 1];
    case 'letter'
        if o.contrast<0
            signalNegPos=[-1 0];
        else
            signalNegPos=[0 1];
        end
    otherwise
        % We will need to handle the 'image' case, but I'm not yet sure
        % what to write for it.
        error('Unknown o.targetKind ''%s''.',o.targetKind);
end
