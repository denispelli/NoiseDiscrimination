function Answer=inputdlg2(Prompt, Title, NumLines, DefAns, Resize, argName, argValue)
% Original inputdlg provided by Mathworks in MATLAB R2018a. This modified
% version allows you to add two arguments, an argument name and value, e.g.
% 'FontSize',12. That's the only argument name I need so that's all I
% added. There are two trivial MATLAB private functions --
% getnicedialoglocation and setdefaultbutton -- that we can't call, though
% we can read their sources. So I commented out those calls. I also
% suppressed the Cancel button, because I don't need it. I marked all my
% changes with "% DGP". The original remains property of Mathworks, and
% this modified version is provided solely for use by licensed users of
% MATLAB. I don't claim any rights to the original inputdlg or my
% modifications.
% denis.pelli@nyu.edu July, 2019.
% Suggested by Jan MVP. 
% https://www.mathworks.com/matlabcentral/answers/15434-change-font-size-and-window-size
%
%INPUTDLG Input dialog box.
%  ANSWER = INPUTDLG(PROMPT) creates a modal dialog box that returns user
%  input for multiple prompts in the cell array ANSWER. PROMPT is a cell
%  array containing the PROMPT strings.
%
%  INPUTDLG uses UIWAIT to suspend execution until the user responds.
%
%  ANSWER = INPUTDLG(PROMPT,NAME) specifies the title for the dialog.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES) specifies the number of lines for
%  each answer in NUMLINES. NUMLINES may be a constant value or a column
%  vector having one element per PROMPT that specifies how many lines per
%  input field. NUMLINES may also be a matrix where the first column
%  specifies how many rows for the input field and the second column
%  specifies how many columns wide the input field should be.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER) specifies the
%  default answer to display for each PROMPT. DEFAULTANSWER must contain
%  the same number of elements as PROMPT and must be a cell array of
%  strings.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER,OPTIONS) specifies
%  additional options. If OPTIONS is the string 'on', the dialog is made
%  resizable. If OPTIONS is a structure, the fields Resize, WindowStyle, and
%  Interpreter are recognized. Resize can be either 'on' or
%  'off'. WindowStyle can be either 'normal' or 'modal'. Interpreter can be
%  either 'none' or 'tex'. If Interpreter is 'tex', the prompt strings are
%  rendered using LaTeX.
%
%  Examples:
%
%  prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
%  name='Input for Peaks function';
%  numlines=1;
%  defaultanswer={'20','hsv'};
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer);
%
%  options.Resize='on';
%  options.WindowStyle='normal';
%  options.Interpreter='tex';
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer,options);
%
%  See also DIALOG, ERRORDLG, HELPDLG, LISTDLG, MSGBOX,
%    QUESTDLG, TEXTWRAP, UIWAIT, WARNDLG .

%  Copyright 1994-2017 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
narginchk(0,7); % DGP
nargoutchk(0,1);

if nargin > 0
    Prompt = convertStringsToChars(Prompt);
end

if nargin > 1
    Title = convertStringsToChars(Title);
end

if nargin > 3
    if isstring(DefAns)
        DefAns = cellstr(DefAns);
    end
end

if nargin > 4
    Resize = convertStringsToChars(Resize);
end

if nargin==6 % DGP
    error('The optional argName and argValue are a pair, and, if used, must both be present.');
end
if nargin>6 % DGP
    if ~ischar(argName)
        error('argName must be a char string.');
    end
    switch argName
        case 'FontSize'
            if ~isfloat(argValue)
                error('argValue must be a positive number.');
            end
        otherwise
            error('argName "%s" not yet supported.',argName);
    end
else
    argName='';
end
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Handle Input Args %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1
  Prompt=getString(message('MATLAB:uistring:popupdialogs:InputDlgInput'));
end
if ~iscell(Prompt)
  Prompt={Prompt};
end
NumQuest=numel(Prompt);


if nargin<2
  Title=' ';
end

if nargin<3
  NumLines=1;
end

if nargin<4
  DefAns=cell(NumQuest,1);
  for lp=1:NumQuest
    DefAns{lp}='';
  end
end

if nargin<5
  Resize = 'off';
end
WindowStyle='modal';
Interpreter='none';

Options = struct([]); %#ok
if nargin==5 && isstruct(Resize)
  Options = Resize;
  Resize  = 'off';
  if isfield(Options,'Resize'),      Resize=Options.Resize;           end
  if isfield(Options,'WindowStyle'), WindowStyle=Options.WindowStyle; end
  if isfield(Options,'Interpreter'), Interpreter=Options.Interpreter; end
end

[rw,cl]=size(NumLines);
OneVect = ones(NumQuest,1);
if (rw == 1 & cl == 2) %#ok Handle []
  NumLines=NumLines(OneVect,:);
elseif (rw == 1 & cl == 1) %#ok
  NumLines=NumLines(OneVect);
elseif (rw == 1 & cl == NumQuest) %#ok
  NumLines = NumLines';
elseif (rw ~= NumQuest | cl > 2) %#ok
  error(message('MATLAB:inputdlg:IncorrectSize'))
end

if ~iscell(DefAns)
  error(message('MATLAB:inputdlg:InvalidDefaultAnswer'));
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create InputFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigWidth=175;
FigHeight=100;
FigPos(3:4)=[FigWidth FigHeight];  %#ok
FigColor=get(0,'DefaultUicontrolBackgroundColor');

InputFig=dialog(                     ...
  'Visible'          ,'off'      , ...
  'KeyPressFcn'      ,@doFigureKeyPress, ...
  'Name'             ,Title      , ...
  'Pointer'          ,'arrow'    , ...
  'Units'            ,'pixels'   , ...
  'UserData'         ,'Cancel'   , ...
  'Tag'              ,Title      , ...
  'HandleVisibility' ,'callback' , ...
  'Color'            ,FigColor   , ...
  'NextPlot'         ,'add'      , ...
  'WindowStyle'      ,WindowStyle, ...
  'Resize'           ,Resize       ...
  );


%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefOffset    = 5;
DefBtnWidth  = 53;
DefBtnHeight = 23;

TextInfo.Units              = 'pixels'   ;
TextInfo.FontSize           = get(0,'FactoryUicontrolFontSize');
TextInfo.FontWeight         = get(InputFig,'DefaultTextFontWeight');
TextInfo.HorizontalAlignment= 'left'     ;
TextInfo.HandleVisibility   = 'callback' ;
switch argName % DGP
    case 'FontSize'
        TextInfo.FontSize=argValue;
end
StInfo=TextInfo;
StInfo.Style              = 'text'  ;
StInfo.BackgroundColor    = FigColor;


EdInfo=StInfo;
EdInfo.FontWeight      = get(InputFig,'DefaultUicontrolFontWeight');
EdInfo.Style           = 'edit';
EdInfo.BackgroundColor = 'white';

BtnInfo=StInfo;
BtnInfo.FontWeight          = get(InputFig,'DefaultUicontrolFontWeight');
BtnInfo.Style               = 'pushbutton';
BtnInfo.HorizontalAlignment = 'center';

% Add VerticalAlignment here as it is not applicable to the above.
TextInfo.VerticalAlignment  = 'bottom';
TextInfo.Color              = get(0,'FactoryUicontrolForegroundColor');

% adjust button height and width
btnMargin=1.4;
ExtControl=uicontrol(InputFig   ,BtnInfo     , ...
  'String'   ,getString(message('MATLAB:uistring:popupdialogs:Cancel'))        , ...
  'Visible'  ,'off'         ...
  );

% BtnYOffset  = DefOffset;
BtnExtent = get(ExtControl,'Extent');
BtnWidth  = max(DefBtnWidth,BtnExtent(3)+8);
BtnHeight = max(DefBtnHeight,BtnExtent(4)*btnMargin);
delete(ExtControl);

% Determine # of lines for all Prompts
TxtWidth=FigWidth-2*DefOffset;
ExtControl=uicontrol(InputFig   ,StInfo     , ...
  'String'   ,''         , ...
  'Position' ,[ DefOffset DefOffset 0.96*TxtWidth BtnHeight ] , ...
  'Visible'  ,'off'        ...
  );

WrapQuest=cell(NumQuest,1);
QuestPos=zeros(NumQuest,4);

for ExtLp=1:NumQuest
  if size(NumLines,2)==2
    [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
      textwrap(ExtControl,Prompt(ExtLp),NumLines(ExtLp,2));
  else
    [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
      textwrap(ExtControl,Prompt(ExtLp),80);
  end
end % for ExtLp

delete(ExtControl);
QuestWidth =QuestPos(:,3);
QuestHeight=QuestPos(:,4);
if ismac % Change Edit box height to avoid clipping on mac.
    editBoxHeightScalingFactor = 1.4;
else 
    editBoxHeightScalingFactor = 1;
end
TxtHeight=QuestHeight(1)/size(WrapQuest{1,1},1) * editBoxHeightScalingFactor;
EditHeight=TxtHeight*NumLines(:,1);
EditHeight(NumLines(:,1)==1)=EditHeight(NumLines(:,1)==1)+4;

FigHeight=(NumQuest+2)*DefOffset    + ...
  BtnHeight+sum(EditHeight) + ...
  sum(QuestHeight);

TxtXOffset=DefOffset;

QuestYOffset=zeros(NumQuest,1);
EditYOffset=zeros(NumQuest,1);
QuestYOffset(1)=FigHeight-DefOffset-QuestHeight(1);
EditYOffset(1)=QuestYOffset(1)-EditHeight(1);

for YOffLp=2:NumQuest
  QuestYOffset(YOffLp)=EditYOffset(YOffLp-1)-QuestHeight(YOffLp)-DefOffset;
  EditYOffset(YOffLp)=QuestYOffset(YOffLp)-EditHeight(YOffLp);
end % for YOffLp

QuestHandle=[];
EditHandle=[];

AxesHandle=axes('Parent',InputFig,'Position',[0 0 1 1],'Visible','off');

inputWidthSpecified = false;

for lp=1:NumQuest
  if ~ischar(DefAns{lp})
    delete(InputFig);
    error(message('MATLAB:inputdlg:InvalidInput'));
  end

  
  EditHandle(lp)=uicontrol(InputFig    , ...
    EdInfo      , ...
    'Max'        ,NumLines(lp,1)       , ...
    'Position'   ,[ TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp)], ...
    'String'     ,DefAns{lp}           , ...
    'Tag'        ,'Edit'                 ...
    );

  QuestHandle(lp)=text('Parent'     ,AxesHandle, ...
    TextInfo     , ...
    'Position'   ,[ TxtXOffset QuestYOffset(lp)], ...
    'String'     ,WrapQuest{lp}                 , ...
    'Interpreter',Interpreter                   , ...
    'Tag'        ,'Quest'                         ...
    );

  MinWidth = max(QuestWidth(:));
  if (size(NumLines,2) == 2)
    % input field width has been specified.
    inputWidthSpecified = true;
    EditWidth = setcolumnwidth(EditHandle(lp), NumLines(lp,1), NumLines(lp,2));
    MinWidth = max(MinWidth, EditWidth);
  end
  % Get the extent of the text object. See g1008152
  questExtent = get(QuestHandle(lp), 'Extent');
  MinWidth = max(MinWidth, questExtent(3));  
  FigWidth=max(FigWidth, MinWidth+2*DefOffset);

end % for lp

% fig width may have changed, update the edit fields if they dont have user specified widths.
if ~inputWidthSpecified
  TxtWidth=FigWidth-2*DefOffset;
  for lp=1:NumQuest
    set(EditHandle(lp), 'Position', [TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp)]);
  end
end

FigPos=get(InputFig,'Position');

FigWidth=max(FigWidth,2*(BtnWidth+DefOffset)+DefOffset);
FigPos(1)=0;
FigPos(2)=0;
FigPos(3)=FigWidth;
FigPos(4)=FigHeight;

% set(InputFig,'Position',getnicedialoglocation(FigPos,get(InputFig,'Units')));
set(InputFig,'Position',[100 200 500 200]); % DGP

OKHandle=uicontrol(InputFig     ,              ...
  BtnInfo      , ...
  'Position'   ,[ FigWidth-2*BtnWidth-2*DefOffset DefOffset BtnWidth BtnHeight ] , ...
  'KeyPressFcn',@doControlKeyPress , ...
  'String'     ,getString(message('MATLAB:uistring:popupdialogs:OK'))        , ...
  'Callback'   ,@doCallback , ...
  'Tag'        ,'OK'        , ...
  'UserData'   ,'OK'          ...
  );

%setdefaultbutton(InputFig, OKHandle); % DGP
if false % DGP
CancelHandle=uicontrol(InputFig     ,              ...
  BtnInfo      , ...
  'Position'   ,[ FigWidth-BtnWidth-DefOffset DefOffset BtnWidth BtnHeight ]           , ...
  'KeyPressFcn',@doControlKeyPress            , ...
  'String'     ,getString(message('MATLAB:uistring:popupdialogs:Cancel'))    , ...
  'Callback'   ,@doCallback , ...
  'Tag'        ,'Cancel'    , ...
  'UserData'   ,'Cancel'       ...
  ); %#ok
end

handles = guihandles(InputFig);
handles.MinFigWidth = FigWidth;
handles.FigHeight   = FigHeight;
handles.TextMargin  = 2*DefOffset;
guidata(InputFig,handles);
set(InputFig,'ResizeFcn', {@doResize, inputWidthSpecified});

% make sure we are on screen
movegui(InputFig)

% if there is a figure out there and it's modal, we need to be modal too
if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
  set(InputFig,'WindowStyle','modal');
end

set(InputFig,'Visible','on');
drawnow;

if ~isempty(EditHandle)
  uicontrol(EditHandle(1));
end

if ishghandle(InputFig)
  % Go into uiwait if the figure handle is still valid.
  % This is mostly the case during regular use.
  c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
  uiwait(InputFig);
  delete(c);
end

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
if ishghandle(InputFig)
  Answer={};
  if strcmp(get(InputFig,'UserData'),'OK')
    Answer=cell(NumQuest,1);
    for lp=1:NumQuest
      Answer(lp)=get(EditHandle(lp),{'String'});
    end
  end
  delete(InputFig);
else
  Answer={};
end
drawnow; % Update the view to remove the closed figure (g1031998)

function doFigureKeyPress(obj, evd) %#ok
switch(evd.Key)
  case {'return','space'}
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
  case {'escape'}
    delete(gcbf);
end

function doControlKeyPress(obj, evd)
switch(evd.Key)
  case {'return'}
    if ~strcmp(get(obj,'UserData'),'Cancel')
      set(gcbf,'UserData','OK');
      uiresume(gcbf);
    else
      delete(gcbf)
    end
  case 'escape'
    delete(gcbf)
end

function doCallback(obj, evd) %#ok
if ~strcmp(get(obj,'UserData'),'Cancel')
  set(gcbf,'UserData','OK');
  uiresume(gcbf);
else
  delete(gcbf)
end

function doResize(FigHandle, evd, multicolumn) %#ok
% TBD: Check difference in behavior w/ R13. May need to implement
% additional resize behavior/clean up.

Data=guidata(FigHandle);

resetPos = false;

FigPos = get(FigHandle,'Position');
FigWidth = FigPos(3);
FigHeight = FigPos(4);

% the current and the target sizes are considered equal
% if the difference is less then 1 pixel
% (Position property values can be doubles due to other units,
%  and the non integer values show up due to conversions/round offs)
widthDiff = Data.MinFigWidth - FigWidth;
if widthDiff >= 1
  FigWidth  = Data.MinFigWidth;
  FigPos(3) = Data.MinFigWidth;
  resetPos = true;
end

% make sure edit fields use all available space if
% number of columns is not specified in dialog creation.
if ~multicolumn
  for lp = 1:length(Data.Edit)
    EditPos = get(Data.Edit(lp),'Position');
    EditPos(3) = FigWidth - Data.TextMargin;
    set(Data.Edit(lp),'Position',EditPos);
  end
end


% the current and the target sizes are considered equal
% if the difference is less then 1 pixel
% (Position property values can be doubles due to other units,
%  and the non integer values show up due to conversions/round offs)
heightDiff = abs(FigHeight - Data.FigHeight);
if heightDiff >= 1
  FigPos(4) = Data.FigHeight;
  resetPos = true;
end

if resetPos
  set(FigHandle,'Position',FigPos);
end


% set pixel width given the number of columns
function EditWidth = setcolumnwidth(object, rows, cols)
% Save current Units and String.
old_units = get(object, 'Units');
old_string = get(object, 'String');
old_position = get(object, 'Position');

set(object, 'Units', 'pixels')
set(object, 'String', char(ones(1,cols)*'x'));

new_extent = get(object,'Extent');
if (rows > 1)
  % For multiple rows, allow space for the scrollbar
  new_extent = new_extent + 19; % Width of the scrollbar
end
new_position = old_position;
new_position(3) = new_extent(3) + 1;
set(object, 'Position', new_position);

% reset string and units
set(object, 'String', old_string, 'Units', old_units);

EditWidth = new_extent(3);
