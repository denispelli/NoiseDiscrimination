% RevealCLUTMapping.m
% Reveal CLUT mapping. Some video drivers load the CLUT incorrectly. What
% you attempt to load into one CLUT entry affects several CLUT entries.
% Read Mario Kleiner's explanation in the last paragraph below. This
% program displays an image designed to reveal which pixel values are
% affected by each entry in the gamma table that you provide to
% LoadNormalizedGammaTable. We create 256 numbered rectangles on the
% screen, numbered 0:255. The number is displayed in black. The background
% of the rectangle is loaded with a pixel value equal to the displayed
% number. Thus the 256 rectangles show you the whole gamut of the CLUT.
% Except black (entry 0) and white (entries 254,255), each frame makes all
% but one of the CLUT entries black, making the chosen one white. Thus the
% numbered white rectangle identifies what luminance index is affected by
% the currently selected clut entry. (Exception: Clut entries 0 and 255
% remain at their standard values of black and white.)
% Denis Pelli, March 30, 2017.
% denis.pelli@nyu.edu
%
% This program documents several weird aspects of LoadNormalizedGammaTable.
% I'm running it on my Mac PowerBook Pro (Retina, 15-inch, Mid 2015), which
% has AMD video. I have installed the Psychtoolbox kernel, but I get the
% same results with and without it.
%
% 1. I am surprised to discover that my gamma table is not loaded if the
% first 86 (or more) entries are black. It loads fine if any number up to
% 85 entries are black. (Before zeroing the first part, I filled my gamma
% array with a linear ramp from 0 to 1.) When not loaded, the original
% gamma table remains, untouched. (I haven't yet figured out a rule
% predicting whether a gamma table will load. This is hard to do as I can
% detect failure only visually.)
% 
% 2. I am surprised that, when LoadNormalizedGammaTable fails, it still
% returns "success" = 1, and subsequent calls to ReadNormalizedGammaTable
% reflect the new table, which was not loaded.
% 
% 3. I am surprised that, even when I successfully load a new gamma table,
% what I get back from calling ReadNormalizedGammaTable is slightly
% different in most of the entries. The changes are tiny, often just 0.001.
% Denis Pelli April 1, 2017
%
% Mario Kleiner replied, and I quote here his comments regarding 1. & 3.
% above: Issue 3 (and partially 1) is very likely because the AMD
% graphics card is not working in "discrete 256 slot gamma table mode"
% anymore, but with a non-linear (or piece-wise linear) gamma table. The
% hardware does not store 256 different color output values in a LUT,
% instead it implements a non-linear or piece-wise linear mathematical
% function, which is cheaper to implement in hardware for large gamma
% tables with more than 256 slots or higher than 10-bit depths. The
% implemented function approximates typical non-linear gamma functions for
% color/gamma correction well, but of course can't fit any arbitrary
% discontinuous stuff you try to upload. So the display driver takes your
% 256 slot input table, then uses some mathematical model of the hardware
% implementation to do some function fit with the function of the hardware,
% then stores the defining parameters of the best fitting function in the
% hardware, so the hardware can implement that "best fit" approximation of
% your input gamma table. Obviously that only works well if your input LUT
% fulfills various unknown but hardware specific constraints, and is
% generally close enough to a typical gamma function. So i'm not surprised
% you get failure in case 1, or slight deviations in case 3 (as the real
% but hidden gamma function is overfitted to parts of your input data). I'm
% only surprised that in case of abject fitting failure like in case 1 the
% driver wouldn't report this failure back to us, but then that's just a
% typical macOS bug like so many others.

clear all
MAX_BLACK_ENTRIES=85; % 85 on MacBook Pro. 
useFractionOfScreen=0;
BackupCluts;
Screen('Preference','SkipSyncTests',2);
Screen('Preference','TextAntiAliasing',0);
normalizeColor=1;
enableCLUTMapping=0;
try
   %% OPEN WINDOW
   screen = 0;
   screenBufferRect = Screen('Rect',screen);
   PsychImaging('PrepareConfiguration');
   PsychImaging('AddTask','General','UseRetinaResolution');
   if normalizeColor
      PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
   end
   if enableCLUTMapping
      PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize,high res
      delayLoading=2;
   else
      delayLoading=1;
   end
   if ~useFractionOfScreen
      [window,screenRect] = PsychImaging('OpenWindow',screen,1);
   else
      [window,screenRect] = PsychImaging('OpenWindow',screen,1,round(useFractionOfScreen*screenBufferRect));
   end
   
   %% FILL WINDOW WITH RECTANGLES, EACH WITH A DIFFERENT COLOR (CLUT INDEX)
   if normalizeColor
      colorNorm=255;
   else
      colorNorm=1;
   end
   black=0/colorNorm;
   white=255/colorNorm;
   Screen('FillRect',window,black);
   Screen('TextFont',window,'Arial');
   height=round(RectHeight(screenRect)/32);
   width=round(RectWidth(screenRect)/12);
   height=min(height,round(width/3));
   Screen('TextSize',window,round(1.*height));
   r0=[0 0 width height];
   i=0;
   for x=0:width:(255/32)*width
      for y=0:height:31*height
         r=OffsetRect(r0,x,y);
         Screen('FillRect',window,i/colorNorm,r); % fill rect with index i
         Screen('DrawText',window,sprintf(' %3d',i),x,y+0.7*height,black,i/colorNorm,1); % Label it i.
         i=i+1;
      end
   end
   x=x+width;
   rWhite=[x 0 screenRect(3) screenRect(4)];
   Screen('FillRect',window,white,rWhite);
   box=[0 0 RectWidth(rWhite) 2.5*height];
   box=AlignRect(box,screenRect,'top','right');
   text=['Testing CLUT-control of all 8-bit monochrome colors '...
      '(R,G,B) = (i,i,i), where i=0:255. Small numbers (left) '...
      'are pixel values. Large number (above) is the selected CLUT entry. '...
      'Entries 253 to 255 are reserved for black and white. ' ...
      'The rest of the CLUT entries are set to black, except the '...
      'one selected above, which is set to white.\n'...
      'Click to advance to next CLUT entry: 0..255. Double-click is faster. '...
      'Triple-click is yet faster. Quad-click to quit.'];
   DrawFormattedText(window,text,x+height,box(4)+height,black,36);
   Screen('TextSize',window,2*height);
   x=box(1)+0.1*RectWidth(box);
   y=box(4)-0.3*RectHeight(box);
   i=1; 
   while i<256
      gamma=repmat((0:255)',1,3)/255;
      gamma(1:MAX_BLACK_ENTRIES,:)=zeros(MAX_BLACK_ENTRIES,3); % fails if MAX_BLACK_ENTRIES>85
      gamma(1+black*colorNorm,1:3)=0;
      gamma(1+(white*colorNorm-1:white*colorNorm),1:3)=1;
      gamma(i+1,1:3)=1; % Set selected entry to white.
      if ~enableCLUTMapping
         [oldtable,success]=Screen('LoadNormalizedGammaTable',window,gamma,delayLoading);
         Screen('Flip',window,[],1);
         table=Screen('ReadNormalizedGammaTable',window);
         if size(table,1)==1024
            table=table(1:4:1023,1:3);
         end
         fprintf('Set entry %3d to white: success=%d\n',i,success);
         list=gamma(:,2)~=table(:,2);
         fprintf('%d differences between gamma table loaded vs. read. Checking only green channel.\n',sum(list));
         n=1:256;
         fprintf('Subs.\tEntry\tLoad\tRead\tDiff\n');
         for j=n(list)
            fprintf('%d\t%d\t%.3f\t%.3f\t%.3f\n',j,j-1,gamma(j,2),table(j,2),table(j,2)-gamma(j,2));
         end
      else
         Screen('LoadNormalizedGammaTable',window,gamma,delayLoading);
      end     
      Screen('FillRect',window,white,box);
      Screen('DrawText',window,sprintf('%3d',i),x,y,black,white,1);
      Screen('Flip',window,[],1);
      switch(GetClicks)
         case 1, inc=1;
         case 2, inc=32;
         case 3, inc=64;
         otherwise, inc=inf;
      end
      i=i+inc;
   end
   sca;
   RestoreCluts;
catch
   sca
   RestoreCluts;
   psychrethrow(psychlasterror);
end