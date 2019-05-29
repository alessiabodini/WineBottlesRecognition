function runDetector()

addpath(genpath('.')); % '.' or pwd?
gt_dir = 'images_winebottles/gt/';
bottles_dir = 'images_winebottles/bottles/';
dataset = 'gt';

if ~exist('num2ndLayerUnits', 'var')
    num2ndLayerUnits=256;
end
modelName = sprintf('models/CNN-B%d.mat', num2ndLayerUnits);
addpath(genpath('../finetune'));
load models/detectorCentroids_96.mat % 1st layer kmeans centroids
load(modelName)

fprintf('Constructing filter stack...\n');
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,num2ndLayerUnits]);

% load images gt
files1 = dir(fullfile(gt_dir,'*.jpg'));
files2 = dir(fullfile(gt_dir,'*.png'));
files = [files1;files2];
gt_names = {files.name};
tot_gt = numel(gt_names);

% load images bottles
files = [];
for i = 1:length(gt_names)
    name = gt_names{i}(1:end-4);
    files1 = dir(fullfile(bottles_dir, name, '/*.jpg'));
    files2 = dir(fullfile(bottles_dir, name, '/*.png'));
    files = [files;files1;files2];
end
bottles_names = {files.name};
tot_bottles = numel(bottles_names);
fprintf('Loaded file names.\n');

if strcmp(dataset,'gt') == 1
    filenames = gt_names;
    data_dir = gt_dir;
    tot_images = tot_gt;
elseif strcmp(dataset,'bottles') == 1
    filenames = bottles_names;
    data_dir = bottles_dir;
    tot_images = tot_bottles;
end

if ~exist(['precomputedLineBoxes/winebottles_', dataset])
    mkdir(['precomputedLineBoxes/winebottles_', dataset])
end
output_dir = ['precomputedLineBoxes/winebottles_', dataset];

for i = 1:length(filenames)
    path = fileparts(which(filenames{i}));
    img = imread([path '\' filenames{i}]);
    saveName = [output_dir, '/', filenames{i}];
    saveName(end-3:end)='.mat';
    fprintf('bbox filename is %s\n', saveName);
    if ~exist(saveName,'file') % only recompute if file does not exist
        fprintf('Computing responses... for img %s\n', filenames{i});
        responses = computeResponses(img, filterStack);
        
        fprintf('Finding lines...\n');
        response = findBoxesFull(responses);
        fprintf('Saving to %s\n', saveName);
        save(saveName, 'response');
        visualizeBoxes(img, response);
        fprintf('Printed response.\n');
    end    
end