function [T_est,P_est,Nlatent,EVs_sort,Ress] = PCA_decomp(X,Beta,PCA_method,Rank,verbose)

    % Eigenvalue decomposition (EIG) of the covariance matrix. The EIG algorithm 
    % is faster than SVD when the number of observations exceeds the number of 
    % variables. Matlab method uses SVD by default

    % eigen value decomposition of XX' because it is a smaller covariance matrix when #samples << #variables)
        
    if strcmp(PCA_method,"EIG")
        
        XXs = X*X'; % var covariance matrix
        [U,M_EVs] = eig(XXs); % V(columns)=eigen vectors and EVs(diagonal)=eigen values
        [~,Neig]=size(M_EVs);
        EVs= diag(M_EVs);
        EVs_sort=zeros(1,Neig);
        M_EV_sort=zeros(Neig,Neig);
        
        for i=1:Neig
            [a,ind] = max(EVs);
            EVs_sort(i)=a;
            M_EV_sort(i,i)=a;
            U_sort(:,i)=U(:,ind);
            EVs(ind)=0;
        end
             
    end
    
    if strcmp(PCA_method,"SVD")
        
        % PCA Matlab
        [P,T,EVs_sort] = pca(X);
        [Neig,~]=size(EVs_sort);
    end
    
    if (strcmp(PCA_method,"EIG") || strcmp(PCA_method,"SVD"))
        tot_var = sum(EVs_sort);
        cont=EVs_sort/tot_var;
        cum_cont=cont;
        R=NaN(1,Neig);
        Nlatent=[];
        for i=2:Neig
            cum_cont(i)=cont(i)+cum_cont(i-1);
            R(i)=cum_cont(i)/cum_cont(i-1);%Wold's R criterion
        end
        
        if Rank==0 
            for i=2:Neig
                if R(i) < Beta && isempty(Nlatent)
                    Nlatent=i;
                    explained=cum_cont(i);
                end
            end
        else 
            Nlatent=Rank;
        end
     
    end
    
    if strcmp(PCA_method,"NIPALS")
        
        [Nbat,Nvar]=size(X);
        X_deflated=X;
        P=zeros(Nvar,1);
        EVs_sort=[];
        cont=[];
        Nlatent=[];
        for i=1:Nvar
            T(:,i)=X_deflated(:,2);
            
            for j=1:1000 % max iterations
                P(:,i)=X_deflated'*T(:,i)/(T(:,i)'*T(:,i));
                P(:,i)=P(:,i)/sqrt(P(:,i)'*P(:,i));
                t_old=T(:,i);
                T(:,i)=X_deflated*P(:,i)/(P(:,i)'*P(:,i));
                
                % evaluating termination criteria
                res=t_old-T(:,i);
                SSE=sum(res.^2);
                if SSE/sum(t_old.^2)<=1e-8
                    break
                end
            end
            
            X_old=X_deflated;
            X_deflated=X_deflated-T(:,i)*P(:,i)';
            EVs_sort=[EVs_sort,(norm(X_old,'fro')^2-norm(X_deflated,'fro')^2)];
            
            
            tot_var = norm(X,'fro')^2;
            cont=[cont,EVs_sort(i)/tot_var];
            if i==1
                cum_cont=cont;
                R=NaN;
            else
                cum_cont=[cum_cont,cont(i)+cum_cont(i-1)];
                R=[R,cum_cont(i)/cum_cont(i-1)];
            end
                
            % evaluation termination condition
            if Rank==0
                if R(i) < Beta && isempty(Nlatent)
                    Nlatent=i;
                    explained=cum_cont(i);
                    break
                end 
            else
                if i==Rank
                    Nlatent=Rank;
                    explained=cum_cont(i);
                    break
                end
            end
            
            % extending scores and loading matrices
            T=[T,ones(Nbat,1)];
            P=[P,ones(Nvar,1)]; 
        end
        
    end
    
    if Rank==0 && (strcmp(PCA_method,"EIG") || strcmp(PCA_method,"SVD"))   
        latent=(1:1:Neig);
    else
        latent=(1:1:Nlatent);
    end
    
    if strcmp(verbose,"True")
        figure
        yyaxis left
        plot(latent,R,'linewidth',3)
        xlabel ('Rank','fontsize', 20)
        ylabel ('Relative increase of explained variance','fontsize', 20)
        ylim([1 1.5])
        grid on
        yyaxis right
        plot(latent,cum_cont,'linewidth',3)
        ylabel ('Explained variance','fontsize', 20)
        ylim([0.4 1])
        yyaxis left
        hold on
        y=[0 1.5];
        x=[Nlatent Nlatent];
        plot(x,y,':k','linewidth',2)
        x=[0 Nlatent];
        y=[Beta Beta];
        plot(x,y,':k','linewidth',2)
        set(gca, 'fontsize', 18, 'LineWidth', 3)

        fprintf('best rank aprox: %d latent variables explain %d of data variability \n', Nlatent, explained)
    end
    
    if strcmp(PCA_method,"EIG")
        U_est=U_sort(:,1:Nlatent);
        Tet_est=M_EV_sort(1:Nlatent,1:Nlatent);
        P_est=X'*U_est*(Tet_est)^(-1/2);
        T_est=X*P_est;
    else
        P_est=P(:,1:Nlatent);
        T_est=T(:,1:Nlatent);
    end
        
    X_est=T_est*P_est';
    Ress=X-X_est;
    
    rel_error = norm(Ress,'fro')/norm(X,'fro');
    fprintf('Relative error with %d latent variables: %d. \n',Nlatent,rel_error)   
    
        
end