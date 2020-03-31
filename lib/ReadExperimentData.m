function [oo,tt]=ReadExperimentData(experiment,vars)
% [oo,tt]=ReadExperimentData(experiment,vars);
% Returns all the thresholds contains in all the MAT files in the data
% folder whose names begin with the string specified in the "experiment"
% argument. The MAT file may contain a whole experiment ooo{}, or a block
% oo(), or a trial o. ooo{} is a cell array of oo. oo is an array of o.
% Each o is a threshold. The thresholds are extracted from all the MAT
% files in the data folder whose names begin with the string in
% "experiment". We add two new fields to each threshold record. "date" is a
% readable string indicating the date and time of measurement.
% "missingField" is a cell list of strings of all the fields that were
% requested in vars, but not available in the threshold record.
% denis.pelli@nyu.edu July 2018

myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(myPath); % We are in the "lib" folder.
% The lib and data folders are in the same folder.
dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data');
% matFiles=dir(fullfile(dataFolder,['run' experiment '*.mat']));
% matFiles=dir(fullfile(dataFolder,[experiment '*.mat']));
if iscell(experiment)
    for i=1:length(experiment)
        m=dir(fullfile(dataFolder,['run' experiment{i} '*.mat']));
        if i==1
            matFiles=m;
        else
            matFiles=[matFiles m];
        end
    end
else
    matFiles=dir(fullfile(dataFolder,['run' experiment '*.mat']));
end

% Each block has a unique identifier: o.dataFilename. It is created
% just before we start running trials. I think that we could read all the
% data files, accumulating both block files, with an "oo" struct,
% and summary files which contain a whole experiment "ooo", consisting of
% multiple blocks "oo", each of which contains several thresholds "o".  
% If we first discard instances with zero trials then we can safely discard
% duplicates with the same identifier and neither lose data, nor retain any
% duplcate data.

% The summary file retains the organization of trials into blocks and
% experiments. The individual threshold files do not, but they do have
% "conditionName" "observer" and "experiment" fields that encode the most
% important aspects of the grouping.

%% READ ALL DATA INTO A LIST OF CONDITIONS IN STRUCT ARRAY "oo".
if nargin<1
    error('You must include the first argument, a string, but it can be an empty string.');
end
if nargin<2
    vars={'condition' 'conditionName' 'experiment' 'dataFilename' ...
        'experimenter' 'observer' 'trials' ...
        'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
        'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
        'targetCheckDeg' 'fullResolutionTarget' ...
        'noiseType' 'noiseSD'  'noiseCheckDeg' ...
        'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
        'contrast' 'E' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
        'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
        'pixPerCm'  'nearPointXYPix' 'NUnits' 'beginningTime'};
end
oo=struct([]);
filenameList={}; % Avoid duplicate data.
for iFile=1:length(matFiles) % One file per iteration.
    % Accumulate all conditions into one long oo struct array. First we
    % read each file into a temporary ooo{} cell array, each of whose
    % elements represents a block. There are two kinds of file: block and
    % summary. Each block file includes an oo() array struct, with one
    % element per condition, all tested during one block, interleaved. Each
    % summary file includes a whole experiment ooo{}, each of whose
    % elements represents a block by an oo() array struct, with one element
    % per condition.
    d=load(matFiles(iFile).name);
    if isfield(d,'ooo')
        % Get ooo struct (a cell array) from summary file.
        ooo=d.ooo;
    elseif isfield(d,'oo')
        % Get "oo" struct array from threshold file.
        ooo={d.oo};
    elseif isfield(d,'o')
        % Get "o" struct from threshold file.
        ooo={d.o};
    else
        continue % Skip unknown file type.
    end
    for block=1:length(ooo) % Iterate through blocks.
        if ~isfield(ooo{block},'dataFilename')
            % Skip any block lacking a dataFilename (undefined).
            continue
        end
        if ismember(ooo{block}(1).dataFilename,filenameList)
            % Skip if we already have this block of data.
            continue
        else
            filenameList{end+1}=ooo{block}(1).dataFilename;
        end
        for oi=1:length(ooo{block}) % Iterate through conditions within a block.
            ooo{block}(oi).localHostName=ooo{block}(oi).cal.localHostName; % Expose computer name, to help identify observer.
            if isempty(ooo{block}(oi).dataFilename)
                continue
            end
            o=ooo{block}(oi); % "o" holds one condition.
            oo(end+1).missingFields={}; % Create new element.
            usesSecsPlural=isfield(o,'targetDurationSecs');
            for i=1:length(vars)
                field=vars{i};
                if usesSecsPlural
                    oldField=field;
                else
                    oldField=strrep(field,'Secs','Sec');
                end
                switch oldField
                    case 'trialsDesired'
                        if isfield(o,'trials')
                            oldField='trials';
                        end
                end
                if isfield(o,oldField)
                    oo(end).(field)=o.(oldField);
                else
                    oo(end).missingFields{end+1}=field;
                end
            end
        end
    end
end
fprintf('ReadExperimentData read %d thresholds from %d files. Now discarding empties and duplicates.\n',length(oo),length(matFiles));

%% CLEAN UP THE LIST, DISCARDING WHAT WE DON'T WANT.
% We've now gotten all the thresholds into oo. 
if ~isfield(oo,'trials')
    error('No data');
end
oo=oo([oo.trials]>0); % Discard conditions with no data.
if isempty(oo)
    return;
end
[~,ii]=unique({oo.dataFilename}); % Discard duplicates.
oo=oo(ii);
% missingFields=unique(cat(1,oo.missingFields));
missingFields=unique(cat(2,oo.missingFields));
if ~isempty(missingFields)
    warning OFF BACKTRACE
    s='Missing fields:';
    s=[s sprintf(' o.%s',missingFields{:})];
    s=sprintf('%s\n',s);
    warning(s);
end
s=sprintf('condition.conditionName(trials):');
for oi=length(oo):-1:1
    if isempty(oo(oi).trials)
        oo(oi)=[];
    end
end
for oi=1:length(oo)
    [y,m,d,h,mi,s] = datevec(oo(oi).beginningTime) ;
    oo(oi).date=sprintf('%04d.%02d.%02d, %02d:%02d:%02.0f',y,m,d,h,mi,s);
end
tt=struct2table(oo,'AsArray',true);
% WARN AND DELETE DATA WITH TOO FEW TRIALS.
if sum(tt.trials<40)>0
    warning('Discarding %d threshold(s) with fewer than 40 trials:\n',sum(tt.trials<40));
    disp(tt(tt.trials<40,{'date' 'observer' 'experiment'  'conditionName' 'trials'}))
end
for oi=length(oo):-1:1
    if oo(oi).trials<40
        oo(oi)=[];
        tt(oi,:)=[];
    end
end

