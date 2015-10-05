clear all
cd('/Users/shivamverma/Desktop/Pelli_Lab/NoiseDiscrimination/');
files = dir('*mat');
filenames = {files.name};
parsefiles=cell(1,length(filenames));
for k=1:length(filenames)
    [pathstr,name,ext]=fileparts(char(filenames(k)));
    if not(isempty(strfind(name,'shivam')))
        %if file_name >= from_date && <= to_date
        parsefiles{k}=char(filenames(k));
    end
end
table=cell(length(parsefiles),13);
col_names={'observer','trials','letter size','noise contrast','noise decay radius','eccentricity','% accuracy','threshold log contrast','threshold contrast SD','contrast','log E/N','efficiency','file name'};
for i=1:length(parsefiles)
    load(char(parsefiles(i)),'o');
    table{i,1}=o.observer; %observer name
    table{i,2}=o.trials; %trials per run
    table{i,3}=o.targetHeightDeg; %letter size
    table{i,4}=o.noiseSD; %noise contrast
    table{i,5}=o.noiseEnvelopeSpaceConstantDeg; %noise decay radius
    table{i,6}=o.eccentricityDeg; %eccentricity
    %table(i,)=o.; %seconds per trials
    table{i,7}=o.p; %percentage accuracy
    table{i,8}=o.questMean; %threshold log contrast
    table{i,9}=o.questSd; %threshold log contrast SD
    table{i,10}=o.contrast; %contrast
    table{i,11}=log(o.EOverN); %log E/N
    table{i,12}=o.efficiency; %efficiency
    table{i,13}=char(parsefiles(i));
    clear o;
end