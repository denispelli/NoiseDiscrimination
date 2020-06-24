function creationDatenum=GetFileCreationDatenum(filePath)
% creationDatenum=GetFileCreationDatenum(filePath);
% Try to get the file's creation date.
% 2019, denis.pelli@nyu.edu
ismacos=ismac;
iswin=ispc;
if exist('PsychtoolboxVersion','file')
    islinux=IsLinux;
else
    % MATLAB recommends calling "contains" instead of "~isempty(strfind(",
    % but it's not available in Octave.
    islinux=ismember(computer,{'GLNX86' 'GLNXA64'}) ...
        || ~isempty(strfind(computer,'linux-gnu'));
end
switch 4*ismacos+2*iswin+islinux
    case 4
        %% macOS
        [~,b]=system(sprintf('GetFileInfo "%s"',filePath));
        filePath=strfind(b,'created: ')+9;
        crdat=b(filePath:filePath+18);
        % In Octave, datenum fails without the explicit format.
        creationDatenum=datenum(crdat,'mm/dd/yyyy HH:MM:SS');
    case 2
        %% Windows
        % https://www.mathworks.com/matlabcentral/answers/288339-how-to-get-creation-date-of-files
        d=System.IO.File.GetCreationTime(filePath);
        % Convert the .NET DateTime d into a MATLAB datenum.
        creationDatenum=datenum(datetime(...
            d.Year,d.Month,d.Day,d.Hour,d.Minute,d.Second));
    case 1
        %% Linux
        % Alas, depending on the file system used, Linux typically does not
        % retain the creation date.
        creationDatenum='';
    otherwise
        error('Unknown OS.');
end % switch
end % function GetFileCreationDatenum

