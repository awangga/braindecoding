% This script constitutes both a help script and a batch script that can be 
% modified for automatic source reconstruction or EEG-MEG model inversion. 
% It details how fields are specified and routines are called to generate a 
% processing stream from the trial-averaged data structure to a smoothed 
% contrast or window image for subsequent between subject analyses.
 
% Load data and specify which the inversion number
%==========================================================================
% We start with loading the data structure D. Each inversion is stored in the 
% structure array D.inv.  The current inversion is indexed by D.val; here we 
% will assume we want to specify and invert a second model.  We will also
% assume that EEG data is being analysed (this simplifies the registration
% step below.
%--------------------------------------------------------------------------
D                 = spm_eeg_ldata( '??????????.mat');
val               = 1;
D.val             = val;
D.modality        = 'EEG';
D.inv{val}.method = 'Imaging';

% Compute a head model
%==========================================================================
% The next step is to define the head model in terms of s structural MRI (sMRI) 
% This is not necessary if you are happy using a standard head model supplied 
% with SPM.  We will assume this analysis is going to use a standard model, so 
% the normalisation and mesh routines are commented out in this script
%--------------------------------------------------------------------------
 
% specify cortical mesh size (1 tp 4; 1 = 3004, 4 = 7204 dipoles)
%--------------------------------------------------------------------------
D.inv{val}.mesh.Msize  = 2;
 
% spatial normalization into a MNI template
%--------------------------------------------------------------------------
% D.inv{val}.mesh.sMRI = '??????????.img'
% D                    = spm_eeg_inv_spatnorm(D);
 
% and compute meshes
%--------------------------------------------------------------------------
% D = spm_eeg_inv_meshing(D);
 
% or, use a template head model and associated meshes
%--------------------------------------------------------------------------
D = spm_eeg_inv_template(D);
 
 
% Compute a head model
%==========================================================================
% Next, we need to register the sensor locations to the head model meshes. 
% This requires one to specify mat files describing the location of the sensors 
% and supplementary information about the cortical surface, which is in the 
% same frame of reference.  The simplest way to do this is to use a Polhemus 
% file that contains both the locations of the fiducials and sensor locations.
% To keep things simple, we will assume that we are analysing EEG.  In this 
% case, the sensor locations also define the scalp surface and can be uses in 
% the registration to the head model.
%--------------------------------------------------------------------------


% get fiducials and head shape
%--------------------------------------------------------------------------
pol_file            = 'C:\home\spm\Grandmean\standard_09_03_2004.pol';
pol_skip            = 2;
[fid_eeg,headshape] = spm_eeg_inv_ReadPolhemus(pol_file,pol_skip);

% get sensor locations
%--------------------------------------------------------------------------
if strcmp(D.modality,'EEG')
    sensors = headshape;
else
    sensors = '?????????.mat';
    name    = fieldnames(sensors);
    sensors = getfield(sensors,name{1});
end
D.inv{val}.datareg.sensors   = sensors;
D.inv{val}.datareg.fid_eeg   = fid_eeg;
D.inv{val}.datareg.headshape = headshape;
D.inv{val}.datareg.megorient = sparse(0,3);

% register data
%--------------------------------------------------------------------------
D = spm_eeg_inv_datareg(D);
 
 
% Compute a forward model
%==========================================================================
% Next, using the geometry of the head model and the location of registered 
% sensors, we can now compute a forward model for each dipole and save it in a 
% lead-field or gain matrix.  This is the basis of our likelihood model.
%--------------------------------------------------------------------------
D.inv{val}.forward.method = 'eeg_3sphereBerg';
D = spm_eeg_inv_BSTfwdsol(D);
 
 
% Invert the forward model
%==========================================================================
% Next, we invert the forward model using the trials or conditions of interest, 
% specified in the field 'trials'.  The full model needs specifying in terms
% of its priors, through the fields below.
 
%--------------------------------------------------------------------------
D.inv{val}.inverse.trials = [1 2];      % Trials
D.inv{val}.inverse.type   = 'MSP';      % Priors on sources MSP, LOR or IID
D.inv{val}.inverse.smooth = 0.4;        % Smoothness of source priors (mm)
D.inv{val}.inverse.Np     = 64;         % Number of sparse priors (x 1/2)
 
% We can also restrict solutions to bilateral spheres in source space
%--------------------------------------------------------------------------
D.inv{val}.inverse.xyz     = [-48 0 0;
                               48 0 0]; % x,y,z and radius (mm)
D.inv{val}.inverse.rad     = [ 32 32]; 
     
% and finally, invert
%--------------------------------------------------------------------------
D = spm_eeg_invert(D);


% Compute conditional expectation of mean square (MS) response
%==========================================================================
% The penultimate step is to specify a time-frequency window and compute the 
% conditional expectation of the MS response.  A simple windowed average 
% is a special case of this, where the frequency is zero.  In this context, 
% the RMS is the same as the absolute value of the time-averaged repsone.
 
% set time-frequency window
%--------------------------------------------------------------------------
D.inv{val}.contrast.woi  = [100 200];   % peristimulus time (ms)
D.inv{val}.contrast.fboi = [2 32];      % frequency window (Hz)
 
% and evaluate contrast
%--------------------------------------------------------------------------
D = spm_eeg_inv_results(D);
 
% Convert mesh data into an image for further analysis
%==========================================================================
% Finally, write the smoothed contrast to an image in voxel space. The file 
% name will correspond to the data name and current inversion (i.e., D.val)
 
%--------------------------------------------------------------------------
D.inv{D.val}.contrast.smooth  = 8; % FWHM (mm)
D.inv{D.val}.contrast.display = 0;
D = spm_eeg_inv_Mesh2Voxels(D);
