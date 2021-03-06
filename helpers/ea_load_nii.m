function nii=ea_load_nii(fname)
% Simple nifti reader using SPM.
% Support fname:
%     'PATH/TO/image.nii'
%     'PATH/TO/image.nii,1' (volume 1)
%     'PATH/TO/image.nii.gz'
%     'PATH/TO/image.nii.gz,1'
%     'PATH/TO/image'
%     'PATH/TO/image,1'

% need to consider the spm_vol('image.nii,1') case
fname=[ea_niigz(fname), fname(strfind(fname, ','):end)];

if regexp(fname, '\.nii.gz$', 'once') % 'image.nii.gz'
    wasgzip=1;
    gunzip(fname);
    fname=fname(1:end-3);
elseif regexp(fname, '\.nii.gz,\d+$', 'once') % 'image.nii.gz,1'
    wasgzip=1;
    [pth, ~, ~, vol] = ea_niifileparts(fname);
    gunzip([pth, '.nii.gz']);
    fname = [pth, '.nii', vol];
else
    wasgzip=0;
end

% Read header and img
nii=spm_vol(fname);
img=spm_read_vols(nii);
nii=nii(1); % only keep the header of the first vol for multi-vol image
nii.img=img; % set image data
nii.voxsize=ea_detvoxsize(nii(1).mat); % set voxsize

if wasgzip
    delete(ea_niifileparts(fname)); % since gunzip makes a copy of the zipped file.
end
