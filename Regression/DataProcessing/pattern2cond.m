function data = pattern2cond(pattern, ranges)
    n = size(pattern, 2);
    if n ~= size(ranges, 1)
        error("Inputs shape mismatch");
    end
    if any(pattern(:) < -1 | pattern(:) > 1)
        error("Invalid pattern");
    end
    if size(ranges, 2) ~= 2 | any(ranges(:, 1) > ranges(:, 2))
        error("Invalid ranges");
    end
    data = zeros(size(pattern));
    for j = 1:n
        mapper = @(x) ((1-x)*ranges(j, 1) + (1+x)*ranges(j, 2)) / 2;
        data(:, j) = arrayfun(mapper, pattern(:, j));
    end
end