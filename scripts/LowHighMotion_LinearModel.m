% Linear model for low/high motion groups for child group and adult group
% Run LowHighMotion_UncensoredVolumesCalculation.m before this script to
% get uncensored volumes for each group
% Or load the saved matrices from below


%Load matched matrix from low/high motion groups (12 participants each)
load('PKdata_matchedmatrix_lowhighmotion_CP.mat');
load('PKdata_lowhighmotion_ordered.mat');
load('PKdata_lowhighmotion_uncensoredvolumes');

% Find the indices where the reliability first meets 0.7 for each row
[~, Timeat7_lowmotion_C_indices] = max(matched_matrix_lowmotion_C >= 0.7, [], 2);
[~, Timeat7_highmotion_C_indices] = max(matched_matrix_highmotion_C >= 0.7, [], 2);
[~, Timeat7_lowmotion_P_indices] = max(matched_matrix_lowmotion_P >= 0.7, [], 2);
[~, Timeat7_highmotion_P_indices] = max(matched_matrix_highmotion_P >= 0.7, [], 2);

child_indices=[low_motion_C'; high_motion_C'];
adult_indices=[low_motion_P'; high_motion_P'];
childadult_indices=[child_indices; adult_indices];


%% LME model to include family group

% Data preparation
ageGroup = [repmat({'Child'}, 24, 1); repmat({'Adult'}, 24, 1)];
uncensoredVols_motion = [uncensored_Timeat7_combinedtotal_lowmotion_C; uncensored_Timeat7_combinedtotal_highmotion_C; uncensored_Timeat7_combinedtotal_lowmotion_P; uncensored_Timeat7_combinedtotal_highmotion_P];
timeAtReliability = [Timeat7_lowmotion_C_indices; Timeat7_highmotion_C_indices; Timeat7_lowmotion_P_indices; Timeat7_highmotion_P_indices];
model_data_input = table(ageGroup, uncensoredVols_motion, timeAtReliability);

% Create a vector of zeros
familyID = [child_indices; adult_indices];
familymodel_data_input = table(ageGroup, uncensoredVols_motion, timeAtReliability, familyID);

% Fit the mixed-effects model
formula = 'timeAtReliability ~ ageGroup + uncensoredVols_motion + ageGroup*uncensoredVols_motion + (1|familyID)';
mdl_mixed = fitlme(familymodel_data_input, formula);
disp(mdl_mixed);


%% Plot mdl_mixed

% Fixed effects coefficients from your model
intercept = 5.5198;
ageGroup_coef = -1.8829;
uncensoredVols_motion_coef = 0.010315;
interaction_coef = 0.0023102;

% Generate data points for the regression lines
motion_values_range = linspace(0, 3500);

% Map age group strings to numeric values
age_group_numeric = zeros(size(ageGroup));
age_group_numeric(strcmp(ageGroup, 'Adult')) = 1;
age_group_numeric(strcmp(ageGroup, 'Child')) = 2;

% Calculate predicted values for each age group
predicted_values_adult = intercept + ageGroup_coef + uncensoredVols_motion_coef * motion_values_range + interaction_coef * motion_values_range;
predicted_values_child = intercept + uncensoredVols_motion_coef * motion_values_range;

% Plot the scatter plot with original data points
figure;
hold on;
scatter(uncensoredVols_motion(age_group_numeric == 1), timeAtReliability(age_group_numeric == 1), [], 'b', 'filled');
scatter(uncensoredVols_motion(age_group_numeric == 2), timeAtReliability(age_group_numeric == 2), [], 'r', 'filled');

% Plot the lines of best fit
plot(motion_values_range, predicted_values_adult, 'b', 'LineWidth', 2);
plot(motion_values_range, predicted_values_child, 'r', 'LineWidth', 2);

% Add legend and labels
legend({'Adult', 'Child', 'Adult Regression', 'Child Regression'}, 'Location', 'best');
xlabel('Uncensored Volumes to reach Time at Reliability > = 0.7');
ylabel('Time at Reliability > = 0.7');

% Add a title
title('Relationship between Uncensored Volumes and Time at Reliability by Age Group');

hold off;

