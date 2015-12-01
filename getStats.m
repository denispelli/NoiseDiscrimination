% to load table.mat file directly saved from parseExpData.m
% newpath is the file path, such as '/Users/xiuyunwu/NoiseDiscrimination/data';
% obs_name is the same as in parseExpData.m, such as 'xiuyun';
% doNeq when set to 0, Neq is not computed(such as when there are no noise_contrst=0 runs);
%       when set to 1, Neq is computed
%
% doEfficiency is the same as doNeq;
% the efficiency here is the 'high noise efficiency', which is E_ideal/(E-E0)
% that means when noist contrast=0, there is no high-noise efficiency computed
%
% To be able to compute E0(needed for Neq and Efficiency), you should have noise contrast=0,
% whose conditon
% has the same target size,eccentricity,TargetCross,noiseCheckDeg and targetKind
% with other noise contrast~=0 conditions;
%
% To be able to compute Efficiency, besides E0, you should also have ideal
% data with the same
% target size, noisecontrast(~=0), noisedecayradius, eccentricity,
% noiseRadiusDeg, noiseSpectrum, noiseCheckDeg and targetKind


function tab = getStats(newpath, obsName, doNeq, doEfficiency, expDate)
% newpath = '/Users/xiuyunwu/NoiseDiscrimination/data';
% obs_name = 'shivam';
% doNeq=1;
% doEfficiency=1;

%settings
[yyyy,mm,dd]=datevec(expDate);
dt=[num2str(yyyy),num2str(mm),num2str(dd)];
filename = [obsName,'_runs_',dt,'.mat'];
% This should be the same as the matfilename in parseExpData.m
csvfilename=[obsName,'_conditions_',dt,'.csv'];
matfilename=[obsName,'_conditions_',dt,'.mat'];

cd(newpath);
load(filename);
% This should be the table directly saved after running parseExpData.m

col_name = {'targetSize','noiseContrast','noiseDecayRadius','eccentricity','hardOrSoft','targetCross','noiseSpectrum','noiseCheckDeg','targetKind','meanThreshold','sdThreshold','squaredNoiseContrast','meanSquaredThreshold','sdSquaredThreshold','meanEnergy','sdEnergy', 'energyAtUnitContrast','noisePowerSpectralDensity'};

% convert conditions to positive integers so that can be used in accumarray()
% subs is the converted condition for each run
% each number 'n' in subs means the condition is the n_th row in con
% the columns in con are targetsize, noisecontrast, noisedecayradius,
% eccentricity, noiseRadiusDeg, TargetCross, noiseCheckDeg and targetKind

cons = [tabdata{:, 3:6} tabdata{:, 17:21}];
con = unique(cons,'rows');
for t = 1:size(con,1)
    cont = repmat(con(t,:),[size(tabdata,1) 1]);
    arr = find(all(tabdata{:, 3:6}==cont(:,1:4),2));
    if length(arr)>2 % soft/hard and cross 0/1 and pink/white and noiseCheckDeg and letter/gabor conditions together
        k=1;
        while k<=length(arr)
            if tabdata{arr(k), 17}~=con(t,5)||tabdata{arr(k), 18}~=con(t,6) || tabdata{arr(k), 19}~=con(t,7) || tabdata{arr(k), 20}~=con(t,8) || tabdata{arr(k), 21}~=con(t,9)
                arr(k)=[];
                k=k-1;
            end;
            k=k+1;
        end;
    end; % the index of the runs under current condition
    subs(arr,1) = t;
end

LinTh=exp(tabdata{:, 8}); % linear threshold contrast
squaTh=exp(tabdata{:, 8}).^2; % squared linear threshold contrast

% mean and sd for threshold and squared threshold
M1 = accumarray(subs, LinTh, [], @mean); % mean for linear threshold contrast
M2 = accumarray(subs, squaTh, [], @mean); % mean for squared linear threshold contrast
SD1 = accumarray(subs, LinTh, [], @std); % std for linear threshold contrast
SD2 = accumarray(subs, squaTh, [], @std); % std for squared linear threshold contrast
ME = accumarray(subs, tabdata{:, 16}, [], @mean); % mean of energy, E & E0
SDE = accumarray(subs, tabdata{:, 16}, [], @std); % std of energy, E & E0
ME1 = accumarray(subs, tabdata{:, 14}, [], @mean); % mean of energy at unit contrast, E1
MN = accumarray(subs, tabdata{:, 15}, [], @mean); % mean of noise power spectral density, N

out = [con,M1,SD1,con(:,2).^2,M2,SD2,ME,SDE,ME1,MN]; %output data for the table 'tab'

if doNeq==1
    % computing Neq
    runNeq = zeros(size(tabdata,1),1); % Neq for each run(when noise contrast = 0, Neq = 0)
    
    for t = 1:size(con,1)
        if con(t, 2)~=0
            cont = repmat(con(t,:),[size(tabdata,1) 1]);
            arr = find(all(tabdata{:, 3:6}==cont(:,1:4),2));
            if length(arr)>2 % soft/hard and cross 0/1 and pink/white and noiseCheckDeg and letter/gabor conditions together
                k=1;
                while k<=length(arr)
                    if tabdata{arr(k), 17}~=con(t,5)||tabdata{arr(k), 18}~=con(t,6)|| tabdata{arr(k), 19}~=con(t,7) || tabdata{arr(k), 20}~=con(t,8) || tabdata{arr(k), 21}~=con(t,9)
                        arr(k)=[];
                        k=k-1;
                    end;
                    k=k+1;
                end;
            end; % the index of the god-knows-how-many runs under current condition
            
            
            for j = 1:size(con,1)
                if con(j, 2)==0 && cont(t,1)==con(j,1) && cont(t,4)==con(j,4) && cont(t,6)==con(j,6) && cont(t,8)==con(j,8) && cont(t,9)==con(j,9)
                    arr0=j; %the index of E0, whose conditon has the same target size,eccentricity,TargetCross,noiseCheckDeg and targetKind
                    break
                end;
            end;
            
            cE0 = repmat(ME(arr0),[length(arr) 1]);
            if isempty(arr0)
                runNeq(arr, 1)=-1; % sth wrong with data
            else
                runNeq(arr, 1)=(cE0./(tabdata{arr,16}-cE0)).*tabdata{arr,15}; %Neq for the runs
            end;
            
        end;
    end;
    MNeq = accumarray(subs, runNeq, [], @mean);
    SDNeq = accumarray(subs, runNeq, [], @std);
    
    out = [out,MNeq,SDNeq];
    col_name = {col_name{:}, 'meanNeq','sdNeq'};
end;

if doEfficiency==1
    % computing high noise Efficiency = E_ideal/(E-E0)
    idealFile=['ideal_conditions_',dt,'.mat'];
    ideal = load(idealFile);
    runEffi = zeros(size(tabdata,1),1); % Neq for each run(when noise contrast = 0, Neq = 0)

    for t = 1:size(con,1)
        if con(t, 2)~=0
            cont = repmat(con(t,:),[size(tabdata,1) 1]);
            arr = find(all(tabdata{:, 3:6}==cont(:,1:4),2));
            if length(arr)>2 % soft/hard and cross 0/1 and noiseCheckDeg and targetKind conditions together
                k=1;
                while k<=length(arr)
                    if tabdata{arr(k), 17}~=con(t,5)||tabdata{arr(k), 18}~=con(t,6)|| tabdata{arr(k), 19}~=con(t,7) || tabdata{arr(k), 20}~=con(t,8) || tabdata{arr(k), 21}~=con(t,9)
                        arr(k)=[];
                        k=k-1;
                    end;
                    k=k+1;
                end;
            end; % the index of the god-knows-how-many runs under current condition
            
            for j = 1:size(con,1)
                if con(j,2)==0 && cont(t,1)==con(j,1) && cont(t,4)==con(j,4) && cont(t,6)==con(j,6) && cont(t,8)==con(j,8) && cont(t,9)==con(j,9)
                    arr0=j; %the index of E0, whose conditon has the same target size,eccentricity,TargetCross,noiseCheckDeg and targetKind
                    break
                end;
            end;
            cE0 = repmat(ME(arr0),[length(arr) 1]);
            
            coni = table2cell(ideal.tab(:, 1:9));
            for tt = 1:size(ideal.tab,1)
                if strcmp(coni{tt, 5}, 'hard')
                    coni{tt, 5}=1;
                elseif strcmp(coni{tt, 5}, 'soft')
                    coni{tt, 5}=0;
                end;
                
                if strcmp(coni{tt, 7}, 'white')
                    coni{tt, 7}=0;
                elseif strcmp(coni{tt, 7}, 'pink')
                    coni{tt, 7}=1;
                end;
                
                if strcmp(coni{tt, 9}, 'letter')
                    coni{tt, 9}=0;
                elseif strcmp(coni{tt, 9}, 'gabor')
                    coni{tt, 9}=1;
                end;
                
            end;
            coni = cell2mat(coni);
            con2 = repmat(con(t,:),[size(ideal.tab,1) 1]);
            arri = find(all(coni(:,1:2)==con2(:,1:2), 2));
            if length(arri)>1 % to discriminate radius, eccentricity, hard/soft, white or pink, noiseCheckDeg and targetKind
                k = 1;
                while k<=length(arri)
                    if coni(arri(k),4)~=con(t, 4) || coni(arri(k),7)~=con(t, 7) || coni(arri(k),8)~=con(t, 8) || coni(arri(k),9)~=con(t, 9)
                        arri(k)=[];
                        k = k-1;
                    elseif (coni(arri(k),5)==0 && (con(t, 5)<17 || con(t, 3)~=coni(arri(k),3))) || (coni(arri(k),5)==1 && (con(t, 5)>17 || con(t, 5)~=coni(arri(k),3)))% radius and hard/soft
                        arri(k)=[];
                        k = k-1;
                    end;
                    k = k+1;
                end;
            end;
            % the index of ideal E
            % has the same targetsize, noisecontrast, noisedecayradius,
            % eccentricity, noiseRadiusDeg, noiseSpectrum, noiseCheckDeg
            % and targetKind
            
            temp = table2cell(ideal.tab(arri, 15));
            temp = cell2mat(temp);
            cEf = repmat(temp,[length(arr) 1]);
            
            if isempty(arri)
                runEffi(arr, 1)=-1; % sth wrong with data
            else
                runEffi(arr, 1)=cEf./(tabdata{arr,16}-cE0); %high noise efficiency for the runs
            end;
        end;
        
    end;
    
    MEffi = accumarray(subs, runEffi, [], @mean);
    SDEffi = accumarray(subs, runEffi, [], @std);
    
    out = [out,MEffi,SDEffi];
    col_name = {col_name{:}, 'meanEfficiency','sdEfficiency'};
    
end;

out = mat2cell(out,ones(1,size(out,1)),ones(1,size(out,2)));

for t = 1:size(out,1)
    if out{t, 5}>17 % soft conditions
        out{t,5} = 'soft';
    else
        out{t,3}=out{t,5};
        out{t,5}='hard';
    end;
    % convert noise decay radius and noisedecayradius to noise decay radius in
    % display and soft/hard, so it would be easier when plotting
    
    if out{t, 7}==0
        out{t, 7} = 'white';
    elseif out{t, 7}==1
        out{t, 7} = 'pink';
    end;
    % convert noiseSpectrum back to strings
    
    if out{t, 9}==0
        out{t, 9} = 'letter';
    elseif out{t, 9}==1
        out{t, 9} = 'gabor';
    end;
    % convert targetKind back to strings
end;
tab = cell2table(out, 'VariableNames', col_name); %converts to table

writetable(tab, csvfilename ,'Delimiter',',')
save(matfilename,'tab');
end