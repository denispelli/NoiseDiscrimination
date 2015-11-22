window=Screen('OpenWindow',0,255);
gamma=Screen('ReadNorm alizedGammaTable',window);
fprintf('gamma size %dx%d\n',size(gamma));
gamma(37,1:3)=[0 1 0]; % green background of 1
gamma(531,1:3)=[1 0 0]; % red square of 128
Screen('LoadNormalizedGammaTable',window,gamma);
Screen('FillRect',window,[1 1 1]); % green background of 1
Screen('FillRect',window,[128 128 128],[0 0 200 200]); % ! red square of 128
Screen('Flip',window);
GetClicks;
sca;
