function runDetectorDemo(outputDir)

addpath(genpath('../finetune'));

% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat

cd '..';
fid = fopen('images_winebottles/gt/list.txt');
if fid == -1
    error('Cannot open file.')
end
filenames = {};
for i = 1:16
    filenames{i} = fgetl(fid);
    filenames{i} =  [filenames{i} '.png'];
end
fclose(fid);

if ~exist(['precomputedLineBboxes/', outputDir])
        cd precomputedLineBboxes/;
        system(['mkdir ', 'precomputedLineBboxes/', outputDir]);
end
cd 'detectorDemo/';

for i = 1:length(filenames)
    img = imread(['../images_winebottles/gt/', filenames{i}]);
    
    fprintf('Constructing filter stack...\n');
    filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);

    fprintf('Computing responses...\n');
    responses = computeResponses(img, filterStack);

    fprintf('Finding lines...\n');
    boxes = findBoxesFull(responses);

    visualizeBoxes(img, boxes);
    
    save(['../precomputedLineBboxes/', outputDir, '/', filenames{i}(1,end-3), '.mat'], 'filterStack', 'responses', 'boxes', '-v7.3');
end
