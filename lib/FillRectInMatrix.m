function matrix=FillRectInMatrix(value,rect,matrix)
% matrix=FillRectInMatrix(value,rect,matrix); 
% Accepts a Psychtoolbox rect [left, top, right, bottom] and an image
% matrix, and fills the pixels specified by the rect with the specified
% value. The value and image must have same depth: 1 (monochrome) or 3
% (color). See also RectOfMatrix, RectHeight, RectWidth, PsychRects. Any
% extent of the rect beyond the matrix is ignored.

% 7/1/15 dgp Wrote it.
% 3/21/18 dgp extended to handle color images.
assert(size(value,1)==1);
assert(size(value,2)==size(matrix,3));
assert(size(rect,1)==1 && size(rect,2)==4);
rect=ClipRect(rect,RectOfMatrix(matrix));
[rows,columns]=IndicesOfRect(rect);
for i=1:length(value)
   matrix(rows,columns,i)=value(i);
end

