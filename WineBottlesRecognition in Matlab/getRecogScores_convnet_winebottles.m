% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)

function scores =  getRecogScores_convnet_winebottles(img, D1, M1, P1, mu,sig, params, netconfig)
% compute sliding window classifier scores on a cropped line segment using 
% the character classifier model provided.
    height(1) = 32;
    if size(img,3)>1
        img = rgb2gray(img);
    end
    img(1) = imresize(img, [height(1), NaN]);
    img(1) = [uint8(ones(height(1),15)*mean(img(1,:))), img(1), uint8(ones(height(1),16)*mean(img(1,:)))]; % pad both sides by half window size
    width(1) = size(img(1), 2);
    
    for i = 1:5
        fs(i) = 8; % first layer filter size
        depth(i+1) = size(D1,1);
        win_total = width(i)-height(i)+1;
        %first layer feed-forward
        height(i+1) = height(i)-fs(i)+1;
        width(i+1) = width(i)-fs(i)+1;
        X1 = double(im2col(img(i), [fs(i), fs(i)], 'sliding')');
        disp(size(X1))
        [X1 M1 P1] = normalizeAndZCA(X1,M1,P1);
        X1 = triangleRect(D1*X1');
        X1 = reshape(X1, [depth(i+1), height(i+1), width(i+1)]);
        X1 = permute(X1, [2,3,1]); % fisrt layer feature maps before pooling
        %pool 1st layer
        X1_pooled = zeros(win_total, 25*depth(i+1));
        for w = 1: win_total
            w_start = w;
            w_end = w-1+25;
            win(i) = X1(:, w_start:w_end,:); % current window on 1st layer feature map
            temp = cat(1, sum(win(i)(1:5,:,:),1), sum(win(i)(6:10,:,:),1), sum(win(i)(11:15,:,:),1), sum(win(i)(16:20,:,:),1), sum(win(i)(21:25,:,:),1));
            win(i+1) = cat(2, sum(temp(:,1:5,:),2), sum(temp(:,6:10,:),2), sum(temp(:,11:15,:),2), sum(temp(:,16:20,:),2), sum(temp(:,21:25,:),2));
            win(i+1) = permute(win(i+1), [3,2,1]);
            X1_pooled(w,:) = win(i+1)(:)';
        end
    end
    
   
    
fprintf('sphereing data\n'); % subtract mean and divide by std (of the training data)
X1_pooled = bsxfun(@rdivide, bsxfun(@minus, X1_pooled, mu), sig)';
imh = 5; imw = 5; [imd_full imm]=size(X1_pooled);
imd = imd_full/(imh*imw);
data = reshape(X1_pooled, [imd, imw, imh, imm]); 
data = permute(data, [3,2,1,4]); % 4 dims are ordered as: height, width, depth, sliding-window num
scores = svmConvPredict(params, netconfig, data, 1000);
    
end
    
