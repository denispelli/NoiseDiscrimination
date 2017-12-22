if 1
   %% CREATE LIST OF CONDITIONS TO BE TESTED
   if verLessThan('matlab','R2013b')
      error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
   end
   clear o oo
   
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
   
   %% Effect of threshold criterion: Graph Neq vs. P.
   % In each of the 3 domains
   % P: 0.35, 0.55, 0.75, 0.95
   % size: 2, 16 deg
   % eccentricity: 0, 30 deg
   % (omit 2 deg letter at 30 deg ecc.)
   o.viewingDistanceCm=25; % viewing distance
   o.experiment='Neq vs. P';
   o.eyes='right'; % 'left', 'right', 'both'.
   Ps=[0.35, 0.55, 0.75, 0.95];
   for ecc = [30 0]
      switch(abs(ecc))
         case(30)
            sizes = 16;
         case 0
            sizes=[2 16];
      end
      for size = sizes
         for noiseSD = [0 0.16]
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=size;
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
   end

   %% Number the conditions, and print the list.
   for i=1:length(oo)
      oo(i).condition=i;
   end
   t=struct2table(oo);
   t
end % Print the oo list of conditions.

if 1
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