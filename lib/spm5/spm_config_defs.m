function conf = spm_config_defs
% Configuration file for deformation jobs.
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_config_defs.m 1032 2007-12-20 14:45:55Z john $

entry = inline(['struct(''type'',''entry'',''name'',name,'...
    '''tag'',tag,''strtype'',strtype,''num'',num)'],...
    'name','tag','strtype','num');

files = inline(['struct(''type'',''files'',''name'',name,'...
    '''tag'',tag,''filter'',fltr,''num'',num)'],...
    'name','tag','fltr','num');

branch = inline(['struct(''type'',''branch'',''name'',name,'...
    '''tag'',tag,''val'',{val})'],...
    'name','tag','val');

repeat = inline(['struct(''type'',''repeat'',''name'',name,'...
    '''tag'',tag,''values'',{values})'],...
    'name','tag','values');

mnu = inline(['struct(''type'',''menu'',''name'',name,'...
        '''tag'',tag,''labels'',{labels},''values'',{values},''help'',{{}})'],...
        'name','tag','labels','values');

%--------------------------------------------------------------------
hsummary = {[...
'This is a utility for working with deformation fields. ',...
'They can be loaded, inverted, combined etc, and the results ',...
'either saved to disk, or applied to some image.'],...
'',[...
'Note that ideal deformations can be treated as members of a Lie group. ',...
'Future versions of SPM may base its warping on such principles.']};

hinv = {[...
'Creates the inverse of a deformation field. ',...
'Deformations are assumed to be one-to-one, in which case they ',...
'have a unique inverse.  If y'':A->B is the inverse of y:B->A, then ',...
'y'' o y = y o y'' = Id, where Id is the identity transform.'],...
'',...
'Deformations are inverted using the method described in the appendix of:',...
['    * Ashburner J, Andersson JLR & Friston KJ (2000) ',...
 '"Image Registration using a Symmetric Prior - in Three-Dimensions." ',...
 'Human Brain Mapping 9(4):212-225']};

hcomp = {[...
'Deformation fields can be thought of as mappings. ',...
'These can be combined by the operation of "composition", which is ',...
'usually denoted by a circle "o". ',...
'Suppose x:A->B and y:B->C are two mappings, where A, B and C refer ',...
'to domains in 3 dimensions. ',...
'Each element a in A points to element x(a) in B. ',...
'This in turn points to element y(x(a)) in C, so we have a mapping ',...
'from A to C. ',...
'The composition of these mappings is denoted by yox:A->C. ',...
'Compositions can be combined in an associative way, such that zo(yox) = (zoy)ox.'],...
'',[...
'In this utility, the left-to-right order of the compositions is ',...
'from top to bottom (note that the rightmost deformation would ',...
'actually be applied first). ',...
'i.e. ...((first o second) o third)...o last. The resulting deformation field will ',...
'have the same domain as the first deformation specified, and will map ',...
'to voxels in the codomain of the last specified deformation field.']};

hsn = {[...
'Spatial normalisation, and the unified segmentation model of ',...
'SPM5 save a parameterisation of deformation fields.  These consist ',...
'of a combination of an affine transform, and nonlinear warps that ',...
'are parameterised by a linear combination of cosine transform ',...
'basis functions.  These are saved in *_sn.mat files, which can be ',...
'converted to deformation fields.']};

hvox = {[...
'Specify the voxel sizes of the deformation field to be produced. ',...
'Non-finite values will default to the voxel sizes of the template image',...
'that was originally used to estimate the deformation.']};

hbb = {[...
'Specify the bounding box of the deformation field to be produced. ',...
'Non-finite values will default to the bounding box of the template image',...
'that was originally used to estimate the deformation.']};

himgr = {[...
'Deformations can be thought of as vector fields. These can be represented ',...
'by three-volume images.']};

himgw = {[...
'Save the result as a three-volume image.  "y_" will be prepended to the ',...
'filename.  The result will be written to the current directory.']};

happly = {[...
'Apply the resulting deformation field to some images. ',...
'The warped images will be written to the current directory, and the ',...
'filenames prepended by "w".  Note that trilinear interpolation is used ',...
'to resample the data, so the original values in the images will ',...
'not be preserved.']};

hmatname = {[...
'Specify the _sn.mat to be used.']};

himg = {[...
'Specify the image file on which to base the dimensions, orientation etc.']};

hid = {[...
'This option generates an identity transform, but this can be useful for '...
'changing the dimensions of the resulting deformation (and any images that '...
'are generated from it).  Dimensions, orientation etc are derived from '...
'an image.']};

def          = files('Deformation Field','def','.*y_.*\.nii$',1);
def.help     = himgr;

matname      = files('Parameter File','matname','.*_sn\.mat$',[1 1]);
matname.help = hmatname;

vox          = entry('Voxel sizes','vox','e',[1 3]);
vox.val      = {[NaN NaN NaN]};
vox.help     = hvox;

bb           = entry('Bounding box','bb','e',[2 3]);
bb.val       = {NaN*ones(2,3)};
bb.help      = hbb;

sn2def       = branch('Imported _sn.mat','sn2def',{matname,vox,bb});
sn2def.help  = hsn;

img          = files('Image to base Id on','space','image',1);
img.help     = himg;
id           = branch('Identity','id',{img});
id.help      = hid;

if spm_matlab_version_chk('7') <= 0,
    ffield = files('Flow field','flowfield','nifti',[1 1]);
    ffield.ufilter = '^u_.*';
    ffield.help = {...
    ['The flow field stores the deformation information. '...
     'The same field can be used for both forward or backward deformations '...
     '(or even, in principle, half way or exaggerated deformations).']};
    %------------------------------------------------------------------------
    forbak = mnu('Forward/Backwards','times',{'Backward','Forward'},{[1 0],[0 1]});
    forbak.val  = {[1 0]};
    forbak.help = {[...
    'The direction of the DARTEL flow.  '...
    'Note that a backward transform will warp an individual subject''s '...
    'to match the template (ie maps from template to individual). '...
    'A forward transform will warp the template image to the individual.']};
    %------------------------------------------------------------------------
    K = mnu('Time Steps','K',...
        {'1','2','4','8','16','32','64','128','256','512'},...
        {0,1,2,3,4,5,6,7,8,9});
    K.val = {6};
    K.help = {...
    ['The number of time points used for solving the '...
     'partial differential equations.  A single time point would be '...
     'equivalent to a small deformation model. '...
     'Smaller values allow faster computations, '...
     'but are less accurate in terms '...
     'of inverse consistency and may result in the one-to-one mapping '...
     'breaking down.']};
    %------------------------------------------------------------------------
    drtl = branch('DARTEL flow','dartel',{ffield,forbak,K});
    drtl.help = {'Imported DARTEL flow field.'};
    %------------------------------------------------------------------------
    other = {sn2def,drtl,def,id};
else
    other = {sn2def,def,id};
end

img          = files('Image to base inverse on','space','image',1);
img.help     = himg;

comp0        = repeat('Composition','comp',other);
comp0.help   = hcomp;

iv0          = branch('Inverse','inv',{comp0,img});
iv0.help     = hinv;

comp1        = repeat('Composition','comp',{other{:},iv0,comp0});
comp1.help   = hcomp;
comp1.check  = @check;

iv1          = branch('Inverse','inv',{comp1,img});
iv1.help     = hinv;

comp2        = repeat('Composition','comp',{other{:},iv1,comp1});
comp2.help   = hcomp;
comp2.check  = @check;

iv2          = branch('Inverse','inv',{comp2,img});
iv2.help     = hinv;


comp         = repeat('Composition','comp',{other{:},iv2,comp2});
comp.help    = hcomp;
comp.check   = @check;

saveas       = entry('Save as','ofname','s',[1 Inf]);
saveas.val   = {''};
saveas.help  = himgw;

applyto      = files('Apply to','fnames','image',[0 Inf]);
applyto.val  = {''};
applyto.help = happly;

interp.type = 'menu';
interp.name = 'Interpolation';
interp.tag  = 'interp';
interp.labels = {'Nearest neighbour','Trilinear','2nd Degree B-spline',...
'3rd Degree B-Spline ','4th Degree B-Spline ','5th Degree B-Spline',...
'6th Degree B-Spline','7th Degree B-Spline'};
interp.values = {0,1,2,3,4,5,6,7};
interp.def  = 'normalise.write.interp';
interp.help = {...
['The method by which the images are sampled when being written in a ',...
'different space.'],...
['    Nearest Neighbour: ',...
'    - Fastest, but not normally recommended.'],...
['    Bilinear Interpolation: ',...
'    - OK for PET, or realigned fMRI.'],...
['    B-spline Interpolation: ',...
'    - Better quality (but slower) interpolation/* \cite{thevenaz00a}*/, especially ',...
'      with higher degree splines.  Do not use B-splines when ',...
'      there is any region of NaN or Inf in the images. '],...
};


conf         = branch('Deformations','defs',{comp,saveas,applyto,interp});
conf.prog    = @spm_defs;
conf.vfiles  = @vfiles;
conf.help    = hsummary;
return;
%_______________________________________________________________________

%_______________________________________________________________________

function str = check(job)
str = '';
if isempty(job),
    str = 'Empty Composition';
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________

function vf = vfiles(job)
vf = {};
s  = strvcat(job.ofname);
if ~isempty(s),
    vf = {vf{:}, fullfile(pwd,['y_' s '.nii,1'])};
end;

s  = strvcat(job.fnames);
for i=1:size(s,1),
    [pth,nam,ext,num] = spm_fileparts(s(i,:));
    vf = {vf{:}, fullfile(pwd,['w',nam,ext,num])};
end;
return;
