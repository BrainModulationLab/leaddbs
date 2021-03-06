function [showcortex,cortex] = ea_showcortex(varargin)
% This function shows a cortical reconstruction in the 3D-Scene viewer. It
% reads in cortex.mat found in the eAuto_root/templates/cortex folder, or 
% in the patientdirectory on button press (Cortical Reconstruction
% Visualization) in the Lead-Anatomy scene. To view patient specific 
% cortical reconstructions, load them to the patient directory using
% ea_importfs via the "Import FS" button in the main Lead DBS GUI.
% __________________________________________________________________________________
% Copyright (C) 2017 University of Pittsburgh (UPMC), Brain Modulation Lab
% Ari Kappel

if nargin==2
    options=varargin{2};
end
if nargin>2
    elstruct=varargin{2};
    options=varargin{3};
end

resultfig=varargin{1};
set(0, 'currentfigure', resultfig);  % for figures
showcortex=getappdata(resultfig,'showcortex');
try delete(showcortex); end

% Initial Opening
if ~isfield(getappdata(resultfig),'cortex')
    color = options.prefs.d3.cortexcolor; % default color is gray
    alpha = options.prefs.d3.cortexalpha; % default alph is 0.333
else
    
    color = options.prefs.d3.cortexcolor;
    appdata = getappdata(resultfig);
    appdata = getappdata(appdata.awin);
    alpha = str2double(appdata.UsedByGUIData_m.cortexalpha.String);
    clear appdata
end

    
nm=[0:2]; % native and mni
try
    nmind=[options.atl.pt,options.atl.can,options.atl.ptnative]; % which shall be performed?
catch
    nmind=[0 1 0];
end
nm=nm(logical(nmind)); % select which shall be performed.

% switch between patient and template cortex
slicecontroldata = getappdata(gcf);
if nm==1 && ~isempty(strfind(slicecontroldata.templateused,'Patient'))
    nm = 0;
end

% macaque brain currently not supported % mcr=ea_checkmacaque(options);
% mcr = '';

for nativemni=nm % switch between native and mni space.
    
    switch nativemni
        case 0 % patient cortex in mni space in future release
            % root=[options.root,options.patientname,filesep];
            % adir=[root,''];
            if ~exist([ea_space(options,'cortex'),'CortexHiRes.mat'],'file')
                ea_error('Missing Template Cortex')
                return
            end
            adir=ea_space(options,'cortex');
            casestr = 'Template';
            reslice='yes'; %future option to import patient brain and reslice to mni space
        case 1 % template cortex in mni space
            %root=[options.earoot];
            if ~exist([ea_space(options,'cortex'),'CortexHiRes.mat'],'file')
                ea_error('Missing Template Cortex')
                return
            end
            adir=ea_space(options,'cortex');
            casestr = 'Template';
            reslice='no';
        case 2 % patient cortex in native space
            root=[options.root,options.patientname,filesep];
            adir=[root,'cortex/'];
            casestr = 'Patient';
            reslice='no';
    end
end

% Check if CortexHiRes.mat and CortexLowRes_*.mat already exists
files = dir(adir); files = files(cellfun(@(x) isempty(regexp(x, '^\.', 'once')), {files.name}));
files = files(~[files.isdir]); files = {files(~cellfun(@isempty , strfind({files.name},'Cortex'))).name};

if size(files,2)>=2
    str = [{['More than one Cortex found in the ' casestr ' folder.']},...
        {'Please, select which Cortex you would like to view.'}];
    file = char(files(listdlg('PromptString',str,'Name',options.patientname,...
        'SelectionMode','single','ListString',files,...
        'ListSize',[250 150])));
    cortex = load([adir,file],'Vertices','Faces');
elseif ~isempty(files)
    file = files{1};
    cortex = load([adir,file],'Vertices','Faces');
else
    fprintf('No Cortex found in patient directory. \nRunning Import FS...\n')
    ea_importfs(options)
    try
        load([adir,'CortexHiRes.mat','Vertices','Faces']);
    catch
    end
end

% % reslice patient cortex to mni space in future release
% % for now always use template cortex in mni space
% if strcmp(reslice,'yes'); end

% Show cortex
set(0, 'currentfigure', resultfig); hold on
showcortex = patch('vertices',cortex.Vertices,'faces',cortex.Faces(:,[1 3 2]),...
    'facecolor',color,'edgecolor','none','FaceAlpha',alpha,...
    'facelighting', 'gouraud', 'specularstrength', .25);
setappdata(resultfig,'showcortex',showcortex);
% camlight('headlight','infinite'); axis equal;
