MATs=dir('data/measure*ning.2017.3.10*.mat');
data=[];
for ii = 1:length(MATs)
    d = load(MATs(ii).name);
    
     data = [data; d.o.noiseSD d.o.xHeightDeg d.o.eccentricityDeg d.o.contrast];
% data = [data; d.o];        
% Chen_March10{ii} = d.o;
    
end
data0 = data(data(:,1) == 0,:);
data1 = data(data(:,1) ~= 0,:);
% data00 = data0(data0(:,1)==0,:);
% data01 = data0(data0(:,1)~=0,:);
% data10 = data1(data1(:,1)==0,:);
% data11 = data1(data1(:,1)~=0,:);
% save Chen_March10 Chen_March10
close all;figure;
% loglog(data1(:,3),-data1(:,4),'s');hold on
loglog(data0(:,3)+0.15,-data0(:,4),'*');
xlim([1e-2 1e2]);ylim([1e-4 1e0])
% figure;
% loglog(data11(:,2),-data11(:,4),'s');hold on
% loglog(data10(:,2),-data10(:,4),'*');
% data00 = data0([4 1 2 3],:);
% Neq = data0(:,3).^2 /(data1(:,3).^2 - data0(:,3).^2);
% figure;
% loglog(data1(:,2)+0.15,Neq,'s')
%%
D = Data;
for ii =1:length(D)
    if D{ii}.trials == 40
        fprintf('yes,\t')
    else
        fprintf('no,\t')
    end
end
%%
clear all;
MATs=dir('data/measure*Ning_dark.2017.3.3*.mat');
data=[];
for ii = 1:length(MATs)
    d = load(MATs(ii).name);
    if d.o.trials >= 40 && strcmp(d.o.noiseType,'gaussian') && d.o.targetHeightDeg <3
        data = [data; d.o.noiseSD d.o.eccentricityDeg d.o.contrast];
        Ning_March3rd_dark{ii}=d.o;
%         Ning_March3rd_dark{ii}.observer
    end
end
data0 = data(data(:,1) == 0,:);
data1 = data(data(:,1) ~= 0,:);
%save Ning_March3rd_dark Ning_March3rd_dark
figure;
loglog(data1(:,2),-data1(:,3),'s');hold on
loglog(data0(:,2),-data0(:,3),'*');

