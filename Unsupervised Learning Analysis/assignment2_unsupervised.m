clear all
close all
clc

%% ---------------------------------
% 1. LOAD + PREPARE DATA
%% ---------------------------------
% load data set
load training_set.mat
load validation_set.mat

% extract name of variables
labels_var=categorical(training_set.Properties.VariableNames);

% data from table to matrix
X=training_set{:,:};            % training data
X_val=validation_set{:,:};      % validation data

% log transform from column 12 onward
X(:,12:end)=log(X(:,12:end));
X_val(:,12:end)=log(X_val(:,12:end));

Nvar=numel(labels_var);
Nval=size(X_val,1);
Nsamples= size(X,1);

%% Normalizing the data
phi=1e-8; % small stdev threshold
[X_std,avg_X,S_X] = normalize(X,phi);   % training data to train PCA model

% Apply the same normalization to validation data
Xval_std = (X_val - avg_X)./S_X;

% Combine all data
X_all_raw = [X_std; Xval_std];

%% ---------------------------------
% 2. K-MEANS ON RAW DATA
%% ---------------------------------
clust_eva = 2:8;  % cluster candidates
clust = zeros(size(X_all_raw,1),numel(clust_eva));

for i=1:numel(clust_eva)
    num_clust = clust_eva(i);
    clust(:,i) = kmeans(X_all_raw,num_clust,'Replicates',50);
end

eva_CH_km_raw = evalclusters(X_all_raw, clust,'CalinskiHarabasz');
eva_DB_km_raw = evalclusters(X_all_raw, clust,'DaviesBouldin');
eva_SI_km_raw = evalclusters(X_all_raw, clust,'Silhouette');


% choose the best from Silhouette:
bestIdx_km_raw = eva_SI_km_raw.OptimalK;  
bestK_km_raw   = clust_eva(bestIdx_km_raw);

finalClust_km_raw = kmeans(X_all_raw, bestK_km_raw,'Replicates',50);

% Store the best metric values for raw k-means
CH_km_raw = eva_CH_km_raw.CriterionValues(bestIdx_km_raw);
DB_km_raw = eva_DB_km_raw.CriterionValues(bestIdx_km_raw);
SI_km_raw = eva_SI_km_raw.CriterionValues(bestIdx_km_raw);

%% ---------------------------------
% 3. PCA + K-MEANS
%% ---------------------------------
% choose Nlatent=3

% Train final PCA on all X_std
Nlatent=3;
[T_est, P_est, ~, ~, ~] = PCA_decomp(X_std,1.05,"EIG",Nlatent,"False");

% Get PCA scores for the validation set
[Tval_est, ~, ~, ~] = scores_PCA(P_est,T_est,Xval_std,Nvar,Nval);

% Combine all scores
T_all = [T_est; Tval_est];

% K-means on PCA scores
clust_eva_pca = 2:8;
clust_pca = zeros(size(T_all,1),numel(clust_eva_pca));
for i=1:numel(clust_eva_pca)
    num_clust = clust_eva_pca(i);
    clust_pca(:,i) = kmeans(T_all,num_clust,'Replicates',50);
end

eva_CH_km_pca = evalclusters(T_all, clust_pca,'CalinskiHarabasz');
eva_DB_km_pca = evalclusters(T_all, clust_pca,'DaviesBouldin');
eva_SI_km_pca = evalclusters(T_all, clust_pca,'Silhouette');

bestIdx_km_pca = eva_SI_km_pca.OptimalK;  
bestK_km_pca   = clust_eva_pca(bestIdx_km_pca);

% final partition
finalClust_km_pca = kmeans(T_all, bestK_km_pca,'Replicates',50);

% store best metric values
CH_km_pca = eva_CH_km_pca.CriterionValues(bestIdx_km_pca);
DB_km_pca = eva_DB_km_pca.CriterionValues(bestIdx_km_pca);
SI_km_pca = eva_SI_km_pca.CriterionValues(bestIdx_km_pca);

%% ---------------------------------
% 4. t-SNE + K-MEANS
%% ---------------------------------
% For small data, 2D is typical used. 

rng(1);  
X_tsne = tsne(X_all_raw, 'NumDimensions',2, 'Perplexity',5, 'Verbose',1);

% K-means in t-SNE space
clust_eva_tsne = 2:8;
clust_tsne = zeros(size(X_tsne,1),numel(clust_eva_tsne));
for i=1:numel(clust_eva_tsne)
    num_clust = clust_eva_tsne(i);
    clust_tsne(:,i) = kmeans(X_tsne, num_clust, 'Replicates',50);
end

eva_CH_tsne = evalclusters(X_tsne, clust_tsne, 'CalinskiHarabasz');
eva_DB_tsne = evalclusters(X_tsne, clust_tsne, 'DaviesBouldin');
eva_SI_tsne = evalclusters(X_tsne, clust_tsne, 'Silhouette');

bestIdx_tsne = eva_SI_tsne.OptimalK;  
bestK_tsne   = clust_eva_tsne(bestIdx_tsne);

% final partition
finalClust_tsne = kmeans(X_tsne, bestK_tsne,'Replicates',50);

% store best metric values
CH_tsne = eva_CH_tsne.CriterionValues(bestIdx_tsne);
DB_tsne = eva_DB_tsne.CriterionValues(bestIdx_tsne);
SI_tsne = eva_SI_tsne.CriterionValues(bestIdx_tsne);

%% ---------------------------------
% 5. HIERARCHICAL CLUSTERING

clust_eva_hc = 2:8;
Z = linkage(X_all_raw,'ward'); 
% do something similar: test different 'k' values
clust_hc = zeros(size(X_all_raw,1),numel(clust_eva_hc));

for i=1:numel(clust_eva_hc)
    clust_hc(:,i) = cluster(Z,'maxclust',clust_eva_hc(i));
end

eva_CH_hc = evalclusters(X_all_raw, clust_hc, 'CalinskiHarabasz');
eva_DB_hc = evalclusters(X_all_raw, clust_hc, 'DaviesBouldin');
eva_SI_hc = evalclusters(X_all_raw, clust_hc, 'Silhouette');

bestIdx_hc = eva_SI_hc.OptimalK;  
bestK_hc   = clust_eva_hc(bestIdx_hc);

% final partition
finalClust_hc = cluster(Z,'maxclust', bestK_hc);

% store best metric values
CH_hc = eva_CH_hc.CriterionValues(bestIdx_hc);
DB_hc = eva_DB_hc.CriterionValues(bestIdx_hc);
SI_hc = eva_SI_hc.CriterionValues(bestIdx_hc);

%% ---------------------------------
% 6. COMPARE ALL 4 APPROACHES
%% ---------------------------------
%  now we have 4 sets of results, each with a CH, DB, SI:
%   1) KM raw:      (CH_km_raw, DB_km_raw, SI_km_raw)
%   2) PCA + KM:    (CH_km_pca, DB_km_pca, SI_km_pca)
%   3) t-SNE + KM:  (CH_tsne, DB_tsne, SI_tsne)
%   4) Hierarchical:(CH_hc, DB_hc, SI_hc)
%
% Typically, CH and Silhouette are *larger is better*, DB is *smaller is better*.
% For demonstration, we want to show them on the same bar chart.

approaches = {'k-means (raw)','PCA + k-means','t-SNE + k-means','Hierarchical'};
% Create a matrix: each row is a metric, each column is an approach


CH_scores = [CH_km_raw; CH_km_pca; CH_tsne; CH_hc];
DB_scores = [DB_km_raw; DB_km_pca; DB_tsne; DB_hc];
SI_scores = [SI_km_raw; SI_km_pca; SI_tsne; SI_hc];

% For a side-by-side bar chart with each metric grouped:

figure('Name','Comparison of clustering metrics','Position',[100 100 900 500]);

% Option A: Show CH, DB, SI each in separate subplots
subplot(1,3,1)
bar(CH_scores)
set(gca,'XTickLabel',approaches,'XTickLabelRotation',45,'FontSize',10)
ylabel('Calinski-Harabasz (Higher=Better)')
title('CH')

subplot(1,3,2)
bar(DB_scores)
set(gca,'XTickLabel',approaches,'XTickLabelRotation',45,'FontSize',10)
ylabel('Davies-Bouldin (Lower=Better)')
title('DB')

subplot(1,3,3)
bar(SI_scores)
set(gca,'XTickLabel',approaches,'XTickLabelRotation',45,'FontSize',10)
ylabel('Silhouette (Higher=Better)')
title('Silhouette')

sgtitle('Comparison of Clustering Approaches')

% Save the bar chart figure
saveas(gcf, 'clustering_metrics_comparison.png');


%% ---------------------------------

% Just to be explicit:
clust_km_raw = finalClust_km_raw; 
clust_km_pca = finalClust_km_pca;
clust_tsne   = finalClust_tsne;
clust_hc     = finalClust_hc;

%% ---------------------------------
% 2. Get a single t-SNE embedding of X_all_raw for visualization
%% ---------------------------------
rng(123);  % for reproducibility
X_tsne_viz = tsne(X_all_raw, ...
    'NumDimensions',2, ...   % project down to 2D
    'Perplexity',5, ...
    'Verbose',1);

%% ---------------------------------
% 3. Plot the four cluster partitions in subplots
%% ---------------------------------
figure('Name','Comparison of 4 clustering approaches in a t-SNE visualization','Position',[100 100 1000 800])

% -- (a) K-means (raw) --
subplot(2,2,1)
gscatter(X_tsne_viz(:,1), X_tsne_viz(:,2), clust_km_raw)
title('K-means on Raw Data')
xlabel('t-SNE dim 1'); ylabel('t-SNE dim 2');
grid on

% -- (b) PCA + K-means --
subplot(2,2,2)
gscatter(X_tsne_viz(:,1), X_tsne_viz(:,2), clust_km_pca)
title('PCA + K-means')
xlabel('t-SNE dim 1'); ylabel('t-SNE dim 2');
grid on

% -- (c) t-SNE + K-means --
subplot(2,2,3)
gscatter(X_tsne_viz(:,1), X_tsne_viz(:,2), clust_tsne)
title('t-SNE + K-means (Clusters)')
xlabel('t-SNE dim 1'); ylabel('t-SNE dim 2');
grid on

% -- (d) Hierarchical --
subplot(2,2,4)
gscatter(X_tsne_viz(:,1), X_tsne_viz(:,2), clust_hc)
title('Hierarchical Clustering')
xlabel('t-SNE dim 1'); ylabel('t-SNE dim 2');
grid on

sgtitle('Comparison of 4 Methods using a t-SNE Visualization')

% Save the t-SNE visualization figure
saveas(gcf, 'clustering_tsne_visualization.png');
