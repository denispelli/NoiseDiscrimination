function oo=OfferToResumeExperiment(oo)
% Offer to resume any saved incomplete experiment on the given
% o.experiment and computer. We don't know the observer name yet, so we
% offer all available. We search by filename in the data folder. The
% filename is assumed to be experiment-observer-localHostName-partial.m
% where experiment=o.experiment, observer= future value of o.observer,
% localHostName is cal.localHostName and "partial" is a literal. Such files
% are produced by RunExperiment.
KbName('UnifyKeyNames');
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
returnChar=13;
cal=OurScreenCalibrations(0);
o=oo{1};
for ii=1:length(o)
    if ~isfield(o,'experiment') || isempty(o(ii).experiment)
        error('The field o.experiment must be a nonempty string.');
    end
end
dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data');
matFiles=dir(fullfile(dataFolder,[o(1).experiment '-*-' cal.localHostName '-partial*.mat']));
if ~isempty(matFiles)
    cd(dataFolder);
    expt={};
    n=[];
    for i = 1:length(matFiles)
        % Load each experiment into one cell of expt.
        expt{i}=load(matFiles(i).name,'oo');
        n(i)=matFiles(i).datenum;
    end
    [~,index]=sort(n,'descend');
    matFiles=matFiles(index);
    expt={expt{index}}; % Sort by date.
    fprintf('Found %d partial runs of this experiment on this computer.\n',length(matFiles));
    fprintf('For each file, type: Y to resume that old experiment; or hit RETURN to pass it; or hit DELETE to delete it; or ESCAPE to run a fresh new experiment.\n');
    try
        ListenChar(2); % no echo
        resumeExperiment=false;
        for i=1:length(expt)
            o=expt{i}.oo{1};
%             if isempty(o(1).observer) || o(1).trials<o(1).trialsPerBlock
%                 % This partial experiment is incomplete. Skip it.
%                 continue
%             end
            fprintf('<strong>%s, %s, Observer: %s</strong>\n',matFiles(i).name,matFiles(i).date,o(1).observer);
            fprintf('To use it, type Y for yes. Hit RETURN to ignore it, or DELETE to delete it:\n');
            responseChar=GetKeypress([KbName('y') KbName('delete') returnKeyCode escapeKeyCode graveAccentKeyCode]);
            switch responseChar
                case 'y'
                    oo=expt{i}.oo;
                    for j=1:length(oo)
                        % In each block, reset the quit flags.
                        oo{j}.quitRun=false;
                        oo{j}.quitExperiment=false;
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
        %     sca; % screen close all
        ListenChar;
        rethrow(e);
    end
end
end
