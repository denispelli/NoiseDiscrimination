function x=PsychRandSample2(list,dims)
% x=PsychRandSample2(list,[dims])
%
% Returns a random sample from a list. The optional second argument may be
% used to request an array (of size dims) of independent samples. E.g.
% PsychRandSample2(-1:1,[10,10]) returns a 10x10 array of samples from the
% list -1:1.  PsychRandSample2 is a quick way to generate samples (e.g.
% visual noise) from a bounded Gaussian distribution. Also see RAND, RANDN,
% randi, Sample, and Shuffle.
%
% "list" can be a double, char, cell, or struct array (e.g. of strings),
% but it must be a vector (1xn or nx1). In the future, we may accept
% matrices (mxn) and treat columns separately, as many standard MATLAB
% functions do.
%
% By default MATLAB uses the 'Twister' random number generator when we call
% randi. The 'simdTwister' generator runs 3 to 4 times faster.
% rng(seed,'simdTwister');

% Denis Pelli 7/22/97 3/24/98
% 8/14/99 dgp Renamed from "Rands" (which conflicts with Neural Net
% Toolbox) to "RandSample".
% 6/22/02 dgp Fixed bug. The shape specified by dims was being lost in the
% table-lookup through "list". I was asking for 256x1 and getting 1x256.
% Now fixed.
% 7/24/04 awi Cosmetic.
% 12/13/04 dgp & kat Enhanced to support cell arrays.
% 1/22/2012 dgp renamed from RandSample to PsychRandSample2 to avoid
% conflict with new MATLAB function.
% 5/10/18 dgp Simplified the code. It might be faster too. The runtime of
% the two active lines are similar. I discovered that the last line works
% for cell lists as well as number lists.
% 4/24/20 dgp Added special case code to speed up binary and ternary noise.
% Also discovered that rng(see,'simdTwister') makes randi twice as fast as
% the default 'Twister'.

if nargin<1 || nargin>2 || min(size(list))~=1
    error('Usage: x=PsychRandSample2(list,[dims])')
end
if nargin==1
    dims=[1 1];
end
% Generate random indices.
ii=randi(length(list),dims);
% Next we use the indices to look up values in list.
% x=list(i);
% That line of code works, but, if possible, we use a shortcut to get the
% same answer much more quickly. Our shorcut works for any equally spaced
% discrete distribution (including our binary and ternary noise), gives the
% same result as list(i), but much more quickly.

% The speedup substitutes a linear transformation (an add and a divide
% applied to the whole matrix at once) for a table lookup. It works for any
% list that, once ordered, has a consistent step size.
if isfloat(list)
    % The lists that can't be sped up can be very long, so try to reject
    % the speedup (due to nonuniform sample spacing) without having to
    % process the whole list.
    shortList=list(1:min(3,length(list)));
    if length(unique(diff(sort(shortList))))==1
        list=sort(list);
        d=unique(diff(list));
        if length(d)==1
            % Equally spaced discrete distribution.
            m=mean(list([1 end]));
            mi=mean([1 length(list)]);
            x=(ii-(mi+m/d))*d;
            return
        end
    end
end
x=list(ii);
