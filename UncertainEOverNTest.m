M=[1 10];
psych.targetKind='gabor';
psych.targetKind='letter';
psych.noiseSD=0.17;
psych.noiseType='gaussian';
[EOverN,psych]=UncertainEOverN(M,psych);
psych.noiseType
EOverN
psych.noiseType='uniform';
[EOverN,psych]=UncertainEOverN(M,psych);
psych.noiseType
EOverN
