% RevealCLUTMapping.m
% Reveal CLUT mapping. Some video drivers load the CLUT incorrectly. What
% you attempt to load into one CLUT entry affects several CLUT entries. (It
% seems that the video driver is doing us the "favor" of smoothing the the
% list of CLUT entries, which is not something I wanted.) This program
% displays an image designed to reveal which pixel values are affected by
% each entry in the gamma table that you provide to
% LoadNormalizedGammaTable. We create 256 numbered rectangles on the
% screen, numbered 0:255. The number is written in black. The background of
% the rectangle is loaded with a pixel value equal to the displayed number.
% Thus the 256 rectangles show you the whole gamut of the CLUT. Except
% black (entry 253) and white (entries 254,255), each frame makes all but
% one of the CLUT entries gray, making the chosen one black. Thus the black
% number identifies what luminance index is affected by the currently
% selected clut entry. (Exception: Clut entries 0 and 255 remain at their
% standard values of black and white. Denis Pelli, March 30, 2017.
% denis.pelli@nyu.edu
useFractionOfScreen=0;
BackupCluts;
Screen('Preference','SkipSyncTests',2);
Screen('Preference', 'TextAntiAliasing', 0);
try
   %% OPEN WINDOW
   screen = 0;
   screenBufferRect = Screen('Rect',screen);
   PsychImaging('PrepareConfiguration');
   PsychImaging('AddTask','General','UseRetinaResolution');
   PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
 %    PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize,high res
   if ~useFractionOfScreen
      [window,screenRect] = PsychImaging('OpenWindow',screen,1);
   else
      [window,screenRect] = PsychImaging('OpenWindow',screen,1,round(useFractionOfScreen*screenBufferRect));
   end
   
   %% FILL WINDOW WITH RECTANGLES, EACH WITH A DIFFERENT COLOR (CLUT INDEX)
   black=253/255;
   white=255/255;
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
         Screen('FillRect',window,i/255,r); % fill rect with index i
         Screen('DrawText',window,sprintf(' %3d',i),x,y+0.7*height,black,i/255,1); % label it i
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
      'Click to advance to next CLUT entry. Double-click is faster. '...
      'Triple-click is yet faster. Quad-click to quit.'];
   DrawFormattedText(window,text,x+height,box(4)+height,black,36);
   Screen('TextSize',window,2*height);
   x=box(1)+0.1*RectWidth(box);
   y=box(4)-0.3*RectHeight(box);
   i=0;
   while i<256
      gamma=zeros(256,3);
      gamma(1+black*255,1:3)=0;
      gamma(1+(white*255-1:white*255),1:3)=1;
      gamma(i+1,1:3)=1;
      Screen('LoadNormalizedGammaTable',window,gamma,0);
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