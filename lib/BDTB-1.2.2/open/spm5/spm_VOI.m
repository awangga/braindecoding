function TabDat = spm_VOI(SPM,xSPM,hReg)
% List of local maxima and adjusted p-values for a small Volume of Interest
% FORMAT TabDat = spm_VOI(SPM,xSPM,hReg)
%
% SPM   - structure containing analysis details (see spm_spm)
%
% xSPM  - structure containing SPM, distribution & filtering details
%        - required fields are:
% .swd   - SPM working directory - directory containing current SPM.mat
% .Z     - minimum of n Statistics {filtered on u and k}
% .n     - number of conjoint tests
% .STAT  - distribution {Z, T, X or F}
% .df    - degrees of freedom [df{interest}, df{residual}]
% .u     - height threshold
% .k     - extent threshold {resels}
% .XYZ   - location of voxels {voxel coords}
% .XYZmm - location of voxels {mm}
% .S     - search Volume {voxels}
% .R     - search Volume {resels}
% .FWHM  - smoothness {voxels}
% .M     - voxels - > mm matrix
% .VOX   - voxel dimensions {mm}
% .DIM   - image dimensions {voxels} - column vector
% .Vspm  - Mapped statistic image(s)
% .Ps    - P vlues in searched voxels (for FDR)
%
% hReg   - Handle of results section XYZ registry (see spm_results_ui.m)
%
% TabDat - Structure containing table data
%        - see spm_list for definition
%
%_______________________________________________________________________
%
% spm_VOI is  called by the SPM results section and takes variables in
% SPM to compute p-values corrected for a specified volume of interest.
%
% The volume of interest may be defined as a box or sphere centred on
% the current voxel or by a mask image.
%
% If the VOI is defined by a mask this mask must have been defined
% independently of the SPM (e.g.using a mask based on an orthogonal
% contrast)
%
% External mask images should be in the same orientation as the SPM
% (i.e. as the input used in stats estimation). The VOI is defined by
% voxels with values greater than 0.
%
% FDR computations are similarly resticted by the small search volume
%
% See also: spm_list
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_VOI.m 1770 2008-06-01 01:01:12Z Darren $


%-Parse arguments
%-----------------------------------------------------------------------
if nargin < 2,   error('insufficient arguments'), end
if nargin < 3,	 hReg = []; end

Num      = 16;			% maxima per cluster
Dis      = 04;			% distance among maxima (mm)

%-Title
%-----------------------------------------------------------------------
spm('FigName',['SPM{',xSPM.STAT,'}: Small Volume Correction']);

%-Get current location {mm}
%-----------------------------------------------------------------------
xyzmm    = spm_results_ui('GetCoords');

%-Specify search volume
%-----------------------------------------------------------------------
str      = sprintf(' at [%.0f,%.0f,%.0f]',xyzmm(1),xyzmm(2),xyzmm(3));
SPACE    = spm_input('Search volume...',-1,'m',...
		{['Sphere',str],['Box',str],'Image'},['S','B','I']);

% voxels in entire search volume {mm}
%-----------------------------------------------------------------------
XYZmm    = SPM.xVol.M(1:3,:)*[SPM.xVol.XYZ; ones(1, SPM.xVol.S)];
Q        = ones(1,size(xSPM.XYZmm,2));
O        = ones(1,size(     XYZmm,2));
FWHM     = xSPM.FWHM;


switch SPACE

	case 'S' %-Sphere
	%---------------------------------------------------------------
	D          = spm_input('radius of VOI {mm}',-2);
	str        = sprintf('%0.1fmm sphere',D);
	j          = find(sum((xSPM.XYZmm - xyzmm*Q).^2) <= D^2);
	k          = find(sum((     XYZmm - xyzmm*O).^2) <= D^2);
	D          = D./xSPM.VOX;


	case 'B' %-Box
	%---------------------------------------------------------------
	D          = spm_input('box dimensions [k l m] {mm}',-2);
    if length(D)~=3, D = ones(1,3)*D(1); end
	str        = sprintf('%0.1f x %0.1f x %0.1f mm box',D(1),D(2),D(3));
	j          = find(all(abs(xSPM.XYZmm - xyzmm*Q) <= D(:)*Q/2));
	k          = find(all(abs(     XYZmm - xyzmm*O) <= D(:)*O/2));
	D          = D./xSPM.VOX;


	case 'I' %-Mask Image
	%---------------------------------------------------------------
	Msk   = spm_select(1,'image','Image defining search volume');
	D     = spm_vol(Msk);
	str   = sprintf('image mask: %s',spm_str_manip(Msk,'a30'));
    
    % fix up string so tex interpreter works correctly
    str   = strrep(str,'\','\\');
    str   = strrep(str,'_','\_');
    str   = strrep(str,'^','\^');
    str   = strrep(str,'{','\{');
    str   = strrep(str,'}','\}');
    
	VOX   = sqrt(sum(D.mat(1:3,1:3).^2));
	FWHM  = FWHM.*(xSPM.VOX./VOX);
	XYZ   = D.mat \ [xSPM.XYZmm; ones(1, size(xSPM.XYZmm, 2))];
	j     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);
	XYZ   = D.mat \ [     XYZmm; ones(1, size(    XYZmm, 2))];
	k     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);

end

xSPM.S     = length(k);
xSPM.R     = spm_resels(FWHM,D,SPACE);
xSPM.Z     = xSPM.Z(j);
xSPM.XYZ   = xSPM.XYZ(:,j);
xSPM.XYZmm = xSPM.XYZmm(:,j);
xSPM.Ps    = xSPM.Ps(k);

%-Tabulate p values
%-----------------------------------------------------------------------
str       = sprintf('search volume: %s',str);
if any(strcmp(SPACE,{'S','B'}))
	str = sprintf('%s at [%.0f,%.0f,%.0f]',str,xyzmm(1),xyzmm(2),xyzmm(3));
end

TabDat    = spm_list('List',xSPM,hReg,Num,Dis,str);

%-Reset title
%-----------------------------------------------------------------------
spm('FigName',['SPM{',xSPM.STAT,'}: Results']);
