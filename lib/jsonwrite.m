function jsonstr = jsonwrite(fname, s)
% Recursively wraps MATLAB's proprietary `jsonencode` function with
% `func2str` because `jsonencode` wails about function_handle class
% objects.
% Hormet Yiltiz
% Copyright, 2019

sane_s = sanify(s); % a recursive call
jsonstr = jsonencode(sane_s);

fid = fopen(fname,'wt'); % this would overwrite if exists
fprintf(fid, jsonstr);
fclose(fid);

ww = whos('jsonstr');
sizeThreshold = 1;
if ww.bytes/2^20 > sizeThreshold % raw str size is larger than 1MB
  warning('jsonwrite:StringSize', 'JSON string is larger than %dMB. Compressing into a zip archive.', sizeThreshold);
  zip([fname '.zip'], fname);
end
end

%% recursive
function sane_s = sanify(s)
if isempty(s)
  % do nothing
  sane_s = nothing(s);
elseif numel(s) == 1
  if strcmp(class(s), 'function_handle')
    try
      sane_s = func2str(s);
    catch
      sane_s = 'UNKNOWN FUNCTION HANDLE WITH INTRICATE BODY';
    end
  elseif strcmp(class(s), 'struct')
    fNames = fieldnames(s);
    sane_s = struct();
    for i=1:numel(fNames)
      sane_s.(fNames{i}) = sanify(s.(fNames{i}));
    end
  else
    % just a leaf, do nothing
    sane_s = nothing(s);
  end
else
  % traverse
  switch class(s)
    case 'cell'
      try
        sane_s = reshape(cellfun(@(x) sanify(x), s, 'UniformOutput', false), size(s));
      catch
        keyboard
      end
      
    case 'table'
      sane_s = table2struct(s);
      
    case 'struct'
      % a struct array: class([struct('a', 1), struct('a', 2)])=='struct'
      sane_s = reshape(arrayfun(@(x) sanify(x), s), size(s));
      
    otherwise
      % class([1 2 3]) is `double` and class([true false]) is `logical`
      % isvector([1 2 3]) == isvector({1, 2, 3})
      % [{1}, {2,3}] == {1,2,3}
      % Stupid MATLAB
      
      % Whatever iterable it is, its content is not of class `cell`. Normal
      % arrays `[]` cannot contain function_handles. Great. Let's exploit
      % by doing nothing, except `jsonencode` wails on complex numbers.
      sane_s = nothing(s);
  end
end

end

function sane_s = nothing(s)
% Ironically, doing nothing on the leaf means fixing `jsonencode` wailing
% on `complex` numbers
if ~isreal(s)
  sane_s = {'type:complex', real(s), imag(s)};
else
  sane_s = s;
end
end
