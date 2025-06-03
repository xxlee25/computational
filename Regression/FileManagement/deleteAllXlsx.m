function deleteAllXlsx()
files = dir('*.xlsx');
for i = 1:length(files)
    deleteFileUnderPwd(files(i).name)
end
end