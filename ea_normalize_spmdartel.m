function varargout=ea_normalize_spmdartel(options)
% This is a function that normalizes both a copy of transversal and coronar
% images into MNI-space. The goal was to make the procedure both robust and
% automatic, but still, it must be said that normalization results should
% be taken with much care because all reconstruction results heavily depend
% on these results. Normalization of DBS-MR-images is especially
% problematic since usually, the field of view doesn't cover the whole
% brain (to reduce SAR-levels during acquisition) and since electrode
% artifacts can impair the normalization process. Therefore, normalization
% might be best archieved with other tools that have specialized on
% normalization of such image data.
%
% The procedure used here uses the SPM DARTEL approach to map a patient's
% brain to MNI space directly. Unlike the usual DARTEL-approach, which is
% usually used for group studies, here, DARTEL is used for a pairwise
% co-registration between patient anatomy and MNI template. It has been
% shown that DARTEL also performs superior to many other normalization approaches
% also  in a pair-wise setting e.g. in
%   Klein, A., et al. (2009). Evaluation of 14 nonlinear deformation algorithms
%   applied to human brain MRI registration. NeuroImage, 46(3), 786?802.
%   doi:10.1016/j.neuroimage.2008.12.037
%
% Since a high resolution is needed for accurate DBS localizations, this
% function applies DARTEL to an output resolution of 0.5 mm isotropic. This
% makes the procedure quite slow.

% The function uses some code snippets written by Ged Ridgway.
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn


if ischar(options) % return name of method.
    if strcmp(spm('ver'),'SPM12')
        varargout{1}='SPM12 DARTEL nonlinear (Ashburner 2007)';
        varargout{2}=1; % compatible
    else
        varargout{1}='SPM12 DARTEL nonlinear (Ashburner 2007)';
        varargout{2}=0; % incompatible
    end

    return
end


directory = [options.root,options.patientname,filesep];

if isfield(options.prefs, 'tranii_unnormalized')
    if exist([directory,options.prefs.tranii_unnormalized,'.gz'],'file')
        try
            gunzip([directory,options.prefs.tranii_unnormalized,'.gz']);
        end
        try
            gunzip([directory,options.prefs.cornii_unnormalized,'.gz']);
        end
        try
            gunzip([directory,options.prefs.sagnii_unnormalized,'.gz']);
        end
        try
            gunzip([directory,options.prefs.prenii_unnormalized,'.gz']);
        end
    end
end



% now dartel-import the preoperative version.
disp('Segmenting preoperative version (Import to DARTEL-space)');
ea_newseg_pt(options,1,1);
disp('Segmentation of preoperative MRI done.');

% check if darteltemplate is available, if not generate one
if exist([ea_space(options,'dartel'),'dartelmni_6.nii'],'file')
    % There is a DARTEL-Template. Check if it will match:
    Vt=spm_vol([ea_space(options,'dartel'),'dartelmni_6.nii']);
    Vp=spm_vol([directory,'rc1',options.prefs.prenii_unnormalized]);
    if ~isequal(Vp.dim,Vt(1).dim) || ~isequal(Vp.mat,Vt(1).mat) % Dartel template not matching. -> create matching one.
        ea_create_tpm_darteltemplate; %([directory,'rc1',options.prefs.prenii_unnormalized]);
    end
else % no dartel template present. -> Create matching dartel templates from highres version.
    ea_create_tpm_darteltemplate; %([directory,'rc1',options.prefs.prenii_unnormalized]);
end

% Normalize to MNI using DARTEL.
matlabbatch{1}.spm.tools.dartel.warp1.images = {
                                                {[directory,'rc1',options.prefs.prenii_unnormalized,',1']}
                                                {[directory,'rc2',options.prefs.prenii_unnormalized,',1']}
                                                {[directory,'rc3',options.prefs.prenii_unnormalized,',1']}
                                                }';
matlabbatch{1}.spm.tools.dartel.warp1.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).template = {[ea_space(options,'dartel'),'dartelmni_1.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).template = {[ea_space(options,'dartel'),'dartelmni_2.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).template = {[ea_space(options,'dartel'),'dartelmni_3.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).template = {[ea_space(options,'dartel'),'dartelmni_4.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).template = {[ea_space(options,'dartel'),'dartelmni_5.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).template = {[ea_space(options,'dartel'),'dartelmni_6.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.its = 3;
jobs{1}=matlabbatch;

spm_jobman('run',jobs);
disp('*** Dartel coregistration of preoperative version worked.');

clear matlabbatch jobs;

% Export normalization parameters:
% backward
switch spm('ver')
    case 'SPM8'
        ea_error('SPM8 is not supported anymore in this version of Lead-DBS');
    case 'SPM12'
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {[directory,'u_rc1',options.prefs.prenii_unnormalized]};
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1 0];
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
        matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = ['ea_normparams'];
        matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = {directory};
end
jobs{1}=matlabbatch;

spm_jobman('run',jobs);
disp('*** Exported normalization parameters to y_ea_normparams.nii');
clear matlabbatch jobs;
    
% forward (inverse)
switch spm('ver')
    case 'SPM8'
        ea_error('SPM8 is not supported anymore in this version of Lead-DBS');
    case 'SPM12'
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {[directory,'u_rc1',options.prefs.prenii_unnormalized]};
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [0 1];
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
        matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
        matlabbatch{1}.spm.util.defs.comp{2}.id.space = {[directory,options.prefs.prenii_unnormalized]};
        matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'ea_inv_normparams';
        matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = {directory};
end
jobs{1}=matlabbatch;

spm_jobman('run',jobs);
disp('*** Exported normalization parameters to y_ea_inv_normparams.nii');
clear matlabbatch jobs;

% delete([directory,'u_rc1',options.prefs.prenii_unnormalized]);

ea_apply_normalization(options)
