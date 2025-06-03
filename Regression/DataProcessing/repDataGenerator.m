function datatable = repDataGenerator(values, varNames, n)% Create the table by repeating the input array n times
datamat = repmat(values, n, 1);
datatable = array2table(datamat, 'VariableNames', varNames);
end