% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% performs end-to-end text recognition on a sample image
addpath(genpath('.'))

%% sliding window detection + NMS to generate line-level bounding boxes
% load first layer features
load detectorDemo/models/detectorCentroids_96.mat
% load detector model
load detectorDemo/models/CNN-B256.mat
% img = imread('detectorDemo/models/sampleImage.jpg');
img = imread('images_winebottles/bottles/Valiano.png');
fprintf('Constructing filter stack...\n');
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,256]);
fprintf('Computing responses, this can take quite long...\n');
responses = computeResponses(img, filterStack);
fprintf('Finding lines...\n');
response = findBoxesFull(responses); % line-level bounding boxes

%% perform joint segmentation and recognition inside each line-level bounding box
model = loadRecognitionModel; % load recognizer model
D1 = model.D;
M1 = model.M;
P1 = model.P;
mu = model.mu;
sig = model.sig;
params = model.params;
netconfig = model.netconfig;

[~, Lex] = getIcdarTestStruct; % load lexicon
% generate icdar full lexicon
origLex = Lex;
Lex = [];
for i = 1:length(origLex)
    origtag = origLex{i};
    origtag = regexprep(char(origtag),'[^a-zA-Z0-9]','');
    if length(origtag)>2
        Lex{end+1} = origtag;
    end
end
% hyperparams found by grid search on training set
global scoreTable wordsTable;
global c_std c_narrow;
c_std=0.21; c_narrow= 0.2; c_split= 4; thresh=0.2;
bboxes = response.bbox;
spaces = response.spaces;
numbbox = size(bboxes,1);
[height, width, depth] = size(img);
wbboxes = []; % predicted word bboxes
predwords = []; % predicted labels
for bidx = 1:numbbox % for every line-level bounding box
    % prune out candidate line bboxes with low score or too many
    % spaces (15). This is valid assumption as lines are almost always
    % shorter than 10 words in natural scenes
    if bboxes(bidx,5)>0.7 && length(spaces(bidx).locations)<15
        x = bboxes(bidx,1);
        y = bboxes(bidx,2);
        w = bboxes(bidx,3);
        h = bboxes(bidx,4);
        % four corners of the bounding box
        % aa---------------bb
        %  |                |
        %  |                |
        %  |                |
        %  cc--------------dd
        aa = [max(y,1),max(x,1)];
        bb = [max(y,1), min(x+w, width)];
        cc = [min(y+h, height), max(x,1)];
        dd = [min(y+h, height), min(x+w, width)];
        % candidate spaces
        locations = spaces(bidx).locations;
        spacescores = spaces(bidx).scores;
        locations = locations(spacescores>0.7);
        spacescores = spacescores(spacescores>0.7);
        [orig_sorted_locations sortidx]= sort(locations(:),'ascend');
        spacescores = spacescores(sortidx);
        % resize and pad the line-level bbox
        longimg = rgb2gray(img(aa(1): cc(1), aa(2):bb(2), :)); % already a
        %gray image
        %longimg = img(aa(1): cc(1), aa(2):bb(2), :);
        stdimg = imresize(longimg, [32, NaN]);
        [subheight subwidth] = size(longimg);
        [stdheight stdwidth] = size(stdimg);
        
        % chop the line into segments using cadidate spaces
        sorted_locations = round(orig_sorted_locations/subheight*stdheight);
        segs = [  [1; sorted_locations] [sorted_locations; stdwidth]];
        std_starts = [1; sorted_locations];
        std_ends = [sorted_locations; stdwidth];
        
        orig_starts = [1; orig_sorted_locations];
        orig_ends = [orig_sorted_locations; subwidth];
        numbeams = 60;
        states = [];
        numsegs = size(segs,1);
        scoreTable = ones(numsegs+1, numsegs+1)*(-99); % -99 is an arbitary number chosen to indicate an empty position
        wordsTable = cell(numsegs+1, numsegs+1);
        curr = 1;
        % compute the recognition score for the current
        % line level bbox
        origscores =  getRecogScores_convnet(longimg, D1, M1, P1, mu,sig, params, netconfig);
        % perform beam search on the line
        while isempty(states) || curr<=size(segs,1)
            [newstates curr]= beam_search_step(states,  curr, origscores, segs, spacescores, numbeams, Lex, thresh, c_split);
            states = newstates;
        end
        fprintf('prediction: ')
        states{1}
        
        if length(states{1}.path)==1 && states{1}.path(1)==2
            states{1}.path(1) = 5;
        end
        
        % now generate word bboxes from beam search results
        startings = states{1}.path==1 | states{1}.path == 2;
        endings  = states{1}.path==1 | states{1}.path == 3;
        assert(sum(startings) == sum(endings));
        realsegs = [orig_starts(startings) orig_ends(endings)];
        realstdsegs = [std_starts(startings) std_ends(endings)]; % starting and endings in the std img
        
        currwords = [];%predicted words in the current line
        for ww = 1:length(states{1}.words)
            if ~isempty(states{1}.words{ww})
                currwords{end+1} = states{1}.words{ww};
            end
        end
        predscores = states{1}.scores(states{1}.scores>thresh);
        for ss = 1:length(currwords)
            tempbbox = zeros(1,5);
            tempbbox(2) = aa(1);
            tempbbox(4) = subheight;
            subscores = origscores(:, realstdsegs(ss,1):realstdsegs(ss,2));
            % compute actual left and right bounds for the current segment
            [~, ~, ~, bounds] =  score2WordBounds(subscores, currwords(ss));
            tempbbox(1) = realsegs(ss,1)+aa(2)-1+round((bounds(1)-1)/32*subheight); % adjust x position
            tempbbox(3) = realsegs(ss,2)-realsegs(ss,1)+1 - round((bounds(1)+bounds(2)-1)/32*subheight); % adjust width
            tempbbox(5) = predscores(ss);
            wbboxes = [wbboxes;tempbbox];
            predwords{end+1} = currwords{ss};
        end
    end
end

if ~isempty(wbboxes)
    %remove wbboxes with low recognition scores
    bad_idx = wbboxes(:,end)<thresh;
    wbboxes(bad_idx, :) = [];
    predwords(bad_idx) = [];
    
    %sort wbboxes in recognition scores
    matchScores = wbboxes(:,end);
    [~, score_idx] = sort(matchScores, 'descend');
    wbboxes = wbboxes(score_idx,:);
    predwords = predwords(score_idx);
    numbbox = size(wbboxes,1);
    suppressed = zeros(numbbox,1);
end
%% visualize boxes
imshow(img);
for i=1:size(wbboxes, 1)
    if suppressed(i)==0
        x = wbboxes(i,1);
        y = wbboxes(i,2);
        w = wbboxes(i,3);
        h = wbboxes(i,4);
        aa = [max(y,1),max(x,1)];% upper left corner
        bb = [max(y,1), min(x+w, width)];% upper right corner
        cc = [min(y+h, height), max(x,1)];% lower left corner
        
        % NMS: eliminate all worse wbboxes that overlap with the current one
        % by 1/2 of the area of either bbox.
        for worse_idx = (i+1):numbbox % wbboxes that are worse than the current one
            if suppressed(worse_idx)==0
                x2 = wbboxes(worse_idx,1);
                y2 = wbboxes(worse_idx,2);
                w2 = wbboxes(worse_idx,3);
                h2 = wbboxes(worse_idx,4);
                aa2 = [max(y2,1),max(x2,1)]; % upper left corner
                bb2 = [max(y2,1), min(x2+w2, width)];% upper right
                cc2 = [min(y2+h2, height), max(x2,1)];% lower left
                pred_y1 = aa(1); pred_y2 = cc(1);
                pred_x1 = aa(2); pred_x2 = bb(2);
                pred_rec = [pred_x1, pred_y1, pred_x2-pred_x1+1, pred_y2-pred_y1+1];
                pred2_y1 = aa2(1); pred2_y2 = cc2(1);
                pred2_x1 = aa2(2); pred2_x2 = bb2(2);
                pred2_rec = [pred2_x1, pred2_y1, pred2_x2-pred2_x1+1, pred2_y2-pred2_y1+1];
                intersect_area = rectint(pred_rec,pred2_rec);
                pred_area = pred_rec(3)* pred_rec(4);
                pred2_area = pred2_rec(3)* pred2_rec(4);
                if intersect_area>0.5*pred_area || intersect_area>0.5*pred2_area
                    suppressed(worse_idx) = 1; % worse bbox did not survive NMS
                end
            end
        end
        rectangle('Position', wbboxes(i, 1:4), 'EdgeColor', 'g', 'LineWidth', 2);
        fprintf('word bbox %d: x=%d, y=%d, w=%d, h=%d, label: %s\n', i, wbboxes(i,1:4), predwords{i});
    end
end

