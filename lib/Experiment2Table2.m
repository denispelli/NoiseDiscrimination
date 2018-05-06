function tt=Experiment2Table2(ooo,vars)
% tt=Experiment2Table2(oo,vars);
% ooo is a cell array representing an experiment. Each cell represents one
% block of the experiment, and contains an array struct oo, with one "o"
% struct per condition. All the conditions in the array were randomly
% interleaved during testing. It is common to have only one condition. Each
% o struct has many fields, including o.trials.
% Denis Pelli, April, 2018
tt=table;
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        t=struct2table(oo(oi),'AsArray',true);
        if ~all(ismember({'trials'},t.Properties.VariableNames)) || t.trials==0
            continue % Skip condition without data.
        end
        % Check for and report any missing fields in this condition.
        ok=ismember(vars,t.Properties.VariableNames);
        if ~all(ok)
            missing=join(vars(~ok),' ');
            warning('Skipping condition %d "%s", because it lacks fields: %s',oi,oo(oi).conditionName,missing{1});
            continue
        end
        tt(end+1,:)=t(1,vars);
    end % for oi=1:length(oo)
end % for block=1:length(ooo)