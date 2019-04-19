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
