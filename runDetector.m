function runDetector()

addpath(genpath('.')); % '.' or pwd?
data_dir = 'images_winebottles/bottles/labels/';
output_dir = 'winebottles_bottles_labels/';
tot_images = 17;

if ~exist('num2ndLayerUnits', 'var')
    num2ndLayerUnits=256;
end
modelName = sprintf('models/CNN-B%d.mat', num2ndLayerUnits);
addpath(genpath('../finetune'));
load models/detectorCentroids_96.mat % 1st layer kmeans centroids
load(modelName)

fprintf('Constructing filter stack...\n');
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,num2ndLayerUnits]);

fid = fopen([data_dir, 'list.txt']);
if fid == -1
    error('Cannot open file.')
end
filenames = cell(tot_images,1);
for i = 1:tot_images
    filenames{i} = fgetl(fid);
    filenames{i} =  [filenames{i} '.png']; % change to .jpg for "raw"
end
fclose(fid);
fprintf('File names loaded.\n');

if ~exist(['../precomputedLineBoxes/', output_dir])
    mkdir(['../precomputedLineBoxes/', output_dir])
end
output_dir = ['../precomputedLineBoxes/', output_dir];

for i = 1:length(filenames)-1
    img = imread([data_dir, filenames{i}]);
    
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
