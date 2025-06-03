function saveACopy(src, dst)
    if ~isfile(src)
        error('Source file "%s" does not exist.', src);
    end
    if isfile(dst)
        error("There is already a version of data out there, " + ...
            "delete it before generate a new one.");
    end
    data = readtable(src);
    writetable(data, dst);
end
