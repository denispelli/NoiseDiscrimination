for i=1:length(ooo)
    t=struct2table(ooo{i});
    disp(t(:,{'observer' 'contrast' 'E' 'EOverN' 'noiseSD' 'trials'}))
end