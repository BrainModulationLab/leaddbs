function ea_run_Martinos_Launchpad(options)

% This is a function that runs code for each subject on a cluster. It needs
% to be adapted to suit your needs. Then, you can "Export code" using
% Lead-DBS and simply change the command ea_run to ea_run_cluster.


jobID=ea_generate_guid;
options.spmdir=spm('dir');
save([options.root,options.patientname,filesep,'job_',jobID],'options')
setenv('ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS','1')
cmdstring=['cd ',options.earoot,' && pbsubmit -q matlab -O ',[options.root,options.patientname,filesep,'job_',jobID],'.out -E ',[options.root,options.patientname,filesep,'job_',jobID],'.err -c "matlab.new -singleCompThread -nodisplay -r "''ea_run runcluster ',[options.root,options.patientname,filesep,'job_',jobID],'''"'];

system(cmdstring);
