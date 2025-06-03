function data = loadData(filepath)
    data = readtable(filepath, 'Sheet', 'Sheet1');
    data.Properties.VariableNames{3} = 'aW';
end