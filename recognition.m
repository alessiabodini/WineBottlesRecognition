
clear all

addpath(genpath('.'));
gt_dir = 'images_winebottles/gt/';
bottles_dir = 'images_winebottles/bottles/';
dataset = 'gt';

% Load images gt
files1 = dir(fullfile(gt_dir,'*.jpg'));
files2 = dir(fullfile(gt_dir,'*.png'));
files = [files1;files2];
gt_names = {files.name};
tot_gt = numel(gt_names);

% Load images bottles
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

%% Call API

import matlab.net.*
import matlab.net.http.*

%for i = 1:length(filenames) 
    path = fileparts(which(filenames{1}));
    img = imread([path '\' filenames{1}]);
    url = 'https://westeurope.api.cognitive.microsoft.com/vision/v2.0/recognizeText?mode=Printed';
    
%     options = weboptions('RequestMethod', 'post', ...
%         'MediaType', 'application/json', ... 
%         'KeyName', 'Ocp-Apim-Subscription-Key', ...
%         'KeyValue', '6dc622eb5a174066aa5c56e674018b75');
%     data = struct('url', ... 
%         'https://raw.githubusercontent.com/alessiabodini/WineBottlesRecognition/master/images_winebottles/gt/Antinori.png');
%     response = webwrite(url, data, options)
    
    uri = matlab.net.URI('https://westeurope.api.cognitive.microsoft.com/vision/v2.0/recognizeText?mode=Printed');
    method = matlab.net.http.RequestMethod.POST;
    requestTarget = '/vision/v2.0/recognizeText?mode=Printed';
    protocolVersion = 'HTTP/1.1';
    requestLine = matlab.net.http.RequestLine(method, requestTarget, protocolVersion);
    %contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    header = matlab.net.http.HeaderField( ...
        'Content-Type', 'application/json', ... 
        'Ocp-Apim-Subscription-Key', '6dc622eb5a174066aa5c56e674018b75');
    body =  matlab.net.http.MessageBody( ...
        '{"url":"http://www.totalwine.com/media/sys_master/twmmedia/h0b/h5c/9299434307614.png"}');
    request = matlab.net.http.RequestMessage(requestLine, header, body);
    response = send(request, uri);
    show(response)
        
    
%end

