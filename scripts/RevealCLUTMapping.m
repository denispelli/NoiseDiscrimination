% Reveal CLUT mapping
% Modern video drivers implement the hardware color lookup table by fitting
% it with a smooth function, and using that function instead of the table
% provided by the user. This results in large effects of neigboring values
% in the table, which this demo exhibits. The lesson is that the hardware
% lookup table is no longer useful for arbitrary user manipulation. It will
% only accurately render a very smooth function. THe identity function is
% accurately rendered in my experience.
%
% Some video drivers load the CLUT incorrectly, putting clut values into
% the wrong entries. This program displays an image designed to reveal what
% goes where. We display 256 numbers, 0:255. Each number is written with
% that luminance index. Each frame makes all the CLUT entries green, except
% one, which is black. Thus the black number identifies what luminance
% index is affected by the currently enabled clut entry.
% Denis Pelli, March, 2017
clear gamma
gamma=[0:255; 0:255; 0:255]';
gamma=gamma/255;
useFractionOfScreen=0;
BackupCluts;
% Screen('Preference','SkipSyncTests',2);
try
   %% OPEN WINDOW
   screen = 0;
   screenBufferRect = Screen('Rect',screen);
   PsychImaging('PrepareConfiguration');
   %    PsychImaging('AddTask','General','UseRetinaResolution');
   %    PsychImaging('AddTask','AllViews','EnableCLUTMapping',256,1); % clutSize,high res
   if ~useFractionOfScreen
      [window,screenRect] = PsychImaging('OpenWindow',screen,255);
   else
      [window,screenRect] = PsychImaging('OpenWindow',screen,255,round(useFractionOfScreen*screenBufferRect));
   end
   
   %% FILL WINDOW WITH NUMBERS, EACH WITH A DIFFERENT COLOR (CLUT INDEX)
   Screen('FillRect',window,255);
   Screen('TextFont',window,'Arial');
   height=screenRect(4)/33;
   Screen('TextSize',window,round(0.7*height));
   for i=0:255
      x=50+floor(i/32)*height*5;
      y=height*(1+mod(i,32));
      Screen('DrawText',window,sprintf('%3d',i),x,y,i,255,1);
   end
   text='Small number is pixel value. Large number is CLUT entry.';
   bounds=Screen('TextBounds',window,text,0,100,1);
   x=screenRect(3)-bounds(3);
   y=screenRect(4)-height/2;
   Screen('DrawText',window,text,x,y,0,255,1);
   box=[0 0 200 80];
   box=CenterRect(box,screenRect);
   box=AlignRect(box,screenRect,'right');
   Screen('TextSize',window,40);
   x=box(1)+0.1*RectWidth(box);
   y=box(4)-0.3*RectHeight(box);
   for i=0:255
      gamma(1,1:3)=0;
      gamma(2:255,1:3)=repmat([.5 1 .5],254,1);
      gamma(i+1,1:3)=0;
      Screen('LoadNormalizedGammaTable',window,gamma,1);
      Screen('FillRect',window,255,box);
      Screen('DrawText',window,sprintf('%3d',i),x,y,0,255,1);
      Screen('Flip',window,[],1);
      GetClicks;
   end
   sca;
   RestoreCluts;
catch
   sca
   RestoreCluts;
   psychrethrow(psychlasterror);
end