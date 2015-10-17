function tabdata = parseExpData(newpath, obs_name, from_date, to_date)
%from_date/to_date of form 'dd-mmm-yyyy hh:mm:ss'.
%Put from_date = -Inf and/or to_date = Inf when wanting unrestricted
%lower/upper bound.

% newpath = '/Users/xiuyunwu/NoiseDiscrimination/data';
% obs_name = 'xiuyun';
% from_date = -Inf;
% to_date = Inf;

cd(newpath);
files = dir('*mat');
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
pdata=cell(length(parsefiles),13);
col_names={'observer','trials','letter_size','noise_contrast','noise_decay_radius','eccentricity','p_accuracy','threshold_log_contrast','threshold_contrast_SD','contrast','log_E_by_N','efficiency','file_date_time'};
for i=1:length(parsefiles)
    load(char(parsefiles(i)),'o');
    
    if o.trials>=80
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
        pdata{i,13}=char(parsedates(i)); %file date for reference
    end;
    clear o;
end
pdata( all(cellfun(@isempty,pdata),2), : ) = []; %removes empty cell rows
tabdata = cell2table(pdata, 'VariableNames', col_names); %converts to table
%Use this command to save file - writetable(tabdata,'test1.txt','Delimiter',',')

% writetable(tabdata,'xiuyunW2W3.csv','Delimiter',',')
save('xiuyunW2-3.mat','tabdata');
end