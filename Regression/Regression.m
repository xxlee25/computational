clc
clear

addpath(fullfile(pwd, 'DataProcessing'));
addpath(fullfile(pwd, 'FileManagement'));
addpath(fullfile(pwd, 'Modeling'));

deleteAllXlsx();

group_id = 14;
group_prefix = sprintf('Group_%d_', group_id);
filepath_1 = fullfile(pwd, "data_1.xlsx");
filepath_2 = fullfile(pwd, "data_2.xlsx");
filepath_3 = fullfile(pwd, "data_3.xlsx");
filepath_4 = fullfile(pwd, "data_4.xlsx");
filepath_val = fullfile(pwd, "data_val.xlsx");

% range of three variables
% Rows: T, pH, aW respectively
% Cols: lower bound, upper bound
ranges = [
    16 24; % T
    5.6 6.4; % pH
    0.982 0.99]; % aW
var_names = {'T', 'pH', 'aW'};

p_threshold = 1 - 0.95;


% model = fitlm(data, [ ...
%     'growthRate ~ T + pH + aW ' ...
%     '+ T^2 + pH^2 + aW^2 + T*pH + T*aW + pH*aW ' ...
%     '+ T*pH*aW']);
% 
% confidence_bounds = model.coefCI(0.99);


% Task 1


if ~exist(filepath_1, "file")
    % Clear old data files.
    deleteExperimentalConditionsFile();
    deleteAllXlsxWithPrefix(group_prefix);
    % Generate random conditions(no more than 30, as required)
    cond_1 = randomDataGenerator(30, ranges);
    % Run experiment with the condition
    cond2Datafile(cond_1, group_id);
    % Save a copy of the latest experiment output under a fix filename
    saveACopy(latestXlsxUnderPwd(group_prefix), filepath_1);
end

% Load the data from the file we just saved.
data_1 = loadData(filepath_1);
% Fit the full model(with a all-true significance mask, just to get 
% the p_values of all the thetas.
[~, p_values1, ~, ~] = fitModel(data_1, 0.99, true(1, 11));
% Get the significance mask of 95%.
significance_1 = p_values1 < p_threshold;
% Fit again, this time pass the mask we got from previous fit to simpify 
% the model, get the final parameters and confidence bounds
[theta_hat1, ~, lower1, upper1] = fitModel(data_1, 0.99, significance_1);
% Get the final model by installing the final parameters to the model.
model_1 = @(X) responseSurfaceModel(theta_hat1, significance_1, X);

% Task 2
if ~exist(filepath_2, "file")
    deleteExperimentalConditionsFile();
    deleteAllXlsxWithPrefix(group_prefix);
    % Generate full factorial pattern table
    pattern_2 = fullFactorialPattern();
    % Generate the condition based on the pattern and the range of each
    % variable. 
    cond_2 = pattern2cond(pattern_2, ranges);
    % Convert the condition matrix to a table
    cond_2 = array2table(cond_2, "VariableNames", var_names);
    cond2Datafile(cond_2, group_id);
    saveACopy(latestXlsxUnderPwd(group_prefix), filepath_2); 
end

data_2 = loadData(filepath_2);
[~, p_values2, ~, ~] = fitModel(data_2, 0.9, true(1, 11));
significance_2 = p_values2 < p_threshold;
[theta_hat2, ~, lower2, upper2] = fitModel(data_2, 0.9, significance_2);
model_2 = @(X) responseSurfaceModel(theta_hat2, significance_2, X);



% Task 3
if ~exist(filepath_3, "file")
    deleteExperimentalConditionsFile();
    deleteAllXlsxWithPrefix(group_prefix);
    % Generate central composite pattern table
    pattern_3 = centralCompositePattern(0.5946);
    cond_3 = pattern2cond(pattern_3, ranges);
    cond_3 = array2table(cond_3, "VariableNames", var_names);
    cond2Datafile(cond_3, group_id);
    saveACopy(latestXlsxUnderPwd(group_prefix), filepath_3);
end

data_3 = loadData(filepath_3);
[~, p_values3, ~, ~] = fitModel(data_3, 0.95, true(1, 11));
significance_3 = p_values3 < p_threshold;
[theta_hat3, ~, lower3, upper3] = fitModel(data_3, 0.95, significance_3);
model_3 = @(X) responseSurfaceModel(theta_hat3, significance_3, X);

% Task 4

% In order to compare the performance of these models, we need to create 
% a unified dataset that is different from any of their training sets. 
% So we randomly generate some new conditions and re-run the experiment.
if ~exist(filepath_val, "file")
    deleteExperimentalConditionsFile();
    deleteAllXlsxWithPrefix(group_prefix);
    N = 3000; % size of the validation dataset
    cond_val = randomDataGenerator(N, ranges);
    cond2Datafile(cond_val, group_id);
    saveACopy(latestXlsxUnderPwd(group_prefix), filepath_val);
end

data_val = loadData(filepath_val);

% Store the models in a cell array for easy access
models = {model_1, model_2, model_3};

% Preallocate an array to store the evaluation scores (RMSE)
scores = zeros(1, length(models));

% Loop through each model to evaluate its performance
% Call the evaluation function for each model, passing in the validation 
% data.
% Store the resulting score in the scores array
for i = 1:length(models)
    scores(i) = evaluation(models{i}, data_val);
end

% Find the best score (smallest RMSE) and its corresponding model index
[best_score, best_model_idx] = min(scores);

% Retrieve the best model
best_model = models{best_model_idx};


if ~exist(filepath_4, "file")
    M = 1000;
    deleteExperimentalConditionsFile();
    deleteAllXlsxWithPrefix(group_prefix);
    values = [17, 6, 0.985];
    cond_4 = repDataGenerator(values, var_names, M);
    cond2Datafile(cond_4, group_id);
    saveACopy(latestXlsxUnderPwd(group_prefix), filepath_4);
end

data_4 = loadData(filepath_4);

y = data_4.growthRate;
y_hat = best_model(data_4);

binWidth = 0.001; % Set the bin width based on precision of data
minValue = min(y) - binWidth/2;
maxValue = max(y) + binWidth/2;
binEdges = minValue:binWidth:maxValue;

histogram(y, ...
    'BinEdges', binEdges, ...
    'FaceColor', 'blue', ...
    'EdgeColor', 'black');

hold on; % Allow overlaying additional plots

% Fit the data to a normal distribution
mu = mean(y); % Mean of the data
sigma = std(y); % Standard deviation of the data

% Generate x values for the normal distribution curve
x = linspace(min(y), max(y), 1000);

% Compute the normal distribution PDF using normpdf
normal_pdf = normpdf(x, mu, sigma);

% Plot the normal distribution curve
plot(x, normal_pdf, 'r-', 'LineWidth', 2);

line([y_hat(1) y_hat(1)], ylim, 'Color', 'g', 'LineWidth', 2, 'LineStyle', '--');


xlabel('Growth Rate');
ylabel('Frequency');
title('A Cute Graph');

