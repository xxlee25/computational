function data = randomDataGenerator(n, ranges)
    % Set a seed for random number generator, do this manually makes your 
    % randomized data reproducable.
    % Feel free to pick any integer you fancy.
    rng(42); 
    T = randi([ranges(1, 1), ranges(1, 2)], n, 1);
    pH = round(ranges(2, 1) + (ranges(2, 2) - ranges(2, 1)) * rand(n, 1), 1);
    aW = round(ranges(3, 1) + (ranges(3, 2) - ranges(3, 1)) * rand(n, 1), 3);
    data = table(T, pH, aW);
end