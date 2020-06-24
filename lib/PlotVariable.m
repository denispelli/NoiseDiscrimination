function figureHandle=PlotVariable(experiment,a,Variable,VariableAlpha)
% function figureHandle=PlotVariable(experiment,a,Variable,VariableAlpha);
%
% Plot "Variable" versus targetCyclesPerDeg.
% May 21, 2020, denis.pelli@nyu.edu
global colors ignoreLuminanceBelow230

ignoreLuminanceBelow230=true;

% eccXsfull=arrayfun(@(x) x.eccentricityXYDeg(1),a);
eccXs=unique([a.eccentricityDeg]);
conditionNames=unique({a.conditionName});
observers=unique({a.observer});
luminances=unique([a.desiredLuminanceAtEye]);
observers=unique({a.observer});
targetCyclesPerDegs=unique([a.targetCyclesPerDeg]);
durations=unique([a.targetDurationSecs]);
cyan        = [0.2 0.8 0.8];
brown       = [0.2 0 0];
orange      = [1 0.5 0];
blue        = [0 0.5 1];
green       = [0 0.6 0.3];
red         = [1 0.2 0.2];
colors={[0.5 0.5 0.5] green red brown blue cyan orange };
assert(length(colors)>=length(targetCyclesPerDegs));
% observerStyle={':x' '-o' '--s' '-.d' '-.^' '-->' '--<'};
% observerStyle={'-o' '-s' '-d' '-^' '->' '-<' '-x' };
observerStyle={'-' '-' '-' '-' '-' '-' '-' };
durationMarker={'o' 's' 'd' '^' '>' '<' 'x' };
if length(observerStyle)<length(observers)
    error('Please define more observerStyle''s for %d observers.',length(observers));
end
observers=sort(observers);
iIdeal=ismember(observers,{'ideal'});
if true
    % Put ideal observer first.
    observers=[observers(iIdeal) observers(~iIdeal)];
else
    % Omit ideal.
    observers=observers(~iIdeal);
end

%% If some observer names differ solely in case, then collapse all names
% to lowercase.
isObserversLower=length(unique(lower(observers)))<length(observers);
if isObserversLower
    observers=unique(lower(observers));
end

% Extra Contrast graphs form a row.
% Extra other graphs form a column.
switch Variable
    case 'Contrast'
        width=500*length(conditionNames);
    otherwise
        width=500;
end
figureHandle=figure('Name',[experiment ' ' Variable],...
    'NumberTitle','off','pos',[10 10 width 900]);

for iCondition=1:length(conditionNames)
    conditionName=conditionNames{iCondition};
    switch Variable
        case 'Contrast'
            plotRows=1;
            plotColumns=length(conditionNames);
        otherwise
            plotRows=length(conditionNames);
            plotColumns=1;
    end
    if false || verLessThan('matlab','9.8')
        subplot(plotRows,plotColumns,iCondition);
    else
        if iCondition==1
            tile=tiledlayout(plotRows,plotColumns);
            tile.TileSpacing='compact'; % 'none'
            tile.Padding='compact';
        end
        nexttile(iCondition);
    end
    switch Variable
        case 'Contrast'
            switch conditionName
                case 'gaborCosCos'
                    PlotBanks(Variable);
            end
    end
    for iObserver=1:length(observers)
        if ismember(observers(iObserver),{'ideal'})
            %continue
        end
        for eccX=eccXs
            for luminance=luminances
                for iDuration=1:length(durations)
                    duration=durations(iDuration);
                    match=ismember({a.thresholdParameter},{'contrast'})...
                        & ismember({a.conditionName},conditionName)...
                        & ismember([a.desiredLuminanceAtEye],luminance)...
                        & ismember([a.targetDurationSecs],duration)...
                        & ismember([a.eccentricityDeg],eccX);
                    % idealMatch=match & ismember({a.observer},{'ideal'});
                    match = match & ismember(lower({a.observer}),lower(observers(iObserver)));
                    targetEnvelopeCycles=[a(match).targetEnvelopeCycles];
                    targetEnvelopeCycles=unique(round(targetEnvelopeCycles,1));
                    if length(targetEnvelopeCycles)>1
                        msg='Using mean of multiple values of targetEnvelopeCycles:';
                        msg=[msg sprintf(' %.1f',targetEnvelopeCycles)];
                        warning(msg);
                        targetEnvelopeCycles=mean([a(match).targetEnvelopeCycles]);
                        targetEnvelopeCycles=round(targetEnvelopeCycles,1);
                    end
                    targetDurationSecs=[a(match).targetDurationSecs];
                    targetDurationSecs=unique(round(targetDurationSecs,2));
                    if length(targetDurationSecs)>1
                        msg='Using mean of multiple values of targetDurationSecs:';
                        msg=[msg sprintf(' %.2f',targetDurationSecs)];
                        warning(msg);
                        targetDurationSecs=mean([a(match).targetDurationSecs]);
                        targetDurationSecs=round(targetDurationSecs,2);
                    end
                    if any(match)
                        for isZeroNoise=[false true]
                            x=[a(match).targetCyclesPerDeg];
                            switch Variable
                                case 'Contrast'
                                    if isZeroNoise
                                        y=-[a(match).c0];
                                    else
                                        y=-[a(match).c];
                                    end
                                case 'E/N'
                                    y=[a(match).EOverN];
                                case 'Efficiency'
                                    y=[a(match).efficiency];
                                case 'Neq'
                                    y=[a(match).Neq];
                            end
                            if length(x)~=length(y)
                                warning('%s:%s:length(x)~=length(y), %d~=%d.',Variable,conditionName,length(x),length(y));
                                continue
                            end
                            ok=isfinite(x) & isfinite(y);
                            if sum(ok)>0
                                color=colors{iObserver};
                                faceColor=color;
                                if isZeroNoise
                                    sd=0;
                                else
                                    sd=max([a(match).noiseSD]);
                                end
                                switch Variable
                                    case 'Contrast'
                                        if isZeroNoise
                                            faceColor=[1 1 1];
                                        else
                                            faceColor=colors{iObserver};
                                        end
                                    case {'E/N' 'Efficiency' 'Neq'}
                                        if isZeroNoise
                                            continue
                                        end
                                        if ismember(observers(iObserver),{'ideal'})
                                            faceColor=[1 1 1];
                                        else
                                            faceColor=colors{iObserver};
                                        end
                                end
                                switch eccX
                                    case eccXs(1)
                                        dash='';
                                    case eccXs(2)
                                        dash='-';
                                end
                                legendText=sprintf('%4.2f, %4.1f, %4.2f, %3.0f, %2.0f, %s',...
                                    sd,...
                                    targetEnvelopeCycles,...
                                    targetDurationSecs,...
                                    luminance,...
                                    eccX,...
                                    observers{iObserver});
                                marker=durationMarker{iDuration};
                                loglog(x(ok),y(ok),...
                                    [dash observerStyle{iObserver}],...
                                    'MarkerSize',8,...
                                    'Marker',marker,...
                                    'MarkerFaceColor',faceColor,...
                                    'MarkerEdgeColor',color,...
                                    'Color',color,...
                                    'LineWidth',1.5,...
                                    'DisplayName',legendText);
                                hold on
                            end
                        end
                    end
                end
            end
        end
    end
    ax=gca;
    ax.TickLength=[0.01 0.025]*2;
    ax.XLim=[0.5 32];
    lgd(iCondition)=legend('Location','northwest','Box','off');
    title(lgd(iCondition),'noiseSD, cycles, s, cd/m^2, eccentricityX, observer');
    lgd(iCondition).FontName='Monaco';
    lgd(iCondition).FontSize=8;
    switch Variable
        case 'Contrast'
            ax.YLim=[0.001 10];
        case 'E/N'
            % ax.YLim(2)=10*ax.YLim(2);
            ax.YLim=[1e1 1e4*10];
        case 'Efficiency'
            % ax.YLim(2)=10*ax.YLim(2);
            ax.YLim=[1e-3 1e-1*10];
        case 'Neq'
            ax.YLim(2)=10*ax.YLim(2);
        otherwise
            disp(['ERROR: ' Variable\n']');
    end
    if true
        % Scale log unit of contrast to be 3 cm vertically.
        % Scale log unit of energy to be 1.5 cm vertically.
        ax=gca;
        % NOTE: Running MATLAB R2019a on a MacBook Pro with Retina screen,
        % I find that the "centimeter" unit is about half that. I suppose
        % that MATLAB is confused by Retina resolution, and is estimating
        % resolution inconsistently.
        ax.Units='centimeters';
        drawnow; % Needed for valid Position reading.
        switch Variable
            case 'Contrast'
                ax.Position(4)=12*diff(log10(ax.YLim))/length(conditionNames);
            case {'E/N' 'Efficiency' 'Neq'}
                % These measures are all proportional to squared contrast,
                % so we set half as many cm per log unit as for contrast.
                ax.Position(4)=6*diff(log10(ax.YLim))/length(conditionNames);
            otherwise
                fprintf('Unknown Variable ''%s''.\n',Variable);
        end
        drawnow;
        fprintf('%s ax.Position=[%.1f %.1f %.1f %.1f], log units %.1f\n',...
            Variable,ax.Position,diff(log10(ax.YLim)));
    end
    hold off
    
    set(gca,'FontSize',14); % Axis numbers
    
    % title, xlabel, ylabel
    title([upper(conditionName(1)) conditionName(2:end)],'fontsize',14)
    xlabel('Spatial frequency (c/deg)','fontsize',18);
    switch Variable
        case {'Contrast' 'E/N'}
            ylabel([Variable ' threshold'],'fontsize',18);
        case 'Efficiency'
            ylabel(Variable,'fontsize',18);
        case 'Neq'
            ylabel(['Equivalent noise (' a(1).NUnits ')'],'fontsize',18);
    end
    switch Variable
        case 'Contrast'
        otherwise
            % subplot(length(conditionNames),1,iCondition);
            if iCondition<length(conditionNames)
                h=gca;
                % h.XAxis.Visible='off';
                set(gca,'Xticklabel',[])
                xlabel('');
            end
    end
end


% Save plot to disk
graphFile=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data',[experiment '-' VariableAlpha 'VsSize.eps']);
if verLessThan('matlab','9.8')
    saveas(gcf,graphFile,'epsc');
else
    exportgraphics(gcf,graphFile);
end
end

function PlotBanks(Variable)
global colors ignoreLuminanceBelow230
switch Variable
    case 'Contrast'
        % Observers MSB and PJB from Banks, Bennet, and Geisler 1987
        msb340F=[4.9 7.0 9.9 13.9 19.7 27.7 40.4];
        msb340C=[0.066 0.094 0.128 0.145 0.212 0.402 0.573];
        msb34F=[4.9 6.8 9.9 13.8 19.9 28.0 39.9];
        msb34C=[0.087 0.126 0.191 0.223 0.339 0.510 0.696 ];
        msb3p4F=[5.017 7.101 10.076 14.42 20.27];
        msb3p4C=[0.044 0.094 0.120 0.241 0.377];
        pjb340F=[ 4.816 6.769 9.717 13.753 19.718 27.71 39.614];
        pjb340C=[0.011 0.012 0.031 0.033 0.069 0.186 0.492];
        pjb34F=[4.8 6.759 9.686 13.817 19.772 26.95];
        pjb34C=[0.016 0.030 0.080 0.116 0.197 0.405];
        pjb3p4F=[4.966 6.833 9.831 13.982 19.59];
        pjb3p4C=[0.073 0.105 0.147 0.227 0.404];
        % Use dark color for low luminance and light color for high
        % luminance.
        color34=mean([colors{6};0 0 0]);
        color340=mean([colors{6};1 1 1]);
        sd=0;
        targetEnvelopeCycles=7.5*acos(exp(-1))/(pi/2);
        targetDurationSecs=0.1;
        luminance=34;
        eccX=0;
        if true
            luminance=340;
            legendText=sprintf('%4.2f, %4.1f, %4.2f, %3.0f, %2.0f, %s',...
                sd,...
                targetEnvelopeCycles,...
                targetDurationSecs,...
                luminance,...
                eccX,...
                'MSB from Banks et al. 1987');
            loglog(msb340F,msb340C,'-ko','LineWidth',3,...
                'MarkerSize',8,...
                'MarkerFaceColor',[1 1 1],...
                'MarkerEdgeColor',color340,...
                'Color',color340,...
                'DisplayName',legendText);
            hold on
            if ~ignoreLuminanceBelow230
                luminance=34;
                legendText=sprintf('%4.2f, %4.1f, %4.2f, %3.0f, %2.0f, %s',...
                    sd,...
                    targetEnvelopeCycles,...
                    targetDurationSecs,...
                    luminance,...
                    eccX,...
                    'MSB from Banks et al. 1987');
                loglog(msb34F,msb34C,'-ko','LineWidth',3,...
                    'MarkerSize',8,...
                    'MarkerFaceColor',[1 1 1],...
                    'MarkerEdgeColor',color34,...
                    'Color',color34,...
                    'DisplayName',legendText);
                hold on
            end
        end
        color34=mean([colors{7};0 0 0]);
        color340=mean([colors{7};1 1 1]);
        luminance=340;
        legendText=sprintf('%4.2f, %4.1f, %4.2f, %3.0f, %2.0f, %s',...
            sd,...
            targetEnvelopeCycles,...
            targetDurationSecs,...
            luminance,...
            eccX,...
            'PJB from Banks et al. 1987');
        loglog(pjb340F,pjb340C,'-ko','LineWidth',3,...
            'MarkerSize',8,...
            'MarkerFaceColor',[1 1 1],...
            'MarkerEdgeColor',color340,...
            'Color',color340,...
            'DisplayName',legendText);
        hold on
        if ~ignoreLuminanceBelow230
            luminance=34;
            legendText=sprintf('%4.2f, %4.1f, %4.2f, %3.0f, %2.0f, %s',...
                sd,...
                targetEnvelopeCycles,...
                targetDurationSecs,...
                luminance,...
                eccX,...
                'PJB from Banks et al. 1987');
            loglog(pjb34F,pjb34C,'-ko','LineWidth',3,...
                'MarkerSize',8,...
                'MarkerFaceColor',[1 1 1],...
                'MarkerEdgeColor',color34,...
                'Color',color34,...
                'DisplayName',legendText);
            hold on
        end
end % switch Variable
end % function PlotBanks