function [sub_networks]=Create_Consensus_Networks(taskpconn_filepath, subID)
%After running create_pconn.m
%subID must be a string with subjectID and task, i.e. sub-1973002C_task-Dora

%------------------------------------------------------------------------
%%The following should be updated to the correct path for successful processing
infomap_path='/Users/shefalirai/anaconda3/bin';
wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
%------------------------------------------------------------------------

%create a new folder to store infomap outputs and thresholded connectomes - only need to do this once
%mkdir ../PRCKIDS_1973_Scripts infomap_outputs
%mkdir ../PRCKIDS_1973_Scripts thresholded_connectomes
infomap_outfolder='/Users/shefalirai/Desktop/infomap_outputs';

% open cifti timeseries smoothed with 4mm kernel
taskpconn_cifti=ciftiopen(taskpconn_filepath,wbcommand);

% store .cdata from pconn gifti, should get 91282x91282 matrix
taskpconn_connectome=taskpconn_cifti.cdata;

%remove any NaN values
taskpconn_connectome(isnan(taskpconn_connectome))=0;

% Threshold connectomes from top 2%-5%
count=0;
for thresh=0.02:0.01:0.05
    threshold=2+count;
    thresh_indices=matrix_thresholder_simple(taskpconn_connectome, thresh);
    mat2pajek_byindex(taskpconn_connectome, thresh_indices, sprintf('/Users/shefalirai/Desktop/thresholded_connectomes/sub-1973018C_threshold%g_200parcels_17nets', threshold));
    count=count+1;
end

% Run Infomap & Consensus Networks
% Infomap run from Gordon paper: [infomapfolder '/Infomap-0.15.7/Infomap --clu -2 -N' num2str(reps) ' ' pajekfilename ' ' pathstr]);

% Threshold 2%-5% and run Infomap to create networks for each subject
for threshold=2:5
        pajekfilename=(sprintf('/Users/shefalirai/Desktop/thresholded_connectomes/sub-1973018C_threshold%g_200parcels_17nets', threshold));
        reps=1000; %can do testing with less than 1000 reps if needed 
        system([infomap_path '/infomap --clu -2 -N' num2str(reps) ' ' pajekfilename ' ' infomap_outfolder]); % not using -s random seed since it gives different results everytime 
end

% After running Infomap, open .clu network file for each subject across each threshold
for threshold=2:5
        fid=fopen(sprintf([infomap_outfolder '/sub-1973018C_threshold%g_200parcels_17nets.clu'], threshold));
        sub_networks{threshold}= cell2mat(textscan(fid,'%f %f %f', 'headerlines', 13, 'delimiter', ' ')); 
        fclose(fid);
end

end
    

