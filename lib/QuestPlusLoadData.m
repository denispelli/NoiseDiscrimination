function oo=QuestPlusLoadData(oo)
%% Load our data into QuestPlus.
for oi=1:length(oo)
    if ~oo(oi).questPlusEnable
        warning('Condition %d: o.questPlusEnable must be true. Skipping to next.',oi);
        continue
    end
    if isfield(oo(oi),'data')
        % For NoiseDiscrimination.m
        for trial=1:size(oo(oi).data,1)
            for i=2:size(oo(oi).data,2)
                tTest=oo(oi).data(trial,1);
                isRight=oo(oi).data(trial,i);
                stim=20*tTest;
                outcome=isRight+1;
                oo(oi).questPlusData=qpUpdate(oo(oi).questPlusData,stim,outcome);
            end
        end
    elseif isfield(oo(oi),'q')
        % For CriticalSpacing.m
        t=QuestTrials(oo(oi).q);
        for i=1:length(t.intensity)
            for response=1:size(t.responses,1)
                for n=1:t.responses(response,i)
                    oo(oi).questPlusData=qpUpdate(oo(oi).questPlusData,20*t.intensity(i),response);
                end
            end
        end
    else
        error('Sorry can''t find your data.');
    end
end
%% RESTRICT tTest TO LEGAL VALUE IN QUESTPLUS
if oo(oi).questPlusEnable
    % Select the nearest available contrast on the fixed contrastDB
    % list used by QuestPlus. This will be slightly inconsistent
    % with whatever stimulus parameter we're controlling.
    %     i=knnsearch(contrastDB'/20,tTest);
    %     tTest=contrastDB(i)/20;
end
