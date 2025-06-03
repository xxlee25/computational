clear;
close all;

% Data matrix (from your image)
data = [4.783107041, 4.97729267, 4.248172595, 5.77522617, 5.928985053; 
        6.07832654, 4.65959962, 4.689797103, 5.424649818, 5.328678802; 
        2.763026994, 2.773338331, 2.300070612, 3.448566849, 3.386297919; 
        6.35855551, 5.216693145, 5.696130906, 5.371737039, 5.079694065; 
        6.306058317, 6.345915724, 5.752167941, 6.173332321, 5.243627754; 
        4.19612958, 4.262264111, 4.567259973, 2.869095511, 3.63283814; 
        4.564452355, 3.719432596, 5.311624252, 5.366156495, 5.157919867; 
        4.729316939, 4.406686738, 4.85874244, 3.668421659, 4.315290421; 
        2.349769989, 2.885298516, 3.500818763, 3.19180399, 1.764626354];

% Conditions
microorganism = {'L. monocytogenes', 'L. monocytogenes', 'L. monocytogenes', ...
                 'E. coli', 'E. coli', 'E. coli', ...
                 'S. enterica', 'S. enterica', 'S. enterica'}';
preservative = {'Control', 'Preservative X', 'Preservative Y', ...
                'Control', 'Preservative X', 'Preservative Y', ...
                'Control', 'Preservative X', 'Preservative Y'}';

% Combine conditions into a table
dataTable = array2table(data, 'VariableNames', {'data_1', 'data_2', 'data_3', 'data_4', 'data_5'});
dataTable.microorganism = microorganism;
dataTable.preservative = preservative;

groupedStats = varfun(@mean, dataTable, ...
    'InputVariables', {'data_1', 'data_2', 'data_3', 'data_4', 'data_5'}, ...
    'GroupingVariables', {'microorganism', 'preservative'});