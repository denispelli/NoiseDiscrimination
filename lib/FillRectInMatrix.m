function matrix=FillRectInMatrix(value,rect,matrix)
% matrix=FillRectInMatrix(value,rect,matrix); 
% Accepts a Psychtoolbox rect [left, top, right, bottom] and matrix, and
% fills the pixels specified by the rect with the specified value. See also
% RectOfMatrix, RectHeight, RectWidth, PsychRects.
% Any extent of the rect beyond the matrix is ignored.

% 7/1/15 dgp Wrote it.
assert(size(value,1)==1 && size(value,2)==1);
assert(size(rect,1)==1 && size(rect,2)==4);
rect=ClipRect(rect,RectOfMatrix(matrix));
[rows,columns]=IndicesOfRect(rect);
matrix(rows,columns)=value;
