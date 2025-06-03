function deleteFileUnderPwd(filename)
filepath = fullfile(pwd, filename);
if exist(filepath, "file")
    delete(filepath)
    disp([filename ' has been deleted.']);
end
end