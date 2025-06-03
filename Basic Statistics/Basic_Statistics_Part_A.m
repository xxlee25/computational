clear;
close all;

data_filepath = "./Group_14.xlsx";

data = readtable(data_filepath, 'Sheet', 'Sheet1');

[~, tbl, ~] = anovan( ...
    data.growthRate, ...
    {data.T, data.pH, data.aw}, ...
    'model', 'interaction', ...
    'varnames', {'T', 'pH', 'aw'} ...
    );

T_values = unique(data.T);  
aw_values = unique(data.aw);    

[T_grid, aw_grid] = meshgrid(T_values, aw_values);

GrowthRate_grid = griddata( ...
    data.T, data.aw, ...
    data.growthRate, ...
    T_grid, aw_grid, ...
    'linear' ...
    );

figure;
surf(T_grid, aw_grid, GrowthRate_grid);

xlabel('Temperature (T)');
ylabel('Water Activity (aw)');
zlabel('GrowthRate');
title('GrowthRate as a function of Temperature and Water Activity');
colorbar; 

shading interp;   
view(3);         
