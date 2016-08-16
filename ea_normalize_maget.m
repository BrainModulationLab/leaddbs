function varargout=ea_normalize_maget(options)

if ischar(options) % return name of method.
    varargout{1}='MAGeT Brain-like Normalization (Chakravarty 2013)';
    varargout{2}={'SPM8','SPM12'};
    return
end

reforce=1;
atlastouse='DISTAL_manual'; % for now, only the distal atlas is supported!

ptage=ea_getpatientage([options.root,options.patientname,filesep]);

peerfolders=ea_getIXI_IDs(21,ptage);


% make sure no peer is also the subject:
ps=ismember(peerfolders,[options.root,options.patientname,filesep]);
peerfolders(ps)=[];


%% step 0: check if all subjects have been processed with an ANTs-based normalization function
for peer=1:length(peerfolders)
    if ~ismember(ea_whichnormmethod([peerfolders{peer},filesep]),ea_getantsnormfuns)
        ea_error('Please make sure that all peers selected have been normalized using ANTs.')
    end
end

subdirec=[options.root,options.patientname,filesep];
if ~ismember(ea_whichnormmethod(subdirec),ea_getantsnormfuns)
    ea_normalize_ants_multimodal(options,'coregonly');
end

%% step 1, setup DISTAL warps back to sub via each peer brain
earoot=ea_getearoot;
atlasbase=[earoot,'atlases',filesep,atlastouse,filesep];

for peer=1:length(peerfolders)
    
    clear spfroms sptos weights metrics
    peerdirec=[peerfolders{peer},filesep];
    poptions=options;
    [poptions.root,poptions.patientname]=fileparts(peerfolders{peer});
    poptions.root=[poptions.root,filesep];
    poptions=ea_assignpretra(poptions);
    
    
    %% step 1, generate warps from peers to the selected patient brain
    
    
    if ~exist([subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'2mni.nii.gz'],'file') || reforce
        [~,peerpresentfiles]=ea_assignpretra(poptions);
        [~,subpresentfiles]=ea_assignpretra(options);
        presentinboth=ismember(subpresentfiles,peerpresentfiles);
        peerpresentfiles=peerpresentfiles(presentinboth);
        if ~isequal(subpresentfiles,peerpresentfiles) % then I made something wrong.
            keyboard
        else
            presentfiles=subpresentfiles;
            clear subpresentfiles peerpresentfiles
        end
        for anatfi=1:length(presentfiles)
            spfroms{anatfi}=[subdirec,presentfiles{anatfi}];
            sptos{anatfi}=[peerdirec,presentfiles{anatfi}];
            metrics{anatfi}='MI';
        end
        weights=repmat(1.5,length(presentfiles),1);
        
        % add FA if present ? add to beginning since will use last entry to
        % converge
        if exist([subdirec,options.prefs.fa2anat],'file') && exist([peerdirec,options.prefs.fa2anat],'file')
            spfroms=[{[subdirec,options.prefs.fa2anat]},spfroms];
            sptos=[{[peerdirec,options.prefs.fa2anat]},sptos];
            
            weights=[0.5;weights];
            metrics=[{'MI'},metrics];
            
        end
        
        defoutput=[subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname];
        if ~exist([subdirec,'MAGeT',filesep,'warps',filesep],'file')
            mkdir([subdirec,'MAGeT',filesep,'warps',filesep]);
        end
        
try        
        ea_ants_nonlinear(sptos,spfroms,[subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'.nii'],weights,metrics,options);
catch
    keyboard
end
        delete([subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'.nii']); % we only need the warp
        %delete([subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'InverseComposite.h5']); % we dont need the inverse warp
        
        % Now export composite transform from MNI -> Peer -> Subject
        
        if ispc
            sufx='.exe';
        else
            sufx=computer('arch');
        end
        
        antsApply=[ea_getearoot,'ext_libs',filesep,'ANTs',filesep,'antsApplyTransforms.',sufx];
        
        template=[ea_getearoot,'templates',filesep,'mni_hires.nii'];
        prenii=[options.root,options.patientname,filesep,options.prefs.prenii_unnormalized];
        cmd=[antsApply,' -r ',template,' -t ',[peerfolders{peer},filesep,'glanatComposite.h5'],' -t ',[subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'Composite.h5'],' -o [',[subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'2mni.nii',',1]']]; % temporary write out uncompressed (.nii) since will need to average slice by slice lateron.
        icmd=[antsApply,' -r ',prenii,' -t ',[subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'InverseComposite.h5'],' -t ',[peerfolders{peer},filesep,'glanatInverseComposite.h5'],' -o [',[subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'2sub.nii',',1]']]; % temporary write out uncompressed (.nii) since will need to average slice by slice lateron.
        if ~ispc
            system(['bash -c "', cmd, '"']);
            system(['bash -c "', icmd, '"']);
        else
            system(cmd);
            system(icmd);
        end
        
        % delete intermediary files
        %delete([subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'InverseComposite.h5']);
        %delete([subdirec,'MAGeT',filesep,'warps',filesep,poptions.patientname,'Composite.h5']);
    end
    
end


% aggregate all warps together and average them

warpbase=[options.root,options.patientname,filesep,'MAGeT',filesep,'warps',filesep];
fis=dir([warpbase,'*2mni.nii']);
for fi=1:length(fis)
ficell{fi}=[warpbase,fis(fi).name];
end
ea_robustaverage_nii(ficell,[warpbase,'ave2mni.nii']);
gzip([warpbase,'ave2mni.nii']);

clear ficell
fis=dir([warpbase,'*sub.nii']);
for fi=1:length(fis)
ficell{fi}=[warpbase,fis(fi).name];
end
ea_robustaverage_nii(ficell,[warpbase,'ave2sub.nii']);
gzip([warpbase,'ave2sub.nii']);

movefile([warpbase,'ave2mni.nii.gz'],[subdirec,'glanatComposite.nii.gz']);
movefile([warpbase,'ave2sub.nii.gz'],[subdirec,'glanatInverseComposite.nii.gz']);

% % now convert to .h5 again and place in sub directory:
% antsApply=[ea_getearoot,'ext_libs',filesep,'ANTs',filesep,'antsApplyTransforms.',sufx];
% template=[ea_getearoot,'templates',filesep,'mni_hires.nii'];
% prenii=[options.root,options.patientname,filesep,options.prefs.prenii_unnormalized];
% cmd=[antsApply,' -r ',template,' -t ',[warpbase,'ave2mni.nii.gz'],' -o [',[subdirec,'glanatComposite.nii.gz,1]']];
% icmd=[antsApply,' -r ',prenii,' -t ',[warpbase,'ave2sub.nii.gz'],' -o [',[subdirec,'glanatInverseComposite.nii.gz,1]']];
% if ~ispc
%     system(['bash -c "', cmd, '"']);
%     system(['bash -c "', icmd, '"']);
% else
%     system(cmd);
%     system(icmd);
% end

% apply warps as always:
ea_apply_normalization(options);


% finally, cleanup.

%rmdir([subdirec,'MAGeT'],'s');



function ea_writecompositewarp(transforms)
basedir=[ea_getearoot,'ext_libs',filesep,'ANTs',filesep];
if ispc
    applyTransforms = [basedir, 'antsApplyTransforms.exe'];
else
    applyTransforms = [basedir, 'antsApplyTransforms.', computer('arch')];
end


cmd=[applyTransforms];
refim=[options.earoot,'templates',filesep,'mni_hires.nii'];
% add transforms:
for t=1:length(transforms)
    [pth1,fn1,ext1]=fileparts(transforms{t}{1});
    [pth2,fn2,ext2]=fileparts(transforms{t}{2});
    tr=[' -r ',refim,...
        ' -t [',ea_path_helper([pth1,filesep,fn1,ext1]),',0]',...
        ' -t [',ea_path_helper([pth2,filesep,fn2,ext2]),',0]'];
    cmd=[cmd,tr];
end

% add output:
cmd=[cmd,' -o [compositeDisplacementField.h5,1]'];

system(cmd)

