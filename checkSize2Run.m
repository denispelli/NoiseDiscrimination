if 1
   %% CREATE LIST OF CONDITIONS TO BE TESTED
   if verLessThan('matlab','R2013b')
      error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
   end
   clear o oo
   
   % We list parameters here in the order that we want them to appear
   % as columns in the list.
   o.condition=1;
   o.experiment='checkSize2';
   o.eccentricityXYDeg=[0 0];
   o.noiseSD=0.16;
   o.pThreshold = 0.75;
   o.noiseType= 'gaussian';
   o.noiseCheckDeg=nan;
   o.targetDurationSec = 0.4;
   o.eyes='right';
   o.viewingDistanceCm=40.;
   o.targetGaborCycles=3;
   
   %% Effect of noise check size: Graph (E-E0)/N vs. checkDeg.
   % Replicating result from Manoj
   o.experiment='checkSize';
   o.fullResolutionTarget=1;
   o.eyes='both'; % 'left', 'right', 'both'.
   sizes=o.targetGaborCycles/0.5; % 0.5 c/deg
   o.targetGaborPhaseDeg=-90; % cosine phase
   o.viewingDistanceCm=80; % viewing distance
   o.noiseType= 'binary';
   o.targetDurationSec = 0.1;
   for size = sizes
      o.eccentricityXYDeg=[0 0];
      o.targetHeightDeg=size;
      for duration=0.1 % [0.1 0.4]
         o.targetDurationSec =duration;
         for fine=0:1
            o.fullResolutionTarget=fine;
            for noiseSD = [0.2 0]
               o.noiseSD=noiseSD;
               if noiseSD>0
                  for n=[10  40  160 320]
                     o.noiseCheckDeg=o.targetHeightDeg/n;
                     if ~exist('oo','var')
                        oo=o;
                     else
                        oo(end+1)=o;
                     end
                  end
               else
                  o.noiseCheckDeg=o.targetHeightDeg/10;
                  if ~exist('oo','var')
                     oo=o;
                  else
                     oo(end+1)=o;
                  end
               end
            end
         end
      end
   end
   o.noiseType= 'gaussian';
   o.targetDurationSec = 0.2;
   o.fullResolutionTarget=0;
   
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