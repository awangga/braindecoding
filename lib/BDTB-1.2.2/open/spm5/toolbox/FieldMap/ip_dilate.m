function ima = ip_dilate(varargin)
% 
% Performs a 2 or 3D dilate on ima using either the supplied
% kernel or a standard 6-connectivity kernel.
% FORMAT: ima = ip_dilate(ima)
% or
% FORMAT: ima = ip_dilate(ima,kernel)
%
% Input:
% ima    : 2 or 3D image
% kernel : (Optional) voxel values in ima are replaced by the 
%          maximum value in a neighbourhood defined by kernel.
%          The "standard" dilation operation (in 2D) is realised
%          using the kernel
%          0 1 0
%          1 1 1
%          0 1 0
%
% Output:
% ima    : Dilated image.
%
% The functionality of this routine has been modelled on the function
% imdilate from the Matlab Image processing toolbox. It doesn't (yet)
% have a support function such as strel to help the user to define
% kernels (you have to do it yourself if you want anything above
% 6-connectivty) and it doesnt do the clever structuring element
% decomposition that strel does (and imdilate uses). That should
% in principle mean that ip_dilate is slower than imdilate, but
% at least for small (typical) kernels it is actually more than
% twice as fast.
% The actual job is done by ip_dilate_erode.c that serves both
% ip_dilate.m and op_erode.m
%__________________________________________________________________
% Jesper Andersson 1/10-03

if exist('ip_dilate_erode')~=3 
   error('mex-file ip_dilate_erode.c has not been compiled');
end

if nargin < 1 | nargin > 2 | nargout ~= 1
   error('FORMAT: ima=ip_dilate(ima) or ima=ip_dilate(ima,kernel)');
end
   
if nargin > 1
   kernel = varargin{2};
else
   if length(size(varargin{1})) == 2
      kernel = [0 1 0; 1 1 1; 0 1 0];
   elseif length(size(varargin{1})) == 3
      kernel = cat(3,[0 0 0; 0 1 0; 0 0 0],[0 1 0; 1 1 1; 0 1 0],[0 0 0; 0 1 0; 0 0 0]);
   else
      error('ip_dilate: ima must be 2- or 3-dimensional');
   end
end

ima = ip_dilate_erode(varargin{1},kernel,'dilate');

return;

