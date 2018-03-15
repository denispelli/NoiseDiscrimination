function [letterStruct,alphabetBounds]=CreateLetters(condition,o,window)
% [letterStruct,alphabetBounds]=CreateLetterTextures(condition,o,window)
% Create an array of images, one per letter in o.alphabet plus o.borderLetter.
% Set o.borderLetter=[] if you don't need it.
% Returns array "letterStruct" with one struct element per letter, plus
% bounding box "alphabetBounds" that will hold any letter. Called by
% NoiseDiscrimination.m. The font is o.targetFont.
%
% If o.readAlphabetFromDisk is false then the font is rendered by Screen
% DrawText to create an image for each desired letter.
%
% The font's TextSize is computed to yield the desired o.targetPix size in
% the direction specified by o.targetSizeIsHeight (true for height, false
% for width). However, if o.targetFontHeightOverNominalPtSize==nan then the
% TextSize is set equal to o.targetPix.
%
% If o.readAlphabetFromDisk==1 then we look for a folder inside
% NoiseDiscrimination/lib/alphabets/ whose name matches that of the desired
% font. We give a fatal error if it's not found. The folder is very simple,
% one image file per letter; the filename is the letter, URL-encoded to
% cope with symbols, including a space.
%
% The "letter" images can be anything (e.g. photos of faces). The only
% requirement is that all the images in a "font" must be the same size.
%
% The argument "condition" is used only for diagnostic printout.

% Checking of image size gives a detailed report if an error is detected,
% for instance:
% ERROR: Found a change in letter image size within the alphabet.
% File "/Users/denispelli/Dropbox/CriticalSpacing/alphabets/Pelli/b.png".
% Letter "b", 12 of 12, image size [0 0 1024 1024] differs from
% the image size of the preceding letters [0 0 102 513].
% Error using CreateLetterTextures (line 102)
% All letters must have the same image size!
% Error in CreateLetterTextures (line 102)
%            error('All letters must have the same image size!');

if ~isfinite(o.targetHeightOverWidth)
   o.targetHeightOverWidth=1;
end
letters=[o.alphabet o.borderLetter];
for i=1:length(letters)
   letterStruct(i).letter=letters(i);
end
canvasRect=[0 0 o.targetPix o.targetPix]*max(1,o.targetHeightOverWidth);
black=0;
white=255;
if o.readAlphabetFromDisk
   
   % Read from disk into "savedAlphabet".
   alphabetsFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'alphabets'); % NoiseDiscrimination/alphabets/
   if ~exist(alphabetsFolder,'dir')
      error('Folder missing: "%s"',alphabetsFolder);
   end
   folder=fullfile(alphabetsFolder,urlencoding(o.targetFont));
   if ~exist(folder,'dir')
      error('Folder missing: "%s". Target font "%s" has not been saved.',folder,o.targetFont);
   end
   d=dir(folder);
   ok=~[d.isdir];
   for i=1:length(ok)
      systemFile=streq(d(i).name(1),'.') && length(d(i).name)>1;
      systemFile=systemFile || streq(d(i).name,'Thumbs.db'); % ignore Windows cache
      ok(i)=ok(i) && ~systemFile;
   end
   d=d(ok);
   if length(d)<length(o.alphabet)
      error('Sorry. Saved %s alphabet has only %d letters, and you requested %d letters.',o.targetFont,length(d),length(o.alphabet));
   end
   savedAlphabet.letters=[];
   savedAlphabet.images={};
   savedAlphabet.rect=[];
   savedAlphabet.imageRects={};
   savedAlphabet.imageRect=[];
   for i=1:length(d)
      filename=fullfile(folder,d(i).name);
      try
         savedAlphabet.images{i}=imread(filename);
      catch
         sca;
         error('Cannot read image file "%s".',filename);
         psychrethrow(psychlasterror);
      end
      if isempty(savedAlphabet.images{i})
         error('Cannot read image file "%s".',filename);
      end
      [~,name]=fileparts(urldecoding(d(i).name));
      if length(name)~=1
         error('Saved "%s" alphabet letter image file "%s" must have a one-character filename after urldecoding.',o.targetFont,name);
      end
      savedAlphabet.letters(i)=name;
      white=savedAlphabet.images{i}(1,1,2); % Use upper left pixel as definition of "white".
      savedAlphabet.bounds{i}=ImageBounds(savedAlphabet.images{i},white);
      savedAlphabet.imageRects{i}=RectOfMatrix(savedAlphabet.images{i});
      if o.showLineOfLetters
         fprintf('%d: CreateLetterTextures "%c" image(%d) width %d, ',condition,savedAlphabet.letters(i),i,RectWidth(savedAlphabet.bounds{i}));
         fprintf('bounds %d %d %d %d, image %d %d %d %d.\n',savedAlphabet.bounds{i},savedAlphabet.imageRects{i});
      end
      if isempty(savedAlphabet.rect)
         savedAlphabet.rect=savedAlphabet.bounds{i};
      else
         savedAlphabet.rect=UnionRect(savedAlphabet.rect,savedAlphabet.bounds{i});
      end
      if isempty(savedAlphabet.imageRect)
         savedAlphabet.imageRect=savedAlphabet.imageRects{i};
      else
         a=savedAlphabet.imageRects{i};
         b=savedAlphabet.imageRect;
         savedAlphabet.imageRect=UnionRect(savedAlphabet.imageRect,a);
         if ~all(a==b)
            fprintf('\nERROR: Found a change in letter image size within the alphabet.\n');
            fprintf(['File "%s".\nLetter "%s", %d of %d, image size [%d %d %d %d] differs from \n'...
               'the image size of the preceding letters [%d %d %d %d].\n'],...
               filename,name,i,length(d),a,b);
            error('All letters must have the same image size!');
         end
      end
   end
   alphabetBounds=savedAlphabet.rect;
   
   % Get images, one per letter.
   for i=1:length(letters)
      which=strfind([savedAlphabet.letters],letters(i));
      if length(which)~=1
         error('Letter %c is not in saved "%s" alphabet "%s".',letters(i),o.targetFont,savedAlphabet.letters);
      end
      assert(length(which)==1);
      r=savedAlphabet.rect;
      letterImage=savedAlphabet.images{which}(r(2)+1:r(4),r(1)+1:r(3));
      letterStruct(i).image=letterImage;
      letterStruct(i).rect=RectOfMatrix(letterStruct(i).image);
   end
   
else % if o.readAlphabetFromDisk
   %    THIS CODE HAS NOT BEEN UPDATED TO RETURN IMAGES INSTEAD OF TEXTURES.
   % Draw font and get bounds.
   Screen('Preference','TextAntiAliasing',0);
   scratchWindow=Screen('OpenOffscreenWindow',window,[],canvasRect*4,8,0);
   if ~isempty(o.targetFontNumber)
      Screen('TextFont',scratchWindow,o.targetFontNumber);
      [~,number]=Screen('TextFont',scratchWindow);
      assert(number==o.targetFontNumber);
   else
      Screen('TextFont',scratchWindow,o.targetFont);
      font=Screen('TextFont',scratchWindow);
      assert(streq(font,o.targetFont));
   end
   if o.targetSizeIsHeight
      sizePix=round(o.targetPix/o.targetFontHeightOverNominalPtSize);
   else
      sizePix=round(o.targetPix*o.targetHeightOverWidth/o.targetFontHeightOverNominalPtSize);
   end
   if ~isfinite(sizePix)
      sizePix=o.targetPix;
   end
   Screen('TextSize',scratchWindow,sizePix);
   for i=1:length(letters)
      lettersInCells{i}=letters(i);
      bounds=TextBounds(scratchWindow,letters(i),1);
      if o.showLineOfLetters
         b=Screen('TextBounds',scratchWindow, letters(i));
         fprintf('%d: %s "%c" textSize %d, TextBounds [%d %d %d %d] width x height %d x %d, Screen TextBounds %.0f x %.0f\n', ...
            condition,o.targetFont,letters(i),sizePix,round(bounds),RectWidth(bounds),RectHeight(bounds),RectWidth(b),RectHeight(b));
      end
      letterStruct(i).bounds=bounds;
      if i==1
         alphabetBounds=bounds;
      else
         alphabetBounds=UnionRect(alphabetBounds,bounds);
      end
   end
   bounds=alphabetBounds;
   if o.printSizeAndSpacing
      fprintf('%d: sizePix %d, first letter "%c", height %d, width %d.\n',condition,sizePix,letters(1),RectHeight(letterStruct(1).bounds),RectWidth(letterStruct(1).bounds));
   end
   assert(RectHeight(bounds)>0);
   for i=1:length(letters)
      letterStruct(i).width=RectWidth(letterStruct(i).bounds);
      desiredBounds=CenterRect(letterStruct(i).bounds,bounds);
      letterStruct(i).dx=desiredBounds(1)-letterStruct(i).bounds(1);
   end
   Screen('Close',scratchWindow);
   
   % Create texture for each letter
   canvasRect=bounds;
   canvasRect=OffsetRect(canvasRect,-canvasRect(1),-canvasRect(2));
   if o.printSizeAndSpacing
      fprintf('%d: textSize %.0f, "%s" height %.0f, width %.0f\n',condition,sizePix,letters,RectHeight(bounds),RectWidth(bounds));
   end
   for i=1:length(letters)
      [letterStruct(i).texture,letterStruct(i).rect]=Screen('OpenOffscreenWindow',window,[],canvasRect,8,0);
      if ~isempty(o.targetFontNumber)
         Screen('TextFont',letterStruct(i).texture,o.targetFontNumber);
         [font,number]=Screen('TextFont',letterStruct(i).texture);
         assert(number==o.targetFontNumber);
      else
         Screen('TextFont',letterStruct(i).texture,o.targetFont);
         font=Screen('TextFont',letterStruct(i).texture);
         assert(streq(font,o.targetFont));
      end
      Screen('TextSize',letterStruct(i).texture,sizePix);
      Screen('FillRect',letterStruct(i).texture,white);
      if o.contrast==1
         Screen('DrawText',letterStruct(i).texture,letters(i),-bounds(1)+letterStruct(i).dx,-bounds(2),black,white,1);
      else
         Screen('DrawText',letterStruct(i).texture,letters(i),-bounds(1)+letterStruct(i).dx,-bounds(2),uint8(white+(double(black)-white)*o.contrast),white,1);
      end
   end
   Screen('Preference','TextAntiAliasing',1);
end % if o.readAlphabetFromDisk
end

function u = urlencoding(s)
u = '';

for k = 1:length(s),
   if ~isempty(regexp(s(k), '[a-zA-Z0-9]', 'once'))
      u(end+1) = s(k);
   else
      u=[u,'%',dec2hex(s(k)+0)];
   end;
end
end

function u = urldecoding(s)
u = '';
k = 1;
while k<=length(s)
   if s(k) == '%' && k+2 <= length(s)
      u = sprintf('%s%c', u, char(hex2dec(s((k+1):(k+2)))));
      k = k + 3;
   else
      u = sprintf('%s%c', u, s(k));
      k = k + 1;
   end
end
end
