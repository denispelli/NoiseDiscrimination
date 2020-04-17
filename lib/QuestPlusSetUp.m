function oo=QuestPlusSetUp(oo)
%% Set parameters for QUESTPlus
if oo(oi).questPlusEnable
    steepnesses=oo(oi).questPlusSteepnesses;
    guessingRates=oo(oi).questPlusGuessingRates;
    lapseRates=oo(oi).questPlusLapseRates;
    contrastDB=20*oo(oi).questPlusLogIntensities;
    switch oo(oi).thresholdParameter
        case 'flankerContrast'
            psychometricFunction=@qpPFCrowding;
        otherwise
            psychometricFunction=@qpPFWeibull;
    end
    oo(oi).questPlusData=qpParams('stimParamsDomainList', ...
        {contrastDB},'psiParamsDomainList',...
        {contrastDB, steepnesses, guessingRates, lapseRates},...
        'qpPF',psychometricFunction);
    oo(oi).questPlusData=qpInitialize(oo(oi).questPlusData);
end

