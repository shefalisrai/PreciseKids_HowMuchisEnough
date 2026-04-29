function avg_spatialvariants = averaged_spatialvariants(subject, task, thresh)
%subject is either 'C' or 'P' depending on if you are running on child or parent 
%Thresh is 10 for 0.1
%Average spatial variants thresholded maps from ARC across all children
%into 1 averaged output


wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
%open each individual spatial variant
for sub=2:26
        if sub >=10
            try
                spatialvariants{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_spatialcorr/sub-19730%d%s_%s_spatialVariants_thresh%d.dtseries.nii', sub, subject, task, thresh)),wbcommand);
                spatialvariants{sub}=spatialvariants{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        elseif sub <10
            try
                spatialvariants{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_spatialcorr/sub-197300%d%s_%s_spatialVariants_thresh%d.dtseries.nii', sub, subject, task, thresh)),wbcommand);
                spatialvariants{sub}=spatialvariants{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        else
            try
                spatialvariants{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_spatialcorr/sub-1973%d%s_%s_spatialVariants_thresh%d.dtseries.nii', sub, subject, task, thresh)),wbcommand);
                spatialvariants{sub}=spatialvariants{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        end
end

%average across subjects
avg_spatialvariants=(spatialvariants{2}+spatialvariants{4}+spatialvariants{5}+spatialvariants{6}+spatialvariants{7}+spatialvariants{8}+spatialvariants{9}+spatialvariants{10}+spatialvariants{11}+spatialvariants{12}+spatialvariants{13}+spatialvariants{14}+spatialvariants{15}+spatialvariants{16}+spatialvariants{17}+spatialvariants{18}+spatialvariants{19}+spatialvariants{20}+spatialvariants{21}+spatialvariants{22}+spatialvariants{23}+spatialvariants{24}+spatialvariants{25}+spatialvariants{26})/24;



%% visualize on the surface
% avg_spatvar=ciftiopen('/Volumes/Prckids2/newmc_spatialcorr/templateSpatialCorrMap.dtseries.nii', wbcommand);
% avg_spatvar.cdata=avgspatvarC;
% ciftisavereset(avg_spatvar, '/Users/shefalirai/Desktop/AveragedChildren_task-RX_spatialVariants_thresh10.dtseries.nii', wbcommand);
% 

% % % to combine across 3 tasks
% alltask_avg_spatialvariant=(doraC_spatvar + rxC_spatvar + ytC_spatvar)/3;
% alltask_avg_spatvar=ciftiopen('/Users/shefalirai/Desktop/templateSpatialCorrMap.dtseries.nii', wbcommand);
% alltask_avg_spatvar.cdata=alltask_avg_spatialvariant;
% ciftisavereset(alltask_avg_spatvar, '/Users/shefalirai/Desktop/AveragedC_alltasks_spatialVariants_thresh10.dtseries.nii', wbcommand);
% 

end
