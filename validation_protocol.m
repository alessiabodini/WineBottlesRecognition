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

%% Create two cell array containing images' names from words_gt and 
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
word_score = ones(tot_bottles,col_bottles,col_gt)*100;
final_index = zeros(tot_gt,col_gt-1);
fid = fopen('validation_results.txt', 'w');
for i = 1:tot_bottles
    matches = cell(1,col_bottles);
    % Extract image name
    name = split(words_bottles{i,1},'.');
    imgname = name(1);
    % Extract corresponding image in gt dataset
    index = find(contains(words_gt_names, imgname));
    fprintf(fid, '%s\n', words_bottles{i,1});
    % if there is at least one word in results_gt for this bottle
    if ~isempty(words_gt{index,2})
        matches = cell(1,col_bottles);
        matches_text = cell(1,col_bottles);
        final_scores = ones(col_bottles,col_gt-1)*100;
        j = 2;
        while j <= col_bottles & ~isempty(words_bottles{i,j})
            z = 2;
            while z <= col_gt & ~isempty(words_gt{index,z})
                % Compare every word in results_bottles with every word in
                % results_gt
                word_score(i,j,z-1) = EditDistance(words_bottles{i,j}, words_gt{index,z});
                z = z + 1;
            end
            % Detect best word score (minimum score) and add the result to
            % the other scores for words found in the same image
            [min_score, min_index] = min(word_score(i,j,:));
            if min_score == 0 % change according to precision
                final_index(index,min_index) = final_index(min_index) + 1;
            end
            final_scores(j,min_index) = min_score;
            %disp(final_index)
            %disp(final_scores(j,:))
            j = j + 1;
        end
        % For all the words in words_gt corresponding to the minimum
        % scores found print the match in validation_results.txt
        for j = 1:col_gt-1
            match = words_gt{index,j+1};
            if isempty(match)
                continue;
            end
            [score,~] = min(final_scores(:,j));
            if score == 0
            	fprintf(fid, '\t%s correct!\n', match);
            elseif score <= 2
                fprintf(fid, '\t%s found similar...\n', match);
            else
                fprintf(fid, '\t%s not found.\n', match);
            end
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);
fprintf('New validation_results.txt!\n');

%% Create a sort results_gt for most similar word found in results_bottles

[~,col_word_score,prof_word_score] = size(word_score);
fid = fopen('sorted_words_gt.txt', 'w');
for i = 1:tot_gt
    % Extract image name
    name = split(words_gt{i,1},'.');
    imgname = name(1);
    % Find corresponding images in bottles dataset
    index = find(contains(words_bottles_names, imgname));
    fprintf(fid, '%s ', words_gt{i,1});
    sort_words_gt = [1,col_gt-1];
    if ~isempty(index) % if bottles called 'imgname' are in bottles dataset
        % Sort all words' scores for images in 'index' (return an array) 
        total_score = zeros(1,col_gt-1);
        % Sort words in results_gt given the indexes of the words matching
        % in the last part of the code
        [~,sort_index] = sort(final_index(i,:),'descend');
        sorted_words_gt = words_gt(i,sort_index+1);
        % Delete empty cell
        sorted_words_gt = sorted_words_gt(~cellfun('isempty',sorted_words_gt));
        % If there are no words in gt for this bottle
        if isempty(sorted_words_gt)
            fprintf(fid, '\n');
            continue;
        end
        % Print in sorted_words_gt.txt
        fprintf(fid, '%s ', sorted_words_gt{:});
    end
    fprintf(fid, '\n');
end    
fclose(fid);
fprintf('New sorted_words_gt.txt!\n');
