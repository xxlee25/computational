clear all
close all
clc

%load training_data.mat
%load validation_data.mat

load training_data_all.mat
load validation_data_all.mat

labels_var=training_data.Properties.VariableNames(2:end);

X=training_data{:,2:end};
Y=training_data{:,1};
X_val=validation_data{:,2:end};
Yval=validation_data{:,1};

Nsamples=numel(Y);
Nval=numel(Yval);

phi=0.00000000000001; % standart deviation treshold %0.00000000001
[X_std,avg_X,S_X] = normalize(X,phi);

for i=1:Nval
    Xval_std(i,:)=(X_val(i,:)-avg_X)./S_X;
end

%data_regrssor=[X,Y];
data_regressor=[X(2:2:end,:),Y(2:2:end,1)];

data_regressor=array2table(data_regressor);
data_regressor.Properties.VariableNames=string([labels_var,'OAS']);

data_validation=X_val(2:2:end,:);
Yval=Yval(2:2:end,1);
data_validation=array2table(data_validation);
data_validation.Properties.VariableNames=string(labels_var);

%%

calcRegressionMetrics = @(yTrue, yPred) deal( ...
    sqrt(mean((yTrue - yPred).^2)), ...                      % RMSE
    1 - sum((yTrue - yPred).^2) / sum((yTrue - mean(yTrue)).^2) ... % R²
);

%% ============ 1 Linear Model ============
load Linear2.mat 

Yestimated = Linear2.predictFcn(data_regressor);
Ypredicted = Linear2.predictFcn(data_validation);


[rmse_lin, r2_lin] = calcRegressionMetrics(Yval, Ypredicted);



%% ============ 2 Fine Tree ============

load Fine_Tree2.mat 
%view(Fine_Tree2.RegressionTree, 'Mode', 'graph')

Yestimated = Fine_Tree2.predictFcn(data_regressor);
Ypredicted = Fine_Tree2.predictFcn(data_validation);


[rmse_fine, r2_fine] = calcRegressionMetrics(Yval, Ypredicted);

%% ============ 3 Quadratic SVM ============

load Quadratic_SVM2.mat 

Yestimated = Quadratic_SVM2.predictFcn(data_regressor);
Ypredicted = Quadratic_SVM2.predictFcn(data_validation);


[rmse_quad, r2_quad] = calcRegressionMetrics(Yval, Ypredicted);

%% ============ 4 Optimal SVM ============

load Optimizable_SVM2.mat 

Yestimated = Optimizable_SVM2.predictFcn(data_regressor);
Ypredicted = Optimizable_SVM2.predictFcn(data_validation);


[rmse_opt, r2_opt] = calcRegressionMetrics(Yval, Ypredicted);


%% ============ Comparison 4 Models ============

models    = {'Linear Model','Fine Tree','Quadratic SVM','Optimal SVM'};
rmse_list = [rmse_lin, rmse_fine, rmse_quad, rmse_opt];
r2_list   = [r2_lin,   r2_fine,   r2_quad,   r2_opt ];

fprintf('\n--- Regression Performance on Validation Data ---\n');
fprintf('Model              RMSE         R^2\n');
for i = 1:numel(models)
    fprintf('%-17s   %.4f       %.4f\n', models{i}, rmse_list(i), r2_list(i));
end

% create a result table
results_table = table(models', rmse_list', r2_list', ...
    'VariableNames', {'Model','RMSE','R2'});
disp(results_table);

%% ========= Comparison of Four Models in One Plot ===========

figure('Name','Comparison of Four Models')

% Linear Model
subplot(2,2,1)
plot(Y(2:2:end,1), Linear2.predictFcn(data_regressor),'bo','LineWidth',1.5)
hold on
plot(Yval, Linear2.predictFcn(data_validation),'ro','LineWidth',1.5)
plot([0 8],[0 8],'k','LineWidth',2)
grid on
title('Linear Model')
xlabel('True Values')
ylabel('Predicted Values')

% Fine Tree
subplot(2,2,2)
plot(Y(2:2:end,1), Fine_Tree2.predictFcn(data_regressor),'bo','LineWidth',1.5)
hold on
plot(Yval, Fine_Tree2.predictFcn(data_validation),'ro','LineWidth',1.5)
plot([0 8],[0 8],'k','LineWidth',2)
grid on
title('Fine Tree')
xlabel('True Values')
ylabel('Predicted Values')

% Quadratic SVM
subplot(2,2,3)
plot(Y(2:2:end,1), Quadratic_SVM2.predictFcn(data_regressor),'bo','LineWidth',1.5)
hold on
plot(Yval, Quadratic_SVM2.predictFcn(data_validation),'ro','LineWidth',1.5)
plot([0 8],[0 8],'k','LineWidth',2)
grid on
title('Quadratic SVM')
xlabel('True Values')
ylabel('Predicted Values')

% Optimal SVM
subplot(2,2,4)
plot(Y(2:2:end,1), Optimizable_SVM2.predictFcn(data_regressor),'bo','LineWidth',1.5)
hold on
plot(Yval, Optimizable_SVM2.predictFcn(data_validation),'ro','LineWidth',1.5)
plot([0 8],[0 8],'k','LineWidth',2)
grid on
title('Optimal SVM')
xlabel('True Values')
ylabel('Predicted Values')

% Save the combined plot
saveas(gcf, 'Comparison_of_Four_Models.png');