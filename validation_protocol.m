%% Search for the results of bottles and gt and put them in cell array
dir_bottles = 'images_winebottles/bottles/labels/';
dir_gt = 'images_winebottles/gt/labels/';
tot_bottles = 17;
tot_gt = 15;

fid = fopen([dir_bottles, 'results_bottles_labels.txt']);
if fid == -1
    error('Cannot open file.\n')
end
words = cell(1);
words_bottles = cell(tot_bottles,1);
for i = 1:tot_bottles
    words{i} = fgetl(fid);
    splits = split(words{i});
    names = size(splits);
    j = 1;
    while ~isempty(splits{j})
        words_bottles{i,j} = splits{j};
        j = j + 1;
    end
end
fclose(fid);
fprintf('Bottles results loaded.\n');

fid = fopen([dir_gt, 'results_gt_labels.txt']);
if fid == -1
    error('Cannot open file.\n')
end
words = cell(1);
words_gt = cell(tot_gt,1);
for i = 1:tot_gt
    words{i} = fgetl(fid);
    splits = split(words{i});
    names = size(splits);
    j = 1;
    while ~isempty(splits{j})
        words_gt{i,j} = splits{j};
        j = j + 1;
    end
end
fclose(fid);
fprintf('GT results loaded.\n');

%% Use EditDistance to define validation results

% Create two cell array containing images' names from words_gt and
% words_bottles
words_gt_names = cell(tot_gt,1);
for i = 1:tot_gt
    words_gt_names{i} = words_gt{i,1};
end

words_bottles_names = cell(tot_bottles,1);
for i = 1:tot_bottles
    words_bottles_names{i} = words_bottles{i,1};
end

% Determine number of columns for words_bottles and words_gt
[row_bottles, col_bottles] = size(words_bottles);
[row_gt, col_gt] = size(words_gt);

% Determine correct word found in results_bottles
word_score = ones(tot_bottles,col_bottles)*100;
fid = fopen('validation_results.txt', 'w');
for i = 1:tot_bottles
    name = split(words_bottles{i,1},'.');
    imgname = name(1);
    index = find(contains(words_gt_names, imgname));
    fprintf(fid, '%s\n', words_bottles{i,1});
    %fprintf('%s\n', words_bottles{i,1});
    j = 2;
    while j <= col_bottles & ~isempty(words_bottles{i,j})
        z = 2;
        while ~isempty(words_gt{index,z})
           word_score(i,z-1) = EditDistance(words_bottles{i,j}, words_gt{index,z});
           %fprintf('%i %s %s\n', word_score(i,z-1), words_bottles{i,j}, words_gt{index,z});
           z = z + 1;
        end
        if ~isempty(words_gt{index,2})
            [minscore, minindex] = min(word_score(i));
            match = words_gt{index, minindex+1};
            if minscore == 0
                fprintf(fid, '\t%s correct!\n', match);
            elseif minscore <= 2
                fprintf(fid, '\t%s found similar\n', match);
            else
                fprintf(fid, '\t%s not found\n', match);
            end
        end
        j = j + 1;
    end
    fprintf(fid, '\n');
    %fprintf('\n');
end
fclose(fid);

% Create a sort results_gt for most similar word found in
% results_bottles
sorted_words_gt = cell(col_gt);
fid = fopen('sorted_words.txt', 'w');
for i = 1:tot_gt
    name = split(words_gt{i,1},'.');
    imgname = name(1);
    index = find(contains(words_bottles_names, imgname));
    fprintf(fid, '%s ', words_gt{i,1});
    if ~isempty(index) 
        for j = index % SCRIVERE PAROLE UNA SOLA VOLTA (non importa quante bottles!)
            [sortout, sortidx] = sort(word_score(j,:));
            sorted_words_gt = words_gt(i, sortidx + 1);
            for x = 1:col_gt-1
                if ~isempty(sorted_words_gt{x})
                    fprintf(fid, '%s ', sorted_words_gt{x});
                end
            end
            %fprintf('work for i=%i, j=%i\n', i, j);
        end
    end
    fprintf(fid, '\n');
end    
fclose(fid);
