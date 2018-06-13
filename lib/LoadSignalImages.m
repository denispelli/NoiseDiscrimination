function [signalStruct,signalBounds]=LoadSignalImages(o)
% [signalStruct,signalBounds]=LoadSignalImages(o);
% Create an array of images, one per letter in o.alphabet plus o.borderLetter.
% Set o.borderLetter=[] if you don't need it.
% Returns array "signalStruct" with one struct element per letter, plus
% bounding box "signalBounds" that will hold any letter. Called by
% NoiseDiscrimination.m. The folder is o.signalImagesFolder.
%
% Setting o.signalImagesAreGammaCorrected=true alerts MATLAB that your
% images are gamma corrected, so it linearizes them before displaying them
% on our linearized display.
%
% The font's TextSize is computed to yield the desired o.targetPix size in
% the direction specified by o.targetSizeIsHeight (true for height, false
% for width). However, if o.targetFontHeightOverNominalPtSize==nan then the
% TextSize is set equal to o.targetPix.
%
% We look for a folder o.signalImagesFolder inside
% NoiseDiscrimination/lib/signalImages/. We give a fatal error if it's not
% found. The folder is very simple, one image file per letter; the filename
% is the letter, URL-encoded to cope with symbols, including a space.
%
% The "letter" images can be anything (e.g. photos of faces). The only
% requirement is that all the images in a signalImagesFolder must be the
% same size. Detailed run-time checking produces a fatal error message if
% any image is missing or has the wrong size.
%
% I think both monochrome and color images are handled correctly.
%
% denis.pelli@nyu.edu March, 2018

if ~isfinite(o.targetHeightOverWidth)
   o.targetHeightOverWidth=1;
end
letters=[o.alphabet o.borderLetter];
for i=1:length(letters)
   signalStruct(i).letter=letters(i);
end
% canvasRect=[0 0 o.targetPix o.targetPix]*max(1,o.targetHeightOverWidth);
% black=0;
% white=255;

% List the filenames in the specified folder.
signalImagesFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'signalImages'); % NoiseDiscrimination/signalImages/
if ~exist(signalImagesFolder,'dir')
   error('Folder missing: "%s"',signalImagesFolder);
end
folder=fullfile(signalImagesFolder,urlencoding(o.signalImagesFolder));
if ~exist(folder,'dir')
   error('Folder missing: "%s" for "%s".',folder,o.signalImagesFolder);
end
d=dir(folder);
ok=~[d.isdir];
for i=1:length(ok)
   ignoreFile=streq(d(i).name(1),'.') && length(d(i).name)>1;
   ignoreFile=ignoreFile || streq(d(i).name,'Thumbs.db'); % ignore Windows cache
   ok(i)=ok(i) && ~ignoreFile;
end
d=d(ok);
if length(d)<length(o.alphabet)
   error('Sorry. Folder %s has only %d images, and you requested %d.',o.signalImagesFolder,length(d),length(o.alphabet));
end

% Read from disk into "savedAlphabet".
savedAlphabet.letters=[];
savedAlphabet.images={};
savedAlphabet.rect=[];
savedAlphabet.imageRects={};
savedAlphabet.imageRect=[];
for i=1:length(d)
   filename=fullfile(folder,d(i).name);
   try
      savedAlphabet.images{i}=imread(filename);
   catch e
      sca;
      ListenChar;
      e.message
      error('Cannot read image file "%s".',filename);
   end
   if isempty(savedAlphabet.images{i})
      error('Cannot read image file "%s".',filename);
   end
   if o.printImageStatistics
       img=savedAlphabet.images{i};
       fprintf('LoadSignalImages %d: image %d "%s" %dx%dx%d, min %.2f, max %.2f.\n',...
           MFileLineNr,i,d(i).name,size(img,1),size(img,2),size(img,3),min(img(:)),max(img(:)));
   end
   if o.signalImagesAreGammaCorrected
       if verLessThan('matlab','R2017b')
           error('This MATLAB is too old. We need MATLAB 2017b or better to use the function "rgb2lin".');
       end
       im = rgb2lin(savedAlphabet.images{i},'OutputType','double');
       savedAlphabet.images{i}=im;
       if o.printImageStatistics
           img=savedAlphabet.images{i};
           fprintf('LoadSignalImages %d: gamma-corrected image %d "%s" %dx%dx%d, min %.2f, max %.2f.\n',...
               MFileLineNr,i,d(i).name,size(img,1),size(img,2),size(img,3),min(img(:)),max(img(:)));
       end
   end
   [~,name]=fileparts(urldecoding(d(i).name));
   if length(name)~=1
      error('Folder "%s" image file "%s" must have a one-character filename after urldecoding.',o.signalImagesFolder,name);
   end
   savedAlphabet.letters(i)=name;
   white=savedAlphabet.images{i}(1,1,:);
   if length(white)>1
       white=white(2);
   end
   % Use upper left pixel, green channel value, as definition of "white".
   % "white" is used solely to measure the image bounds, i.e. the bounding
   % rect of the non-white pixels.
   o.targetPix=round(o.targetPix);
   sz=size(savedAlphabet.images{i});
   rows=o.targetPix;
   cols=round(o.targetPix*sz(2)/sz(1));
   savedAlphabet.images{i}=imresize(savedAlphabet.images{i},[rows cols],'bilinear');
   if o.printImageStatistics
       img=savedAlphabet.images{i};
       fprintf('LoadSignalImages %d: resized image %d "%s" %dx%dx%d, min %.2f, max %.2f.\n',...
           MFileLineNr,i,d(i).name,size(img,1),size(img,2),size(img,3),min(img(:)),max(img(:)));
   end
   savedAlphabet.bounds{i}=ImageBounds(savedAlphabet.images{i},white);
   savedAlphabet.imageRects{i}=RectOfMatrix(savedAlphabet.images{i});
   if o.printSignalImages
      fprintf('%d: LoadSignalImages "%c" image(%d) width %d, ',...
          o.condition,savedAlphabet.letters(i),i,RectWidth(savedAlphabet.bounds{i}));
      fprintf('bounds %d %d %d %d, image %d %d %d %d. min %.2f, max %.2f\n',...
          savedAlphabet.bounds{i},savedAlphabet.imageRects{i},...
          min(savedAlphabet.images{i}(:)),max(savedAlphabet.images{i}(:)));
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
         fprintf('\nERROR: Found a change in image size within the folder.\n');
         fprintf(['File "%s".\nImage "%s", %d of %d, size [%d %d %d %d] differs from \n'...
            'the size of the preceding images [%d %d %d %d].\n'],...
            filename,name,i,length(d),a,b);
         error('All images must have the same size!');
      end
   end
end
signalBounds=savedAlphabet.rect;

% Get images, one per letter.
for i=1:length(letters)
   which=strfind([savedAlphabet.letters],letters(i));
   if length(which)~=1
      error('Image %c is not in "%s" folder, which only has "%s".',letters(i),o.signalImagesFolder,savedAlphabet.letters);
   end
   assert(length(which)==1);
   r=savedAlphabet.rect;
   letterImage=savedAlphabet.images{which}(r(2)+1:r(4),r(1)+1:r(3),:);
   signalStruct(i).image=letterImage;
   signalStruct(i).rect=RectOfMatrix(signalStruct(i).image);
end
end

function u = urlencoding(s)
u = '';

for k = 1:length(s)
   if ~isempty(regexp(s(k), '[a-zA-Z0-9]', 'once'))
      u(end+1) = s(k);
   else
      u=[u,'%',dec2hex(s(k)+0)];
   end
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
