clear all
close all
clc

%load training_data.mat
%load validation_data.mat

load training_data_small.mat
load validation_data_small.mat

labels_var=training_data.Properties.VariableNames(2:end);

X=training_data{:,2:end};
Y=training_data{:,1};
X_val=validation_data{:,2:end};
Yval=validation_data{:,1};

Nsamples=numel(Y);
Nval=numel(Yval);

for i=1:size(X,1)
    if Y(i,1)<=0.5
        C_true(i)=0;
    else
        C_true(i)=1;
    end
end

for i=1:size(X_val,1)
    if Yval(i,1)<=0.5
        Cval_true(i)=0;
    else
        Cval_true(i)=1;
    end
end

phi=0.00000000000001; % standart deviation treshold %0.00000000001
[X_std,avg_X,S_X] = normalize(X,phi);

for i=1:Nval
    Xval_std(i,:)=(X_val(i,:)-avg_X)./S_X;
end

data_classifier=[X,C_true'];

data_classifier=array2table(data_classifier);
data_classifier.Properties.VariableNames=string([labels_var,'Class']);

data_validation=X_val;

data_validation=array2table(data_validation);
data_validation.Properties.VariableNames=string(labels_var);

%% =============== 1 kNN =================
fold=10;                             % samples per fold
list_samples=(1:1:Nsamples);
k_fold=floor(Nsamples/fold);       % number of folds
if Nsamples/fold>k_fold
    k_fold=k_fold+1;
end
folds=cell(k_fold,1);
for i=1:k_fold-1
    fold_ite(i)=fold;
    folds{i} = datasample(list_samples,fold,'Replace',false)';
    for j=1:fold
        list_samples(list_samples==folds{i}(j))=[];
    end
end    
folds{k_fold,1}=list_samples';
fold_ite(k_fold)=size(list_samples,2);
list_samples=(1:1:Nsamples);

%%find best k using accuracy in cross-validation
for i=2:20
    for j=1:k_fold
        
        Ncval=size(folds{j},1);
        for k=1:Ncval
            list_samples(list_samples==folds{j}(k))=[];
        end
        X_training=X(list_samples,:);
        C_training_true=C_true(1,list_samples);
        X_testing=X(folds{j},:);
        C_testing_true=C_true(1,folds{j});
        
        knn_model=fitcknn(X_training,C_training_true','NumNeighbors',i,'Standardize',1);
        C_testing = predict(knn_model,X_testing);
        true_fresh=numel(C_testing_true(C_testing_true==0))-sum(C_testing(C_testing_true==0));
        true_aged=sum(C_testing(C_testing_true==1));
        accuracy(j,i-1)=(true_fresh+true_aged)/Ncval;
        
        list_samples=(1:1:Nsamples);
        
    end
end

figure
plot(2:1:20,mean(accuracy,1))


knn_model=fitcknn(X,C_true','NumNeighbors',9,'Standardize',1);
Cval_knn = predict(knn_model,X_val);

figure
plotconfusion(Cval_true,Cval_knn')
title('kNN - Validation Confusion Matrix')

saveas(gcf, 'knn Confusion Matrix.png');

%% ================= 2 Coarse Tree =================

load Coarse_tree
view(Coarse_tree.ClassificationTree,'Mode','graph')

Cval_coarseTree = Coarse_tree.predictFcn(data_validation);

figure('Name','Confusion Matrix: Coarse Tree')
plotconfusion(Cval_true,Cval_coarseTree')
title('Coarse Tree - Validation Confusion Matrix')

saveas(gcf, 'Coarse Tree Confusion Matrix.png');

%% ================= 3 Fine tree =================

load Fine_tree.mat

view(Fine_tree.ClassificationTree,'Mode','graph')
Cval_fineTree = Fine_tree.predictFcn(data_validation);

figure('Name','Confusion Matrix: Fine Tree')
plotconfusion(Cval_true,Cval_fineTree')
title('Fine Tree - Validation Confusion Matrix')

saveas(gcf, 'Fine Tree Confusion Matrix.png');

%% ================= 4 Boosted trees ================= 

load Boosted_tree.mat  


%view(Boosted_tree.ClassificationEnsemble.Trained{3}, 'Mode','graph')

Cval_boost = Boosted_tree.predictFcn(data_validation);

figure('Name','Confusion Matrix: Boosted Trees')
plotconfusion(Cval_true, Cval_boost')
title('Boosted Trees - Validation Confusion Matrix')

saveas(gcf, 'Boosted Trees Confusion Matrix.png');

%% ================= 5 Optimal SVM =================


load Optimal_SVM.mat

Cval_optSVM = Optimal_SVM.predictFcn(data_validation);

figure('Name','Confusion Matrix: Optimal SVM')
plotconfusion(Cval_true,Cval_optSVM')
title('Optimal SVM - Validation Confusion Matrix')

saveas(gcf, 'Optimal_SVM_Confusion_Matrix.png');


%% === Calculate the accuracy of 5 models on the validation set ===

models = {'kNN', 'Coarse Tree', 'Fine Tree', 'Boosted Trees', 'Optimal SVM'};
preds  = {Cval_knn, Cval_coarseTree, Cval_fineTree, Cval_boost, Cval_optSVM};

fprintf('\nValidation Accuracy of Each Model:\n');
for i = 1:length(models)
    confMat = confusionmat(Cval_true, preds{i});
    acc = sum(diag(confMat)) / sum(confMat(:));
    fprintf('%s: %.2f%%\n', models{i}, acc*100);
end






