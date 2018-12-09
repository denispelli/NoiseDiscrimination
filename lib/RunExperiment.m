function oOut=RunExperiment(oo)
% oo=RunExperiment(oo);
% 
% KEEP WINDOW OPEN THROUGHOUT EXPERIMENT: The psychtoolbox Screen command
% takes maybe 30 s to open a window and a similar time to close it. It's
% unpleasant for observers to wait through those delays more than once. To
% eliminate needless waiting, the first time we call NoiseDiscrimination to
% run a block of trials, it opens a window. That window typically fills the
% whole screen, unless you've set o.useFractionOfScreenToDebug less than 1 (to
% facilitate debugging). That window stays open when NoiseDiscrimination
% returns, so it's ready for the next block, and so on, until we reach the
% end of the experiment (end of the "oo" cell array), or the user hits
% ESCAPE and chooses to o.quitExperiment.
%
% RESUME: Optionally resume a partially-completed experiment. When you call
% RunExperiment, we first look in the data folder for a partially-done
% experiment with the same o.experiment name, done on this computer. (Alas,
% we don't yet know the observer's name, so we can't search for it.) If we
% find one or more matching partial experiment file we ask, for each, if
% you want to finish it (or delete it or skip it). If you say YES then we
% ignore the oo argument that you passed (and the rest of the matching
% partial-experiment files), and instead load up oo from the disk file. One
% by one we run the conditions that still don't have enough trials, until
% the observer quits or we reach the end of the experiment. Then we save
% the completed experiment to disk, without "partial" in the filename.
%
% denis.pelli@nyu.edu, May 4, 2018

% TO DO: DELETE OBSOLETE EXPERIMENT SUMMARY. Once we save the new file we
% ought to delete the old partial, since its data are now obsolete,
% duplicated in the new complete experiment file.

% TO DO: INTERLEAVE CONDITIONS. I'd like to enhance NoiseDiscrimination to
% be like CriticalSpacing and accept an array of conditions that should all
% be randomly interleaved in the block. That is easily achieved, by doing a
% global replacement of "o" by "oo(oi)", where oi is the condition index.
% An experiment might have different number of conditions in each block.
% Thus the argument to RunExperiment needs to allow specification of
% several conditions for each block, and not assume a consistent number of
% conditions from block to block. Thus it should receive a cell array ooo,
% where each element of the cell array is a struct array, oo.

% Once we call onCleanup, until RunExperiment ends, MyCleanupFunction will
% run (closing any open windows) when this function terminates for any
% reason, whether by reaching the end, the posting of an error here or in
% any function called from here, or the user hitting control-C.

cleanup=onCleanup(@() MyCleanupFunction);

if isempty(oo)
    error('oo was empty. You didn''t specify any conditions.');
end
computer=Screen('Computer');
if computer.windows
   localHostName=getenv('USERDOMAIN');
elseif computer.linux
   localHostName=strrep(computer.localHostName,'鈄1�7',''''); % work around bug in Screen('Computer')
elseif computer.osx || computer.macintosh
   localHostName=strrep(computer.localHostName,'鈄1�7',''''); % work around bug in Screen('Computer')
end

%% LOOK FOR PARTIAL RUNS OF THIS EXPERIMENT.
oo=OfferToResumeExperiment(oo);

%% RUN THE CONDITIONS
% We run every condition that has fewer than the desired number of trials.
% When we run a condition, we discard any old trials.
oPrior=[];
for oi=1:length(oo)
    o=oo{oi};
    if isfield(o,'trials') && o.trials>=o.trialsPerBlock
        % Skip any condition that already has the desired trials.
        continue
    end
    o.block=oi;
    o.blocksDesired=length(oo);
    o.localHostName=localHostName;
    if ~isempty(oPrior)
        % Reuse answers from immediately preceding block.
        o.experimenter=oPrior.experimenter;
        o.observer=oPrior.observer;
        o.filterTransmission=oPrior.filterTransmission;
        % Setting o.useFilter false forces o.filterTransmission=1.
    end
    oPrior=NoiseDiscrimination(o); % Run one condition.
    oo{oi}=oPrior;
    if oPrior.quitExperiment
        break
    end
end
oOut=oo;

%% SAVE ALL THE RESULTS IN AN EXPERIMENT MAT FILE LABELED "partial"
%% THAT SUPPORTS LATER RESUMING A PARTIALLY DONE EXPERIMENT.
% If no block has been completed, then save nothing. If we have at least
% one block done, then save the whole experiment. If at least one, but not
% all, the blocks have been done, then the observer can resume and finish
% the experiment. The criterion for "done" should be a reasonable number of
% trials. For testing, I've set it to 2 trials, but I expect to raise that
% to 20 trials.
n=0;
for oi=1:length(oo)
    if isfield(oo{oi},'trials') && oo{oi}.trials>=2
        % Gather components of filename.
        o.experiment=oo{oi}.experiment;
        o.observer=oo{oi}.observer;
        n=n+1;
    end
end
if n<length(oo)
    partialString='-partial';
else
    partialString='';
end
if n>0
    experimentFilename=sprintf('%s-%s-%s%s.%d.%d.%d.%d.%d.%d.mat',...
        o.experiment,o.observer,o.localHostName,partialString,round(datevec(now)));
    dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data');
    save(fullfile(dataFolder,experimentFilename),'oo');
    fprintf('Saved the experiment (completed %d of %d blocks) in %s in data folder.\n',...
        n,length(oo),experimentFilename);
end
end % function

%% CLEANUP WHEN RunExperiment TERMINATES.
function MyCleanupFunction()
% Close any window opened by the Psychtoolbox Screen command, and re-enable keyboard.
global window
sca;
window=[];
ListenChar;
end % function
