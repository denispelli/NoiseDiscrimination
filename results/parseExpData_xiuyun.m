% function tabdata = parseExpData(newpath, obs_name, from_date, to_date)
%from_date/to_date of form 'dd-mmm-yyyy hh:mm:ss'.
%Put from_date = -Inf and/or to_date = Inf when wanting unrestricted
%lower/upper bound.

newpath = '/Users/xiuyunwu/NoiseDiscrimination/data';
obs_name='xiuyun';
from_date=-inf;
to_date=inf;

smallestTrialNum = 80;

cd(newpath);
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
if sum(from_date==-Inf)==1
    from_dt=-Inf;
else
    from_dt = datenum(from_date,fmt);
end
if sum(to_date==Inf)==1
    to_dt=Inf;
else
    to_dt = datenum(to_date, fmt);
end

parsefiles=cell(1,length(filenames));
parsedates=cell(1,length(filenames));
for k=1:length(filenames)
    [pathstr,name,ext]=fileparts(char(filenames(k)));
    if not(isempty(strfind(name,char(obs_name))))
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
col_names={'observer','trials','letter_size','noise_contrast','noise_decay_radius','eccentricity','p_accuracy','threshold_log_contrast','threshold_contrast_SD','contrast','log_E_by_N','efficiency','file_date_time','energy_at_unit_contrast','noise_power_spectral_density', 'threshold_energy'};

j = 1; % to skip the re-run runs(unfinished runs due to mis-representation of letters)
for i=1:length(parsefiles)
    load(char(parsefiles(i)),'o');
    if o.trials>=smallestTrialNum
        pdata{j,1}=o.observer; %observer name
        pdata{j,2}=o.trials; %trials per run
        pdata{j,3}=o.targetHeightDeg; %letter size
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
        if o.noiseSD==0
            pdata{j,14}=o.E1; % energy at unit contrast
            pdata{j,15}=o.N; % noise power spectral density
        end;
        
        % for old data with noise contrast~=0 we just compute E1 and N from o
        if o.noiseSD~=0
        N = (o.noiseSD^2)*o.noiseCheckDeg^2;
        E10=o.EOverN*N;
        E1=E10/o.contrast^2;
        
        pdata{j,14}=E1; % energy at unit contrast
        pdata{j,15}=N; % noise power spectral density 
        end;
       
        E = E1*exp(o.questMean)^2;
        pdata{j,16}=E; %threshold energy
        
        j = j+1;
    end;
    clear o;
end
pdata( all(cellfun(@isempty,pdata),2), : ) = []; %removes empty cell rows
tabdata = cell2table(pdata, 'VariableNames', col_names); %converts to table
%Use this command to save file - writetable(tabdata,'test1.txt','Delimiter',',')

%Also save a .mat file for further processing
save('xiuyunW2-3.mat','tabdata');
% end