function affinefile = ea_brainsfit(varargin)
% Wrapper for BRAINSFit

fixedVolume=varargin{1};
movingVolume=varargin{2};
outputVolume=varargin{3};

if nargin>=4
    writematout=varargin{4};
else
    writematout=1;
end

if nargin>=5
    if isempty(varargin{5}) % [] or {} or ''
        otherfiles = {};
    elseif ischar(varargin{5}) % single file, make it to cell string
        otherfiles = varargin(5);
    else % cell string
        otherfiles = varargin{5};
    end
else
    otherfiles = {};
end

volumedir = [fileparts(ea_niifileparts(movingVolume)), filesep];

fixedVolume = ea_niigz(fixedVolume);
movingVolume = ea_niigz(movingVolume);
outputVolume = ea_niigz(outputVolume);

% name of the output transformation
[~, mov] = ea_niifileparts(movingVolume);
[~, fix] = ea_niifileparts(fixedVolume);
xfm = [mov, '2', fix, '_brainsfit'];

fixparams = [' --fixedVolume ' , ea_path_helper(fixedVolume), ...
             ' --movingVolume ', ea_path_helper(movingVolume), ...
             ' --outputVolume ', ea_path_helper(outputVolume), ...
             ' --useRigid --useAffine' ...
             ' --samplingPercentage 0.005' ...
             ' --removeIntensityOutliers 0.005' ...
             ' --interpolationMode Linear' ...
             ' --outputTransform ', ea_path_helper([volumedir, xfm, '.h5'])];

% first attempt...
paramset{1} = [fixparams, ...
               ' --initializeTransformMode useGeometryAlign' ...
               ' --maskProcessingMode ROIAUTO' ...
               ' --ROIAutoDilateSize 3'];

% second attempt...
paramset{2} = [fixparams, ...
               ' --initializeTransformMode useGeometryAlign'];

% third attempt...
if exist([volumedir, xfm, '.h5'],'file')
    paramset{3} = [fixparams, ...
                   ' --maskProcessingMode ROIAUTO' ...
                   ' --ROIAutoDilateSize 3' ...
                   ' --initializeTransformMode Off' ...
                   ' --initialTransform ', ea_path_helper([volumedir, xfm, '.h5'])];
else
    paramset{3} = [fixparams, ...
                   ' --maskProcessingMode ROIAUTO' ...
                   ' --ROIAutoDilateSize 3'];
end

% fourth attempt..
if exist([volumedir, xfm, '.h5'],'file')
    paramset{4} = [fixparams, ...
                   ' --initializeTransformMode Off' ...
                   ' --initialTransform ', ea_path_helper([volumedir, xfm, '.h5'])];
else
    paramset{4} = fixparams;
end

basename = [fileparts(mfilename('fullpath')), filesep, 'BRAINSFit'];
if ispc
    BRAINSFit = [basename, '.exe '];
else
    BRAINSFit = [basename, '.', computer('arch'), ' '];
end

ea_libs_helper
for trial = 1:4
    cmd = [BRAINSFit, paramset{trial}];
    if ~ispc
        status = system(['bash -c "', cmd, '"']);
    else
        status = system(cmd);
    end
    if status == 0
        fprintf(['\nBRAINSFit with parameter set ', num2str(trial), '\n']);
        break
    end
end

if ~isempty(otherfiles)
    for fi = 1:numel(otherfiles)
        ea_brainsresample(fixedVolume, otherfiles{fi}, otherfiles{fi}, ...
                                    [volumedir, xfm, '.h5']);
    end
end

if ~writematout
    delete([volumedir, xfm, '.h5']);
    affinefile = {};
else
    affinefile = {[volumedir, xfm, '.h5']};
end

fprintf('\nBRAINSFit LINEAR registration done.\n');
