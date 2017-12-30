%% CREATE LIST OF CONDITIONS TO BE TESTED
if verLessThan('matlab','R2013b')
   error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
end
clear o oo
fakeRun=0; % Used to check plotting before we have data.

% We list parameters here in the order that we want them to appear
% as columns in the list.
o.condition=1;
o.experiment='criterion';
o.eccentricityXYDeg=[0 0];
o.noiseSD=0.16;
o.noiseType= 'gaussian';
o.eyes='right';
o.viewingDistanceCm=40;
o.targetHeightDeg=1;
o.targetGaborCycles=3;
o.targetDurationSec = 0.2;
o.fullResolutionTarget=0;
o.pThreshold = 0.75;
cal=OurScreenCalibrations(0);

%% Effect of threshold criterion: Graph Neq vs. P.
% In each of the 3 domains
% P: 0.35, 0.55, 0.75, 0.95
% size: 2, 16 deg
% eccentricity: 0, 30 deg
% (omit 2 deg letter at 30 deg ecc.)
o.experiment='Neq vs. P';
o.eyes='right'; % 'left', 'right', 'both'.
Ps=[0.35, 0.55, 0.75, 0.95];
for domain=1:3
   switch domain
      case 1
         % photon
         ecc=0;
         cpd=4;
         o.targetDurationSec=0.1;
         o.luminanceFactor=1/8;
         o.domainName='photon';
%          o.minScreenWidthDeg=10;
      case 2
         % cortical
         ecc=0;
         cpd=0.5;
         o.targetDurationSec=0.4;
         o.luminanceFactor=1;
         o.domainName='cortical';
%          o.minScreenWidthDeg=10;
      case 3
         % ganglion
         ecc=30;
         cpd=0.2;
         o.targetDurationSec=0.2;
         o.luminanceFactor=1;
         o.domainName='ganglion';
%          o.minScreenWidthDeg=50;
   end
   for noiseSD = [0 0.16]
      o.eccentricityXYDeg=[ecc 0];
      o.targetHeightDeg=o.targetGaborCycles/cpd;
      o.minScreenWidthDeg=1+abs(o.eccentricityXYDeg(1))+o.targetHeightDeg*0.75;
      o.maxViewingDistanceCm=round(cal.screenWidthMm/10/(2*tand(o.minScreenWidthDeg/2)));
      o.viewingDistanceCm=min([o.maxViewingDistanceCm 50]);
      o.noiseCheckDeg=o.targetHeightDeg/20;
      o.noiseSD=noiseSD;
      for p=Ps
         o.pThreshold=p;
         if ~exist('oo','var')
            oo=o;
         else
            oo(end+1)=o;
         end
      end
   end
end

%% Number the conditions, and print the list.
for i=1:length(oo)
   oo(i).condition=i;
end
t=struct2table(oo);
t % Print the oo list of conditions.

if fakeRun
   data=table2struct(t);
   for i=1:length(data)
      data(i).E=data(i).noiseSD+0.03+0.01*floor((i-1)/8);
      data(i).trials=40;
      data(i).N=data(i).noiseSD;
      data(i).experimenter='Experimenter';
      data(i).observer='Observer';
      data(i).targetKind='gabor';
      data(i).noiseType='gaussian';
      data(i).LMean=280*data(i).luminanceFactor;
   end
   criterionAnalyze;
else
   %% RUN THE CONDITIONS
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" above.
   for oi=1:length(oo)
      o=oo(oi);
      %       o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
      o.experimenter='chen';
      o.experimenter='satrianna';
      o.experimenter='hortense';
      o.experimenter='darshan';
      o.experimenter='flavia';
      o.experimenter='shenghao';
      o.experimenter='yichen';
      o.experimenter='';
      o.observer=''; % Enter observer's name at run time.
      if oi>1 && isempty(o.observer)
         o.observer=oOut.observer;
      end
      if oi>1 && isempty(o.experimenter)
         o.experimenter=oOut.experimenter;
      end
      o.blankingRadiusReEccentricity=0;
      if 0
         o.targetKind='letter';
         o.font='Sloan';
         o.alphabet='DHKNORSVZ';
      else
         o.targetKind='gabor';
         o.targetGaborOrientationsDeg=[0 45 90 135];
         o.targetGaborNames='1234';
         o.alphabet=o.targetGaborNames;
         o.alternatives=length(o.alphabet);
      end
      o.useDynamicNoiseMovie = 1;
      o.markTargetLocation=1;
      if all(o.eccentricityXYDeg==0)
         o.markTargetLocation=0;
      end
      o.blankingRadiusReTargetHeight=0;
      o.moviePreSec = 0.2;
      o.moviePostSec = 0.2;
      o.targetMarkDeg=1;
      o.fixationCrossDeg=3;
      oOut=NoiseDiscrimination(o);
      if oOut.quitSession
         break
      end
   end
end % Run the selected conditions