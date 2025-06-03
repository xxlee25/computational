function pattern = centralCompositePattern(q)
    qs = [-q, q];
    [g1, g2, g3] = ndgrid(qs, qs, qs);
    pattern = [g1(:), g2(:), g3(:)];
    pattern1 = [
        -1 0 0; 
        1 0 0; 
        0 -1 0; 
        0 1 0; 
        0 0 -1; 
        0 0 1; 
        0 0 0; 
        0 0 0; 
        0 0 0;
        ];
    pattern = [pattern; pattern1];
end