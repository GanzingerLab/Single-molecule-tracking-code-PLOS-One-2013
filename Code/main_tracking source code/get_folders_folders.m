function [list_dir,folders] = get_folders_folders(keyword,directory)

d = dir(directory);

ii = 1;

if strcmp(keyword, 'all')== 1
    for n = 3:length(d),
        folders1{ii} = d(n).name;
            list_dir1{ii} = strcat(directory,'\',d(n).name);
            ii = ii + 1;
    end
end

ii = 1;

for n = 3:length(d),

        a = d(n).name;
        findstr(a,'fig');
        if isempty(findstr(a,'fig')) == 1,
            folders2{ii} = d(n).name;
            list_dir2{ii} = strcat(directory,'\',d(n).name);
            ii = ii + 1;
        end  
end

for n = 1 : size(list_dir2,2)
    current_directory = list_dir2{n};
    [list_dir{n},folders{n}] = get_folders_withdirectory('Results_tracking',current_directory);
    
end