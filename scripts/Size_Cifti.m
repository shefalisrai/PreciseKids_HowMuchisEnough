function dtseries = Size_Cifti(subject, task)
%subject is either 'C' or 'P' depending on if you are running on child or parent 
%open all original spatial corrlelation maps (unthresholded) from ARC across
%all children and parents

wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
%open each individual spatial variant
for sub=2:26
        if sub >=10
            try
                dtseries{sub}=ciftiopen((sprintf('/Volumes/Prckids2/matlabdir/FD0.15mmCensored_Dtseries/sub-19730%d%s_%s_allsessions_15RM.dtseries.nii', sub, subject, task)),wbcommand);
                dtseries{sub}=dtseries{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        elseif sub <10
            try
                dtseries{sub}=ciftiopen((sprintf('/Volumes/Prckids2/matlabdir/FD0.15mmCensored_Dtseries/sub-197300%d%s_%s_allsessions_15RM.dtseries.nii', sub, subject, task)),wbcommand);
                dtseries{sub}=dtseries{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        else
            try
                dtseries{sub}=ciftiopen((sprintf('/Volumes/Prckids2/matlabdir/FD0.15mmCensored_Dtseries/sub-1973%d%s_%s_allsessions_15RM.dtseries.nii', sub, subject, task)),wbcommand);
                dtseries{sub}=dtseries{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        end
end

% dtseries_size=size(dtseriesC_RX{2});
    


end

