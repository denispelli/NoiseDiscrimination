% function tab = getStats(newpath, filename)

newpath = '/Users/xiuyunwu/NoiseDiscrimination/data';
filename = 'xiuyunW2-3.mat';

cd(newpath);
load(filename);        
% This is the  table directly saved after running Shivam's parseExpData.m

col_name = {'letter_size','noise_contrast','noise_decay_radius','eccentricity','mean_threshold','sd_threshold','squared_noise_contrast','mean_squared_threshod','sd_squared_threshold','Neq'};

% convert conditions to positive integers so that can be used in accumarray
% subs is the converted condition for each run
% each number 'n' in subs means the condition is the n_th row in con
% the columns in con are lettersize, noisecontrast, noisedecayradius and
% eccentricity 
con = unique(tabdata{:, 3:6},'rows');
conInteger = linspace(1,size(con, 1),size(con,1))';
for t = 1:size(con,1)
    cont = repmat(con(t,:),[size(tabdata,1) 1]);
    arr = find(all(tabdata{:, 3:6}==cont,2)); % the index of the two runs
    subs(arr,1) = t;
end

LinTh=exp(tabdata{:, 8}); % linear threshold contrast
squaTh=exp(tabdata{:, 8}).^2; % squared linear threshold contrast

% mean and sd for threshold and squared threshold
M1 = accumarray(subs, LinTh, [], @mean); % mean for linear threshold contrast
M2 = accumarray(subs, squaTh, [], @mean); % mean for linear threshold contrast
SD1 = accumarray(subs, LinTh, [], @std); % mean for squared linear threshold contrast
SD2 = accumarray(subs, squaTh, [], @std); % mean for squared linear threshold contrast

% computing Neq
% only use the mean of E0 in ME(when noise contrast is 0)
me = accumarray(subs, tabdata{:, 16}, [], @mean);
runNeq = zeros(size(tabdata,1),1); % Neq for each run(when noise contrast = 0, Neq = 0)

for t = 1:size(con,1)
    if con(t, 2)~=0
    cont = repmat(con(t,:),[size(tabdata,1) 1]);
    arr = find(all(tabdata{:, 3:6}==cont,2)); % the index of the two runs
    
    con0 = con(t,:);
    con0(2)=0;
    cont0 = repmat(con0,[size(con, 1) 1]);
    arr0 = find(all(con(:, 1:4)==cont0,2)); % the index of E0
    
    cE0 = repmat(me(arr0),[2 1]);
    runNeq(arr, 1)=(cE0/(tabdata{arr,14}-cE0))./tabdata{arr,15}; %Neq for the two runs
    end;
end;
ME = accumarray(subs, runNeq, [], @mean);
SDE = accumarray(subs, runNeq, [], @std);

out = [con,M1,SD1,tabdata{:,4}.^2,M2,SD2,ME];
tab = cell2table(out, 'VariableNames', col_name); %converts to table

writetable(tabdata,'xiuyun23.csv','Delimiter',',')
save('xiuyun23.mat','tab');
% end;