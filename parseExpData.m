%fromDate/toDate of form 'dd-mmm-yyyy hh:mm:ss'.
%Put fromDate = -Inf and/or toDate = Inf when wanting unrestricted
%lower/upper bound.
% 
function tabdata = parseExpData(newPath, obsName, fromDate, toDate)

% settings
% I didn't include them into the function parameters since these may not
% change everytime
smallestTrialNum = 80; %used for skipping unfinished runs
[yyyy,mm,dd]=datevec(date);
dt=[num2str(yyyy),num2str(mm),num2str(dd)];
csvfilename=[obsName,'_runs_',dt,'.csv'];
matfilename=[obsName,'_runs_',dt,'.mat'];
%settings end

cd(newPath);
files = dir('study*.mat');
filenames = {files.name};
filedates=cell(size(filenames));
filedates2=cell(size(filenames));
fmt = 'dd-mmm-yyyy HH:MM:SS';
for i=1:length(filenames)
    temp=strsplit(filenames{i},'.');
    filedates{i}=datestr(cellfun(@str2num,temp(2:7)),0);
    filedates2{i}=datenum(filedates{i},fmt);
end
if sum(fromDate==-Inf)==1
    from_dt=-Inf;
else
    from_dt = datenum(fromDate,fmt);
end
if sum(toDate==Inf)==1
    to_dt=Inf;
else
    to_dt = datenum(toDate, fmt);
end

parsefiles=cell(1,length(filenames));
parsedates=cell(1,length(filenames));
for k=1:length(filenames)
    [pathstr,name,ext]=fileparts(char(filenames(k)));
    if not(isempty(strfind(name,char(obsName))))
        curr_date = filedates2{k};
        if curr_date>=from_dt && curr_date<=to_dt
            parsefiles{k}=char(filenames(k));
            parsedates{k}=char(filedates(k));
        end
    end
end
parsefiles=parsefiles(~cellfun('isempty',parsefiles)); %command to remove empty cells
parsedates=parsedates(~cellfun('isempty',parsedates));
% pdata=cell(length(parsefiles),13);
pdata = {};
col_names={'observer','trials','targetSize','noiseContrast','noiseDecayRadius','eccentricity','pAccuracy','thresholdLogContrast','thresholdContrastSD','contrast','logEbyN','efficiency','fileDateTime','energyAtUnitContrast','noisePowerSpectralDensity', 'thresholdEnergy','noiseRadiusDeg','targetCross','noiseSpectrum', 'noiseCheckDeg', 'targetKind'};
j = 1; % to skip the re-run runs(unfinished runs due to mis-representation of letters)
for i=1:length(parsefiles)
    load(char(parsefiles(i)),'o');
    if o.trials>=smallestTrialNum
        pdata{j,1}=o.observer; %observer name
        pdata{j,2}=o.trials; %trials per run
        %target size
        if o.targetHeightDeg<1 % we only got 0.5 and sqrt(2*6) as non-integer for now; but if we get more this should be modified
            pdata{j,3}=0.5;
        elseif o.targetHeightDeg>3 && o.targetHeightDeg<4
            pdata{j,3}=sqrt(2*6);
        else
            pdata{j,3}=round(o.targetHeightDeg);
        end;
        pdata{j,4}=o.noiseSD; %noise contrast
        pdata{j,5}=o.noiseEnvelopeSpaceConstantDeg; %noise decay radius
        pdata{j,6}=o.eccentricityDeg; %eccentricity
        %pdata(j,)=o.; %seconds per trials
        pdata{j,7}=o.p; %percentage accuracy
        pdata{j,8}=o.questMean; %threshold log contrast
        pdata{j,9}=o.questSd; %threshold log contrast SD
        pdata{j,10}=o.contrast; %contrast
        pdata{j,11}=log(o.EOverN); %log E/N
        pdata{j,12}=o.efficiency; %efficiency
        pdata{j,13}=char(parsedates(i)); %file date for reference
        
        % the following commands might be used for all conditions later
        % when E1 and N are saved into o using the modified NoiseDiscrimination.m
        %if o.noiseSD==0 %for now just the new noise contrast=0 runs saved E1 and N into struct o
        pdata{j,14}=o.E1; % energy at unit contrast
        pdata{j,15}=o.N; % noise power spectral density
        E1 = o.E1;
        N = o.N;
        %end;
        
        % for old data with noise contrast~=0 we just compute E1 and N from o
%         if o.noiseSD~=0
%             N = (o.noiseSD^2)*o.noiseCheckDeg^2;
%             E=o.EOverN*N;
%             E1=E/o.contrast^2;
%             
%             pdata{j,14}=E1; % energy at unit contrast
%             pdata{j,15}=N; % noise power spectral density
%         end;
        
        E = E1*o.contrast^2;
        pdata{j,16}=E; %threshold energy
        
        pdata{j,17}=o.noiseRadiusDeg; % hard/soft
        % when o.noiseRadiusDeg=1 & decay radius=inf, hard 1 radius;
        % when o.noiseRadiusDeg=inf & decay radius=1, soft 1 radius
        
        if isfield(o,'targetCross')
            pdata{j,18}=o.targetCross;
        else
            pdata{j,18}=0;
        end;
        
        if isfield(o,'noiseSpectrum')
            if strcmp(o.noiseSpectrum, 'white')
                pdata{j,19}=0;
            elseif strcmp(o.noiseSpectrum, 'pink')
                pdata{j,19}=1;
            end;
        else
            pdata{j,19}=0; % data in week 1&2, all white noise
        end;
        % 0 is white and 1 is pink, for computing in getStats
        % would be converted back after getStats
        
        pdata{j,20}=o.noiseCheckDeg;
        
        if isfield(o,'targetKind')
            if strcmp(o.targetKind, 'letter')
                pdata{j,21}=0;
            elseif strcmp(o.targetKind, 'gabor')
                pdata{j,21}=1;
            end;
        else
            pdata{j,21}=0; % data before, all letters
        end;
        
        j = j+1;

    end;
    clear o;
end
pdata( all(cellfun(@isempty,pdata),2), : ) = []; %removes empty cell rows
tabdata = cell2table(pdata, 'VariableNames', col_names); %converts to table
%Use this command to save file -
writetable(tabdata, csvfilename,'Delimiter',',')

%Also save a .mat file for further processing
save(matfilename,'tabdata');
end
