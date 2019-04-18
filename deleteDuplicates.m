function cell = deleteDuplicates(cell)
% If a cell array contains an empy string [] o a duplicate delete it

[~,col] = size(cell);

for i = 1:col-1
    mod = false;
    if isempty(cell{i})
        continue;
    end
    for j = i+1:col
        if isempty(cell{j})
            continue;
        end
        if find(contains(cell{j},cell{i}))
            mod = true;
            break;
        end
    end
    if mod == true
        cell{i} = [];
    end
end

cell = cell(~cellfun('isempty',cell));
        