function Open_Cifti(file_path)
%Function to open cifti timeseries
%subID must be a string with subjectID and task, i.e. sub-1973002C_task-Dora
%filepath input must be a string locating where the subject's cifti timeseries is located

file = file_path;
[filepath,name,ext] = fileparts(file);

%------------------------------------------------------------------------
%%The following should be added to the matlab path for successful processing
addpath(genpath('~/Programs/matlab/gifti-1.6'))
addpath(genpath('~/Programs/matlab/BCT'))
addpath(genpath('~/Programs/matlab/cifti_matlab-master'))
wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
outputcifti=sprintf('/Users/shefalirai/Desktop/%s%s',name,ext);
%------------------------------------------------------------------------

disp('current working directory is:')
disp(pwd)
disp('subject and task selected for processing is:')
disp(name)


% open cifti timeseries smoothed with 4mm kernel
subject_cifti=ciftiopen(file_path,wbcommand);

% store .cdata from original gifti
subject_ciftidata=subject_cifti.cdata;

% mean center timeseries
subject_ciftimc=(subject_ciftidata'-mean(subject_ciftidata'))';

%if needed, save cifti to folder as specified by path above
subject_cifti.cdata=subject_ciftimc;
ciftisave(subject_cifti, outputcifti, wbcommand); 

end

