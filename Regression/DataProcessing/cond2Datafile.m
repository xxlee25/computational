function cond2Datafile(cond, group_id)
    writetable(cond, fullfile(pwd, "ExperimentalConditions.xlsx"));
    Experiment(group_id);
end

