function [M_std,avg,S] = normalize(M,phi)

    [r,c]=size(M);
    M_std=zeros(r,c);
    for i=1:c
        avg(i) = mean(M(:,i));
        S(i) = std(M(:,i));
        M_std(:,i)=(M(:,i)-avg(i));
        if S(i)>=phi
            M_std(:,i)=M_std(:,i)/S(i);
        end 
    end
    
end