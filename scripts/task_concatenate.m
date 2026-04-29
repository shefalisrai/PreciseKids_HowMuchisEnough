function dtseries = task_concatenate(subject, task)
%subject is either 'C' or 'P' depending on if you are running on child or parent 
%open all original spatial corrlelation maps (unthresholded) from ARC across
%all children and parents

wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

%open dtseries
for sub=2:26
        if sub >=10
            try
                dtseries{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-19730%d%s_%s_allsessions_censored.dtseries.nii', sub, subject, task)),wbcommand);
                dtseries{sub}=dtseries{sub}.cdata;
            catch
                fprintf('error: file does not exist for >10 \n')
            end
        elseif sub <10
            try
                dtseries{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-197300%d%s_%s_allsessions_censored.dtseries.nii', sub, subject, task)),wbcommand);
                dtseries{sub}=dtseries{sub}.cdata;
            catch
                fprintf('error: file does not exist for <10 \n')
            end
        else
            try
                dtseries{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-1973%d%s_%s_allsessions_censored.dtseries.nii', sub, subject, task)),wbcommand);
                dtseries{sub}=dtseries{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        end
end



%% after running this function for each task run the following:
% 
% for sub=2:26
%     try
%         dtseries_C_alltasks{sub} = [dtseries_C_DORA{sub} dtseries_C_RX{sub} dtseries_C_YT{sub}];
%     catch
%         fprintf('error: could not concatenate\n')
%     end
% end

% for sub=2:26
%     try
%         dtseries_P_alltasks{sub} = [dtseries_P_DORA{sub} dtseries_P_RX{sub} dtseries_P_YT{sub}];
%     catch
%         fprintf('error: could not concatenate\n')
%     end
% end


 %% save all tasks dtseries manually 
% % not part of function, need to run this manually
% 
% wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
% 
% % %%%%%% save for children 
% % 
% for sub=2:26
%         if sub >=10
%             try
%                 dtseries{1,sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-19730%dC_task-DORA_allsessions_censored.dtseries.nii', sub)),wbcommand);
%                 dtseries{1,sub}.cdata=dtseries_C_alltasks{1,sub};
%                 ciftisave(dtseries{1,sub},sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-19730%dC_alltasks_allsessions_censored.dtseries.nii', sub), wbcommand); 
%             catch
%                 fprintf('error: file does not exist\n')
%             end
%         elseif sub <10
%             try
%                 dtseries{1,sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-197300%dC_task-DORA_allsessions_censored.dtseries.nii', sub)),wbcommand);
%                 dtseries{1,sub}.cdata=dtseries_C_alltasks{1,sub};
%                 ciftisave(dtseries{1,sub},sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-197300%dC_alltasks_allsessions_censored.dtseries.nii', sub), wbcommand); 
%             catch
%                 fprintf('error: file does not exist\n')
%             end
%         else
%             try
%                 dtseries{1,sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-1973%dC_task-DORA_allsessions_censored.dtseries.nii', sub)),wbcommand);
%                 dtseries{1,sub}.cdata=dtseries_C_alltasks{1,sub};
%                 ciftisave(dtseries{1,sub},sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-1973%dC_alltasks_allsessions_censored.dtseries.nii', sub), wbcommand);
%             catch
%                 fprintf('error: file does not exist\n')
%             end
%         end
% end

% %%%%%% save for parents
% 
% for sub=2:26
%         if sub >=10
%             try
%                 dtseries{1,sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-19730%dP_task-DORA_allsessions_censored.dtseries.nii', sub)),wbcommand);
%                 dtseries{1,sub}.cdata=dtseries_P_alltasks{1,sub};
%                 ciftisave(dtseries{1,sub},sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-19730%dP_alltasks_allsessions_censored.dtseries.nii', sub), wbcommand); 
%             catch
%                 fprintf('error: file does not exist\n')
%             end
%         elseif sub <10
%             try
%                 dtseries{1,sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-197300%dP_task-DORA_allsessions_censored.dtseries.nii', sub)),wbcommand);
%                 dtseries{1,sub}.cdata=dtseries_P_alltasks{1,sub};
%                 ciftisave(dtseries{1,sub},sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-197300%dP_alltasks_allsessions_censored.dtseries.nii', sub), wbcommand); 
%             catch
%                 fprintf('error: file does not exist\n')
%             end
%         else
%             try
%                 dtseries{1,sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-1973%dP_task-DORA_allsessions_censored.dtseries.nii', sub)),wbcommand);
%                 dtseries{1,sub}.cdata=dtseries_P_alltasks{1,sub};
%                 ciftisave(dtseries{1,sub},sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_allses_dtseries/sub-1973%dP_alltasks_allsessions_censored.dtseries.nii', sub), wbcommand);
%             catch
%                 fprintf('error: file does not exist\n')
%             end
%         end
% end

end


