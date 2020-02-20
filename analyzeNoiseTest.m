%% Analyze the data collected by runNoiseTest.
% denis.pelli@nyu.edu
% February 20, 2020

experiment='NoiseTest';
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
% clear Plot % Clear the persistent variables in the subroutine below.

%% READ ALL DATA OF experiment FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'experiment' 'dataFilename' ...
    'experimenter' 'observer' 'trials' ...
    'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' ...
    'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
    'targetCheckDeg' 'fullResolutionTarget' ...
    'targetFont' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'contrast' 'E' 'E1' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
    'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
    'pixPerCm'  'nearPointXYPix' 'NUnits' 'beginningTime' 'thresholdParameter'...
    'questMean' 'partingComments' 'blockSecs' 'blockSecsPerTrial'...
    'fullResolutionTarget'};
oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.
fprintf('%s %d thresholds.\n',experiment,length(oo));

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

% COMPUTE EFFICIENCY
% Select thresholdParameter='contrast', for each conditionName,
% For each observer, including ideal, use all (E,N) data to estimate deltaNOverE and Neq.
% Compute efficiency by comparing deltaNOverE of each to that of the ideal.
conditionNames=unique({oo.conditionName});
observers=unique({oo.observer});

% Round each target size to a power of 2.
for oi=1:numel(oo)
    oo(oi).targetHeightDeg = 2.^round(log2([oo(oi).targetHeightDeg]));
end

% We average all thresholds that match in:
% noiseType, conditionName, observer, targetHeight, and eccentricityXY.
targetHeightDegs=unique([oo.targetHeightDeg]);
eccXsfull=arrayfun(@(x) x.eccentricityXYDeg(1),oo);
eccXs=unique(eccXsfull);
noiseTypes=unique({oo.noiseType});
aa=[];
for conditionName=conditionNames
    for observer=observers
        for targetHeightDeg=targetHeightDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    match=ismember({oo.conditionName},conditionName) ...
                        & ismember({oo.observer},observer) ...
                        & ismember([oo.targetHeightDeg],targetHeightDeg) ...
                        & ismember(eccXsfull,eccX) ...
                        & ismember({oo.noiseType},noiseType);
                    match=match & ismember({oo.thresholdParameter},{'contrast'});
                    if sum(match)>0
                        E=[oo(match).E];
                        N=[oo(match).N];
                        [Neq,E0,deltaEOverN]=EstimateNeq(E,N);
                        aa(end+1).conditionName=conditionName{1};
                        aa(end).observer=observer{1};
                        aa(end).E=E;
                        aa(end).N=N;
                        aa(end).E0=E0;
                        aa(end).Neq=Neq;
                        aa(end).deltaEOverN=deltaEOverN;
                        oi=find(match,1);
                        aa(end).thresholdParameter=oo(oi).thresholdParameter;
                        aa(end).eccentricityDeg=eccX;
                        aa(end).targetHeightDeg=targetHeightDeg;
                        aa(end).contrast=[oo(match).contrast];
                        aa(end).noiseSD=[oo(match).noiseSD];
                        aa(end).noiseType=noiseType{1};
                    end
                end
            end
        end
    end
end

for conditionName=conditionNames
    for observer=observers
        for targetHeightDeg=targetHeightDegs
            for eccX=eccXs
                for noiseType=noiseTypes
                    match=ismember({aa.thresholdParameter},{'contrast'})...
                        & ismember({aa.conditionName},conditionName)...
                        & ismember([aa.targetHeightDeg],targetHeightDeg)...
                        & ismember([aa.eccentricityDeg], eccX) ...
                        & ismember({aa.noiseType},noiseType);
                    if targetHeightDeg>32
                        keyboard
                    end
                    idealMatch=match & ismember({aa.observer},{'ideal'});
                    match = match & ismember({aa.observer},observer);
                    if sum(match)>0 && sum(idealMatch)>0
                        assert(sum(match)==1 & sum(idealMatch)==1);
                        aa(match).efficiency=idealEOverN.(conditionName{1})/aa(match).deltaEOverN;
                        % aa(match).efficiency=aa(idealMatch).deltaEOverN/aa(match).deltaEOverN;
                    end
                end
            end
        end
    end
end
for i=1:length(aa)
    aa(i).noiseIndex=find(ismember(noiseTypes,aa(i).noiseType));
end
% human=~ismember({aa.observer},'ideal');

t=struct2table(aa);
t=sortrows(t,'conditionName');
disp(t(:,{'conditionName' 'targetHeightDeg' 'contrast' 'observer' 'noiseType' 'noiseIndex' 'noiseSD'}));
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
% for iefficiency=1:length(t.efficiency)
%   if isempty(t.efficiency{iefficiency})
%     t.efficiency{iefficiency}=NaN;
%   end
% end
writetable(t,fullfile(dataFolder,[experiment '.xls']));
jsonwrite(fullfile(dataFolder,[experiment '.json']), t);

a=table2struct(t);
ii=1:4;
% figure(1);
figureHandle=figure('Name',experiment,'NumberTitle','off','pos',[10 10 500 800]);
% orient 'landscape'; % For printing.

subplot(2,1,1);
semilogy([a(ii).noiseIndex],-[a(ii).contrast],'-r'); % 2
hold on
ii=ii+4;
semilogy([a(ii).noiseIndex],-[a(ii).contrast],'-g'); % 8
ii=ii+4;
semilogy([a(ii).noiseIndex],-[a(ii).contrast],'-b'); % 32
set(findall(gcf,'-property','FontSize'),'FontSize',12)
title('Gabor','fontsize',18)
xlabel('Noise type','fontsize',18);
ylabel('Contrast threshold','fontsize',18);
xlim([0 5]);
ax = gca;
ax.XTick = 1:4;
ax.XTickLabels = {'Binary' 'Gaussian' 'Ternary' 'Uniform'};
lgd=legend('Location','northwest','String',{'2 deg','8 deg','32 deg'},'fontsize',12);
lgd.Box='off';
title(lgd,'Size','fontsize',12)
hold off

% Scale log unit to be 18 cm, vertically.
ax=gca;
ax.YLim=[0.04 0.16];
u=ax.Units;
ax.Units='centimeters';
drawnow; % Needed for valid Position reading.
pos=ax.Position;
ax.Position=[pos(1:3) 18*diff(log10(ax.YLim))];
ax.Units=u;

subplot(2,1,2);
semilogy([a(ii).noiseIndex],-[a(ii).contrast],'-r'); % 2
hold on
ii=ii+4;
semilogy([a(ii).noiseIndex],-[a(ii).contrast],'-g'); % 8
ii=ii+4;
semilogy([a(ii).noiseIndex],-[a(ii).contrast],'-b'); % 32
title('Letter','fontsize',18)
xlabel('Noise type','fontsize',18);
ylabel('Contrast threshold','fontsize',18);
xlim([0 5]);
ax = gca;
ax.XTick = 1:4;
ax.XTickLabels = {'Binary' 'Gaussian' 'Ternary' 'Uniform'};
lgd=legend('Location','northwest','String',{'2 deg','8 deg','32 deg'},'fontsize',12);
lgd.Box='off';
title(lgd,'Size','fontsize',12)
hold off

% Scale log unit to be 18 cm, vertically.
ax=gca;
ax.YLim=[0.04 0.16];
u=ax.Units;
ax.Units='centimeters';
drawnow; % Needed for valid Position reading.
pos=ax.Position;
ax.Position=[pos(1:3) 18*diff(log10(ax.YLim))];
ax.Units=u;

set(findall(gcf,'-property','FontSize'),'FontSize',12);

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[experiment '.eps']);
saveas(gcf,graphFile,'epsc');
