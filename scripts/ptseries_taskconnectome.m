function ptseries_task = ptseries_taskconnectome(thresh, subject, task)
%update variabel to reflect which task between DORA, YT and RX
% For 200 parcels
wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

for sub=2:26
        if sub >=10
            try
                ptseries_task{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_ptseries/sub-19730%d%s_%s_allsessions_%dRM_200parcels.ptseries.nii', sub, subject, task, thresh)),wbcommand);
                ptseries_task{sub}=ptseries_task{sub}.cdata;
            catch
                fprintf('error: file does not exist for >10 \n')
            end
        elseif sub <10
            try
                ptseries_task{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_ptseries/sub-197300%d%s_%s_allsessions_%dRM_200parcels.ptseries.nii', sub, subject, task, thresh)),wbcommand);
                ptseries_task{sub}=ptseries_task{sub}.cdata;
            catch
                fprintf('error: file does not exist for <10 \n')
            end
        else
            try
                ptseries_task{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/censored_ptseries/sub-1973%d%s_%s_allsessions_%dRM_200parcels.ptseries.nii', sub, subject, task, thresh)),wbcommand);
                ptseries_task{sub}=ptseries_task{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        end
end

%% Correlation to create connectomes

% % must manually delete sub01 and sub03 
% 
% % Create connectomes 
% for sub=1:24
%             try
%                 ptseries_RX_connectome{sub} =  corr(ptseries_RX{sub}');
%                 ptseries_RX_connectome{sub} =  corr(ptseries_RX{sub}');
% 
%                 %Remove any NAN values from connectomes
%                 ptseries_RX_connectome{sub}(isnan(ptseries_RX_connectome{sub}))=0;
%                 ptseries_RX_connectome{sub}(isnan(ptseries_RX_connectome{sub}))=0;
%             catch
%                 fprintf('error in corr function \n')
%             end
% end
% 
% 
% % Child correlation 
% for ncoeff = 1:24
%     for ncross = 1:24
%         for r=1:200
%             try
%                  %fprintf('now correlating child %d and parent %d', ncoeff, ncross);
%                  % Calculate the correlation
%                  % Get your correlated connectomes
%                  ptseries_RX_corr{ncoeff, ncross}(r) = corr(ptseries_RX_connectome{1,ncoeff}(r,:)', ptseries_RX_connectome{1,ncross}(r,:)');
%             catch
%                 fprintf('error in corr function \n')
%             end
%         end
%     end
% end
% 
% % take the mean of each parcel
% ptseries_RX_corrmean = cellfun(@(ptseries_RX_corr) mean(ptseries_RX_corr,2), ptseries_RX_corr,'UniformOutput',false);
% 
% 
% % convert cell array to matrix to plot
% ptseries_RX_corrmean=cell2mat(ptseries_RX_corrmean);
% 
% %set diagonals to NaN
% v = nan;
% n = size(ptseries_RX_corrmean,1);
% ptseries_RX_corrmean(1:(n+1):end) = v;
% 
% % %plot connectome
% imagesc(ptseries_RX_corrmean)
% hcb=colorbar('ver'); % colorbar handle
% hcb.FontSize = 30;
% ax = gca;
% ax.CLim = [0.42 0.52];
% colorbar

end

