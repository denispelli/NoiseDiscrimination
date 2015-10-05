%clear all
cd('/Users/shivamverma/Desktop/Pelli_Lab/NoiseDiscrimination/');
files = dir('*mat');
filenames = {files.name};
filedates = {files.datenum};
fmt = 'dd-mmm-yyyy HH:MM:SS';
from_dt = datenum(from_date,fmt);
to_dt = datenum(to_date, fmt);
parsefiles=cell(1,length(filenames));
pf_dates=cell(1,length(filedates));
for k=1:length(filenames)
    [pathstr,name,ext]=fileparts(char(filenames(k)));
    if not(isempty(strfind(name,char(obs_name))))
        curr_date = filedates{k};
        if curr_date>=from_dt && curr_date<=to_dt
            parsefiles{k}=char(filenames(k));
        end
    end
end
parsefiles=parsefiles(~cellfun('isempty',parsefiles));
%parsefiles( all(cellfun(@isempty,parsefiles),2), : ) = [];
table=cell(length(parsefiles),13);
col_names={'observer','trials','letter_size','noise_contrast','noise_decay_radius','eccentricity','p_accuracy','threshold_log_contrast','threshold_contrast_SD','contrast','log_E_by_N','efficiency','file_name'};
for i=1:length(parsefiles)
    load(char(parsefiles(i)),'o');
    pdata{i,1}=o.observer; %observer name
    pdata{i,2}=o.trials; %trials per run
    pdata{i,3}=o.targetHeightDeg; %letter size
    pdata{i,4}=o.noiseSD; %noise contrast
    pdata{i,5}=o.noiseEnvelopeSpaceConstantDeg; %noise decay radius
    pdata{i,6}=o.eccentricityDeg; %eccentricity
    %pdata(i,)=o.; %seconds per trials
    pdata{i,7}=o.p; %percentage accuracy
    pdata{i,8}=o.questMean; %threshold log contrast
    pdata{i,9}=o.questSd; %threshold log contrast SD
    pdata{i,10}=o.contrast; %contrast
    pdata{i,11}=log(o.EOverN); %log E/N
    pdata{i,12}=o.efficiency; %efficiency
    pdata{i,13}=char(parsefiles(i)); %date of experiments
    pdata{i,14}=char(parsefiles(i)); %file name for reference
    clear o;
end
pdata( all(cellfun(@isempty,pdata),2), : ) = []; %removes empty cell rows
tabdata = cell2table(pdata, 'VariableNames', col_names); %converts to table
