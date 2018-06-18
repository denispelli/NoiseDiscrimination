function tt=Experiment2Table(oo,vars)
% tt=Experiment2Table(oo,vars);
% oo is a cell array representing an experiment. Each element represents
% one block for one condition of the experiment. It's an o struct with many
% fields, including o.trials. Each o may be an array.
% Denis Pelli, April, 2018
tt=table;
for oi=1:length(oo)
    t=struct2table(oo{oi},'AsArray',true);
    if ~all(ismember({'trials'},t.Properties.VariableNames)) || all(t.trials==0)
        continue % Skip condition without data.
    end
    % Check for and report any missing fields in this condition.
    ok=ismember(vars,t.Properties.VariableNames);
    if ~all(ok)
        missing=join(vars(~ok),' ');
        warning('Skipping incomplete condition %d, because it lacks: %s',i,missing{1});
        continue
    end
    tt=vertcat(tt,t(:,vars));
end % for oi=1:length(oo)
