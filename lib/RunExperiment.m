function oOut=RunExperiment(oo)
% oo=RunExperiment(oo);
% The first time we call NoiseDiscrimination it will open a window. That
% window typically fills the whole screen, unless you've set
% o.useFractionOfScreen less than 1. That window stays open when
% NoiseDiscrimination returns, so it's ready for the next run, and so on,
% until we reach the end of the session (end of oo cell array), or the user
% hits ESCAPE and chooses to o.quitExperiment.

% I'm not sure. Do I want to call with just the rows I want to text now:
% oo([1 3 5:10])? Or provide two arguments, the list and a set of indices:
% oo,[1 3 5:10]? If I keep the list complete then it could be passed
% several times, as it fills up. When the session is finally done, we can
% sort it by conditionName and increasing noiseSd. It would be nice if each
% row was marked o.done, and the user could keep working until the whole
% session is done, without having to edit anything in the script. If the
% computer stayed on, it could simply be a while loop that kept calling
% this function until the whole table is o.done. I suppose we could save
% the table after each run and then load it to resume from where we left
% off.

% I'd like to make it easier to resume a session. I could save oo in a MAT
% file, with a file name that specifies script name, machine name, and
% observer name. when the script starts it could offer to resume an
% unfinished session, if it finds one. That would allow resuming with no
% editing. Currently you'd have to paste in the seed and specify condition
% numbers. 

% myCleanupFunction will run (closing open windows) when this function
% terminates, whether by reaching the end, the flagging of an error here or
% in any function called from here, or the user hitting control-C.
cleanup=onCleanup(@() myCleanupFunction);

%% RUN THE CONDITIONS
% Typically, you'll select just a few of the conditions stored in oo
% that you want to run now. Select them from the above printing of "tt"
% in your Command Window.
oPrior=[];
for oi=1:length(oo)
    o=oo{oi};
    o.blockNumber=oi;
    o.blocksDesired=length(oo);
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
end
function myCleanupFunction()
% Close window opened by Psychtoolbox Screen command, and re-enable keyboard.
global window
sca;
window=[];
ListenChar;
end
