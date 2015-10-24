% to load table.mat file directly saved from parseExpData.m
% newpath is the file path, such as '/Users/xiuyunwu/NoiseDiscrimination/data';
% obs_name is the same as in parseExpData.m, such as 'xiuyun';
% doNeq when set to 0, Neq is not computed(such as when there are no noise_contrst=0 runs);
%       when set to 1, Neq is computed
% doEfficiency is the same as doNeq;
% the efficiency here is the 'high noise efficiency', which is E_ideal/(E-E0)
% that means when noist contrast=0, there is no high-noise efficiency computed

function tab = getStats(newpath, obs_name, doNeq, doEfficiency)

%settings
filename = [obs_name,'_runs.mat'];
% This should be the same as the matfilename in parseExpData.m
csvfilename=[obs_name,'_conditions.csv'];
matfilename=[obs_name,'_conditions.mat'];

cd(newpath);
load(filename);
% This should be the table directly saved after running parseExpData.m

col_name = {'letter_size','noise_contrast','noise_decay_radius','eccentricity','mean_threshold','sd_threshold','squared_noise_contrast','mean_squared_threshod','sd_squared_threshold','Energy','Energy_at_unit_contrast','Noise_power_spectral_density'};

% convert conditions to positive integers so that can be used in accumarray()
% subs is the converted condition for each run
% each number 'n' in subs means the condition is the n_th row in con
% the columns in con are lettersize, noisecontrast, noisedecayradius and eccentricity
con = unique(tabdata{:, 3:6},'rows');
for t = 1:size(con,1)
    cont = repmat(con(t,:),[size(tabdata,1) 1]);
    arr = find(all(tabdata{:, 3:6}==cont,2)); % the index of the two runs under current condition
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
ME1 = accumarray(subs, tabdata{:, 14}, [], @mean); % mean of energy at unit contrast, E1
MN = accumarray(subs, tabdata{:, 15}, [], @mean); % mean of noise power spectral density, N

out = [con,M1,SD1,con(:,2).^2,M2,SD2,ME,ME1,MN]; %output data for the table 'tab'

if doNeq==1
    % computing Neq
    runNeq = zeros(size(tabdata,1),1); % Neq for each run(when noise contrast = 0, Neq = 0)
    
    for t = 1:size(con,1)
        if con(t, 2)~=0
            cont = repmat(con(t,:),[size(tabdata,1) 1]);
            arr = find(all(tabdata{:, 3:6}==cont,2)); % the index of the two runs
            
            for j = 1:size(con,1)
                if cont(t,1)==con(j,1) && cont(t,4)==con(j,4)
                    arr0=j; %the index of E0, whose conditon has the same letter size and eccentricity
                    break
                end;
            end;
            
            cE0 = repmat(ME(arr0),[2 1]);
            runNeq(arr, 1)=(cE0./(tabdata{arr,16}-cE0)).*tabdata{arr,15}; %Neq for the two runs
            
        end;
    end;
    MNeq = accumarray(subs, runNeq, [], @mean);
    SDNeq = accumarray(subs, runNeq, [], @std);
    
    out = [out,MNeq,SDNeq];
    col_name = {col_name{:}, 'Neq','sd_Neq'};
end;

if doEfficiency==1
    % computing high noise Efficiency = E_ideal/(E-E0)
    ideal = load('ideal_runs.mat');
    runEffi = zeros(size(tabdata,1),1); % Efficiency for each run(when noise contrast = 0, Efficiency = 0)
    
    coni = unique(ideal.tabdata{:, 3:6},'rows'); % sort the ideal data
for t = 1:size(coni,1)
    conti = repmat(coni(t,:),[size(ideal.tabdata,1) 1]);
    arri = find(all(ideal.tabdata{:, 3:6}==conti,2)); % the index of the two runs under current condition
    subsi(arri,1) = t;
end
    
    meffi = accumarray(subsi, ideal.tabdata{:, 16}, [], @mean); % mean of ideal energy
    for t = 1:size(con,1)
        if con(t, 2)~=0
            cont = repmat(con(t,:),[size(tabdata,1) 1]);
            arr = find(all(tabdata{:, 3:6}==cont,2)); % the index of the two runs
            
            for j = 1:size(con,1)
                if cont(t,1)==con(j,1) && cont(t,4)==con(j,4)
                    arr0=j; %the index of E0, whose conditon has the same letter size and eccentricity
                    break
                end;
            end;
            cE0 = repmat(ME(arr0),[2 1]);
            
            cont2 = repmat(con(t,:),[size(coni,1) 1]);
            arri = find(all(coni==cont2, 2)); % the index of ideal E
            cEf = repmat(meffi(arri),[2 1]);
            
            runEffi(arr, 1)=cEf./(tabdata{arr,16}-cE0); %high noise efficiency for the two runs
        end;
        
    end;
    
        MEffi = accumarray(subs, runEffi, [], @mean);
        SDEffi = accumarray(subs, runEffi, [], @std);
    
        out = [out,MEffi,SDEffi];
        col_name = {col_name{:}, 'mean_Efficiency','sd_Efficiency'};
    
end;

out = mat2cell(out,ones(1,size(out,1)),ones(1,size(out,2)));
tab = cell2table(out, 'VariableNames', col_name); %converts to table

writetable(tab, csvfilename ,'Delimiter',',')
save(matfilename,'tab');
end