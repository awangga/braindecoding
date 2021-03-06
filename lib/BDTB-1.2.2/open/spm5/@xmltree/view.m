function view(tree)
% XMLTREE/VIEW View Method
% FORMAT view(tree)
% 
% tree   - XMLTree object
%_______________________________________________________________________
%
% Display an XML tree in a graphical interface
%_______________________________________________________________________
% @(#)view.m                  Guillaume Flandin                02/04/08

error(nargchk(1,1,nargin));

%-Build the Graphical User Interface
%-----------------------------------------------------------------------
figH = findobj('Tag','mlBatchFigure'); %this tag doesn't exist so a new 
% window is created ....
if isempty(figH)
	h = xmltree_build_ui;
	figH = h.fig;
else
   set(figH,'Visible','on');
   % recover all the handles
   % h = struct(...);
end
drawnow;

%-New title for the main window
%-----------------------------------------------------------------------
set(figH,'Name',['XML TreeViewer:' getfilename(tree)]);


%-Initialize batch listbox
%-----------------------------------------------------------------------
tree = set(tree,root(tree),'show',1);
builtin('set',figH,'UserData',tree);

view_ui('update',figH);

%=======================================================================
function handleStruct = xmltree_build_ui

%- Create Figure
pixfactor = 72 / get(0,'screenpixelsperinch');
%- Figure window size and position
oldRootUnits   = get(0,'Units');
set(0, 'Units', 'points');
figurePos      = get(0,'DefaultFigurePosition');
figurePos(3:4) = [560 420];
figurePos      = figurePos * pixfactor;
rootScreenSize = get(0,'ScreenSize');
if ((figurePos(1) < 1) ...
	  | (figurePos(1)+figurePos(3) > rootScreenSize(3)))
   figurePos(1) = 30;
end
set(0, 'Units', oldRootUnits);
if ((figurePos(2)+figurePos(4)+60 > rootScreenSize(4)) ...
	  | (figurePos(2) < 1))
   figurePos(2) = rootScreenSize(4) - figurePos(4) - 60;
end
%- Create Figure Window
handleStruct.fig = figure(...
	'Name','XML TreeViewer', ...
	'Units', 'points', ...
	'NumberTitle','off', ...
	'Resize','on', ...
	'Color',[0.8 0.8 0.8],...
	'Position',figurePos, ...
	'MenuBar','none', ... 
	'Tag', 'BatchFigure', ...
	'CloseRequestFcn','view_ui close');

%- Build batch listbox
batchListPos = [20 55 160 345] * pixfactor;
batchString = ' ';
handleStruct.batchList = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'listbox', ...
	'HorizontalAlignment','left', ...
	'Units','points', ...
	'Visible','on',...
	'BackgroundColor', [1 1 1], ...
	'Max', 1, ...
	'Value', 1 , ...
	'Enable', 'on', ...
	'Position', batchListPos, ...
	'Callback', 'view_ui batchlist', ...
	'String', batchString, ...
	'Tag', 'BatchListbox');

%- Build About listbox
aboutListPos = [200 220 340 180] * pixfactor;
aboutString = ' ';
handleStruct.aboutList = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'list', ...
	'HorizontalAlignment','left', ...
	'Units','points', ...
	'Visible','on',...
	'BackgroundColor', [0.8 0.8 0.8], ...
	'Min', 0, ...
	'Max', 2, ...
	'Value', [], ...
	'Enable', 'inactive', ...
	'Position', aboutListPos, ...
	'Callback', '', ...
	'String', aboutString, ...
	'Tag', 'AboutListbox');

%- The Add button
addBtnPos = [20 20 70 25] * pixfactor;
handleStruct.add = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', addBtnPos, ...
	'String', 'Add', ...
   'Visible', 'on', ...
   'Enable','on',...
	'Tag', 'Add', ...
	'Callback', 'view_ui add');
	%'TooltipString', 'Add batch', ...
   
%- The modify button
modifyBtnPos = [95 20 70 25] * pixfactor;
handleStruct.modify = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', modifyBtnPos, ...
	'String', 'Modify', ...
   'Visible', 'on', ...
   'Enable','on',...
	'Tag', 'Modify', ...
	'Callback', 'view_ui modify');
	%'TooltipString', 'Modify batch', ...

%- The Copy button
copyBtnPos = [170 20 70 25] * pixfactor;
handleStruct.copy = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', copyBtnPos, ...
	'String', 'Copy', ...
   'Visible', 'on', ...
   'Enable','on',...
	'Tag', 'Copy', ...
	'Callback', 'view_ui copy');
	%'TooltipString', 'Copy batch', ...

%- The delete button
deleteBtnPos = [245 20 70 25] * pixfactor;
handleStruct.delete = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', deleteBtnPos, ...
	'String', 'Delete', ...
   'Visible', 'on', ...
   'Enable','on',...
	'Tag', 'Delete', ...
	'Callback', 'view_ui delete');
	%'TooltipString', 'Delete batch', ...

%- The save button
saveBtnPos = [320 20 70 25] * pixfactor;
handleStruct.save = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', saveBtnPos, ...
	'String', 'Save', ...
   'Visible', 'on', ...
   'UserData',0,...
	'Tag', 'Save', ...
	'Callback', 'view_ui save');
	%'TooltipString', 'Save batch', ...

%- The run button  
runBtnPos = [395 20 70 25] * pixfactor;
handleStruct.run = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', runBtnPos, ...
	'String', 'Run', ...
	'Visible', 'on', ...
	'Enable', 'on', ...
	'Tag', 'Run', ...
	'Callback', 'view_ui run');
	%'TooltipString', 'Run batch', ...

%- The close button
closeBtnPos = [470 20 70 25] * pixfactor;
handleStruct.close = uicontrol( ...
	'Parent',handleStruct.fig, ...
	'Style', 'pushbutton', ...
	'Units', 'points', ...
	'Position', closeBtnPos, ...
	'String', 'Close', ...
	'Visible', 'on', ...
	'Tag', 'Close', ...
	'Callback', 'view_ui close');
	%'TooltipString', 'Close window', ...

handleArray = [handleStruct.fig handleStruct.batchList handleStruct.aboutList handleStruct.add handleStruct.modify handleStruct.copy handleStruct.delete handleStruct.save handleStruct.run handleStruct.close];

set(handleArray,'Units', 'normalized');
