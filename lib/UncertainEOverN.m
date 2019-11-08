function [EOverN,psych]=UncertainEOverN(M,psych)
% [EOverN,psych]=UncertainEOverN(M,psych);
% Measures threshold E/N for ideal detection of known signal at one of
% locations. (I.e. one of M orthogonal signals.) This corresponds to a
% 2-interval forced choice where the signal appears at one of M locations,
% randomly on one of two intervals, and the observer must report which
% interval. Or the signal has one of two orthogal shapes (grating
% orientation) and appears at one of M locations, and the observer's task
% is to identify orientation.
% Based on QuestDemo.m
plusMinus=char(177);
micro=char(181);
wrongRight={'wrong','right'};
timeZero=GetSecs;

if nargin<1
    M=1;
end
EOverN=zeros(size(M));
if nargin<2
    psych.x=[];
end
if ~isfield(psych,'trialsDesired')
    psych.trialsDesired=100;
end
if ~isfield(psych,'reps')
    psych.reps=100;
end
if ~isfield(psych,'tGuess')
    psych.tGuess=0;
end
if ~isfield(psych,'tGuessSd')
    psych.tGuessSd=2;
end
if ~isfield(psych,'pThreshold')
    psych.pThreshold=0.75;
end
if ~isfield(psych,'beta')
    psych.beta=3.5;
end
if ~isfield(psych,'delta')
    psych.delta=0.01;
end
if ~isfield(psych,'gamma')
    psych.gamma=0.5;
end
if isfield(psych,'x')
    psych=rmfield(psych,'x');
end
for m=1:length(M)
    t=zeros([1 psych.reps]);
    for r=1:psych.reps
        q=QuestCreate(psych.tGuess,psych.tGuessSd,psych.pThreshold,psych.beta,psych.delta,psych.gamma);
        q.normalizePdf=1;
        for k=1:psych.trialsDesired
            tTest=QuestQuantile(q);
            x=randn([M(m) 2]); % 2 interval forced choice, with M locations.
            x(1,1)=x(1,1)+10^tTest; % Add signal to one location.
            % y is max of each column.
            if M(m)>1
                y=max(x);
            else
                y=x;
            end
            response=y(1)>y(2); % Correct if we choose the signal.
            %     fprintf('Trial %3d at %5.2f is %s\n',k,tTest,char(wrongRight(response+1)));
            q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
        end
        t(r)=QuestMean(q);
    end
    logC=mean(t);
    EOverN(m)=10^(2*logC);
    if false
        fprintf(['M %7.0f. E/N %6.3f, c %6.3f, log c %5.3f ' plusMinus ' %.3f\n'],...
            M(m),EOverN(m),10^logC,logC,std(t)/sqrt(length(t)));
    end
end
% fprintf('%.0f ms/trial\n',1000*(GetSecs-timeZero)/(psych.reps*4*psych.trialsDesired));
if false
    % Optionally, reanalyze the data with psych.beta as a free parameter.
    fprintf('\nBETA. Many people ask, so here''s how to analyze the data with psych.beta as a free\n');
    fprintf('parameter. However, we don''t recommend it as a daily practice. The data\n');
    fprintf('collected to estimate threshold are typically concentrated at one\n');
    fprintf('contrast and don''t constrain psych.beta. To estimate psych.beta, it is better to use\n');
    fprintf('100 trials per intensity (typically log contrast) at several uniformly\n');
    fprintf('spaced intensities. We recommend using such data to estimate psych.beta once,\n');
    fprintf('and then using that psych.beta in your daily threshold measurements. With\n');
    fprintf('that disclaimer, here''s the analysis with psych.beta as a free parameter.\n');
    QuestBetaAnalysis(q); % optional
    fprintf('Parameters of QUEST fit:\n');
    fprintf('psych.beta	psych.gamma\n');
    fprintf('%4.1f	%5.2f\n',q.psych.beta,q.psych.gamma);
end
