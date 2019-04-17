% Demo of end-to-end text recognition using trained character detector and recognizer
% models, and reproduce the end-to-end results
addpath(genpath('.'));
model = loadRecognitionModel; % load recognizer model

% hyperparameters obtained with grid search on icdarTrain
std_cost = 0.21; narrow_cost = 0.2; split_cost = 4; THRESH = 0.2;

% test on winebottles
printOutput(model, std_cost, narrow_cost, split_cost, THRESH);