%% Search for the results of bottles and gt and put them in cell array

addpath(genpath('.'));
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
[~,col_bottles] = size(words_bottles);
[~,col_gt] = size(words_gt);

% Determine correct word found in results_bottles
word_score = ones(tot_bottles,col_bottles)*100;
fid = fopen('validation_results.txt', 'w');
for i = 1:tot_bottles
    matches = cell(1,col_bottles);
    % Extract image name
    name = split(words_bottles{i,1},'.');
    imgname = name(1);
    % Extract corresponding image in gt dataset
    index = find(contains(words_gt_names, imgname));
    fprintf(fid, '%s\n', words_bottles{i,1});
    fprintf('%s\n', words_bottles{i,1});
    % if there is at least one word in results_gt for this bottle
    if ~isempty(words_gt{index,2})
        matches = cell(1,col_bottles);
        matches_text = cell(1,col_bottles);
        j = 2;
        while j <= col_bottles & ~isempty(words_bottles{i,j})
            z = 2;
            fprintf('Analysing %s\n', words_bottles{i,j});
            while z <= col_gt & ~isempty(words_gt{index,z})
                % Compare every word in results_bottles with every word in
                % results_gt
                word_score(i,z-1) = EditDistance(words_bottles{i,j}, words_gt{index,z});
                z = z + 1;
            end
            % Detect best word score (minimum score)
            [minscore, minindex] = min(word_score(i));
            % PER OGNI PAROLA DELL'IMMAGINE WORD_SCORE VIENE RISCRITTO:
            % UTILIZZARE UNA MATRICE 3D?? COME CAMBIA SOTTO??
            matches{j-1} = words_gt{index, minindex+1};
            matches = deleteDuplicates(matches);
            if isempty(matches{j-1})
                j = j + 1;
                continue;
            end
            if minscore == 0
                matches_text{j-1} = sprintf('\t%s correct!\n', matches{j-1});
            elseif minscore <= 2
                matches_text{j-1} = sprintf('\t%s found similar\n', matches{j-1});
            else
                matches_text{j-1} = sprintf('\t%s not found\n', matches{j-1});
            end
            j = j + 1;
        end
        [~,tot_matches] = size(matches_text);
        fprintf(fid, '%s', matches_text{:});
        fprintf('%s', matches_text{:});
    end
    fprintf(fid, '\n');
end
fclose(fid);
fprintf('New validation_results.txt!\n');

% Create a sort results_gt for most similar word found in
% results_bottles
[~,col_word_score] = size(word_score);
fid = fopen('sorted_words_gt.txt', 'w');
for i = 1:tot_gt
    % Extract image name
    name = split(words_gt{i,1},'.');
    imgname = name(1);
    % Find corresponding images in bottles dataset
    index = find(contains(words_bottles_names, imgname));
    fprintf(fid, '%s ', words_gt{i,1});
    if ~isempty(index) % if bottles called 'imgname' are in bottles dataset
        % Sort all words' scores for images in 'index' (return an array) 
        % RIVEDERE LE DIMENSIONI DI WORD_SCORE!!
        tot_word_score = (col_word_score) * length(index);
        score_per_name = reshape(word_score(index,:), 1, tot_word_score);
        [sortout, sortidx] = sort(score_per_name);
        % Sort words in results_gt
        tot_sorted_words = (col_gt-1) * (length(index));
        sorted_words_gt = cell(1, tot_sorted_words);
        single_words_gt = reshape(words_gt(i,2:end), 1, col_gt-1);
        single_words_gt = [single_words_gt single_words_gt];
        sorted_words_gt = single_words_gt(sortidx);
        % Delete empty cell
        sorted_words_gt = sorted_words_gt(~cellfun('isempty',sorted_words_gt));
        % If there are no words in gt for this bottle
        if isempty(sorted_words_gt)
            fprintf(fid, '\n');
            %fprintf('%s empty\n', words_gt{i,1});
            continue;
        end
        [~,tot_sorted_words] = size(sorted_words_gt);
        % If a cell array contains an empy string [] o a duplicate, delete it
        sorted_words_gt = deleteDuplicates(sorted_words_gt);
        % Print non duplicates in sorted_words_gt.txt
        fprintf(fid, '%s ', sorted_words_gt{:});
        %fprintf('%s printed\n', words_gt{i,1});
    end
    fprintf(fid, '\n');
end    
fclose(fid);
fprintf('New sorted_words_gt.txt!\n');
