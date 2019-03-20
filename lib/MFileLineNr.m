function line = MFileLineNr()
% line=MFileLineNr;
% MFILELINENR returns the current linenumber
    Stack  = dbstack;
    line = Stack(2).line;   % the line number of the calling function
end

% Downloaded from MATLAB Central in November 2015
% http://www.mathworks.com/matlabcentral/fileexchange/26262-mfilelinenr