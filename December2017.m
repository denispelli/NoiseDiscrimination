% December2017.m
% December 5, 2017, denis.pelli@nyu.edu
% Script for darshan, flavia, shenghao, and yichen to measure equivalent noise in the periphery.

% Neq Plan
% October 19, 2017 by Denis & Manoj
%
% Standard condition
% measure each Neq twice.
% six observers.
% gabor target at 1 of 4 orientations
% P=0.75, assuming 4 alternatives
% luminance 206 cd/m2
% monocular, temporal field, right eye
% duration 200 ms
%
% After running o=NoiseDiscrimination(o); you can type "o" to see the
% default values for all the parameters you didn't explicitly set.

if 1
   %% CREATE COMPLETE LIST OF CONDITIONS TO BE TESTED
   if verLessThan('matlab','R2013b')
      error('This MATLAB is too old. We need MATLAB 2013b or better to use the function "struct2table".');
   end
   clear o oo
   
   % We list parameters here in the order that we want them to appear
   % as columns in the list.
   o.condition=1;
   o.experiment='';
   o.eccentricityXYDeg=[0 0];
   o.targetHeightDeg=1;
   o.noiseSD=0.16;
   o.pThreshold = 0.75;
   o.noiseType= 'gaussian';
   o.noiseCheckDeg=nan;
   o.targetDurationSec = 0.4;
   o.eyes='right';
   o.viewingDistanceCm=40.;
   o.targetGaborCycles=3;
      
   %% Graph E vs. N, monocular vs binocular
   % In each of the 3 domains
   % size: 2, 16 deg
   % eccentricity: 0, 30 deg
   % (omit 2 deg letter at 30 deg ecc.)
   o.experiment='one vs two eyes';
   size=8;
   for ecc=60
      o.eyes='right'; % 'left', 'right', 'both'.
      for noiseSD = [0 0.16]
         o.eccentricityXYDeg=[0 ecc];
         o.targetHeightDeg=size;
         o.noiseCheckDeg=o.targetHeightDeg/20;
         o.noiseSD=noiseSD;
         if ~exist('oo','var')
            oo=o;
         else
            oo(end+1)=o;
         end
      end
      o.eyes='both';
      for noiseSD = [0 0.16]
         o.eccentricityXYDeg=[0 ecc];
         o.targetHeightDeg=size;
         o.noiseCheckDeg=o.targetHeightDeg/20;
         o.noiseSD=noiseSD;
         if ~exist('oo','var')
            oo=o;
         else
            oo(end+1)=o;
         end
      end
   end
   
   %% Effect of Eccentricity: Graph Neq vs Eccentricity. temporal field
   % ecc: 0, 3, 10, 30, 60 deg
   % size: 2, 4, 8, 16 deg
   o.experiment='Neq vs eccentricity';
   o.eyes='right'; % 'left', 'right', 'both'.
   eccs=[60 30 10 3 0];
   o.viewingDistanceCm=40; % viewing distance
   sizes = [2 4 8 16];
   for ecc = eccs
      switch(abs(ecc))
         case(30)
            sizes = [4 8 16];
         case(60)
            sizes= [8 16];
      end
      for size = sizes
         for noiseSD = [0 0.16]
            o.eccentricityXYDeg=[ecc 0];
            o.targetHeightDeg=size;
            o.noiseCheckDeg=o.targetHeightDeg/20;
            o.noiseSD=noiseSD;
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
   t
end % Create the oo list of conditions.


if 0
   %% RUN THE CONDITIONS
   % Typically, you'll select just a few of the conditions stored in oo
   % that you want to run now. Select them from the printout of "t" above.
   for oi=13
      o=oo(oi);
%       o.useFractionOfScreen=0.4; % 0: normal, 0.5: small for debugging.
      o.experimenter='';
      o.observer=''; 
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
      o=NoiseDiscrimination(o);
      if o.quitExperiment
         break
      end
   end
end % Run the selected conditions