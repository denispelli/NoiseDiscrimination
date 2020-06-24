%% Analyze the data collected by runCSFTest.
% denis.pelli@nyu.edu
% May 9, 2020

experiment='DynamicCSFTest';
% global printConditions makePlotLinear showLegendBox
% showLegendBox=true;
% printConditions=false;
printFilenames=true;
% plotGraphs=true;
% makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
close all

%% READ ALL DATA OF experiment FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'experiment' 'dataFilename' 'logFilename'...
    'experimenter' 'observer' 'trials' ...
    'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' 'targetGaborSpaceConstantCycles' 'targetCyclesPerDeg' ...
    'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
    'targetCheckDeg' 'isTargetFullResolution' ...
    'targetFont' 'isTargetFullResolution' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' 'noiseCheckFrames' 'isNoiseDynamic'...
    'moviePreAndPostFrames'  'moviePreAndPostSecs' 'movieSignalFrames' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'contrast' 'E' 'E1' 'N' 'NUnits' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
    'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
    'pixPerCm'  'nearPointXYPix'  'beginningTime' 'thresholdParameter'...
    'questMean' 'questSd' 'partingComments' 'blockSecs' 'blockSecsPerTrial'...
    ... % Needed by ComputeE1
    'task' 'stimulusRect' 'desiredLuminanceAtEye' 'beginningTime' 'targetGaborOrientationsDeg' ...
    'targetXYPix' 'pixPerDeg'...
    'targetWidthPix' 'targetHeightPix' 'targetCheckPix' 'getAlphabetFromDisk' 'screenRect'...
    'allowAnyFont' 'words' 'alternatives'  'canvasSize' 'gapFraction4afc'...
    };
oo=ReadExperimentData({experiment},vars); % Adds date and missingFields.
fprintf('%s %d thresholds.\n',experiment,length(oo));
oo=SortFields(oo);
oo=ComputeE1(oo);

%% Discard thresholds with bad estimates of frame rate.
%% Assume display actually runs at 60 Hz. Reject errors exceeding 10%.
for oi=1:length(oo)
    if ~isfield(oo,'displayHz') || isempty(oo(oi).displayHz) || ~isfinite(oo(oi).displayHz)
            oo(oi).movieHz=oo(oi).movieSignalFrames/oo(oi).targetDurationSecs;
            oo(oi).displayHz=oo(oi).noiseCheckFrames*oo(oi).movieHz;
    end
end
hz=[oo.displayHz];
ok=abs(hz-60)<6;
if ~all(ok)
    fprintf('WARNING: Discarding %d thresholds with bad frame rates:',sum(~ok));
    fprintf(' %.1f',sort([oo(~ok).displayHz]));
    fprintf(' Hz.\n');
end
oo=oo(ok); % Discard thresholds with bad estimates of frame rate.

% Fix the remaining oo(oi).targetDurationSecs for small errors in
% displayHz.
for oi=1:length(oo)
    oo(oi).targetDurationSecs=oo(oi).targetDurationSecs*oo(oi).displayHz/60;
end
fprintf('Unique o.targetDurationSecs:');
fprintf(' %.2f',unique([oo.targetDurationSecs]));
fprintf(' s.\n');

% x=1000./[oo.movieHz];
% y=1000*[oo.targetDurationSecs]/[oo.movieSignalFrames]; 
% loglog(x,y,'o');
% xlabel('Movie frame (ms)');
% ylabel('Signal frame (ms)');
% fprintf('movie frame %.2f +/- %.2f ms\n',mean(x),std(x));
% unique([oo.targetDurationSecs] ./ [oo.movieSignalFrames])
% unique(2*[oo.movieSignalFrames] ./ [oo.targetDurationSecs] )

%% Fix E1 and E if isNoiseDyname==true and duration was omitted.
for oi=1:length(oo)
    if oo(oi).logFilename(end-1)=='-'
        oo(oi).logFilename(end)='1';
    end
    if ~oo(oi).isNoiseDynamic
        continue
    end
    % If it says 'log E1/deg^2' then E1 and E omitted duration.
    content=fileread(fullfile(dataFolder,[oo(oi).logFilename,'.txt']));
    k=strfind(content,'log E1/deg^2');
    if isempty(k)
        continue
    end
    oo(oi).E1=oo(oi).E1*oo(oi).targetDurationSecs;
    oo(oi).E=oo(oi).E*oo(oi).targetDurationSecs;
end

% same=ismember({oo.dataFilename},'runDynamicCSFTest-NoiseDiscrimination-ideal-gaborCosCos.2020.5.22.23.53.16');
% oo(same)
% same=ismember({oo.dataFilename},'runDynamicCSFTest-NoiseDiscrimination-ideal-gaborCosCos.2020.5.22.23.54.49');
% oo(same)
if false
    experiment2='NoiseTest';
    oo2=ReadExperimentData(experiment2,vars); % Adds date and missingFields.
    fprintf('%s %d thresholds.\n',experiment2,length(oo2));
    for oi=1:length(oo2)
        oo2(oi).conditionName=strrep(oo2(oi).conditionName,'small','gabor');
    end
    oo=[oo oo2];
end

%% PRINT COMMENTS
if isfield(oo,'partingComments')
    comments={oo.partingComments};
    ok=true(size(comments));
    for i=1:length(comments)
        if isempty(comments{i}) || isempty(comments{i}{1})
            ok(i)=false;
        end
    end
    comments=comments(ok);
    for i=1:length(comments)
        fprintf('%s\n',comments{i}{1});
    end
end

%% Rename condition 'GaborX' to 'Gabor3';
for oi=1:length(oo)
    if ismember({oo(oi).conditionName},{'gaborX'})
        oo(oi).conditionName='gabor3';
    end
end

% ROUNDING
% Round each targetCyclesPerDeg >4 to an integer, otherwise one decimal.
% Round duration to two decimals.
if true
    for oi=1:length(oo)
        switch oo(oi).targetKind
            case 'gaborCosCos'
                % Round duration to multiple of 50 ms.
                oo(oi).targetDurationSecs=0.05*round(oo(oi).targetDurationSecs/0.05);
            otherwise
                % Round duration to multiple of 50 ms.
                oo(oi).targetDurationSecs=0.05*round(oo(oi).targetDurationSecs/0.05);
        end
        if oo(oi).targetCyclesPerDeg>4
            oo(oi).targetCyclesPerDeg=round(oo(oi).targetCyclesPerDeg);
        else
            oo(oi).targetCyclesPerDeg=round(oo(oi).targetCyclesPerDeg,1);
        end
    end
end

%% KEEP DATA ONLY AT 230 and 250 cd/m^2
ii=ismember([oo.desiredLuminanceAtEye],[230 250]);
oo=oo(ii);

%% KEEP ONLY THRESHOLDS WITH questSd<0.5
ii=[oo.questSd]<0.5;
oo=oo(ii);

%% SKIP ASHLEY'S BAD THRESHOLD.
fprintf('SKIPPING IMPOSSIBLY LOW THRESHOLDS\n');
plusMinusChar=char(177); % Use this instead of literal plus minus sign to
for oi=length(oo):-1:1
    if abs(oo(oi).contrast)<0.01 && oo(oi).noiseSD>0 && ~ismember(oo(oi).observer,{'ideal'})
        fprintf('%16s contrast %6.3f [%2.0f %2.0f] %2.0f c/deg, questMean%cquestSd %.2f%c%.2f %s %s\n',...
            oo(oi).observer,oo(oi).contrast,oo(oi).eccentricityXYDeg,...
            oo(oi).targetCyclesPerDeg,plusMinusChar,oo(oi).questMean,plusMinusChar,oo(oi).questSd,...
            oo(oi).date,oo(oi).dataFilename);
        oo(oi)=[];
    end
end
fprintf('\n');

%% UNIVERSAL WAY TO REPORT HEIGHT
%% o.targetEnvelopeDeg = full extent of envelope at 1/e.
for oi=1:length(oo)
    switch oo(oi).targetKind
        case {'gaborCos' 'gaborCosCos'}
            % Half cosine. Nonzero full extent is o.targetHeightDeg.
            oo(oi).targetEnvelopeDeg=oo(oi).targetHeightDeg*acos(exp(-1))/(pi/2); % trig scalar is 0.7602
        case 'gabor'
            oo(oi).targetEnvelopeDeg=2*oo(oi).targetGaborSpaceConstantCycles/oo(oi).targetCyclesPerDeg;
        case {'letter' 'image'}
            oo(oi).targetEnvelopeDeg=oo(oi).targetHeightDeg;
        otherwise
            error('Unknown o.targetKind ''%s''.',oo(oi).targetKind);
    end % switch oo(oi).targetKind
    oo(oi).targetEnvelopeCycles=oo(oi).targetEnvelopeDeg*oo(oi).targetCyclesPerDeg;
    oo(oi).targetEnvelopeCycles=round(oo(oi).targetEnvelopeCycles,1);
end

%% COMPUTE EFFICIENCY
% Select thresholdParameter='contrast', for each conditionName, For each
% observer, including ideal, use all (E,N) data to estimate deltaNOverE and
% Neq. Compute efficiency by comparing deltaNOverE of each to that of the
% ideal.

% Each element of aa is the average all thresholds in oo that match in:
% noiseType, conditionName, observer, targetHeight, and eccentricityXY.
% But ignore noiseType of thresholds for which noiseSD==0.
observers=unique({oo.observer});
% If any names differ solely in case, then collapse all names to
% lowercase.
isObserversLower=length(unique(lower(observers)))<length(observers);
if isObserversLower
    observers=unique(lower(observers));
end
isIdeal=ismember(observers,{'ideal'});
if any(isIdeal)
    % If present, put ideal observer first.
    observers=[observers(isIdeal) observers(~isIdeal)];
end
conditionNames=unique({oo.conditionName});
targetCyclesPerDegs=unique([oo.targetCyclesPerDeg]);
eccXsfull=arrayfun(@(x) x.eccentricityXYDeg(1),oo);
eccXs=unique(eccXsfull);
noiseTypes=unique({oo.noiseType});
luminances=unique([oo.desiredLuminanceAtEye]);
if true
    % Ignore luminances below 230 cd/m^2.
    ok=luminances>=229;
    luminances=luminances(ok);
end

oo=SortFields(oo);
vars={'noiseSD' 'N' 'E' 'conditionName' 'targetCyclesPerDeg' 'observer' 'dataFilename'};
t=struct2table(oo);
disp(t(ismember(t.observer,'ideal')&ismember(t.conditionName,'gaborCosCos'),vars));

%% COMPUTE Neq, E0, deltaEOverN
% aa has one element for each deltaEOverN. That element reflects all
% thresholds that contribute to its deltaEOverN. Efficiency is the ratio of
% deltaEOverN for ideal over that for human.
aa=[];
for observer=observers
    for conditionName=conditionNames
        for targetCyclesPerDeg=targetCyclesPerDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    for luminance=luminances
                        for duration=unique([oo.targetDurationSecs])
                            for cycle=unique([oo.targetEnvelopeCycles])
                                try
                                match=ismember({oo.conditionName},conditionName) ...
                                    & ismember([oo.targetCyclesPerDeg],targetCyclesPerDeg) ...
                                    & ismember(eccXsfull,eccX) ...
                                    & ismember([oo.desiredLuminanceAtEye],luminance) ...
                                    & (ismember({oo.noiseType},noiseType) | ismember([oo.noiseSD],0)) ...
                                    & ismember({oo.thresholdParameter},{'contrast'}) ...
                                    & ismember([oo.targetDurationSecs],duration) ...
                                    & ismember([oo.targetEnvelopeCycles],cycle);
                                catch
                                    1;
                                end
                                idealMatch=match & ismember(lower({oo.observer}),'ideal');
                                match=match & ismember(lower({oo.observer}),lower(observer));
                                % We include all noise levels within the match
                                % group, as they all contribute to estimating Neq.
                                % E0, and delatEOverN. We include zero-noise
                                % conditions without regard to noiseType. But we
                                % keep the resulting set of conditions only if at
                                % least one has the right noiseType.
                                if any(match) && any(ismember({oo(match).noiseType},noiseType))
                                    E=[oo(match).E];
                                    N=[oo(match).N];
                                    % EstimateNeq uses all noise levels.
                                    [Neq,E0,deltaEOverN]=EstimateNeq(E,N);
                                    % c and EOverN use only max noise level.
                                    m=ismember(N,max(N));
                                    if max(N)>0
                                        c=[oo(match).contrast];
                                        c=mean(c(m));
                                    end
                                    EOverN=mean(E(m))/max(N);
                                    % c0 uses only zero noise.
                                    m=ismember(N,0);
                                    if any(m)
                                        c0=[oo(match).contrast];
                                        c0=mean(c0(m));
                                    else
                                        c0=nan;
                                    end
                                    oi=find(match,1);
                                    aa(end+1).experiment=oo(oi).experiment;
                                    aa(end).conditionName=oo(oi).conditionName;
                                    aa(end).observer=oo(oi).observer;
                                    aa(end).dates=sort({oo(match).date});
                                    aa(end).date=aa(end).dates{end};
                                    aa(end).c=c; % Scalar
                                    aa(end).c0=c0; % Scalar
                                    aa(end).EOverN=EOverN; % Scalar
                                    aa(end).maxNoiseSD=max([oo(match).noiseSD]); % Scalar
                                    aa(end).E=E; % Array
                                    aa(end).N=N; % Array
                                    aa(end).E0=E0; % Scalar
                                    aa(end).Neq=Neq; % Scalar
                                    aa(end).deltaEOverN=deltaEOverN; % Scalar
                                    aa(end).dataFilenames=sort({oo(match).dataFilename});
                                    aa(end).dataFilename=aa(end).dataFilenames{end};
                                    aa(end).thresholdParameter=oo(oi).thresholdParameter;
                                    aa(end).eccentricityDeg=eccX;
                                    aa(end).targetCyclesPerDeg=targetCyclesPerDeg;
                                    aa(end).targetGaborCycles=mean([oo(match).targetGaborCycles]);
                                    aa(end).targetHeightDeg=mean([oo(match).targetHeightDeg]);
                                    aa(end).contrast=[oo(match).contrast];
                                    aa(end).noiseSD=[oo(match).noiseSD];
                                    aa(end).noiseType=noiseType{1};
                                    aa(end).desiredLuminanceAtEye=luminance;
                                    aa(end).NUnits=oo(match).NUnits;
                                    aa(end).targetEnvelopeCycles=mean([oo(match).targetEnvelopeCycles]);
                                    aa(end).targetEnvelopeDeg=mean([oo(match).targetEnvelopeDeg]);
                                    aa(end).targetDurationSecs=mean([oo(match).targetDurationSecs]); % =duration
                                    aa(end).n=length(E);
                                    aa(end).eccX=eccX;
                                    aa(end).idealMatch=find(idealMatch);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
aa=SortFields(aa);
vars={'Neq' 'E0' 'deltaEOverN' 'noiseSD' 'N' 'E' 'conditionName' 'targetCyclesPerDeg' 'eccX' 'observer' 'dataFilename'};
t=struct2table(aa);
disp(t(t.n==1,vars));
disp(t(t.n==2,vars));

% Now analyze aa, matching each human record with the corresponding ideal
% observer record.
[aa.efficiency]=deal(-1);
[aa.touched]=deal(false);
for conditionName=conditionNames
    for observer=observers
        for targetCyclesPerDeg=targetCyclesPerDegs
            for luminance=luminances
                for eccX=eccXs
                    for noiseType=noiseTypes
                        for duration=unique([oo.targetDurationSecs])
                            for cycle=unique([oo.targetEnvelopeCycles])
                                match=ismember({aa.thresholdParameter},{'contrast'})...
                                    & ismember({aa.conditionName},conditionName)...
                                    & ismember([aa.targetCyclesPerDeg],targetCyclesPerDeg)...
                                    & ismember([aa.desiredLuminanceAtEye],luminance)...
                                    & ismember([aa.eccentricityDeg],eccX) ...
                                    & ismember({aa.noiseType},noiseType) ...
                                    & ismember([aa.targetDurationSecs],duration) ...
                                    & ismember([aa.targetEnvelopeCycles],cycle);
                                idealMatch=match & ismember({aa.observer},{'ideal'});
                                match = match & ismember(lower({aa.observer}),lower(observer));
                                if any(match)
                                    aa(match).efficiency=nan;
                                    aa(match).touched=true;
                                    aa(match).idealMatch=find(idealMatch);
                                end
                                if any(match) && any(idealMatch)
                                    assert(sum(match)==1 & sum(idealMatch)==1);
                                    aa(match).efficiency=(aa(idealMatch).E/aa(idealMatch).N)/aa(match).deltaEOverN;
                                    if isempty(aa(match).efficiency)
                                        1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

for i=1:length(aa)
    % Convert noiseType (a name) to noiseIndex (an integer).
    aa(i).noiseIndex=find(ismember(noiseTypes,aa(i).noiseType));
end
% human=~ismember({aa.observer},'ideal');

oo=SortFields(oo);

%% CHECK FOR MISSING EFFICIENCY
fprintf('CHECK FOR MISSING EFFICIENCY\n');
fprintf('%d elements of aa are untouched.\n',sum(~[aa.touched]));
for i=1:length(aa)
    if -1==aa(i).efficiency
        fprintf('aa(%d) touched %d, deltaEOverN %.1f, efficiency -1, conditionName %s, c/deg %.0f, eccX %.0f, luminance %.0f',...
            i,aa(i).touched,aa(i).deltaEOverN,aa(i).conditionName,...
            aa(i).targetCyclesPerDeg,aa(i).eccX,...
            aa(i).desiredLuminanceAtEye);
        fprintf(', ooIdealMatch');
        fprintf(' %d',aa(i).idealMatch);
        fprintf(', noiseSD');
        fprintf(' %.2f',aa(i).noiseSD);
        fprintf(', E ');
        fprintf(' %f',aa(i).E);
        fprintf('\n');
        match=ismember({aa.thresholdParameter},{'contrast'})...
            & ismember({aa.conditionName},'gabor')...
            & ismember([aa.desiredLuminanceAtEye],[230 ])...
            & ismember([aa.eccentricityDeg],[0 ]);
        idealMatch=match & ismember({aa.observer},{'ideal'});
        1;
    end
end
fprintf('\n');


%% SAVE TABLE TO DISK
aa=SortFields(aa);
t=struct2table(aa);
t=sortrows(t,'conditionName');
t=sortrows(t,'observer');
disp(t(:,{'experiment' 'conditionName' 'targetHeightDeg' ...
         'targetDurationSecs' 'targetEnvelopeCycles'...
    'targetCyclesPerDeg' 'noiseSD' 'efficiency' 'c' 'contrast' 'observer' ...
    'noiseType' 'maxNoiseSD' 'dataFilename' 'date'}));
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
% On Feb, 20, 2020 I discovered that writetable may screw up xls tables,
% but xlsx seems to be ok.
writetable(t,fullfile(dataFolder,[experiment '.xlsx']));
jsonwrite(fullfile(dataFolder,[experiment '.json']), t);
fprintf('Wrote files %s and %s to disk.\n',[experiment '.xlsx'],[experiment '.json']);

%% PLOT THREE GRAPHS FOR EACH OBSERVER
% Convert table t to struct a
a=table2struct(t);

%% PLOT CONTRAST VERSUS targetCyclesPerDeg
figureHandle(1)=PlotVariable(experiment,a,'Contrast','Contrast');

%% PLOT EOverN FOR EACH OBSERVER
figureHandle(2)=PlotVariable(experiment,a,'E/N','EOverN');

%% PLOT EFFICIENCY FOR EACH OBSERVER
figureHandle(3)=PlotVariable(experiment,a,'Efficiency','Efficiency');

%% PLOT Neq FOR EACH OBSERVER
figureHandle(3)=PlotVariable(experiment,a,'Neq','Neq');


