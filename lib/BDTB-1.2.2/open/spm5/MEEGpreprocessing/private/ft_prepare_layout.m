function [lay] = prepare_layout(cfg, data);

% PREPARE_LAYOUT creates a 2-D layout of the channel locations. This layout
% is required for plotting the topographical distribution of the potential
% or field distribution, or for plotting timecourses in a topographical
% arrangement.
%
% Use as
%   lay = prepare_layout(cfg, data)
%
% There are several ways in which a 2-D layout can be made: it can be read
% directly from a *.lay file, it can be created based on 3-D electrode or
% gradiometer positions in the configuration or in the data, or it can be
% created based on the specification of an electrode of gradiometer file.
%
% You can specify either one of the following configuration options
%   cfg.layout      filename containg the 2-D layout
%   cfg.rotate      number, rotation around the z-axis in degrees (default = [], which means automatic)
%   cfg.projection  string, 'stereographic', 'ortographic', 'polar', 'gnomic' or 'inverse' (default = 'orthographic')
%   cfg.elec        structure with electrode positions, or
%   cfg.elecfile    filename containing electrode positions
%   cfg.grad        structure with gradiometer definition, or
%   cfg.gradfile    filename containing gradiometer definition
%
% Alternatively the layout can be constructed from either
%   data.elec     structure with electrode positions
%   data.grad     structure with gradiometer definition
%
% Alternatively, you can specify
%   cfg.layout = 'ordered' 
% which will give you a 2-D ordered layout. Note that this is only suited
% for multiplotting and not for topoplotting.
%
% See also layoutplot, topoplotER, topoplotTFR, multiplotER, multiplotTFR


% Copyright (C) 2007, Robert Oostenveld
%
% $Log: prepare_layout.m,v $
% Revision 1.6  2007/05/06 09:06:37  roboos
% implemented layout=ordered, for multiplotting only
%
% Revision 1.5  2007/03/21 15:52:30  roboos
% included the cfg.layout=lay case in the if-ladder
%
% Revision 1.4  2007/03/21 14:17:28  chrhes
% added a check to detect the (unlikely) case where cfg.layout already contains
% a valid layout (lay) structure, which is then returned as is; added a few
% comments to code; updated documentation.
%
% Revision 1.3  2007/03/20 10:41:30  roboos
% added options cfg.rotate and cfg.projection
% changed the default projection method from stereographic into orthographic
% by default rotate MEG electrode positions 90 degrees around the z-axis
% changed the default rotation for some MEG systems (now it is more explicit in
% the code)
%
% Revision 1.2  2007/03/20 09:23:23  chrhes
% small change to subfunction grad2lay which allows for MEG channel labels that
% do not have a space after the "MEG" token in the cases of neuromag122 and
% neuromag306 data
%
% Revision 1.1  2007/03/14 08:44:29  roboos
% new function that replaces private/createlayout, this new function can be used
% by end-users added support for mat files containing a lay variable, made some
% changes to the lay structure
%


% Undocumented option:
% cfg.layout can contain a lay structure which is simply returned as is


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic check/initialization of input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin<1) || (nargin>2), error('incorrect number of input arguments'); end;
if (nargin<2), data = []; end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set default configuration options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(cfg, 'rotate'),     cfg.rotate = [];                end  % [] => rotation is determined based on the type of sensors
if ~isfield(cfg, 'projection'), cfg.projection = 'ortographic'; end
if ~isfield(cfg, 'layout'),     cfg.layout = [];                end
if ~isfield(cfg, 'grad'),       cfg.grad = [];                  end
if ~isfield(cfg, 'elec'),       cfg.elec = [];                  end
if ~isfield(cfg, 'gradfile'),   cfg.gradfile = [];              end
if ~isfield(cfg, 'elecfile'),   cfg.elecfile = [];              end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try to generate the layout structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check whether cfg.layout already contains a valid layout structure (this can 
% happen when higher level plotting functions are called with cfg.layout set to 
% a lay structure)
if isstruct(cfg.layout) && all(isfield(cfg.layout, {'pos';'width';'height';'label'}))
    lay = cfg.layout;

elseif isequal(cfg.layout, 'ordered')
  nchan = length(data.label);
  ncol = ceil(sqrt(nchan))+1;
  nrow = ceil(sqrt(nchan))+1;
  k = 0;
  for i=1:nrow
  for j=1:ncol
    k = k+1;
    if k<=nchan
      x = (j-1)/ncol;
      y = (nrow-i-1)/nrow;
      lay.pos(k,:) = [x y];
      lay.width(k,1)  = 0.8 * 1/(ncol-1);
      lay.height(k,1) = 0.8 * 1/(nrow-1);
    end
  end
  end
  lay.label = data.label;
  
% 
%   lay.label{end+1}  = 'SCALE';
%   lay.width(end+1)  = mean(lay.width);
%   lay.height(end+1) = mean(lay.height);
%   x = (ncol-2)/ncol;
%   y = 1/nrow;
%   lay.pos(end+1,:) = [x y];
% 
%   lay.label{end+1}  = 'COMNT';
%   lay.width(end+1)  = mean(lay.width);
%   lay.height(end+1) = mean(lay.height);
%   x = (ncol-1)/ncol;
%   y = 1/nrow;
%   lay.pos(end+1,:) = [x y];

% elseif isstruct(cfg.layout) && all(isfield(cfg.layout, {'pnt', 'ori', 'tra', 'label'}))
%     lay = grad2lay(cfg.layout, cfg.rotate, cfg.projection);

% elseif isstruct(cfg.layout) && all(isfield(cfg.layout, {'pnt', 'tra', 'label'}))
%     lay = elec2lay(cfg.layout, cfg.rotate, cfg.projection);

% try to generate layout from other configuration options
elseif isstr(cfg.layout) && filetype(cfg.layout, 'matlab')
  fprintf('reading layout from file %s\n', cfg.layout);
  load(cfg.layout, 'lay');

elseif isstr(cfg.layout) && filetype(cfg.layout, 'layout')
  fprintf('reading layout from file %s\n', cfg.layout);
  lay = readlay(cfg.layout);

elseif isstr(cfg.layout) && ~filetype(cfg.layout, 'layout')
  % assume that cfg.layout is an electrode file
  fprintf('creating layout from electrode file %s\n', cfg.layout);
  lay = elec2lay(read_fcdc_elec(cfg.layout), cfg.rotate, cfg.projection);

elseif isstr(cfg.elecfile)
  fprintf('creating layout from electrode file %s\n', cfg.elecfile);
  lay = elec2lay(read_fcdc_elec(cfg.elecfile), cfg.rotate, cfg.projection);

elseif ~isempty(cfg.elec) && isstruct(cfg.elec)
  fprintf('creating layout from cfg.elec\n');
  lay = elec2lay(cfg.elec, cfg.rotate, cfg.projection);

elseif isfield(data, 'elec') && isstruct(data.elec)
  fprintf('creating layout from data.elec\n');
  lay = elec2lay(data.elec, cfg.rotate, cfg.projection);

elseif isstr(cfg.gradfile)
  fprintf('creating layout from gradiometer file %s\n', cfg.gradfile);
  lay = grad2lay(read_fcdc_elec(cfg.gradfile), cfg.rotate, cfg.projection);

elseif ~isempty(cfg.grad) && isstruct(cfg.grad)
  fprintf('creating layout from cfg.grad\n');
  lay = grad2lay(cfg.grad, cfg.rotate, cfg.projection);

elseif isfield(data, 'grad') && isstruct(data.grad)
  fprintf('creating layout from data.grad\n');
  lay = grad2lay(data.grad, cfg.rotate, cfg.projection);

else
  fprintf('reverting to 151 channel CTF default\n');
  lay = readlay('CTF151s.lay');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add axes positions for comments and scale information if required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if ~any(strcmp('COMNT', lay.label))
%   % add a placeholder for the comment in the upper left corner
%   lay.label{end+1}  = 'COMNT';
%   lay.width(end+1)  = mean(lay.width);
%   lay.height(end+1) = mean(lay.height);
%   X                 = min(lay.pos(:,1));
%   Y                 = max(lay.pos(:,2));
%   lay.pos(end+1,:)  = [X Y];
% end

% if ~any(strcmp('SCALE', lay.label))
%   % add a placeholder for the scale in the upper right corner
%   lay.label{end+1}  = 'SCALE';
%   lay.width(end+1)  = mean(lay.width);
%   lay.height(end+1) = mean(lay.height);
%   X                 = max(lay.pos(:,1));
%   Y                 = max(lay.pos(:,2));
%   lay.pos(end+1,:)  = [X Y];
% end

% to plot the layout for debugging, you can use this code snippet
global fb
if ~isempty(fb) && fb
  X      = lay.pos(:,1);
  Y      = lay.pos(:,2);
  Width  = lay.width;
  Height = lay.height;
  Lbl    = lay.label;
  figure
  plot(X, Y, '.');
  text(X, Y, Lbl);
  line([X X+Width X+Width X X]',[Y Y Y+Height Y+Height Y]');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
% read the layout information from the ascii file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lay = readlay(filename);
if ~exist(filename, 'file')
  error(sprintf('could not open layout file: %s', filename));
end
[chNum,X,Y,Width,Height,Lbl,Rem] = textread(filename,'%f %f %f %f %f %q %q');
for i=1:length(Lbl)
  if ~isempty(Rem{i})
    % this ensures that channel names with a space in them are also supported (i.e. Neuromag)
    Lbl{i} = [Lbl{i} ' ' Rem{i}];
  end
end
lay.pos    = [X Y];
lay.width  = Width;
lay.height = Height;
lay.label  = Lbl;
return % function readlay

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
% convert 3D electrode positions into 2D layout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lay = elec2lay(elec, rz, method);
if isempty(rz)
  rz = 90;
end
elec.pnt = ft_warp_apply(rotate([0 0 rz]), elec.pnt, 'homogenous');
prj = ft_elproj(elec.pnt, method);
d = dist(prj');
d(find(eye(size(d)))) = inf;
mindist = min(d(:));
X = prj(:,1);
Y = prj(:,2);
Width  = ones(size(X)) * mindist * 0.8;
Height = ones(size(X)) * mindist * 0.6;
Lbl = elec.label;
lay.pos    = [X Y];
lay.width  = Width;
lay.height = Height;
lay.label  = Lbl;
return % function elec2lay

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
% convert the magnetometer/gradiometer coil positions into a layout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lay = grad2lay(grad, rz, method);
fprintf('creating layout for %s system\n', sensortype(grad));
switch lower(sensortype(grad))
  case {'ctf151', 'ctf275', 'ctf151_planar', 'ctf275_planar', 'bti148', 'magnetometer'}
    rz = 90;
  case {'neuromag122', 'neuromag306'}
    rz = 0;
  otherwise
    rz = 0;
end
grad.pnt = warp_apply(rotate([0 0 rz]), grad.pnt, 'homogenous');
switch lower(sensortype(grad))
  case {'ctf151', 'ctf275'}
    Lbl = channelselection('MEG', grad.label);
    ind = match_str(grad.label, Lbl);
    pnt = grad.pnt(ind,:);
    prj = ft_elproj(pnt, method);
    d = dist(prj');
    d(find(eye(size(d)))) = inf;
    mindist = min(d(:));
    X = prj(:,1);
    Y = prj(:,2);
    Width  = ones(size(X)) * mindist * 0.8;
    Height = ones(size(X)) * mindist * 0.6;

  case {'ctf151_planar', 'ctf275_planar'}
    % create a list with planar channel names
    chan = {};
    for i=1:length(grad.label)
      if ~isempty(findstr(grad.label{i}, '_dH')) || ...
          ~isempty(findstr(grad.label{i}, '_dV'))
        chan{i} = grad.label{i}(1:(end-3));
      end
    end
    chan = unique(chan);
    % find the matching channel-duplets
    ind = [];
    lab = {};
    for i=1:length(chan)
      ch1 =  [chan{i} '_dH'];
      ch2 =  [chan{i} '_dV'];
      sel = match_str(grad.label, {ch1, ch2});
      if length(sel)==2
        ind = [ind; i];
        lab(i,:) = {ch1, ch2};
        meanpnt1 = mean(grad.pnt(find(grad.tra(sel(1),:)),:), 1);
        meanpnt2 = mean(grad.pnt(find(grad.tra(sel(2),:)),:), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);
    prj = ft_elproj(pnt, method);
    X = prj(:,1);
    Y = prj(:,2);
    d = dist(prj');
    d(find(eye(size(d)))) = inf;
    mindist = min(d(:));
    X1 = X; Y1 = Y + 0.21 * mindist;
    X2 = X; Y2 = Y - 0.21 * mindist;
    X = [X1; X2];
    Y = [Y1; Y2];
    Lbl = [lab(:,1); lab(:,2)];
    Width  = ones(size(X))*mindist/2;
    Height = ones(size(X))*mindist/3.0;

  case 'neuromag122'
    % find the matching channel-duplets
    ind = [];
    lab = {};
    for i=1:2:140
      % first try MEG channel labels with a space
      ch1 = sprintf('MEG %03d', i);
      ch2 = sprintf('MEG %03d', i+1);
      sel = match_str(grad.label, {ch1, ch2});
      % the try MEG channel labels without a space
      if (length(sel)~=2)
        ch1 = sprintf('MEG%03d', i);
        ch2 = sprintf('MEG%03d', i+1);
        sel = match_str(grad.label, {ch1, ch2});
      end
      % the try to determine the channel locations
      if (length(sel)==2)
        ind = [ind; i];
        lab(i,:) = {ch1, ch2};
        meanpnt1 = mean(grad.pnt(find(grad.tra(sel(1),:)),:), 1);
        meanpnt2 = mean(grad.pnt(find(grad.tra(sel(2),:)),:), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);
    prj = ft_elproj(pnt, method);
    X = prj(:,1);
    Y = prj(:,2);
    d = dist(prj');
    d(find(eye(size(d)))) = inf;
    mindist = min(d(:));
    X1 = X; Y1 = Y + 0.21 * mindist;
    X2 = X; Y2 = Y - 0.21 * mindist;
    X = [X1; X2];
    Y = [Y1; Y2];
    Lbl = [lab(:,1); lab(:,2)];
    Width  = ones(size(X))*mindist/2;
    Height = ones(size(X))*mindist/3.0;

  case 'neuromag306'
    % find the matching channel-triplets
    ind = [];
    lab = {};
    for i=1:300
      % first try MEG channel labels with a space
      ch1 = sprintf('MEG %03d1', i);
      ch2 = sprintf('MEG %03d2', i);
      ch3 = sprintf('MEG %03d3', i);
      sel = match_str(grad.label, {ch1, ch2, ch3});
      % the try MEG channels without a space
      if (length(sel)~=3)
        ch1 = sprintf('MEG%03d1', i);
        ch2 = sprintf('MEG%03d2', i);
        ch3 = sprintf('MEG%03d3', i);
        sel = match_str(grad.label, {ch1, ch2, ch3});
      end
      % then try to determine the channel locations
      if (length(sel)==3)
        ind = [ind; i];
        lab(i,:) = {ch1, ch2, ch3};
        meanpnt1 = mean(grad.pnt(find(grad.tra(sel(1),:)),:), 1);
        meanpnt2 = mean(grad.pnt(find(grad.tra(sel(2),:)),:), 1);
        meanpnt3 = mean(grad.pnt(find(grad.tra(sel(3),:)),:), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2; meanpnt3], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);
    prj = ft_elproj(pnt, method);
    X = prj(:,1);
    Y = prj(:,2);
    d = dist(prj');
    d(find(eye(size(d)))) = inf;
    mindist = min(d(:));
    X1 = X - 0.2 * mindist; Y1 = Y + 0.2 * mindist;
    X2 = X - 0.2 * mindist; Y2 = Y - 0.2 * mindist;
    X3 = X + 0.2 * mindist; Y3 = Y + 0.0 * mindist;
    X = [X1; X2; X3];
    Y = [Y1; Y2; Y3];
    Lbl = [lab(:,1); lab(:,2); lab(:,3)];
    Width  = ones(size(X))*mindist/3;
    Height = ones(size(X))*mindist/3;

  case {'bti148', 'magnetometer'}
    % select all channels for the layout
    pnt = grad.pnt;
    lab = grad.label;
    prj = ft_elproj(pnt, method);
    d = dist(prj');
    d(find(eye(size(d)))) = inf;
    mindist = min(d(:));
    X = prj(:,1);
    Y = prj(:,2);
    Lbl = lab;
    Width  = ones(size(X)) * mindist * 0.8;
    Height = ones(size(X)) * mindist * 0.6;

  otherwise
    error('unrecognized sensor type');
end % switch sensortype

lay.pos    = [X Y];
lay.width  = Width;
lay.height = Height;
lay.label  = Lbl;
return % function grad2lay

function [H] = rotate(D);

% ROTATE returns the homogenous coordinate transformation matrix
% corresponding to a rotation around the x, y and z-axis. The direction of
% the rotation is according to the right-hand rule.
%
% Use as
%   [H] = rotate(R)
% where
%   R		[rx, ry, rz] in degrees
%   H		corresponding homogenous transformation matrix
%
% Note that the order in which the rotations are performs matters. The
% rotation is first done around the z-axis, then the y-axis and finally the
% x-axis.

% Copyright (C) 2000-2005, Robert Oostenveld
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: rotate.m,v $
% Revision 1.5  2006/09/12 13:35:28  roboos
% convert input rotation from degrees (according to documentation) into radians (needed for computations)
%
% Revision 1.4  2005/08/15 08:15:33  roboos
% reimplemented the rotate function, which contained an error (the error is in the AIR technical reference)
% changed all functions to be dependent on the rotate, translate and scale function
% all functions now behave consistenly, which also means that they are not compleetly backward compatible w.r.t. the order of the rotations
%
% Revision 1.3  2004/05/19 09:57:07  roberto
% added GPL copyright statement, added CVS log item
%

% convert degrees to radians
R = D*pi/180;

% get the individual angles (in radians)
rx = R(1);
ry = R(2);
rz = R(3);

% precompute the sin/cos values of the angles
cX = cos(rx);
cY = cos(ry);
cZ = cos(rz);
sX = sin(rx);
sY = sin(ry);
sZ = sin(rz);

% according to Roger Woods' http://bishopw.loni.ucla.edu/AIR5/homogenous.html
% it should be this, but I cannot reproduce his rotation matrix
% H = eye(4,4);
% H(1,1) = cZ*cY + sZ*sX*sY;
% H(1,2) = sZ*cY - cZ*sX*sY;
% H(1,3) =            cX*sY;
% H(2,1) = -sZ*cX;
% H(2,2) =  cZ*cX;
% H(2,3) =     sX;
% H(3,1) =  sZ*sX*cY - cZ*sY;
% H(3,2) = -cZ*sX*cY - sZ*sY;
% H(3,3) =             cX*cY;

% instead, the following rotation matrix does work according my
% expectations. It rotates according to the right hand rule and first
% rotates around z, then y and then x axis
H = [
           cZ*cY,          -sZ*cY,              sY,               0
  cZ*sY*sX+sZ*cX, -sZ*sY*sX+cZ*cX,          -cY*sX,               0
 -cZ*sY*cX+sZ*sX,  sZ*sY*cX+cZ*sX,           cY*cX,               0
               0,               0,               0,               1
];

if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code can be used to construct the combined rotation matrix
% for either xyz or zyx ordering (using the Matlab symbolic math toolbox)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  syms sX sY sZ cX cY cZ
  % this is for only rotating around x
  Rx = [
    1   0    0   0
    0   cX  -sX  0
    0   sX   cX  0
    0   0    0   1
    ];
  % this is for only rotating around y
  Ry = [
    cY  0   sY  0
    0   1   0   0
    -sY  0   cY  0
    0   0   0   1
    ];
  % this is for only rotating around z
  Rz = [
    cZ -sZ  0   0
    sZ  cZ  0   0
    0   0   1   0
    0   0   0   1
    ];
  % combine them
  Rzyx = Rz * Ry * Rx  % rotate around x, y, then z
  Rxyz = Rx * Ry * Rz  % rotate around z, y, then x
end

