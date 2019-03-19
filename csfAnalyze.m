%% Analyze the data collected by csfRun.
% Why did I have to adjust the ideal thresholds? What changed?
% Does new letter efficiency match old graph?
% It seems misleading to count repeats of same observer when reporting n.
global printConditions figureHandle averageAcrossObservers displayCaption observerList
global printObserverNames showIdeal
for expt={'csfLettersStatic' 'csfGaborsStatic'}
    % for expt={'csf' 'csfLetters' 'csfLettersStatic' 'csfGaborsStatic'}
    printObserverNames=false;
    experiment=expt{1};
    idealEOverN=struct;
    idealEOverN.letter=1.27/0.15; % Ran ideal, average of 30 1000-trial thresholds. sd=0.17
    idealEOverN.gabor=1.49/.8; % Ran ideal, average of 30 1000-trial thresholds. sd=0.10
    averageAcrossObservers=true;
    showIdeal=true;
    readExperiment=true;
    printConditions=false;
    displayCaption=false;
    printFilenames=true;
    plotGraphs=true;
    myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
    addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
    dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
    cd(dataFolder);
    if readExperiment
        % Each file contains an experiment: a cell array with one cell per
        % block. Each cell contains a struct array, with an element per
        % condition and its threshold.
        matFiles=dir(fullfile(dataFolder,'EvsN-*.mat'));
        m=dir(fullfile(dataFolder,[experiment 'Run*.summary.mat']));
        matFiles=[matFiles;m];
        m=dir(fullfile(dataFolder,[experiment '*-done.*.mat']));
        matFiles=[matFiles;m];
    else
        % Each file contains one condition and its threshold.
        s=[experiment '*-NoiseDiscrimination*.mat'];
        matFiles=dir(fullfile(dataFolder,s));
    end
    close all
    % We will ignore the blocking and read every condition into one huge struct
    % array oo. Each element contains one condition and its threshold.
    oo=[];
    clear Plot % To clear the persistent variables in the subroutine below.
    oi=0;
    vars={'functionNames' 'conditionName' 'experiment' 'dataFilename' ...
        'experimenter' 'observer' 'trials' ...
        'targetKind' 'targetGaborPhaseDeg' 'targetGaborCycles' 'targetCyclesPerDeg'...
        'targetHeightDeg' 'targetDurationSecs' 'targetDurationSecsMean' 'targetDurationSecsSD'...
        'targetCheckDeg' 'fullResolutionTarget' ...
        'noiseType' 'noiseSD'  'noiseCheckDeg' ...
        'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
        'contrast' 'E' 'N' 'LBackground' 'luminanceAtEye' 'luminanceFactor'...
        'filterTransmission' 'useFilter' 'retinalIlluminanceTd' 'pupilDiameterMm'...
        'pixPerCm' 'nearPointXYPix' 'trialsPerBlock' 'NUnits' 'useDynamicNoiseMovie' 'noiseCheckFrames'};
    for iFile=1:length(matFiles) % One file per iteration.
        % Extract the desired fields into "oo", one cell-row per threshold.
        d=load(matFiles(iFile).name);
        if readExperiment
            if contains(matFiles(iFile).name,'NoiseDiscrimination') || ~isfield(d,'ooo')
                %                 continue
            end
            if isempty(d.ooo{1}(1).observer)
                continue
            end
            if ~startsWith(d.ooo{1}(1).functionNames,experiment)
                fprintf('Skipping function name: %s\n',d.ooo{1}(1).functionNames);
                continue
            end
            ooo=d.ooo;
        else
            if ~isfield(d,'o') || d.o.trials<d.o.trialsPerBlock
                continue
            end
            ooo={d.o};
        end
        for block=1:length(ooo)
            ooIn=ooo{block};
            % Fix error in experiment name. Assume o.functionNames is right.
            [ooIn.experiment]=deal(experiment);
            % Fill in missing names. Assume first block is right.
            [ooIn.experimenter]=deal(ooo{1}(1).experimenter);
            [ooIn.observer]=deal(ooo{1}(1).observer);
            for oiIn=1:length(ooIn)
                oi=oi+1;
                for field=vars
                    if isfield(ooIn(oiIn),field{1})
                        newField=field{1};
                        oo(oi).(newField)=ooIn(oiIn).(field{1});
                    else
                        if block==1
                            warning OFF BACKTRACE
                            warning('Missing o field: %s\n',field{:});
                        end
                    end
                end
            end
        end
    end
    if isempty(oo)
        fprintf('Couldn''t find any data for experiment "%s".\n',experiment);
        return
    end
    
    % DISCARD THRESHOLDS WITH INSUFFICIENT TRIALS
    s=sprintf('condition(trials):');
    for oi=length(oo):-1:1
        if isempty(oo(oi).trials) || oo(oi).trials<oo(oi).trialsPerBlock
            s=[s sprintf(' %d(%d),',oi,oo(oi).trials)];
            oo(oi)=[];
            continue
        end
        % Delete thresholds that seem impossibly low.
        %         if oo(oi).contrast<0.01
        %             oo(oi)=[];
        %             continue
        %         end
    end
    if sum([oo.trials]<oo(1).trialsPerBlock)>0
        warning('Discarding %d threshold(s) with fewer than %d trials: %s',sum([oo.trials]<oo(1).trialsPerBlock),oo(oi).trialsPerBlock,s);
    end
    
    % COMPUTE DERIVED QUANTITIES
    oo=ComputeNPhoton(oo);
    for observer=unique({oo.observer})
        for conditionName=unique({oo.conditionName})
            ii=ismember({oo.conditionName},conditionName)&ismember({oo.observer},observer);
            if sum(ii(:))>1
                E=[oo(ii).E];
                N=[oo(ii).N];
                ok=abs([oo(ii).contrast])<1.1;
                [E0,Neq]=EstimateNeq(E,N,ok);
                efficiency=idealEOverN.(oo(1).targetKind)/(E0/Neq);
            else
                E0=[];
                Neq=[];
                efficiency=[];
            end
            [oo(ii).E0]=deal(E0);
            [oo(ii).Neq]=deal(Neq);
            [oo(ii).efficiency]=deal(efficiency);
        end
    end
    
    % FOR EACH conditionName AND noiseSD, COMPUTE AVERAGE "a" ACROSS
    % ALL OBSERVERS, EXCEPT IDEAL. WE DON'T YET EXCLUDE DUPLICATES.
    if averageAcrossObservers
        observerList=unique({oo.observer});
        ok=~ismember(observerList,'ideal');
        observerList=observerList(ok); % Exclude 'ideal'.
        numberOfObservers=length(observerList);
        aa=[];
        ai=0;
        % We average all the data for all conditions sharing the same
        % condition name and noiseSD. Currently we treat two runs by one
        % observer in the same way as runs by different observers. In
        % principle one might want to average each observer's data before
        % averaging across observers.
        for conditionName=unique({oo.conditionName})
            for noiseSD=unique([oo.noiseSD])
                ii=ismember({oo.conditionName},conditionName) & ismember([oo.noiseSD],noiseSD)...
                    & ismember({oo.observer},observerList);
                if isempty(ii)
                    continue
                end
                ai=ai+1;
                aa(ai).n=sum(ii(:));
                aa(ai).observerList={oo(ii).observer};
                aa(ai).ii=ii;
                aa(ai).experiment=oo(find(ii,1)).experiment;
                aa(ai).experimenter=oo(find(ii,1)).experimenter;
                aa(ai).observer=sprintf('n=%d',numberOfObservers);
                aa(ai).conditionName=conditionName{1};
                ok=ii & isfinite([oo.contrast]) & abs([oo.contrast])<1 & abs([oo.contrast])>0.002;
                aa(ai).contrast=mean([oo(ok).contrast],'omitnan');
                aa(ai).contrastSD=std([oo(ok).contrast],'omitnan');
                aa(ai).contrastSE=std([oo(ok).contrast],'omitnan')/sqrt(sum(ok(:)));
                aa(ai).E=mean([oo(ii).E],'omitnan');
                aa(ai).ESD=std([oo(ii).E],'omitnan');
                aa(ai).ESE=std([oo(ii).E],'omitnan')/sqrt(sum(ii(:)));
                aa(ai).Neq=mean([oo(ii).Neq],'omitnan');
                aa(ai).NeqSD=std([oo(ii).Neq],'omitnan');
                aa(ai).NeqSE=std([oo(ii).Neq],'omitnan')/sqrt(sum(ii(:)));
                ok=ii & isfinite([oo.efficiency]) & [oo.efficiency]<1;
                aa(ai).efficiency=mean([oo(ok).efficiency],'omitnan');
                aa(ai).efficiencySD=std([oo(ok).efficiency],'omitnan');
                aa(ai).efficiencySE=std([oo(ok).efficiency],'omitnan')/sqrt(sum(ok(:)));
                aa(ai).eccentricityXYDeg=oo(find(ii,1)).eccentricityXYDeg;
                aa(ai).targetHeightDeg=oo(find(ii,1)).targetHeightDeg;
                aa(ai).targetCyclesPerDeg=oo(find(ii,1)).targetCyclesPerDeg;
                aa(ai).targetKind=oo(find(ii,1)).targetKind;
                aa(ai).E0=oo(find(ii,1)).E0;
                aa(ai).N=oo(find(ii,1)).N;
                aa(ai).dataFilename=oo(find(ii,1)).dataFilename;
                aa(ai).noiseSD=oo(find(ii,1)).noiseSD;
                aa(ai).targetGaborCycles=oo(find(ii,1)).targetGaborCycles;
                aa(ai).LBackground=oo(find(ii,1)).LBackground;
                aa(ai).filterTransmission=oo(find(ii,1)).filterTransmission;
                aa(ai).pupilDiameterMm=oo(find(ii,1)).pupilDiameterMm;
                aa(ai).eyes=oo(find(ii,1)).eyes;
                aa(ai).targetDurationSecs=oo(find(ii,1)).targetDurationSecs;
                aa(ai).retinalIlluminanceTd=oo(find(ii,1)).retinalIlluminanceTd;
                aa(ai).noiseCheckDeg=oo(find(ii,1)).noiseCheckDeg;
                aa(ai).noiseType=oo(find(ii,1)).noiseType;
                aa(ai).luminanceAtEye=oo(find(ii,1)).luminanceAtEye;
                aa(ai).noiseCheckFrames=oo(find(ii,1)).noiseCheckFrames;
                aa(ai).useDynamicNoiseMovie=oo(find(ii,1)).useDynamicNoiseMovie;
                fprintf('%d:%s,%s,%s: %d thresholds, %d observers\n',...
                    ai,aa(ai).experiment,aa(ai).conditionName,aa(ai).observer,aa(ai).n,numberOfObservers);
            end
        end
        ooOld=oo;
        oo=aa;
    end
    % Display table of thresholds.
    t=struct2table(oo);
    for exp=unique(t.experiment)
        for cond=(t.conditionName)
            rows=ismember(t.experiment,exp) & ismember(t.conditionName,cond) & t.noiseSD>0;
            disp(t(rows,{'experiment' 'conditionName' 'efficiency' 'contrast'}));
        end
    end
    
    if plotGraphs
        fprintf('Plotting %d thresholds.\n',length(oo));
        observers=unique({oo.observer});
        
        if 1
            field='contrast';
            figureHandle=[];
            if averageAcrossObservers
                style={'-' '-' '-' '-'};
            else
                style={'-xk' '--xk' '-.xk' ':xk'};
            end
            if averageAcrossObservers
                if showIdeal
                    subplots=[2 2];
                else
                    subplots=[2 1];
                end
                fprintf('%s %s %s: %d thresholds.\n',experiment,'average',field);
                for col=1:subplots(2)
                    switch col
                        case 1
                            iiObserver=true(size(observer));
                        case 2
                            averageAcrossObservers=false;
                            oo=ooOld;
                            iiObserver=ismember('ideal',{oo.observer});
                    end
                    for row=1:subplots(1)
                        subplotIndex=sub2ind(fliplr(subplots),col,row);
                        switch row
                            case 1
                                which= iiObserver & [oo.noiseSD]>0;
                            case 2
                                which= iiObserver & [oo.noiseSD]==0;
                        end
                        Plot(field,oo(which),subplots,subplotIndex,style);
                    end
                    averageAcrossObservers=true;
                    oo=aa;
                end
            else
                subplots=[2 length(observers)];
                for col=1:subplots(2)
                    observer=observers{col};
                    iiObserver=ismember({oo.observer},observer);
                    if sum(iiObserver)>0
                        fprintf('%s %s %s: %d thresholds.\n',experiment,observer,field,sum(iiObserver));
                        for row=1:subplots(1)
                            subplotIndex=sub2ind(fliplr(subplots),col,row);
                            switch row
                                case 1
                                    which=iiObserver & [oo.noiseSD]>0;
                                case 2
                                    which=iiObserver & [oo.noiseSD]==0;
                            end
                            Plot(field,oo(which),subplots,subplotIndex,style);
                        end
                    end
                end
            end
        end
        
        if 1
            field='efficiency';
            figureHandle=[];
            subplots=[2 length(observers)];
            if averageAcrossObservers
                style={'-k' '--k' '-.k' ':k'};
                style={'-' '-' '-' '-'};
            else
                style={'-xk' '--xk' '-.xk' ':xk'};
            end
            if averageAcrossObservers
                if showIdeal
                    subplots=[2 2];
                else
                    subplots=[2 1];
                end
                fprintf('%s %s %s: %d thresholds.\n',experiment,'average',field,length(oo));
                for col=1:subplots(2)
                    switch col
                        case 1
                            iiObserver=0;
                        case 2
                            averageAcrossObservers=false;
                            iiObserver=ismember('ideal',observer);
                    end
                    for row=1:subplots(1)
                        subplotIndex=sub2ind(fliplr(subplots),col,row);
                        which=[oo.noiseSD]==iiObserver & [oo.targetHeightDeg]>0.15;
                        switch row
                            case 1
                                Plot('efficiency',oo(which),subplots,subplotIndex,style);
                            case 2
                                Plot('Neq',oo(which),subplots,subplotIndex,style);
                        end
                    end
                    averageAcrossObservers=true;
                end
            else
                for col=1:length(observers)
                    observer=observers{col};
                    iiObserver=ismember({oo.observer},observer);
                    if sum(iiObserver)>0
                        fprintf('%s %s %s: %d thresholds.\n',experiment,observer,field,sum(iiObserver));
                        which=iiObserver & [oo.noiseSD]==0;
                        for row=1:subplots(1)
                            subplotIndex=sub2ind(fliplr(subplots),col,row);
                            switch row
                                case 1
                                    Plot('efficiency',oo(which),subplots,subplotIndex,style);
                                case 2
                                    Plot('Neq',oo(which),subplots,subplotIndex,style);
                            end
                        end
                    end
                end
            end % if averageAcrossObservers
        end
        
        if 1
            field='EOverN';
            figureHandle=[];
            subplots=[1 length(observers)];
            if averageAcrossObservers
                style={'-k' '--k' '-.k' ':k'};
                style={'-' '-' '-' '-'};
            else
                style={'-xk' '--xk' '-.xk' ':xk'};
            end
            if averageAcrossObservers
                if showIdeal
                    subplots=[2 2];
                else
                    subplots=[2 1];
                end
                fprintf('%s %s %s: %d thresholds.\n',experiment,'average',field);
                for col=1:subplots(2)
                    switch col
                        case 1
                            iiObserver=true(size(observer));
                        case 2
                            averageAcrossObservers=false;
                            oo=ooOld;
                            iiObserver=ismember({oo.observer},'ideal');
                    end
                    for row=1:subplots(1)
                        subplotIndex=sub2ind(fliplr(subplots),col,row);
                        switch row
                            case 1
                                Plot('EOverN',oo(which),subplots,subplotIndex,style);
                            case 2
                                Plot('efficiency',oo(which),subplots,subplotIndex,style);
                        end
                    end
                    averageAcrossObservers=true;
                    oo=aa;
                end
            else
                for col=1:subplots(2)
                    observer=observers{col};
                    iiObserver=ismember({oo.observer},observer);
                    if sum(iiObserver)>0
                        fprintf('%s %s %s: %d thresholds.\n',experiment,observer,field,sum(iiObserver));
                        which=iiObserver & [oo.noiseSD]>0;
                        for row=1:subplots(1)
                            subplotIndex=sub2ind(fliplr(subplots),col,row);
                            switch row
                                case 1
                                    Plot('EOverN',oo(which),subplots,subplotIndex,style);
                                case 2
                                    Plot('Neq',oo(which),subplots,subplotIndex,style);
                            end
                        end
                    end % if sum
                end % for col
            end % if averageAcrossObservers
        end
        
    end % if plotGraphs
end % for expt={}
return

%% PLOT
function Plot(field,oo,subplots,subplotIndex,style,color)
global printConditions figureHandle averageAcrossObservers displayCaption
global printObserverNames
persistent figureTitle axisHandle
if isempty(oo)
    return
end
if nargin<5
    style={'-' '-' '-' '-'};
end
if nargin<6
    color=[0 0 0;.5 .5 .5;.7 .7 .7;.8 .8 .8;.9 .9 .9];
end
fontSize=10;
if isempty(figureHandle)
    rect=Screen('Rect',0);
    figureTitle=[oo(1).experiment '-' field];
    if averageAcrossObservers
        figureTitle=[figureTitle '-average'];
    end
    if averageAcrossObservers
        figureHandle=figure('Name',figureTitle,'NumberTitle','off','pos',[10 10 900 700]);
    else
        figureHandle=figure('Name',figureTitle,'NumberTitle','off','pos',[10 10 1280 700]);
    end
    orient 'landscape'; % For printing.
    overPlots=zeros(1,subplots(1)*subplots(2));
    axisHandle=zeros(1,subplots(1)*subplots(2));
    an=annotation('textbox',[0 0.9 1 .1],...
        'String',figureTitle,...
        'LineStyle','none','FontSize',fontSize*2,...
        'HorizontalAlignment','center','VerticalAlignment','top');
else
    figure(figureHandle);
end
if axisHandle(subplotIndex)==0
    % subplot(m,n,p) makes it easy to show several related graphs in one
    % figure window. Calling subplot(m,n,p) for an existing axis object
    % seems to erase it. So, when we first select that figure panel, we
    % save a handle to it, which we later reuse to select the panel by
    % calling subplot(handle), without calling subplot(m,n,p) again.
    axisHandle(subplotIndex)=subplot(subplots(1),subplots(2),subplotIndex);
else
    hold(axisHandle(subplotIndex),'on');
    subplot(axisHandle(subplotIndex));
end

% Sort by eccentricity.
x=[];
for i=1:length(oo)
    x(i)=oo(i).eccentricityXYDeg(1);
end
[~,ii]=sort(x);
oo=oo(ii);
% Sort by sf.
[~,ii]=sort([oo.targetCyclesPerDeg]);
oo=oo(ii);

% Create CSV file
vars={'experiment' 'conditionName' ...
    'experimenter' 'observer' 'trials' 'contrast' 'luminanceAtEye' 'E' 'N' ...
    'Neq' 'E0' 'efficiency' ...
    'targetKind' 'targetCyclesPerDeg' 'targetHeightDeg' 'targetDurationSecs' ...
    'noiseType' 'noiseSD'  'noiseCheckDeg' ...
    'eccentricityXYDeg' 'viewingDistanceCm' 'eyes' ...
    'LBackground'  'dataFilename' 'useDynamicNoiseMovie' 'noiseCheckFrames'};
t=struct2table(oo);
% spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',[oo(1).experiment '.csv']);
% writetable(t,spreadsheet);
if printConditions
    disp(t(:,vars));
end
% fprintf('All selected fields have been saved in spreadsheet: /data/%s.csv\n',oo(1).experiment);

% Plot
N=[oo.N];
Neq=oo(1).Neq;
E0=oo(1).E0;
if Neq>=min(N) && Neq<2*max(N)
    % Trust reasonable Neq.
    NLow=Neq/100;
    NHigh=max([N Neq*10]);
else
    % Igore crazy Neq.
    NLow=min(N(N>0)); % Smallest nonzero noise.
    NHigh=max(N);
end
sfList=unique([oo.targetCyclesPerDeg]);
yAll=[];
for iStyle=1:length(sfList)
    sf=sfList(iStyle);
    ii=[oo.targetCyclesPerDeg]==sf;
    switch oo(1).targetKind
        case 'gabor'
            legendText=sprintf('%.1f c/deg',sf);
        case {'letter' 'word'} % March 2019 DGP
            legendText=sprintf('%.1f deg',oo(1).targetGaborCycles/sf);
    end
    switch field
        case 'EOverN'
            y=abs([oo(ii).E]-[oo(ii).E0])./[oo(ii).N];
        otherwise
            y=abs([oo(ii).(field)]);
    end
    y(y>10^3*min(y))=nan;
    yAll=[yAll y];
    try
        x=[];
        for i=find(ii)
            x(end+1)=oo(i).eccentricityXYDeg(1)+0.15;
        end
        h=loglog(x,y,style{min(iStyle,length(style))});
        h.Color=color(min(iStyle,size(color,1)),1:3);
        h.LineWidth=2;
        h.DisplayName=legendText;
        hold on
    catch e
        fprintf('observer %s, condition %s, legend %s\n',oo(1).observer,oo(1).conditionName,legendText);
        fprintf('size x %d %d, size y %d %d\n',length([oo(ii)]),length(y));
        rethrow(e);
    end
    if averageAcrossObservers
        % Error bars
        switch field
            case 'EOverN'
                ySE=[oo(ii).ESE]./[oo(ii).N];
            otherwise
                ySE=[oo(ii).([field 'SE'])];
        end
        x=[];
        for i=find(ii)
            x(end+1)=oo(i).eccentricityXYDeg(1)+0.15;
        end
        x=Expand(x,1,2);
        yBar=zeros(2,length(ySE));
        yBar(1,:)=y-ySE;
        yBar(2,:)=y+ySE;
        loglog(x,yBar,'-k','LineWidth',1,'HandleVisibility','off');
        j=find(ii,1);
        msg=sprintf('n = %d',oo(j).n);
        if printObserverNames
            msg=[msg '.'];
            for i=1:length(oo(j).observerList)
                msg=[msg sprintf(' %s',oo(j).observerList{i})];
            end
        end
        if iStyle==1
            text(4,8,msg,'Units','points','FontSize',fontSize);
        end
        hold on
    end
    hold on;
end % for iStyle=1:length(sfList)
% NLine=logspace(log10(NLow),log10(NHigh));
% ELine=(NLine+Neq)*E0/Neq;
% loglog(NLine,ELine,style2,'DisplayName','Linear fit');
set(gca,'FontSize',fontSize);
if ~averageAcrossObservers
    title([oo(1).observer]);
end
xlabel('Eccentricity+0.15 (deg)','Interpreter','tex','FontSize',fontSize);
xtickformat('%.1f');
switch field
    case 'Neq'
        ylabel('{\itN}eq (s deg^2)','Interpreter','tex','FontSize',fontSize);
    case 'contrast'
        ylabel('Contrast','Interpreter','tex','FontSize',fontSize);
    case 'efficiency'
        ylabel('Efficiency','Interpreter','tex','FontSize',fontSize);
    case 'EOverN'
        ylabel('(E-E0)/N','Interpreter','tex','FontSize',fontSize);
    otherwise
        ylabel(field,'Interpreter','tex','FontSize',fontSize);
end
if 1 || ~averageAcrossObservers
    lgd=legend('show');
    lgd.Location='southwest';
    lgd.FontSize=fontSize;
    legend('boxoff');
end
oo=ComputeNPhoton(oo);
caption={};
caption{1}=sprintf('observer %s, eyes %s', ...
    oo(1).observer,oo(1).eyes);
caption{2}=sprintf('noiseSD<=%.2f, noiseCheckDeg %.3f, noiseType %s', ...
    max([oo.noiseSD]),oo(1).noiseCheckDeg,oo(1).noiseType);
caption{3}=sprintf('%.1f cd/m^2, %.1f s, %s, useDynamicNoiseMovie %d, noiseCheckFrames %d', ...
    oo(1).luminanceAtEye,oo(1).targetDurationSecs,oo(1).targetKind,oo(1).useDynamicNoiseMovie,oo(1).noiseCheckFrames);
% If necessary, expand Y range to 3 log units.
switch field
    case 'contrast'
        logUnits=3;
    otherwise
        logUnits=2;
end
ax=gca;
yLim=ax.YLim;
assert(all(isreal(yLim)) && all(yLim>0),...
    sprintf('Complex or not positive: %f%+fi %f%+fi  %f%+fi %f%+fi\n',...
    real(yLim(1)),imag(yLim(1)),real(yLim(2)),imag(yLim(2))));
switch field
    case 'contrast'
        yLim=[3e-3 1];
    case 'efficiency'
        yLim=[3e-3 1];
     case 'EOverN'
        yLim=[.1 100];
   case 'Neq'
        yLim=[1e-7 3e-4];
end
ax.YLim=yLim;
switch field
    case 'contrast'
        yticklabels({'0.01' '0.1' '1'});
    case 'efficiency'
        yticklabels({'0.01' '0.1' '1'});
    case 'EOverN'
        yticklabels({'0.1' '1' '10' '100'});
    case 'Neq'
end

% Scale log unit to be logUnitCm, vertically and horizontally for all
% variables, except 2*logUnitCm per log unit of contrast.
ax=gca;
u=ax.Units;
ax.Units='centimeters';
drawnow; % Needed for valid Position reading.
pos=ax.Position;
logUnitCm=2;
switch field
    case 'contrast'
        ax.Position=[pos(1:2) logUnitCm*diff(log10(ax.XLim)) 2*logUnitCm*diff(log10(ax.YLim))];
    otherwise
        ax.Position=[pos(1:2) logUnitCm*diff(log10(ax.XLim)) logUnitCm*diff(log10(ax.YLim))];
end
ax.Units=u;

xLim=ax.XLim;
yLim=ax.YLim;
if ~averageAcrossObservers && displayCaption
    switch field
        case 'contrast'
            text(xLim(1),yLim(1)*20^0.5,caption,'FontSize',fontSize,'VerticalAlignment','bottom');
        otherwise
            text(xLim(1),yLim(1)*20,caption,'FontSize',fontSize,'VerticalAlignment','bottom');
    end
end
%         xtickformat('%.1f');
% xticklabels('manual');
xticklabels({'0.1','1','10','100'});

% Add second x-axis for noise contrast noiseSD.
% ax1=gca;
% ax2=axes('Position',ax1.Position,...
%     'XAxisLocation','top',...
%     'YAxisLocation','right',...
%     'Color','none',...
%     'XColor','k','YColor','k');
% ax2.XScale=ax1.XScale;
% ax2.YScale=ax1.YScale;
% ax2.XLim=sqrt(ax1.XLim)*oo(end).noiseSD/sqrt(oo(end).N);
% ax2.YLim=ax1.YLim;
% ax2.FontSize=ax1.FontSize;

% Save plot to disk
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')
% print(gcf,graphFile,'-depsc'); % equivalent to saveas above
end % function Plot