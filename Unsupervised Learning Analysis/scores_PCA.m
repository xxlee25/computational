function [T_est,T_SPE,TSQR,Xnew_est]=scores_PCA(P,T,Xnew,Nvar,Nbat)

    T_est=Xnew*P;
    
    TSQR_cov=T_est/cov(T)*T_est';
    TSQR=diag(TSQR_cov);
    
    Xnew_est=T_est*P';
    
    E=Xnew_est-Xnew;
    
    % total SPE, Error for each batch allong all variables and all times
    T_SPE=E*E';
    [r,c]=size(T_SPE);
    if r>1 
        T_SPE=diag(T_SPE)';
    end
    
end
    
