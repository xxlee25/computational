function [cov_X_sort_sort, labels]=sorting_covariance_matrix(cov_X,c,num_clust,Nvar,labels_var)

cov_X_sort=[];
clusters=cell(num_clust,1);
labels=cell(Nvar,1);
n=1;
for i=1:num_clust
    clusters{i}= find(c==i);
    total_cov=sum(abs(cov_X(c==i,:)),2);
    [B,I]=sort(total_cov);
    clusters{i}=clusters{i}(I);
    cov_X_sort=[cov_X_sort;cov_X(clusters{i},:)];
    for j=1:sum(c(:)==i)
        labels{n}=labels_var(clusters{i}(j));
        n=n+1;
    end
end

cov_X_sort_sort=[];

for i=1:num_clust
    cov_X_sort_sort=[cov_X_sort_sort,cov_X_sort(:,clusters{i})];
end


end