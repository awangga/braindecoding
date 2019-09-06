function ft2spm(ftdata, filename, ctf)
% Converter from Fieldtrip (http://www.ru.nl/fcdonders/fieldtrip/)
% data structures to SPM file format
%_______________________________________________________________________
% Copyright (C) 2007 Wellcome Trust Centre for Neuroimaging


disp('Converting data to SPM format');


% If preprocessing format
if iscell(ftdata.time)

    if length(ftdata.time)>1
        % Initial checks
        if any(diff(cellfun('length', ftdata.time))~=0)
            error('SPM can only handle data with equal trial lengths.');
        else
            times=cell2mat(ftdata.time(:));
            if any(diff(times(:, 1))~=0) || any(diff(times(:, end))~=0)
                error('SPM can only handle data the same trial borders.');
            end
        end
    end

    D.Nevents=length(ftdata.trial);

    nchan  = size(ftdata.trial{1},1);
    ntime  = size(ftdata.trial{1},2);

    data = zeros(nchan, ntime, D.Nevents);

    spm_progress_bar('Init', D.Nevents, 'converting data to SPM format'); drawnow;
    for n=1:D.Nevents
        spm_progress_bar('Set', n); drawnow;
        data(:,:,n) = ftdata.trial{n};
    end
    spm_progress_bar('Clear');
    
    ftdata.time  = ftdata.time{1};
else % timelockanalysis format
    rptind=strmatch('rpt', tokenize(ftdata.dimord, '_'));
    if isempty(rptind)
        rptind=strmatch('subj', tokenize(ftdata.dimord, '_'));
    end

    timeind=strmatch('time', tokenize(ftdata.dimord, '_'));
    chanind=strmatch('chan', tokenize(ftdata.dimord, '_'));

    if ~isempty(rptind)
        if isfield(ftdata, 'trial')
            D.Nevents = size(ftdata.trial, rptind);
            data =permute(ftdata.trial, [chanind, timeind, rptind]);
        else
            D.Nevents = size(ftdata.individual, rptind);
            data =permute(ftdata.individual, [chanind, timeind, rptind]);
        end
    else
        D.Nevents=1;
        data =permute(ftdata.avg, [chanind, timeind]);
    end
end

% sampling rate in Hz
D.Radc = ftdata.fsample;

% Number of time bins in peri-stimulus time
D.Nsamples = length(ftdata.time);

% channel template file
D.channels.ctf = ctf;

% Names of channels in order of the data
D.channels.name = ftdata.label(:)';
D.Nchannels = length(D.channels.name);

% index vector of bad channels
D.channels.Bad = [];


% name of SPM mat file
D.fname = filename;

megchans=match_str(ftdata.label, ft_channelselection('MEG', ftdata.label));
if isfield(ftdata, 'hdr') &&  isfield(ftdata.hdr, 'grad') && ~isempty(megchans) % MEG
    D.modality = 'MEG';
    D.units = 'fT';
    % This is a rule of thumb. Look at the distribution of values
    % at one timepoint across channels and trials. Assumes that in MEG
    % datasets most channels will be MEG.
    if (median(abs(reshape(data(:,fix(end/2),:), 1,[])))<1e-10)
        data(megchans, :, :)=1e15*data(megchans, :, :);
        warning('Detected MEG data and converted to the units to fT');
    end
else   %EEG
    D.modality = 'EEG';
    D.units = '\muV';
    if (median(abs(reshape(data(:,fix(end/2),:), 1,[])))<1e-2)
        data=1e6*data;
        warning('Scaled the data for CTF EEG.');
    else
        warning('Assuming that units are uV. Units may not be correct for EEG data.');
    end
end


% Don't change these
D.channels.reference = 0;
D.channels.ref_name = 'NIL';

% In the case of epoched data preprocessed in SPM codes and times are taken
% from the trl table
if issubfield(ftdata, 'cfg.trl') && D.Nevents>1
    trl = getsubfield(ftdata, 'cfg.trl');
    D.events.time = trl(:,1) - trl(:,3);
    if size(trl, 2)<4
        D.events.code = ones(size(D.events.time));
    else
        D.events.code = trl(:,4)';
    end
    %If there is no trl (data is continuous or not from SPM GUI)
elseif issubfield(ftdata.cfg, 'cfg.event')
    % If data comes from FT spm codes are added to events
    event = getsubfield(ftdata, 'cfg.event');
    if ~isfield(event, 'spmcode')
        event=spm_eeg_recode_events(event);
    end
    D.events.time = [event.sample];
    D.events.code = [event.spmcode];
else
    % If there is no information about events the codes are 1s
    warning('No event information found in the FT data');
    D.events.code=ones(1, size(data,3));
    D.events.time=nan(1, size(data,3));
end

% This is for compatibility  with the old conversion
if isfield(D.events, 'time')
    D.events.time=D.events.time(:)';
end
if isfield(D.events, 'code')
    D.events.code=D.events.code(:)';
end

% FIXME Support for original events for epoched data can be added.

D.events.types = unique(D.events.code);
D.events.Ntypes = length(D.events.types);


% If the data is  epoched or ERP  (rather than continuous un-epoched)
% The rule of thumb of total duration longer than 5 sec is used to
% distinguish between continuous and ERP.
if D.Nevents>1 || (ftdata.time(end)-ftdata.time(1))<5
    % finds the index of the time point closest to zero (will only work if
    % the baseline has negative time values).
    [junk zero_ind]=min(abs(ftdata.time));
    % nr of time bins before stimulus onset (this excludes the time bin at zero)
    D.events.start = zero_ind-1;
    % nr of time bins after stimulus onset (this excludes the time bin at zero)
    D.events.stop = length(ftdata.time)-zero_ind;

    % This is here because spm_eeg_epochs checks whether there is a previous
    % reject field and does not replace it. So for continuous data there should
    % not be any.
    D.events.reject = zeros(1, D.Nevents);
end

D.events.repl=[];


if D.Nevents>1 && length(D.events.code)~=D.Nevents
    warning('Number of events in the events field is not consistent with the number of trials');
end


% Name for the data file
D.path = fileparts(D.fname);
D.fname = spm_str_manip(D.fname, 't');
D.fnamedat = [spm_str_manip(D.fname, 'r') '.dat'];


Csetup = load(fullfile(spm('dir'), 'EEGtemplates', D.channels.ctf));

% Map name of channels (EEG only) to channel order specified in channel
% template file.
D.channels.heog = find(strncmpi('heog', D.channels.name, 4));
if isempty(D.channels.heog)
    D.channels.heog = 0;
else
    D.channels.heog = D.channels.heog(1);
end

D.channels.veog = find(strncmpi('veog', D.channels.name, 4));
if isempty(D.channels.veog)
    D.channels.veog = 0;
else
    D.channels.veog = D.channels.veog(1);
end

if Csetup.Nchannels>0
    switch D.modality
        case {'EEG', 'MEG'}
            % FIXME This is not a generic way for all kinds of EEG data.
            D.channels.eeg = setdiff([1:D.Nchannels], [D.channels.veog D.channels.heog]);

            for i = D.channels.eeg

                index = find(strcmpi(D.channels.name{i}, Csetup.Cnames));

                if isempty(index)
                    warning(sprintf('No channel named %s found in channel template file.', D.channels.name{i}));
                else
                    % take only the first found channel descriptor
                    D.channels.order(i) = index(1);
                end

            end
    end
end

D.scale = ones(D.Nchannels, 1, D.Nevents);
D.datatype  = 'float32';

fpd = fopen(fullfile(D.path, D.fnamedat), 'w');

for i = 1:D.Nevents
    d = squeeze(data(:, :, i));
    D.scale(:, 1, i) = spm_eeg_write(fpd, d, 2, D.datatype);
end


fclose(fpd);

if str2num(version('-release'))>=14
    save(fullfile(D.path, D.fname), '-V6', 'D');
else
    save(fullfile(D.path, D.fname), 'D');
end

spm('Pointer', 'Arrow');

