function runDetectorNew(outputDir)

addpath ../.
data_dir = '../images_winebottles/raw/';
tot_images = 14;

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

if ~exist(['../precomputedLineBboxes/', outputDir])
    mkdir(['../precomputedLineBboxes/', outputDir])
end
outputDir = ['../precomputedLineBboxes/', outputDir];

for i = 1:length(filenames)-1
    img = imread([data_dir, filenames{i}]);
    
    saveName = [outputDir, '/', filenames{i}];
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
