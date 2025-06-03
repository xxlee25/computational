function pattern = fullFactorialPattern()
    qs = [-1, 0, 1];
    [g1, g2, g3] = ndgrid(qs, qs, qs);
    pattern = [g1(:), g2(:), g3(:)];
end