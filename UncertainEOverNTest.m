clear all
Screen('Preference','Verbosity',0);
% psych.trialsDesired=100;
psych.trialsDesired=300;
% psych.reps=100;
psych.reps=12;
% psych.noiseSD=0.17;
% psych.pThreshold=0.64;
psych.noiseType='gaussian';
psych.getAlphabetFromDisk=false;
M=[1 100];
for n=[2 9]
    a='DKHNORSVZ';
    psych.alphabet=a(1:n);
    for targetKind={'gabor' 'orthogonalLetter' 'letter'}
        psych.targetKind=targetKind{1};
        [EOverN,psych]=UncertainEOverN(M,psych);
    end
end