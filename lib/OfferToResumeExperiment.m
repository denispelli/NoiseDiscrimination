function ooo=OfferToResumeExperiment(ooo)
% Offer to resume any saved incomplete run of the given o.experiment on
% this computer. We don't know the observer name yet, so we offer all
% available. We search by filename in the data folder. The filename is
% assumed to be experiment-observer-localHostName-partial.m where
% experiment=o.experiment, observer= future value of o.observer,
% localHostName is cal.localHostName and "partial" is a literal. Such files
% are produced by RunExperiment.
KbName('UnifyKeyNames');
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
returnKeyCode=KbName('return');
spaceKeyCode=KbName('space');
cal=OurScreenCalibrations(0);
o=ooo{1}(1);
if ~isfield(o,'experiment') || isempty(o.experiment)
    error('The field o.experiment must be a nonempty string.');
end
dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data');
matFiles=dir(fullfile(dataFolder,[o.experiment '-*-' cal.localHostName '-partial*.mat']));
if ~isempty(matFiles)
    cd(dataFolder);
    expt={};
    n=[];
    for i = 1:length(matFiles)
        % Load each experiment into one cell of expt.
        expt{i}=load(matFiles(i).name,'ooo');
        n(i)=matFiles(i).datenum;
    end
    [~,index]=sort(n,'descend');
    matFiles=matFiles(index);
    expt={expt{index}}; % Sort by date.
    fprintf('Found %d partial runs of this experiment on this computer.\n',length(matFiles));
    fprintf(['For each file: \n'...
        'type Y to resume that old experiment, \n'...
        'or hit RETURN to skip it, \n'...
        'or hit DELETE to delete it, \n'...
        'or ESCAPE to run a fresh new experiment.\n']);
    try
        ListenChar(2); % no echo
        resumeExperiment=false;
        for i=1:length(expt)
            o=expt{i}.ooo{1}(1);
%             if isempty(o.observer) || o.trials<o.trialsDesired
%                 % This partial experiment has no data. Skip it.
%                 continue
%             end
            s=sprintf('<strong>%s, %s, Observer: %s </strong>\n',matFiles(i).name,matFiles(i).date,o.observer);
            fprintf('%s',s);
            fprintf('Type Y for: Yes, use it. Hit RETURN to ignore it, or DELETE to delete it: ');
            responseChar=GetKeypress([KbName('y') KbName('delete') returnKeyCode escapeKeyCode graveAccentKeyCode]);
            fprintf('\n');
            switch responseChar
                case 'y'
                    ooo=expt{i}.ooo;
                    for j=1:length(ooo)
                        % In each block, reset the quit flags.
                        [ooo{j}.quitBlock]=deal(false);
                        [ooo{j}.quitExperiment]=deal(false);
                    end
                    fprintf('Ok. Resuming partial old experiment.\n');
                    resumeExperiment=true;
                    break
                case 'delete'
                    delete(matFiles(i).name);
                    fprintf('Deleted.\n');
                case returnChar
                    fprintf('Skipped.\n');
                    continue
                case {escapeChar graveAccentChar}
                    break
            end
        end %  i=1:length(expt)
        ListenChar;
        if ~resumeExperiment
            fprintf('Running your fresh new experiment.\n');
        end
    catch e
        ListenChar;
        rethrow(e);
    end
end
end
