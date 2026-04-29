function parcelledpconnmap = Corr_Parcelled_pconn(thresh, subject, task)
%subject is either 'C' or 'P' depending on if you are running on child or parent 
%open all original spatial corrlelation maps (unthresholded) from ARC across
%all children and parents

wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';
%open each individual spatial variant
for sub=2:26
        if sub >=10
            try
                parcelledpconnmap{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/pconn_connectomes/sub-19730%d%s_%s_allsessions_%dRM_snr_200parcels_corr.pconn.nii', sub, subject, task, thresh)),wbcommand);
                parcelledpconnmap{sub}=parcelledpconnmap{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        elseif sub <10
            try
                parcelledpconnmap{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/pconn_connectomes/sub-197300%d%s_%s_allsessions_%dRM_snr_200parcels_corr.pconn.nii', sub, subject, task, thresh)),wbcommand);
                parcelledpconnmap{sub}=parcelledpconnmap{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        else
            try
                parcelledpconnmap{sub}=ciftiopen((sprintf('/Volumes/Prckids2/newmc_matlabdir/pconn_connectomes/sub-1973%d%s_%s_allsessions_%dRM_snr_200parcels_corr.pconn.nii', sub, subject, task, thresh)),wbcommand);
                parcelledpconnmap{sub}=parcelledpconnmap{sub}.cdata;
            catch
                fprintf('error: file does not exist\n')
            end
        end
end

%% Must manually delete 001 family column and 003 due to excluding 003C
% 
% % Parent correlation 
% for ncoeff = 1:24
%     for ncross = 1:24
%         for r=1:200
%             try
%                  %fprintf('now correlating child %d and parent %d', ncoeff, ncross);
%                  %Remove any NAN values from connectomes
%                  %parcelledpconnmapP_alltasks{1,ncoeff}(isnan(parcelledpconnmapP_alltasks{1,ncoeff}))=0;
%                  parcelledpconnmapP_alltasks{1,ncoeff}(isnan(parcelledpconnmapP_alltasks{1,ncoeff}))=0;
%                  parcelledpconnmapP_alltasks{1,ncross}(isnan(parcelledpconnmapP_alltasks{1,ncross}))=0;
%                  % Calculate the correlation
%                  % Get your correlated connectomes
%                  Alltasks_allcorrP{ncoeff, ncross}(r) = corr(parcelledpconnmapP_alltasks{1,ncoeff}(r,:)', parcelledpconnmapP_alltasks{1,ncross}(r,:)');
%             catch
%                 fprintf('error in corr function \n')
%             end
%         end
%     end
% end
% % 
% % Child correlation 
% % Child correlation 
% for ncoeff = 1:24
%     for ncross = 1:24
%         for r=1:200
%             try
%                 %fprintf('now correlating child %d and parent %d', ncoeff, ncross);
%                 
%                 % Check if the columns are empty
%                 if ~isempty(parcelledpconnmapC_alltasks{1,ncoeff}) && ~isempty(parcelledpconnmapC_alltasks{1,ncross})
%                     % Remove any NAN values from connectomes
%                     parcelledpconnmapC_alltasks{1,ncoeff}(isnan(parcelledpconnmapC_alltasks{1,ncoeff}))=0;
%                     parcelledpconnmapC_alltasks{1,ncross}(isnan(parcelledpconnmapC_alltasks{1,ncross}))=0;
%                     
%                     % Calculate the correlation
%                     % Get your correlated connectomes
%                     Alltasks_allcorrC{ncoeff, ncross}(r) = corr(parcelledpconnmapC_alltasks{1,ncoeff}(r,:)', parcelledpconnmapC_alltasks{1,ncross}(r,:)');
%                 else
%                     % Handle the case where one or both columns are empty
%                     fprintf('Columns %d and/or %d are empty\n', ncoeff, ncross);
%                 end
%                 
%             catch
%                 fprintf('Error in corr function \n');
%             end
%         end
%     end
% end
% 
% % 
% 
% % % ParentChild correlation 
% % for ncoeff = 1:24
% %     for ncross = 1:24
% %         for r=1:1000
% %             try
% %                  %fprintf('now correlating child %d and parent %d', ncoeff, ncross);
% %                  %Remove any NAN values from connectomes
% %                  parcelledpconnmapC_alltasks{1,ncoeff}(isnan(parcelledpconnmapC_alltasks{1,ncoeff}))=0;
% %                  parcelledpconnmapP_alltasks{1,ncross}(isnan(parcelledpconnmapP_alltasks{1,ncross}))=0;
% %                  % Calculate the correlation
% %                  % Get your correlated connectomes
% %                  Alltasks_allcorrCP{ncoeff, ncross}(r) = corr(parcelledpconnmapC_alltasks{1,ncoeff}(r,:)', parcelledpconnmapP_alltasks{1,ncross}(r,:)');
% %             catch
% %                 fprintf('error in corr function \n')
% %             end
% %         end
% %     end
% % end
% % 
% % % take the mean of each parcel
% Alltasks_allcorrPmean = cellfun(@(x) mean(x, 2, 'omitnan'), Alltasks_allcorrP,'UniformOutput',false);
% Alltasks_allcorrCmean = cellfun(@(x) mean(x, 2, 'omitnan'), Alltasks_allcorrC, 'UniformOutput', false);
%Alltasks_allcorrCPmean = cellfun(@(Alltasks_allcorrCP) mean(Alltasks_allcorrCP,2), Alltasks_allcorrCP,'UniformOutput',false);
% 
% % 
% % % convert cell array to matrix to plot
% Alltasks_allcorrPmean=cell2mat(Alltasks_allcorrPmean);
% Alltasks_allcorrCmean=cell2mat(Alltasks_allcorrCmean);
% % 
% % 
% % Assuming Alltasks_allcorrCmean is a 26x26 cell array
% [row, col] = size(Alltasks_allcorrCmean);
% 
% % Initialize a matrix with NaN values
% Alltasks_allcorrCmeanMatrix = nan(row, col);
% 
% % Fill the matrix with non-empty cell values
% for i = 1:row
%     for j = 1:col
%         if ~isempty(Alltasks_allcorrCmean{i, j})
%             Alltasks_allcorrCmeanMatrix(i, j) = mean(Alltasks_allcorrCmean{i, j}, 'omitnan');
%         end
%     end
% end
% 
% 
% % Alltasks_allcorrCPmean=cell2mat(Alltasks_allcorrCPmean);
% 
% 
%set diagonals to NaN
% v = nan;
% n = size(Alltasks_allcorrCmean,1);
% Alltasks_allcorrCmean(1:(n+1):end) = v;
% 
% v = nan;
% n = size(Alltasks_allcorrPmean,1);
% Alltasks_allcorrPmean(1:(n+1):end) = v;
% % 
% % n = size(Alltasks_allcorrPmean,1);
% % Alltasks_allcorrPmean(1:(n+1):end) = v;
% % 
% % n = size(Alltasks_allcorrCPmean,1);
% % Alltasks_allcorrCPmean(1:(n+1):end) = v;
% % 
% % %plot connectome
% imagesc(Alltasks_allcorrCmean)
% hcb=colorbar('ver'); % colorbar handle
% hcb.FontSize = 30;
% ax = gca;
% ax.CLim = [0.62 0.82];
% colorbar
% 
% % 
% imagesc(Alltasks_allcorrCmean)
% hcb=colorbar('ver'); % colorbar handle
% hcb.FontSize = 30;
% 
% imagesc(Alltasks_allcorrCPmean)
% hcb=colorbar('ver'); % colorbar handle
% hcb.FontSize = 30;



end

