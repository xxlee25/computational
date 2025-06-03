function deleteAllXlsxWithPrefix(prefix)
    xlsxFiles = dir([prefix, '*.xlsx']);
    for i = 1:length(xlsxFiles)
        deleteFileUnderPwd(xlsxFiles(i).name);
    end
end
