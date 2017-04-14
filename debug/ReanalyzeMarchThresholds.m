% Fix threshold contrasts measured in January-March 2017. We got great Neq
% data from Chen and Ning. We included Chen's data in my NIH grant proposal
% sent mid March. Ning's data agree with Chen's at high contrast, but was
% crazy at low contrast. Eventually I discovered two bugs. Firstly CLUT was
% loaded AFTER the trial, so each trial ran at the nominal contrast of the
% previous trial. This can be overcome by reanalyzing the data, with the
% correct association of response and trial. More important, I discovered
% that we were attaining only 8 bits of luminance precision. As a
% consequence all nominal contrasts of 0.78% or above were correct (with
% negligible rounding error) and all contrasts below that were rounded to
% 0.78% or zero. That discrepancy between actual and nominal contrast led
% Quest to estimate absurdly low thresholds for Ning. Again, we can
% overcome the bug by reanalyzing the data with the actual contrast.
%
% actualC=0.0078*round(nominalC/0.0078);
%
% When we enhanced NoiseDiscrimination to show dynamic noise, the single
% image presentation was expanced to be a movie. In this program contrast
% is controlled by loading the CLUT (color lookup table). Formerly the CLUT
% was loaded by the same Screen Flip command the presented the stimulus
% image. The movie code left the CLUT loading to happen after the whole
% movie was shown. The the trial was displayed with the CLUT and contrast
% remaining from the last trial. Fixing NoiseDiscrimination is easy, simply
% loading the CLUT before the movie. We collected data for a few weeks with
% that bug. This program salvages the data, correctly pairing the contrast
% and response and running Quest again to obtain a valid threshold estimate
% to replace the old invalid one. Chen provided MATLAB code to cycle
% through our MAT files. I added code to run Quest and save the results.
% denis.pelli@nyu.edu March 21, 2017.

% Actual N at each eccentricity. The program's computation of power
% spectral density assumes display at site of target is orthogonal to line
% of sight (from eye) and at specified viewing distance. In fact the
% display was orthogonal to line of sight at fixation point, and thus
% tilted at the target site. The target site is further than the nominal
% viewing distance. Our target is along the horizontal meridian so the tilt
% compressed along the x axis without affecting the y axis. This reduces
% power spectral density N by a factor of cos(phi), where phi is
% eccentricity. The ratio of nominal to actual distance is cos(phi). This
% scales both x and y, so it reduces N by a factor of cos(phi)^2. Thus the
% actual N(phi) is cos(phi)^3*N.

clear all;
name='measurePeripheralThresholds';
dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data');
cd(dataFolder);
matFiles=dir('*.mat');
fprintf('Saving results in "fixed data summary.txt", which you can read into Excel.\n');
fprintf('Analyzing only files whose names begin with "%s"\n',name);
fi=fopen('reanalyzedMarchThresholds.txt','w');
fprintf(fi,['secs\tdate\tname\tecc deg\theight deg\tdur s\tNNominal\tN\ttrials\t'...
    'file mean\tsd\told mean\tsd\tnew mean\tsd\terr\tchange\n']);
for iFile = 1:length(matFiles)
    n=length(name);
    if ~strncmp(name,matFiles(iFile).name,n)
        continue
    end
    a=load(matFiles(iFile).name);
    o=a.o;
    data = o.data;
    if length(data)<40
        % Skip runs with less than 40 trials.
        continue;
    end
    % For each contrast (column 1), the response (column 2) is in the next
    % row. We discard the first response (to an unknown contrast) and the
    % last contrast (untested).
    dataX=data(1:end-1,:); % Get log contrast (column 1).
    dataX(:,2)=data(2:end,2); % Get response (column 2).
    % actualC=0.0078*round(nominalC/0.0078);
    dataX(:,1)=log10(0.0078*round(10.^dataX(:,1)/0.0078));
    good=isfinite(dataX(:,1));
    dataX=dataX(good,1:2);
    delta = 0.02;
    gamma = 1/o.alternatives;
    tGuess = -0.5;
    tGuessSd = 2;
    q = QuestCreate(tGuess,tGuessSd,o.pThreshold,o.beta,delta,gamma);
    q.normalizePdf = 1; % adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    qX=q;
    for i=1:length(data)
        q = QuestUpdate(q,data(i,1),data(i,2)); % Add the new datum (actual test intensity and o.observer response) to the database.
    end
    for i=1:length(dataX)
        qX = QuestUpdate(qX,dataX(i,1),dataX(i,2)); % Add the new datum (actual test intensity and o.observer response) to the database.
    end
    fprintf(['%12s, %9s, %2.0f deg ecc,%2.0f deg,%4.1f s,%6.2f log NNominal,%6.2f log N,%5d trials, '...
        'file %5.2f±%4.2f, old %5.2f±%4.2f, new %5.2f±%4.2f, err %5.2f, change %5.2f\n'],...
        datestr(o.beginningTime,1),o.observer,o.eccentricityDeg,o.targetHeightDeg,o.durationSec,log10(o.N),log10(o.N*cosd(o.eccentricityDeg).^3),o.trials,...
        o.questMean,o.questSd,QuestMean(q),QuestSd(q),QuestMean(qX),QuestSd(qX),o.questMean-QuestMean(q),QuestMean(q)-QuestMean(qX));
    fprintf(fi,['%d\t%s\t%s\t%.0f\t%.0f\t%.1f\t%.2g\t%5d\t'...
        '%5.2f\t%4.2f\t%5.2f\t%4.2f\t%5.2f\t%4.2f\t%5.2f\t%5.2f\n'],...
        o.beginningTime,datestr(o.beginningTime,1),o.observer,o.eccentricityDeg,o.targetHeightDeg,o.durationSec,o.N,o.N*cosd(o.eccentricityDeg).^3,o.trials,...
        o.questMean,o.questSd,QuestMean(q),QuestSd(q),QuestMean(qX),QuestSd(qX),o.questMean-QuestMean(q),QuestMean(q)-QuestMean(qX));   
end
fclose(fi);
