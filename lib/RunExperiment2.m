function oooOut=RunExperiment2(ooo)
% ooo=RunExperiment2(ooo);
%
% ooo is a cell array representing an experiment. Each cell represents one
% block of the experiment, and contains an array struct oo, with one "o"
% struct per condition. All the conditions in the array are randomly
% interleaved during testing. It is common to have just one condition. Each
% "o" struct has many fields, including o.trials.
%
% KEEP WINDOW OPEN THROUGHOUT EXPERIMENT: The psychtoolbox Screen command
% takes tens of seconds to open a window and a similar time to close it.
% It's unpleasant for observers to wait through those delays more than
% once. To eliminate needless waiting, the first time we call
% NoiseDiscrimination to run a block of trials, it opens a window. That
% window fills the whole screen, unless you've set o.useFractionOfScreenToDebug
% less than 1 (to facilitate debugging). That window stays open when
% NoiseDiscrimination returns, so it's ready for the next block, and so on,
% until we reach the end of the experiment (end of the "ooo" cell array),
% or the user hits ESCAPE and chooses to o.quitExperiment.
%
% RESUME INCOMPLETE EXPERIMENT: Optionally resume a partially-completed
% experiment. When you call RunExperiment, we first look in the data folder
% for a partially-done experiment with the same o.experiment name, done on
% this computer. (Alas, we don't yet know the observer's name, so we can't
% search for it.) If we find one or more matching partial experiment file
% we ask, for each, if you want to finish it (or delete it or skip it). If
% you say YES then we ignore the oo argument that you passed (and the rest
% of the matching partial-experiment files), and instead load up oo from
% the disk file. One by one we run the conditions that still don't have
% enough trials, until the observer quits or we reach the end of the
% experiment. Then we save the completed experiment to disk, without
% "partial" in the filename.
%
% denis.pelli@nyu.edu, May 4, 2018

% TO DO: DELETE OBSOLETE EXPERIMENT SUMMARY. Once we save the new file we
% ought to delete the old partial, since its data are now obsolete,
% duplicated in the new complete experiment file.

% Once we call onCleanup, until RunExperiment ends, CloseWindowsAndCleanup
% will run (closing any open windows) when this function terminates for any
% reason, whether by reaching the end, the posting of an error here or in
% any function called from here, or the user hitting control-C.

cleanup=onCleanup(@() CloseWindowsAndCleanup);

if isempty(ooo)
    error('ooo was empty. You didn''t specify any conditions.');
end
if ~exist('Screen','file')
    error('We need the Psychtoolbox. Please add it to the MATLAB path. Available from http://psychtoolbox.org');
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
ooo=OfferToResumeExperiment2(ooo);

%% RUN THE CONDITIONS IN EXPERIMENT ooo, WHETHER OLD OR NEW.
% You pass a cell array ooo that represents the whole experiment. Each cell
% ooo{block} represents one block. The cell contains an array struct oo.
% Each struct oo(oi) is a condition, which we typically (but not here)
% refer to by o=oo(oi). If the experiment is already partially completed,
% we run every block that has any conditions with fewer than the desired
% number of trials. When we run a block, we discard any old trials.
ooPrior=[];
for block=1:length(ooo)
    % Skip any block in which all conditions are already done.
    oo=ooo{block}; % Get a block.
    thisBlockDone=true;
    for oi=1:length(oo)
        if isfield(oo(oi),'trials') && oo(oi).trials>=oo(oi).trialsPerBlock
            continue
        end
        thisBlockDone=false;
    end
    [ooo{block}.skipThisBlock]=deal(thisBlockDone);
end
s=[];
for i=1:length(ooo)
    s(i)=ooo{i}(1).skipThisBlock;
end
blockList=find(~s);
ooPrior=[];
for block=blockList
    % Prepare this block.
    oo=ooo{block};
    [oo.block]=deal(block);
    [oo.blocksDesired]=deal(length(ooo)); % Display on screen.
    [oo.isLastBlock]=deal(block==blockList(end)); % March 2019 DGP
    [oo.localHostName]=deal(localHostName);
    if ~isempty(ooPrior)
        % Reuse answers from immediately preceding block.
        [oo.experimenter]=deal(ooPrior(1).experimenter);
        if isempty(oo(1).observer)
            [oo.observer]=deal(ooPrior(1).observer);
        end
        [oo.filterTransmission]=deal(ooPrior(1).filterTransmission);
        % Setting o.useFilter to false forces o.filterTransmission=1.
    end
    % Run this block.
    ooPrior=NoiseDiscrimination2(oo); % Run a block.
    ooo{block}=ooPrior; % Save results in ooo.
    if any([ooPrior.quitExperiment])
        break
    end
end % for block=1:length(ooo)
oooOut=ooo;

%% HOW MANY BLOCKS ARE DONE?
% The criterion for "done" is at least o.trialsPerBlock trials.
blocksDone=0;
for block=1:length(ooo)
    thisBlockDone=true; % Initial value.
    oo=ooo{block}; % Get a block.
    for oi=1:length(oo)
        % Check each condition in a block.
        if isfield(oo(oi),'trials') && isfield(oo(oi),'trialsPerBlock') && oo(oi).trials>=oo(oi).trialsPerBlock
            % Gather components of filename.
            experiment=oo(oi).experiment;
            observer=oo(oi).observer;
            continue
        end
        thisBlockDone=false;
    end
    if thisBlockDone
        blocksDone=blocksDone+1;
    end
end
    
%% SAVE THE EXPERIMENT
% If no block has been completed, then save nothing. If we have at least
% one block done, then save the whole experiment in a MAT file. If
% complete, it is labeled "-done". Otherwise it is labelled "-partial",
% indicating that the observer can later resume and finish the experiment.
if blocksDone<length(ooo)
    partialString='-partial';
else
    partialString='-done';
end
if blocksDone>0
    experimentFilename=sprintf('%s-%s-%s%s.%d.%d.%d.%d.%d.%d.mat',...
        experiment,observer,localHostName,partialString,round(datevec(now)));
    dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data');
    save(fullfile(dataFolder,experimentFilename),'ooo');
    fprintf('Saved the experiment (%d of %d blocks done) in %s in data folder.\n',...
        blocksDone,length(ooo),experimentFilename);
end
end % function

%% Clean up whenever RunExperiment terminates, even by control-C.
function CloseWindowsAndCleanup()
% Close any window opened by the Psychtoolbox Screen command, and re-enable keyboard.
global window
if ~isempty(Screen('Windows'))
    % Screen CloseAll is very slow, so we call it only if we need to.
    Screen('CloseAll');
    %     sca;
    if ismac
        AutoBrightness(0,1);
    end
end
window=[];
ListenChar; % May already be done by sca.
ShowCursor; % May already be done by sca.
end % function CloseWindowsAndCleanup()
