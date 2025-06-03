clear;
close all;

data_filepath = "./Group_14.xlsx";

data = readtable(data_filepath, 'Sheet', 'Sheet2');

data = stack(data, {'data_1', 'data_2', 'data_3', 'data_4', 'data_5'}, ...
    'NewDataVariableName', 'growth', 'IndexVariableName', 'replicate');

% ********************************** Q1 **********************************
% I turn display off since I found the pop-up window annoying. Remove the 
% 'display' 'off' parameter if you prefer to see them. Otherwise, the 
% results can be found in the 2nd return value (tbl).
[~, tbl1, ~] = anovan(data.growth, {data.microorganism, data.preservative}, ...
    'model', 'interaction', ...
    'varnames', {'microorganism', 'preservative'}, ...
    'display', 'off');

% ********************************** Q2 **********************************
% This 'off' parameter here is of same effect as 'display', 'off' in anovan.
% To suppress the pop-up behavior. Omit it if you want it happen.
[~, tbl2, stats2] = anova1(data.growth, data.preservative, 'off');
% Very instructive paragraph explaining the purpose of doing multcompare, 
% from the matlab help center page for multcompare.
% https://nl.mathworks.com/help/stats/multcompare.html#d126e822638
% "The small p-value (value in the column Prob>F) indicates that group mean 
% differences are significant. However, the ANOVA results do not indicate 
% which groups have different means.
% Perform pairwise comparisons using a multiple comparison test to identify 
% the groups that have significantly different means."
[c, m, h, gnames] = multcompare(stats2);
% From the results, the mean value of preservative Y is 
% significantly different from that of the control group, but X is not. 
% So we can interpret the results of ANOVA1 in the previous step accordingly: 
% the use of preservatives has an impact on growth rate (group mean 
% differences are significant) where the effect of Y is significant.


% ********************************** Q3 **********************************
% group by 'microorganism' and 'preservative', calculate 'mean', 'var', 'std'
% on growth. 
% Note that Q3 does not require you to calculate the standard deviation, 
% but for the convenience of drawing errbar in Q5, it is calculated here. 
% Otherwise, you will need to manually sqrt the var to get std later.
stats3 = groupsummary(data, ...
    {'microorganism', 'preservative'}, {'mean', 'var', 'std'}, 'growth');


% ********************************** Q4 **********************************
% Extract all categories of microorganisms and preservatives, in order to: 
% 1. Rearrange the results of the previous step into a matrix by the number 
%   of categories in the groups, for easy appling `bar` function. 
% 2. Used as labels for axes and legends.
microorganism = unique(stats3.microorganism);
preservative = unique(stats3.preservative);

% Rearrange the mean values ​​in the output of the previous step into a matrix. 
% Through some attempts, it is not difficult to find that MATLAB uses 
% column major order to organize matrices, that is, when its reshape function 
% rearranges an array into a matrix, it fills one column of the matrix 
% one by one, and then fills the next column. 
% You may find this helpful in understanding how matlab handle matrices: 
% https://nl.mathworks.com/matlabcentral/answers/545291-use-reshape-or-transpose-to-change-the-order-of-a-matrix-while-preserving-the-row-order
% Note that you may have discovered in your early experiment of the bar function 
% that when drawing a 2-leveled  barplot, the rows of the input matrix represent 
% the outer labels and the columns represent the inner labels. 
% Which is, each row of the matrix represents a group of bars on the X-axis. 
% So the result of reshape needs to be transposed here.
mean_growth = reshape(stats3.mean_growth, numel(preservative), [])';
std_growth = reshape(stats3.std_growth, numel(preservative), [])';

figure;
barHandle = bar(microorganism, mean_growth);
hold on;

% ********************************** Q5 **********************************
% Get the position of each bar in the drawn bar plot on the x-axis.
xCoordinates = sort([barHandle(:).XEndPoints]);

% Set 'LineStyle' to 'none' is necessary here. 
% https://nl.mathworks.com/help/matlab/creating_plots/bar-chart-with-error-bars.html
% errorbar(xCoordinates, ...
%     reshape(mean_growth', size(xCoordinates)), ...
%     reshape(std_growth', size(xCoordinates)), ...
%     'k', 'LineWidth', 1.5, 'LineStyle','none' ...
%     );
errorbar(xCoordinates, stats3.mean_growth, stats3.std_growth, ...
    'k', 'LineWidth', 1.5, 'LineStyle','none');

% ********************************** Q6 **********************************
% x axis is microorganism
% set(gca, 'XTickLabel', microorganism);
xlabel('Microorganism');
ylabel('Mean Growth');
legend(preservative, 'Location', 'NorthEastOutside');
title('A Wanderful Title');
grid on;

hold off;