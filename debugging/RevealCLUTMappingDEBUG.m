% Bug in LoadNormalizedGammaTable
clear all
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
      gamma=zeros(256,3);
      gamma=repmat((0:255)',1,3)/255;
      gamma(1:85,:)=zeros(85,3); % succeeds
%       gamma(1:86,:)=zeros(86,3); % fails
      gamma(1+black*colorNorm,1:3)=0;
      gamma(1+(white*colorNorm-1:white*colorNorm),1:3)=1;
      gamma(i+1,1:3)=1;
      if ~enableCLUTMapping
         [oldtable,success]=Screen('LoadNormalizedGammaTable',window,gamma,delayLoading);
         Screen('Flip',window,[],1);
         table=Screen('ReadNormalizedGammaTable',window);
         if size(table,1)==1024
            table=table(1:4:1023,1:3);
         end
         fprintf('setting entry %3d to white, success=%d\n',i,success);
         list=gamma(:,2)~=table(:,2);
         fprintf('%d differences\n',sum(list));
         n=1:256;
         ['n' 'loaded' 'read']
         [n(list)' gamma(list,2) table(list,2)]
      else
         Screen('LoadNormalizedGammaTable',window,gamma,delayLoading);
      end
      fprintf('%3d, success %d\n',i,success);
      list=gamma(:,2)~=table(:,2);
      fprintf('%d differences\n',sum(list));
      n=1:256;
      [n(list)' gamma(list,2) table(list,2)]      
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