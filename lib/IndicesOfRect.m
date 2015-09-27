function [rows, columns]=IndicesOfRect(rect)
% [rows, columns]=IndicesOfRect(rect);
% Accepts a Psychtoolbox rect [left, top, right, bottom] and returns the
% MATLAB array indices, rows and columns, of all the pixels.
% See also RectOfMatrix, RectHeight, RectWidth, PsychRects.

% 7/1/15 dgp Wrote it.
assert(size(rect,1)==1 && size(rect,2)==4);
rect=round(rect);
rows=1+rect(2):rect(4);
columns=1+rect(1):rect(3);
