function machine=IdentifyComputer(windowOrScreen)
% machine=IdentifyComputer([windowOrScreen]);
% Returns a struct with ten text fields (plus screen number and size) that
% specify the basic configuration of your hardware and software. The openGL
% fields refer to the screen with the number specified by the screen field.
% Use windowOrScreen to provide a window pointer or the screen number.
% Default is screen 0, the main screen. This routine is quick if
% windowOrScreen is empty [] or points to a window; it's slow if you
% provide a screen number (or use the default screen 0) because then it has
% to open and close a window, which may take 30 s. Passing an empty
% windowOrScreen skips opening a window, at the cost of leaving the screen
% size and openGL fields empty.
%
% Here are several examples of the output struct for macOS and Windows:
%
%                    model: 'MacBook10,1'
%         modelDescription: 'MacBook (Retina, 12-inch, 2017)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
% psychtoolboxKernelDriver: ''
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%                   screen: 0
%                     size: [1440 2304]
%           openGLRenderer: 'Intel(R) HD Graphics 615'
%             openGLVendor: 'Intel Inc.'
%            openGLVersion: '2.1 INTEL-12.10.12'
%
%                    model: 'MacBookPro11,5'
%         modelDescription: 'MacBook Pro (Retina, 15-inch, Mid 2015)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%                   matlab: 'MATLAB 9.4 (R2018a)'
%                   system: 'macOS 10.14.6'
%                   screen: 0
%                     size: [? ?]
%           openGLRenderer: 'AMD Radeon R9 M370X OpenGL Engine'
%             openGLVendor: 'ATI Technologies Inc.'
%            openGLVersion: '2.1 ATI-2.11.20'
%
%                    model: 'MacBookPro13,2'
%         modelDescription: 'MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.15'
% psychtoolboxKernelDriver: ''
%                   matlab: 'MATLAB 9.5 (R2018b)'
%                   system: 'macOS 10.14.5'
%                   screen: 0
%                     size: [? ?]
%           openGLRenderer: 'Intel(R) Iris(TM) Graphics 550'
%             openGLVendor: 'Intel Inc.'
%            openGLVersion: '2.1 INTEL-12.9.22?
%
%                    model: 'Inspiron 5379'
%         modelDescription: ''
%             manufacturer: 'Dell Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
% psychtoolboxKernelDriver: ''
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'Windows NT-10.0.9200'
%
% Unavailable answers are empty ''.
%
% This is handy in testing, benchmarking, and bug reporting, to easily
% record the test environment in a compact human-readable way.
%
% If you are trying to produce a compact string, e.g. to use in a file
% name, you might do something like this:
% machine=IdentifyComputer([]);
% filename=['TestFlip-' machine.model ...
%     '-' machine.system ...
%     '-' machine.psychtoolbox '.png'];
% filename=strrep(filename,'Windows','Win');
% filename=strrep(filename,'Psychtoolbox','Psy');
% filename=strrep(filename,' ','-');
% Which produces a string like this:
% TestFlip-MacBook10,1-macOS-10.14.6-Psy-3.0.16.png
%
% In principle one might want to separately report each screen, but in
% practice there's typically no point in doing that. In the old days one
% could plug in arbitrary video cards and have different drivers for each
% screen. Today, most of us use computers with no slots. At most we plug in
% a cable connected to an external display and thus use the same video
% driver as the built-in display (screen 0). Thus some properties, e.g.
% resolution and frame rate, might differ, but not the information we
% report here. If it becomes useful to report screen-dependent information
% we could drop the screen field, and change each of the screen-dependent
% fields to be a cell array.
%
% September 1, 2019, denis.pelli@nyu.edu
%
% LIMITATIONS: Works on all OSes, but on Linux doesn't yet get model name
% or manufacturer.

%% HISTORY
% August 24, 2019. DGP wrote it as a subroutine for TestFlip.m
% August 25, 2019. DGP fixed bug that bypassed most of the cleanup of
%                  machine.system.
% August 27, 2019. DGP use macOS Terminal only if it is running the bash
%                  or zsh shell. Reduce dependence on Psychtoolbox.
% September 13, 2019. DGP debugged code to detect PsychtoolboxKernelDriver.
%                  Renamed the openGL fields to more closely correspond to
%                  the names in windowInfo.
% September 24, 2019. DGP added "size" specifying the screen resolution.
% October 14, 2019. Omkar added linux code for model identification
if nargin<1
    windowOrScreen=0;
end
machine.model='';
machine.modelDescription=''; % Currently non-empty only for macOS.
machine.manufacturer='';
machine.psychtoolbox='';
machine.psychtoolboxKernelDriver='';
machine.matlab='';
machine.system='';
machine.screen=0;
machine.size=[];
resolution=Screen('Resolution',windowOrScreen);
machine.size=[resolution.height resolution.width];
machine.openGLRenderer='';
machine.openGLVendor='';
machine.openGLVersion='';
if exist('PsychtoolboxVersion','file')
    [~,p]=PsychtoolboxVersion;
    machine.psychtoolbox=sprintf('Psychtoolbox %d.%d.%d',p.major,p.minor,p.point);
end
if exist('ver','file')
    m=ver('octave');
    if isempty(m)
        m=ver('matlab');
        if isempty(m)
            error('The language must be MATLAB or Octave.');
        end
    end
    machine.matlab=sprintf('%s %s %s',m.Name,m.Version,m.Release);
else
    warn('MATLAB/OCTAVE too old (pre 2006) to have "ver" command.');
end
if exist('Screen','file')
    c=Screen('Computer');
    machine.system=c.system;
    if isfield(c,'hw') && isfield(c.hw,'model')
        machine.model=c.hw.model;
    end
else
    warn('Currently need Psychtoolbox to get operating system name.');
end
switch computer
    %% macOS
    case 'MACI64'
        machine.manufacturer='Apple Inc.';
        % https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        % Whatever shell is running, we maintain compatibility by sending
        % each script to the bash shell.
        serialNumber=evalc('!bash -c ''system_profiler SPHardwareDataType'' | awk ''/Serial/ {print $4}''');
        report=evalc(['!bash -c ''curl -s https://support-sp.apple.com/sp/product?cc=' serialNumber(9:end-1) '''']);
        x=regexp(report,'<configCode>(?<modelDescription>.*)</configCode>','names');
        machine.modelDescription=x.modelDescription;
        s=machine.modelDescription;
        if length(s)<3 || ~all(isstrprop(s(1:3),'alpha'))
            machine
            shell=evalc('!echo $0') % name of current shell.
            warning(['Oops. Failed in getting modelDescription. '...
                'Please send the lines above to denis.pelli@nyu.edu: "%s"'],s);
            machine.modelDescription='';
            % http://osxdaily.com/2007/02/27/how-to-change-from-bash-to-tcsh-shell/
            % https://support.apple.com/en-us/HT208050
        end
        % A python solution: https://gist.github.com/zigg/6174270
        
    %% Windows
    case 'PCWIN64'
        wmicString = evalc('!wmic computersystem get manufacturer, model');
        % Here's a typical result:
        % wmicString=sprintf(['    ''Manufacturer  Model            \n'...
        % '     Dell Inc.     Inspiron 5379    ']);
        s=strrep(wmicString,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        s=regexprep(s,'  +',char(9)); % Change run of 2+ spaces to a tab.
        s=strrep(s,'''',''); % Remove stray quote.
        fields=split(s,char(9)); % Use tabs to split into tokens.
        fields=fields(~ismissing(fields)); % Discard empty fields.
        % The original had two columns: category and value. We've now got
        % one long column with n categories followed by n values. We asked
        % for manufacturer and model so n should be 2.
        if length(fields)==4
            n=length(fields)/2; % n names followed by n values.
            for i=1:n
                % Grab each field's name and value.
                % Lowercase name.
                fields{i}(1)=lower(fields{i}(1));
                machine.(fields{i})=fields{i+n};
            end
        end
        if ~isfield(machine,'manufacturer') || isempty(machine.manufacturer)...
                || ~isfield(machine,'model') || isempty(machine.model)
            wmicString
            warning('Failed to retrieve manufacturer and model from WMIC.');
        end
        
    %% Linux
    case 'GLNXA64'
        % lshw command is used for listing hardware information on Linux
        % systems. This snippet is tested on Ubuntu 18.04 system.
        [status,std_out] = system("lshw -C system -json");
        % Use regexp to get the start of json information
        start_index = regexp(std_out,"{\s{0,}");
        % convert std_out string into a dictionary 
        % jsonified structure of lshw output looks like:
        % '{
        % .
        % "description" : "Notebook",
        % "product" : "80WK (LENOVO_MT_80WK_BU_idea_FM_Lenovo Y520-15IKBN)",
        % "vendor" : "LENOVO",
        % "version" : "Lenovo Y520-15IKBN",
        % "serial" : "PF0U17J8",
        % "width" : 64,
        % .
        % .
        jsonified_description = std_out(start_index(1):end);
        % convert json string into a matlab compatible struct form
        description_struct = jsondecode(jsonified_description);
        % assign values from description to machine
        machine.manufacturer = description_struct.vendor;
        machine.model = description_struct.product;
        % failure handlingmodel
        if ~isfield(machine,'manufacturer') || isempty(machine.manufacturer)...
                || ~isfield(machine,'model') || isempty(machine.model)
            warning('Failed to retrieve manufacturer and model from lshw.');
        end
        

end
% Clean up the Operating System name.
while ismember(machine.system(1),{' ' '-'})
    % Strip leading separators.
    if length(machine.system)>1
        machine.system=machine.system(2:end);
    else
        machine.system='';
    end
end
while ismember(machine.system(end),{' ' '-'})
    % Strip trailing separators.
    if length(machine.system)>1
        machine.system=machine.system(1:end-1);
    else
        machine.system='';
    end
end
% Modernize spelling.
machine.system=strrep(machine.system,'Mac OS','macOS');
if IsWin
    % Prepend "Windows".
    if ~all('win'==lower(machine.system(1:3)))
        machine.system=['Windows ' machine.system];
    end
end

%% PSYCHTOOLBOX KERNEL DRIVER
% http://psychtoolbox.org/docs/psychtoolboxKernelDriver';
machine.psychtoolboxKernelDriver='';
if ismac
    [~,result]=system('kextstat -l -b PsychtoolboxKernelDriver');
    if contains(result,'PsychtoolboxKernelDriver')
        % Get version number of Psychtoolbox kernel driver.
        v=regexp(result,'(?<=\().*(?=\))','match'); % find (version)
        if ~isempty(v)
            v=v{1};
        else
            v='';
            warning('Failed to get version of PsychtoolboxKernelDriver.');
        end
        machine.psychtoolboxKernelDriver=['PsychtoolboxKernelDriver ' v];
    end
end

%% OpenGL DRIVER
% Mario Kleiner suggests (1.9.2019) identifying the gpu hardware and driver
% by the combination of GLRenderer, GLVendor, and GLVersion, which are
% provided by info=Screen('GetWindowInfo',window);

% From the provided windowOrScreen we get a window and screen.
window=[];
if ismember(windowOrScreen,Screen('Screens'))
    % It's a screen. Open a window on it.
    machine.screen=windowOrScreen;
    % Opening and closing a window takes a long time, on the order of 30 s,
    % so you may want to skip it if you don't need the openGL fields.
    fractionOfScreenUsed=0.2;
    screenBufferRect=Screen('Rect',machine.screen);
    r=round(fractionOfScreenUsed*screenBufferRect);
    r=AlignRect(r,screenBufferRect,'right','bottom');
    verbosity=Screen('Preference','Verbosity',0);
    try
        window=Screen('OpenWindow',machine.screen,255,r);
    catch e
        warning(e.message);
        warning('Unable to open window on screen %d.',machine.screen);
    end
    Screen('Preference','Verbosity',verbosity);
elseif Screen('WindowKind',windowOrScreen)==1
    % It's a window pointer. Get the screen number.
    machine.screen=Screen('WindowScreenNumber',windowOrScreen);
    if ~ismember(machine.screen,Screen('Screens'))
        % This occurred only with an experimental version of Screen.
        error('Could not get screen number of window.');
    end
else
    if ~isempty(windowOrScreen)
        error('Illegal windowOrScreen=%.0f, should be a window pointer, a screen number, or empty.',windowOrScreen);
    end
end
if ~isempty(window)
    info=Screen('GetWindowInfo',window);
    machine.openGLRenderer=info.GLRenderer;
    machine.openGLVendor=info.GLVendor;
    machine.openGLVersion=info.GLVersion;
    if windowOrScreen==machine.screen
        % If we opened the window, then close it.
        Screen('Close',window);
    end
else
    machine.screen=[];
end
end % function
